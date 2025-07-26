import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:music_app/utils/const.dart';

class AdManager {
  static late BannerAd _bannerAd;
  static bool _isBannerAdReady = false;

  // Phương thức để khởi tạo quảng cáo banner
  static void loadBannerAd(
      {required Function onAdLoaded, required Function onAdFailedToLoad}) {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId, // Thay bằng adUnitId của bạn
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdReady = true;
          onAdLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          print('BannerAd failed to load: $error');
          _isBannerAdReady = false;
          ad.dispose();
          onAdFailedToLoad();
        },
      ),
    )..load();
  }

  // Phương thức để lấy widget quảng cáo
  static Widget getBannerAdWidget() {
    if (_isBannerAdReady) {
      return SizedBox(
        width: _bannerAd.size.width.toDouble(),
        height: _bannerAd.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd),
      );
    } else {
      return const SizedBox
          .shrink(); // Trả về widget rỗng khi quảng cáo chưa sẵn sàng
    }
  }

  // Dispose quảng cáo
  static void disposeAd() {
    _bannerAd.dispose();
  }
}
