// ignore_for_file: no_leading_underscores_for_local_identifiers, non_constant_identifier_names, prefer_const_constructors

import 'dart:io';

import 'package:HenyoU/helper.dart';
import 'package:HenyoU/soundplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';

import 'language.dart';

class BuiltInKeyboard extends StatefulWidget {
  // Language of the keyboard
  final Language language;

  // layout of the keyboard
  final Layout layout;

  // The controller connected to the InputField
  final TextEditingController? controller;

  // Vertical spacing between key rows
  final double spacing;

  // Border radius of the keys
  final BorderRadius? borderRadius;

  // Color of the keys
  final Color color;

  // TextStyle of the letters in the keys (fontsize, fontface)
  final TextStyle letterStyle;

  // the additional key that can be added to the keyboard
  final bool enableSpaceBar;
  final bool enableBackSpace;
  final bool enableCapsLock;

  // height and width of each key
  final double? height;
  final double? width;

  // Additional functionality for the keys //

  // Makes the keyboard uppercase
  final bool enableAllUppercase;

  // Long press to write uppercase letters
  final bool enableLongPressUppercase;

  // The color displayed when the key is pressed
  final Color? highlightColor;
  final Color? splashColor;

  const BuiltInKeyboard({
    super.key,
    @required this.controller,
    this.language = Language.EN,
    this.layout = Layout.QWERTY,
    this.height,
    this.width,
    this.spacing = 8.0,
    this.borderRadius,
    this.color = Colors.deepOrange,
    this.letterStyle = const TextStyle(fontSize: 25, color: Colors.black),
    this.enableSpaceBar = false,
    this.enableBackSpace = true,
    this.enableCapsLock = false,
    this.enableAllUppercase = false,
    this.enableLongPressUppercase = false,
    this.highlightColor,
    this.splashColor,
  });
  @override
  BuiltInKeyboardState createState() => BuiltInKeyboardState();
}

class BuiltInKeyboardState extends State<BuiltInKeyboard> {
  double? height;
  double? width;
  bool capsLockUppercase = false;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    height = screenHeight > 800 ? screenHeight * 0.059 : screenHeight * 0.07;
    width = screenWidth > 350 ? screenWidth * 0.084 : screenWidth * 0.082;
    List<Widget> keyboardLayout = layout();
    double hspacing;
    int topLen, midLen;
    try {
      hspacing = double.parse(languageConfig[widget.language]![widget.layout]![
          'horizontalSpacing']!);
      topLen = int.parse(
          languageConfig[widget.language]![widget.layout]!['topLength']!);
      midLen = int.parse(
          languageConfig[widget.language]![widget.layout]!['middleLength']!);
    } catch (_CastError) {
      printError(
          "Uknown language or layout was used, or Incorrect combination of language-layout");
      exit(0);
    }
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: hspacing,
          runSpacing: 5,
          children: keyboardLayout.sublist(0, topLen),
        ),
        SizedBox(
          height: widget.spacing,
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: hspacing,
          runSpacing: 5,
          children: keyboardLayout.sublist(topLen, topLen + midLen),
        ),
        SizedBox(
          height: widget.spacing,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            widget.enableCapsLock
                ? capsLock()
                : SizedBox(
                    width: (widget.width ?? width)! + 20,
                  ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: hspacing,
              runSpacing: 5,
              children: keyboardLayout.sublist(topLen + midLen),
            ),
            widget.enableBackSpace
                ? backSpace()
                : SizedBox(
                    width: (widget.width ?? width)! + 20,
                  ),
          ],
        ),
        widget.enableSpaceBar
            ? Column(
                children: [
                  SizedBox(
                    height: widget.spacing,
                  ),
                  spaceBar(),
                ],
              )
            : SizedBox(),
      ],
    );
  }

  // Letter button widget
  Widget buttonLetter(String letter) {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(0),
      child: SizedBox(
        height: widget.height ?? height,
        width: widget.width ?? width,
        child: Material(
          type: MaterialType.button,
          color: widget.color,
          child: InkWell(
            highlightColor: widget.highlightColor,
            splashColor: widget.splashColor,
            splashFactory: InkRipple.splashFactory,
            onTap: () {
              setState(() {
                widget.controller?.text += letter;
              });
              // widget.controller?.selection = TextSelection.fromPosition(
              //     TextPosition(offset: widget.controller!.text.length));
              HapticFeedback.lightImpact();
            },
            onLongPress: () {
              if (widget.enableLongPressUppercase &&
                  !widget.enableAllUppercase) {
                widget.controller?.text += letter.toUpperCase();
                widget.controller?.selection = TextSelection.fromPosition(
                    TextPosition(offset: widget.controller!.text.length));
              }
            },
            child: Center(
              child: Text(
                textScaler: customTextScaler(context),
                letter,
                style: widget.letterStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Spacebar button widget
  Widget spaceBar() {
    ScreenScaler scaler = ScreenScaler()..init(context);
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(0),
      child: SizedBox(
        height: widget.height ?? height,
        width: (widget.width ?? width)! + scaler.getWidth(50),
        child: Material(
          type: MaterialType.button,
          color: widget.color,
          child: InkWell(
            highlightColor: widget.highlightColor,
            splashColor: widget.splashColor,
            onTap: () {
              widget.controller?.text += ' ';
              // widget.controller?.selection = TextSelection.fromPosition(
              //     TextPosition(offset: widget.controller!.text.length));
              HapticFeedback.lightImpact();
            },
            child: Center(
              child: Text(
                textScaler: defaultTextScaler(context),
                '_________',
                style: TextStyle(
                  fontSize: widget.letterStyle.fontSize,
                  color: widget.letterStyle.color,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  SoundPlayer player = SoundPlayer();
  // Backspace button widget
  Widget backSpace() {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(0),
      child: SizedBox(
        height: widget.height ?? height,
        width: (widget.width ?? width)! + 20,
        child: Material(
          type: MaterialType.button,
          color: widget.color,
          child: InkWell(
            highlightColor: widget.highlightColor,
            splashColor: widget.splashColor,
            onTap: () {
              if (widget.controller!.text.isNotEmpty) {
                widget.controller?.text = widget.controller!.text
                    .substring(0, widget.controller!.text.length - 1);
                // widget.controller?.selection = TextSelection.fromPosition(
                //     TextPosition(offset: widget.controller!.text.length));
                player.playBackspaceSound();
              }
              HapticFeedback.lightImpact();
            },
            onLongPress: () {
              if (widget.controller!.text.isNotEmpty) {
                widget.controller?.text = '';
                widget.controller?.selection = TextSelection.fromPosition(
                    TextPosition(offset: widget.controller!.text.length));
              }
            },
            child: Center(
              child: Icon(
                Icons.backspace,
                size: widget.letterStyle.fontSize!,
                color: widget.letterStyle.color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Capslock button widget
  Widget capsLock() {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(0),
      child: SizedBox(
        height: widget.height ?? height,
        width: (widget.width ?? width)! + 20,
        child: Material(
          type: MaterialType.button,
          color: widget.color,
          child: InkWell(
            highlightColor: widget.highlightColor,
            splashColor: widget.splashColor,
            onTap: () {
              setState(() {
                capsLockUppercase = !capsLockUppercase;
              });
              HapticFeedback.lightImpact();
            },
            child: Center(
              child: Icon(
                Icons.keyboard_capslock,
                size: widget.letterStyle.fontSize,
                color: widget.letterStyle.color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Keyboard layout list
  List<Widget> layout() {
    List<String> letters = [];
    try {
      letters =
          languageConfig[widget.language]![widget.layout]!['layout']!.split("");
    } catch (_CastError) {
      printError(
          "Uknown language or layout was used, or Incorrect combination of language-layout");
      exit(0);
    }

    List<Widget> keyboard = [];
    for (var letter in letters) {
      keyboard.add(
        buttonLetter(letter),
      );
    }
    return keyboard;
  }
}

void printError(String text) {
  debugPrint('\x1B[31m$text\x1B[0m');
}
