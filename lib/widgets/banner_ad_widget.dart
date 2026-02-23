import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final adService = context.read<AdService>();

    if (!adService.isAdLoaded || adService.bannerAd == null) {
      // Return a small space if ad hasn't loaded to avoid layout shifts once it does
      // or just return empty for a cleaner look.
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: adService.bannerAd!.size.width.toDouble(),
      height: adService.bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: adService.bannerAd!),
    );
  }
}
