import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';
import 'debug.dart';
import 'helper.dart';

class EmailEntryPage extends StatefulWidget {
  const EmailEntryPage({super.key});

  @override
  EmailEntry createState() => EmailEntry();
}

class EmailEntry extends State<EmailEntryPage> {
  BannerAd? _bannerAd;
  TextEditingController textController = TextEditingController();
  FocusNode inputNode = FocusNode();
  String additionalMessage = '';
  // late StreamSubscription<bool> keyboardSubscription;
  // var keyboardVisibilityController = KeyboardVisibilityController();

  @override
  void initState() {
    super.initState();
    currentShowOnceValue =
        setInfoStrings(ShowOnceValues.backupRestorePage, infoLocale);

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
      if (!showOnce.infoBackupRestoreShown) {
        showInfoDialog(context);
        showOnce.infoBackupRestoreShown = true;
        objectBox.setShowOnce(showOnce);
      }
    });
  }

  @override
  void dispose() {
    currentShowOnceValue =
        setInfoStrings(ShowOnceValues.settingsPage, infoLocale);
    player3.playBackspaceSound();
    _bannerAd?.dispose();
    inputNode.dispose();
    super.dispose();
  }

  ButtonStyle landingButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: appThemeColor.withOpacity(.5), //background color of button
    side: BorderSide(width: 1, color: borderColor), //border width and color
    elevation: 5, //elevation of button
    shape: RoundedRectangleBorder(
        //to set border radius to button
        borderRadius: BorderRadius.circular(10)),
    // padding: const EdgeInsets.all(10) //content padding inside button
  );

  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);
    // final bool widerScreen = screenW > 374.0;
    // const double fontScale = 0.65;
    final textScaler = MediaQuery.textScalerOf(context)
        .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.2);

    return lightBulbBackgroundWidget(
        context,
        'Backup or Restore game data',
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
              const SizedBox(height: 20),
              // if (false)
              //   SingleChildScrollView(
              //       keyboardDismissBehavior:
              //           ScrollViewKeyboardDismissBehavior.onDrag,
              //       child: Text( textScaler: getcustomTextScaler(context),
              //         globalMessages.getBackupRestoreMessage(wordLocale),
              //         style: textStyleDark(),
              //       )),
              // const SizedBox(
              //   height: 10,
              // ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                  child: MediaQuery(
                      data: MediaQuery.of(context)
                          .copyWith(textScaler: textScaler),
                      child: TextFormField(
                        autofocus: true,
                        focusNode: inputNode,
                        controller: textController,
                        keyboardType: TextInputType.emailAddress,
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
                          hintText:
                              'Enter your email address or restore code here',
                          hintStyle: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ))),
              Text(textScaler: customTextScaler(context), additionalMessage),
              const SizedBox(height: 20),
              Row(children: [
                const Spacer(),
                defaultSquareButton(
                  context,
                  scaler.getHeight(15),
                  scaler.getWidth(30),
                  // buttonHeight,
                  // screenW / buttonWidthDivisor,
                  'Save your email',
                  () {
                    if (textController.text.isEmpty ||
                        !EmailValidator.validate(textController.text)) {
                      setState(() {
                        additionalMessage =
                            'Email invalid! Please re-enter a valid email.';
                      });
                      return;
                    }
                    setSecureDataRecordEntry('email',
                        encryptWithServerPublicKey(textController.text));
                    createRecordBackup(textController.text).then((response) {
                      setState(() {
                        additionalMessage = response.body.trim();
                      });
                      debug(additionalMessage);
                    });
                  },
                ),
                // Container(
                //   width: screenW / 3,
                //   color: Colors.transparent,

                //   child: Center(
                //     child: ElevatedButton(
                //       style: squareButtonStyle(
                //           Size(screenW / buttonWidthDivisor, buttonHeight)),
                //       onPressed: () {
                //         if (textController.text.isEmpty ||
                //             !EmailValidator.validate(textController.text)) {
                //           setState(() {
                //             additionalMessage =
                //                 'Email invalid! Please re-enter a valid email.';
                //           });
                //           return;
                //         }
                //         setSecureDataRecordEntry('email',
                //             encryptWithServerPublicKey(textController.text));
                //         createRecordBackup(textController.text)
                //             .then((response) {
                //           setState(() {
                //             additionalMessage = response.body.trim();
                //           });
                //           debug(additionalMessage);
                //         });
                //       },
                //       child: Text(
                //           textScaler: customTextScaler(context),
                //           'Save your email',
                //           style: textStyleCustomFontSizeFromContext(
                //               context, fontScale)),
                //     ),
                //   ),
                // ),
                const Spacer(),
                defaultSquareButton(
                  context,
                  scaler.getHeight(15),
                  scaler.getWidth(30),
                  'Request code via email',
                  () {
                    if (textController.text.isEmpty ||
                        !EmailValidator.validate(textController.text)) {
                      setState(() {
                        additionalMessage =
                            'Email invalid! Please re-enter a valid email.';
                      });
                      return;
                    }
                    requestCodeBackupByEmail(
                            encryptWithServerPublicKey(textController.text))
                        .then((response) {
                      setState(() {
                        additionalMessage = response.body.trim();
                      });
                      debug(additionalMessage);
                    });
                  },
                ),
                // Container(
                //   width: screenW / 3,
                //   color: Colors.transparent,
                //   child: Center(
                //     child: ElevatedButton(
                //       style: squareButtonStyle(
                //           Size(screenW / buttonWidthDivisor, buttonHeight)),
                //       onPressed: () {
                //         if (textController.text.isEmpty ||
                //             !EmailValidator.validate(textController.text)) {
                //           setState(() {
                //             additionalMessage =
                //                 'Email invalid! Please re-enter a valid email.';
                //           });
                //           return;
                //         }
                //         requestCodeBackupByEmail(
                //                 encryptWithServerPublicKey(textController.text))
                //             .then((response) {
                //           setState(() {
                //             additionalMessage = response.body.trim();
                //           });
                //           debug(additionalMessage);
                //         });
                //       },
                //       child: Text(
                //           textScaler: customTextScaler(context),
                //           'Request code via email',
                //           style: textStyleCustomFontSizeFromContext(
                //               context, fontScale)),
                //     ),
                //   ),
                // ),
                const Spacer(),
                defaultSquareButton(
                  context,
                  scaler.getHeight(15),
                  scaler.getWidth(30),
                  'Restore using code',
                  () {
                    if (textController.text.isEmpty ||
                        EmailValidator.validate(textController.text)) {
                      setState(() {
                        additionalMessage =
                            'Invalid restore code. Double check that you have entered the correct code.';
                      });
                      return;
                    }
                    restoreUserRecordWithCode(textController.text).then(
                      (value) {
                        setState(() {
                          if (value.statusCode == 200) {
                            additionalMessage =
                                'Successfully restored from backup';
                          } else {
                            additionalMessage = value.body.trim();
                          }
                          debug(additionalMessage);
                        });
                      },
                    );
                  },
                ),
                // Container(
                //   width: screenW / 3,
                //   color: Colors.transparent,
                //   child: Center(
                //     child: ElevatedButton(
                //       style: squareButtonStyle(
                //           Size(screenW / buttonWidthDivisor, buttonHeight)),
                //       onPressed: () {
                //         if (textController.text.isEmpty ||
                //             EmailValidator.validate(textController.text)) {
                //           setState(() {
                //             additionalMessage =
                //                 'Invalid restore code. Double check that you have entered the correct code.';
                //           });
                //           return;
                //         }
                //         restoreUserRecordWithCode(textController.text).then(
                //           (value) {
                //             setState(() {
                //               if (value.statusCode == 200) {
                //                 additionalMessage =
                //                     'Successfully restored from backup';
                //               } else {
                //                 additionalMessage = value.body.trim();
                //               }
                //               debug(additionalMessage);
                //             });
                //           },
                //         );
                //       },
                //       child: Text(
                //           textScaler: customTextScaler(context),
                //           'Restore using code',
                //           style: textStyleCustomFontSizeFromContext(
                //               context, fontScale)),
                //     ),
                //   ),
                // ),
                const Spacer(),
              ]),
              const Spacer(),
              Container(
                color: Colors.transparent,
                child: Center(
                  child: defaultBackButton(context, backButtonFontScale, .5),

                  // ElevatedButton(
                  //   style: landingButtonStyle,
                  //   onPressed: () {
                  //     // Navigate back to first route when tapped.
                  //     Navigator.pop(context);
                  //   },
                  //   child: Text( textScaler: getcustomTextScaler(context),'Back',
                  //       style: textStyleCustomFontSizeFromContext(context, .9)),
                  // ),
                ),
              ),
              const SizedBox(height: 10),
            ]));
  }
}
