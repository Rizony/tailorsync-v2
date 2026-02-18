import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static RewardedAd? _rewardedAd;

  // Replace with your actual Ad Unit IDs from AdMob
  static const String _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; 

  static void loadRewardedAd({required Function onAdLoaded}) {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          onAdLoaded();
        },
        onAdFailedToLoad: (error) => _rewardedAd = null,
      ),
    );
  }

  static void showRewardedAd({required Function onRewardEarned}) {
    if (_rewardedAd == null) {
      loadRewardedAd(onAdLoaded: () => showRewardedAd(onRewardEarned: onRewardEarned));
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewardedAd(onAdLoaded: () {}); // Preload the next one
      },
    );

    _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
      onRewardEarned();
    });
  }
}