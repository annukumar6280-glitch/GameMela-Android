import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GameMelaAds {
  static int _completedGames = 0;
  static bool _initialized = false;
  static Future<void>? _initialization;
  static Future<void> initialize() => _initialization ??= _initialize();
  static Future<void> _initialize() async {
    try { await MobileAds.instance.initialize(); _initialized = true; } catch (_) {}
  }

  static void gameFinished() {
    if (!Platform.isAndroid || !_initialized) return;
    _completedGames++;
    if (_completedGames % 3 != 0) return;
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (value) => value.dispose(),
            onAdFailedToShowFullScreenContent: (value, error) => value.dispose(),
          );
          ad.show();
        },
        onAdFailedToLoad: (_) {},
      ),
    );
  }
}

class GameMelaBannerAd extends StatefulWidget {
  const GameMelaBannerAd({super.key});
  @override
  State<GameMelaBannerAd> createState() => _GameMelaBannerAdState();
}

class _GameMelaBannerAdState extends State<GameMelaBannerAd> {
  BannerAd? ad;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    if (!Platform.isAndroid) return;
    GameMelaAds.initialize().then((_) { if (mounted) _loadAd(); });
  }

  void _loadAd() {
    if (!mounted) return;
    ad = BannerAd(
      adUnitId: 'ca-app-pub-9742595266312511/9826282800',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (value) { if (mounted) setState(() => loaded = true); },
        onAdFailedToLoad: (value, error) { value.dispose(); },
      ),
    )..load();
  }

  @override
  void dispose() { ad?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (!loaded || ad == null) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(child: SizedBox(width: 320, height: 50, child: AdWidget(ad: ad!))),
    );
  }
}
