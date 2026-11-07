import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GameMelaBackend {
  GameMelaBackend._();

  static const String _url = 'https://pvmmhoqurmbaiuumaltw.supabase.co';
  static const String _publishableKey = 'sb_publishable_Ee4L_yvqoJs-YEyUfNgOsg_o2IppwAq';

  static final ValueNotifier<int> coins = ValueNotifier<int>(0);
  static bool ready = false;
  static String? lastError;
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(url: _url, publishableKey: _publishableKey);
      ready = client.auth.currentUser != null;
      if (ready) await refreshCoins();
    } catch (error) {
      lastError = error.toString();
      ready = false;
    }
  }


  static Future<bool> signIn(String email, String password) async {
    await client.auth.signInWithPassword(email: email.trim(), password: password);
    ready = client.auth.currentUser != null;
    if (ready) await refreshCoins();
    return ready;
  }

  static Future<bool> signUp(String email, String password) async {
    final response = await client.auth.signUp(email: email.trim(), password: password);
    ready = response.session != null && client.auth.currentUser != null;
    if (ready) await refreshCoins();
    return ready;
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
    ready = false;
    coins.value = 0;
  }

  static Future<int> refreshCoins() async {
    if (!ready) return coins.value;
    try {
      final row = await client.from('coin_wallets').select('balance')
          .eq('user_id', client.auth.currentUser!.id).maybeSingle();
      final value = (row?['balance'] as num?)?.toInt() ?? 0;
      coins.value = value;
      return value;
    } catch (error) {
      lastError = error.toString();
      return coins.value;
    }
  }

  static Future<int?> claimReward(String gameKey, int score) async {
    if (!ready) return null;
    try {
      final value = await client.rpc('claim_game_coins', params: {
        'p_game_key': gameKey,
        'p_score': score,
      });
      coins.value = (value as num).toInt();
      return coins.value;
    } catch (error) {
      lastError = error.toString();
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> loadVehicles() async {
    if (!ready) return [];
    final rows = await client.from('garage_vehicles')
        .select('id,vehicle_type,model_id,upgrades,durability,purchased_at')
        .eq('user_id', client.auth.currentUser!.id)
        .order('purchased_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<void> purchaseVehicle(String type, String modelId) async {
    final value = await client.rpc('purchase_gamemela_vehicle', params: {
      'p_vehicle_type': type,
      'p_model_id': modelId,
    });
    coins.value = (value as num).toInt();
  }

  static Future<void> upgradeVehicle(String vehicleId, String upgrade) async {
    final value = await client.rpc('upgrade_gamemela_vehicle', params: {
      'p_vehicle_id': vehicleId,
      'p_upgrade': upgrade,
    });
    coins.value = (value as num).toInt();
  }

  static Future<void> repairVehicle(String vehicleId) async {
    final value = await client.rpc('repair_gamemela_vehicle', params: {
      'p_vehicle_id': vehicleId,
    });
    coins.value = (value as num).toInt();
  }

  static Future<void> saveProgress(String gameKey, int score, {int level = 1}) async {
    if (!ready) return;
    final userId = client.auth.currentUser!.id;
    final previous = await client.from('game_progress')
        .select('best_score,level')
        .eq('user_id', userId)
        .eq('game_key', gameKey)
        .maybeSingle();
    final bestScore = score > ((previous?['best_score'] as num?)?.toInt() ?? 0)
        ? score
        : ((previous?['best_score'] as num?)?.toInt() ?? 0);
    final bestLevel = level > ((previous?['level'] as num?)?.toInt() ?? 1)
        ? level
        : ((previous?['level'] as num?)?.toInt() ?? 1);
    await client.from('game_progress').upsert({
      'user_id': userId,
      'game_key': gameKey,
      'level': bestLevel,
      'best_score': bestScore,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id,game_key');
  }
}
