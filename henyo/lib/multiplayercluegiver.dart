import 'dart:async';
import 'dart:convert';

import 'package:HenyoU/multiplayerdata.dart';
import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'ad_helper.dart';
import 'debug.dart';
import 'helper.dart';
import 'soundplayer.dart';

class MultiPlayerClueGiver extends StatefulWidget {
  const MultiPlayerClueGiver({super.key});

  @override
  MultiPlayerClueGiverPage createState() => MultiPlayerClueGiverPage();
}

class MultiPlayerClueGiverPage extends State<MultiPlayerClueGiver>
    with SingleTickerProviderStateMixin {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  // List<AblyMessage> messages = [];
  String guessWord = '';
  String playersGuess = multiplayerLocale == 'ph'
      ? "Ikaw ang tagabigay ng sagot"
      : "You're playing as the clue giver";
  // bool gameStarted = false;
  SoundPlayer player = SoundPlayer();
  List<AblyMessage> _messages = [];
  int delay = 0;
  late final AnimationController _controller;
  bool showOnlyOnce = true;

  @override
  void initState() {
    currentShowOnceValue =
        setInfoStrings(ShowOnceValues.multiPlayerClueGiverPage, infoLocale);

    timerColor = darkTextColor;

    subscribeToRoom(mpInfo!.data.room);

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
    _loadInterstitialAd();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!showOnce.infoMultiPlayerClueGiverShown) {
        showInfoDialog(context);
        showOnce.infoMultiPlayerClueGiverShown = true;
        objectBox.setShowOnce(showOnce);
      }
    });
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    player3.playBackspaceSound();
    _bannerAd?.dispose();
    mpInfo!.data.setTxnStatus(RoomState.cluegiverLeft.name);
    leaveRoom(mpInfo!.data).then((value) => roomJoined = false);
    getRoom(mpInfo!.data.room).then((value) {
      // debug('CLUEGIVERPAGE DISPOSE: ' + mpInfo!.data.toJson().toString());
      value.status = convertStringToRoomState(mpInfo!.data.txnStatus);
      sendUserNegotiation(
        MultiPlayerTransaction.copyFromMultiPlayerRoomData(value),
      );
      // Navigator.of(context).pop();
    });
    sendUserResponse(jsonEncode(mpInfo!.data.toJson()), mpInfo!.data.room, 0);
    _controller.dispose();
  }

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

  Color colorBasedOnAnswer(String answer) {
    if (answer.toLowerCase() == 'oo' || answer.toLowerCase() == 'yes') {
      return Colors.green.shade100.withOpacity(.3);
    } else if (answer.toLowerCase() == 'pwede' ||
        answer.toLowerCase() == 'close') {
      return Colors.orange.shade100.withOpacity(.3);
    }
    return Colors.red.shade100.withOpacity(.3);
  }

  _buildMessage(AblyMessage message, bool isMe) {
    final Container msg = Container(
      margin: isMe
          ? const EdgeInsets.only(
              top: 2.0,
              bottom: 2.0,
              left: 80.0,
            )
          : const EdgeInsets.only(
              top: 2.0,
              bottom: 2.0,
            ),
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 5.0),
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: BoxDecoration(
        color: isMe
            ? colorBasedOnAnswer(
                message.text!) //buttonTextColor.withOpacity(.3)
            : Colors.blue.shade100.withOpacity(.3),
        borderRadius: isMe
            ? const BorderRadius.only(
                topLeft: Radius.circular(5.0),
                bottomLeft: Radius.circular(5.0),
              )
            : const BorderRadius.only(
                topRight: Radius.circular(5.0),
                bottomRight: Radius.circular(5.0),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Text( textScaler: customTextScaler(context),
          //   message.time!,
          //   style: const TextStyle(
          //     color: Colors.blueGrey,
          //     fontSize: 16.0,
          //     fontWeight: FontWeight.w600,
          //   ),
          // ),
          // const SizedBox(height: 8.0),
          Text(
            textScaler: customTextScaler(context),
            message.text!,
            style: TextStyle(
              fontFamily: fontName,
              color: Colors.blueGrey,
              fontSize: calculateFixedFontSize(context) * .75,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    if (isMe) {
      return msg;
    }
    return Row(
      children: <Widget>[
        msg,
      ],
    );
  }

  bool alertShowing = false;
  bool displayOnce = false;
  void subscribeToRoom(String roomName) {
    // ignore: prefer_typing_uninitialized_variables
    var newMsgFromAbly;
    int tries = 0;
    var messageStream = chatChannel!.subscribe(name: roomName);
    messageStream.listen((ably.Message message) {
      AblyMessage newChatMsg;
      // AblyUser cluegiver = AblyUser(id: 1, name: username);
      newMsgFromAbly = message.data;
      debug("New message arrived (cluegiver page)${message.data}");
      String customMsg = '';
      var msgTime = DateTime.now().toString();
      if (message.clientId == getRoomData().cluegiver) {
        newChatMsg = AblyMessage(
          sender: cluegiver,
          time: msgTime,
          text: newMsgFromAbly["text"],
          unread: false,
        );
      }
      // } else {
      String sender = newMsgFromAbly["sender"].toString();
      AblyUser user;
      if (sender == username) {
        user = AblyUser(id: 1, name: sender);
      } else {
        user = AblyUser(id: 0, name: sender);
      }

      String msg = newMsgFromAbly["text"].toString();
      if (msg.contains('guesserLeft') && !alertShowing) {
        alertShowing = true;
        showGenericAlertDialog(context, 'Game room: $roomName',
            'Guesser left the room.', '', 'Go Back', () {
          Navigator.of(context).pop();
        });
        return;
      }
      if (msg.contains('timestamp')) {
        // ignore incoming MultiPlayerData msg
        return;
      }
      if (msg.startsWith('guesserResponse:guessword=')) {
        showOnlyOnce = false;
        _messages = [];
        guessWord = msg.split('=')[1];
        customMsg = 'Guess word: $guessWord';
        timerColor = darkTextColor;
        playersGuess = '';
        tries = 0;
        // } else if (msg.startsWith('guesserResponse:locale=')) {
        //   locale = msg.split('=')[1];
      } else if (msg.startsWith('guesserResponse:duration=')) {
        _resetTimer();
        int duration = int.parse(msg.split('=')[1]);
        debug('duration from guesser: $duration');
        setState(() => myDuration = Duration(minutes: duration));
        _startTimer();
      } else if (msg.startsWith('guesserResponse:score=') &&
          tries > globalSettings.maxGuessTriesForAward) {
        int score = int.parse(msg.split('=')[1]);
        totalScore += score;
        timerColor = darkTextColor;
        customMsg = 'Score earned: $score';
      } else if (msg.startsWith('guesserResponse:tokenReward=')) {
        _stopTimer();
        player.playRightAnswerSound();
        if (tries > globalSettings.maxGuessTriesForAward) {
          int reward = int.parse(msg.split('=')[1]);
          customMsg = 'Tokens earned: $reward';
          setUserCredits(reward);
          streak++;
          var ticker = _controller.forward();
          ticker.whenComplete(() {
            _controller.reset();
          });
        } else {
          try {
            var ticker = _controller.forward();
            ticker.whenComplete(() {
              _controller.reset();
              debug('showing interstitial ad');
              _interstitialAd!.show();
            });
          } catch (e) {
            debug(e.toString());
          }
          return;
        }
      } else if (msg.startsWith('guesserResponse:showAd')) {
        _stopTimer();
        try {
          var ticker = _controller.forward();
          ticker.whenComplete(() {
            _controller.reset();
            debug('showing interstitial ad');
            _interstitialAd!.show();
          });
        } catch (e) {
          debug(e.toString());
        }
      } else {
        // if (msg.contains('correctly guessed')) {
        //   if (displayOnce) {
        //     msg = '';
        //   } else {
        //     displayOnce = true;
        //   }
        // }
        if (msg.contains('=')) {
          tries++;
          playersGuess = msg.split('=')[1];
          player.playIncomingMessage();
        } else if (msg.contains('cluegiverAnswer:')) {
          customMsg = msg.split(':')[1];
        } else {
          playersGuess = msg;
        }
      }
      // newChatMsg = AblyMessage(
      //   sender: user,
      //   time: msgTime,
      //   text: newMsgFromAbly["text"],
      //   unread: false,
      // );

      if (mounted) {
        setState(() {
          // if (!playersGuess.contains('=')) {
          String text = customMsg.isNotEmpty ? customMsg : playersGuess;
          newChatMsg = AblyMessage(
              sender: user, time: msgTime, text: text, unread: false);
          _messages.insert(0, newChatMsg);
          // }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n, int l) => n.toString().padLeft(l, '0');
    final minutes = strDigits(myDuration.inMinutes.remainder(60), 2);
    final seconds = strDigits(myDuration.inSeconds.remainder(60), 2);
    final milliseconds =
        strDigits(myDuration.inMilliseconds.remainder(1000), 3);
    String locale = multiplayerLocale;
    String answerYes = locale == 'ph' ? 'OO' : 'Yes';
    String answerClose = locale == 'ph' ? 'Pwede' : 'Close';
    String answerNo = locale == 'ph' ? 'Hindi' : 'No';
    // final bool widerScreen = screenW > 374.0;
    const double fontScale = .8;
    const double opacity = .5;
    // final double buttonWidth = screenW > 375 ? 1 : .95;
    // roomState.setRoomActive();
    return PopScope(
        canPop: !gameStarted,
        child: lightBulbBackgroundWidget(
            context,
            'Room: ${mpInfo!.data.room}',
            Stack(children: [
              Lottie.asset('assets/confetti.json',
                  controller: _controller,
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height,
                  fit: BoxFit.cover,
                  repeat: false),
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
                    Row(
                      children: [
                        const SizedBox(width: 5),
                        Text('Timer: $minutes:$seconds.$milliseconds',
                            style: textStyleAutoScaledByPercent(
                                context, 12, timerColor),
                            textScaler: customTextScaler(context)),
                        const Spacer(),
                        // Text(
                        //   'Room: ${mpInfo!.data.room}',
                        //   style: textStyleAutoScaledByPercent(
                        //       context, 12, darkTextColor),
                        //   textScaler: customTextScaler(context),
                        // ),
                        // const SizedBox(width: 5),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Visibility(
                        visible: !showOnlyOnce,
                        child: Text(
                          'Guess word is:', //${guessWord.toLowerCase()}',
                          style: textStyleAutoScaledByPercent(
                              context, 14, darkTextColor),
                          textScaler: customTextScaler(context),
                        )),
                    const SizedBox(width: 5),
                    Text(
                      guessWord.toUpperCase(),
                      style: textStyleAutoScaledByPercent(
                          context, 14, darkTextColor),
                      textScaler: customTextScaler(context),
                    ),
                    const SizedBox(height: 10),
                    Visibility(
                        visible: !showOnlyOnce,
                        child: Text(
                          'Player\'s current guess:',
                          style: textStyleAutoScaledByPercent(
                              context, 13, darkTextColor),
                          textScaler: customTextScaler(context),
                        )),
                    Text(
                      playersGuess,
                      style: textStyleAutoScaledByPercent(
                          context, 13, darkTextColor),
                      textScaler: customTextScaler(context),
                    ),
                    const SizedBox(height: 10),
                    // Stack(children: [
                    Expanded(
                      child: ListView.builder(
                        reverse: true,
                        // padding: const EdgeInsets.only(top: 15.0),
                        itemCount: _messages.length,
                        itemBuilder: (BuildContext context, int index) {
                          final AblyMessage message = _messages[index];
                          final bool isMe = message.sender!.id != guesser.id;
                          // if (message.text!.contains(':')) {
                          //   return null;
                          // }
                          return _buildMessage(message, isMe);
                        },
                      ),
                    ),
                    // ]),
                    // const Spacer(),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      const Spacer(),
                      Container(
                        color: Colors.transparent,
                        child: Center(
                          child: defaultButton(
                              context, fontScale, opacity, answerYes, () {
                            sendUserResponse('cluegiverAnswer:$answerYes',
                                mpInfo!.data.room, delay);
                          }),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        color: Colors.transparent,
                        child: Center(
                          child: defaultButton(
                              context, fontScale, opacity, answerClose, () {
                            sendUserResponse('cluegiverAnswer:$answerClose',
                                mpInfo!.data.room, delay);
                          }),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        color: Colors.transparent,
                        child: Center(
                          child: defaultButton(
                              context, fontScale, opacity, answerNo, () {
                            sendUserResponse('cluegiverAnswer:$answerNo',
                                mpInfo!.data.room, delay);
                          }),
                        ),
                      ),
                      const Spacer(),
                    ]),
                    const SizedBox(
                      height: 10,
                    ),
                  ]),
            ])));
  }

  void _startTimer() {
    countdownTimer = Timer.periodic(
        const Duration(milliseconds: 69), (_) => _setCountDown());
    timerRunning = true;
    gameStarted = true;
    timerColor = darkTextColor;
  }

  void _stopTimer() {
    setState(() => countdownTimer!.cancel());
    gameStarted = false;
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
        player.playTimerRanOutSound();
        myDuration = const Duration(milliseconds: 0);
        resultColor = constResultColor;
        totalStreak = user.resetTotalStreak();
      } else {
        if (seconds <= 10000) {
          if (seconds % 1000 > 930) {
            player.playTimerRunningOutSound();
            // guessText = shuffleWord(wordToGuess!).toLowerCase();
          }
          if (seconds % 1000 > 0 && seconds % 1000 < 400) {
            timerColor = darkTextColor;
          } else {
            timerColor = Colors.red;
          }
        }
        myDuration = Duration(milliseconds: seconds);
      }
    });
  }
}
