import 'package:HenyoU/debug.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

class SoundPlayer {
  AudioPlayer player = AudioPlayer();
  bool playerIsInitialized = false;

  void playStartGameSound() async {
    await player.setAsset('assets/StartGame.mp3');
    HapticFeedback.mediumImpact();
    player.play();
  }

  void playNoSound(String locale) async {
    if (locale == 'ph') {
      await player.setAsset('assets/male-hindi.mp3');
    } else {
      await player.setAsset('assets/female-no.mp3');
    }
    // player.setVolume(5.0);
    player.play();
  }

  void playMaybeSound(String locale) async {
    if (locale == 'ph') {
      await player.setAsset('assets/male-pwede.mp3');
    } else {
      await player.setAsset('assets/female-close.mp3');
    }
    // player.setVolume(5.0);
    player.play();
  }

  void playYesSound(String locale) async {
    if (locale == 'ph') {
      await player.setAsset('assets/male-oo.mp3');
    } else {
      await player.setAsset('assets/female-yes.mp3');
    }
    // player.setVolume(5.0);
    player.play();
  }

  void playRightAnswerSound() async {
    try {
      await player.setAsset('assets/RightAnswer.mp3');
      HapticFeedback.heavyImpact();
      player.play();
    } catch (e) {
      debug(e.toString());
    }
  }

  void playRightAnswerSoundGimme5() async {
    try {
      await player.setAsset('assets/Yes.mp3');
      HapticFeedback.lightImpact();
      player.play();
      HapticFeedback.lightImpact();
    } catch (e) {
      debug(e.toString());
    }
  }

  void playWrongAnswerSoundGimme5() async {
    try {
      await player.setAsset('assets/No.mp3');
      player.play();
    } catch (e) {
      debug(e.toString());
    }
  }

  void playTimerRanOutSound() async {
    try {
      await player.setAsset('assets/TimerRanOut.mp3');
      HapticFeedback.mediumImpact();
      player.play();
    } catch (e) {
      debug(e.toString());
    }
  }

  void playTimerRunningOutSound() async {
    try {
      await player.setAsset('assets/TimeRunningOut1.mp3');
      HapticFeedback.lightImpact();
      player.play();
    } catch (e) {
      debug(e.toString());
    }
  }

  void playBackspaceSound() async {
    await player.setAsset('assets/Backspace.mp3');
    player.play();
  }

  void playGimme5Sound() async {
    await player.setAsset('assets/Maybe.mp3');
    player.play();
  }

  void playClapSmallCrowd() async {
    try {
      await player.setAsset('assets/ClapSmallCrowd.mp3');
      HapticFeedback.heavyImpact();
      player.play();
    } catch (e) {
      debug(e.toString());
    }
  }

  void playClapBigCrowd() async {
    try {
      await player.setAsset('assets/ClapBigCrowd.mp3');
      HapticFeedback.heavyImpact();
      player.play();
    } catch (e) {
      debug(e.toString());
    }
  }

  void playIncomingMessage() async {
    try {
      await player.setAsset('assets/IncomingMessage.mp3');
      HapticFeedback.lightImpact();
      player.play();
    } catch (e) {
      debug(e.toString());
    }
  }

  void playOpenPage() {
    playTimerRunningOutSound();
    HapticFeedback.lightImpact();
  }

  void playGoBackSound() {
    playBackspaceSound();
    HapticFeedback.lightImpact();
  }

  void stop() {
    player.stop();
  }

  void close() {
    player.dispose();
  }
}
