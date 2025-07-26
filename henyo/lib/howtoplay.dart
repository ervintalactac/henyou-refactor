import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';
import 'debug.dart';
import 'helper.dart';

class HowToPlayPage extends StatefulWidget {
  const HowToPlayPage({super.key});

  @override
  HowToPlay createState() => HowToPlay();
}

class HowToPlay extends State<HowToPlayPage> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    resetInfoData();
    super.initState();

    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.fullBanner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debug('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    player3.playBackspaceSound();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // double screenW = MediaQuery.of(context).size.width;
    // final bool widerScreen = screenW > 374.0;
    return lightBulbBackgroundWidget(
        context,
        'How To Play?',
        Column(
            //mainAxisSize: MainAxisSize.min,
            children: [
              if (_bannerAd != null)
                Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                )
              else
                (SizedBox(height: bannerHeight)),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Text(
                      textScaler: customTextScaler(context, max: 2.0),
                      style: TextStyle(
                          fontFamily: fontName,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkTextColor),
                      globalMessages.getHowToPlayMessage(wordLocale)),
                ),
              ),
              Text(
                  style:
                      textStyleAutoScaledByPercent(context, 12, darkTextColor),
                  textScaler: defaultTextScaler(context),
                  globalMessages.getScoreBreakDownMessage()),
              Container(
                color: Colors.transparent,
                child: Center(
                  child: defaultBackButton(context, backButtonFontScale, .5),
                ),
              ),
              const SizedBox(height: 10),
            ]));
  }
}
