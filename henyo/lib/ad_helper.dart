import 'dart:io';

import 'helper.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  static bool henyogamemaker = true;
  static String get bannerAdUnitId {
    if (kDebugMode || globalSettings.showTestAds) {
      return 'ca-app-pub-3940256099942544/6300978111'; // test
    }
    if (Platform.isAndroid) {
      return globalSettings.bannerAdUnitIdAndroid;
      // if (henyogamemaker) {
      //   return 'ca-app-pub-9660306973957595/9151709168'; // henyogamemaker
      // } else {
      //   return 'ca-app-pub-5434308461438291/8909668645'; // esaflip
      // }
    } else if (Platform.isIOS) {
      return globalSettings.bannerAdUnitIdIOS;
      // if (henyogamemaker) {
      //   return 'ca-app-pub-9660306973957595/6659361470'; // henyogamemaker
      // } else {
      //   return 'ca-app-pub-5434308461438291/6189234012'; // esaflip
      // }
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get nativeAdUnitId {
    if (kDebugMode || globalSettings.showTestAds) {
      return 'ca-app-pub-3940256099942544/2247696110'; // test
    }
    if (Platform.isAndroid) {
      return globalSettings.nativeAdUnitIdAndroid;
      // if (henyogamemaker) {
      //   return 'ca-app-pub-9660306973957595/4392290789'; // henyogamemaker
      // } else {
      //   return 'ca-app-pub-5434308461438291/8350738789'; // esaflip
      // }
    } else if (Platform.isIOS) {
      return globalSettings.nativeAdUnitIdIOS;
      // if (henyogamemaker) {
      //   return 'ca-app-pub-9660306973957595/8602998536'; // henyogamemaker
      // } else {
      //   return 'ca-app-pub-5434308461438291/2867321707'; // esaflip
      // }
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get interstitialAdUnitId {
    if (kDebugMode || globalSettings.showTestAds) {
      return 'ca-app-pub-3940256099942544/8691691433'; // test
    }
    if (Platform.isAndroid) {
      return globalSettings.interstitialAdUnitIdAndroid;
      // if (henyogamemaker) {
      //   return 'ca-app-pub-9660306973957595/6962575815'; // henyogamemaker
      // } else {
      //   return "ca-app-pub-5434308461438291/2092096974"; // esaflip
      // }
      //return "ca-app-pub-3940256099942544/1033173712";
    } else if (Platform.isIOS) {
      return globalSettings.interstitialAdUnitIdIOS;
      // if (henyogamemaker) {
      //   return 'ca-app-pub-9660306973957595/1323274318'; // henyogamemaker
      // } else {
      //   return "ca-app-pub-5434308461438291/9451620354"; // esaflip
      // }
      //return "ca-app-pub-3940256099942544/4411468910";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

// iOS
// ca-app-pub-5434308461438291~6701651168
  static String get rewardedAdUnitId {
    if (kDebugMode || globalSettings.showTestAds) {
      return 'ca-app-pub-3940256099942544/5224354917'; // test
    }
    if (Platform.isAndroid) {
      return globalSettings.rewardedAdUnitIdAndroid;
      // if (henyogamemaker) {
      //   return 'ca-app-pub-9660306973957595/7649009516'; // henyogamemaker
      // } else {
      //   return "ca-app-pub-5434308461438291/4213097892"; // esaflip
      // }
    } else if (Platform.isIOS) {
      return globalSettings.rewardedAdUnitIdIOS;
      // if (henyogamemaker) {
      //   return 'ca-app-pub-9660306973957595/2504494041'; // henyogamemaker
      // } else {
      //   return "ca-app-pub-5434308461438291/9307881590"; // esaflip
      // }
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

// android
// ca-app-pub-5434308461438291~8541105194
  static String get rewardedInterstitialAdUnitId {
    if (kDebugMode || globalSettings.showTestAds) {
      return 'ca-app-pub-3940256099942544/5354046379'; // test
    }
    if (Platform.isAndroid) {
      return globalSettings.rewardedInterstitialAdUnitIdAndroid;
      // if (henyogamemaker) {
      //   return 'ca-app-pub-9660306973957595/8962091187'; // henyogamemaker
      // } else {
      //   return "ca-app-pub-5434308461438291/2491740545"; // esaflip
      // }
    } else if (Platform.isIOS) {
      return globalSettings.rewardedInterstitialAdUnitIdIOS;
      // if (henyogamemaker) {
      //   return 'ca-app-pub-9660306973957595/6443739056'; // henyogamemaker
      // } else {
      //   return "ca-app-pub-5434308461438291/7803228231"; // esaflip
      // }
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get appOpenAdUnitId {
    if (kDebugMode || globalSettings.showTestAds) {
      return 'ca-app-pub-3940256099942544/341983529'; // test
    }
    if (Platform.isAndroid) {
      return globalSettings.appOpenAdUnitIdAndroid;
      // if (henyogamemaker) {
      //   return 'ca-app-pub-9660306973957595/9453045779'; // henyogamemaker
      // } else {
      //   return "ca-app-pub-5434308461438291/1587644021"; // esaflip
      // }
    } else if (Platform.isIOS) {
      return globalSettings.appOpenAdUnitIdIOS;
      // if (henyogamemaker) {
      //   return 'ca-app-pub-9660306973957595/4334496756'; // henyogamemaker
      // } else {
      //   return "ca-app-pub-5434308461438291/4783038608"; // esaflip
      // }
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}

Future<InitializationStatus> initGoogleMobileAds() {
  return MobileAds.instance.initialize();
}
