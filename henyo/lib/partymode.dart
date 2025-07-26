import 'dart:async';
import 'dart:convert';

import 'package:HenyoU/soundplayer.dart';
import 'package:HenyoU/wordselection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_speech/google_speech.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'ad_helper.dart';
import 'debug.dart';
import 'helper.dart';

class PartyModePage extends StatefulWidget {
  const PartyModePage({super.key});

  @override
  PartyMode createState() => PartyMode();
}

class PartyMode extends State<PartyModePage> {
  BannerAd? _bannerAd;
  bool timerStarted = false;
  bool showOneTime = true;
  SoundPlayer player = SoundPlayer();
  SoundPlayer player2 = SoundPlayer();
  Color timerPMColor = darkTextColor;
  int testColor = 0;
  VoiceEntry useVoiceEntry = VoiceEntry.unset;
  PermissionStatus? microphoneStatus;
  String guess = '';
  double opacity = .7;
  Map<String, String> userGuesses = <String, String>{};

  @override
  void initState() {
    currentShowOnceValue =
        setInfoStrings(ShowOnceValues.partyModePage, infoLocale);
    super.initState();

    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
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

    wordsMP.loadMPWordsList();
    wordToGuess = '';
    // wordToGuess = 'philippine eagle';
    // wordToGuess = 'president bong bong marcos';

    _resetTimer();
    initSpeech();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!showOnce.infoPartyModeShown) {
        showInfoDialog(context);
        showOnce.infoPartyModeShown = true;
        objectBox.setShowOnce(showOnce);
      }
    });
  }

  @override
  void dispose() {
    scaffoldColor = Colors.transparent;
    player.playBackspaceSound();
    resetInfoData();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    if (timerStarted) _stopTimer();
    countdownTimer?.cancel();
    _bannerAd?.dispose();
    recorder?.dispose();
    _recordingDataSubscription?.cancel();
    gameMode = GameMode.unset;
    super.dispose();
    // await wait(2);
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

  void _startTimer() {
    countdownTimer = Timer.periodic(
        const Duration(milliseconds: 69), (_) => _setCountDown());
    timerRunning = true;
    timerPMColor = darkTextColor;
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
        player2.stop();
        player.playTimerRanOutSound();
        myDuration = const Duration(milliseconds: 0);
        endOfRound();
      } else {
        if (seconds <= 10000) {
          if (seconds % 1000 > 930) {
            player2.playTimerRunningOutSound();
          }
          if (seconds % 1000 > 0 && seconds % 1000 < 400) {
            timerPMColor = darkTextColor;
          } else {
            timerPMColor = Colors.red;
          }
        }
        myDuration = Duration(milliseconds: seconds);
      }
    });
  }

  void endOfRound() {
    debug('game ended');
    _stopTimer();
    _addToUserGuessMap(userGuesses.isNotEmpty
        ? 'guesser got the word'
        : 'guesser was not playing henyo assist');
    _saveUserGuessEntry();
    useVoiceEntry = VoiceEntry.unset;
    timerStarted = false;
    if (recognizing) stopRecording();
    // myDuration = const Duration(milliseconds: 0);
  }

  void _addToUserGuessMap(String guessResult) {
    userGuesses.putIfAbsent(
        myDuration.inMilliseconds > 0
            ? '"${myDuration.inMilliseconds}"'
            : '"0001"',
        () =>
            '"${guess.trim().toLowerCase()}:${guessResult.trim().toLowerCase()}"');
  }

  void _saveUserGuessEntry() async {
    PartyModeGuesses guessEntries = PartyModeGuesses(
        id: 0,
        name: username,
        word: wordToGuess.trim().toLowerCase(),
        timestamp: DateTime.now().millisecond,
        extraData: jsonEncode(jsonEncode(<String, dynamic>{
          //need to double encode to store in db
          "useVoiceEntry": useVoiceEntry.name,
        })),
        attempts: jsonEncode(userGuesses.toString().toLowerCase()));
    // objectBox.addUserGuess(guess);
    int i = 0;
    while ((await postPartyModeGuess(guessEntries.toJson().toString()))
                .statusCode !=
            200 &&
        i < 5) {
      await wait(++i);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    final minutes = strDigits(myDuration.inMinutes.remainder(60), 2);
    final seconds = strDigits(myDuration.inSeconds.remainder(60), 2);
    final milliseconds =
        strDigits(myDuration.inMilliseconds.remainder(1000), 3);
    double screenW = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final bool widerScreen = screenW > 374.0;
    const double fontScale = .8;
    // double d =
    //     calculateFontSize(wordToGuess!) + calculateFixedFontSize(context);
    // debug('$d');
    // debug(
    // 'calculated font size: ${calculateFontSize(wordToGuess!) + calculateFixedFontSize(context)}');
    return lightBulbBackgroundWidget(
        context,
        'Henyo Party',
        Column(
            //mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                SizedBox(
                    width: screenW * .4,
                    child: Text(
                      textScaler: customTextScaler(context, max: 1.1),
                      style: textStyleAutoScaledByPercent(
                          context, 14, timerPMColor),
                      // style: TextStyle(
                      //     color: timerPMColor,
                      //     fontSize: calculateFixedFontSize(context) *
                      //         (widerScreen ? 1 : .7),
                      //     fontWeight: FontWeight.bold),
                      ' Timer: $minutes:$seconds.$milliseconds',
                    )),
                const Spacer(),
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
                  (SizedBox(
                    height: bannerHeight,
                    width: screenW * .6,
                  )),
                // const Spacer(),
                // const SizedBox(
                //   height: 50,
                //   width: 20,
                // )
              ]),
              if (showOneTime)
                Row(children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Container(
                      color: Colors.transparent,
                      width: screenW * .8,
                      child: Text(
                          style: textStyleAutoScaledByPercent(
                              context, 12, darkTextColor),
                          textScaler: customTextScaler(context),
                          globalMessages.getPartyModeMessage(wordLocale))),
                  const SizedBox(
                    width: 10,
                  ),
                ]),
              if (height > 650) const Spacer(),
              Visibility(
                  visible: timerStarted || !showOneTime,
                  child: SizedBox(
                      child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                        textScaler: customTextScaler(context, max: 1.0),
                        // style: textStyleAutoScaledByPercent(
                        //     context,
                        //     calculateFontSizePartyMode(context, wordToGuess!),
                        //     darkTextColor),
                        style: TextStyle(
                            fontSize: (calculateFontSize(wordToGuess) +
                                    calculateFixedFontSize(context)) *
                                1.3,
                            fontWeight: FontWeight.bold,
                            color: darkTextColor),
                        wordToGuess.toUpperCase()),
                  ))),
              if (widerScreen) const Spacer(),
              Visibility(
                  visible: timerStarted && recognizing,
                  child: Row(children: [
                    Text(
                      textScaler: customTextScaler(context),
                      'henyo assistant: $guess',
                      style: textStyleAutoScaledByPercent(
                          context, 16, darkTextColor),
                      // style: TextStyle(
                      //     fontSize: calculateFontSize(guess) * .7,
                      //     fontWeight: FontWeight.bold,
                      //     color: darkTextColor),
                    ),
                    const Spacer(),
                  ])),
              const Spacer(),
              Container(
                  color: Colors.transparent,
                  child: Row(children: [
                    const Spacer(),
                    Container(
                      width: screenW / 6,
                      color: Colors.transparent,
                      child: Visibility(
                          visible: !timerStarted,
                          child: defaultScaledLandscapeButton(
                              context, 1.5, 1, fontScale, opacity, 'Back', () {
                            Navigator.pop(context);
                          })),
                    ),
                    const Spacer(),
                    Container(
                      color: Colors.transparent,
                      child: Center(
                        child: defaultScaledLandscapeButton(
                            context,
                            1.5,
                            .8,
                            fontScale,
                            opacity,
                            timerStarted ? 'Stop Timer' : 'Start Guessing', () {
                          setState(() {
                            timerStarted = !timerStarted;
                            if (showOneTime) showOneTime = false;
                            if (timerStarted) {
                              guess = '';
                              userGuesses = <String, String>{};
                              player.playStartGameSound();
                              scaffoldColor = Colors.transparent;
                              _resetTimer();
                              _startTimer();
                            } else {
                              player.playBackspaceSound();
                              endOfRound();
                            }
                          });
                          if (timerStarted) {
                            loadNextMPGuessWord(wordLocale);
                          }
                        }),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: screenW / 2.2,
                      color: Colors.transparent,
                      child: Visibility(
                          visible: !timerStarted,
                          child: Center(
                              child: defaultScaledLandscapeButton(
                                  context,
                                  1.5,
                                  1,
                                  fontScale,
                                  opacity,
                                  'Start with Henyo Assist', () {
                            if (microphoneStatus!.isPermanentlyDenied) {
                              showGenericAlertDialog(
                                  context,
                                  globalMessages
                                      .getMicrophoneDeniedTitle(wordLocale),
                                  globalMessages
                                      .getMicrophonePermanentlyDeniedMessage(
                                          wordLocale),
                                  '',
                                  'OK',
                                  () {});
                            } else if (!microphoneStatus!.isGranted) {
                              Permission.microphone.status.then((status) {
                                if (!status.isGranted) {
                                  showGenericAlertDialog(
                                      context,
                                      globalMessages
                                          .getMicrophoneDeniedTitle(wordLocale),
                                      globalMessages.getMicrophoneDeniedMessage(
                                          wordLocale),
                                      '',
                                      'OK',
                                      () {});
                                }
                              });
                            }
                            if (globalSettings.promptForHenyoPartyVoiceEntry) {
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
                                  startGameWithVoiceEntry();
                                  // streamingRecognize(context, wordLocale);
                                });
                                if (useVoiceEntry == VoiceEntry.unsubscribed) {
                                  return;
                                }
                              }
                            } else {
                              useVoiceEntry = VoiceEntry.subscribed;
                              startGameWithVoiceEntry();
                            }
                          }))),
                    ),
                    const Spacer(),
                  ])),
              const SizedBox(height: 10),
            ]));
  }

  void startGameWithVoiceEntry() {
    debug('voice entry enabled');
    setState(() {
      timerStarted = !timerStarted;
      if (showOneTime) showOneTime = false;
      if (timerStarted) {
        guess = '';
        player.playStartGameSound();
        scaffoldColor = Colors.transparent;
        _resetTimer();
        _startTimer();
      } else {
        player.playBackspaceSound();
        _stopTimer();
        stopRecording();
      }
    });
    if (timerStarted) {
      loadNextGuessWord();
    }
    // if (timerStarted) return;
    if (!recognizing) {
      streamingRecognize(context, wordLocale);
    } else {
      stopRecording();
    }
  }

  bool recognizing = false;
  bool recognizeFinished = false;
  String text = '';
  // StreamSubscription<List<int>>? _audioStreamSubscription;
  // BehaviorSubject<List<int>>? _audioStream;
  AudioRecorder? recorder;
  StreamSubscription? _recordingDataSubscription;

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

    _recordingDataSubscription = responseStream.listen((data) {
      final currentText =
          data.results.map((e) => e.alternatives.first.transcript).join(' ');

      if (data.results.first.isFinal) {
        responseText += ' $currentText';
        debug(responseText);
        setState(() {
          scaffoldColor = Colors.transparent;
          text = responseText;
          recognizeFinished = true;
          guess = removeCluegiverResponse(currentText).toLowerCase();
          if (guess.trim().toLowerCase() == wordToGuess.toLowerCase()) {
            player.playRightAnswerSound();
            endOfRound();
            scaffoldColor = Colors.green.withOpacity(.4);
          } else if (wordsAssociated!
              .contains(WordSelection.sanitize(guess.toLowerCase()))) {
            pauseRecording();
            player.playYesSound(wordLocale);
            scaffoldColor = Colors.green.withOpacity(.4);
            _addToUserGuessMap('yes');
          } else if (wordsPossible!
              .contains(WordSelection.sanitize(guess.toLowerCase()))) {
            pauseRecording();
            player.playMaybeSound(wordLocale);
            scaffoldColor = Colors.orange.withOpacity(.4);
            _addToUserGuessMap('close');
          } else {
            player.playNoSound(wordLocale);
            pauseRecording();
            scaffoldColor = Colors.red.withOpacity(.4);
            _addToUserGuessMap('no');
          }
          debug('guess: $guess');
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
    await recorder!.stop();
    // await _audioStream?.close();
    await _recordingDataSubscription?.cancel();
    setState(() {
      recognizing = false;
    });
  }
}

class PartyModeGuesses {
  int id;
  int timestamp;
  String name;
  String word;
  String attempts;
  String extraData;

  PartyModeGuesses({
    this.id = 0,
    this.timestamp = 0,
    this.name = '',
    this.word = '',
    this.attempts = '',
    this.extraData = '',
  });

  bool isEmpty() => isEmpty();

  PartyModeGuesses.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        timestamp = json['timestamp'],
        word = json['word'],
        extraData = json['extraData'],
        attempts = json['attempts'];

  Map<String, dynamic> toJson() {
    return {
      '"name"': '"$name"',
      '"word"': '"$word"',
      '"extraData"': extraData,
      '"attempts"': attempts,
    };
  }
}
