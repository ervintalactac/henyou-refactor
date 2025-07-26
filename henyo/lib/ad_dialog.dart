import 'countdown_timer.dart';
import 'package:flutter/material.dart';
import 'helper.dart';

/// A simple class that displays an alert prompt prior to showing an ad.
class AdDialog extends StatefulWidget {
  final VoidCallback showAd;
  final bool earnReward;

  const AdDialog({
    super.key,
    required this.showAd,
    required this.earnReward,
  });

  @override
  AdDialogState createState() => AdDialogState();
}

class AdDialogState extends State<AdDialog> {
  final CountdownTimer _countdownTimer = CountdownTimer();

  @override
  void initState() {
    _countdownTimer.setCountdownTimeInSeconds(10);
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
    String earn = widget.earnReward ? 'earn' : 'keep';
    // _countdownTimer.setCountdownTimeInSeconds(10);
    return AlertDialog(
      backgroundColor: Colors.white.withOpacity(.9),
      title: Text(
        'Watch an ad to $earn ${globalSettings.rewardedAdAmount} tokens?',
        style: textStyleAutoScaledByPercent(context, 14, darkTextColor),
        textScaler: defaultTextScaler(context),
      ),
      content: Text(
          'Video will be skipped in ${_countdownTimer.timeLeft} seconds...',
          style: textStyleAutoScaledByPercent(context, 12, darkTextColor),
          textScaler: defaultTextScaler(context)),
      actions: <Widget>[
        TextButton(
            onPressed: () {
              _countdownTimer.stop();
              Navigator.pop(context);
            },
            child: Text(
              'No thanks',
              style: textStyleAutoScaledByPercent(context, 13, darkTextColor),
              textScaler: defaultTextScaler(context),
            )),
        TextButton(
            onPressed: () {
              userSettings.nextRewardTimestamp =
                  DateTime.now().millisecondsSinceEpoch +
                      globalSettings.rewardedAdNextAvailableInMs;
              objectBox.storeUserSettings(userSettings);
              _countdownTimer.stop();
              Navigator.pop(context);
              widget.showAd();
            },
            child: Text(
              'Yes please',
              style: textStyleAutoScaledByPercent(context, 13, darkTextColor),
              textScaler: defaultTextScaler(context),
            )),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _countdownTimer.dispose();
  }
}
