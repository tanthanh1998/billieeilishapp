import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdManager {
  final List<BannerAd?> _bannerAds = [];
  int adLoadCount = 0;

  BannerAd createBannerAd(String adUnitId) {
    final ad = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Banner Ad Loaded');
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner Ad Failed to Load: $error');
          ad.dispose(); // Dispose of the ad if it fails to load
        },
      ),
    );
    ad.load(); // Load the ad
    return ad;
  }

  void loadAds(String adUnitId, int numberOfAds) {
    for (int i = 0; i < numberOfAds; i++) {
      _bannerAds.add(createBannerAd(adUnitId));
      adLoadCount++;
    }
  }

  List<BannerAd?> get bannerAds => _bannerAds;

  void dispose() {
    for (var ad in _bannerAds) {
      ad?.dispose();
    }
  }
}
