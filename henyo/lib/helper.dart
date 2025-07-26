import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'package:HenyoU/main.dart';
import 'package:HenyoU/multiplayerdata.dart';
import 'package:HenyoU/soundplayer.dart';
import 'package:HenyoU/toggle.dart';
import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:animate_gradient/animate_gradient.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:faker/faker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:googleapis_auth/auth_io.dart';
// import 'package:flutter_device_id/flutter_device_id.dart';
import 'package:http/http.dart' as http;
import 'package:nice_buttons/nice_buttons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pointycastle/export.dart';
import 'package:vertex_ai/vertex_ai.dart';
import 'debug.dart';
import 'entities.dart';
import 'myobjectbox.dart';
import 'objectbox.g.dart';
import 'wordselection.dart';

const String title = "HENYO U?!";
bool gameStarted = false;
bool showTestAds = false;
String infoTitle = '';
String infoMessage = '';
int totalRewardedAdClicks = 0;
double bannerHeight = 60.0;
double backButtonFontScale = 0.9;
Color customBlueColor = const Color(0xFF577299);
Color appBackgroundColor =
    const Color(0xFFE9EEEE); //const Color.fromARGB(255, 196, 208, 214);
Color mainBackgroundColor = Colors.blueGrey;
String themeColorName = 'Gray';
Color grey = Colors.grey.shade700;
Color appThemeColor = grey;
Color borderColor = const Color.fromARGB(255, 111, 34, 34);
Color constTimerColor = Colors.white;
Color constResultColor = Colors.transparent;
Color resultColor = constResultColor;
Color timerColor = constTimerColor;
Color inputTextColor = appThemeColor;
Color buttonTextColor = Colors.white;
Color scaffoldColor = Colors.transparent;
Color darkTextColor = grey;
String fontName = GoogleFonts.margarine().fontFamily!;
TextStyle textStyle = TextStyle(
    fontFamily: fontName,
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: buttonTextColor);
TextStyle textStyleSmall = TextStyle(
    fontSize: 7,
    fontWeight: FontWeight.bold,
    color: buttonTextColor,
    fontFamily: fontName);
TextStyle textStyleDark(BuildContext context) {
  double screenW = MediaQuery.of(context).size.width;
  double screenH = MediaQuery.of(context).size.height;
  double size = (sqrt(screenH) + sqrt(screenW)) / 3;
  return TextStyle(
      fontFamily: fontName,
      fontSize: size,
      fontWeight: FontWeight.bold,
      color: darkTextColor);
}

TextStyle textStyleDarkBig = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: darkTextColor,
    fontFamily: fontName);
TextStyle textStyleDarkDisabled = TextStyle(
    fontFamily: fontName,
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: darkTextColor.withOpacity(.1));
TextStyle textStyle18 = TextStyle(
    fontFamily: fontName,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: buttonTextColor);
TextStyle textStyleCustomFontSize(double size) {
  return TextStyle(
      fontFamily: fontName,
      fontSize: size,
      fontWeight: FontWeight.bold,
      color: buttonTextColor);
}

TextStyle textStyleCustom(BuildContext context, Color color) {
  double screenW = MediaQuery.of(context).size.width;
  double screenH = MediaQuery.of(context).size.height;
  double size = (sqrt(screenH) + sqrt(screenW)) / (screenW > 700 ? 2 : 3);
  return TextStyle(
      fontFamily: fontName,
      fontSize: size,
      fontWeight: FontWeight.bold,
      color: color);
}

TextStyle textStyleAutoScaledByPercent(
    BuildContext context, double percent, Color color) {
  ScreenScaler scaler = ScreenScaler()..init(context);
  scaledFontSize(context);
  // double size = (sqrt(MediaQuery.sizeOf(context).width));
  // debug('auto scaled: ${scaler.getTextSize(percent)}');
  // TextStyle style = GoogleFonts.margarine;
  return TextStyle(
      fontFamily: fontName,
      // fontFamily: GoogleFonts.indieFlower().fontFamily,
      // fontFamily: GoogleFonts.merienda().fontFamily,
      // fontFamily: GoogleFonts.jua().fontFamily,
      fontSize: scaler.getTextSize(percent),
      fontWeight: FontWeight.bold,
      color: color);
}

TextStyle textStyleCustomFontSizeFromContext(
    BuildContext context, double scale) {
  ScreenScaler scaler = ScreenScaler()..init(context);
  return TextStyle(
      fontFamily: fontName,
      fontSize: scaler.getTextSize(10) *
          scale, // calculateFixedFontSize(context) * scale,
      fontWeight: FontWeight.bold,
      color: buttonTextColor);
}

TextStyle textStyleDarkCustomFontSizeFromContext(
    BuildContext context, double scale) {
  ScreenScaler scaler = ScreenScaler()..init(context);
  return TextStyle(
      fontFamily: fontName,
      fontSize: scaler.getTextSize(12) *
          scale, //calculateFixedFontSize(context) * scale,
      fontWeight: FontWeight.bold,
      color: darkTextColor);
}

TextStyle textStyleDarkCustomFontSize(double fontSize) {
  return TextStyle(
      fontFamily: fontName,
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: darkTextColor);
}

ButtonStyle buttonStyle = ElevatedButton.styleFrom(
  textStyle: textStyle,
  backgroundColor: appThemeColor.withOpacity(.5),
  side: BorderSide(width: 1, color: borderColor), //border width and color
  elevation: 9,
);
final ButtonStyle homeButtonStyle = ElevatedButton.styleFrom(
  textStyle: textStyle,
  backgroundColor: appThemeColor,
  side: BorderSide(width: 1, color: borderColor), //border width and color
  elevation: 9,
);
ButtonStyle landingButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: appThemeColor.withOpacity(.5), //background color of button
  side: BorderSide(width: 1, color: borderColor), //border width and color
  elevation: 5, //elevation of button
  shape: RoundedRectangleBorder(
      //to set border radius to button
      borderRadius: BorderRadius.circular(10)),
  // padding: const EdgeInsets.all(10) //content padding inside button
);

TextScaler customTextScaler(BuildContext context,
    {double min = 0.8, double max = 1.2}) {
  return MediaQuery.textScalerOf(context)
      .clamp(minScaleFactor: min, maxScaleFactor: max);
}

TextScaler defaultTextScaler(BuildContext context) {
  double screenW = MediaQuery.of(context).size.width;
  double min = 0.8;
  double max = 1.0;
  if (screenW > 800) {
    max = 1.4;
  } else if (screenW > 500) {
    max = 1.2;
  }
  return MediaQuery.textScalerOf(context)
      .clamp(minScaleFactor: min, maxScaleFactor: max);
}

double scaledFontSize(BuildContext context) {
  final scale = MediaQuery.textScalerOf(context);
  final scaleFactor = scale.scale(1.0);
  // debug('scale factor: $scaleFactor');
  return 1 / scaleFactor;
}

double screenHeightThreshold = 870.0;

Widget defaultButton(
    BuildContext context,
    // double heightScaleButton,
    // double widthScaleButton,
    double fontScale,
    double opacity,
    String text,
    VoidCallback callback) {
  return defaultButtonWithDirection(context, fontScale, opacity, text,
      GradientOrientation.Horizontal, callback);
}

double defaultPercentageForButtons = 16;
Widget defaultButtonWithDirection(
    BuildContext context,
    // double heightScaleButton,
    // double widthScaleButton,
    double fontScale,
    double opacity,
    String text,
    GradientOrientation direction,
    VoidCallback callback) {
  ScreenScaler scaler = ScreenScaler()..init(context);
  // double screenH = MediaQuery.of(context).size.height;
  // double screenW = MediaQuery.of(context).size.width;
  // // final bool tallerScreen = screenH >= screenHeightThreshold;
  // final bool widerScreen = screenW > 450.0;
  // final double textLength =
  //     text.length < 8 ? 8 : (text.length - (widerScreen ? 0 : 2));
  // final double textLength = calculateFontSizePartyMode(context, text);

  TextStyle style = textStyleAutoScaledByPercent(context, 12, buttonTextColor);
  Size size = getSizeOfText(text, style);

  return NiceButtons(
    endColor: appThemeColor,
    startColor: customBlueColor,
    stretch: false,
    width: size.width + scaler.getTextSize(defaultPercentageForButtons),
    height: size.height + scaler.getTextSize(defaultPercentageForButtons),
    // height: pow(screenH, .3) *
    //     log(screenH) *
    //     (screenH > 1000 ? 1.3 : 1), //height of button
    // width: textLength * scaler.getTextSize(12), //width of button
    borderColor: borderColor,
    borderThickness: 2.0,
    borderRadius: 10,
    gradientOrientation: direction,
    onTap: (finish) {
      callback();
    },
    child: Text(
      textScaler: defaultTextScaler(context),
      text,
      style: style,
      maxLines: 1,
    ),
  );

  // return SizedBox(
  //   height: pow(screenH, .3) *
  //       log(screenH) *
  //       (screenH > 1000 ? 1.3 : 1), //height of button
  //   width: sqrt(screenW) * textLength * fontScale, //width of button
  //   child: ElevatedButton(
  //     style: ElevatedButton.styleFrom(
  //         backgroundColor:
  //             appThemeColor.withOpacity(opacity), //background color of button
  //         side:
  //             BorderSide(width: 1, color: borderColor), //border width and color
  //         elevation: 5, //elevation of button
  //         shape: RoundedRectangleBorder(
  //             //to set border radius to button
  //             borderRadius: BorderRadius.circular(10)),
  //         padding: const EdgeInsets.all(10) //content padding inside button
  //         ),
  //     onPressed: callback,
  //     child: Text(
  //       textScaler: customTextScaler(context),
  //       text,
  //       style: textStyleCustomFontSizeFromContext(context, fontScale),
  //     ),
  //   ),
  // );
}

Widget defaultButtonWithIcon(BuildContext context, double fontScale,
    double opacity, String text, Icon icon, VoidCallback callback) {
  // double screenH = MediaQuery.of(context).size.height;
  // double screenW = MediaQuery.of(context).size.width;
  // final bool tallerScreen = screenH >= screenHeightThreshold;
  // final bool widerScreen = screenW > 375.0;
  // final double textLength =
  //     text.length < 8 ? 8 : (text.length - (widerScreen ? 0 : 2));
  ScreenScaler scaler = ScreenScaler()..init(context);
  // double screenH = MediaQuery.of(context).size.height;
  // double screenW = MediaQuery.of(context).size.width;
  // // final bool tallerScreen = screenH >= screenHeightThreshold;
  // final bool widerScreen = screenW > 450.0;
  // final double textLength =
  //     text.length < 8 ? 8 : (text.length - (widerScreen ? 0 : 2));
  // final double textLength = calculateFontSizePartyMode(context, text);

  TextStyle style = textStyleAutoScaledByPercent(context, 12, buttonTextColor);
  Size size = getSizeOfText(text, style);

  return NiceButtons(
    endColor: appThemeColor,
    startColor: customBlueColor,
    stretch: false,
    width: size.width +
        scaler.getTextSize(defaultPercentageForButtons) +
        icon.size!,
    height: size.height + scaler.getTextSize(defaultPercentageForButtons),
    // height: pow(screenH, .3) *
    //     log(screenH) *
    //     (screenH > 1000 ? 1.3 : 1), //height of button
    // width: (sqrt(screenW) * text.length * fontScale) +
    //     icon.size!, //width of b/width of button
    borderColor: borderColor,
    borderThickness: 2.0,
    borderRadius: 10,
    gradientOrientation: GradientOrientation.Horizontal,
    onTap: (finish) {
      callback();
    },
    child: Row(children: [
      const Spacer(),
      Text(
        textScaler: defaultTextScaler(context),
        text,
        style: textStyleAutoScaledByPercent(context, 12, buttonTextColor),
      ),
      icon,
      const Spacer(),
    ]),
  );

  // return SizedBox(
  //   height: pow(screenH, .3) *
  //       log(screenH) *
  //       (screenH > 1000 ? 1.3 : 1), //height of button
  //   width: (sqrt(screenW) * text.length * fontScale) +
  //       icon.size!, //width of button
  //   child: ElevatedButton(
  //       style: ElevatedButton.styleFrom(
  //           backgroundColor:
  //               appThemeColor.withOpacity(opacity), //background color of button
  //           side: BorderSide(
  //               width: 1, color: borderColor), //border width and color
  //           elevation: 5, //elevation of button
  //           shape: RoundedRectangleBorder(
  //               //to set border radius to button
  //               borderRadius: BorderRadius.circular(10)),
  //           padding: const EdgeInsets.all(10) //content padding inside button
  //           ),
  //       onPressed: callback,
  //       child: Row(children: [
  //         const Spacer(),
  //         Text(
  //           textScaler: customTextScaler(context),
  //           text,
  //           style: textStyleCustomFontSizeFromContext(context, fontScale),
  //         ),
  //         icon,
  //         const Spacer(),
  //       ])),
  // );
}

Widget defaultIconButton(BuildContext context, double scale, double opacity,
    Icon icon, VoidCallback callback) {
  double screenH = MediaQuery.of(context).size.height;
  double screenW = MediaQuery.of(context).size.width;
  final bool tallerScreen = screenH >= screenHeightThreshold;
  // final bool widerScreen = screenW > 375.0;
  // icon.size = sqrt(screenW);

  return NiceButtons(
    endColor: appThemeColor,
    startColor: customBlueColor,
    stretch: false,
    height: sqrt(screenH) * (tallerScreen ? 1.7 : 1.6), //height of button
    width: sqrt(screenW) * 4, //width of button
    borderColor: borderColor,
    borderThickness: 2.0,
    borderRadius: 30,
    gradientOrientation: GradientOrientation.Vertical,
    onTap: (finish) {
      callback();
    },
    child: icon,
  );

  // return SizedBox(
  //     height: sqrt(screenH) * (tallerScreen ? 1.7 : 1.6), //height of button
  //     width: sqrt(screenW) * 4, //width of button
  //     child: ElevatedButton(
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor:
  //             appThemeColor.withOpacity(opacity), //background color of button
  //       ),
  //       onPressed: callback,
  //       // child: Row(children: [
  //       //   const Spacer(),
  //       //   icon,
  //       //   const Spacer(),
  //       // ])),
  //       child: icon,
  //     ));
}

Widget defaultIconButton2(BuildContext context, double scale, double opacity,
    Icon icon, VoidCallback callback) {
  double screenH = MediaQuery.of(context).size.height;
  double screenW = MediaQuery.of(context).size.width;
  final bool tallerScreen = screenH >= screenHeightThreshold;
  // final bool widerScreen = screenW > 375.0;
  // icon.size = sqrt(screenW);

  return NiceButtons(
    endColor: appThemeColor,
    startColor: customBlueColor,
    stretch: false,
    height: sqrt(screenH) * (tallerScreen ? 1.6 : 1.5), //height of button
    width: sqrt(screenW) * 2.5, //width of button
    borderColor: borderColor,
    borderThickness: 2.0,
    borderRadius: 10,
    gradientOrientation: GradientOrientation.Vertical,
    onTap: (finish) {
      callback();
    },
    child: icon,
  );
}

Widget blankButton(BuildContext context) {
  double screenH = MediaQuery.of(context).size.height;
  double screenW = MediaQuery.of(context).size.width;
  final bool tallerScreen = screenH >= screenHeightThreshold;
  // final bool widerScreen = screenW > 375.0;
  // icon.size = sqrt(screenW);
  return SizedBox(
    height: sqrt(screenH) * (tallerScreen ? 1.7 : 1.6), //height of button
    width: sqrt(screenW) * 4, //width of button
    // child: ElevatedButton(
    //   style: ElevatedButton.styleFrom(
    //     backgroundColor:
    //         appThemeColor.withOpacity(opacity), //background color of button
    //   ),
    //   onPressed: callback,
    //   // child: Row(children: [
    //   //   const Spacer(),
    //   //   icon,
    //   //   const Spacer(),
    //   // ])),
    //   child: icon,
  );
}

Widget defaultScaledButton(
    BuildContext context,
    double heightScaleButton,
    double widthScaleButton,
    double fontScale,
    double opacity,
    String text,
    VoidCallback callback) {
  ScreenScaler scaler = ScreenScaler()..init(context);
  double screenH = MediaQuery.of(context).size.height;
  double screenW = MediaQuery.of(context).size.width;
  debug('$screenH $screenW');
  // final bool tallerScreen = screenH >= screenHeightThreshold;
  final bool widerScreen = screenW > 420.0;
  final double textLength =
      text.length < 6 ? 6 : (text.length - (widerScreen ? 0 : 2));

  return NiceButtons(
    endColor: appThemeColor,
    startColor: customBlueColor,
    stretch: false,
    height: pow(screenH, .3) *
        log(screenH) *
        (screenH > 1000 ? 1.3 : 1), //height of button
    width: textLength * scaler.getTextSize(11), //width of button
    borderColor: borderColor,
    borderThickness: 2.0,
    borderRadius: 10,
    gradientOrientation: GradientOrientation.Horizontal,
    onTap: (finish) {
      callback();
    },
    child: Text(
      textScaler: defaultTextScaler(context),
      text,
      style: textStyleAutoScaledByPercent(context, 12, buttonTextColor),
      maxLines: 1,
    ),
  );

  // return SizedBox(
  //   height: pow(screenH, .3333) *
  //       log(screenH) *
  //       (screenH > 1000 ? 1.3 : .8) *
  //       heightScaleButton,
  //   width: sqrt(screenW) *
  //       textLength *
  //       fontScale *
  //       widthScaleButton, //width of button
  //   child: ElevatedButton(
  //     style: ElevatedButton.styleFrom(
  //         backgroundColor:
  //             appThemeColor.withOpacity(opacity), //background color of button
  //         side:
  //             BorderSide(width: 1, color: borderColor), //border width and color
  //         elevation: 5, //elevation of button
  //         shape: RoundedRectangleBorder(
  //             //to set border radius to button
  //             borderRadius: BorderRadius.circular(10)),
  //         padding: const EdgeInsets.all(10) //content padding inside button
  //         ),
  //     onPressed: callback,
  //     child: Text(
  //       textScaler: defaultTextScaler(context, max: .8),
  //       text,
  //       style: textStyleCustomFontSizeFromContext(context, fontScale),
  //     ),
  //   ),
  // );
}

Widget defaultScaledLandscapeButton(
    BuildContext context,
    double heightScaleButton,
    double widthScaleButton,
    double fontScale,
    double opacity,
    String text,
    VoidCallback callback) {
  double screenH = MediaQuery.of(context).size.height;
  double screenW = MediaQuery.of(context).size.width;
  // final bool tallerScreen = screenH >= screenHeightThreshold;
  final bool widerScreen = screenW > 900.0;
  final double textLength =
      text.length < 6 ? 6 : (text.length - (widerScreen ? 0 : 2));

  return NiceButtons(
    endColor: appThemeColor,
    startColor: customBlueColor,
    stretch: false,
    height: pow(screenH, .3333) *
        log(screenH) *
        (screenH > 1000 ? 1.3 : .8) *
        heightScaleButton,
    width: sqrt(screenW) *
        textLength *
        fontScale *
        widthScaleButton, //width of button
    borderColor: borderColor,
    borderThickness: 2.0,
    borderRadius: 10,
    gradientOrientation: GradientOrientation.Horizontal,
    onTap: (finish) {
      callback();
    },
    child: Text(
      // textScaler: defaultTextScaler(context, max: widerScreen ? 1.1 : .95),
      textScaler: defaultTextScaler(context),
      text,
      style: textStyleAutoScaledByPercent(context, 13, buttonTextColor),
    ),
  );

  // return SizedBox(
  //   height: pow(screenH, .3333) *
  //       log(screenH) *
  //       (screenH > 1000 ? 1.3 : .8) *
  //       heightScaleButton,
  //   width: sqrt(screenW) *
  //       textLength *
  //       fontScale *
  //       widthScaleButton, //width of button
  //   child: ElevatedButton(
  //     style: ElevatedButton.styleFrom(
  //         backgroundColor:
  //             appThemeColor.withOpacity(opacity), //background color of button
  //         side:
  //             BorderSide(width: 1, color: borderColor), //border width and color
  //         elevation: 5, //elevation of button
  //         shape: RoundedRectangleBorder(
  //             //to set border radius to button
  //             borderRadius: BorderRadius.circular(10)),
  //         padding: const EdgeInsets.all(10) //content padding inside button
  //         ),
  //     onPressed: callback,
  //     child: Text(
  //       textScaler: defaultTextScaler(context, max: widerScreen ? 1.1 : .95),
  //       text,
  //       style: textStyleCustomFontSizeFromContext(context, fontScale),
  //     ),
  //   ),
  // );
}

Widget defaultBackButton(
    BuildContext context, double fontScale, double opacity) {
  double screenH = MediaQuery.of(context).size.height;
  double screenW = MediaQuery.of(context).size.width;
  // final bool tallerScreen = screenH >= screenHeightThreshold;
  // final bool widerScreen = screenW > 430.0;

  return NiceButtons(
    endColor: appThemeColor,
    startColor: customBlueColor,
    stretch: false,
    height: pow(screenH, .3) *
        log(screenH) *
        (screenH > 1000 ? 1.3 : 1), //height of button
    width: sqrt(screenW) * 7 * fontScale, //width of button//width of button
    borderColor: borderColor,
    borderThickness: 2.0,
    borderRadius: 10,
    gradientOrientation: GradientOrientation.Horizontal,
    onTap: (finish) {
      // Navigate back to first route when tapped.
      Navigator.pop(context);
    },
    child: Text(
      textScaler: customTextScaler(context),
      'Back',
      style: textStyleAutoScaledByPercent(context, 12, buttonTextColor),
      maxLines: 1,
    ),
  );

  // return SizedBox(
  //   height: pow(screenH, .3) *
  //       log(screenH) *
  //       (screenH > 1000 ? 1.3 : 1), //height of button
  //   width: sqrt(screenW) * 7 * fontScale, //width of button
  //   child: ElevatedButton(
  //     style: ElevatedButton.styleFrom(
  //         backgroundColor:
  //             appThemeColor.withOpacity(opacity), //background color of button
  //         side:
  //             BorderSide(width: 1, color: borderColor), //border width and color
  //         elevation: 5, //elevation of button
  //         shape: RoundedRectangleBorder(
  //             //to set border radius to button
  //             borderRadius: BorderRadius.circular(10)),
  //         padding: const EdgeInsets.all(10) //content padding inside button
  //         ),
  //     onPressed: () {
  //       // Navigate back to first route when tapped.
  //       Navigator.pop(context);
  //     },
  //     child: Text(
  //       textScaler: defaultTextScaler(context),
  //       'Back',
  //       style: textStyleCustomFontSizeFromContext(context, fontScale),
  //     ),
  //   ),
  // );
}

Widget defaultSquareButton(BuildContext context, double height, double width,
    String text, VoidCallback callback) {
  return NiceButtons(
    endColor: appThemeColor,
    startColor: customBlueColor,
    stretch: false,
    height: height, //height of button
    width: width, //width of button
    borderColor: borderColor,
    borderThickness: 2.0,
    borderRadius: 10,
    gradientOrientation: GradientOrientation.Horizontal,
    onTap: (finish) {
      callback();
    },
    child: Text(
      textAlign: TextAlign.center,
      text,
      textScaler: defaultTextScaler(context),
      style: textStyleAutoScaledByPercent(context, 12, buttonTextColor),
      softWrap: true,
      // maxLines: 1,
    ),
  );
}

ButtonStyle squareButtonStyle(Size size) {
  return ElevatedButton.styleFrom(
    fixedSize: size,
    backgroundColor: appThemeColor.withOpacity(.5), //background color of button
    side: BorderSide(width: 1, color: borderColor), //border width and color
    elevation: 5, //elevation of button
    shape: RoundedRectangleBorder(
        //to set border radius to button
        borderRadius: BorderRadius.circular(10)),
    // padding: const EdgeInsets.all(10) //content padding inside button
  );
}

Widget gradientGoldCoin(Widget widget) {
  return AnimateGradient(
      duration: const Duration(seconds: 30),
      primaryBegin: Alignment.topLeft,
      primaryEnd: Alignment.bottomLeft,
      secondaryBegin: Alignment.bottomLeft,
      secondaryEnd: Alignment.topRight,
      primaryColors: const [
        Colors.yellow,
        Colors.orange,
        // Colors.green,
        // appThemeColor,
        // customBlueColor,
        // Colors.white,
        // appThemeColor,
      ],
      secondaryColors: const [
        // Colors.blue,
        Colors.orange,
        Colors.yellow,
        // Colors.red,
        // Colors.white,
        // customBlueColor,
        // appThemeColor,
        // Colors.white,
      ],
      child: widget);
}

Widget animateGradient(AnimationController controller, Widget widget) {
  return AnimateGradient(
      controller: controller,
      // duration: const Duration(seconds: 20),
      primaryBegin: Alignment.topLeft,
      primaryEnd: Alignment.bottomLeft,
      secondaryBegin: Alignment.bottomLeft,
      secondaryEnd: Alignment.topRight,
      primaryColors: [
        // Colors.purple,
        // Colors.orange,
        // Colors.green,
        appThemeColor,
        customBlueColor,
        // Colors.white,
        // appThemeColor,
      ],
      secondaryColors: [
        // Colors.blue,
        // Colors.yellow,
        // Colors.red,
        // Colors.white,
        customBlueColor,
        appThemeColor,
        // Colors.white,
      ],
      child: widget);
}

Widget animateGradientReverse(Widget widget) {
  return AnimateGradient(
      duration: const Duration(seconds: 20),
      primaryBegin: Alignment.bottomLeft,
      primaryEnd: Alignment.topLeft,
      secondaryBegin: Alignment.topLeft,
      secondaryEnd: Alignment.bottomRight,
      secondaryColors: [
        // Colors.purple,
        // Colors.orange,
        // Colors.green,
        customBlueColor,
        appThemeColor,
        // Colors.white,
        // appThemeColor,
      ],
      primaryColors: [
        // Colors.blue,
        // Colors.yellow,
        // Colors.red,
        // Colors.white,
        appThemeColor,
        customBlueColor,
        // Colors.white,
      ],
      child: widget);
}

Widget gradientButton(BuildContext context, AnimationController animation,
    String text, VoidCallback callback) {
  double screenH = MediaQuery.sizeOf(context).height;
  double screenW = MediaQuery.sizeOf(context).width;
  final bool tallerScreen = MediaQuery.of(context).size.height >= 800.0;
  final bool widerScreen = MediaQuery.of(context).size.width > 430.0;
  TextStyle style = textStyleAutoScaledByPercent(context, 13, buttonTextColor);
  return Center(
      child: Container(
          height: sqrt(screenH) * (tallerScreen ? 2.3 : 1.7), //height of button
          width: screenW * (widerScreen ? .6 : .8), //width of button
          decoration: BoxDecoration(
            image: const DecorationImage(
                scale: .8,
                repeat: ImageRepeat.repeat,
                alignment: Alignment.centerRight,
                image: AssetImage('assets/lightbulb_brain.png')),
            borderRadius: BorderRadius.circular(20),
          ),
          // decoration: BoxDecoration(boxShadow: [
          //   BoxShadow(
          //       color: appThemeColor.withOpacity(.3),
          //       blurRadius: animation.value,
          //       spreadRadius: animation.value)
          // ]),
          child: AnimateGradient(
              // duration: const Duration(seconds: 5),
              controller: animation,
              primaryBegin: Alignment.topLeft,
              primaryEnd: Alignment.bottomLeft,
              secondaryBegin: Alignment.bottomLeft,
              secondaryEnd: Alignment.topRight,
              primaryColors: [
                // Colors.purple,
                // Colors.orange,
                // Colors.green,
                appThemeColor.withOpacity(.8),
                customBlueColor,
                // Colors.white,
                // appThemeColor,
              ],
              secondaryColors: [
                // Colors.blue,
                // Colors.yellow,
                // Colors.red,
                // Colors.white,
                customBlueColor,
                appThemeColor.withOpacity(.8),
                // Colors.white,
              ],
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shadowColor: Colors.transparent,
                    backgroundColor: Colors.transparent,
                    overlayColor: Colors.white,
                    side: const BorderSide(
                        width: 1,
                        color: Colors.transparent), //border width and color
                    elevation: 5, //elevation of button
                    shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 3),
                        borderRadius: BorderRadius.circular(15)),
                    padding:
                        const EdgeInsets.all(10) //content padding inside button
                    ),
                onPressed: callback,
                child: Text(
                  textScaler: defaultTextScaler(context),
                  text,
                  style: style,
                  maxLines: 1,
                ),
              ))));
}

Widget niceButtonGimme5(BuildContext context, double height, double width,
    String text, Function(int) callback, Color color) {
  textStyleAutoScaledByPercent(context, 13, color);
  // Size size = getSizeOfText(text, style);
  // ScreenScaler scaler = ScreenScaler()..init(context);
  return NiceButtons(
      endColor: customBlueColor,
      startColor: Colors.white,
      stretch: false,
      width: width,
      height: height,
      // width: size.width + scaler.getTextSize(defaultPercentageForButtons),
      // height: size.height + scaler.getTextSize(defaultPercentageForButtons),
      borderColor: borderColor,
      borderThickness: 2.0,
      borderRadius: 10,
      gradientOrientation: GradientOrientation.Vertical,
      onTap: (n) {
        callback(5);
      },
      child: AutoSizeText(text,
          style: textStyleAutoScaledByPercent(
              context,
              getSizeOfText(text,
                      textStyleAutoScaledByPercent(context, 12, appThemeColor))
                  .height,
              color))
      // child: Center(
      //     child: Text(
      //   textScaler: defaultTextScaler(context),
      //   text,
      //   style: style,
      //   maxLines: 2,
      // )),
      );
}

Widget niceButton(BuildContext context, double height, double width,
    String text, VoidCallback callback) {
  TextStyle style = textStyleAutoScaledByPercent(context, 13, buttonTextColor);
  // Size size = getSizeOfText(text, style);
  // ScreenScaler scaler = ScreenScaler()..init(context);
  return NiceButtons(
      endColor: appThemeColor,
      startColor: customBlueColor,
      stretch: false,
      width: width,
      height: height,
      // width: size.width + scaler.getTextSize(defaultPercentageForButtons),
      // height: size.height + scaler.getTextSize(defaultPercentageForButtons),
      borderColor: borderColor,
      borderThickness: 2.0,
      borderRadius: 10,
      gradientOrientation: GradientOrientation.Horizontal,
      onTap: (finish) {
        callback();
      },
      child: Text(
        textScaler: defaultTextScaler(context),
        text,
        style: style,
        maxLines: 1,
      ));
}

List<Color> phColors = [
  Colors.white,
  // Colors.blue.shade200,
  Colors.blue.shade300,
  Colors.blue.shade300,
  // Colors.white,
  Colors.white,
  Colors.yellow.shade200,
  Colors.white,
  Colors.yellow.shade300,
  Colors.white,
  Colors.yellow.shade200,
  // Colors.white,
  Colors.white,
  Colors.red.shade300,
  Colors.red.shade300,
  // Colors.red.shade200,
  Colors.white
];

Widget niceButtonWithAnimate(BuildContext context, double height, double width,
    String text, VoidCallback callback, int delayFadeIn, int delayShimmer) {
  TextStyle style = textStyleAutoScaledByPercent(context, 13, buttonTextColor);

  return RepaintBoundary(
      child: NiceButtons(
          endColor: appThemeColor,
          startColor: customBlueColor,
          stretch: false,
          width: width,
          height: height,
          borderColor: borderColor,
          borderThickness: 2.0,
          borderRadius: 10,
          gradientOrientation: GradientOrientation.Horizontal,
          onTap: (finish) {
            callback();
          },
          child: Text(
            textScaler: defaultTextScaler(context),
            text,
            style: style,
            maxLines: 1,
          )
              .animate(delay: delayShimmer.ms)
              .shimmer(duration: 10000.ms, colors: phColors)
              .swap(
                  builder: (_, child) => child!
                      .animate(onPlay: (c) => c.repeat())
                      .shimmer(
                          delay: delayFadeIn.ms,
                          duration: 10000.ms,
                          colors: phColors))));

  // .fadeIn(duration: 900.ms, delay: delayFadeIn.ms)
  // .shimmer(blendMode: BlendMode.srcOver, color: Colors.white12)
  // .move(begin: const Offset(-32, 0), curve: Curves.easeOutQuad);
}

SoundPlayer player3 = SoundPlayer();

late String wordLocale;
String wordDifficulty = 'e';
String wordCategory = '';
String difficultyEasyMessage = 'Regular words to be guessed are selected';
String difficultyMediumMessage = 'Regular and Hard words are selected';
String difficultyHardMessage = 'All words are selected';
String difficultyMessage = difficultyEasyMessage;

List<dynamic>? wordsAssociated;
List<dynamic>? wordsPossible;
List<dynamic>? wordsDictionary;
List<dynamic>? wordsAlternate;

late Secure keys;
late Store store;
late User user;
Record? record; // not 'late' since we want to check for null
late List<Record> records;
late UserSettings userSettings;
//late Future<List<Record>> records;
late ObjectBox objectBox;

HenyoWordsList wordsList = HenyoWordsList();
// may need to cache words map to db for persistency
Map<String, dynamic> wordsMap = <String, dynamic>{};
Map<String, dynamic> dictionaryMap = <String, dynamic>{};
Map<String, dynamic> gimme5Round1Map = <String, dynamic>{};

enum GameMode {
  solo,
  multiPlayer,
  gimme5Round1,
  gimme5Round2,
  gimme5Round3,
  party,
  unset
}

int gimme5TotalCorrectGuessCount = 0;
int gimme5Wager = 10;

GameMode gameMode = GameMode.unset;

bool gimme5Start = false;
var gimme5Words = [];
List<Widget> gimme5Buttons = [];
int gimme5CategoryRound1Index = -1;
String gimme5CategoryRound1 = '';
String gimme5CategoryRound2 = '';
List<String> getGimme5Categories(String locale) {
  if (locale == 'ph') {
    return ['TAO', 'BAGAY', 'HAYOP', 'LUGAR', 'PAGKAIN'];
  } else {
    return ['PERSON', 'THING', 'ANIMAL', 'PLACE', 'FOOD'];
  }
}

String henyoApiUrl = 'https://www.henyogames.com/v2/api';
// String henyoApiUrl2 = 'https://henyo.esaflip.com/v2/api';

int score = 0;
int totalScore = 0;
int streak = 0;
int totalStreak = 0;
int credits = 1000;
int id = 0;
String username = henyou;
String alias = '';

String whatsNewMessage = '';
String whatsNewTitle = '';
int whatsNewTimestamp = 0;
int dailyRewardLastGiven = 0;
int totalTokensUsed = 0;

late StreamSubscription<ConnectivityResult> internetSubscription;
Timer? countdownTimer;
// Duration? tempDuration;
// int gameDuration = 2;
Duration myDuration = Duration(minutes: globalSettings.gameDuration);
// int consecutiveWins = 0;
bool isOffline = false;
bool timerRunning = false;
bool haveLoadedUserData = false;

ably.RealtimeChannel? chatChannel, negotiatingChannel;
String mpRoomName = '';
// bool multiplayerMode = false;
String multiplayerLocale = 'ph';
String multiplayerDifficulty = 'h';
bool roomJoined = false;
MultiPlayerInfo? mpInfo;
Map<String, dynamic> multiplayerWordsMap = <String, dynamic>{};
HenyoMPWordsList wordsMP = HenyoMPWordsList();

// bool gimme5Mode = false;

// bool isIOSandPH = Platform.isIOS &&
//     (wordLocale == 'ph' ||
//         (gameMode == GameMode.multiPlayer && multiplayerLocale == 'ph'));

PackageInfo? packageInfo;
String? version;
String? code;
String henyou = 'henyou';

const String serverPublickKey =
    '-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAkzJyv2o0g0iOuEcabGFy\nV1uaeGEy7Kh+4iUArYMpzj4M0OP2DEYgPZFLxumHUZQzS4mvVdW7W4kY8OMOVFxF\n0EN2jKub8hpQVlHhAAAFqIB61Pz7UMR5MX+gTRzelh7B3L2nmjxDoVhxwAjhZ3Bt\nwLl3ppOyrm2/k7rHrLK1sChUT+wwBRXOTtZz8AqzJ3WdOnXa6qIWxeCbSSghnn3N\nGQR5OifmbpwC+CAfGt5nJS4ke9XEt6RnSkRNdIhg9hy6kGwTiXuLMZuZuv9S0v3u\nEpzUCuLdELoDuXLW2lKgMLYxnpX1A9HWKLSTYu/mKPx9ZzGh5PR7AKH9aAkCFXU+\n/QIDAQAB\n-----END PUBLIC KEY-----';
// const String serverPrivateKey =
// '-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCTMnK/ajSDSI64\nRxpsYXJXW5p4YTLsqH7iJQCtgynOPgzQ4/YMRiA9kUvG6YdRlDNLia9V1btbiRjw\n4w5UXEXQQ3aMq5vyGlBWUeEAAAWogHrU/PtQxHkxf6BNHN6WHsHcvaeaPEOhWHHA\nCOFncG3AuXemk7Kubb+TusessrWwKFRP7DAFFc5O1nPwCrMndZ06ddrqohbF4JtJ\nKCGefc0ZBHk6J+ZunAL4IB8a3mclLiR71cS3pGdKRE10iGD2HLqQbBOJe4sxm5m6\n/1LS/e4SnNQK4t0QugO5ctbaUqAwtjGelfUD0dYotJNi7+Yo/H1nMaHk9HsAof1o\nCQIVdT79AgMBAAECggEAbivoLtSzEUARcmPlpxEYn8H0T/2QPAmxTlobs8LkW3Wd\n6gt1caJbJznE2dCYc7rU2cjn7vrWDKEEheesJgAaUNLtvEQFqKOBVdpa6cEaexAO\n37Op9r3XZ/D6bj0ZbIsA1tMsywgoJm8oVG9RJjbELueiYo9RwbRrG4tFQEFSM9IZ\nEjaa/X57otdr+0Bff3+X6E2znmyqE5MDRdqwRy6mfrphu/2tTLlG0aNZEuhg2lfe\nffCvpIyRaG3R2JMBHW1AqhXNqumUGufI7TV29TCD6OlpqSmXa/u8woyNoJY7h025\nuRSp6ZOWb25gIae6FvF0w1rDvzQrGESBgAzIKQDYAQKBgQDCwUQyJihseKWFs8jU\nDXlL/BZ6GLc67xgHYlpy6wcawEI4iuz5b1HJJBbNvNEYh2CpzyAUtx67au4DUhQu\nZ9uGH8u6TRvxROMKuRRq7WBeJNj3c9jhMwhA3W1qibT9akkIAq+YUXPerhN4AgCD\nNLF28UuZUgx9shY9aljaA/gJgQKBgQDBfImnIZ4nEHs2flPPcgC0UhzY8E+k/zwx\np8+XhOU0VUnxaBwAgOpNz+RFH1VfIscbk27zt3oDMNHCExBhpjUwuj4RCyb4Z/ON\n9WEv8kTa7ZdXTi+0EN2Iqqn3HLggayaeKjKgbVKsP2va5KQsHtcf0galbKQsQRVF\nQluLuFgbfQKBgQCAPuw9acsswrWcuasBmG3Lj5DtjeD6uf9EvYt6KTJgd0IkIbey\n+Y8NuOobSL8YO+13ZKFngr6GA///x8jqVhHE3KM3ZxeDZS1tHjtHvlC7LeCB8pNa\nmFRTAnzOryezyI2W7M3cq6Z1eIPxfr//pm9GN9bke5cmHmNuxd0Ek6B+AQKBgHIA\nRMK6pgpyRYaoDA2QKCYWs3SGswaOdBL1wvSNktaw4e5g3w7U5jiOovqvKYfyX8o5\npgfnNPaoTw7AWMiQO4rIUUWNgpqd9PzRdT/gyP0NPDxujuDThxO9KoO04jAHsitC\nxa2MfEeM3qmMScbNLQdMoinZxylj93plTLcYGKGpAoGBALXM1qgR0P+vlYe3cTEi\n+WRRM5iiuIOj9n1SfI6ESso7iamFDgtc+AX7uqookwmm3bojkn8Jph2325NFkrIT\nUJ216gFkczSKelMSCNp9p/bgRo1S4Duij+U4GMJWYJO4mxS1dR4ORTQJTlSM4xoL\ncdTa9jmSyGqZDgoG3TU6vfQ6\n-----END PRIVATE KEY-----';

String getOSInfo() {
  return '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
}

// TODO: may need to check is user name already exists in the future
String generateNewUsername() {
  String name =
      '${Faker().color.commonColor()}${Faker().animal.name()}In${Faker().address.streetName()}${Faker().randomGenerator.integer(9999999, min: 1000000)}';
  return name.replaceAll(' ', '').replaceAll('-', '').replaceAll("'", '');
}

Future<http.Response> updateUserRecord(Record rec) async {
  HttpAuth auth = getAuthHeader();
  return await http.post(
    Uri.parse('$henyoApiUrl/updateuserrecord.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
    body: encryptWithSymmetricKey(
        jsonEncode(<String, dynamic>{
          'id': rec.id,
          'name': rec.name,
          'alias': rec.alias,
          'score': rec.score,
          'totalScore': rec.totalScore,
          'streak': rec.streak,
          'totalStreak': rec.totalStreak,
          'extraData': rec.extraData,
          'secureData': rec.secureData,
        }),
        auth),
  );
}

Future<http.Response> updateRecordFromUser(User user) async {
  try {
    var extraData = jsonDecode(record!.extraData);
    final creds = <String, dynamic>{'tokens': '$credits'};
    extraData.addEntries(creds.entries);
    HttpAuth auth = getAuthHeader();
    String body = jsonEncode(<String, dynamic>{
      // 'id': user.id,
      'name': user.username,
      'alias': user.alias,
      'score': user.score,
      'totalScore': user.totalScore,
      'streak': user.streak,
      'totalStreak': user.totalStreak,
      'extraData': jsonEncode(extraData),
      'secureData': record?.secureData,
    });
    debug(body);
    return await http.post(
      Uri.parse('$henyoApiUrl/updateuserrecord.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'auth2': auth.authKey,
      },
      body: encryptWithSymmetricKey(body, auth),
    );
  } catch (e) {
    debug("updateRecordFromUser: $e");
  }
  return http.Response('client code error', 501);
}

Future<http.Response> createUserRecord() async {
  HttpAuth auth = getAuthHeader();
  final response = await http.get(
    Uri.parse("$henyoApiUrl/fetchuserrecord.php"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
  );
  if (response.statusCode == 200) {
    debug('User record found. Skipping creating a new user record.');
    return response;
  } else if (response.statusCode == 401) {
    debug(
        'Failed to retrieve valid record data for user $username. Skipping for now');
    return response;
  }

  String payload = jsonEncode(<String, dynamic>{
    'name': username,
    'alias': username,
    'score': score,
    'totalScore': totalScore,
    'streak': streak,
    'totalStreak': totalStreak,
    'secureData': jsonEncode(<String, dynamic>{
      'publicKey': base64.encode(utf8.encode(keys.publicKey)),
    }),
    'extraData':
        jsonEncode(<String, dynamic>{'appVersionInstalled': '$version+$code'}),
  });
  auth = getAuthHeader();
  return await http.post(
    Uri.parse('$henyoApiUrl/createuserrecord.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
    body: encryptWithSymmetricKey(payload, auth),
  );
}

// loadUserRecords
Future<List<Record>> fetchRecords() async {
  HttpAuth auth = getAuthHeader();
  final response = await http.get(
    Uri.parse('$henyoApiUrl/fetchrecords.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
  );
  debug('fetching all records ${DateTime.now()}');
  debug('${response.statusCode}');
  if (response.statusCode == 200) {
    List<Record> tempRecords = [];
    Map<String, dynamic> recs =
        jsonDecode(decryptWithSymmetricKey(response.body.trim(), auth));
    for (int i = 0; i < recs.values.elementAt(0).length; i++) {
      dynamic rec = recs.values.elementAt(0).elementAt(i);
      // debug(rec['id'] + ':' + rec['name']);
      tempRecords.add(Record(
        id: int.parse(rec['id']),
        name: rec['name'],
        alias: rec['alias'],
        score: int.parse(rec['score']),
        totalScore: int.parse(rec['totalScore']),
        streak: int.parse(rec['streak']),
        totalStreak: int.parse(rec['totalStreak']),
        // left out created and modified for faster response
        // created: rec['created'],
        // modified: rec['modified'],
      ));
    }
    tempRecords.sort((a, b) => b.totalScore.compareTo(a.totalScore));
    return tempRecords;
  }
  return [];
}

Future<Record?> fetchUserRecord() async {
  HttpAuth auth = getAuthHeader();
  final response = await http.get(
    Uri.parse("$henyoApiUrl/fetchuserrecord.php"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
  );

  Record? tempRecord;
  if (response.statusCode == 200) {
    try {
      String temp = decryptWithSymmetricKey(response.body.trim(), auth);
      debug(temp);
      tempRecord = Record.fromJson(jsonDecode(temp));
    } catch (e) {
      debug('fetchUserRecord: $e');
    }
  }
  return tempRecord;
}

Future<List<WeeklyRecord>> getWeeklyRecords({int weekNumber = 0}) async {
  HttpAuth auth = getAuthHeader();
  String weekNum = weekNumber == 0 ? '' : '?weekNumber=$weekNumber';
  final response = await http.get(
    Uri.parse('$henyoApiUrl/getweeklyrecords.php$weekNum'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
  );
  debug('fetching weekly records ${DateTime.now()}');
  debug(response.body);
  if (response.statusCode == 200) {
    List<WeeklyRecord> tempRecords = [];
    Map<String, dynamic> recs =
        jsonDecode(decryptWithSymmetricKey(response.body.trim(), auth));
    for (int i = 0; i < recs.values.elementAt(0).length; i++) {
      dynamic rec = recs.values.elementAt(0).elementAt(i);
      debug(rec['name']);
      // TODO: may need better logic to handle duplicate entries
      if (tempRecords.every((test) => test.name != rec['name']))
        tempRecords.add(WeeklyRecord(
          id: int.parse(rec['id']),
          name: rec['name'],
          alias: rec['alias'],
          score: int.parse(rec['score']),
          streak: int.parse(rec['streak']),
          weekNumber: int.parse(rec['weekNumber']),
          awardPaid: int.parse(rec['awardPaid']),
          awardAmount: int.parse(rec['awardAmount']),
        ));
    }
    tempRecords.sort((a, b) => b.score.compareTo(a.score));
    return tempRecords;
  }
  return [];
}

// creates or updates user weekly record
Future<http.Response> setUserWeeklyRecord(User rec) async {
  HttpAuth auth = getAuthHeader();
  return await http.post(
    Uri.parse('$henyoApiUrl/setuserweeklyrecord.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
    body: encryptWithSymmetricKey(
        jsonEncode(<String, dynamic>{
          'name': rec.username,
          'alias': rec.alias,
          'score': rec.score,
          'streak': rec.streak,
          'weekNumber': getCurrentWeekNumber(),
          // 'auth': encryptWithServerPublicKey(getOTP(rec.username)),
        }),
        auth),
  );
}

Future<WeeklyRecord> getUserWeeklyRecord(int weekNumber) async {
  HttpAuth auth = getAuthHeader();
  final response = await http.get(
    Uri.parse("$henyoApiUrl/getuserweeklyrecord.php?&weekNumber=$weekNumber"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
  );

  // debug(response.body);
  WeeklyRecord? tempRecord;
  if (response.statusCode == 200) {
    Map<String, dynamic> rec =
        jsonDecode(decryptWithSymmetricKey(response.body.trim(), auth));
    tempRecord = WeeklyRecord(
      id: int.parse(rec['id']),
      name: rec['name'],
      alias: rec['alias'],
      score: int.parse(rec['score']),
      streak: int.parse(rec['streak']),
      weekNumber: int.parse(rec['weekNumber']),
      awardPaid: int.parse(rec['awardPaid']),
      awardAmount: int.parse(rec['awardAmount']),
    );
  }
  return tempRecord!;
}

Future<http.Response> isUserAndWeekNumberExists() async {
  HttpAuth auth = getAuthHeader();
  return await http.post(
    Uri.parse('$henyoApiUrl/isuserandweeknumberexists.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
    body: encryptWithSymmetricKey(
        jsonEncode(<String, dynamic>{
          'weekNumber': getCurrentWeekNumber(),
          // 'auth': encryptWithServerPublicKey(getOTP(name)),
        }),
        auth),
  );
}

Future<WeeklyWinners> getWeeklyWinnersPreviousWeek() async {
  HttpAuth auth = getAuthHeader();
  final response = await http.get(
    Uri.parse('$henyoApiUrl/getweeklywinners.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
  );

  debug('fetching weekly winners ${DateTime.now()}');
  if (response.statusCode == 200) {
    return WeeklyWinners.fromJson(
        jsonDecode(decryptWithSymmetricKey(response.body.trim(), auth)));
  }
  return WeeklyWinners();
}

Future<http.Response> updateWeeklyWinnersPreviousWeek(
    WeeklyWinners winners) async {
  debug('updating weekly winners ${DateTime.now()}');
  HttpAuth auth = getAuthHeader();
  return await http.post(
    Uri.parse('$henyoApiUrl/updateweeklywinner.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
    body: encryptWithSymmetricKey(
        jsonEncode(<String, dynamic>{
          'weekNumber': getCurrentWeekNumber() - 1,
          'firstPlace': winners.firstPlace,
          'secondPlace': winners.secondPlace,
          'thirdPlace': winners.thirdPlace,
        }),
        auth),
  );
}

Future<http.Response> createRecordBackup(String email) async {
  String payload = jsonEncode(<String, dynamic>{
    'email': encryptWithServerPublicKey(email),
  });
  HttpAuth auth = getAuthHeader();
  return await http.post(
    Uri.parse('$henyoApiUrl/createrecordbackup.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
    body: encryptWithSymmetricKey(payload, auth),
  );
}

Future<http.Response> requestCodeBackupByEmail(String email) async {
  String payload = jsonEncode(<String, dynamic>{
    'email': email,
  });
  HttpAuth auth = getAuthHeader();
  return await http.post(
    Uri.parse('$henyoApiUrl/sendmail.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
    body: encryptWithSymmetricKey(payload, auth),
  );
}

Future<http.Response> restoreUserRecordWithCode(String code) async {
  String payload = jsonEncode(<String, dynamic>{
    'code': code,
  });
  HttpAuth auth = getAuthHeader();
  var response = await http.post(
    Uri.parse('$henyoApiUrl/restorewithcode.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
    body: encryptWithSymmetricKey(payload, auth),
  );
  if (response.statusCode == 200) {
    try {
      String payload = decryptWithSymmetricKey(response.body.trim(), auth);
      debug(payload);
      record = Record.fromJson(jsonDecode(payload));
      User user = User(
        id: 1,
        username: record!.name,
        alias: record!.alias,
        score: record!.score,
        totalScore: record!.totalScore,
        streak: record!.streak,
        totalStreak: record!.totalStreak,
      );
      if (record!.extraData.contains('tokens')) {
        debug(record!.extraData);
        user.credits = getFromExtraData('tokens', record!.extraData);
      }
      objectBox.setUser(user);

      username = user.username;
      alias = user.alias;
      streak = user.streak;
      totalStreak = user.totalStreak;
      score = user.score;
      totalScore = user.totalScore;
      credits = user.credits;
    } catch (e) {
      debug('restoreUserRecordWithCode: $e');
    }
  }
  return response;
}

Future<bool> fetchLatestJsonWords() async {
  if (objectBox.isJsonWordsNotEmpty() &&
      objectBox.getJsonWordsDate() == await fetchLatestJsonWordsDate()) {
    debug("no new updated JsonWords");
    return false;
  }
  HttpAuth auth = getAuthHeader();
  final response = await http.get(
    Uri.parse("$henyoApiUrl/fetchjsonwords.php"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
  );
  if (response.statusCode == 200) {
    JsonWords jsonWords = JsonWords();
    jsonWords.id = objectBox.isJsonWordsNotEmpty() ? 1 : 0;

    var data = jsonDecode(decryptWithSymmetricKey(response.body.trim(), auth));
    debug(data.toString());
    jsonWords.wordsDate = data['wordsDate'];
    jsonWords.wordsJson = data['wordsJson'];
    if (!objectBox.setJsonWords(jsonWords)) {
      debug('failed to save new json words to db');
    }

    debug('fetchLatestJsonWords loaded new json words');

    return true;
  }
  return false;
}

Future<int> fetchLatestJsonWordsDate() async {
  HttpAuth auth = getAuthHeader();
  final response = await http.get(
    Uri.parse("$henyoApiUrl/latestjsonwordsdate.php"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
  );
  if (response.statusCode == 200) {
    var wordsDate =
        jsonDecode(decryptWithSymmetricKey(response.body.trim(), auth));
    var date = wordsDate['wordsDate'];
    debug('json words date: ${date}');
    return date;
  }
  return 0;
}

Future<bool> fetchLatestJsonMultiplayer() async {
  if (objectBox.isJsonMultiplayerNotEmpty() &&
      objectBox.getJsonMultiplayerDate() ==
          await fetchLatestJsonMultiplayerDate()) {
    debug("no new updated JsonMultiplayer");
    return false;
  }
  HttpAuth auth = getAuthHeader();
  final response = await http.get(
    Uri.parse("$henyoApiUrl/fetchjsonmultiplayer.php"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
  );
  if (response.statusCode == 200) {
    JsonMultiplayer jsonMultiplayer = JsonMultiplayer();
    jsonMultiplayer.id = objectBox.isJsonMultiplayerNotEmpty() ? 1 : 0;

    var data = jsonDecode(decryptWithSymmetricKey(response.body.trim(), auth));
    debug(data.toString());
    jsonMultiplayer.multiplayerDate = data['multiplayerDate'];
    jsonMultiplayer.multiplayerJson = data['multiplayerJson'];
    if (!objectBox.setJsonMultiplayer(jsonMultiplayer)) {
      debug('failed to save new json multiplayer to db');
    }

    debug('fetchLatestJsonWMultiplayer loaded new json multiplayer words');

    return true;
  }
  return false;
}

Future<int> fetchLatestJsonMultiplayerDate() async {
  HttpAuth auth = getAuthHeader();
  final response = await http.get(
    Uri.parse("$henyoApiUrl/latestjsonmultiplayerdate.php"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
  );
  if (response.statusCode == 200) {
    var multiplayerDate =
        jsonDecode(decryptWithSymmetricKey(response.body.trim(), auth));
    var date = multiplayerDate['multiplayerDate'];
    debug('json multiplayer date: ${date}');
    return date;
  }
  return 0;
}

Future<bool> fetchLatestJsonDictionary() async {
  if (objectBox.isJsonDictionaryNotEmpty() &&
      objectBox.getJsonDictionaryDate() ==
          await fetchLatestJsonDictionaryDate()) {
    debug("no new updated JsonDictionary");
    return false;
  }
  HttpAuth auth = getAuthHeader();
  final response = await http.get(
    Uri.parse("$henyoApiUrl/fetchjsondictionary.php"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
  );
  if (response.statusCode == 200) {
    JsonDictionary jsonDictionary = JsonDictionary();
    jsonDictionary.id = objectBox.isJsonDictionaryNotEmpty() ? 1 : 0;

    var data = jsonDecode(decryptWithSymmetricKey(response.body.trim(), auth));
    debug(data.toString());
    jsonDictionary.dictionaryDate = data['dictionaryDate'];
    jsonDictionary.dictionaryJson = data['dictionaryJson'];
    if (!objectBox.setJsonDictionary(jsonDictionary)) {
      debug('failed to save new json dictionary to db');
    }

    debug('fetchLatestJsonDictionary loaded new json dictionary');

    return true;
  }
  return false;
}

Future<int> fetchLatestJsonDictionaryDate() async {
  HttpAuth auth = getAuthHeader();
  final response = await http.get(
    Uri.parse("$henyoApiUrl/latestjsondictionarydate.php"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
  );
  if (response.statusCode == 200) {
    var dictionaryDate =
        jsonDecode(decryptWithSymmetricKey(response.body.trim(), auth));
    var date = dictionaryDate['dictionaryDate'];
    debug('json dictionary date: ${date}');
    return date;
  }
  return 0;
}

Future<bool> fetchLatestJsonGimme5Round1() async {
  if (objectBox.isJsonGimme5Round1NotEmpty() &&
      objectBox.getJsonGimme5Round1Date() ==
          await fetchLatestJsonGimme5Round1Date()) {
    debug("no new updated JsonGimme5Round1");
    return false;
  }
  HttpAuth auth = getAuthHeader();
  final response = await http.get(
    Uri.parse("$henyoApiUrl/fetchjsongimme5round1.php"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
  );
  if (response.statusCode == 200) {
    JsonGimme5Round1 jsonGimme5Round1 = JsonGimme5Round1();
    jsonGimme5Round1.id = objectBox.isJsonGimme5Round1NotEmpty() ? 1 : 0;

    var data = jsonDecode(decryptWithSymmetricKey(response.body.trim(), auth));
    debug(data.toString());
    jsonGimme5Round1.gimme5Round1Date = data['gimme5Round1Date'];
    jsonGimme5Round1.gimme5Round1Json = data['gimme5Round1Json'];
    if (!objectBox.setJsonGimme5Round1(jsonGimme5Round1)) {
      debug('failed to save new json gimme5 round1 to db');
    }

    debug('fetchLatestJsonGimme5Round1 loaded new json gimme round1 words');

    return true;
  }
  return false;
}

Future<int> fetchLatestJsonGimme5Round1Date() async {
  HttpAuth auth = getAuthHeader();
  final response = await http.get(
    Uri.parse("$henyoApiUrl/latestjsongimme5round1date.php"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
  );
  if (response.statusCode == 200) {
    var gimme5Round1Date =
        jsonDecode(decryptWithSymmetricKey(response.body.trim(), auth));
    var date = gimme5Round1Date['gimme5Round1Date'];
    debug('json gimme5Round1 date: ${date}');
    return date;
  }
  return 0;
}

void fetchLatestJsons() {
  fetchLatestJsonWords();
  fetchLatestJsonDictionary();
  fetchLatestJsonGimme5Round1();
  fetchLatestJsonMultiplayer();
}

Future<int> fetchLatestWordsListDate() async {
  HttpAuth auth = getAuthHeader();
  final response = await http.get(
    Uri.parse("$henyoApiUrl/latestwordslistdate.php"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
  );
  if (response.statusCode == 200) {
    Map<String, dynamic> rec =
        jsonDecode(decryptWithSymmetricKey(response.body.trim(), auth));

    return rec['uploadDate'];
  }
  return 0;
}

Future<bool> fetchLatestWordsList() async {
  var categories = ['animal', 'food', 'person', 'place', 'thing'];
  var difficulty = ['e', 'm', 'h'];
  wordsIndex = 0;

  // var words = jsonDecode(await rootBundle.loadString('json/words_temp.json'));
  // var map1 = getJsonWords(categories, difficulty, words);
  // map1.forEach((key, value) {
  //   debug('$key:${value.guessword}');
  // });
  // words = jsonDecode(await rootBundle.loadString('json/henyowords_temp.json'));
  // var map2 = getJsonWords(categories, difficulty, words);
  // wordsMap = {...map1, ...map2};

  // var words = jsonDecode(await rootBundle.loadString('json/henyowords.json'));
  var words = jsonDecode(objectBox.getJsonWords());
  wordsMap = getJsonWords(categories, difficulty, words);

  // temp.forEach((key, value) {
  //   debug('$key:${value.guessWord}');
  // });
  debug('new map size: ${wordsMap.length}');
  wordsIndex = 0;
  // wordsMap = removePreviouslyUsedWords(temp, gameMode);

  return wordsMap.length > 0;

  // debug('${objectBox.getLatestWordsListDateEntry()}');
  // try {
  //   if (objectBox.isWordListEmpty() ||
  //       await fetchLatestWordsListDate() >
  //           objectBox.getLatestWordsListDateEntry()) {
  //     HenyoWords? henyoWords = await fetchWordsList2();
  //     if (henyoWords != null) {
  //       // henyoWords.id = objectBox.wordsSize();
  //       objectBox.updateWords(henyoWords);
  //       debug('words list: ${henyoWords.getWordsList()}');
  //       objectBox.storeWords(henyoWords);
  //       objectBox.updateBackupWords(henyoWords);
  //     }
  //     // if (objectBox.wordsSize() > 1) {
  //     //   henyoWords!.id = 1;
  //     // } else {
  //     //   henyoWords!.id = 0;
  //     // }

  //     return true;
  //   }
  // } catch (e) {
  //   debug('fetchLatestWordsList: ${e.toString()}');
  // }
  // return false;
}

Future<bool> getMultipleWordsList() async {
  if (await fetchLatestWordsListDate() >
      objectBox.getLatestWordsListDateEntry()) {
    MultiPlayerWords? multiplayerWords = await fetchMultiPlayerWordsList();
    objectBox.setMPWordsList(multiplayerWords!);
    return true;
  }
  return false;
}

Future<String> getServiceAccountKey() async {
  int tries = 0;
  debug('retrieving service account key');
  while (serviceAccountKey.isEmpty && tries++ < 5) {
    serviceAccountKey = await fetchServiceAccountKey();
  }
  // debug(serviceAccountKey);
  return serviceAccountKey;
}

String serviceAccountKey = '';
Future<String> fetchServiceAccountKey() async {
  HttpAuth auth = getAuthHeader();
  try {
    final response = await http.get(
      Uri.parse('$henyoApiUrl/getserviceaccountkey.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'auth2': auth.authKey,
      },
    );
    if (response.statusCode == 200) {
      return decryptWithSymmetricKey(response.body.trim(), auth);
    }
    debug('failed to retrieve service account key');
  } catch (e) {
    debug('fetchServiceAccountKey: ${e.toString()}');
  }
  return '';
}

Future<String> fetchAblyApiKey() async {
  try {
    HttpAuth auth = getAuthHeader();
    final response = await http.get(
      Uri.parse('$henyoApiUrl/getablykey.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'auth2': auth.authKey,
      },
    );
    if (response.statusCode == 200) {
      return decryptWithSymmetricKey(response.body.trim(), auth);
    }
  } catch (e) {
    debug('fetchAblyApiKey: ${e.toString()}');
  }
  return '';
}

Future<String> getAblyApiKey() async {
  String key = objectBox.getAblyApiKey();
  if (key.isEmpty) {
    key = userSettings.getAblyApiKey();
  } else {
    return key;
  }
  if (key.isNotEmpty) {
    return key;
  }
  return '';
}

void checkForNewAblyApiKey() async {
  String keyFromServer = '';
  int i = 0;
  do {
    keyFromServer = await fetchAblyApiKey();
  } while (keyFromServer.isEmpty && i++ < 5);
  if (await getAblyApiKey() != keyFromServer && keyFromServer.isNotEmpty) {
    userSettings.setAblyApiKey(keyFromServer);
    objectBox.storeUserSettings(userSettings);
  }
}

int wordsIndex = 0;
Map<String, dynamic> processJsonWords(
    String category, String difficulty, var words) {
  Map<String, dynamic> map = <String, dynamic>{};
  var json = words['$category-$difficulty'];
  if (json != null)
    for (var item in json) {
      String locale = 'en';
      WordObject? objEn;
      if (item[locale]['guessword'] != null &&
          item[locale].toString().isNotEmpty) {
        objEn = WordObject(
            guessword: item[locale]['guessword'],
            alternate: item[locale]['alternate'],
            difficulty: difficulty,
            locale: locale,
            category: category,
            associatedWords: item[locale]['associated'],
            possibleWords: item[locale]['possible']);
        debug(objEn.getGuessWord().toString());
        map.addAll({'${wordsIndex++}': objEn});
      }
      if (objEn != null) {
        locale = 'ph';
        if (item[locale]['guessword'] != null &&
            item[locale].toString().isNotEmpty) {
          List<dynamic> associatedWords = item[locale]['associated'];
          // let's add the english version of the guessword to the ph assoc words
          // plus alternate words
          associatedWords.add(objEn.getGuessWord());
          if (objEn.alternate.isNotEmpty) {
            associatedWords.addAll(objEn.alternate);
          }
          WordObject obj = WordObject(
              guessword: item[locale]['guessword'],
              alternate: item[locale]['alternate'],
              difficulty: difficulty,
              locale: locale,
              category: category,
              associatedWords: associatedWords,
              possibleWords: item[locale]['possible']);

          obj = obj.copy(objEn);
          obj.associatedWords =
              LinkedHashSet<dynamic>.from(obj.associatedWords).toList();

          debug(obj.getGuessWord().toString());
          map.addAll({'${wordsIndex++}': obj});
        }
      }
    }
  return map;
}

Map<String, dynamic> getJsonWords(var categories, var difficulty, var words) {
  var map = <String, dynamic>{};

  // wordsIndex = 0;
  for (String cat in categories) {
    for (String diff in difficulty) {
      map.addAll(processJsonWords(cat, diff, words));
    }
  }
  debug('map size: ${map.length}');
  return map;
}

Future<JsonWords> fetchJsonWords() async {
  JsonWords jsonWords = JsonWords();
  // jsonWords.setWordsJson

  return jsonWords;
}

Future<HenyoWords?> fetchWordsList2() async {
  HenyoWords? henyoWords;
  try {
    HttpAuth auth = getAuthHeader();
    final response = await http.get(
      Uri.parse('$henyoApiUrl/fetchwordslist.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        // 'auth': encryptWithServerPublicKey(getOTP(username)),
        'auth2': auth.authKey,
      },
    );
    if (response.statusCode == 200) {
      var rec = jsonDecode(decryptWithSymmetricKey(response.body.trim(), auth));
      debug(rec['wordsList']);
      henyoWords = HenyoWords(
        id: int.parse(rec['id']),
        uploadDate: rec['uploadDate'],
        wordsList: rec['wordsList'],
        dictionaryList: rec['dictionaryList'],
      );
    }
  } catch (e) {
    debug('fetchWordsList: ${e.toString()}');
  }
  return henyoWords;
}

Future<MultiPlayerWords?> fetchMultiPlayerWordsList() async {
  MultiPlayerWords? words;
  try {
    HttpAuth auth = getAuthHeader();
    final response = await http.get(
        Uri.parse('$henyoApiUrl/fetchmpwordslist.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'auth2': auth.authKey,
        });
    debug('fetchMultiPlayerWordsList: ${response.body}');
    if (response.statusCode == 200) {
      var rec = jsonDecode(decryptWithSymmetricKey(response.body.trim(), auth));
      debug(rec['multiPlayerWordsList']);
      words = MultiPlayerWords(
        id: int.parse(rec['id']),
        uploadDate: rec['uploadDate'],
        multiplayerWordsList: rec['multiPlayerWordsList'],
      );
    }
  } catch (e) {
    debug('fetchWordsList: ${e.toString()}');
  }
  return words;
}

// Future<void> refreshUserRecords() async {
//   debug('refreshing player records');
//   records = await fetchRecords();
// }

Future<void> fetchWhatsNew() async {
  HttpAuth auth = getAuthHeader();
  http.Response response = await http.get(
    Uri.parse("$henyoApiUrl/whatsnew.php"),
    headers: <String, String>{
      'auth2': auth.authKey,
    },
  );

  if (response.statusCode == 200) {
    String r = decryptWithSymmetricKey(response.body.trim(), auth);
    debug(r);
    Map<String, dynamic> resp = jsonDecode(r);
    whatsNewTimestamp = int.parse(resp['timestamp']);
    whatsNewMessage = resp['message'];
    whatsNewTitle = resp['title'];
  }
}

void showWhatsNewDialog(BuildContext context, String title, String message) {
  showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(.5),
      barrierDismissible:
          false, // disables popup to close if tapped outside popup (need a button to close)
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(.9),
          title: Text(
            title,
            style: textStyleAutoScaledByPercent(context, 14, darkTextColor),
            textScaler: defaultTextScaler(context),
          ),
          content: Text(
              style: textStyleAutoScaledByPercent(context, 12, darkTextColor),
              textScaler: defaultTextScaler(context),
              message),
          //buttons?
          actions: <Widget>[
            TextButton(
              child: Text(
                  style:
                      textStyleAutoScaledByPercent(context, 13, darkTextColor),
                  textScaler: defaultTextScaler(context),
                  "Continue"),
              onPressed: () {
                Navigator.of(context).pop();
              }, //closes popup
            ),
          ],
        );
      });
}

Future<http.Response> postUserGuess(String payload) async {
  debug(payload);
  HttpAuth auth = getAuthHeader();
  return await http.post(
    Uri.parse('$henyoApiUrl/userguess.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
    body: encryptWithSymmetricKey(payload, auth),
  );
}

Future<http.Response> postMultiPlayerGuess(String payload) async {
  debug(payload);
  HttpAuth auth = getAuthHeader();
  return await http.post(
    Uri.parse('$henyoApiUrl/multiplayerguess.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
    body: encryptWithSymmetricKey(payload, auth),
  );
}

Future<http.Response> postPartyModeGuess(String payload) async {
  debug(payload);
  HttpAuth auth = getAuthHeader();
  return await http.post(
    Uri.parse('$henyoApiUrl/partymodeguess.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
    body: encryptWithSymmetricKey(payload, auth),
  );
}

Future<http.Response> postGimme5Guess(String payload) async {
  debug(payload);
  HttpAuth auth = getAuthHeader();
  return await http.post(
    Uri.parse('$henyoApiUrl/gimme5guess.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
    body: encryptWithSymmetricKey(payload, auth),
  );
}

Future<http.Response> createNewRoom(String roomName) async {
  String payload = jsonEncode(<String, dynamic>{
    'roomName': roomName,
    'guesser': '',
    'cluegiver': '',
    'status': 'open',
  });
  HttpAuth auth = getAuthHeader();
  return await http.post(
    Uri.parse('$henyoApiUrl/createroom.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
    body: encryptWithSymmetricKey(payload, auth),
  );
}

Future<http.Response> updateRoom(MultiPlayerRoomData data) async {
  int index = getIndexByRoomName(data.roomName);
  if (index != -1) {
    data.created = DateTime.now().millisecondsSinceEpoch;
    mprdRooms[index] = data;
    bool result = sendRoomUpdate(mprdRooms);
    if (result) {
      return http.Response('Room updated successfully.', 200);
    } else {
      return http.Response('Room failed to update.', 400);
    }
  }

  String payload = jsonEncode(<String, dynamic>{
    'roomName': data.roomName,
    'guesser': data.guesser,
    'cluegiver': data.cluegiver,
    'status': data.status.name,
    'created': DateTime.now(),
  });
  HttpAuth auth = getAuthHeader();
  return await http.post(
    Uri.parse('$henyoApiUrl/updateroom.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
      // 'auth': encryptWithServerPublicKey(getOTP(username)),
      // 'user': username,
    },
    body: encryptWithSymmetricKey(payload, auth),
  );
}

RoomState convertStringToRoomState(String status) {
  switch (status) {
    case 'open':
      return RoomState.open;
    case 'ready':
      return RoomState.ready;
    case 'guesserJoined':
      return RoomState.guesserJoined;
    case 'guesserCluegiverAccepted':
      return RoomState.guesserCluegiverAccepted;
    // case 'guesserLeft':
    //   return RoomState.guesserLeft;
    // case 'cluegiverLeft':
    //   return RoomState.cluegiverLeft;
    // case 'guesserReady':
    //   return RoomState.guesserReady;
    // case 'cluegiverReady':
    //   return RoomState.cluegiverReady;
    case 'cluegiverJoined':
      return RoomState.cluegiverJoined;
    case 'cluegiverGuesserAccepted':
      return RoomState.cluegiverGuesserAccepted;
    case 'waitingForPlayers':
      return RoomState.waitingForPlayers;
  }
  return RoomState.open;
}

Future<List<MultiPlayerRoomData>> getRooms() async {
  // if (mprdRooms.isNotEmpty) {
  //   // || roomJoined == true) {
  //   return mprdRooms;
  // }
  debug('fetching rooms from server ${DateTime.now()}');
  HttpAuth auth = getAuthHeader();
  http.Response json = await http.get(
    Uri.parse("$henyoApiUrl/getrooms.php"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
  );

  List<MultiPlayerRoomData> resp = [];
  debug(json.statusCode.toString());
  if (json.statusCode == 200) {
    Map<String, dynamic> data =
        jsonDecode(decryptWithSymmetricKey(json.body.trim(), auth));
    for (int i = 0; i < data.values.elementAt(0).length; i++) {
      dynamic rec = data.values.elementAt(0).elementAt(i);
      // debug(rec['id']);
      resp.add(MultiPlayerRoomData(
        id: int.parse(rec['id']),
        roomName: rec['roomName'],
        guesser: rec['guesser'],
        cluegiver: rec['cluegiver'],
        status: convertStringToRoomState(rec['status']),
        // created: DateTime(rec['created']),
      ));
    }
  }
  return resp;
}

Future<MultiPlayerRoomData> getRoom(String roomName) async {
  // getLatestRooms();
  int index = mprdRooms.indexWhere((element) => element.roomName == roomName);
  if (index != -1) {
    return mprdRooms[index];
  }
  HttpAuth auth = getAuthHeader();
  http.Response json = await http.get(
    Uri.parse("$henyoApiUrl/getroom.php?roomName=$roomName"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
  );

  MultiPlayerRoomData mprd = MultiPlayerRoomData();
  if (json.statusCode == 200) {
    String r = decryptWithSymmetricKey(json.body.trim(), auth);
    debug(r);
    Map<String, dynamic> resp = jsonDecode(r);
    mprd.roomName = resp['roomName'];
    mprd.guesser = resp['guesser'];
    mprd.cluegiver = resp['cluegiver'];
    mprd.status = convertStringToRoomState(resp['status']);
  }
  return mprd;
}

dynamic setcustomTextScaler(BuildContext context, dynamic widget) {
  return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.0)),
      child: widget);
}

showGimme5Dialog(
    BuildContext context,
    String title,
    String message,
    String cancelText,
    String yesText,
    VoidCallback callback,
    StateSetter setState,
    bool showWagerOption) async {
  player3.playOpenPage();
  const maxScale = 1.1;
  final double toggleWidth = (sqrt(MediaQuery.of(context).size.width));
  double screenW = MediaQuery.of(context).size.width;
  final bool widerScreen = MediaQuery.of(context).size.width > 430.0;
  // ScreenScaler scaler = ScreenScaler()..init(context);

  // set up the buttons
  Widget cancelButton = Visibility(
    visible: cancelText.isNotEmpty,
    child: TextButton(
      child: Text(
          style: textStyleAutoScaledByPercent(context, 13, darkTextColor),
          textScaler: customTextScaler(context),
          cancelText),
      onPressed: () {
        Navigator.of(context).pop();
        // Navigator.of(context).pop();
        popToMainMenu(context);
      },
    ),
  );
  Widget continueButton = TextButton(
    child: Text(
        style: textStyleAutoScaledByPercent(context, 13, darkTextColor),
        textScaler: customTextScaler(context),
        yesText),
    onPressed: () {
      Navigator.of(context).pop();
      callback();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    backgroundColor: Colors.white.withOpacity(.9),
    title: Text(
      title,
      style: textStyleAutoScaledByPercent(context, 14, darkTextColor),
      textScaler: defaultTextScaler(context),
    ),
    content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(children: [
          if (showWagerOption)
            Text(
                style: textStyleAutoScaledByPercent(context, 12, darkTextColor),
                textScaler: customTextScaler(context),
                'Select wager amount'),
          if (showWagerOption)
            MediaQuery(
                data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(
                        screenW > 430 ? maxScale * 1.4 : maxScale)),
                child: ToggleWidget(
                  cornerRadius: 8.0,
                  minWidth: widerScreen ? toggleWidth * 4.8 : 70,
                  initialLabel: getDifficulty(wordDifficulty),
                  activeBgColor: appThemeColor.withOpacity(.5),
                  activeTextColor: Colors.white,
                  inactiveBgColor: customBlueColor
                      .withOpacity(.3), // Colors.grey.withOpacity(.3),
                  inactiveTextColor: appThemeColor,
                  labels: const ['10', '25', '50'],
                  onToggle: (index) {
                    debug('wager switched to: $index');
                    player3.playOpenPage();
                    setState(() {
                      switch (index) {
                        case 0:
                          gimme5Wager = 10;
                          break;
                        case 1:
                          gimme5Wager = 25;
                          break;
                        case 2:
                        default:
                          gimme5Wager = 50;
                          break;
                      }
                    });
                    setState(() {});
                  },
                )),
          const SizedBox(
            height: 5,
          ),
          Text(
              style: textStyleAutoScaledByPercent(context, 12, darkTextColor),
              textScaler: customTextScaler(context),
              message)
        ])),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  await showDialog(
    barrierColor: Colors.black.withOpacity(.5),
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showGenericAlertDialogForInfoDialog(
    BuildContext context,
    String title,
    String message,
    String cancelText,
    String yesText,
    VoidCallback callback,
    bool doPop) async {
  player3.playOpenPage();
  late StateSetter setStateTitle, setStateMessage, setStateChangeLanguage;
  // String locale = wordLocale;
  (getInfoTitle(infoLocale).listen((t) => title));
  getInfoMessage(infoLocale).listen((m) => message);

  // set up the buttons
  Widget cancelButton = Visibility(
    visible: cancelText.isNotEmpty,
    child: TextButton(
      child: Text(
          style: textStyleAutoScaledByPercent(context, 12, darkTextColor),
          textScaler: customTextScaler(context),
          cancelText),
      onPressed: () {
        Navigator.of(context).pop();
      },
    ),
  );
  Widget continueButton = TextButton(
    child: StatefulBuilder(builder: (context, setState) {
      setStateChangeLanguage = setState;
      return Text(
          style: textStyleAutoScaledByPercent(context, 12, darkTextColor),
          textScaler: customTextScaler(context),
          yesText);
    }),
    onPressed: () {
      if (doPop) {
        Navigator.of(context).pop();
      }
      // debug('testing');
      // callback();
      setStateChangeLanguage(() {
        infoLocale = infoLocale == 'ph' ? 'en' : 'ph';
        yesText = infoLocale == 'ph' ? 'View in English' : 'View in Tagalog';
        setInfoStrings(currentShowOnceValue, infoLocale);
      });
      setStateTitle(
        () {
          title = infoTitle;
        },
      );
      setStateMessage(
        () {
          message = infoMessage;
        },
      );
    },
  );

  // show the dialog
  await showDialog(
    barrierColor: Colors.black.withOpacity(.5),
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white.withOpacity(.9),
        title: StatefulBuilder(builder: (context, setState) {
          setStateTitle = setState;
          return Text(
            textScaler: defaultTextScaler(context),
            title,
            style: textStyleAutoScaledByPercent(context, 13, darkTextColor),
          );
        }),
        content: StatefulBuilder(builder: (context, setState) {
          setStateMessage = setState;
          return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Text(
                  style:
                      textStyleAutoScaledByPercent(context, 11, darkTextColor),
                  textScaler: customTextScaler(context),
                  message));
        }),
        actions: [
          cancelButton,
          // const Spacer(),
          continueButton,
        ],
      );
    },
  );
}

showGenericAlertDialogPopOption(
    BuildContext context,
    String title,
    String message,
    String cancelText,
    VoidCallback cancelCallback,
    String yesText,
    VoidCallback yesCallback,
    bool doPop,
    double verticalPosition) async {
  player3.playOpenPage();
  // set up the buttons
  Widget cancelButton = Visibility(
    visible: cancelText.isNotEmpty,
    child: TextButton(
      child: Text(
          style: textStyleAutoScaledByPercent(context, 13, darkTextColor),
          textScaler: customTextScaler(context),
          cancelText),
      onPressed: () {
        cancelCallback();
      },
    ),
  );
  Widget continueButton = TextButton(
    child: Text(
        style: textStyleAutoScaledByPercent(context, 13, darkTextColor),
        textScaler: customTextScaler(context),
        yesText),
    onPressed: () {
      if (doPop) {
        Navigator.of(context).pop();
      }
      yesCallback();
    },
  );
  // double w = MediaQuery.of(context).size.width;
  // double h = MediaQuery.of(context).size.height;
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    alignment: Alignment(0, verticalPosition),
    backgroundColor: Colors.white.withOpacity(.8),
    title: Text(
      title,
      style: textStyleAutoScaledByPercent(context, 14, darkTextColor),
      textScaler: defaultTextScaler(context),
    ),
    content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Text(
            style: textStyleAutoScaledByPercent(context, 12, darkTextColor),
            textScaler: customTextScaler(context),
            message)),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  await showDialog(
    // anchorPoint: Offset.zero,
    barrierColor: Colors.black.withOpacity(.4),
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showGenericAlertDialog(BuildContext context, String title, String message,
    String cancelText, String yesText, VoidCallback callback) async {
  showGenericAlertDialogPopOption(context, title, message, cancelText, () {
    Navigator.of(context).pop();
  }, yesText, callback, true, 0);
}

showGameSettings(
    BuildContext context,
    String title,
    String message,
    String cancelText,
    String yesText,
    VoidCallback callback,
    StateSetter setStateApp) async {
  player3.playOpenPage();
  const maxScale = 1.1;
  final double toggleWidth = (sqrt(MediaQuery.of(context).size.width));
  double screenW = MediaQuery.of(context).size.width;
  final bool widerScreen = MediaQuery.of(context).size.width > 430.0;
  ScreenScaler scaler = ScreenScaler()..init(context);
  // set up the buttons
  Widget cancelButton = Visibility(
    visible: cancelText.isNotEmpty,
    child: TextButton(
      child: Text(
          style: textStyleAutoScaledByPercent(context, 13, darkTextColor),
          textScaler: customTextScaler(context),
          cancelText),
      onPressed: () {
        Navigator.of(context).pop();
      },
    ),
  );
  Widget continueButton = TextButton(
    child: Text(
        style: textStyleAutoScaledByPercent(context, 13, darkTextColor),
        textScaler: customTextScaler(context),
        yesText),
    onPressed: () {
      // if (doPop) {
      Navigator.of(context).pop();
      // }
      callback();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    backgroundColor: Colors.white.withAlpha(230),
    // icon: Icon(Icons.settings, color: appThemeColor),
    title: Text(
      title,
      style: textStyleAutoScaledByPercent(context, 14, darkTextColor),
      textScaler: defaultTextScaler(context),
    ),
    content:
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      // setStateApp = setState;
      return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              // const Spacer(),
              Container(
                color: Colors.transparent,
                child: Text(
                    textScaler: customTextScaler(context, max: maxScale),
                    'Select Difficulty',
                    style: textStyleDark(context)),
              ),
              if (MediaQuery.of(context).size.height > 650)
                const SizedBox(
                  height: 3,
                ),
              MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(
                          screenW > 430 ? maxScale * 1.4 : maxScale)),
                  child: ToggleWidget(
                    cornerRadius: 8.0,
                    minWidth: widerScreen ? toggleWidth * 5 : screenW / 5,
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
                      setStateApp(() {});
                      userSettings.setDifficulty(wordDifficulty);
                      objectBox.storeUserSettings(userSettings);
                    },
                  )),
              const SizedBox(
                height: 10,
              ),
              Container(
                color: Colors.transparent,
                child: Text(
                    textScaler: customTextScaler(context, max: maxScale),
                    'Select Language',
                    style: textStyleDark(context)),
              ),
              const SizedBox(
                height: 3,
              ),
              MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(
                          screenW > 430 ? maxScale * 1.4 : maxScale)),
                  child: ToggleWidget(
                    minWidth: widerScreen ? toggleWidth * 9 : screenW / 4,
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
                      setState(() {
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
                        setStateApp(() {
                          if (!gimme5Start)
                            gimme5Words = getGimme5Categories(wordLocale);
                        });
                      });
                    },
                  )),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Spacer(),
                  Text(
                      textScaler: customTextScaler(context),
                      'Auto start voice entry\non game start: ',
                      style: textStyleAutoScaledByPercent(
                          context, 10, darkTextColor)),
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
              Row(
                children: [
                  const Spacer(),
                  Text(
                      textScaler: customTextScaler(context),
                      'Custom Keyboard:',
                      style: textStyleAutoScaledByPercent(
                          context, 10, darkTextColor)),
                  const SizedBox(
                    width: 5,
                  ),
                  SizedBox(
                      width: scaler.getWidth(10),
                      child: FittedBox(
                          fit: BoxFit.fill,
                          child: Switch(
                            activeColor: appThemeColor,
                            value: userSettings.getUseCustomKeyboard(),
                            onChanged: (bool value) {
                              debug(
                                  'use custom keyboard toggled. new value $value');
                              setStateApp(() {
                                setState(() {
                                  userSettings.setUseCustomKeyboard(value);
                                });
                              });
                              objectBox.storeUserSettings(userSettings);
                            },
                          ))),
                  const Spacer(),
                ],
              ),
              Row(children: [
                const Spacer(),
                Text(
                    textScaler: customTextScaler(context),
                    'Color Theme: ',
                    style: textStyleAutoScaledByPercent(
                        context, 10, darkTextColor)),
                MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: defaultTextScaler(context)),
                    child: colorThemeSelectorDropDown(
                        context, setStateApp, setState)),
                const Spacer(),
              ]),
              Row(children: [
                const Spacer(),
                Text(
                    textScaler: customTextScaler(context),
                    'Game duration: ',
                    style: textStyleAutoScaledByPercent(
                        context, 10, darkTextColor)),
                const SizedBox(
                  width: 5,
                ),
                gameDurationDropDown(context, setState, setStateApp),
                const Spacer(),
              ]),
            ],
          ));
    }),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  await showDialog(
    barrierColor: Colors.black.withOpacity(.5),
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Widget gameDurationDropDown(
    BuildContext context, StateSetter setState, StateSetter setStateApp) {
  ScreenScaler scaler = ScreenScaler()..init(context);
  double screenW = MediaQuery.of(context).size.width;
  double width = screenW / 5;
  double heightPercent = 3;
  const double fontScale = 1.1;
  const double themeOpacity = .6;
  return DropdownButton(
    // itemHeight: scaler.getHeight(6),
    dropdownColor: Colors.transparent,
    value: globalSettings.gameDuration,
    onChanged: (value) {
      setState(() {
        globalSettings.gameDuration = int.parse(value.toString());
        myDuration = Duration(minutes: globalSettings.gameDuration);
      });
      setStateApp(() {});
    },
    items: [
      DropdownMenuItem(
          value: 1,
          child: Container(
            alignment: Alignment.center,
            height: scaler.getHeight(heightPercent),
            width: width,
            color: appThemeColor.withOpacity(themeOpacity),
            child: Text(
              textScaler: customTextScaler(context),
              '1',
              style: textStyleCustomFontSizeFromContext(context, fontScale),
            ),
          )),
      DropdownMenuItem(
          value: 2,
          child: Container(
            alignment: Alignment.center,
            height: scaler.getHeight(heightPercent),
            width: width,
            color: appThemeColor.withOpacity(themeOpacity),
            child: Text(
              textScaler: customTextScaler(context),
              '2',
              style: textStyleCustomFontSizeFromContext(context, fontScale),
            ),
          )),
      DropdownMenuItem(
          value: 3,
          child: Container(
            alignment: Alignment.center,
            height: scaler.getHeight(heightPercent),
            width: width,
            color: appThemeColor.withOpacity(themeOpacity),
            child: Text(
              textScaler: customTextScaler(context),
              '3',
              style: textStyleCustomFontSizeFromContext(context, fontScale),
            ),
          ))
    ],
  );
}

Widget colorThemeSelectorDropDown(
    BuildContext context, StateSetter setStateApp, StateSetter setState) {
  ScreenScaler scaler = ScreenScaler()..init(context);
  Color selectedColor = grey;
  Color textColor = Colors.white;
  double screenW = MediaQuery.of(context).size.width;
  double width = screenW / 5;
  double heightPercent = 3;
  const double fontScale = 1;
  const double themeOpacity = .6;
  return DropdownButton(
    // itemHeight: scaler.getHeight(9),
    dropdownColor: Colors.transparent,
    value: themeColorName,
    onChanged: (value) {
      textColor = Colors.white;
      switch (value) {
        case 'Gray':
          themeColorName = 'Gray';
          selectedColor = grey;
          break;
        case 'Dark Blue':
          themeColorName = 'Dark Blue';
          selectedColor = Colors.blue.shade900;
          break;
        case 'Pink':
          themeColorName = 'Pink';
          selectedColor = Colors.pink.shade300;
          break;
        case 'Green':
          themeColorName = 'Green';
          selectedColor = Colors.green.shade700;
          break;
        case 'Red':
          themeColorName = 'Red';
          selectedColor = Colors.red.shade800;
          break;
        case 'Orange':
          themeColorName = 'Orange';
          selectedColor = Colors.orange.shade900;
          break;
        case 'Purple':
          themeColorName = 'Purple';
          selectedColor = Colors.purple.shade800;
          break;
      }
      setState(() {
        appThemeColor = selectedColor;
        constTimerColor = textColor;
        timerColor = textColor;
        inputTextColor = appThemeColor;
        // constResultColor = appThemeColor;
        // buttonTextColor = appThemeColor;
        debug('selected color: ${selectedColor.value}');
        userSettings.setColorTheme(selectedColor.value);
        objectBox.storeUserSettings(userSettings);
      });
      setStateApp(() {});
    },
    items: [
      DropdownMenuItem(
          value: 'Gray',
          child: Container(
            alignment: Alignment.center,
            height: scaler.getHeight(heightPercent),
            width: width,
            color: grey.withOpacity(.7),
            child: Text(
              textScaler: customTextScaler(context),
              'Gray',
              style: textStyleCustomFontSizeFromContext(context, fontScale),
            ),
          )),
      DropdownMenuItem(
          value: 'Dark Blue',
          child: Container(
            alignment: Alignment.center,
            height: scaler.getHeight(heightPercent),
            width: width,
            color: Colors.blue.shade900.withOpacity(themeOpacity),
            child: Text(
              textScaler: customTextScaler(context),
              'Dark Blue',
              style: textStyleCustomFontSizeFromContext(context, fontScale),
            ),
          )),
      DropdownMenuItem(
          value: 'Green',
          child: Container(
            alignment: Alignment.center,
            height: scaler.getHeight(heightPercent),
            width: width,
            color: Colors.green.shade700.withOpacity(themeOpacity),
            child: Text(
              textScaler: customTextScaler(context),
              'Green',
              style: textStyleCustomFontSizeFromContext(context, fontScale),
            ),
          )),
      DropdownMenuItem(
          value: 'Purple',
          child: Container(
            alignment: Alignment.center,
            height: scaler.getHeight(heightPercent),
            width: width,
            color: Colors.purple.shade800.withOpacity(themeOpacity),
            child: Text(
              textScaler: customTextScaler(context),
              'Purple',
              style: textStyleCustomFontSizeFromContext(context, fontScale),
            ),
          )),
      DropdownMenuItem(
          value: 'Orange',
          child: Container(
            alignment: Alignment.center,
            height: scaler.getHeight(heightPercent),
            width: width,
            color: Colors.orange.shade900.withOpacity(themeOpacity),
            child: Text(
              textScaler: customTextScaler(context),
              'Orange',
              style: textStyleCustomFontSizeFromContext(context, fontScale),
            ),
          )),
      DropdownMenuItem(
          value: 'Red',
          child: Container(
            alignment: Alignment.center,
            height: scaler.getHeight(heightPercent),
            width: width,
            color: Colors.red.shade700.withOpacity(themeOpacity),
            child: Text(
              textScaler: customTextScaler(context),
              'Red',
              style: textStyleCustomFontSizeFromContext(context, fontScale),
            ),
          )),
      DropdownMenuItem(
          value: 'Pink',
          child: Container(
            alignment: Alignment.center,
            height: scaler.getHeight(heightPercent),
            width: width,
            color: Colors.pink.shade300.withOpacity(themeOpacity),
            child: Text(
              textScaler: customTextScaler(context),
              'Pink',
              style: textStyleCustomFontSizeFromContext(context, fontScale),
            ),
          ))
    ],
  );
}

String getColorNameFromValue(int value) {
  if (value == Colors.blue.shade900.value) {
    return 'Dark Blue';
  } else if (value == Colors.pink.shade300.value) {
    return 'Pink';
  } else if (value == Colors.green.shade700.value) {
    return 'Green';
  } else if (value == Colors.red.shade800.value) {
    return 'Red';
  } else if (value == Colors.orange.shade900.value) {
    return 'Orange';
  } else if (value == Colors.purple.shade800.value) {
    return 'Purple';
  }
  return 'Gray'; // default
}

String shuffleWord(String word) {
  List<String> temp = word.split(' ');
  String text = word;
  if (temp.length > 1) {
    while (text.startsWith(word.split('')[0])) {
      text = (temp[0].split('')..shuffle()).join();
    }
    for (int i = 1; i < temp.length; i++) {
      String words = temp[i];
      while (words.startsWith(temp[i].split('')[0])) {
        words = (temp[i].split('')..shuffle()).join();
      }
      text += ' $words';
    }
  } else {
    while (text.startsWith(word.split('')[0])) {
      text = (word.split('')..shuffle()).join();
    }
  }
  return text;
}

// SpeechToText? speechToText;

// String getWordFromJson(Map<String, dynamic> data) {
//   return data.keys.first;
// }

Future wait(int seconds) async {
  await Future.delayed(Duration(seconds: seconds), () => {});
}

Future waitInMs(int milliseconds) async {
  await Future.delayed(Duration(milliseconds: milliseconds), () => {});
}

Set<String> correctGuessMessage = {
  'Tumpak!',
  'Galing ah!',
  'Korek ka diyan!',
  'Panis!',
  'Sana all!',
  'Henyo pa more!',
  'Kuha mo!',
  'Ikaw na!',
  'Sapul!',
  'Astig naman!',
  'Huwaw!',
};

Set<String> correctGuessMessageEn = {
  'You got it!',
  'Exactly!',
  'That\'s right!',
  'Easy peasy!',
  'Genius!',
  'You\'re the one!',
  'Smarty pants!',
  'Hit it on the nose!',
  'Bullseye!',
  'Wow!',
  'Booom!',
};

double calculateFontSize(String text) {
  double size = 52.0 - text.length;
  return (text.length > 30 ? size : size * .7).floorToDouble();
}

double calculateFixedFontSize(context) {
  return sqrt(MediaQuery.of(context).size.width);
}

double calculateFontSizePartyMode(context, text) {
  ScreenScaler scaler = ScreenScaler()..init(context);
  double screenW = MediaQuery.of(context).size.width;
  double fontSize = 10.0;
  do {
    fontSize = fontSize + .1;
  } while (screenW > (scaler.getTextSize(fontSize) * text.length));
  debug('calculateFontSizePartyMode font size $fontSize');
  return fontSize;
}

TextScaler mediaQueryTextScaler(BuildContext context) {
  return MediaQuery.textScalerOf(context)
      .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.2);
}

Widget lightBulbBackgroundWidget(
    BuildContext context, String title, Widget widget) {
  double height = MediaQuery.of(context).size.height;
  double width = MediaQuery.of(context).size.width;
  if (MediaQuery.of(context).orientation == Orientation.landscape) {
    height = MediaQuery.of(context).size.height * .55;
    width = MediaQuery.of(context).size.width * .55;
  }
  return Stack(children: <Widget>[
    Container(
      decoration: BoxDecoration(
        color: appBackgroundColor,
        image: const DecorationImage(
            // fit: BoxFit.fitWidth,
            scale: .2,
            opacity: .1,
            // repeat: ImageRepeat,
            alignment: Alignment.center,
            image: AssetImage('assets/lightbulb_brain.png')),
      ),
      // child: MediaQuery(
      //   data: MediaQuery.of(context).copyWith(invertColors: false),
      //   child: Center(
      //       child: Image.asset(
      //     'assets/lightbulb_brain.png',
      //     height: height,
      //     width: width,
      //     opacity: const AlwaysStoppedAnimation(.2),
      //   )),
      // ),
    )
        // .animate()
        // .moveY(begin: 0, end: 100, curve: Curves.easeOutQuad)
        .animate(onPlay: (c) => c.repeat(reverse: true), delay: 3.seconds)
        // .saturate(duration: 10.seconds)
        .shader()
        // .boxShadow(
        //   end: const BoxShadow(
        //     blurRadius: 4,
        //     color: Colors.white,
        //     spreadRadius: 5,
        //   ),
        //   curve: Curves.easeOutExpo,
        // )
        // .scaleXY(duration: 10.seconds, end: 1.1, curve: Curves.easeOutCirc),
        .shimmer(delay: 10000.ms, duration: 3000.ms, color: Colors.white),
    Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: scaffoldColor,
        appBar: GradientAppBar(
            actions: [
              Visibility(
                  visible: currentShowOnceValue != ShowOnceValues.undefined,
                  child: IconButton(
                      onPressed: () {
                        showInfoDialog(context);
                      },
                      icon: Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: (height > width) ? sqrt(height) : sqrt(width),
                        // size: scaler.getTextSize(14),
                      ))),
            ],
            centerTitle: true,
            gradient: LinearGradient(colors: [customBlueColor, appThemeColor]),
            // toolbarHeight: MediaQuery.of(context).size.height / toolbarHeight,
            // backgroundColor: appThemeColor,
            title: MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: mediaQueryTextScaler(context)),
                child: AutoSizeText(
                  title,
                  // textScaler: customTextScaler(context),
                  // // defaultTextScaler(context, max: width > 450 ? 1.1 : 1.0),
                  style: textStyleAutoScaledByPercent(
                      context, 12, buttonTextColor),
                )
                // style: TextStyle(
                //     fontSize:
                //         calculateFixedFontSize(context) * (width > 430 ? 1 : 0.8),
                //     fontWeight: FontWeight.bold,
                // color: Colors.white)),
                )),
        body: widget)
  ]);
}

String getOTP2(String secret) {
  int timestep = 5;
  int codeLength = 8;
  var hmac = Hmac(sha1, Uint8List.fromList(utf8.encode(secret)));
  int time =
      (((DateTime.now().millisecondsSinceEpoch ~/ 1000).round()) ~/ timestep)
          .floor();
  final timebytes = _int2bytes(time);
  List<int> hash = hmac.convert(timebytes).bytes;
  // debug(time.toString());
  Iterable<int> code = hash.getRange(hash.length - 4, hash.length);
  String c = '';
  for (int n in code) {
    c += n.toRadixString(16).padLeft(2, '0');
  }
  // debug('getOTP2: $c');
  int numericCode = 0;
  //
  for (int i = 0; i < (codeLength < c.length ? codeLength : c.length); i++) {
    numericCode = numericCode * 10 + int.parse(c[i], radix: 16);
  }
  // debug('numericCode otp2: $numericCode');
  return numericCode.toString();
}

String getOTPwithTime(String secret, int ts) {
  int timestep = 60;
  int codeLength = 8;
  var hmac = Hmac(sha1, Uint8List.fromList(utf8.encode(secret)));
  int time = (((ts ~/ 1000).round()) ~/ timestep).floor();
  final timebytes = _int2bytes(time);
  List<int> hash = hmac.convert(timebytes).bytes;
  // debug(hash.toString());
  Iterable<int> code = hash.getRange(hash.length - 4, hash.length);
  String c = '';
  for (int n in code) {
    c += n.toRadixString(16).padLeft(2, '0');
  }
  // debug('getOTP: $c');
  int numericCode = 0;
  //
  for (int i = 0; i < (codeLength < c.length ? codeLength : c.length); i++) {
    numericCode = numericCode * 10 + int.parse(c[i], radix: 16);
  }
  // debug('numericCode otp: $numericCode');
  return numericCode.toString();
}

Uint8List _int2bytes(int long) {
// we want to represent the input as a 8-bytes array
  final byteArray = Uint8List(8);

  for (var index = byteArray.length - 1; index >= 0; index--) {
    final byte = long & 0xff;
    byteArray[index] = byte;
    long = (long - byte) ~/ 256;
  }
  return byteArray;

// Cleaner implementation but breaks in dart2js/flutter web
// return Uint8List(8)..buffer.asByteData().setInt64(0, long);
}

String testEncrypt() {
  var plainText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';
  final key = enc.Key.fromUtf8('GrayLeopard36283');
  debug(key.base16.substring(0, 32));
  final hex = getOTP2('GrayLeopard36283');
  debug(hex);
  final iv = enc.IV.fromUtf8(hex);
  debug(iv.base16.substring(0, 16));

  final encrypter = enc.Encrypter(enc.AES(key));

  final encrypted = encrypter.encrypt(plainText, iv: iv);
  final decrypted = encrypter.decrypt(encrypted, iv: iv);

  debug(decrypted); // Lorem ipsum dolor sit amet, consectetur adipiscing elit
  debug(encrypted.base64);
  return encrypted.base64;
}

Future<String> testRSAEncrypt() async {
  var plainText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';
  final encrypter = enc.Encrypter(enc.RSA(
    publicKey: CryptoUtils.rsaPublicKeyFromPem(serverPublickKey),
    //privateKey: CryptoUtils.rsaPrivateKeyFromPem(serverPrivateKey),
  ));

  final encrypted = encrypter.encrypt(plainText);
  final decrypted = encrypter.decrypt(encrypted);
  debug(decrypted); // Lorem ipsum dolor sit amet, consectetur adipiscing elit
  debug(encrypted.base64);
  return '';
}

String generateServerAuth() {
  return encryptWithServerPublicKey(getOTP2(username));
}

String getHash(String text) {
  var bytes = utf8.encode(text);
  return sha256.convert(bytes).toString();
}

String encryptWithSymmetricKey(String text, HttpAuth auth) {
  // debug(username.hashCode.toString());
  // final key = enc.Key.fromUtf8(getHash(username));
  // // debug(key.toString());
  // henyoKey = enc.Key.fromUtf8(key.base16.toString().substring(0, 32));
  // debug(key.base16.toString().substring(0, 32));
  // final hex = getOTP2(username);
  // // debug(hex);
  // final iv = enc.IV.fromUtf8(getHash(hex));
  // henyoIV = enc.IV.fromUtf8(iv.base16.substring(0, 16));
  // debug(iv.base16.substring(0, 16));

  final encrypter = enc.Encrypter(enc.AES(auth.key!, mode: enc.AESMode.cbc));
  final encrypted = encrypter.encrypt(text, iv: auth.iv!);
  // debug(encrypted.base64);

  // String auth = jsonEncode(<String, dynamic>{
  //   'key': henyoKey!.base64,
  //   'iv': henyoIV!.base64,
  // });
  // debug(auth);
  String body = jsonEncode(<String, dynamic>{
    // 'auth': encryptWithServerPublicKey(auth),
    'payload': encrypted.base64,
  });
  // debug(body);
  return body;
}

String decryptWithSymmetricKey(String encData, HttpAuth auth) {
  final encrypter = enc.Encrypter(enc.AES(auth.key!, mode: enc.AESMode.cbc));
  return encrypter.decrypt(enc.Encrypted.fromBase64(encData), iv: auth.iv!);
}

String? generateSignature({
  required final String data,
}) {
  try {
    final parsedPrivateKey =
        enc.RSAKeyParser().parse(objectBox.getKeys().privateKey);
    if (parsedPrivateKey is RSAPrivateKey) {
      final signer = enc.Signer(
        enc.RSASigner(
          enc.RSASignDigest.SHA256,
          privateKey: parsedPrivateKey,
        ),
      );
      final signature = signer.sign(data).base64;
      return signature;
    }
  } catch (e) {
    debug('generateSignature: ${e.toString()}');
  }
  return null;
}

String encryptWithServerPublicKey(String text) {
  final encrypter = enc.Encrypter(enc.RSA(
    publicKey: CryptoUtils.rsaPublicKeyFromPem(serverPublickKey),
    // privateKey: CryptoUtils.rsaPrivateKeyFromPem(serverPrivateKey),
  ));

  final encrypted = encrypter.encrypt(text);
  // debug(encrypted.base64);
  return encrypted.base64;
}

// String encryptWithPublicKey(String text) {
//   final encrypter = enc.Encrypter(enc.RSA(
//     publicKey: CryptoUtils.rsaPublicKeyFromPem(keys.publicKey),
//     // privateKey: CryptoUtils.rsaPrivateKeyFromPem(serverPrivateKey),
//   ));

//   final encrypted = encrypter.encrypt(text);
//   debug(encrypted.base64);
//   return encrypted.base64;
// }

Future<String> decryptWithPrivateKey(String b64Encoded) async {
  final encrypter = enc.Encrypter(enc.RSA(
      publicKey: CryptoUtils.rsaPublicKeyFromPem(keys.publicKey),
      privateKey: CryptoUtils.rsaPrivateKeyFromPem(keys.privateKey)));

  final decrypted = encrypter.decrypt(enc.Encrypted.fromBase64(b64Encoded));
  // debug(decrypted);
  return decrypted;
}

HttpAuth getAuthHeader() {
  HttpAuth auth = HttpAuth();
  auth.otp = getOTP2(username);
  var tempkey = enc.Key.fromUtf8(getHash(username));
  auth.key = enc.Key.fromUtf8(tempkey.base16.toString().substring(0, 32));
  String key = auth.key!.base64;
  final hex = getOTP2(username);
  // debug(hex);
  final tempiv = enc.IV.fromUtf8(getHash(hex));
  auth.iv = enc.IV.fromUtf8(tempiv.base16.substring(0, 16));
  String iv = auth.iv!.base64;
  auth.nonce = getCustomUniqueId();
  String decKey = '${auth.otp}:$username:$key:$iv:${auth.nonce}';
  // debug(decKey);
  auth.authKey = encryptWithServerPublicKey(decKey);
  // debug(auth.authKey);
  return auth;
}

Future<void> generateKeys() async {
  if (objectBox.isKeysNotEmpty()) {
    keys = objectBox.getKeys();
    return;
  }

  final kp = await computeKeyPair(getSecureRandom());
  final publicKey =
      CryptoUtils.encodeRSAPublicKeyToPem(kp.publicKey as RSAPublicKey);
  final privateKey =
      CryptoUtils.encodeRSAPrivateKeyToPem(kp.privateKey as RSAPrivateKey);

  keys = Secure(publicKey: publicKey, privateKey: privateKey);
  keys.id = objectBox.getKeysSize();
  objectBox.storeKeys(keys);
}

AsymmetricKeyPair<PublicKey, PrivateKey> generateKeyPair(SecureRandom random) {
  int bitLength = 2048;
  final keyGen = RSAKeyGenerator()
    ..init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 5),
        random));

  return keyGen.generateKeyPair();
}

SecureRandom getSecureRandom() {
  final secureRandom = FortunaRandom();
  final seedSource = Random.secure();
  final seeds = <int>[];
  for (int i = 0; i < 32; i++) {
    seeds.add(seedSource.nextInt(255));
  }
  secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
  return secureRandom;
}

Future<AsymmetricKeyPair<PublicKey, PrivateKey>> computeKeyPair(
    SecureRandom random) async {
  return await compute(generateKeyPair, random);
}

Widget displayOfflineMessage(BuildContext context, String? message) {
  message ??=
      'Online connection required to play this game. Please ensure you\'re connected to the internet to continue. Option for offline play is being considered!';
  return Container(
    padding: const EdgeInsets.all(10.00),
    margin: const EdgeInsets.only(bottom: 10.00),
    color: Colors.red,
    child: Row(children: [
      Container(
        margin: const EdgeInsets.only(right: 6.00),
        child: const Icon(Icons.info, color: Colors.white),
      ), // icon for error message
      Expanded(
          child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Text(
            textScaler: customTextScaler(context), message, style: textStyle),
      ))
      //show error message text
    ]),
  );
}

Future<bool> testFetch(String name) async {
  try {
    // HenyoWords? henyoWords;
    // int time = DateTime.now().millisecondsSinceEpoch;
    // String clientOTP = '';

    // fetchGlobalSettings();
    // debug(jsonEncode(globals.toJson()));

    // restoreUserRecordWithCode('7bc46a791a').then((response) {
    //   debug(response.body.trim());
    // });

    http.Response? response;
    String body, b;
    int i = 0;
    do {
      body = jsonEncode(<String, dynamic>{
        'name': name,
        'time': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      });
      debug(body);
      HttpAuth auth = getAuthHeader();
      response = await http.post(
        Uri.parse('$henyoApiUrl/testfetch.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'auth2': auth.authKey,
        },
        body: encryptWithSymmetricKey(body, auth),
      );
      // if (i % 2 == 0) {
      //   fetchRecords();
      // } else {
      //   await fetchRecords();
      // }

      b = decryptWithSymmetricKey(response.body.trim(), auth);
      debug(b);
      debug('$i');
    } while (i++ < 100);

    // if (response.statusCode == 200) {
    // Map<String, dynamic> rec = jsonDecode(response.body);
    // var encWordsList = rec['encWordsList'];
    // clientOTP = getOTPwithTime(name, time);
    // debug('client otp: $clientOTP');
    // debug('server otp: ${response.body}');
    // debug(response.body);

    //     if (int.parse(clientOTP) != int.parse(response.body) ||
    //         int.parse(clientOTP) > 200000000) break;
    //     // String encKeys = rec['encKeys'];
    //     // String sIV = sha256
    //     //     .convert(utf8.encode(getOTP(name).toString()))
    //     //     .toString()
    //     //     .substring(0, 16);
    //     // final sKey =
    //     //     sha256.convert(utf8.encode(name)).toString().substring(0, 32);
    //     // var jsonKeys = jsonDecode(await decryptWithPrivateKey(encKeys));
    //     // final key = enc.Key.fromBase64(jsonKeys['key']);
    //     // final iv = enc.IV.fromBase64(jsonKeys['iv']);
    //     // final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    //     // final decrypted =
    //     //     encrypter.decrypt(enc.Encrypted.fromBase64(encWordsList), iv: iv);
    //     // rec = jsonDecode(decrypted);
    //     // debug(rec['wordsList']);
    //     // henyoWords = HenyoWords(
    //     //   id: int.parse(rec['id']),
    //     //   uploadDate: rec['uploadDate'],
    //     //   wordsList: rec['wordsList'],
    //     //   dictionaryList: rec['dictionaryList'],
    //     // );
    //     // debug(henyoWords.toString());
    //     time -= 60000;
    //   }
    //   // if (clientOTP != response.body) break;
    // } while (clientOTP.compareTo(response.body) != 0);
  } catch (e) {
    debug('testFetch: ${e.toString()}');
  }
  return true;
}

bool userExists(String name) {
  records.map((rec) {
    if (rec.name == username) {
      debug('Duplicate username found. $username Regenerating a new one. ');
      return true;
    }
  });
  return false;
}

Future<bool> loadUserData() async {
  int start = DateTime.now().millisecond;
  debug('loading user data');
  if (objectBox.getUser(1) == null || objectBox.getUser(1)!.username.isEmpty) {
    records = await fetchRecords();
    do {
      username = generateNewUsername();
    } while (userExists(username));
    user = User(
      username: username,
      alias: username,
    );
    objectBox.setUser(user);
    saveWordsHistory();
    debug('added user $username to local db');
  } else {
    user = objectBox.getUser(1)!;
    username = user.username;
    alias = user.alias;
    streak = user.streak;
    totalStreak = user.totalStreak;
    score = user.score;
    totalScore = user.totalScore;
    credits = user.credits;
    debug('finished loading user data from objectbox');
  }
  debug('done loading user data ${DateTime.now().millisecond - start}ms');

  // reset weekly score and streak if it's a new week
  var response = await isUserAndWeekNumberExists();
  if (response.body == 'false' || response.statusCode == 400) {
    score = user.score = 0;
    streak = user.streak = 0;
  }

  return true;
}

Future<void> loadUserSettings() async {
  debug('loading user settings');
  if (objectBox.getUserSettingsSize() == 0) {
    userSettings = UserSettings();
    objectBox.storeUserSettings(userSettings);
  } else {
    userSettings = objectBox.getUserSettings();
  }
  appThemeColor = Color(userSettings.getColorTheme());
  // debug(objectBox.getUserSettingsSize().toString());
  // debug(appThemeColor.toString());
  themeColorName = getColorNameFromValue(appThemeColor.value);
  wordLocale = userSettings.getLocale();
  wordDifficulty = userSettings.getDifficulty();
  switch (wordDifficulty) {
    case 'e':
      difficultyMessage = difficultyEasyMessage;
      break;
    case 'm':
      difficultyMessage = difficultyMediumMessage;
      break;
    case 'h':
      difficultyMessage = difficultyHardMessage;
      break;
  }

  if (objectBox.isShowOnceNotEmpty()) {
    debug('loading showOnce values from objectbox');
    showOnce = objectBox.getShowOnce()!;
  } else {
    debug('initializing showOnce values on objectbox');
    objectBox.setShowOnce(showOnce);
  }
}

Future<void> loadGlobalMessages() async {
  debug('loading global messages');
  try {
    globalMessages = await fetchGlobalMessages();
    objectBox.setGlobalMessages(globalMessages);
  } catch (e) {
    debug(e.toString());
    if (objectBox.isGlobalMessagesNotEmpty()) {
      globalMessages = objectBox.getGlobalMessages()!;
    }
  }
}

Future<void> loadGlobalSettings() async {
  debug('loading global messages');
  try {
    globalSettings = await fetchGlobalSettings();
    objectBox.setGlobalSettings(globalSettings);
  } catch (e) {
    debug(e.toString());
    if (objectBox.isGlobalSettingsNotEmpty()) {
      globalSettings = objectBox.getGlobalSettings()!;
    }
  }
}

void loadWordsHistory() async {
  if (objectBox.getWordsHistory() != null &&
      objectBox.getWordsHistory()!.wordsHistoryJson.isNotEmpty) {
    wordsHistory = jsonDecode(objectBox.getWordsHistory()!.wordsHistoryJson);
    usedHenyoWordsToGuess = wordsHistory['usedHenyoWordsToGuess'];
    usedGimme5Round1Questions = wordsHistory['usedGimme5Round1Questions'];
    usedHenyoMPWordsToGuess = wordsHistory['usedHenyoMPWordsToGuess'];
    usedPartyModeWords = wordsHistory['usedPartyModeWords'];
  }
}

void saveWordsHistory() async {
  wordsHistory['usedGimme5Round1Questions'] = usedGimme5Round1Questions;
  wordsHistory['usedHenyoWordsToGuess'] = usedHenyoWordsToGuess;
  wordsHistory['usedHenyoMPWordsToGuess'] = usedHenyoMPWordsToGuess;
  wordsHistory['usedPartyModeWords'] = usedPartyModeWords;
  if (!objectBox.setWordsHistory(jsonEncode(wordsHistory))) {
    debug('failed to save words history');
  }
}

dynamic getFromExtraData(String key, String extraData) {
  try {
    assert(extraData.contains(key));
    var rec = jsonDecode(extraData);
    return rec[key];
  } catch (e) {
    debug('getFromExtraData: $e');
  }
  return -1;
}

Future<void> loadUserRecord() async {
  debug('loading user record');
  getPackageInfo();
  record = await fetchUserRecord();
  if (record != null) {
    setSecureDataRecordEntry(
        'publicKey', base64.encode(utf8.encode(keys.publicKey)));
    // retrieve json content of secure data to add to it in the future
    setExtraDataRecordEntry('appVersionInstalled', '$version+$code');
    setExtraDataRecordEntry('tokens', credits);
    setExtraDataRecordEntry('deviceInfo', getOSInfo());
    if (record!.extraData.contains('totalRewardedAdClicks')) {
      totalRewardedAdClicks =
          getFromExtraData('totalRewardedAdClicks', record!.extraData);
      debug('totalRewardedAdClicks = $totalRewardedAdClicks');
    }
  } else {
    // let's create record for the user if it doesn't exist
    http.Response resp = await createUserRecord();
    if (resp.statusCode == 200) {
      record = await fetchUserRecord();
    } else {
      debug('Failed to create user record: ${resp.body.trim()}');
    }
  }
}

void setSecureDataRecordEntry(String key, dynamic value) {
  try {
    var secureData = jsonDecode(record!.secureData);
    final newEntry = <String, dynamic>{key: value};
    secureData.addEntries(newEntry.entries);
    record!.secureData = jsonEncode(secureData);
    updateUserRecord(record!).then((response) {
      if (response.statusCode != 200) {
        debug('failed to update user record with securedata: $key - $value');
      } else {
        debug('Updated user record with securedata: $key - $value');
      }
    });
  } catch (e) {
    debug('setSecureDataRecordEntry: $e');
  }
}

String getSecureDataRecordEntry(String key) {
  Map<String, dynamic> secureData = jsonDecode(record!.secureData);
  return secureData[key];
}

void setExtraDataRecordEntry(String key, dynamic value) {
  try {
    var extraData = jsonDecode(record!.extraData);
    final newEntry = <String, dynamic>{key: value};
    extraData.addEntries(newEntry.entries);
    record!.extraData = jsonEncode(extraData);
    updateUserRecord(record!).then((response) {
      if (response.statusCode != 200) {
        debug('failed to update user record with extradata: $key - $value');
      } else {
        debug('Updated user record with extradata: $key - $value');
      }
    });
  } catch (e) {
    debug('setExtraDataRecordEntry: $e');
  }
}

String getExtraDataRecordEntry(String key) {
  Map<String, dynamic> extraData = jsonDecode(record!.extraData);
  return extraData[key];
}

FittedBox fitText(BuildContext context, String text, TextStyle style) {
  return FittedBox(
      fit: BoxFit.contain,
      child: Text(textScaler: customTextScaler(context), text, style: style));
}

void getPackageInfo() async {
  packageInfo = await PackageInfo.fromPlatform();
  version = packageInfo!.version;
  code = packageInfo!.buildNumber;
}

bool sendUserResponse(String answer, String roomName, int delay) {
  // update rooms while game in progress to keep it in history
  // getRooms().then(
  //   (value) => sendRoomUpdate(value),
  // );
  debug('user response: $answer');
  // wait(delay);
  chatChannel!.publish(name: roomName, data: {
    "sender": username,
    "text": answer,
  });
  return true;
}

bool sendUserNegotiation(MultiPlayerTransaction txn) {
  String response = jsonEncode(txn.toJson());
  debug('negotiating: $response');
  chatChannel!.publish(name: txn.room, data: {
    "type": txn.transaction,
    "sender": username,
    "text": response,
  });
  return true;
}

bool sendRoomUpdate(List<MultiPlayerRoomData> rooms) {
  try {
    String json = jsonEncode(rooms);
    debug('updating rooms: $json');
    chatChannel!.publish(
      name: 'roomData',
      data: json,
    );
    return true;
  } catch (e) {
    debug('sendRoomUpdate: $e');
  }
  return false;
}

ably.PaginatedResult<ably.Message>? historyMessages;
bool getRoomsFromHistory() {
  if (chatChannel == null || gameStarted) {
    debug('getRoomsFromHistory returning false');
    return false;
  }
  try {
    debug('getting last rooms data');
    // Future.delayed(const Duration(milliseconds: 500));
    chatChannel!.history().then((msgHistory) {
      historyMessages = msgHistory;
      for (int i = 0; i < msgHistory.items.length; i++) {
        debug(msgHistory.items[i].data.toString());
        if (msgHistory.items[i].name == 'roomData') {
          final list = jsonDecode(msgHistory.items[i].data.toString());
          mprdRooms = list
              .map<MultiPlayerRoomData>(
                  (rooms) => MultiPlayerRoomData.fromJson(rooms))
              .toList();
          return true;
        }
      }
    });
  } catch (e) {
    debug('getRoomsFromHistory: $e');
  }
  return false;
}

bool checkLastTransactionStatus(String status) {
  if (historyMessages!.items.isEmpty) {
    chatChannel!.history().then((msgHistory) {
      historyMessages = msgHistory;
    });
  }
  for (int i = 0; i < historyMessages!.items.length; i++) {
    debug(historyMessages!.items[i].data.toString());
    if (historyMessages!.items[i].name == 'txnhenyou' &&
        historyMessages!.items[i].data.toString() == status) {
      return true;
    }
  }
  return false;
}

bool inCurrentWeek(int userTime) {
  int currentWeek = getWeekNumber(DateTime.now().millisecondsSinceEpoch);
  int userWeek = getWeekNumber(userTime);
  // debug('current week: $currentWeek, user week: $userWeek');
  return currentWeek == userWeek;
}

int getWeekNumber(int time) {
  if (time == 0) time = DateTime.now().millisecondsSinceEpoch;
  int divisor = time > 2000000000 ? 1000 : 1;
  return ((time / divisor) - 345600) ~/ 604800;
}

int getCurrentWeekNumber() {
  return getWeekNumber(0);
}

int getWeeklyRemainingTime() {
  return (((getCurrentWeekNumber() + 1) * 604800) + 345600) -
      (DateTime.now().millisecondsSinceEpoch ~/ 1000);
}

int calculateNextRewardTime() {
  return objectBox.getUserSettings().nextRewardTimestamp -
      DateTime.now().millisecondsSinceEpoch;
}

String strDigits(int n, int l) => n.toString().padLeft(l, '0');

setUserCredits(int newCredits) {
  credits += newCredits;
  user.setCredits(credits);
  objectBox.setUser(user);
}

deductUserCredits(int fee) {
  totalTokensUsed += fee;
  credits -= fee;
  user.setCredits(credits);
  objectBox.setUser(user);
  setExtraDataRecordEntry('totalTokensUsed', totalTokensUsed);
}

class HttpAuth {
  String authKey = '';
  String otp = '';
  enc.Key? key;
  enc.IV? iv;
  String nonce = '';
}

String wordToGuess = 'henyou';

void loadNextGuessWord() {
  try {
    WordObject ws = wordsList.selectRandomWordObject();
    while ((getDifficulty(ws.difficulty) > getDifficulty(wordDifficulty)) ||
        (getLocale() == 'en' && ws.locale != 'en')) {
      debug(
          'word selected: ${ws.guessword}; words list size: ${wordsList.getWordsListSize()}');
      ws = wordsList.selectRandomWordObject();
    }
    wordsAlternate = ws.getAlternateWords();
    wordsAssociated = ws.getAssociatedWords(dictionaryMap);
    wordsPossible = ws.getPossibleWords(dictionaryMap);
    wordToGuess = ws.getGuessWord();
    wordCategory = ws.category;
    usedHenyoWordsToGuess.add(wordToGuess);
    saveWordsHistory();
  } catch (e) {
    debug('loadNextGuessWord: $e');
  }
}

// deprecated
void loadNextGuessWordOld() {
  try {
    WordSelection ws = wordsList.selectRandomWord();
    while ((getDifficulty(ws.difficulty) > getDifficulty(wordDifficulty)) ||
        (getLocale() == 'en' && ws.locale != 'en')) {
      debug(
          'word selected: ${ws.guessWord}; words list size: ${wordsList.getWordsListSize()}');
      ws = wordsList.selectRandomWord();
    }
    wordsAssociated = ws.getAssociatedWords(dictionaryMap);
    wordsPossible = ws.getPossibleWords(dictionaryMap);
    wordToGuess = ws.getGuessWord();
    wordCategory = ws.category;
    // wordLocale = ws.locale;
    usedHenyoWordsToGuess.add(wordToGuess);
    saveWordsHistory();
  } catch (e) {
    debug('loadNextGuessWordOld: $e');
  }
}

void loadNextMPGuessWord(String userLocale) {
  try {
    MPWordSelection mpws = wordsMP.selectRandomMPWord();
    while ((getDifficulty(mpws.difficulty) > getDifficulty(wordDifficulty)) ||
        (userLocale == 'en' && mpws.locale != 'en')) {
      debug(
          'word selected: ${mpws.guessWord}; words list size: ${wordsMP.getWordsListSize()}');
      mpws = wordsMP.selectRandomMPWord();
    }
    wordToGuess = mpws.getGuessWord();

    if (gameMode == GameMode.multiPlayer) {
      usedHenyoMPWordsToGuess.add(wordToGuess);
    } else if (gameMode == GameMode.party) {
      usedPartyModeWords.add(wordToGuess);
    }
    saveWordsHistory();
  } catch (e) {
    debug('loadNextMPGuessWord: $e');
  }
}

int getDifficulty(String value) {
  switch (value) {
    case 'e':
      return 0;
    case 'm':
      return 1;
    case 'h':
      return 2;
    default:
      return 0;
  }
}

List<String> toggleDifficultyLabels() {
  if (wordLocale == 'en') return const ['Regular', 'Tough', 'Genius'];
  return const ['Sakto', 'Astig', 'Henyo'];
}

const int kAudioSampleRate = 16000;
const int kAudioNumChannels = 1;

enum VoiceEntry {
  unsubscribed,
  subscribed,
  unset,
}

List<String> cluegiverResponses = [
  'oo',
  'pwede',
  'hindi',
  'yes',
  'no',
  'close'
];
String removeCluegiverResponse(String text) {
  String val = '';
  if (text.contains(' ')) {
    for (String t in text.split(' ')) {
      if (!cluegiverResponses.contains(t.toLowerCase().trim())) {
        val += ' $t';
      }
    }
  } else {
    if (!cluegiverResponses.contains(text)) {
      return text;
    }
  }
  return val;
}

String getLocale() {
  if (gameMode == GameMode.multiPlayer) {
    return multiplayerLocale;
  } else {
    return wordLocale;
  }
}

GlobalMessages globalMessages = GlobalMessages();
Future<GlobalMessages> fetchGlobalMessages() async {
  GlobalMessages globalMessages = GlobalMessages();
  try {
    HttpAuth auth = getAuthHeader();
    final response = await http.get(
      Uri.parse('$henyoApiUrl/globalmessages.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'auth2': auth.authKey,
      },
    );
    if (response.statusCode == 200) {
      String messages = decryptWithSymmetricKey(response.body.trim(), auth);
      debug(messages);
      globalMessages = GlobalMessages.fromJson(jsonDecode(messages));
      debug('fetchGlobalMessages success');
      return globalMessages;
    }
  } catch (e) {
    debug('fetchGlobalMessages: $e}');
  }
  debug('fetchGlobalMessages failed');
  return globalMessages;
}

GlobalSettings globalSettings = GlobalSettings();
Future<GlobalSettings> fetchGlobalSettings() async {
  GlobalSettings globalSettings = GlobalSettings();
  try {
    HttpAuth auth = getAuthHeader();
    final response = await http.get(
      Uri.parse('$henyoApiUrl/globalsettings.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'auth2': auth.authKey,
      },
    );
    if (response.statusCode == 200) {
      String settings = decryptWithSymmetricKey(response.body.trim(), auth);
      globalSettings = GlobalSettings.fromJson(jsonDecode(settings));
      debug('fetchGlobalSettings success');
      return globalSettings;
    }
  } catch (e) {
    debug('fetchGlobalSettings: $e}');
  }
  debug('fetchGlobalSettings failed');
  return globalSettings;
}

ShowOnce showOnce = ShowOnce();

enum ShowOnceValues {
  undefined,
  gamePage,
  gimme5Round1,
  gimme5Round2,
  gimme5Round3,
  multiplayerPage,
  multiPlayerGuesserPage,
  multiPlayerClueGiverPage,
  partyModePage,
  leaderBoardPage,
  settingsPage,
  backupRestorePage,
}

bool setShowOnceShown(ShowOnceValues values) {
  switch (values) {
    case ShowOnceValues.gamePage:
      return showOnce.infoGamePageShown = true;
    case ShowOnceValues.gimme5Round1:
      return showOnce.infoGimme5Round1 = true;
    case ShowOnceValues.gimme5Round2:
      return showOnce.infoGimme5Round2 = true;
    case ShowOnceValues.gimme5Round3:
      return showOnce.infoGimme5Round3 = true;
    case ShowOnceValues.multiplayerPage:
      return showOnce.infoMultiPlayerPageShown = true;
    case ShowOnceValues.multiPlayerGuesserPage:
      return showOnce.infoMultiPlayerGuesserShown = true;
    case ShowOnceValues.multiPlayerClueGiverPage:
      return showOnce.infoMultiPlayerClueGiverShown = true;
    case ShowOnceValues.partyModePage:
      return showOnce.infoPartyModeShown = true;
    case ShowOnceValues.backupRestorePage:
      return showOnce.infoBackupRestoreShown = true;
    case ShowOnceValues.leaderBoardPage:
      return showOnce.infoLeaderBoardShown = true;
    case ShowOnceValues.settingsPage:
      return showOnce.infoSettingsPageShown = true;
    case ShowOnceValues.undefined:
    default:
      return false;
  }
}

ShowOnceValues setInfoStrings(ShowOnceValues values, String locale) {
  if (locale == 'ph') {
    switch (values) {
      case ShowOnceValues.gamePage:
        infoTitle = globalMessages.infoGamePageTitlePH;
        infoMessage = globalMessages.infoGamePageMessagePH;
        break;
      case ShowOnceValues.gimme5Round1:
        infoTitle = globalMessages.infoGimme5Round1TitlePH;
        infoMessage = globalMessages.infoGimme5Round1MessagePH;
        break;
      case ShowOnceValues.gimme5Round2:
        infoTitle = globalMessages.infoGimme5Round2TitlePH;
        infoMessage = globalMessages.infoGimme5Round2MessagePH;
        break;
      case ShowOnceValues.gimme5Round3:
        infoTitle = globalMessages.infoGimme5Round3TitlePH;
        infoMessage = globalMessages.infoGimme5Round3MessagePH;
        break;
      case ShowOnceValues.multiplayerPage:
        infoTitle = globalMessages.infoMultiPlayerPageTitlePH;
        infoMessage = globalMessages.infoMultiPlayerPageMessagePH;
        break;
      case ShowOnceValues.multiPlayerGuesserPage:
        infoTitle = globalMessages.infoMultiPlayerGuesserPageTitlePH;
        infoMessage = globalMessages.infoMultiPlayerGuesserPageMessagePH;
        break;
      case ShowOnceValues.multiPlayerClueGiverPage:
        infoTitle = globalMessages.infoMultiPlayerClueGiverTitlePH;
        infoMessage = globalMessages.infoMultiPlayerClueGiverMessagePH;
        break;
      case ShowOnceValues.partyModePage:
        infoTitle = globalMessages.infoPartyModeTitlePH;
        infoMessage = globalMessages.infoPartyModeMessagePH;
        break;
      case ShowOnceValues.backupRestorePage:
        infoTitle = globalMessages.infoBackupRestoreTitlePH;
        infoMessage = globalMessages.infoBackupRestoreMessagePH;
        break;
      case ShowOnceValues.leaderBoardPage:
        infoTitle = globalMessages.infoLeaderBoardTitlePH;
        infoMessage = globalMessages.infoLeaderBoardMessagePH;
        break;
      case ShowOnceValues.settingsPage:
        infoTitle = globalMessages.infoSettingsPageTitlePH;
        infoMessage = globalMessages.infoSettingsPageMessagePH;
        break;
      case ShowOnceValues.undefined:
      default:
        break;
    }
  } else {
    switch (values) {
      case ShowOnceValues.gamePage:
        infoTitle = globalMessages.infoGamePageTitleEN;
        infoMessage = globalMessages.infoGamePageMessageEN;
        break;
      case ShowOnceValues.gimme5Round1:
        infoTitle = globalMessages.infoGimme5Round1TitleEN;
        infoMessage = globalMessages.infoGimme5Round1MessageEN;
        break;
      case ShowOnceValues.gimme5Round2:
        infoTitle = globalMessages.infoGimme5Round2TitleEN;
        infoMessage = globalMessages.infoGimme5Round2MessageEN;
        break;
      case ShowOnceValues.gimme5Round3:
        infoTitle = globalMessages.infoGimme5Round3TitleEN;
        infoMessage = globalMessages.infoGimme5Round3MessageEN;
        break;
      case ShowOnceValues.multiplayerPage:
        infoTitle = globalMessages.infoMultiPlayerPageTitleEN;
        infoMessage = globalMessages.infoMultiPlayerPageMessageEN;
        break;
      case ShowOnceValues.multiPlayerGuesserPage:
        infoTitle = globalMessages.infoMultiPlayerGuesserPageTitleEN;
        infoMessage = globalMessages.infoMultiPlayerGuesserPageMessageEN;
        break;
      case ShowOnceValues.multiPlayerClueGiverPage:
        infoTitle = globalMessages.infoMultiPlayerClueGiverTitleEN;
        infoMessage = globalMessages.infoMultiPlayerClueGiverMessgaeEN;
        break;
      case ShowOnceValues.partyModePage:
        infoTitle = globalMessages.infoPartyModeTitleEN;
        infoMessage = globalMessages.infoPartyModeMessageEN;
        break;
      case ShowOnceValues.backupRestorePage:
        infoTitle = globalMessages.infoBackupRestoreTitleEN;
        infoMessage = globalMessages.infoBackupRestoreMessageEN;
        break;
      case ShowOnceValues.leaderBoardPage:
        infoTitle = globalMessages.infoLeaderBoardTitleEN;
        infoMessage = globalMessages.infoLeaderBoardMessageEN;
        break;
      case ShowOnceValues.settingsPage:
        infoTitle = globalMessages.infoSettingsPageTitleEN;
        infoMessage = globalMessages.infoSettingsPageMessageEN;
        break;
      case ShowOnceValues.undefined:
      default:
        break;
    }
  }
  return values;
}

ShowOnceValues currentShowOnceValue = ShowOnceValues.undefined;
String infoLocale = wordLocale;
void showInfoDialog(BuildContext context) {
  showGenericAlertDialogForInfoDialog(context, infoTitle, infoMessage, 'Close',
      infoLocale == 'ph' ? 'View in English' : 'View in Tagalog', () {
    // setInfoStrings(currentShowOnceValue, wordLocale == 'ph' ? 'en' : 'ph');
  }, false);
}

Stream<String> getInfoTitle(String locale) async* {
  setInfoStrings(currentShowOnceValue, locale);
  yield infoTitle;
}

Stream<String> getInfoMessage(String locale) async* {
  setInfoStrings(currentShowOnceValue, locale);
  yield infoMessage;
}

// Future<String> getDeviceID() async {
//   final flutterDeviceIdPlugin = FlutterDeviceId();
//   var id = await flutterDeviceIdPlugin.getDeviceId();
//   return id!;
// }

void resetInfoData() {
  infoTitle = '';
  infoMessage = '';
  currentShowOnceValue = ShowOnceValues.undefined;
}

Stream<int> monitorTokenCount() async* {
  yield credits;
}

// Widget showConfetti() {
//   return Lottie.asset('assets/confetti.json', controller: controller,
//       onLoaded: (composition) {
//     controller
//       ..duration = composition.duration
//       ..forward();
//   });
// }

Size getSizeOfText(String text, TextStyle style) {
  TextPainter textPainter = TextPainter()
    ..text = TextSpan(text: text, style: style)
    ..textDirection = TextDirection.ltr
    ..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}

Widget autoSizeText(
    BuildContext context, String text, double maxFontSize, Color color) {
  return AutoSizeText(text,
      style: textStyleAutoScaledByPercent(
          context,
          getSizeOfText(text,
                  textStyleAutoScaledByPercent(context, maxFontSize, color))
              .height,
          color));
}

Future<String> vertexAI(String prompt, String content) async {
  final vertexAi = VertexAIGenAIClient(
    httpClient: await _getAuthHttpClient(),
    project: _getProjectId(),
    location: wordLocale == 'ph'
        ? globalSettings.GoogleApiServerAsia
        : globalSettings.GoogleApiServerUS,
  );
  // var prompt =
  //     "You're an english and tagalog dictionary and wikipedia expert. I’ll give you two words separated by colon(:) like 'subject1:subject2' and you'll tell me if subject2 directly describes, similar, belongs, part of, close to or relates to subject1 by answering yes, close or no. Words to be compared will be in english and/or tagalog. NO EXPLANATION NEEDED!";
  final res = await vertexAi.chat.predict(
      context: prompt,
      messages: [VertexAITextChatModelMessage(content: content)]
      // model: 'llama3.1',
      // parameters: VertexAITextModelRequestParams(),
      );
  String aiResponse = res.predictions.first.candidates.last.content;
  debug('vertexAI response: $aiResponse');
  return aiResponse;
}

Future<AuthClient> _getAuthHttpClient() async {
  final serviceAccountCredentials = ServiceAccountCredentials.fromJson(
    json.decode(await getServiceAccountKey()),
  );
  return clientViaServiceAccount(
    serviceAccountCredentials,
    [VertexAIGenAIClient.cloudPlatformScope],
  );
}

String _getProjectId() {
  return globalSettings.GoogleProjectID;
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

List<dynamic> usedGimme5Round1Questions = [];
List<dynamic> usedHenyoWordsToGuess = [];
List<dynamic> usedHenyoMPWordsToGuess = [];
List<dynamic> usedPartyModeWords = [];
Map<String, dynamic> wordsHistory = {};

Map<String, dynamic> removePreviouslyUsedWords(
    Map<String, dynamic> map, GameMode gameMode) {
  try {
    wordsHistory = jsonDecode(objectBox.getWordsHistory()!.wordsHistoryJson);
  } catch (e) {
    debug('removePreviouslyUsedWords: $e');
    return map;
  }

  if (wordsHistory.isEmpty) return map;
  var listRemoveKeys = [];

  switch (gameMode) {
    case GameMode.solo:
    case GameMode.gimme5Round2:
    case GameMode.gimme5Round3:
      if (wordsHistory.keys.contains('usedHenyoWordsToGuess')) {
        usedHenyoWordsToGuess = wordsHistory['usedHenyoWordsToGuess'];
        // if (map.containsKey(word)) {
        //   map.remove(word);
        // }
        map.forEach((key, value) {
          if (value.guessword != null &&
              usedHenyoWordsToGuess.contains(value.guessword)) {
            // map.remove(key);
            listRemoveKeys.add(key);
          }
        });

        listRemoveKeys.forEach((key) => map.remove(key));

        if (map.isEmpty) {
          map = wordsMap;
          usedHenyoWordsToGuess = [];
        }
      }
      break;
    case GameMode.multiPlayer:
      if (wordsHistory.keys.contains('usedHenyoMPWordsToGuess')) {
        usedHenyoMPWordsToGuess = wordsHistory['usedHenyoMPWordsToGuess'];
        for (String word in usedHenyoMPWordsToGuess) {
          if (map.containsKey(word)) {
            map.remove(word);
          }
        }
        if (map.isEmpty) {
          map = multiplayerWordsMap;
          usedHenyoMPWordsToGuess = [];
        }
      }
      break;
    case GameMode.gimme5Round1:
      if (wordsHistory.keys.contains('usedGimme5Round1Questions')) {
        usedGimme5Round1Questions = wordsHistory['usedGimme5Round1Questions'];
        var it = map.values.iterator;
        List<dynamic> temp = [];
        while (it.moveNext()) {
          for (var n in it.current) {
            debug(n['question']);
            if (!usedGimme5Round1Questions
                .contains(n['question'].toString().toLowerCase())) {
              temp.add(n);
            }
          }
        }
        if (temp.isEmpty) {
          usedGimme5Round1Questions = [];
          return map;
        } else {
          return {map.keys.first: temp};
        }
      }
      break;
    case GameMode.party:
      if (wordsHistory.keys.contains('usedPartyModeWords')) {
        usedPartyModeWords = wordsHistory['usedPartyModeWords'];
        for (String word in usedPartyModeWords) {
          if (map.containsKey(word)) {
            map.remove(word);
          }
        }
        if (map.isEmpty) {
          map = multiplayerWordsMap;
          usedPartyModeWords = [];
        }
      }
      break;
    case GameMode.unset:
      assert(true); // should not get here
      break;
  }

  return map;
}

String getCustomUniqueId() {
  String pushChars = username +
      '-ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz0123456789';
  int lastPushTime = 0;
  List lastRandChars = [];
  int now = DateTime.now().millisecondsSinceEpoch;
  bool duplicateTime = (now == lastPushTime);
  lastPushTime = now;
  List timeStampChars = List<String>.filled(8, '0');
  for (int i = 7; i >= 0; i--) {
    timeStampChars[i] = pushChars[now % 64];
    now = (now / 64).floor();
  }
  if (now != 0) {
    print("Id should be unique");
  }
  String uniqueId = timeStampChars.join('');
  if (!duplicateTime) {
    for (int i = 0; i < 12; i++) {
      lastRandChars.add((Random().nextDouble() * 64).floor());
    }
  } else {
    int i = 0;
    for (int i = 11; i >= 0 && lastRandChars[i] == 63; i--) {
      lastRandChars[i] = 0;
    }
    lastRandChars[i]++;
  }
  for (int i = 0; i < 12; i++) {
    uniqueId += pushChars[lastRandChars[i]];
  }
  return uniqueId;
}

Future<void> fetchGimme5Round1Words({bool dateonly = false}) async {
  HttpAuth auth = getAuthHeader();
  String endpoint = '/getgimme5round1words.php';
  if (dateonly) {
    endpoint += '?date';
  }
  http.Response response = await http.get(
    Uri.parse("$henyoApiUrl$endpoint"),
    headers: <String, String>{
      'auth2': auth.authKey,
    },
  );

  if (response.statusCode == 200) {
    debug(response.body.trim());
    String r = decryptWithSymmetricKey(response.body.trim(), auth);
    debug(r);
    Map<String, dynamic> resp = jsonDecode(r);
    // var time = int.parse(resp['uploadDate']);
    debug(resp['uploadDate']);
    if (!dateonly) {
      var words = resp['gimme5Round1Words'];
      debug(words);
    }
  }
}

Future<http.Response> postGimme5Round1Guess(String payload) async {
  debug(payload);
  HttpAuth auth = getAuthHeader();
  return await http.post(
    Uri.parse('$henyoApiUrl/userguess.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'auth2': auth.authKey,
    },
    body: encryptWithSymmetricKey(payload, auth),
  );
}

popToMainMenu(BuildContext context) {
  Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (BuildContext context) => LandingPage()),
      (Route<dynamic> route) => route is LandingPage);
}
