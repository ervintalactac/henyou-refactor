import 'package:HenyoU/backuprestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';
import 'debug.dart';
import 'entities.dart';
import 'helper.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  Settings createState() => Settings();
}

class Settings extends State<SettingsPage> with SingleTickerProviderStateMixin {
  BannerAd? _bannerAd;
  TextEditingController textController = TextEditingController();
  bool editUsername = false;
  String editUsernameLabel = 'Change username';
  late List<Record> users;
  String hintText = alias.isEmpty
      ? username
      : alias != user.alias
          ? alias
          : user.alias;

  @override
  void initState() {
    currentShowOnceValue =
        setInfoStrings(ShowOnceValues.settingsPage, infoLocale);
    initGoogleMobileAds();
    alias = user.alias;
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!showOnce.infoSettingsPageShown) {
        showInfoDialog(context);
        showOnce.infoSettingsPageShown = true;
        objectBox.setShowOnce(showOnce);
      }
    });

    textController.text = alias;

    super.initState();
  }

  @override
  void dispose() {
    player3.playBackspaceSound();
    resetInfoData();
    super.dispose();
    textController.dispose();
    _bannerAd?.dispose();
  }

  bool userExists(String user) {
    return users.map((usernames) => usernames.alias).toList().contains(user) ||
        users.map((usernames) => usernames.name).toList().contains(user);
  }

  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);
    // final bool largerScreen = MediaQuery.of(context).size.height >= 600.0;
    // double spacingWidth = largerScreen ? 160 : 140;
    double screenH = MediaQuery.of(context).size.height;
    double screenW = MediaQuery.of(context).size.width;
    // ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    //   textStyle: textStyle,
    //   backgroundColor: appThemeColor.withOpacity(.5),
    //   side: BorderSide(width: 1, color: borderColor), //border width and color
    //   elevation: 9,
    // );
    final bool widerScreen = screenW > 375.0;
    String wordJsonLastDate =
        DateTime.fromMillisecondsSinceEpoch(objectBox.getJsonWordsDate() * 1000)
            .toString();
    if (!widerScreen) {
      textStyle18 = TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: buttonTextColor);
      // textStyleDark() = TextStyle(
      //     fontSize: 12, fontWeight: FontWeight.bold, color: darkTextColor);
      textStyle = TextStyle(
          fontSize: 10, fontWeight: FontWeight.bold, color: buttonTextColor);
    }
    const double fontScale = 1.1;
    FocusNode inputNode = FocusNode();

    return lightBulbBackgroundWidget(
      context,
      'Game Settings',
      // Stack(
      //   children: [
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
        const SizedBox(height: 10),
        if (kDebugMode)
          Text(textScaler: customTextScaler(context), '$screenH x $screenW'),
        // if (kDebugMode) futureWidget(),
        //if (kDebugMode) Text('isOffline=$isOffline'),
        //if (kDebugMode) Text('gameStarted=$gameStarted'),
        //if (kDebugMode) Text('timerRunning=$timerRunning'),
        const SizedBox(width: 10),
        //Row(children: [
        editUsername
            ? Padding(
                padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                child: MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: const TextScaler.linear(1.0)),
                    child: TextFormField(
                      // autofocus: true,
                      focusNode: inputNode,
                      controller: textController,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.done,
                      style: TextStyle(
                        fontFamily: fontName,
                        fontWeight: FontWeight.bold,
                        color: inputTextColor,
                        fontSize: calculateFixedFontSize(context),
                      ),
                      decoration: InputDecoration(
                        fillColor: mainBackgroundColor.withOpacity(.1),
                        contentPadding:
                            const EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide:
                              BorderSide(width: 2.0, color: appThemeColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(
                              width: 2.0, color: mainBackgroundColor),
                        ),
                        hintText: hintText,
                        hintStyle: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                    )))
            : MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.0)),
                child: TextField(
                  style: textStyleDark(context),
                  enabled: editUsername,
                  readOnly: editUsername,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: editUsername
                        ? const OutlineInputBorder()
                        : InputBorder.none,
                    hintStyle: TextStyle(fontSize: scaler.getTextSize(12)),
                    hintText: hintText,
                  ),
                )),
        const SizedBox(height: 5),
        defaultButton(context, fontScale, .5, editUsernameLabel, () async {
          player3.playOpenPage();
          editUsername = !editUsername;
          if (editUsername) {
            setState(() {
              editUsernameLabel = 'Save username';
              textController.text = '';
              hintText = 'Enter a custom username';
            });
            fetchRecords().then((recs) => users = recs);
          } else {
            if (textController.text.isEmpty) {
              setState(() {
                editUsername = !editUsername;
                hintText = "Username empty. Please enter a username";
                textController.text = '';
              });
              return;
            }
            if (username != textController.text &&
                userExists(textController.text)) {
              setState(() {
                editUsername = !editUsername;
                hintText =
                    "Username already exists. Please re-enter a username";
                textController.text = '';
              });
              return;
            }
            String response = await vertexAI(
                globalSettings.promptValidateUsername, textController.text);
            if (response.trim().toLowerCase().startsWith('true')) {
              setState(() {
                editUsername = !editUsername;
                hintText =
                    "Please re-enter a username that doesn't contain profanity";
                textController.text = '';
              });
            } else {
              setState(() {
                hintText = alias = textController.text;
                editUsernameLabel = 'Change username';
              });
              user.setAlias(alias);
              objectBox.setUser(user);
              updateRecordFromUser(user);
              setUserWeeklyRecord(user);
            }
          }
        }),
        const Spacer(),
        Row(children: [
          const Spacer(),
          defaultButton(context, fontScale, .5, "What's New?", () {
            player3.playOpenPage();
            showDialog(
              context: context,
              barrierColor: Colors.black.withOpacity(.5),
              builder: (BuildContext context) => Center(
                child: AlertDialog(
                  backgroundColor: Colors.white.withOpacity(.9),
                  title: Text(
                    whatsNewTitle,
                    style: textStyleAutoScaledByPercent(
                        context, 14, darkTextColor),
                    textScaler: customTextScaler(context),
                  ),
                  // insetPadding: const EdgeInsets.all(20),
                  // contentPadding: const EdgeInsets.all(0),
                  content: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Text(whatsNewMessage,
                          style: textStyleAutoScaledByPercent(
                              context, 12, darkTextColor),
                          textScaler: customTextScaler(context))),
                  actions: <Widget>[
                    TextButton(
                      child: Text("Continue",
                          style: textStyleAutoScaledByPercent(
                              context, 13, darkTextColor),
                          textScaler: customTextScaler(context)),
                      onPressed: () {
                        player3.playBackspaceSound();
                        Navigator.of(context).pop();
                      }, //closes popup
                    ),
                  ],
                ),
              ),
            );
          }),
          const Spacer(),
          defaultButton(context, fontScale, .5, "Backup/Restore", () {
            player3.playOpenPage();
            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EmailEntryPage()))
                .then((value) => setState(() {
                      setInfoStrings(ShowOnceValues.settingsPage, wordLocale);
                    }));
          }),
          const Spacer(),
        ]),
        const Spacer(),
        Row(children: [
          const Spacer(),
          Text(
              textScaler: customTextScaler(context),
              'Color Theme: ',
              style: textStyleAutoScaledByPercent(context, 12, darkTextColor)),
          MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: defaultTextScaler(context)),
              child: colorThemeSelectorDropDown(context, setState, setState)),
          const Spacer(),
        ]),
        const Spacer(),
        Row(
          children: [
            const Spacer(),
            Text(
                textScaler: customTextScaler(context),
                'Auto start Voice Entry on game start: ',
                style: textStyleDark(context)),
            const SizedBox(
              width: 5,
            ),
            SizedBox(
                width: scaler.getWidth(10),
                child: FittedBox(
                    fit: BoxFit.fill,
                    child: Switch(
                      activeColor: appThemeColor,
                      value: userSettings.getAutoStartVoiceEntry(),
                      onChanged: (bool value) {
                        debug(
                            'auto start voice entry toggled. new value $value');
                        setState(() {
                          userSettings.setAutoStartVoiceEntry(value);
                        });
                        objectBox.storeUserSettings(userSettings);
                      },
                    ))),
            const Spacer(),
          ],
        ),
        // SizedBox(
        //   height: 40, //height of button
        //   width: spacingWidth, //width of button
        //   child: ElevatedButton(
        //     style: landingButtonStyle,
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //             builder: (context) => AdDialog(
        //                   showAd: () {
        //                     showAboutDialog(context: context);
        //                   },
        //                 )),
        //       ).then((value) => setState(() {}));
        //     },
        //     child: Row(children: [
        //       const Spacer(),
        //       Text( textScaler: customTextScaler(context),'Ad Dialog',
        //           style: widerScreen ? textStyle : textStyle18),
        //       const Spacer(),
        //     ]),
        //   ),
        // ),
        const Spacer(),
        Text(
            textScaler: customTextScaler(context),
            'Privacy Policy:',
            style: textStyleDark(context)),
        fitText(context, 'https://www.henyogames.com/privacypolicy.htm',
            textStyleDark(context)),
        const SizedBox(width: 10),
        if (kDebugMode)
          defaultButton(context, fontScale, .8, 'Test Button', () async {
            //   showGenericAlertDialog(
            //       context,
            //       'Use a hint?',
            //       globalMessages
            //           .getUseHintMessage(wordLocale)
            //           .replaceFirst('\$hintFee', '${globalSettings.hintFee}'),
            //       'No Thanks',
            //       "Yes Please",
            //       () {});

            // try {
            //   var ticker = controller.forward();
            //   ticker.whenComplete(() {
            //     controller.reset();
            //   });
            // } catch (e) {
            //   debug(e.toString());
            // }

            // getDeviceID().then((id) {
            //   debug(id);
            // });

            // showAlertDialog(context);
            // createUserRecord();
            // updateUserRecord(record!);
            // testFetch(username);
            // debug(fetchWhatsNew());
            // debug(username);

            // String otp = getOTP(username);
            // // debug(otp);
            // var dec = encryptWithPublicKey('$otp:$username');
            // debug(dec);
            // decryptWithPrivateKey(dec).then((onValue) {
            //   debug(onValue);
            // });

            // updateUserRecord(record!);
            //debug(generateNewUsername());
            // player.playTimerRunningOutSound();
            // updateRoomClueGiver('WhiteBat', '');
            // updateRoomStatus('WhiteBat', 'starting');
            // postMultiPlayerGuess(
            //     '{"guesser": "GoldZebraBrakus31513", "cluegiver": "GoldZebraBrakus31513", "word": "bear", "extradata": "{\\"hintUsed\\":false, \\"tokensCount\\":1354, \\"difficulty setting\\": \\"h\\", \\"colorTheme\\": \\"Gray\\"}", "attempts": "{\\"108546\\": \\"tao:hindi\\", \\"99093\\": \\"hayop:oo\\", \\"91296\\": \\"oso:oo\\", \\"87294\\": \\"bear:astig naman!\\"}"}');
            // fetchMultiPlayerWordsList()
            //     .then((value) => debug(value!.multiplayerWordsList));

            // debug('${DateTime.now().millisecondsSinceEpoch % 604800000}');
            // debug(
            //     '${DateTime.fromMillisecondsSinceEpoch(record!.modified * 1000)}');
            // debug('${DateTime.now().weekday}');
            // debug('${(record!.modified - 345600) / 604800}');
            // debug('${(1716768000 - 345600) / 604800}'); //1716768001
            // debug('${(1716768000 - 345600) % 604800}'); //171676800
            // debug(
            //     '${(DateTime.now().millisecondsSinceEpoch - 345600000) / 604800000}');

            // inCurrentWeek(record!.modified);
            // inCurrentWeek(1715558401);
            // inCurrentWeek(DateTime.now().millisecondsSinceEpoch);

            // debug('${record!.modified}');
            // debug('${DateTime.now().millisecondsSinceEpoch ~/ 1000}');

            // createUserWeeklyRecord(record!).then((onValue) {
            //   int code = onValue.statusCode;
            //   debug('$code');
            //   debug(onValue.body);
            // });

            // setUserWeeklyRecord(record!).then((onValue) {
            //   int code = onValue.statusCode;
            //   debug('$code');
            //   debug(onValue.body);
            // });

            // fetchUserRecord().then((r) {
            //   debug(r!.name);
            //   debug(r.toJson().toString());
            //   debug(record!.name);
            // });

            // wordsIndex = 0;
            // var words =
            //     jsonDecode(await rootBundle.loadString('json/words_temp.json'));
            // var map1 = getJsonWords(words);
            // map1.forEach((key, value) {
            //   debug('$key:${value.guessWord}');
            // });
            // words = jsonDecode(
            //     await rootBundle.loadString('json/henyowords_temp.json'));
            // var map2 = getJsonWords(words);
            // var temp = {...map1, ...map2};
            // // temp.forEach((key, value) {
            // //   debug('$key:${value.guessWord}');
            // // });
            // debug('new map size: ${temp.length}');
            // wordsIndex = 0;
            // var newmap = removePreviouslyUsedWords(temp, gameMode);
            // newmap.forEach((key, value) {
            //   debug('$key:${value.guessWord}');
            // });

            // var categories = ['animal', 'food', 'person', 'place', 'thing'];
            // // var difficulty = ['e', 'm', 'h'];
            // // var categories = ['animal'];
            // var difficulty = ['e'];
            // wordsIndex = 0;
            // var words =
            //     jsonDecode(await rootBundle.loadString('json/words_temp.json'));
            // var map1 = getJsonWords(categories, difficulty, words);
            // map1.forEach((key, value) {
            //   if (value.getAlternateWords().isNotEmpty)
            //     debug('$key:${value.getAlternateWords()}');
            // });
            // words = jsonDecode(
            //     await rootBundle.loadString('json/henyowords_temp.json'));
            // var map2 = getJsonWords(categories, difficulty, words);
            // var temp = {...map1, ...map2};
            // temp.forEach((key, value) {
            //   if (value.getAlternateWords().isNotEmpty)
            //     debug('$key:${value.getAlternateWords()}');
            //   // debug('$key:${value.guessWord}');
            // });
            // wordsIndex = 0;

            // loadNextGuessWord();

            // var obj = wordsList.selectRandomWordObject();
            // debug(obj.guessWord);

            // fetchGimme5Round1Words(dateonly: true);
            // vertexAI("guimaras", "tao", "place");

            // getAuthHeader();
            // debug(getCustomUniqueId());
            // for (WordSelection w in words.selectGimme5RandomWords(
            //     wordLocale, wordDifficulty, 'food')) {
            //   debug(w.guessWord.toTitleCase());
            // debug(w.category);
            // }

            // fetchRecords()
            //     .then((value) => debug(value.asMap().toString()));

            // getUserWeeklyRecord(getCurrentWeekNumber()).then((value) {
            //   debug(value.toJson().toString());
            //   isUserAndWeekNumberExists().then((response) {
            //     debug(response.toString());
            //     if (response.statusCode == 200) debug(response.body);
            //   });
            //   debug(value.toJson().toString());
            // });

            // getWeeklyRecords(weekNumber: getCurrentWeekNumber());
            fetchLatestJsonGimme5Round1();

            // getWeeklyWinnersPreviousWeek().then((winners) {
            //   debug(winners.toJson().toString());
            // });

            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //       builder: (context) => Recorder(
            //             onStop: (String path) {
            //               debug(path);
            //             },
            //           )),
            // );
            // assemblyuitest();
            // SpeechToTextGoogleDialog.getInstance().showGoogleDialog(
            //     locale: 'fil-PH',
            //     onTextReceived: (data) {
            //       debug(data);
            //     });

            // Init a new Stream
            // Stream<List<int>> stream = MicStream.microphone(
            //     sampleRate: 16000,
            //     audioFormat: AudioFormat.ENCODING_PCM_16BIT,
            //     audioSource: AudioSource.MIC);
            // // Start listening to the stream
            // StreamSubscription<List<int>> listener =
            //     stream.listen((samples) => print('$samples'));
            // Transform the stream and print each sample individually
            // stream.transform(MicStream.toSampleStream).listen(print);

            // testFetch(username);
            // fetchMultiPlayerWordsList().then((value) {
            //   MultiPlayerWords? multiplayerWords = value;
            //   objectBox.setMPWordsList(multiplayerWords!);
            // });

            // getWeeklyWinnersPreviousWeek().then((winners) {
            //   String message = '';
            //   if (winners.toJson().toString().contains(username)) {
            //     if (winners.firstPlace.contains(username) &&
            //         winners.firstPlace.contains('unclaimed')) {
            //       var data = jsonDecode(winners.firstPlace);
            //       var reward = int.parse((data[username])['amount']);
            //       credits += reward;
            //       message =
            //           'Congrats on winning 1st place with last week\'s tournament! You\'ve earned $reward token reward!!';
            //       winners.firstPlace = winners.firstPlace
            //           .replaceAll('unclaimed', 'claimed');
            //       winners.secondPlace = '';
            //       winners.thirdPlace = '';
            //     } else if (winners.secondPlace.contains(username) &&
            //         winners.secondPlace.contains('unclaimed')) {
            //       var data = jsonDecode(winners.secondPlace);
            //       var reward = int.parse((data[username])['amount']);
            //       credits += reward;
            //       winners.secondPlace = winners.secondPlace
            //           .replaceAll('unclaimed', 'claimed');
            //       winners.firstPlace = '';
            //       winners.thirdPlace = '';
            //       message =
            //           'You won 2nd place with last week\'s tournament! You\'ve earned $reward token reward!!';
            //     } else if (winners.thirdPlace.contains(username) &&
            //         winners.thirdPlace.contains('unclaimed')) {
            //       var data = jsonDecode(winners.thirdPlace);
            //       var reward = int.parse((data[username])['amount']);
            //       credits += reward;
            //       winners.thirdPlace = winners.thirdPlace
            //           .replaceAll('unclaimed', 'been_claimed');
            //       winners.firstPlace = '';
            //       winners.secondPlace = '';
            //       message =
            //           'You\ve placed 3rd with last week\'s tournament! You\'ve earned $reward token reward!!';
            //     }
            //     debug(message);
            //     updateWeeklyWinnersPreviousWeek(winners)
            //         .then((response) {
            //       var body = response.body
            //           .trim()
            //           .replaceAll('\t', '')
            //           .replaceAll(' ', '')
            //           .replaceAll('\n', '');
            //       debug(body);
            //     });
            //   }
            // });
          }),
        const Spacer(),
        Text(
            textScaler: customTextScaler(context),
            'Locale selected: $wordLocale',
            style: textStyleDark(context)),
        Text(
            textScaler: customTextScaler(context),
            // 'Words list last updated:\n',
            'Words list last updated:\n$wordJsonLastDate',
            style: textStyleDark(context)),
        Text(
            textScaler: customTextScaler(context),
            'Henyo U?! ver: $version+$code',
            style: textStyleDark(context)),
        const Spacer(),
        defaultBackButton(context, backButtonFontScale, .5),
        const SizedBox(height: 10),
      ]),
      // Lottie.asset('assets/confetti.json',
      //     controller: controller,
      //     width: MediaQuery.sizeOf(context).width,
      //     height: MediaQuery.sizeOf(context).width,
      //     fit: BoxFit.cover,
      //     repeat: false),
      // Lottie.asset('assets/coin.json', controller: _controller,
      //     onLoaded: (composition) {
      //   _controller
      //     ..duration = composition.duration
      //     ..forward();
      // }),
      //   ],
      // )
    );
  }
}
