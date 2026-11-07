create schema if not exists private;

create table if not exists private.rewarded_ad_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  nonce uuid not null unique default gen_random_uuid(),
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '15 minutes'),
  used_at timestamptz,
  transaction_id text unique
);

alter table private.rewarded_ad_sessions enable row level security;
revoke all on private.rewarded_ad_sessions from public, anon, authenticated;
grant usage on schema private to service_role;

create or replace function private.create_rewarded_ad_session(p_user_id uuid)
returns uuid language plpgsql security definer set search_path = ''
as $$
declare v_nonce uuid;
begin
  if p_user_id is null then raise exception 'Missing player account'; end if;
  if (select count(*) from private.rewarded_ad_sessions s
      where s.user_id = p_user_id and s.created_at > now() - interval '10 minutes') >= 5
  then raise exception 'Too many reward ad attempts. Please wait.'; end if;
  insert into private.rewarded_ad_sessions(user_id) values (p_user_id)
  returning nonce into v_nonce;
  return v_nonce;
end;
$$;

create or replace function private.process_admob_reward(
  p_nonce uuid, p_transaction_id text, p_reward_amount integer
)
returns bigint language plpgsql security definer set search_path = ''
as $$
declare v_user_id uuid; v_balance bigint; v_existing_transaction text;
begin
  if p_reward_amount <> 20 then raise exception 'Unexpected reward amount'; end if;
  if p_transaction_id is null or length(p_transaction_id) < 8 then
    raise exception 'Invalid AdMob transaction';
  end if;
  select s.user_id, s.transaction_id into v_user_id, v_existing_transaction
  from private.rewarded_ad_sessions s
  where s.nonce = p_nonce and s.expires_at > now()
  for update;
  if v_user_id is null then raise exception 'Reward session missing or expired'; end if;
  if v_existing_transaction is not null then
    if v_existing_transaction = p_transaction_id then
      select w.balance into v_balance from public.coin_wallets w where w.user_id = v_user_id;
      return v_balance;
    end if;
    raise exception 'Reward session already used';
  end if;
  update public.coin_wallets set balance = balance + 20, updated_at = now()
  where user_id = v_user_id returning balance into v_balance;
  if v_balance is null then raise exception 'Player wallet not found'; end if;
  insert into public.coin_transactions(user_id, amount, reason, reference_id)
  values (v_user_id, 20, 'rewarded_ad', 'admob:' || p_transaction_id);
  update private.rewarded_ad_sessions set used_at = now(), transaction_id = p_transaction_id
  where nonce = p_nonce;
  return v_balance;
end;
$$;

create or replace function public.create_rewarded_ad_session(p_user_id uuid)
returns uuid language sql security invoker set search_path = ''
as $$ select private.create_rewarded_ad_session(p_user_id); $$;

create or replace function public.process_admob_reward(
  p_nonce uuid, p_transaction_id text, p_reward_amount integer
)
returns bigint language sql security invoker set search_path = ''
as $$ select private.process_admob_reward(p_nonce, p_transaction_id, p_reward_amount); $$;

revoke all on function private.create_rewarded_ad_session(uuid) from public, anon, authenticated;
revoke all on function private.process_admob_reward(uuid, text, integer) from public, anon, authenticated;
revoke all on function public.create_rewarded_ad_session(uuid) from public, anon, authenticated;
revoke all on function public.process_admob_reward(uuid, text, integer) from public, anon, authenticated;
grant execute on function private.create_rewarded_ad_session(uuid) to service_role;
grant execute on function private.process_admob_reward(uuid, text, integer) to service_role;
grant execute on function public.create_rewarded_ad_session(uuid) to service_role;
grant execute on function public.process_admob_reward(uuid, text, integer) to service_role;
