import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:developer' as developer;
import 'dart:io';

class AdService {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  BannerAd? get bannerAd => _bannerAd;
  bool get isAdLoaded => _isAdLoaded;

  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      developer.log('MobileAds initialized');
      await loadBannerAd();
    } catch (e) {
      developer.log('Error initializing AdMob: $e');
    }
  }

  Future<void> loadBannerAd() async {
    String? adUnitId;

    if (kDebugMode) {
      // Always use Google's official test Ad Unit IDs in debug mode
      // to avoid "No fill" errors and prevent account suspension
      if (Platform.isAndroid) {
        adUnitId = 'ca-app-pub-3940256099942544/6300978111';
      } else if (Platform.isIOS) {
        adUnitId = 'ca-app-pub-3940256099942544/2934735716';
      }
      developer.log('Debug mode: Using test Ad Unit ID: $adUnitId');
    } else {
      adUnitId = dotenv.env['ADMOB_BANNER_ID'];
      developer.log('Release mode: Using production Ad Unit ID');
    }

    if (adUnitId == null || adUnitId.isEmpty) {
      developer.log('AdMob Banner ID not found');
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isAdLoaded = true;
          developer.log('Banner Ad loaded successfully');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isAdLoaded = false;
          developer.log('Banner Ad failed to load: $error');
        },
      ),
    );

    await _bannerAd!.load();
  }

  void dispose() {
    _bannerAd?.dispose();
  }
}
