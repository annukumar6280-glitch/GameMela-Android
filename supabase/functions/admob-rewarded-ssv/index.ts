import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const PROJECT_URL = Deno.env.get("SUPABASE_URL")!;
const publishableKeys = JSON.parse(Deno.env.get("SUPABASE_PUBLISHABLE_KEYS") ?? "{}");
const secretKeys = JSON.parse(Deno.env.get("SUPABASE_SECRET_KEYS") ?? "{}");
const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") ?? publishableKeys.default;
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? secretKeys.default;
const REWARDED_AD_UNIT = "ca-app-pub-9742595266312511/1824715882";
const EXPECTED_REWARD = 20;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
};

function reply(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function decodeBase64(value: string): Uint8Array {
  const normalized = value.replace(/-/g, "+").replace(/_/g, "/");
  const padded = normalized + "=".repeat((4 - normalized.length % 4) % 4);
  const binary = atob(padded);
  return Uint8Array.from(binary, (c) => c.charCodeAt(0));
}

function readDerLength(bytes: Uint8Array, state: { offset: number }): number {
  const first = bytes[state.offset++];
  if (first < 0x80) return first;
  const count = first & 0x7f;
  if (count < 1 || count > 2) throw new Error("Invalid DER length");
  let length = 0;
  for (let i = 0; i < count; i++) length = (length << 8) | bytes[state.offset++];
  return length;
}

function derEcdsaToRaw(der: Uint8Array): Uint8Array {
  const state = { offset: 0 };
  if (der[state.offset++] !== 0x30) throw new Error("Invalid ECDSA signature");
  readDerLength(der, state);
  const readInteger = () => {
    if (der[state.offset++] !== 0x02) throw new Error("Invalid ECDSA integer");
    const length = readDerLength(der, state);
    let value = der.slice(state.offset, state.offset + length);
    state.offset += length;
    while (value.length > 32 && value[0] === 0) value = value.slice(1);
    if (value.length > 32) throw new Error("ECDSA integer too large");
    const padded = new Uint8Array(32);
    padded.set(value, 32 - value.length);
    return padded;
  };
  const r = readInteger();
  const s = readInteger();
  const raw = new Uint8Array(64);
  raw.set(r, 0);
  raw.set(s, 32);
  return raw;
}

async function verifyAdMobSignature(rawQuery: string, params: URLSearchParams): Promise<boolean> {
  const signatureMarker = rawQuery.lastIndexOf("&signature=");
  const keyMarker = rawQuery.lastIndexOf("&key_id=");
  if (signatureMarker <= 0 || keyMarker <= signatureMarker) return false;
  if (keyMarker + 1 >= rawQuery.length) return false;

  const signature = params.get("signature");
  const keyId = params.get("key_id");
  if (!signature || !keyId) return false;

  const signedContent = new TextEncoder().encode(rawQuery.slice(0, signatureMarker));
  const keysResponse = await fetch("https://www.gstatic.com/admob/reward/verifier-keys.json");
  if (!keysResponse.ok) throw new Error("Could not retrieve AdMob verification keys");
  const keyData = await keysResponse.json();
  const key = (keyData.keys ?? []).find((item: { keyId: number }) => String(item.keyId) === keyId);
  if (!key?.base64) return false;

  const publicKey = await crypto.subtle.importKey(
    "spki",
    decodeBase64(key.base64),
    { name: "ECDSA", namedCurve: "P-256" },
    false,
    ["verify"],
  );
  const derSignature = decodeBase64(signature);
  const rawSignature = derEcdsaToRaw(derSignature);
  return await crypto.subtle.verify(
    { name: "ECDSA", hash: "SHA-256" },
    publicKey,
    rawSignature,
    signedContent,
  );
}

async function handleAdMobCallback(requestUrl: URL) {
  const rawQuery = requestUrl.search.startsWith("?")
    ? requestUrl.search.slice(1)
    : requestUrl.search;
  const params = new URLSearchParams(rawQuery);

  // AdMob's dashboard "Verify URL" probe uses documented placeholder values.
  // Acknowledge this probe without verifying a signature or crediting any coins.
  // Real reward callbacks must always pass cryptographic signature verification below.
  if (
    params.get("ad_unit") === "1234567890" &&
    params.get("transaction_id") === "123456789" &&
    (params.get("reward_item") ?? "").toLowerCase() === "reward" &&
    params.get("reward_amount") === "20"
  ) {
    console.log("AdMob dashboard verification probe acknowledged; no reward credited.");
    return reply({ success: true, verification_test: true }, 200);
  }

  if (!(await verifyAdMobSignature(rawQuery, params))) {
    return reply({ error: "Invalid AdMob signature" }, 403);
  }

  const adUnit = params.get("ad_unit");
  const rewardAmount = Number(params.get("reward_amount"));
  const rewardItem = (params.get("reward_item") ?? "").toLowerCase();
  const nonce = params.get("custom_data");
  const transactionId = params.get("transaction_id");
  const timestamp = Number(params.get("timestamp"));

  if (adUnit !== REWARDED_AD_UNIT || rewardAmount !== EXPECTED_REWARD ||
      !["coin", "coins"].includes(rewardItem) || !nonce || !transactionId ||
      !Number.isFinite(timestamp)) {
    return reply({ error: "Reward callback does not match the configured ad" }, 400);
  }

  const nowMs = Date.now();
  if (timestamp < nowMs - 24 * 60 * 60 * 1000 || timestamp > nowMs + 5 * 60 * 1000) {
    return reply({ error: "Reward callback timestamp is outside the accepted window" }, 400);
  }

  if (!SERVICE_KEY) return reply({ error: "Server reward service is not configured" }, 500);
  const admin = createClient(PROJECT_URL, SERVICE_KEY, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data, error } = await admin.rpc("process_admob_reward", {
    p_nonce: nonce,
    p_transaction_id: transactionId,
    p_reward_amount: EXPECTED_REWARD,
  });
  if (error) {
    console.error("Reward processing failed:", error.message);
    return reply({ error: "Reward processing failed" }, 500);
  }
  return reply({ success: true, balance: data });
}

async function createRewardSession(request: Request) {
  const authHeader = request.headers.get("Authorization") ?? "";
  const token = authHeader.replace(/^Bearer\s+/i, "");
  if (!token || !ANON_KEY || !SERVICE_KEY) {
    return reply({ error: "Sign in is required to request a reward" }, 401);
  }

  const userClient = createClient(PROJECT_URL, ANON_KEY, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: userData, error: userError } = await userClient.auth.getUser(token);
  if (userError || !userData.user) {
    return reply({ error: "Your session has expired. Please sign in again." }, 401);
  }

  const admin = createClient(PROJECT_URL, SERVICE_KEY, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data, error } = await admin.rpc("create_rewarded_ad_session", {
    p_user_id: userData.user.id,
  });
  if (error || !data) {
    console.error("Reward session creation failed:", error?.message);
    return reply({ error: "Could not start a rewarded ad session" }, 429);
  }
  return reply({ custom_data: data });
}

Deno.serve(async (request: Request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  try {
    if (request.method === "GET") return await handleAdMobCallback(new URL(request.url));
    if (request.method === "POST") return await createRewardSession(request);
    return reply({ error: "Method not allowed" }, 405);
  } catch (error) {
    console.error("Rewarded ad endpoint error:", error);
    return reply({ error: "Internal server error" }, 500);
  }
});
