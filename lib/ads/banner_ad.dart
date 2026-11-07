import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GameMelaAds {
  GameMelaAds._();
  static Future<void> initialize() async {
    try { await MobileAds.instance.initialize(); } catch (_) {}
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
    ad = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
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
