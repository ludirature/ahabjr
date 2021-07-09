import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';

import 'globalvars.dart';

Ads2 theads2 = Ads2();

class Ads2 {
  // int rewardcounter = 0;
  // bool isfirstday = false;
  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;

  bool ishidden = false;
  bool isnaaybanner = false;
  bool isdebug = false;
  // bool isbannershowing = false;

  BuildContext acontext;

  String anchor = "";
  String bannersize = "";

  String appid = FirebaseAdMob.testAppId;
  String rewardid = RewardedVideoAd.testAdUnitId;
  String bannerid = BannerAd.testAdUnitId;
  String interstitialid = InterstitialAd.testAdUnitId;

  bool ismanaagvideo = false;

  // String appid = "ca-app-pub-1547741271935331~9899365465";
  // String rewardid = "ca-app-pub-3003521480953457/5736903683";
  // String bannerid = "ca-app-pub-1547741271935331/2020875442";
  // String interstitialid = "ca-app-pub-3003521480953457/6083796117";

  Future initialize(bool visdebug) async {
    isdebug = visdebug;
    if (visdebug) {
      await FirebaseAdMob.instance.initialize(
        appId: FirebaseAdMob.testAppId,
      );
    } else if (isworkspace) {
      await FirebaseAdMob.instance.initialize(
        appId: FirebaseAdMob.testAppId,
      );
    } else {
      await FirebaseAdMob.instance.initialize(
        appId: appid,
      );
    }
  }

  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: <String>[],
    keywords: <String>['games', 'war', 'car', 'racing', 'shooting', 'strategy'],
    contentUrl: 'http://foo.com/bar.html',
    childDirected: false,
    nonPersonalizedAds: true,
  );

  Future showvideo() async {
    await RewardedVideoAd.instance
        .load(adUnitId: rewardid, targetingInfo: targetingInfo);

    RewardedVideoAd.instance.listener = (RewardedVideoAdEvent event,
        {String rewardType, int rewardAmount}) async {
      // print("asdfasdfasdfasdfasdfasdfasdfasdfasdfsadf"  +    event.toString());
      // rewardcounter = 0;

      if (event == RewardedVideoAdEvent.rewarded) {
        ismanaagvideo = true;
        hideBannerAd();
        Future.delayed(Duration(minutes: 30), () {
          ismanaagvideo = false;
          // showBannerAd(false);
        });
      }
      if (event == RewardedVideoAdEvent.loaded) {
        Future.delayed(Duration(seconds: 1), () {
          RewardedVideoAd.instance.show();
        });
      }

      if (event == RewardedVideoAdEvent.failedToLoad) {
        if (ismanaagvideo == false) {
          ismanaagvideo = true;
          hideBannerAd();
          Future.delayed(Duration(minutes: 5), () {
            ismanaagvideo = false;
            // showBannerAd(false);
          });
        }
      }
    };
  }

  BannerAd _createBannerAd() {
    // print("asdfasdfasdf");
    return BannerAd(
      adUnitId: isdebug || isworkspace ? BannerAd.testAdUnitId : bannerid,
      // adUnitId: "ca-app-pub-3003521480953457/2421413587",

      size: bannersize == "banner"
          ? AdSize.banner
          : bannersize == "fullBanner"
              ? AdSize.fullBanner
              : bannersize == "largeBanner"
                  ? AdSize.largeBanner
                  : bannersize == "leaderboard"
                      ? AdSize.leaderboard
                      : bannersize == "mediumRectangle"
                          ? AdSize.mediumRectangle
                          : bannersize == "smartBanner"
                              ? AdSize.smartBanner
                              : AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
        isnaaybanner = false;
        //
        if (ishidden) {
          hideBannerAd();
        } else {
          if (event == MobileAdEvent.loaded) {
            _bannerAd.show(anchorOffset: 0.0, anchorType: AnchorType.top);
            isnaaybanner = true;
          }
          if (event == MobileAdEvent.failedToLoad) {
            hideBannerAd();
          }
        }
        // }
      },
    );
  }

  BannerAd _createBannerAd2() {
    // print("asdfasdfasdf");
    return BannerAd(
      adUnitId: isdebug || isworkspace ? BannerAd.testAdUnitId : bannerid,
      // adUnitId: "ca-app-pub-3003521480953457/2421413587",

      size: bannersize == "banner"
          ? AdSize.banner
          : bannersize == "fullBanner"
              ? AdSize.fullBanner
              : bannersize == "largeBanner"
                  ? AdSize.largeBanner
                  : bannersize == "leaderboard"
                      ? AdSize.leaderboard
                      : bannersize == "mediumRectangle"
                          ? AdSize.mediumRectangle
                          : bannersize == "smartBanner"
                              ? AdSize.smartBanner
                              : AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
        isnaaybanner = false;
        //
        if (ishidden) {
          hideBannerAd();
        } else {
          if (event == MobileAdEvent.loaded) {
            _bannerAd.show(anchorOffset: 0.0, anchorType: AnchorType.bottom);
            isnaaybanner = true;
          }
          if (event == MobileAdEvent.failedToLoad) {
            hideBannerAd();
          }
        }
        // }
      },
    );
  }

  InterstitialAd _createInterstitialAd() {
    return InterstitialAd(
      // Replace the testAdUnitId with an ad unit id from the AdMob dash.
      // https://developers.google.com/admob/android/test-ads
      // https://developers.google.com/admob/ios/test-ads
      adUnitId: interstitialid,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("InterstitialAd event is $event");
      },
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd == null) {
      _interstitialAd = _createInterstitialAd();
    }
  }

  void showBannerAd(bool istop) {
    // isbannershowing = true;
    // if (ismanaagvideo && istop == false) return;
    // if (isbannershowing) return;
    // print("showbanner" + "        " + theads2.bannerid);

    if (_bannerAd == null)
      _bannerAd = istop ? _createBannerAd() : _createBannerAd2();
    ishidden = false;

    _bannerAd.load();
  }

  Future hideBannerAd() async {
    // isbannershowing = false;
    print("hide" + "        " + theads2.appid);
    if (_bannerAd != null) {
      ishidden = true;
      await _bannerAd.dispose();
      _bannerAd = null;
      isnaaybanner = false;
    }
  }
}
