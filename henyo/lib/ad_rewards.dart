import 'countdown_timer.dart';
import 'package:flutter/material.dart';
import 'helper.dart';

/// A simple class that displays an alert prompt prior to showing an ad.
class AdWaitForReward extends StatefulWidget {
  const AdWaitForReward({
    super.key,
  });

  @override
  AdDialogState createState() => AdDialogState();
}

class AdDialogState extends State<AdWaitForReward> {
  final CountdownTimer _countdownTimer = CountdownTimer();

  @override
  void initState() {
    _countdownTimer
        .setCountdownTimeInSeconds(calculateNextRewardTime() ~/ 1000);
    _countdownTimer.addListener(() => setState(() {
          if (_countdownTimer.isComplete) {
            Navigator.pop(context);
          }
        }));
    _countdownTimer.start();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Duration timeLeftReward =
        Duration(seconds: calculateNextRewardTime() ~/ 1000);
    final mins = strDigits(timeLeftReward.inMinutes.remainder(60), 1);
    final secs = strDigits(timeLeftReward.inSeconds.remainder(60), 2);
    return AlertDialog(
        backgroundColor: Colors.white.withOpacity(.9),
        title: Text(
          'Reward not available yet!',
          style: textStyleAutoScaledByPercent(context, 14, darkTextColor),
          textScaler: defaultTextScaler(context),
        ),
        content: Text(
            style: textStyleAutoScaledByPercent(context, 12, darkTextColor),
            textScaler: defaultTextScaler(context),
            'Reward will become available in ${mins}m:${secs}s'),
        actions: <Widget>[
          TextButton(
              onPressed: () {
                player3.playBackspaceSound();
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: textStyleAutoScaledByPercent(context, 13, darkTextColor),
                textScaler: defaultTextScaler(context),
              )),
        ]);
  }

  @override
  void dispose() {
    super.dispose();
    _countdownTimer.dispose();
  }
}
