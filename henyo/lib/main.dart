import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:HenyoU/ad_rewards.dart';
import 'package:HenyoU/entities.dart';
import 'package:HenyoU/partymode.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';
import 'ad_helper.dart';
import 'debug.dart';
import 'gamepage.dart';
import 'helper.dart';
import 'howtoplay.dart';
import 'leaderboard.dart';
import 'multiplayerpage.dart';
import 'myobjectbox.dart';
import 'settingspage.dart';
import 'toggle.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  int start = DateTime.now().millisecond;
  objectBox = await ObjectBox.create();
  initGoogleMobileAds();
  // debugRepaintRainbowEnabled = kDebugMode;
  debug('done loading main in ${DateTime.now().millisecond - start}ms');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    internetSubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      // whenever connection status is changed.
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.other) {
        //connection is from mobile or wifi
        isOffline = false;
      } else if (result == ConnectivityResult.none) {
        //there is no internet connection
        isOffline = true;
      }
    });
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        theme: ThemeData(
            scaffoldBackgroundColor: appBackgroundColor,
            brightness: Brightness.light),
        //darkTheme: ThemeData(brightness: Brightness.dark),
        home: AnimatedSplashScreen.withScreenFunction(
          splashIconSize: MediaQuery.of(context).size.height / 1.7,
          backgroundColor: appBackgroundColor,
          splash:
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              height: MediaQuery.of(context).size.height / 2,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/lightbulb_brain2.png'),
                  fit: BoxFit.fitWidth,
                ),
                shape: BoxShape.rectangle,
              ),
              child:
                  // isOffline
                  //     ? displayOfflineMessage()
                  //     :
                  const Text(''),
            ),
            const SizedBox(
              height: 20,
            ),
            DefaultTextStyle(
              style: TextStyle(
                fontSize: scaledFontSize(context),
              ),
              child: AnimatedTextKit(
                animatedTexts: [
                  WavyAnimatedText('Loading app data...',
                      speed: const Duration(milliseconds: 150),
                      textStyle: TextStyle(
                          fontSize: calculateFixedFontSize(context) *
                              scaledFontSize(context),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF577299))),
                ],
                isRepeatingAnimation: true,
              ),
            ),
          ]),
          screenFunction: () async {
            if (isOffline) {
              return displayOfflineMessage(context,
                  'Online connection required to play this game. Please ensure you\'re connected to the internet to continue. Option for offline play is being considered!\n\nEnable internet access then restart the app to try again.');
            }

            // don't change the order of these
            await generateKeys();
            await loadGlobalSettings(); // may need to await these two loads if messages and settings
            await loadGlobalMessages(); // are mangled
            await loadUserSettings();
            await loadUserData();
            if (!isOffline) {
              await loadUserRecord();
              // if (!kDebugMode) {
              fetchLatestJsons();
              // }
            }
            loadWordsHistory();
            fetchRecords().then((value) => records = value);
            getRooms();
            checkForNewAblyApiKey();
            getServiceAccountKey();
            return const LandingPage();
          },
          splashTransition: SplashTransition.scaleTransition,
          //pageTransitionType: PageTransitionType.scale,
        ));
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});
  // bool isDialogShow;
  // LandingPage({this.isDialogShow});
  @override
  Landing createState() => Landing();
}

class Landing extends State<LandingPage> with TickerProviderStateMixin {
  BannerAd? _bannerAd;
  AnimationController? _animationController;
  Animation? _animation;

  @override
  void initState() {
    resetInfoData();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10));
    _animationController!.repeat(reverse: true);
    _animation = Tween(begin: 2.0, end: 15.0).animate(_animationController!)
      ..addListener(() {
        setState(() {});
      });

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

    // let's load user data here so the start up doesn't take forever to load
    // loadUserData().then((value) => null);

    // load what's new dialog if there's a new version available
    !isOffline
        ? fetchWhatsNew().then((value) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (whatsNewTimestamp > userSettings.getSplashPageMessageTS()) {
                showGenericAlertDialog(context, whatsNewTitle, whatsNewMessage,
                    '', 'Continue', () {});
                userSettings.setSplashPageMessageTS(whatsNewTimestamp);
                objectBox.storeUserSettings(userSettings);
              }
            });
          })
        : null;

    int lastTimeStamp = DateTime.now().millisecondsSinceEpoch +
        globalSettings.rewardedAdNextAvailableInMs;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setExtraDataRecordEntry('fontScaleFactor', scaledFontSize(context));
      monitorTokenCount().listen((c) {
        if (c < globalSettings.lowTokenCountThreshold &&
            totalScore > 0 &&
            DateTime.now().millisecondsSinceEpoch > lastTimeStamp) {
          debug('Detecting low credit count. Showing user awarded ad.');
          showAdDialog(context);
        }
      });
      if (totalScore == 0) return;
      int dayLastRewarded = DateTime.fromMillisecondsSinceEpoch(
              objectBox.getUserSettings().getDailyRewardLastGiven())
          .day;
      int monthLastRewarded = DateTime.fromMillisecondsSinceEpoch(
              objectBox.getUserSettings().getDailyRewardLastGiven())
          .month;
      if (DateTime.now().day != dayLastRewarded ||
          DateTime.now().month != monthLastRewarded) {
        showGenericAlertDialog(
            context,
            'Daily Token Rewards',
            globalMessages.getDailyTokenRewardMessage(wordLocale).replaceFirst(
                '\$dailyTokenReward', '${globalSettings.dailyTokenReward}'),
            '',
            'Continue',
            () {});
        userSettings
            .setDailyRewardLastGiven(DateTime.now().millisecondsSinceEpoch);
        objectBox.storeUserSettings(userSettings);
        setUserCredits(globalSettings.dailyTokenReward);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // process weekly rewards
      WeeklyWinners winners = await getWeeklyWinnersPreviousWeek();
      String message = '';
      if (winners.toJson().toString().contains(username)) {
        if (winners.firstPlace.contains(username)) {
          if (!winners.firstPlace.contains('unclaimed')) return;
          var data = jsonDecode(winners.firstPlace);
          var reward = int.parse((data[username])['amount']);
          setUserCredits(reward);
          message = globalMessages
              .getWeeklyWinnerFirstPlaceMessage(wordLocale)
              .replaceFirst('\$reward', '$reward');
          winners.firstPlace =
              winners.firstPlace.replaceAll('unclaimed', 'claimed');
          winners.secondPlace = '';
          winners.thirdPlace = '';
        } else if (winners.secondPlace.contains(username)) {
          if (!winners.secondPlace.contains('unclaimed')) return;
          var data = jsonDecode(winners.secondPlace);
          var reward = int.parse((data[username])['amount']);
          setUserCredits(reward);
          winners.secondPlace =
              winners.secondPlace.replaceAll('unclaimed', 'claimed');
          winners.firstPlace = '';
          winners.thirdPlace = '';
          message = globalMessages
              .getWeeklySecondPlaceMessage(wordLocale)
              .replaceFirst('\$reward', '$reward');
        } else if (winners.thirdPlace.contains(username)) {
          if (!winners.thirdPlace.contains('unclaimed')) return;
          var data = jsonDecode(winners.thirdPlace);
          var reward = int.parse((data[username])['amount']);
          setUserCredits(reward);
          winners.thirdPlace =
              winners.thirdPlace.replaceAll('unclaimed', 'been_claimed');
          winners.firstPlace = '';
          winners.secondPlace = '';
          message = globalMessages
              .getWeeklyWinnerThirdPlaceMessage(wordLocale)
              .replaceFirst('\$reward', '$reward');
        }
        var response = await updateWeeklyWinnersPreviousWeek(winners);
        debug(response.body);
        if (mounted) {
          showGenericAlertDialog(
              context, 'Weekly Tournament Winner', message, '', 'OK', () {});
        }
      }
    });

    monitorTokenCount().listen((c) {
      if (c < 500) {
        showDialog(
            barrierColor: Colors.black.withOpacity(.5),
            context: context,
            builder: (BuildContext context) => showFreeTokensDialog(context));
      }
    });

    _startCountdownTimer();
    _createRewardedAd();
    super.initState();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _animationController!.dispose();
    player3.close();
    super.dispose();
  }

  AlertDialog showFreeTokensDialog(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white.withOpacity(.9),
      title: Text(
        'Get Free Tokens!',
        style: textStyleAutoScaledByPercent(context, 14, darkTextColor),
        textScaler: defaultTextScaler(context),
      ),
      content: Text(
        'Watch an ad to earn ${globalSettings.rewardedAdAmount} tokens?',
        style: textStyleAutoScaledByPercent(context, 12, darkTextColor),
        textScaler: defaultTextScaler(context),
      ),
      // style: textStyleDark()),
      actions: <Widget>[
        TextButton(
            onPressed: () {
              player3.playBackspaceSound();
              Navigator.pop(context);
            },
            child: Text(
              'No Thanks.',
              style: textStyleAutoScaledByPercent(context, 13, darkTextColor),
              textScaler: defaultTextScaler(context),
            )),
        TextButton(
            onPressed: () {
              player3.playOpenPage();
              userSettings.nextRewardTimestamp =
                  DateTime.now().millisecondsSinceEpoch +
                      globalSettings.rewardedAdNextAvailableInMs;
              objectBox.storeUserSettings(userSettings);
              // _countdownTimer.stop();
              Navigator.pop(context);
              _showRewardedAd();
            },
            child: Text(
              'Yes Please!!',
              style: textStyleAutoScaledByPercent(context, 13, darkTextColor),
              textScaler: defaultTextScaler(context),
            )),
      ],
    );
  }

  void _startCountdownTimer() {
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => _setCountDown());
  }

  void _setCountDown() {
    const int reduceBy = 1;
    setState(() {
      final seconds = timeLeftWeek.inSeconds - reduceBy;
      timeLeftWeek = Duration(seconds: seconds);
    });
  }

  VoidCallback? showAd;
  Duration timeLeftWeek = Duration(seconds: getWeeklyRemainingTime());
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  final AdRequest request = const AdRequest();
  int tries = 0;
  int displayRewardAdMax = 5;
  int displayInterstitialAdMax = 2;
  String? mins;
  String? secs;

  void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: AdHelper.rewardedAdUnitId,
        request: request,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            debug('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            debug('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts < 3) {
              _createRewardedAd();
            }
          },
        ));
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      debug('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          debug('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debug('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd();
        _setCountDown();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debug('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      setState(() {
        setUserCredits(globalSettings.rewardedAdAmount);
        setExtraDataRecordEntry(
            'totalRewardedAdClicks', ++totalRewardedAdClicks);
      });
    });
    _rewardedAd = null;
  }

  void showAdDialog(BuildContext context) {
    player3.playOpenPage();
    if (calculateNextRewardTime() > 0) {
      Navigator.of(context).push(
        MaterialTransparentRoute(
            builder: (context) => const AdWaitForReward(),
            settings: const RouteSettings()),
      );
    } else {
      showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(.5),
          barrierDismissible: false,
          builder: (BuildContext context) =>
              Center(child: showFreeTokensDialog(context)));
    }
  }

  final colorizeColors = [
    Colors.white,
    appThemeColor,
    Colors.white,
    Colors.white,
  ];

  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);
    ButtonStyle landingButtonStyle = ElevatedButton.styleFrom(
        backgroundColor:
            appThemeColor.withOpacity(.5), //background color of button
        side: BorderSide(width: 1, color: borderColor), //border width and color
        elevation: 5, //elevation of button
        shape: RoundedRectangleBorder(
            //to set border radius to button
            borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(10) //content padding inside button
        );
    Color labelBackgroundColor = Colors.transparent;
    final bool tallerScreen = MediaQuery.of(context).size.height >= 800.0;
    final bool widerScreen = MediaQuery.of(context).size.width > 430.0;
    final double toggleWidth = (sqrt(MediaQuery.of(context).size.width));
    double fontSize = scaler.getTextSize(11);
    // widerScreen
    //     ? calculateFixedFontSize(context) * .75
    //     : calculateFixedFontSize(context) * .65;
    textStyle18 = TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: buttonTextColor);
    // textStyleDark() = TextStyle(
    //     fontSize: fontSize, fontWeight: FontWeight.bold, color: darkTextColor);
    textStyle = TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: buttonTextColor);

    double screenW = MediaQuery.of(context).size.width;
    double screenH = MediaQuery.of(context).size.height;
    // debug('${sqrt(screenW)}');
    double niceButtonHeight = sqrt(screenH) * (tallerScreen ? 2.1 : 1.7);
    double niceButtonWidth = screenW * .45; //(widerScreen ? .6 : .8);
    double spacingHeight = sqrt(screenH) * 2;
    double spacingWidth = calculateFixedFontSize(context) * 8;
    String playButtonTitle = "Henyo";
    // wordLocale == 'ph' ? 'Pinoy Henyo' : 'Word Henyo';
    //debug('objectbox user len: ${objectBox.getAllUsers().length}')

    // if (whatsNewTimestamp > userSettings.getSplashPageMessageTS()) {
    //   showWhatsNewDialog(context, "What's New?", whatsNewMessage);
    //   userSettings.setSplashPageMessageTS(whatsNewTimestamp);
    // }
    final days = timeLeftWeek.inDays.remainder(7);
    final hours = strDigits(timeLeftWeek.inHours.remainder(24), 2);
    final minutes = strDigits(timeLeftWeek.inMinutes.remainder(60), 2);
    final seconds = strDigits(timeLeftWeek.inSeconds.remainder(60), 2);

    // double maxScale = screenW > 700 ? 1.3 : 1.1;
    const maxScale = 1.1;
    var buttonNames = [
      globalMessages.infoMainMenuGimme5Title,
      globalMessages.infoMainMenuSoloTitle,
      globalMessages.infoMainMenuMultiPlayer5Title,
      globalMessages.infoMainMenuPartyTitle
    ];

    List<Widget> mainButtons = List<Widget>.generate(4, (index) {
      int delayShimmer = 500;
      return niceButtonWithAnimate(
          context, niceButtonHeight, niceButtonWidth, buttonNames[index], () {
        switch (index) {
          case 0:
            player3.playOpenPage();
            gameMode = GameMode.gimme5Round1;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GamePage()),
            ).then((value) => setState(() {
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.portraitUp,
                    DeviceOrientation.portraitDown,
                  ]);
                  resetInfoData();
                }));
            break;
          case 1:
            gameMode = GameMode.solo;
            player3.playOpenPage();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GamePage()),
            ).then((value) => setState(() {
                  resetInfoData();
                }));
            break;
          case 2:
            player3.playOpenPage();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MultiPlayerPage()),
            ).then((value) => setState(() {
                  resetInfoData();
                }));
            break;
          case 3:
            gameMode = GameMode.party;
            player3.playOpenPage();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PartyModePage()),
            ).then((value) => setState(() {
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.portraitUp,
                    DeviceOrientation.portraitDown,
                  ]);
                  resetInfoData();
                }));
            break;
        }
      }, 30000, delayShimmer + (index * 10000));
    })
        .animate(interval: 500.ms)
        .effect(duration: 3000.ms) // this "pads out" the total duration
        .effect(delay: 300.ms, duration: 1500.ms) // set defaults
        .shake(curve: Curves.easeInOut, hz: 0.5)
        .slideX(curve: Curves.easeOut, begin: -1.2, end: 0)
        .slideY(curve: Curves.bounceOut, begin: -7.0, end: 0);

    return lightBulbBackgroundWidget(
        context,
        user.alias.isEmpty ? username : user.alias,
        Column(children: [
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
          // const SizedBox(height: 5),
          Row(
            children: [
              TextButton(
                child: Text(
                  style: textStyleDark(context),
                  textScaler: customTextScaler(context),
                  'Score: $totalScore',
                ),
                onPressed: () {
                  player3.playOpenPage();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LeaderBoardPage()),
                  ).then((value) => setState(() {}));
                },
              ),
              const Spacer(),
              TextButton(
                child: Text(
                    textScaler: customTextScaler(context),
                    'Streak: $totalStreak',
                    style: textStyleDark(context)),
                onPressed: () {
                  player3.playOpenPage();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LeaderBoardPage()),
                  ).then((value) => setState(() {}));
                },
              ),
              // AutoSizeText(
              //   '   Streak: $totalStreak',
              //   style: textStyleDark(),
              //   maxLines: 1,
              // ),
              const Spacer(),
              TextButton(
                child: Row(children: [
                  RiveAnimatedIcon(
                      // splashColor: Colors.grey,
                      riveIcon: RiveIcon.add,
                      // width: screenW * (screenW > 600 ? .065 : .085),
                      width: scaler.getWidth(10),
                      height: screenW * (screenW > 600 ? .065 : .085),
                      color: Colors.orange.shade300,
                      strokeWidth: 40,
                      loopAnimation: true,
                      onTap: () {
                        showAdDialog(context);
                      },
                      onHover: (value) {}),
                  // Lottie.asset(
                  //   'assets/coin.json',
                  //   controller: _controller,
                  //   width: 40,
                  //   height: 50,
                  // ),
                  // Icon(
                  //   size: fontSize * scaledFontSize(context) * 2,
                  //   Icons.control_point,
                  //   color: appThemeColor.withOpacity(.8),
                  //   applyTextScaling: true,
                  // ),
                  Text(
                      textScaler: customTextScaler(context),
                      'Token: $credits',
                      style: textStyleDark(context)),
                ]),
                onPressed: () {
                  showAdDialog(context);
                },
              ),
              const Spacer(),
              // const SizedBox(
              //   width: 10,
              // ),
            ],
          ),
          // if (tallerScreen)
          //   const SizedBox(
          //     height: 5,
          //   ),
          Row(children: [
            const Spacer(),
            mainButtons[0],
            const Spacer(),
            mainButtons[1],
            const Spacer(),
          ]),
          // SizedBox(
          //   height: tallerScreen ? 10 : 5,
          // ),
          SizedBox(
            height: tallerScreen ? 10 : 5,
          ),
          Row(children: [
            const Spacer(),
            mainButtons[2],
            const Spacer(),
            mainButtons[3],
            const Spacer(),
          ]),
          Visibility(
              visible: false,
              child: Center(
                  child: Container(
                      height: spacingHeight * 1.1, //height of button
                      width: spacingWidth * 2.1, //width of button
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                            color: appThemeColor.withOpacity(.3),
                            blurRadius: _animation!.value,
                            spreadRadius: _animation!.value)
                      ]),
                      child: ElevatedButton(
                        style: landingButtonStyle,
                        onPressed: () {
                          player3.playOpenPage();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PartyModePage()),
                          ).then((value) => setState(() {}));
                        },
                        child: Text(
                          textScaler: customTextScaler(context),
                          "$playButtonTitle Wordle",
                          style: textStyle18,
                          maxLines: 1,
                        ),
                      )))),
          const Spacer(),
          Container(
              height: screenH / 4,
              width: screenW > 600 ? screenW * .8 : screenW - 6,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  border: Border.all(
                      color: customBlueColor.withOpacity(.5),
                      width: widerScreen ? 4 : 3)),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                      color: labelBackgroundColor,
                      child: Text(
                        textScaler: defaultTextScaler(context),
                        'Select Difficulty',
                        style: textStyleDark(context),
                      )),
                  if (MediaQuery.of(context).size.height > 650)
                    const SizedBox(
                      height: 10,
                    ),
                  MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                          textScaler: TextScaler.linear(
                              screenW > 430 ? maxScale * 1.4 : maxScale)),
                      child: ToggleWidget(
                        cornerRadius: 8.0,
                        minWidth: widerScreen ? toggleWidth * 5 : 100,
                        initialLabel: getDifficulty(wordDifficulty),
                        activeBgColor: appThemeColor.withOpacity(.5),
                        activeTextColor: Colors.white,
                        inactiveBgColor: customBlueColor
                            .withOpacity(.3), // Colors.grey.withOpacity(.3),
                        inactiveTextColor: appThemeColor,
                        labels: toggleDifficultyLabels(),
                        onToggle: (index) {
                          debug('switched to: $index');
                          player3.playOpenPage();
                          setState(() {
                            switch (index) {
                              case 0:
                                wordDifficulty = 'e';
                                difficultyMessage = globalMessages
                                    .getDifficultyEasyLabel(wordLocale);
                                break;
                              case 1:
                                wordDifficulty = 'm';
                                difficultyMessage = globalMessages
                                    .getDifficultyMediumLabel(wordLocale);
                                break;
                              case 2:
                              default:
                                wordDifficulty = 'h';
                                difficultyMessage = globalMessages
                                    .getDifficultyHardLabel(wordLocale);
                                break;
                            }
                          });
                          userSettings.setDifficulty(wordDifficulty);
                          objectBox.storeUserSettings(userSettings);
                        },
                      )),
                  Container(
                    color: labelBackgroundColor,
                    child: Text(
                      textScaler: customTextScaler(context, max: maxScale),
                      difficultyMessage,
                      style: textStyleDark(context),
                      maxLines: 1,
                    ),
                  ),
                  const Spacer(),
                  // const SizedBox(
                  //   height: 30,
                  // ),
                  Container(
                    color: labelBackgroundColor,
                    child: Text(
                        textScaler: customTextScaler(context, max: maxScale),
                        'Select Language',
                        style: textStyleDark(context)),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                          textScaler: TextScaler.linear(
                              screenW > 430 ? maxScale * 1.4 : maxScale)),
                      child: ToggleWidget(
                        minWidth: widerScreen ? toggleWidth * 9 : 110,
                        initialLabel: wordLocale == 'en' ? 0 : 1,
                        activeBgColor: appThemeColor.withOpacity(.5),
                        activeTextColor: Colors.white,
                        inactiveBgColor: customBlueColor
                            .withOpacity(.3), // Colors.grey.withOpacity(.3),
                        inactiveTextColor: appThemeColor,
                        labels: const ['English', 'Tagalog & English'],
                        onToggle: (index) {
                          player3.playOpenPage();
                          debug('switched to: $index');
                          switch (index) {
                            case 0:
                              wordLocale = 'en';
                              break;
                            case 1:
                            default:
                              wordLocale = 'ph';
                          }
                          userSettings.setLocale(wordLocale);
                          objectBox.storeUserSettings(userSettings);
                          setState(() {});
                        },
                      )),
                  const Spacer(),
                ],
              )),
          // SizedBox(
          //   height: spacingHeight / 2,
          // ),

          const Spacer(),
          // const SizedBox(height: 10), textScaler: defaultTextScaler(context, max: maxScale),
          Center(
              child: defaultButton(context, .9, .5, 'Leader Board', () {
            player3.playOpenPage();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LeaderBoardPage()),
            ).then((value) => setState(() {
                  resetInfoData();
                }));
          })),
          Center(
              child: Text(
            textScaler: customTextScaler(context),
            style: textStyleDark(context),
            'Weekly tournament ends in ${days}d:${hours}h:${minutes}m:${seconds}s',
          )),
          Center(
              child: Text(
            textScaler: customTextScaler(context),
            'Weekly Score: $score  |  Weekly Streak: $streak',
            style: textStyleDark(context),
            maxLines: 1,
          )),
          // Text(style: textStyleDark(), '${getWeeklyRemainingTime()}'),
          const Spacer(),
          const SizedBox(height: 10),
          const Spacer(),
          Row(children: [
            const Spacer(),
            defaultButtonWithIcon(
                context,
                .9,
                .5,
                'Settings',
                Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: calculateFixedFontSize(context) * 1.2,
                ), () {
              player3.playOpenPage();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              ).then((value) => setState(() {
                    resetInfoData();
                  }));
            }),
            // SizedBox(
            //   height:
            //       sqrt(screenH) * (tallerScreen ? 2.3 : 1.7), //height of button
            //   width: spacingWidth, //width of button
            //   child: ElevatedButton(
            //     style: landingButtonStyle,
            //     onPressed: () {
            //       player3.playOpenPage();
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (context) => const SettingsPage()),
            //       ).then((value) => setState(() {
            //             resetInfoData();
            //           }));
            //     },
            //     child: Row(children: [
            //       const Spacer(),
            //       Text('Settings',
            //           style: textStyleCustomFontSizeFromContext(
            //               context, tallerScreen ? .8 : .7)),
            //       const Icon(Icons.settings, color: Colors.white),
            //       const Spacer(),
            //     ]),
            //   ),
            // ),
            //const SizedBox(width: 10),
            const Spacer(),
            defaultButton(context, .9, .5, 'How To Play?', () {
              player3.playOpenPage();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HowToPlayPage()),
              ).then((value) => setState(() {}));
            }),
            // SizedBox(
            //   height:
            //       sqrt(screenH) * (tallerScreen ? 2.3 : 1.7), //height of button
            //   width: spacingWidth, //width of button
            //   child: ElevatedButton(
            //     style: landingButtonStyle,
            //     onPressed: () {
            //       player3.playOpenPage();
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (context) => const HowToPlayPage()),
            //       ).then((value) => setState(() {}));
            //     },
            //     child: Text( textScaler: customTextScaler(context),'How To Play?',
            //         style: textStyleCustomFontSizeFromContext(
            //             context, tallerScreen ? .8 : .7)),
            //   ),
            // ),
            const Spacer(),
          ]),
          const Center(
              child: Row(children: [
            //Text('Test', style: textStyle),
          ])),
          const SizedBox(
            height: 10,
          ),
        ]));
  }
}

class MaterialTransparentRoute<T> extends PageRoute<T>
    with MaterialRouteTransitionMixin<T> {
  MaterialTransparentRoute({
    required this.builder,
    required RouteSettings super.settings,
    this.maintainState = true,
    super.fullscreenDialog,
  });

  final WidgetBuilder builder;

  @override
  Widget buildContent(BuildContext context) => builder(context);

  @override
  Color? get barrierColor => Colors.black.withOpacity(.5);

  @override
  bool get opaque => false;

  @override
  final bool maintainState;

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';
}
