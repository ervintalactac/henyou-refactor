import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:gemini_flutter/gemini_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_speech/google_speech.dart';
// import 'package:smart_autocomplete/smart_autocomplete.dart';
import 'package:sprintf/sprintf.dart';

import 'ad_dialog.dart';
import 'ad_helper.dart';
import 'debug.dart';
import 'entities.dart';
import 'helper.dart';
import 'language.dart';
import 'keyboard.dart';
import 'multiplayerdata.dart';
import 'soundplayer.dart';
import 'wordselection.dart';

class GamePage extends StatefulWidget {
  // final bool multiPlayerGame;
  const GamePage({
    super.key,
    // this.multiPlayerGame = false,
  });

  @override
  Game createState() => Game();
}

// bool multiPlayerGame = false;
// final String _appodealKey = Platform.isAndroid
//     ? "d5573513b59f8626156556d2815ed06bd032ad1d33600ad2"
//     : "03bcfec4a5cbb98709e74c59f2ac802ea67bfe4c70aa6ac5";

class Game extends State<GamePage> with TickerProviderStateMixin {
  TextEditingController textController = TextEditingController();
  String guessText =
      gameMode == GameMode.multiPlayer ? '' : 'HENYO U?! solo play';
  String guessResult = '';
  Color guessTextColor = Colors.white;
  bool guessSent = true;
  String headerTitle = '';

  Map<String, String> userGuesses = <String, String>{};
  SoundPlayer player = SoundPlayer();
  SoundPlayer player2 = SoundPlayer();
  bool enableHint = false;
  int maxFailedLoadAttempts = 3;
  int tokenReward = 0;
  int delay = 0;

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  BannerAd? _bannerAd;
  int _numRewardedLoadAttempts = 0;
  final AdRequest request = const AdRequest();
  int gamesPlayedCount = 0;
  int tries = 0;
  bool waitForConfetti = true;
  // int displayRewardAdMax = 5;
  // int displayInterstitialAdMax = 2;

  List<AblyMessage> ablyMessages = [];
  // HenyoSpeechToText speechToText = HenyoSpeechToText();
  PermissionStatus? microphoneStatus;
  late Future<StreamSubscription<dynamic>> hsttSubscription;

  late final AnimationController _controller;
  late final AnimationController _controllerAnimateGradient;

  String apiKeyGemini = //"AIzaSyBAUSNsq1TawYWQcILpNEq7vXHe48Rg6QY";
      "AIzaSyAoYR-pL5Ve2_j2aWHuarZ6--eurjoeRyw";
  // "AIzaSyDm1nuvYyXEyJYzmvKZsxy5Py1OEr7gMUw";

  var prompt = globalSettings.promptCompareTwoWords;
  var promptGimme5Round1 = globalSettings.promptGimme5Round1;

  bool canPop = false;

  @override
  void initState() {
    // textController = TextEditingController();
    initSpeech();
    // isOffline = false;
    internetSubscription.onData((data) {
      // whenever connection status is changed.
      //connection is from mobile or wifi
      setState(() {
        isOffline = !(data == ConnectivityResult.mobile ||
            data == ConnectivityResult.wifi);
        debug('Device internet connectivity status: $data');
      });
    });
    if (!gameStarted) {
      resultColor = constResultColor;
    }
    timerColor = constTimerColor;
    wordsList.loadWordsList();
    wordsList.loadDictionaryList();

    switch (gameMode) {
      case GameMode.solo:
        currentShowOnceValue =
            setInfoStrings(ShowOnceValues.gamePage, infoLocale);
        headerTitle = 'Streak: $totalStreak    Tokens: $credits';
        if (!showOnce.infoGamePageShown) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            debug('show once game play instructions');
            showInfoDialog(context);
            showOnce.infoGamePageShown = true;
            objectBox.setShowOnce(showOnce);
          });
        }
        break;
      case GameMode.multiPlayer:
        wordsMP.loadMPWordsList();
        subscribeToRoom(mpInfo!.data.room);
        currentShowOnceValue =
            setInfoStrings(ShowOnceValues.multiPlayerGuesserPage, infoLocale);
        headerTitle = 'Room: ${mpInfo!.data.room}';
        if (!showOnce.infoMultiPlayerGuesserShown) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            debug('show once game play as guesser instructions');
            showInfoDialog(context);
            showOnce.infoMultiPlayerGuesserShown = true;
            objectBox.setShowOnce(showOnce);
          });
        }
        break;
      case GameMode.gimme5Round1:
        currentShowOnceValue =
            setInfoStrings(ShowOnceValues.gimme5Round1, infoLocale);
        headerTitle = "Gimme 5 - Round 1";
        String gimme5Round1Instructions = infoMessage;
        gimme5Words = getGimme5Categories(wordLocale);
        loadGimme5Json();
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          debug('show gimme 5 round 1 instructions');
          debug('gimme5 wager: $gimme5Wager');
          showGimme5Dialog(context, headerTitle, gimme5Round1Instructions,
              "Back To Main Menu", "OK", () {
            setState(() {
              displayGimme5 = true;
            });
          }, setState, true);
        });
        break;
      case GameMode.gimme5Round2:
        currentShowOnceValue =
            setInfoStrings(ShowOnceValues.gimme5Round2, infoLocale);
        String gimme5Round2Instructions =
            "Congratulations on making it to 2nd round!\n\n$infoMessage";
        gimme5Words = getGimme5Categories(wordLocale);
        headerTitle = "Gimme 5 - Round 2";
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          debug('show gimme 5 round 2 instructions');
          showGimme5Dialog(
              context, headerTitle, gimme5Round2Instructions, "", "OK", () {
            setState(() {
              displayGimme5 = true;
              // reset game board
              gimme5Message = 'Choices on the board. Select a category above.';
              _resetGimme5Data();
              gimme5Buttons = generateGimme5Buttons();
            });
          }, setState, false);
        });
        break;
      case GameMode.gimme5Round3:
        currentShowOnceValue =
            setInfoStrings(ShowOnceValues.gimme5Round3, infoLocale);
        headerTitle = "Gimme 5 - Round 3";
        String gimme5Round3Instructions =
            "Congratulations on making it to the final round!\n\n$infoMessage";
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          debug('show gimme 5 round 3 instructions');
          showGimme5Dialog(
              context, headerTitle, gimme5Round3Instructions, "", "OK", () {
            setState(() {
              displayGimme5 = true;
              // reset game board
              gimme5Message =
                  'Final round. Words will come from all 5 categories.';
              _resetGimme5Data();
              gimme5Buttons = generateGimme5Buttons();
            });
          }, setState, false);
          gimme5RandomWordSelections =
              wordsList.selectGimme5RandomWords(wordLocale, wordDifficulty, '');
          gimme5Words = gimme5RandomWords =
              gimme5RandomWordSelections.map((word) => word.guessword).toList();
          debug(gimme5RandomWords.toString());
        });
        break;
      case GameMode.party:
      case GameMode.unset:
        assert(true); // should not get here
        break;
    }
    gimme5AttemptCounter = 0;

    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   switch (gameMode) {
    //     case GameMode.solo:
    //       break;
    //     case GameMode.multiPlayer:
    //       break;
    //     case GameMode.gimme5Round1:
    //       break;
    //     case GameMode.gimme5Round2:
    //       break;
    //     case GameMode.gimme5Round3:
    //       break;
    //     case GameMode.unset:
    //       assert(true); // should not get here
    //       break;
    //   }

    // monitorTokenCount().listen((c) {
    //   if (c < globalSettings.lowTokenCountThreshold &&
    //       DateTime.now().millisecondsSinceEpoch > lastTimeStamp) {
    //     showGenericAlertDialog(context);
    //   }
    // });
    // });

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

    _controllerAnimateGradient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
    super.initState();
  }

  void initSpeech() async {
    microphoneStatus = await Permission.microphone.request();
    if (!microphoneStatus!.isGranted) {
      if (mounted) {
        showGenericAlertDialog(
            context,
            'Warning!',
            globalMessages.getMicrophoneDeniedMessage(wordLocale),
            '',
            'OK',
            () {});
      }
    }
  }

  @override
  void dispose() {
    if (gameMode == GameMode.multiPlayer) {
      mpInfo!.data.setTxnStatus(RoomState.guesserLeft.name);
      leaveRoom(mpInfo!.data).then((value) => roomJoined = false);
      getRoom(mpInfo!.data.room).then((value) {
        value.status = convertStringToRoomState(mpInfo!.data.txnStatus);
        sendUserNegotiation(
            MultiPlayerTransaction.copyFromMultiPlayerRoomData(value));
        // Navigator.of(context).pop();
      });
      sendUserResponse(jsonEncode(mpInfo!.data.toJson()), mpInfo!.data.room, 0);
    }
    // _controller.dispose();
    // _controllerAnimateGradient.dispose();
    resetInfoData();
    player3.playBackspaceSound();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _bannerAd?.dispose();
    // textController.dispose();
    player.close();
    userGuesses.clear();
    wordsAssociated?.clear();
    wordsDictionary?.clear();
    wordsPossible?.clear();
    recorder?.dispose();
    _recordingDataSubscription?.cancel();
    displayGimme5 = false;
    // gameMode = GameMode.unset;
    super.dispose();
  }

  // Future<void> initialization() async {
  //   Appodeal.setTesting(kDebugMode ? true : false); //only not release mode
  //   Appodeal.setLogLevel(Appodeal.LogLevelVerbose);

  //   Appodeal.setAutoCache(AppodealAdType.Interstitial, false);
  //   Appodeal.setAutoCache(AppodealAdType.RewardedVideo, false);
  //   Appodeal.setUseSafeArea(true);

  //   Appodeal.initialize(
  //       appKey: _appodealKey,
  //       adTypes: [
  //         AppodealAdType.RewardedVideo,
  //         AppodealAdType.Interstitial,
  //         AppodealAdType.Banner,
  //         AppodealAdType.MREC
  //       ],
  //       onInitializationFinished: (errors) {
  //         errors?.forEach((error) => debug(error.desctiption));
  //         debug("onInitializationFinished: errors - ${errors?.length ?? 0}");
  //       });
  // }

  void _loadInterstitialAd() async {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debug("Ad dismissed!");
              //_moveToHome();
            },
          );

          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          debug('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

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
            if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
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

  bool compareGuessWordFromWordToGuess(String guessWord, String wordToGuess) {
    if (wordToGuess.contains(':')) {
      List<String> words = wordToGuess.split(':');
      return words.contains(guessWord);
    } else {
      return wordToGuess == guessWord ||
          WordSelection.sanitize(guessText) ==
              WordSelection.sanitize(wordToGuess);
    }
  }

  Widget guessResultWidget() {
    ScreenScaler scaler = ScreenScaler()..init(context);
    return Center(
      child: (compareGuessWordFromWordToGuess(
                  guessText.toLowerCase(), wordToGuess) &&
              guessText.isNotEmpty)
          ? Container(
              height: scaler.getHeight(7),
              width: scaler.getWidth(5) *
                  (guessResult.length > 8 ? guessResult.length : 12),
              decoration: BoxDecoration(
                  color: resultColor,
                  border: Border.all(
                    color: resultColor, //appThemeColor,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(50))),
              child: Center(
                  child: Text(
                textScaler: customTextScaler(context),
                guessResult,
                style:
                    textStyleAutoScaledByPercent(context, 15, buttonTextColor),
              )),
            )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(delay: 2.seconds, duration: 1000.ms, color: Colors.white)
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .effect(duration: 3000.ms)
              .effect(delay: 70.ms, duration: 500.ms)
              .scaleXY(end: 1.05, curve: Curves.easeOutBack)
              .moveY(end: -10, duration: 200.ms)
              .elevation(
                  end: 24,
                  borderRadius: const BorderRadius.all(Radius.circular(50)))
              .shake(curve: Curves.easeInOutCubic, hz: 3)
              .fadeIn()
          // .rotate()
          : Container(
              height: scaler.getHeight(7),
              width: scaler.getWidth(5) *
                  (guessResult.length > 8 ? guessResult.length : 12),
              decoration: BoxDecoration(
                  color: resultColor,
                  border: Border.all(
                    color: resultColor, //appThemeColor,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(50))),
              child: Center(
                  child: Text(
                textScaler: customTextScaler(context),
                guessResult,
                style:
                    textStyleAutoScaledByPercent(context, 15, buttonTextColor),
              )),
            ),
    );
  }

  List<String> get5RandomWords(List<dynamic> words) {
    List<String> fiveWords = [];
    for (int i = 0; i < 5; i++) {
      var w = words[Random().nextInt(words.length)];
      words.remove(w);
      fiveWords.add(w);
    }
    return fiveWords;
  }

  List<String> gimme5RandomWords = [];
  List<WordObject> gimme5RandomWordSelections = [];
  String gimme5Question = '';
  final gimme5Index = ['1', '2', '3', '4', '5'];

  final categoriesForJson = ['person', 'thing', 'animal', 'place', 'food'];
  final resetColorBorder = [
    Colors.transparent,
    Colors.transparent,
    Colors.transparent,
    Colors.transparent,
    Colors.transparent
  ];
  var colorBorder = [
    Colors.transparent,
    Colors.transparent,
    Colors.transparent,
    Colors.transparent,
    Colors.transparent
  ];
  String gimme5Message = 'Choices on the board. Select a category above.';
  bool gimme5Correct = false;
  bool gimme5Wrong = false;
  bool gimme5GuesserSelected = false;
  bool displayGimme5 = false;
  String gimme5Category = '';
  String lastGuess = '';
  String gimme5OnScreenMessage = '';
  bool gimme5OnScreenSwitch = false;
  bool animateTimer = false;
  int gimme5CorrectGuessCount = 0;
  int gimme5AttemptCounter = 0;
  String hintText = '';
  List<dynamic> gimme5Round1List = [];
  List<String> gimme5Prompts = [
    'Timer Ready!',
    'Give me 5 on the board!',
    'In %d Minutes...',
    'Timer Starts...',
    'Timer Starts Now!'
  ];

  var onScreenMessage;
  startGimme5Round(int duration) async {
    var onScreenPrompts = List<Widget>.generate(5, (index) {
      String text = gimme5Prompts[index];
      if (index == 2) {
        text = sprintf(gimme5Prompts[index], [duration]);
      }
      return autoSizeText(context, text, 9, buttonTextColor.withOpacity(.9))
          .animate()
          .fadeIn(duration: 900.ms, delay: 300.ms)
          .shimmer(blendMode: BlendMode.srcOver, color: Colors.white12)
          .move(begin: const Offset(-16, 0), curve: Curves.easeOutQuad)
          // .animate(interval: 3000.ms)
          .fadeOut(delay: 12000.ms, duration: 2000.ms);
    });
    player.playGimme5Sound();
    setState(() {
      if (canPop) return;
      myDuration = Duration(minutes: duration);
      animateTimer = true;
      gimme5Message = '';
      // gimme5OnScreenMessage = 'Timer Ready!';
      onScreenMessage = onScreenPrompts[0];
      gimme5OnScreenSwitch = true;
    });
    await Future.delayed(const Duration(seconds: 3));
    player.playGimme5Sound();
    setState(() {
      if (canPop) return;
      gimme5Words = gimme5Index;
      gimme5Buttons = generateGimme5Buttons();
      onScreenMessage = onScreenPrompts[1];
      // gimme5OnScreenMessage = 'Give me 5 on the board!';
      // gimme5OnScreenSwitch = true;
      gimme5Start = true;
    });
    await Future.delayed(const Duration(seconds: 3));
    player.playGimme5Sound();
    setState(() {
      if (canPop) return;
      onScreenMessage = onScreenPrompts[2];
      gimme5Message = gimme5Question;
      // gimme5OnScreenMessage = 'In 2 minutes...';
      // gimme5OnScreenSwitch = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    player.playGimme5Sound();
    setState(() {
      if (canPop) return;
      onScreenMessage = onScreenPrompts[3];
      // gimme5OnScreenMessage = 'Timer Starts...';
    });
    await Future.delayed(const Duration(seconds: 3));
    player.playGimme5Sound();
    setState(() {
      if (canPop) return;
      onScreenMessage = onScreenPrompts[4];
      // gimme5OnScreenMessage = 'Timer Starts Now!';
      gimme5OnScreenSwitch = true;
    });
    hintText = '   Start guessing!';
    player.playStartGameSound();
    // _resetTimer();
    _startTimer();
    Future.delayed(const Duration(seconds: 10))
        .then((v) => gimme5OnScreenSwitch = false);
  }

  Widget gimme5MessageWidget(BuildContext context, String message) {
    final double screenW = MediaQuery.of(context).size.width;
    // final double screenH = MediaQuery.of(context).size.height;
    // for tablets we need a smaller percent value
    // double percent = screenW > 700 ? 7 : 8;
    // debug('screen height: $screenH');
    return SizedBox(
        width: screenW * .9,
        // height: screenH * .07,
        child: Text(message,
            textScaler: customTextScaler(context, max: 1.6),
            style: textStyleCustom(context, buttonTextColor)));
  }

  loadGimme5Json() async {
    gimme5Round1Map = jsonDecode(objectBox.getJsonGimme5Round1Words());
    debug('loadGimme5Json success');
    // gimme5Round1Map =
    //     jsonDecode(await rootBundle.loadString('json/gimme5r1.json'));
  }

  loadNextGimme5Word() {
    assert(gimme5RandomWordSelections.isNotEmpty);
    WordObject ws = gimme5RandomWordSelections.first;
    wordToGuess = ws.getGuessWord();
    wordsAssociated = ws.getAssociatedWords(dictionaryMap);
    wordsPossible = ws.getPossibleWords(dictionaryMap);
    gimme5RandomWordSelections.removeAt(0);
  }

  gimme5LaunchNextRound() {
    if (gameMode == GameMode.gimme5Round1) {
      gameMode = GameMode.gimme5Round2;
    } else if (gameMode == GameMode.gimme5Round2) {
      gameMode = GameMode.gimme5Round3;
    }
    // Navigator.of(context).pop();
    popToMainMenu(context);
    player3.playOpenPage();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GamePage()),
    );
    // .then((value) => setState(() {
    //       resetInfoData();
    //     }));
  }

  // gimme5LaunchRound3() {
  //   gameMode = GameMode.gimme5Round3;
  //   Navigator.of(context).pop();
  //   player3.playOpenPage();
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const GamePage()),
  //   );
  //   // .then((value) => setState(() {
  //   //       resetInfoData();
  //   //     }));
  // }

  List<Widget> generateGimme5Buttons() {
    // bool longerScreen = MediaQuery.of(context).size.height >= 600.0;
    // double bigScreenButtonHeight = sqrt(MediaQuery.of(context).size.height) * 2;
    final double screenW = MediaQuery.of(context).size.width;
    final double screenH = MediaQuery.of(context).size.height;
    double height = screenH * .065;
    if (!userSettings.useCustomKeyboard) height = screenH * .059;
    // debug('gimme5CategoryRound1: $gimme5CategoryRound1');
    double width = screenW * .45; //(wid
    return List<Widget>.generate(5, (index) {
      int i = index;
      String categoryName = gimme5Words[index].toString().toTitleCase();
      if (gameMode == GameMode.gimme5Round2 &&
          gimme5CategoryRound1Index == index &&
          !gimme5Start) categoryName = '';
      return niceButtonGimme5(context, height, width, categoryName, (index) {
        if (gimme5Start ||
            categoryName.isEmpty ||
            gameMode == GameMode.gimme5Round3) return;
        gimme5Category = getGimme5Categories(wordLocale)[i];
        showGenericAlertDialog(
            context,
            "Confirmation",
            "You selected $gimme5Category.\nPress OK to continue.",
            "Cancel",
            "OK", () {
          gimme5Category = gimme5Words[i];
          switch (gameMode) {
            case GameMode.gimme5Round1:
              List<dynamic> list = [];
              String key = sprintf(
                  '%s-%s-%s', [categoriesForJson[i], 'en', wordDifficulty]);
              list = gimme5Round1Map[key];
              if (wordLocale == 'ph') {
                key = sprintf(
                    '%s-%s-%s', [categoriesForJson[i], 'ph', wordDifficulty]);
                list.addAll(gimme5Round1Map[key]);
              }
              gimme5Round1List =
                  removePreviouslyUsedWords({key: list}, gameMode)[key];
              break;
            case GameMode.gimme5Round2:
              gimme5RandomWordSelections = wordsList.selectGimme5RandomWords(
                  wordLocale, wordDifficulty, categoriesForJson[i]);
              gimme5RandomWords = gimme5RandomWordSelections
                  .map((word) => word.guessword)
                  .toList();
              debug(gimme5RandomWords.toString());
              break;
            case GameMode.gimme5Round3:
              break;
            case GameMode.solo:
            case GameMode.multiPlayer:
            case GameMode.party:
            case GameMode.unset:
              assert(true);
              break;
          }
          gimme5GuesserSelected = true;
          setState(() {
            gimme5Message = 'Press Start Game to begin';
            // displayGimme5 = false;
          });
        });
      },
              gimme5Category == gimme5Words[index]
                  ? appThemeColor.withOpacity(.4)
                  : appThemeColor)
          .animate()
          .toggle(builder: (_, b, child) {
        return Container(
          color: colorBorder[index],
          padding: const EdgeInsets.all(6),
          child: child,
        );
      });
      // .animate(onPlay: (c) => c.repeat())
      // .effect(duration: 3000.ms)
      // .effect(delay: 750.ms, duration: 1500.ms)
    });
  }

  Future<List<String>> getSuggestions(String key) async {
    // await Future.delayed(const Duration(milliseconds: 500));
    // return categoriesForJson
    //     .where((e) => e.toLowerCase().startsWith(key))
    //     .toList();
    return [];
  }

  Future<String?> getAutoCompletion(String text) async {
    if (text.isEmpty || !globalSettings.enableAutoComplete) {
      return null;
    }
    await Future.delayed(const Duration(milliseconds: 500));
    var input = text.toLowerCase();
    var sortedOptions = categoriesForJson
        .where((option) => option.toLowerCase().startsWith(input))
        .toList();
    sortedOptions.sort((a, b) => a.length.compareTo(b.length));

    if (sortedOptions.isNotEmpty) {
      var completion = sortedOptions.first;
      return completion;
    } else {
      return null;
    }
  }

  bool showSuggestions = true;

  // StateSetter setState(var callback) {
  //   if (mounted) {
  //     return setState(callback);
  //   }
  //   return setState;
  // }

  @override
  Widget build(BuildContext context) {
    // ScreenScaler scaler = ScreenScaler()..init(context);
    final minutes = strDigits(myDuration.inMinutes.remainder(60), 2);
    final seconds = strDigits(myDuration.inSeconds.remainder(60), 2);
    final milliseconds =
        strDigits(myDuration.inMilliseconds.remainder(1000), 3);
    bool longerScreen = MediaQuery.of(context).size.height >= 600.0;
    // double bigScreenButtonHeight = sqrt(MediaQuery.of(context).size.height) * 2;
    final double screenW = MediaQuery.of(context).size.width;
    final double screenH = MediaQuery.of(context).size.height;
    final bool tallerScreen = screenH >= screenHeightThreshold;
    // double niceButtonHeight = sqrt(screenH) * (longerScreen ? 2.1 : 1.7);
    // double niceButtonWidth = screenW * .45; //(widerScreen ? .6 : .8);
    // final double fontSize = (MediaQuery.of(context).size.width / 5) - 60;
    //debug('$fontSize');

    gameDefaultSubmit() async {
      try {
        if (!timerRunning || textController.text.isEmpty) {
          return;
        }
        String guessText2 = guessText = textController.text;
        if (guessText2.endsWith('s')) {
          guessText2 = guessText.substring(0, guessText.length - 1);
        }
        tries++;
        textController.text = '';
        if (compareGuessWordFromWordToGuess(
            guessText.toLowerCase(), wordToGuess)) {
          player.playRightAnswerSound();
          if (recognizing) stopRecording();
          Set<String> message = correctGuessMessageEn;
          if (getLocale() == 'ph') {
            message = correctGuessMessage;
          }
          int index = Random().nextInt(message.length);
          guessResult = message.elementAt(index);
          resultColor = Colors.green;
          timerColor = constTimerColor;
          // guesses under 3 tries are probably cheating
          if (userGuesses.length > globalSettings.maxGuessTriesForAward) {
            setUserData();
          }
          bool displayAd = false;
          if (gameMode == GameMode.multiPlayer) {
            sendUserResponse(
                'guesserResponse:=Player correctly guessed the word!',
                mpInfo!.data.room,
                delay);
            if (userGuesses.length > globalSettings.maxGuessTriesForAward) {
              int currentScore = _calculateScore();
              sendUserResponse('guesserResponse:score=$currentScore',
                  mpInfo!.data.room, delay);
              sendUserResponse('guesserResponse:tokenReward=$tokenReward',
                  mpInfo!.data.room, delay);
            } else {
              sendUserResponse(
                  'guesserResponse:showAd', mpInfo!.data.room, delay);
              displayAd = true;
            }
          }
          waitForConfetti = false;
          _controller.forward().whenComplete(() {
            setState(() {
              waitForConfetti = true;
            });
            _controller.reset();
            if (displayAd ||
                _rewardedAd != null &&
                    gamesPlayedCount >=
                        globalSettings.displayRewardedAdAfterThisManyTries) {
              gamesPlayedCount = 0;
              debug('showing rewarded ad');
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AdDialog(
                          earnReward: true,
                          showAd: () {
                            _showRewardedAd();
                          },
                        )),
              );
            } else if (displayAd ||
                _interstitialAd != null &&
                    totalStreak %
                            globalSettings
                                .displayInstertitialAdAfterThisManyTries ==
                        0) {
              if (gameMode == GameMode.multiPlayer) {
                sendUserResponse(
                    'guesserResponse:showAd', mpInfo!.data.room, delay);
              }
              debug('showing interstitial ad');
              _interstitialAd!.show();
            }
          });
          _afterRoundTasks();
        } else {
          pauseRecording();
          switch (gameMode) {
            case GameMode.solo:
            case GameMode.gimme5Round2:
            case GameMode.gimme5Round3:
              if (wordsAssociated!
                      .contains(WordSelection.sanitize(guessText)) ||
                  wordsAssociated!
                      .contains(WordSelection.sanitize(guessText2))) {
                guessResult = guessResultLocale('yes');
                guessResultHandler(guessResult);
              } else if (_possibly(guessText)) {
                guessResult = guessResultLocale('close');
                guessResultHandler(guessResult);
              } else {
                if (tries > 5) {
                  String res = await checkAI(prompt, wordToGuess, guessText);
                  guessResult = guessResultLocale(res);
                } else {
                  guessResult = guessResultLocale('no');
                }
                guessResultHandler(guessResult);
              }
              break;
            case GameMode.multiPlayer:
              sendUserResponse(
                  'guesserResponse:=$guessText', mpInfo!.data.room, delay);
              guessResult = '';
              resultColor = constResultColor;
              break;
            case GameMode.gimme5Round1:
              break;
            case GameMode.party:
            case GameMode.unset:
              assert(true); // should not get here
              break;
          }

          guessSent = true;
          // recorder!.resume();
          // if (gameStarted && _speechEnabled) {
          //   _resetListening();
          // }
        }
        setState(() {});
        if (gameMode != GameMode.multiPlayer) {
          _addToUserGuessMap();
        }
        // if (isListening) {
        //   _resetListener(getLocale());
        // }
      } catch (e) {
        debug('GamePage onPressed Submit: $e');
      }
    }

    gameStartCallback() {
      // var ticker = _controller.forward();
      // waitForConfetti = false;
      // ticker.whenComplete(() {
      //   setState(() {
      //     waitForConfetti = true;
      //   });
      //   _controller.reset();
      // });

      if (!waitForConfetti) return;
      if (userSettings.getAutoStartVoiceEntry()) {
        streamingRecognize(context, getLocale());
        if (globalSettings.promptForGamePageVoiceEntry) {
          if (showOnce.autoStartVoiceEntryFeeNotice) {
            showGenericAlertDialog(
                context,
                'Voice Entry fee notice',
                'This feature costs ${globalSettings.voiceEntryFee} tokens per game.',
                'OK',
                "OK and don't remind me again", () {
              showOnce.autoStartVoiceEntryFeeNotice = false;
            });
          }
          deductUserCredits(globalSettings.voiceEntryFee);
        }
      }
      userGuesses = <String, String>{};

      switch (gameMode) {
        case GameMode.solo:
          loadNextGuessWord();
          break;
        case GameMode.multiPlayer:
          loadNextMPGuessWord(multiplayerLocale);
          debug('multiplayerLocale : $multiplayerLocale');
          ablyMessages = [];
          subscribeToRoom(mpInfo!.data.room);
          // roomState.setRoomActive();
          // sendUserResponse('locale:$wordLocale');
          sendUserResponse(
              'guesserResponse:duration=${globalSettings.gameDuration}',
              mpInfo!.data.room,
              delay);
          sendUserResponse('guesserResponse:guessword=$wordToGuess',
              mpInfo!.data.room, delay);
          break;
        case GameMode.gimme5Round1:
          if (gimme5Start) return;
          if (gimme5Category.isEmpty) {
            showGenericAlertDialog(
                context,
                'First things first!',
                'Please select a category above before starting the game.',
                '',
                'OK',
                () {});
            return;
          }
          gimme5CategoryRound1 = gimme5Category;
          gimme5CategoryRound1Index =
              getGimme5Categories(wordLocale).indexOf(gimme5Category);
          int index = Random().nextInt(gimme5Round1List.length);
          gimme5Question =
              gimme5Round1List[index]['question'].toString().toTitleCase();
          usedGimme5Round1Questions.add(gimme5Question.toLowerCase());
          saveWordsHistory();
          gimme5RandomWords =
              get5RandomWords(gimme5Round1List[index]["answer"]);
          debug(gimme5RandomWords.toString());
          setState(() {
            gimme5CorrectGuessCount = 0;
            gimme5TotalCorrectGuessCount = 0;
            colorBorder = resetColorBorder;
          });
          deductUserCredits(gimme5Wager);
          startGimme5Round(2);
          debug(gimme5Words.toString());
          return;
        case GameMode.gimme5Round2:
          if (gimme5Start) return;
          if (gimme5Category.isEmpty) {
            showGenericAlertDialog(
                context,
                'First things first!',
                'Please select a category above before starting the game.',
                '',
                'OK',
                () {});
            return;
          }
          loadNextGimme5Word();
          gimme5CategoryRound2 = gimme5Category;
          String locale = wordLocale == 'ph' ? ' and tagalog' : '';
          String category = gimme5Category.toLowerCase();
          gimme5Question = '$category in english$locale';
          setState(() {
            gimme5CorrectGuessCount = 0;
            colorBorder = resetColorBorder;
          });
          gimme5CategoryRound1Index = -1;
          startGimme5Round(3);
          debug(gimme5Words.toString());
          return;
        case GameMode.gimme5Round3:
          if (gimme5Start) return;
          setState(() {
            gimme5CorrectGuessCount = 0;
            colorBorder = resetColorBorder;
          });
          gimme5Message = 'All categories';
          loadNextGimme5Word();
          startGimme5Round(3);
          debug(gimme5Words.toString());
          return;
        case GameMode.party:
        case GameMode.unset:
          assert(true); // should not get here
          break;
      }
      _loadInterstitialAd();
      _createRewardedAd();
      // if (_speechEnabled) {
      //   _startListening();
      // }
      setState(() {
        guessText = 'Start guessing';
        textController.text = '';
        _resetTimer();
        _startTimer();
        resultColor = constResultColor;
        guessResult = '';
        player.playStartGameSound();
        gameStarted = true;
        tries = 0;
      });
    }

    correctGuessTasksGimme5() {
      gimme5CorrectGuessCount++;
      gimme5TotalCorrectGuessCount++;
      if (gimme5CorrectGuessCount < 5) tries = 0;
      debug('gimme5TotalCorrectGuessCount: $gimme5TotalCorrectGuessCount');
      int additionalTime = myDuration.inSeconds + 30;
      if (gameMode == GameMode.gimme5Round1) {
        gimme5Correct = true;
        if (additionalTime > 120) additionalTime = 120;
      } else {
        if (additionalTime > 180) additionalTime = 180;
      }

      myDuration = Duration(seconds: additionalTime);
      timerColor = buttonTextColor;
    }

    gimme5R2and3Submit() async {
      try {
        if (!timerRunning || textController.text.isEmpty) {
          return;
        }
        String guessText2 = guessText = textController.text;
        if (guessText2.endsWith('s')) {
          guessText2 = guessText.substring(0, guessText.length - 1);
        }
        tries++;
        textController.text = '';
        if (compareGuessWordFromWordToGuess(
            guessText.toLowerCase(), wordToGuess)) {
          player.playRightAnswerSound();
          Set<String> message = correctGuessMessageEn;
          if (getLocale() == 'ph') {
            message = correctGuessMessage;
          }
          int index = Random().nextInt(message.length);
          guessResult = message.elementAt(index);
          resultColor = Colors.green;
          timerColor = constTimerColor;
          // guesses under 3 tries are probably cheating
          if (userGuesses.length > globalSettings.maxGuessTriesForAward) {
            setUserData();
          }
          correctGuessTasksGimme5();
          if (gimme5RandomWordSelections.isNotEmpty) {
            int index = 5 - (gimme5RandomWordSelections.length + 1);
            colorBorder[index] = Colors.green;
            gimme5Words[index] = gimme5RandomWords[index];
            loadNextGimme5Word();
            _addToGimme5GuessMap();
            return;
          } else {
            colorBorder[4] = Colors.green;
            gimme5Words[4] = gimme5RandomWords[4];
            _stopTimer();
          }
          bool displayAd = false;
          waitForConfetti = false;
          _controller.forward().whenComplete(() {
            setState(() {
              waitForConfetti = true;
            });
            _controller.reset();
            if (displayAd ||
                _rewardedAd != null &&
                    gamesPlayedCount >=
                        globalSettings.displayRewardedAdAfterThisManyTries) {
              gamesPlayedCount = 0;
              debug('showing rewarded ad');
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AdDialog(
                          earnReward: true,
                          showAd: () {
                            _showRewardedAd();
                          },
                        )),
              );
            } else if (displayAd ||
                _interstitialAd != null &&
                    totalStreak %
                            globalSettings
                                .displayInstertitialAdAfterThisManyTries ==
                        0) {
              debug('showing interstitial ad');
              _interstitialAd!.show();
            }
            if (gameMode != GameMode.gimme5Round3) {
              gimme5LaunchNextRound();
            } else {
              showGimme5WinnerDialog();
            }
          });
          _afterRoundTasks();
        } else {
          pauseRecording();
          switch (gameMode) {
            case GameMode.gimme5Round2:
            case GameMode.gimme5Round3:
              if (wordsAssociated!
                      .contains(WordSelection.sanitize(guessText)) ||
                  wordsAssociated!
                      .contains(WordSelection.sanitize(guessText2))) {
                guessResult = guessResultLocale('yes');
                guessResultHandler(guessResult);
              } else if (_possibly(guessText)) {
                guessResult = guessResultLocale('close');
                guessResultHandler(guessResult);
              } else {
                if (tries > 5) {
                  try {
                    final response = await GeminiHandler().geminiPro(
                        temprature: 0.1,
                        text:
                            '$prompt Words are "$wordToGuess:$guessText" and base your response that $wordToGuess relates to $wordCategory');
                    var result =
                        response?.candidates?.first.content?.parts?.first.text;
                    guessResult = guessResultLocale(result!.trim());
                  } catch (e) {
                    guessResult = guessResultLocale('no');
                  }
                } else {
                  guessResult = guessResultLocale('no');
                }
                guessResultHandler(guessResult);
              }
              break;
            case GameMode.solo:
            case GameMode.multiPlayer:
            case GameMode.gimme5Round1:
            case GameMode.party:
            case GameMode.unset:
              assert(true); // should not get here
              break;
          }

          guessSent = true;
          _addToGimme5GuessMap();
          // recorder!.resume();
          // if (gameStarted && _speechEnabled) {
          //   _resetListening();
          // }
        }
        setState(() {});

        // if (isListening) {
        //   _resetListener(getLocale());
        // }
      } catch (e) {
        debug('GamePage onPressed gimme5R2and3Submit: $e');
      }
    }

    gimme5Round1OnWrongGuess() {
      guessResult = 'no';
      lastGuess = textController.text;
      player.playWrongAnswerSoundGimme5();
      gimme5Wrong = true;
    }

    gimme5Round1OnCorrectGuess(int index) {
      if (gimme5Words[index].toString().length > 1) {
        gimme5Round1OnWrongGuess();
        return;
      }
      gimme5Words[index] = gimme5RandomWords[index];
      colorBorder[index] = Colors.green;
      correctGuessTasksGimme5();
      if (gimme5CorrectGuessCount == 5) {
        setUserData();
        player.playRightAnswerSound();
        _stopTimer();
        waitForConfetti = false;
        _controller.forward().whenComplete(() {
          setState(() {
            waitForConfetti = true;
          });
          _controller.reset();
          if (_rewardedAd != null &&
              gamesPlayedCount >=
                  globalSettings.displayRewardedAdAfterThisManyTries) {
            gamesPlayedCount = 0;
            debug('showing rewarded ad');
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AdDialog(
                        earnReward: true,
                        showAd: () {
                          _showRewardedAd();
                        },
                      )),
            );
          } else if (_interstitialAd != null &&
              totalStreak %
                      globalSettings.displayInstertitialAdAfterThisManyTries ==
                  0) {
            debug('showing interstitial ad');
            _interstitialAd!.show();
          }
          gimme5LaunchNextRound();
        });
        _afterRoundTasks();
      } else {
        player.playRightAnswerSoundGimme5();
      }
      guessResult = 'yes';
    }

    bool subjectiveCompare = true;
    gimme5Submit() async {
      if (!timerRunning || textController.text.isEmpty) return;
      var list = gimme5RandomWords
          .map((w) => w
              .toLowerCase()
              .replaceAll(" ", "")
              .replaceAll("'", "")
              .replaceAll("-", ""))
          .toList();
      guessText = textController.text.toLowerCase();
      int index = list.indexOf(guessText
          .replaceAll(" ", "")
          .replaceAll("'", "")
          .replaceAll("-", ""));

      if (index != -1 && gimme5Words[index].length == 1) {
        gimme5Round1OnCorrectGuess(index);
      } else {
        // TODO: replace with flag for subjective or exact comparing
        if (subjectiveCompare) {
          try {
            String index = await checkAI(
                promptGimme5Round1, gimme5RandomWords.toString(), guessText);
            int i = int.parse(index);
            if (i > 0) {
              gimme5Round1OnCorrectGuess(i - 1);
            } else {
              gimme5Round1OnWrongGuess();
            }
          } catch (e) {
            debug(e.toString());
            gimme5Round1OnWrongGuess();
          }
          // ignore: dead_code
        } else {
          gimme5Round1OnWrongGuess();
        }
      }
      textController.text = '';
      _addToGimme5GuessMap();
    }

    Widget showHistoryWidget() {
      List<String> list = userGuesses.values.map((v) {
        var vals = v.split(':');
        if (vals.length > 2) v = '${vals[0]}:${vals[1]}';
        return v.toString().replaceAll('"', '').replaceAll(':', ' - ');
      }).toList();
      // insert a blank line so the history doesn't cover the message widget
      list.insert(list.length, ' ');
      return ListView.builder(
        reverse: true,
        // padding: const EdgeInsets.only(top: 15.0),
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          return Text(
              style: textStyleCustom(context, Colors.white.withOpacity(.8)),
              list.reversed.toList()[index]);
        },
        // ),
      );
      // .animate()
      // .effect(duration: 6000.ms)
      // .effect(delay: 750.ms, duration: 1500.ms)
      // .fadeOut(duration: 4000.ms)
      // .animate(delay: 4000.ms)
      // .listen(callback: (value) => showHistory = false);
    }

    Widget gimme5Container() {
      gimme5Buttons = generateGimme5Buttons();
      if (gimme5Start) {
        gimme5Buttons = gimme5Buttons
            .animate(interval: 3000.ms)
            .effect(duration: 3000.ms)
            .effect(delay: 750.ms, duration: 1500.ms)
            .slideX(begin: 1)
            .flipH(begin: -1, alignment: Alignment.centerRight)
            .scaleXY(begin: 1, curve: Curves.easeInOutQuad)
            .untint(begin: 0.6);
      } else {
        gimme5Buttons = gimme5Buttons
            .animate(interval: 600.ms)
            .fadeIn(duration: 300.ms, delay: 300.ms)
            .shimmer(blendMode: BlendMode.srcOver, color: Colors.white12)
            .move(begin: const Offset(-16, 0), curve: Curves.easeOutQuad);
      }
      return Visibility(
          visible: displayGimme5,
          // maintainState: true,
          // maintainAnimation: true,
          child: Stack(alignment: AlignmentDirectional.bottomEnd, children: [
            Column(children: [
              Row(children: [
                const Spacer(),
                gimme5Buttons[0],
                const Spacer(),
                gimme5Buttons[1],
                const Spacer(),
              ]),
              // const Spacer(),
              gimme5Buttons[2],
              // const Spacer(),
              Row(children: [
                const Spacer(),
                gimme5Buttons[3],
                const Spacer(),
                gimme5Buttons[4],
                const Spacer(),
              ]),
              const Spacer(),
              Stack(alignment: AlignmentDirectional.bottomEnd, children: [
                Visibility(
                    visible: gameMode != GameMode.gimme5Round1,
                    child: guessResultWidget()),
                Visibility(
                    visible: gimme5OnScreenSwitch,
                    child: Center(
                      child: onScreenMessage,
                    )),
              ]),
              const Spacer(),
              gimme5Start
                  ? gimme5MessageWidget(context, gimme5Message)
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(
                          delay: 6000.ms,
                          duration: 1500.ms,
                          color: appThemeColor.withOpacity(.7))
                  : gimme5MessageWidget(context, gimme5Message)
                      .animate(delay: 2500.ms)
                      .effect(duration: 3000.ms)
                      .effect(delay: 750.ms, duration: 1500.ms)
                      .scaleXY()
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(
                          delay: 2000.ms,
                          duration: 1500.ms,
                          color: appThemeColor.withOpacity(.7))
            ]),
            Visibility(
                visible: gimme5Correct,
                child: Center(
                    child: Icon(
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.yellow.withOpacity(0.5),
                      offset: const Offset(5.0, 5.0),
                    ),
                  ],
                  Icons.check,
                  color: Colors.green,
                  size: screenH / 4,
                )
                        .animate()
                        .effect(duration: 3000.ms)
                        .effect(delay: 750.ms, duration: 1500.ms)
                        .fadeOut(duration: 3000.ms)
                        .listen(callback: (value) {
                  // debug(DateTime.now().toString());
                  // debug(value.toString());
                  gimme5Correct = false;
                }))),
            Visibility(
                visible: gimme5Wrong,
                child: Center(
                  child: Column(children: [
                    Icon(
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.yellow.withOpacity(0.5),
                          offset: const Offset(5.0, 5.0),
                        ),
                      ],
                      Icons.close,
                      color: Colors.red,
                      size: screenH / 4,
                    )
                        .animate()
                        .effect(duration: 3000.ms)
                        .effect(delay: 750.ms, duration: 1500.ms)
                        .fadeOut(duration: 4000.ms)
                        .animate(delay: 4000.ms)
                        .listen(callback: (value) => gimme5Wrong = false),
                    autoSizeText(
                        context, lastGuess, 9, buttonTextColor.withOpacity(.8)),
                  ]),
                )),
            Visibility(
              visible: userSettings.showHistory && gimme5Start,
              // child: Center(
              //   child: Column(children: [
              //     SingleChildScrollView(
              // child: Expanded(
              child: showHistoryWidget(),
              // ]),
              // )
            )
          ]));
    }

    Widget gameScreenContainer() {
      //error message widget.
      if (isOffline) {
        if (timerRunning || gameStarted) {
          _stopTimer();
        }
        return displayOfflineMessage(context, null);
      } else {
        if (!timerRunning && gameStarted) {
          _startTimer();
        }
        return Stack(children: [
          Container(
            // height: 120.0,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.transparent, // appThemeColor,
              image: DecorationImage(
                image: AssetImage('assets/lightbulb_brain.png'),
                fit: BoxFit.contain,
                opacity: .3,
                invertColors: false,
              ),
              shape: BoxShape.rectangle,
            ),
            child: Center(
              child: Text(
                textScaler: customTextScaler(context, max: 1.6),
                guessText,
                style:
                    textStyleAutoScaledByPercent(context, 16, buttonTextColor),
              ),
            ),
          ),
          Visibility(
              visible: userSettings.showHistory, child: showHistoryWidget())
        ]);
        // Lottie.asset('assets/confetti.json',
        //     controller: _controller,
        //     width: MediaQuery.sizeOf(context).width,
        //     height: MediaQuery.sizeOf(context).height,
        //     fit: BoxFit.cover,
        //     repeat: false),

        //if error is false, return empty container.
      }
    }

    speechToTextCallback() {
      debug('speech to text started');

      if (microphoneStatus!.isPermanentlyDenied) {
        showGenericAlertDialog(
            context,
            globalMessages.getMicrophoneDeniedTitle(wordLocale),
            globalMessages.getMicrophonePermanentlyDeniedMessage(wordLocale),
            '',
            'OK',
            () {});
      } else if (!microphoneStatus!.isGranted) {
        Permission.microphone.status.then((status) {
          if (!status.isGranted) {
            showGenericAlertDialog(
                context,
                globalMessages.getMicrophoneDeniedTitle(wordLocale),
                globalMessages.getMicrophoneDeniedMessage(wordLocale),
                '',
                'OK',
                () {});
          }
        });
      }
      if (globalSettings.promptForGamePageVoiceEntry) {
        if (useVoiceEntry == VoiceEntry.unset ||
            useVoiceEntry == VoiceEntry.unsubscribed) {
          useVoiceEntry = VoiceEntry.unsubscribed;
          showGenericAlertDialog(
              context,
              'Use Voice Entry?',
              'This feature costs ${globalSettings.voiceEntryFee} tokens per game.',
              'No Thanks',
              'Yes Please', () {
            useVoiceEntry = VoiceEntry.subscribed;
            streamingRecognize(context, getLocale());
          });
          if (useVoiceEntry == VoiceEntry.unsubscribed) {
            return;
          }
        }
      } else {
        if (!recognizing) {
          useVoiceEntry = VoiceEntry.subscribed;
          streamingRecognize(context, getLocale());
        } else {
          stopRecording();
        }
      }
    }

    return PopScope(
        canPop: (!gameStarted || !gimme5Start) && canPop,
        onPopInvokedWithResult: (didPop, result) {
          debug('onPopInvokedWithResult result: $result, didPop: $didPop');
          if (!didPop) {
            if (!gameStarted || !gimme5Start) {
              switch (gameMode) {
                case GameMode.multiPlayer:
                case GameMode.solo:
                  gameStarted = false;
                  Navigator.of(context).pop();
                  return;
                case GameMode.gimme5Round1:
                  if (!gimme5Start) {
                    Navigator.of(context).pop();
                    return;
                  }
                  break;
                case GameMode.gimme5Round3:
                case GameMode.gimme5Round2:
                case GameMode.party:
                case GameMode.unset:
                  break;
              }
            }
            String message = 'Do you really wanna exit?';
            if (gameMode.name.contains('gimme5')) {
              message += " You're gonna lose your wager if you exit now.";
            }
            canPop = true;
            showGenericAlertDialog(context, 'Confirmation!', message,
                "No, I'll return to the game", 'Yes, exit now', () {
              // canPop = true;
              _stopTimer();
              gimme5Start = gameStarted = false;
              switch (gameMode) {
                case GameMode.multiPlayer:
                case GameMode.solo:
                case GameMode.gimme5Round1:
                  Navigator.of(context).pop();
                  break;
                case GameMode.gimme5Round3:
                case GameMode.gimme5Round2:
                  popToMainMenu(context);
                  break;
                case GameMode.party:
                case GameMode.unset:
                  break;
              }
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => const LandingPage()),
              // ).then((value) => setState(() {
              //       resetInfoData();
              //     }));
            });
          }
        },
        child: Stack(alignment: AlignmentDirectional.bottomEnd, children: [
          animateGradient(
              _controllerAnimateGradient,
              Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent, // appThemeColor,
                  // image: DecorationImage(
                  //   alignment: Alignment.center,
                  //   image: AssetImage('assets/lightbulb_brain.png'),
                  //   fit: BoxFit.fitWidth,
                  //   opacity: .1,
                  //   invertColors: false,
                  // ),
                  shape: BoxShape.rectangle,
                ),
                width: double.infinity,
                height: double.infinity,
              )),
          Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                toolbarHeight: screenH * .05,
                iconTheme: const IconThemeData(color: Colors.white),
                actions: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          userSettings
                              .setShowHistory(!userSettings.getShowHistory());
                        });
                      },
                      icon: Icon(
                        Icons.menu_open,
                        color: userSettings.showHistory
                            ? Colors.white
                            : Colors.white24,
                        size:
                            (screenH > screenW) ? sqrt(screenH) : sqrt(screenW),
                      )),
                  IconButton(
                      onPressed: () {
                        showGameSettings(context, 'Guesser Settings', '', '',
                            'OK', () {}, setState);
                      },
                      icon: Icon(
                        Icons.settings,
                        color: Colors.white,
                        size:
                            (screenH > screenW) ? sqrt(screenH) : sqrt(screenW),
                      )),
                  IconButton(
                      onPressed: () {
                        showInfoDialog(context);
                      },
                      icon: Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size:
                            (screenH > screenW) ? sqrt(screenH) : sqrt(screenW),
                      ))
                ],
                // centerTitle: true,
                // gradient:
                //     LinearGradient(colors: [customBlueColor, appThemeColor]),
                // toolbarHeight: MediaQuery.of(context).size.height / 20,
                backgroundColor:
                    longerScreen ? Colors.transparent : resultColor,
                surfaceTintColor: Colors.transparent,
                foregroundColor: Colors.transparent,
                title: longerScreen
                    ? AutoSizeText(headerTitle,
                        style: textStyleAutoScaledByPercent(
                            context, 11, buttonTextColor))
                    : Text(
                        textScaler: customTextScaler(context),
                        guessResult,
                        style: textStyleAutoScaledByPercent(
                            context, 14, buttonTextColor),
                      ),
              ),
              body: (Column(
                  //mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tallerScreen)
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
                    Container(
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          const SizedBox(width: 15),
                          animateTimer
                              ? Text(
                                  textScaler:
                                      customTextScaler(context, max: 1.2),
                                  style: textStyleAutoScaledByPercent(
                                      context, 12, timerColor),
                                  'Timer: $minutes:$seconds.$milliseconds',
                                )
                                  .animate()
                                  .flipH(delay: 500.ms, duration: 1500.ms)
                              : Text(
                                  textScaler:
                                      customTextScaler(context, max: 1.2),
                                  style: textStyleAutoScaledByPercent(
                                      context, 12, timerColor),
                                  'Timer: $minutes:$seconds.$milliseconds',
                                ),
                          const Spacer(),
                          Text(
                            textScaler: customTextScaler(context, max: 1.2),
                            style: textStyleAutoScaledByPercent(
                                context, 12, buttonTextColor),
                            // style: TextStyle(
                            //     color: buttonTextColor,
                            //     fontSize: calculateFixedFontSize(context) *
                            //         (widerScreen ? 1 : .7),
                            //     fontWeight: FontWeight.bold),
                            'Score: $totalScore',
                          ),
                          const SizedBox(width: 15),
                        ],
                      ),
                    ),
                    Expanded(
                        flex: 9,
                        child: gameMode.name.contains('gimme5')
                            ? gimme5Container()
                            : gameScreenContainer()),
                    if (longerScreen && !gameMode.name.contains('gimme5'))
                      guessResultWidget(),
                    // ]),
                    //   animateGradient(SizedBox(
                    //     width: screenW,
                    //     height: screenH / 2,
                    //   )),
                    // ]),
                    // const Spacer(),
                    Row(children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                        child: MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                                textScaler: const TextScaler.linear(1.0)),
                            child: TextFormField(
                              autocorrect: false,
                              autofocus: !userSettings.useCustomKeyboard,
                              onEditingComplete: () {
                                // debug('onEditingComplete');
                              },
                              onSaved: (newValue) => {debug('onSaved')},
                              onFieldSubmitted: (val) {
                                // debug('onFieldSubmitted: $val');
                                switch (gameMode) {
                                  case GameMode.solo:
                                  case GameMode.multiPlayer:
                                    gameDefaultSubmit();
                                    break;
                                  case GameMode.gimme5Round1:
                                    gimme5Submit();
                                    break;
                                  case GameMode.gimme5Round2:
                                  case GameMode.gimme5Round3:
                                    gimme5R2and3Submit();
                                    break;
                                  case GameMode.party:
                                  case GameMode.unset:
                                    // unused
                                    break;
                                }
                              },
                              controller: textController,
                              // readOnly: true,
                              keyboardType: userSettings.getUseCustomKeyboard()
                                  ? TextInputType.none
                                  : TextInputType.text,

                              style: textStyleAutoScaledByPercent(
                                  context, 14, buttonTextColor),
                              // style: TextStyle(
                              //   fontWeight: FontWeight.bold,
                              //   color: inputTextColor,
                              //   fontSize: calculateFixedFontSize(context),
                              // ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.fromLTRB(
                                    15.0, 0.0, 0.0, 0.0),
                                filled: true,
                                fillColor: Colors.transparent,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide(
                                      width: 2.0, color: appThemeColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide(
                                      width: 2.0, color: mainBackgroundColor),
                                ),
                                hintText: hintText,
                                // hintText: _isListening ? _lastWord : '',
                                hintStyle: textStyleAutoScaledByPercent(context,
                                    11, buttonTextColor.withOpacity(.5)),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                            )),
                      )),
                      defaultIconButton2(
                          context,
                          2,
                          1,
                          Icon(Icons.menu,
                              color: Colors.white, size: sqrt(screenW)), () {
                        setState(() {
                          // userSettings.setShowHistory(true);
                          myDuration = Duration(seconds: 5);
                        });
                      }),
                      SizedBox(
                        width: 5,
                      )
                    ]),
//                     Visibility(
//                       visible: userSettings.getUseCustomKeyboard(),
// child: KeyboardTypeBuilder(
//      builder: (
//        BuildContext context,
//        CustomKeyboardController controller,
//      ) =>
//          ToggleButton(
//        builder: (bool active) => Icon(
//          Icons.sentiment_very_satisfied,
//          color: active ? Colors.orange : null,
//        ),
//        activeChanged: (bool active) {
//          _keyboardPanelType = KeyboardPanelType.emoji;
//          if (active) {
//            controller.showCustomKeyboard();
//            if (!_focusNode.hasFocus) {
//              SchedulerBinding.instance
//                  .addPostFrameCallback((Duration timeStamp) {
//                _focusNode.requestFocus();
//              });
//            }
//          } else {
//            controller.showSystemKeyboard();
//          }
//        },
//        active: controller.isCustom &&
//            _keyboardPanelType == KeyboardPanelType.emoji,
//      ),
//    ),
                    // ),
                    Visibility(
                        visible: userSettings.getUseCustomKeyboard(),
                        child: Container(
                            // height: screenH / 3.9,
                            // width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                              // image: DecorationImage(
                              //   // centerSlice: Rect.fromLTRB(40, 40, 40, 40),
                              //   repeat: ImageRepeat.noRepeat,
                              //   alignment: Alignment.center,
                              //   image: AssetImage('assets/lightbulb_brain.png'),
                              //   fit: BoxFit.scaleDown,
                              //   opacity: .1,
                              //   invertColors: false,
                              // ),
                              shape: BoxShape.rectangle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: RepaintBoundary(
                                  child: BuiltInKeyboard(
                                height: getSizeOfText(
                                        'a',
                                        textStyleAutoScaledByPercent(
                                            context, 16, buttonTextColor))
                                    .height,
                                letterStyle: textStyleAutoScaledByPercent(
                                    context, 13, buttonTextColor),
                                // letterStyle: TextStyle(
                                //     fontSize: calculateFixedFontSize(context),
                                //     fontWeight: FontWeight.bold,
                                //     color: Colors.white),
                                color: Colors.white.withOpacity(.05),
                                borderRadius: BorderRadius.circular(8),
                                controller: textController,
                                enableLongPressUppercase: false,
                                enableSpaceBar: true,
                                enableBackSpace: true,
                                enableCapsLock: false,
                                enableAllUppercase: false,
                                splashColor: Colors.transparent,
                                language: getLocale() == 'ph'
                                    ? Language.PH
                                    : Language.EN,
                                layout: getLocale() == 'ph'
                                    ? Layout.QWERTN
                                    : Layout.QWERTY,
                              )),
                            ))),
                    const SizedBox(height: 3),
                    Row(children: [
                      const Spacer(),
                      Visibility(
                        visible: gameMode == GameMode.gimme5Round2 ||
                            gameMode == GameMode.gimme5Round3,
                        child: defaultButtonWithDirection(
                            context, 2, 1, 'Pass', GradientOrientation.Vertical,
                            () async {
                          if (!gimme5Start) return;
                          String message = 'Skip this word?';
                          String noButton = 'No Thanks';
                          String yesButton = 'Yes Please';
                          if (gimme5RandomWordSelections.isEmpty) {
                            //
                            message =
                                "Can't pass anymore since it's the last word. End the round instead?";
                            noButton = 'No, go back';
                            yesButton = "Yes, end this round";
                          }
                          await showGenericAlertDialog(context, 'Confirmation',
                              message, noButton, yesButton, () {
                            // go to the next word unless it's the last one
                            if (gimme5RandomWordSelections.isEmpty) {
                              myDuration = Duration(seconds: 0);
                              return;
                            }
                            int index =
                                5 - (gimme5RandomWordSelections.length + 1);
                            colorBorder[index] = Colors.red;
                            gimme5Words[index] = gimme5RandomWords[index];
                            loadNextGimme5Word();
                          });
                        }),
                      ),
                      Visibility(
                          visible: blankButtonVisibility(),
                          child: blankButton(context)),
                      Visibility(
                          visible: hintButtonVisibility(),
                          child: AvatarGlow(
                            animate: true,
                            glowColor: appThemeColor,
                            duration: const Duration(seconds: 2),
                            repeat: true,
                            // repeatPauseDuration: const Duration(milliseconds: 500),
                            // endRadius: 30.0,
                            child: defaultIconButton(
                                context,
                                2,
                                1,
                                Icon(
                                  Icons.question_mark,
                                  color: Colors.white,
                                  size: sqrt(screenW),
                                ), () async {
                              if (!gameStarted) return;
                              await showGenericAlertDialog(
                                  context,
                                  'Use a hint?',
                                  globalMessages
                                      .getUseHintMessage(wordLocale)
                                      .replaceFirst('\$hintFee',
                                          '${globalSettings.hintFee}'),
                                  'No Thanks',
                                  "Yes Please",
                                  _useHint);
                            }),
                          )),
                      if (submitButtonGimme5Visibility()) const Spacer(),
                      Visibility(
                          visible: submitButtonGimme5Visibility(),
                          child: Center(
                              child: defaultButtonWithDirection(
                                  context,
                                  1.5,
                                  1,
                                  'Submit',
                                  GradientOrientation.Vertical,
                                  gameMode == GameMode.gimme5Round1
                                      ? gimme5Submit
                                      : gimme5R2and3Submit))),
                      if (!submitButtonVisibility() &&
                          !submitButtonGimme5Visibility())
                        const Spacer(),
                      Visibility(
                          visible: !submitButtonVisibility() &&
                              !submitButtonGimme5Visibility(),
                          child: Center(
                              child: defaultButtonWithDirection(
                                  context,
                                  1.5,
                                  1,
                                  'Start Game',
                                  GradientOrientation.Vertical,
                                  gameStartCallback))),
                      if (submitButtonVisibility()) const Spacer(),
                      Visibility(
                          visible: submitButtonVisibility(),
                          child: Center(
                              child: defaultButton(
                                  context, 1, 1, 'Submit', gameDefaultSubmit))),
                      const Spacer(),
                      Visibility(
                          visible: serviceAccountKey.isEmpty,
                          child: defaultIconButton(
                              context,
                              2,
                              1,
                              Icon(
                                Icons.mic_off,
                                color: Colors.white,
                                size: sqrt(screenW),
                              ), () {
                            getServiceAccountKey();
                          })),
                      Visibility(
                          visible: serviceAccountKey.isNotEmpty,
                          child: AvatarGlow(
                              animate: true,
                              glowColor: appThemeColor.withAlpha(25),
                              duration: const Duration(seconds: 2),
                              repeat: true,
                              // repeatPauseDuration: const Duration(milliseconds: 500),
                              // endRadius: 30.0,
                              child: defaultIconButton(
                                  context,
                                  2,
                                  1,
                                  recognizing
                                      ? Icon(
                                          Icons.mic,
                                          color: Colors.red.shade400,
                                          size: sqrt(screenW),
                                        )
                                      : Icon(
                                          Icons.mic_off,
                                          color: Colors.white,
                                          size: sqrt(screenW),
                                        ),
                                  speechToTextCallback))),
                      const Spacer(),
                    ]),
                    SizedBox(
                        height: screenH > screenHeightThreshold ||
                                userSettings.useCustomKeyboard
                            ? 20
                            : 3),
                  ]))),
          Visibility(
            visible: !waitForConfetti,
            child: Lottie.asset('assets/confetti.json',
                controller: _controller,
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height,
                fit: BoxFit.cover,
                repeat: false),
          ),
        ]));
  }

  bool submitButtonVisibility() {
    switch (gameMode) {
      case GameMode.solo:
      case GameMode.multiPlayer:
        return gameStarted;
      case GameMode.gimme5Round1:
      case GameMode.gimme5Round2:
      case GameMode.gimme5Round3:
      case GameMode.party:
      case GameMode.unset:
        return false;
    }
  }

  bool submitButtonGimme5Visibility() {
    switch (gameMode) {
      case GameMode.gimme5Round1:
      case GameMode.gimme5Round2:
      case GameMode.gimme5Round3:
        return gimme5Start;
      case GameMode.solo:
      case GameMode.multiPlayer:
      case GameMode.party:
      case GameMode.unset:
        return false;
    }
  }

  bool blankButtonVisibility() {
    switch (gameMode) {
      case GameMode.gimme5Round1:
      case GameMode.multiPlayer:
        return true;
      case GameMode.party:
      case GameMode.unset:
      case GameMode.gimme5Round2:
      case GameMode.gimme5Round3:
        return false;
      case GameMode.solo:
        return enableHint ||
            tries < (globalSettings.maxTriesForHintToAppear + 1);
    }
  }

  bool hintButtonVisibility() {
    switch (gameMode) {
      case GameMode.gimme5Round1:
      case GameMode.gimme5Round2:
      case GameMode.gimme5Round3:
      case GameMode.multiPlayer:
      case GameMode.party:
      case GameMode.unset:
        return false;
      case GameMode.solo:
        return !enableHint &&
            tries > globalSettings.maxTriesForHintToAppear &&
            credits > 0;
    }
  }

  VoiceEntry useVoiceEntry = VoiceEntry.unset;
  bool recognizing = false;
  bool recognizeFinished = false;
  AudioRecorder? recorder;
  StreamSubscription? _recordingDataSubscription;
  int _startRecordingTimeStamp = 0;

  void autoStopRecordingOnIdle() async {
    _startRecordingTimeStamp = DateTime.now().millisecondsSinceEpoch;
    while (_startRecordingTimeStamp + 125000 >
            DateTime.now().millisecondsSinceEpoch &&
        recognizing) {
      await wait(1);
    }
    if (recognizing) stopRecording();
  }

  void streamingRecognize(context, String locale) async {
    await Permission.microphone.request();
    deductUserCredits(globalSettings.voiceEntryFee);
    setState(() {
      recognizing = true;
    });
    recorder = AudioRecorder();

    final serviceAccount =
        ServiceAccount.fromString(await getServiceAccountKey());
    final speechToText = SpeechToText.viaServiceAccount(serviceAccount);

    final responseStream = speechToText.streamingRecognize(
        StreamingRecognitionConfig(
            config: RecognitionConfig(
                encoding: AudioEncoding.LINEAR16,
                model: RecognitionModel.basic,
                enableAutomaticPunctuation: true,
                sampleRateHertz: 16000,
                languageCode: locale == 'ph' ? 'fil-PH' : 'en-US'),
            interimResults: true),
        await recorder!.startStream(const RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            numChannels: kAudioNumChannels,
            sampleRate: kAudioSampleRate)));

    var responseText = '';
    autoStopRecordingOnIdle();
    _recordingDataSubscription = responseStream.listen((data) {
      final currentText =
          data.results.map((e) => e.alternatives.first.transcript).join(' ');

      if (data.results.first.isFinal) {
        responseText += ' $currentText';
        debug(responseText);
        textController.text =
            removeCluegiverResponse(currentText).trim().toLowerCase();
        setState(() {
          recognizeFinished = true;
        });
      } else {
        setState(() {
          removeCluegiverResponse(currentText).trim().toLowerCase();
        });
      }

      // else {
      //   setState(() {
      //     text = '$responseText $currentText';
      //     recognizeFinished = true;
      //     if (!cluegiverResponses.contains(currentText.toLowerCase())) {
      //       textController.text = removeCluegiverResponse(currentText);
      //     }
      //   });
      // }
    }, onDone: () {
      setState(() {
        recognizing = false;
        // textController.text = '';
      });
    });
  }

  void pauseRecording() async {
    if (!recognizing) return;
    debug('s:${DateTime.now()}');
    recorder!.pause();
    _recordingDataSubscription!.pause();
    // debug(DateTime.now().toString());
    await waitInMs(globalSettings.msPauseForVoiceEntry);
    recorder!.resume();
    _recordingDataSubscription!.resume();
    debug('e:${DateTime.now()}');
  }

  void stopRecording() async {
    try {
      setState(() {
        recognizing = false;
      });
      _recordingDataSubscription?.cancel();
      if (await recorder!.isRecording()) recorder?.stop();
    } catch (e) {
      debug('stopRecording: $e');
    }
  }

  void _startTimer() {
    countdownTimer = Timer.periodic(
        const Duration(milliseconds: 69), (_) => _setCountDown());
    timerRunning = true;
    timerColor = constTimerColor;
  }

  void _stopTimer() {
    setState(() => countdownTimer!.cancel());
    timerRunning = false;
  }

  void _resetTimer() {
    if (timerRunning) _stopTimer();
    setState(() => myDuration = Duration(minutes: globalSettings.gameDuration));
  }

  void _setCountDown() {
    const int reduceBy = 69;
    setState(() {
      final seconds = myDuration.inMilliseconds - reduceBy;
      if (seconds <= 0) {
        if (gameMode.name.contains('gimme5')) {
          gimme5Words = gimme5RandomWords;
          gimme5Correct = false;
          gimme5Wrong = false;
          for (int i = 0; i < colorBorder.length; i++) {
            if (colorBorder[i] == Colors.transparent) {
              colorBorder[i] = Colors.red;
            }
          }
          if (gimme5CorrectGuessCount > 2) {
            waitForConfetti = false;
            _controller.forward().whenComplete(() {
              setState(() {
                waitForConfetti = true;
              });
              _controller.reset();
              if (gameMode == GameMode.gimme5Round3) {
                showGimme5WinnerDialog();
              } else {
                gimme5LaunchNextRound();
              }
            });
          } else {
            _afterRoundTasks();
            showGimme5GameOver();
          }
        }
        player2.stop();
        if (gameMode.name.contains('gimme5') && gimme5CorrectGuessCount > 2) {
          player.playRightAnswerSound();
        } else {
          player.playTimerRanOutSound();
        }
        myDuration = const Duration(milliseconds: 0);
        guessText = getLocale() == 'en'
            ? 'the answer was\n$wordToGuess'
            : 'ang sagot ay\n$wordToGuess';
        resultColor = constResultColor;
        guessResult = 'GAME OVER';
        totalStreak = user.resetTotalStreak();
        streak = user.resetStreak();
        // deductUserCredits(50);
        if (_rewardedAd != null && gamesPlayedCount >= 7) {
          if (gameMode == GameMode.multiPlayer)
            sendUserResponse(
                'guesserResponse:showAd', mpInfo!.data.room, delay);
          gamesPlayedCount = 0;
          debug('showing rewarded ad');
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AdDialog(
                      earnReward: false,
                      showAd: () {
                        _showRewardedAd();
                      },
                    )),
          );
        } else if (_interstitialAd != null) {
          debug('showing interstitial ad');
          _interstitialAd!.show();
        }
        // need to be last call to set credits
        _afterRoundTasks();
      } else {
        if (seconds <= 10000) {
          if (seconds % 1000 > 930) {
            player2.playTimerRunningOutSound();
            if (gameMode == GameMode.solo) {
              guessText = shuffleWord(wordToGuess).toLowerCase();
            }
          }
          if (seconds % 1000 > 0 && seconds % 1000 < 400) {
            timerColor = constTimerColor;
          } else {
            timerColor = Colors.red;
          }
        }
        if (enableHint && seconds % 1000 > 930) {
          guessText = shuffleWord(wordToGuess).toLowerCase();
        }
        myDuration = Duration(milliseconds: seconds);
      }
    });
  }

  // void gimme5AfterRound1() {}

  String guessResultLocale(String result) {
    if (wordLocale == 'ph') {
      switch (result.toLowerCase()) {
        case 'oo':
        case 'yes':
          return 'oo';
        case 'pwede':
        case 'close':
          return 'pwede';
        case 'hindi':
        case 'no':
          return 'hindi';
      }
      return 'hindi';
    } else {
      switch (result.toLowerCase()) {
        case 'oo':
        case 'yes':
          return 'yes';
        case 'pwede':
        case 'close':
          return 'close';
        case 'hindi':
        case 'no':
          return 'no';
      }
    }
    return 'no';
  }

  void guessResultHandler(String result) {
    debug(result);

    guessResult = result;
    switch (result.toLowerCase()) {
      case 'oo':
      case 'yes':
        resultColor = Colors.green;
        player.playYesSound(getLocale());
        break;
      case 'pwede':
      case 'close':
        resultColor = Colors.orange;
        player.playMaybeSound(getLocale());
        break;
      case 'hindi':
      case 'no':
        resultColor = Colors.red;
        player.playNoSound(getLocale());
        break;
      default:
        resultColor = constResultColor;
    }
  }

  bool _possibly(String guessText) {
    debug(guessText);
    String guess = WordSelection.sanitize(guessText);
    for (String text in wordsPossible!) {
      if (text == guess) {
        return true;
      }
    }
    return wordsPossible!.contains(WordSelection.sanitize(guessText));
  }

  int _calculateScore() {
    int s = (myDuration.inMilliseconds / 30000).ceil();
    switch (wordDifficulty) {
      case 'h':
        s *= 5;
        break;
      case 'm':
        s *= 4;
        break;
      default:
        s *= 3;
    }
    debug('score calc: $s');
    return s;
  }

  void _addToGimme5GuessMap() {
    debug('adding to userguess: ${userGuesses.toString()}');
    userGuesses.putIfAbsent(
        '"${++gimme5AttemptCounter}"',
        () =>
            '"${guessText.trim().toLowerCase()}:${guessResult.trim().toLowerCase()}:${myDuration.inMilliseconds}"');
  }

  void _addToUserGuessMap() {
    if (myDuration.inMilliseconds > 0) {
      userGuesses.putIfAbsent(
          '"${myDuration.inMilliseconds}"',
          () =>
              '"${guessText.trim().toLowerCase()}:${guessResult.trim().toLowerCase()}"');
    } else {
      userGuesses.putIfAbsent(
          '"0001"',
          () =>
              '"${guessText.trim().toLowerCase()}:${guessResult.trim().toLowerCase()}"');
    }
  }

  void _saveUserGuessEntry() async {
    UserGuesses guess = UserGuesses(
        id: 0,
        name: username,
        word: guessText.trim().toLowerCase(),
        timestamp: DateTime.now().millisecond,
        // extraData: jsonEncode(
        //     '{"useVoiceEntry":"${useVoiceEntry.name}","hintUsed":$enableHint,"tokensCount":$credits,"difficulty setting":"$wordDifficulty","colorTheme":"$themeColorName"}'),
        extraData: jsonEncode(jsonEncode(<String, dynamic>{
          //need to double encode to store in db
          "useVoiceEntry": useVoiceEntry.name,
          "hintUsed": enableHint,
          "tokensCount": credits,
          "colorTheme": themeColorName,
          "alias": alias,
          "userSettings": jsonEncode(userSettings.toJson()),
        })),
        attempts: jsonEncode(userGuesses.toString().toLowerCase()));
    int i = 0;
    while ((await postUserGuess(guess.toJson().toString())).statusCode != 200 &&
        i < 5) {
      await wait(++i);
    }
  }

  void _saveMultiPlayerGuessEntry() async {
    MultiPlayerGuesses guess = MultiPlayerGuesses(
        id: 0,
        guesser: getRoomData().guesser,
        cluegiver: getRoomData().cluegiver,
        word: guessText.toLowerCase(),
        extradata: jsonEncode(jsonEncode(<String, dynamic>{
          //need to double encode to store in db
          "useVoiceEntry": useVoiceEntry.name,
          "hintUsed": enableHint,
          "tokensCount": credits,
          "difficulty setting": wordDifficulty,
          "colorTheme": themeColorName,
          "roomName": mpInfo!.data.room,
        })),
        attempts: jsonEncode(userGuesses.toString().toLowerCase()));
    int i = 0;
    while ((await postMultiPlayerGuess(guess.toJson().toString())).statusCode !=
            200 &&
        i < 5) {
      await wait(++i);
    }
  }

  void _saveGimme5GuessEntry() async {
    Gimme5Guesses guess = Gimme5Guesses(
        id: 0,
        round: gameMode.name,
        name: username,
        words: gimme5RandomWords.toString().toLowerCase(),
        timestamp: DateTime.now().millisecond,
        extradata: jsonEncode(jsonEncode(<String, dynamic>{
          //need to double encode to store in db
          "useVoiceEntry": useVoiceEntry.name,
          "tokensCount": credits,
          "difficulty setting": wordDifficulty,
          "colorTheme": themeColorName,
        })),
        attempts: jsonEncode(userGuesses.toString().toLowerCase()));
    // objectBox.addUserGuess(guess);
    int i = 0;
    while (
        (await postGimme5Guess(guess.toJson().toString())).statusCode != 200 &&
            i < 5) {
      await wait(++i);
    }
  }

  void _useHint() {
    debug('hint used');
    enableHint = true;
    deductUserCredits(globalSettings.hintFee);
  }

  void _afterRoundTasks() {
    gamesPlayedCount++;
    _stopTimer();
    textController.text = '';
    if (recognizing) stopRecording();
    objectBox.setUser(user);
    updateRecordFromUser(user);
    setUserWeeklyRecord(user);
    gameStarted = false;
    gimme5Start = false;
    hintText = '';
    animateTimer = false;

    switch (gameMode) {
      case GameMode.solo:
        _addToUserGuessMap();
        _saveUserGuessEntry();
        break;
      case GameMode.multiPlayer:
        _addToUserGuessMap();
        _saveMultiPlayerGuessEntry();
        break;
      case GameMode.gimme5Round1:
      case GameMode.gimme5Round2:
      case GameMode.gimme5Round3:
        _addToGimme5GuessMap();
        _saveGimme5GuessEntry();
        break;
      case GameMode.unset:
      case GameMode.party:
        assert(true); // should not get here
        break;
    }
    // guessResult = '';
    enableHint = false;
    useVoiceEntry = VoiceEntry.unset;
    // if (wordsMap.isEmpty) {
    //   String list = objectBox.getBackupWordsList();
    //   if (list.isNotEmpty) {
    //     wordsMap = jsonDecode(list);
    //   } else {
    //     fetchWordsList2().then((henyoWords) {
    //       objectBox.setWordsList(henyoWords!.wordsList);
    //       wordsMap = jsonDecode(henyoWords.wordsList);
    //     });
    //   }
    // }
  }

  bool alertShowing = false;
  void subscribeToRoom(String roomName) {
    // ignore: prefer_typing_uninitialized_variables
    var newMsgFromAbly;
    chatChannel!.subscribe(name: roomName).listen((ably.Message message) {
      // AblyUser guesser = AblyUser(id: 0, name: username);
      AblyMessage newChatMsg = AblyMessage();
      newMsgFromAbly = message.data;
      debug("New message arrived (guesserpage)${message.data}");
      String msg = newMsgFromAbly["text"];
      if (msg.contains('cluegiverLeft') && !alertShowing) {
        alertShowing = true;
        showGenericAlertDialog(context, 'Game room: $roomName',
            'Clue giver left the room.', '', 'Go Back', () {
          Navigator.of(context).pop();
        });
      }
      var msgTime = DateTime.now().toString();
      if (message.clientId == getRoomData().guesser) {
        newChatMsg = AblyMessage(
          sender: guesser,
          time: msgTime,
          text: newMsgFromAbly["text"],
          unread: false,
        );
      } else {
        if (!msg.contains('cluegiverAnswer:')) {
          return;
        }
        guessResult = msg.split(':')[1];
        _addToUserGuessMap();
        switch (guessResult.toLowerCase()) {
          case 'oo':
          case 'yes':
            resultColor = Colors.green;
            player.playYesSound(getLocale());
            break;
          case 'pwede':
          case 'close':
            resultColor = Colors.orange;
            player.playMaybeSound(getLocale());
            break;
          case 'hindi':
          case 'no':
            resultColor = Colors.red;
            player.playNoSound(getLocale());
            break;
          default:
            resultColor = constResultColor;
        }
        setState(() {});
      }
      if (mounted) {
        setState(() {
          ablyMessages.insert(0, newChatMsg);
        });
      }
    });
  }

  void _resetGimme5Data() {
    gimme5CorrectGuessCount = 0;
    gimme5Words = getGimme5Categories(wordLocale);
    if (gameMode == GameMode.gimme5Round3) gimme5Words = gimme5Index;
    colorBorder = [
      Colors.transparent,
      Colors.transparent,
      Colors.transparent,
      Colors.transparent,
      Colors.transparent
    ];
  }

  void setUserScore(int currentScore) {
    if (inCurrentWeek(record!.modified)) {
      score = user.score += currentScore;
    } else {
      score = user.score = currentScore;
    }
  }

  void setUserStreak(int currentStreak) {
    if (inCurrentWeek(record!.modified)) {
      streak = user.streak = currentStreak;
    } else {
      streak = user.streak = 1;
    }
  }

  showGimme5WinnerDialog() {
    int award = gimme5Wager * 2;
    String text = 'doubled.';
    if (gimme5TotalCorrectGuessCount == 15) {
      text = 'quadrupled for getting all correct answers!';
      award *= 2;
    }
    showGenericAlertDialog(
        context,
        'Congratulations',
        "You won all 3 rounds of Gimme 5! Your wager will be $text You won $award tokens",
        '',
        'OK', () {
      setUserCredits(award + gimme5Wager);
      popToMainMenu(context);
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => const LandingPage()),
      // ).then((value) => setState(() {
      //       resetInfoData();
      //     }));
    });
  }

  showGimme5GameOver() {
    showGenericAlertDialogPopOption(
        context,
        'GAME OVER!',
        "You failed to get at least 3 correct answers. You guessed $gimme5CorrectGuessCount out of 5.",
        'Back to Main Menu',
        () {
          player3.playGoBackSound();
          switch (gameMode) {
            case GameMode.gimme5Round3:
            case GameMode.gimme5Round2:
              popToMainMenu(context);
              break;
            case GameMode.gimme5Round1:
              Navigator.of(context).pop();
              break;
            case GameMode.multiPlayer:
            case GameMode.solo:
            case GameMode.party:
            case GameMode.unset:
              break;
          }
          popToMainMenu(context);
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const LandingPage()),
          // ).then((value) => setState(() {
          //       resetInfoData();
          //     }));
        },
        'Try again?',
        () {
          gameMode = GameMode.gimme5Round1;
          player3.playOpenPage();
          popToMainMenu(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GamePage()),
          ).then((value) => setState(() {
                resetInfoData();
              }));
        },
        false,
        0.37);
  }

  setUserData() {
    int currentScore = _calculateScore();
    setUserScore(currentScore);
    totalScore += currentScore;
    user.setTotalScore(totalScore);
    if (!gameMode.name.contains('gimme5')) {
      tokenReward = enableHint ? (currentScore / 2).floor() : currentScore;
      setUserCredits(tokenReward);
      totalStreak = user.incrementTotalStreak();
      setUserStreak(user.incrementStreak());
    }
  }

  Future<String> checkAI(String prompt, String compareWith, String compareTo) {
    String content =
        'Words are "$compareWith:$compareTo and subject1 is a type of $wordCategory"';
    return vertexAI(prompt, content);
  }

  // Future<String> checkAI(
  //     String prompt, String compareWith, String compareTo) async {
  //   GeminiHandler().initialize(apiKey: apiKeyGemini);
  //   String text =
  //       '$prompt Words are $compareWith:$compareTo"'.replaceAll('\n', ' ');
  //   bool gimme5NotRound1 = gameMode != GameMode.gimme5Round1;
  //   if (gimme5NotRound1) {
  //     text +=
  //         ' and base your response that $wordToGuess relates to $wordCategory"';
  //   }
  //   hintText =
  //       '...checking with AI. You can continue answering if response is delayed.';
  //   final response =
  //       await GeminiHandler().geminiPro(temprature: 0.1, text: text);
  //   var result = response?.candidates?.first.content?.parts?.first.text;
  //   debug(result.toString());
  //   hintText = '...Start guessing';
  //   return result == null
  //       ? gimme5NotRound1
  //           ? 'no'
  //           : '0'
  //       : result.toString();
  // }
}
