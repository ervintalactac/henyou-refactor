// ignore: unused_import
import 'dart:math';

import 'package:HenyoU/soundplayer.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'ad_helper.dart';
import 'debug.dart';
import 'entities.dart';
import 'helper.dart';
import 'toggle.dart';

// List<Record>? records;

class LeaderBoardPage extends StatefulWidget {
  const LeaderBoardPage({super.key});

  @override
  LeaderBoard createState() => LeaderBoard();
}

class LeaderBoard extends State<LeaderBoardPage> {
  BannerAd? _bannerAd;
  List<Record>? recs;
  int rankNumber = 0;
  int rankWeekly = 0;
  double? widthColumn1;
  double? widthColumn3;
  TextStyle? textStyleLB;
  Rankings ranking = Rankings.globalRankings;

  @override
  void initState() {
    currentShowOnceValue =
        setInfoStrings(ShowOnceValues.leaderBoardPage, infoLocale);
    updateRecordFromUser(user);
    getWeeklyUserRecords();

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
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!showOnce.infoLeaderBoardShown) {
        showInfoDialog(context);
        showOnce.infoLeaderBoardShown = true;
        objectBox.setShowOnce(showOnce);
      }
    });
  }

  @override
  void dispose() {
    SoundPlayer().playBackspaceSound();
    resetInfoData();
    super.dispose();
    recs?.clear();
  }

  Future<List<Record>> getRecords() async {
    rankNumber = await getIndexFromRecords(username, records);
    if (ranking == Rankings.globalRankings) {
      return await fetchRecords();
    } else {
      return await getWeeklyUserRecords();
    }
  }

  Future<List<Record>> getWeeklyUserRecords() async {
    List<WeeklyRecord> wRecords =
        await getWeeklyRecords(weekNumber: getCurrentWeekNumber());
    List<Record> recs = [];
    for (WeeklyRecord rec in wRecords) {
      if (rec.score > 0) recs.add(rec.convertToRecord());
    }
    rankWeekly = await getIndexFromRecords(username, recs);
    return recs;
  }

  Future<int> getIndexFromRecords(String user, List<Record> records) async {
    for (int i = 0; i < records.length; i++) {
      if (records[i].name == username) {
        return ++i;
      }
    }
    return 0;
  }

  double getHeight(BuildContext context) {
    return sqrt(MediaQuery.of(context).size.height) * 1.5;
  }

  List<Widget> _getTitleWidget() {
    return [
      _getTitleItemWidget('Score', widthColumn1!),
      _getTitleItemWidget('Streak', widthColumn1!),
      _getTitleItemWidget('Player', widthColumn3!),
    ];
  }

  Widget _getTitleItemWidget(String label, double width) {
    return Container(
      width: width,
      height: getHeight(context),
      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
      child: Text(
          textScaler: customTextScaler(context),
          label,
          style: textStyleDark(context)),
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    return Row(
      children: <Widget>[
        Container(
          width: widthColumn1,
          height: getHeight(context),
          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          color: getColor(recs![index]),
          child: Center(
              child: Text(
            textScaler: customTextScaler(context),
            getStreak(recs![index]),
            style: textStyleLB,
          )),
        ),
        Container(
            width: widthColumn3,
            height: getHeight(context),
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            color: getColor(recs![index]),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                maxLines: 1,
                textScaler: customTextScaler(context),
                recs![index].alias.isEmpty
                    ? recs![index].name
                    : recs![index].alias,
                style: textStyleLB,
              ),
            )),
      ],
    );
  }

  String getScore(Record rec) {
    switch (ranking) {
      case Rankings.weeklyRankings:
        return rec.score.toString();
      case Rankings.globalRankings:
      default:
        return rec.totalScore.toString();
    }
  }

  String getStreak(Record rec) {
    switch (ranking) {
      case Rankings.weeklyRankings:
        return rec.streak.toString();
      case Rankings.globalRankings:
      default:
        return rec.totalStreak.toString();
    }
  }

  Color getColor(Record rec) {
    if (rec.name == username) {
      return Colors.orange.withOpacity(.3);
    } else {
      return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    // final double h = MediaQuery.of(context).size.height;
    final bool widerScreen = w > 375.0;
    // widthColumn1 = w * (widerScreen ? .15 : .2);
    // widthColumn3 = w * (widerScreen ? .7 : .6);
    widthColumn1 = w * .17;
    widthColumn3 = w * .66;
    textStyleLB = TextStyle(
        fontFamily: fontName,
        fontSize: calculateFixedFontSize(context) * .7,
        fontWeight: FontWeight.bold,
        color: appThemeColor);
    // bool sortAscending = false;
    // int sortColumnIndex = 0;
    // fetchRecords().then((value) => records = value);

    Widget generateFirstColumnRow(BuildContext context, int index) {
      // if (recs![index].name == username) {
      //   setState(() {
      //     rankNumber = index + 1;
      //   });
      // }
      return Row(
        children: <Widget>[
          Container(
            width: widthColumn1,
            height: getHeight(context),
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            color: getColor(recs![index]),
            child: Center(
                child: Text(
              textScaler: customTextScaler(context),
              getScore(recs![index]),
              style: textStyleLB,
            )),
          ),
        ],
      );
    }

    // getRankNumber().then((value) => rank = value);

    return lightBulbBackgroundWidget(
      context,
      'Leader Board',
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
        MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(w > 430 ? 1.5 : 1.0)),
            child: ToggleWidget(
              minWidth: widerScreen ? 180 : 110,
              initialLabel: 0,
              activeBgColor: appThemeColor.withOpacity(.5),
              activeTextColor: Colors.white,
              inactiveBgColor: customBlueColor.withOpacity(.3),
              inactiveTextColor: appThemeColor, //.grey.shade900,
              labels: const [' Global Rankings ', ' Weekly Rankings '],
              onToggle: (index) {
                debug('switched to: $index');
                player3.playOpenPage();
                switch (index) {
                  case 0:
                    ranking = Rankings.globalRankings;
                    break;
                  case 1:
                  default:
                    ranking = Rankings.weeklyRankings;
                }
                // userSettings.setLocale(wordLocale);
                // objectBox.storeUserSettings(userSettings);
                setState(() {
                  getIndexFromRecords(username, records).then((index) {
                    rankNumber = index;
                  });
                });
              },
            )),
        Center(
            child: ranking == Rankings.globalRankings
                ? Text(
                    textScaler: customTextScaler(context, max: 1.1),
                    'YOUR GLOBAL RANK: $rankNumber',
                    style: textStyleDark(context))
                : Text(
                    textScaler: defaultTextScaler(context),
                    'YOUR WEEKLY RANK: $rankWeekly',
                    style: textStyleDark(context))),
        Expanded(
          child: FutureBuilder<List<Record>?>(
              future: getRecords(),
              builder: (context, snapshot) {
                // filter out inactive players from leader board
                recs = <Record>[];
                if (snapshot.hasData) {
                  switch (ranking) {
                    case Rankings.globalRankings:
                      for (Record r in snapshot.data!) {
                        if (r.totalScore != 0) recs!.add(r);
                      }
                      break;
                    case Rankings.weeklyRankings:
                      for (Record r in snapshot.data!) {
                        if (inCurrentWeek(r.modified)) {
                          recs!.add(r);
                        }
                      }
                      // recs!.sort((a, b) => b.score.compareTo(a.score));
                      // getIndexFromRecords(username, recs!).then((index) {
                      //   rankWeekly = index;
                      // });
                      break;
                  }
                }
                return snapshot.hasData
                    ? HorizontalDataTable(
                        leftHandSideColumnWidth: widthColumn1!,
                        rightHandSideColumnWidth: widthColumn1! + widthColumn3!,
                        isFixedHeader: true,
                        headerWidgets: _getTitleWidget(),
                        isFixedFooter: false,
                        // footerWidgets: _getTitleWidget(w),
                        leftSideItemBuilder: generateFirstColumnRow,
                        rightSideItemBuilder: _generateRightHandSideColumnRow,
                        itemCount: recs!.length,
                        rowSeparatorWidget: const Divider(
                          color: Colors.black38,
                          height: 1.0,
                          thickness: 0.0,
                        ),
                        leftHandSideColBackgroundColor: Colors.transparent,
                        rightHandSideColBackgroundColor: Colors.transparent,
                        itemExtent: getHeight(context) + 1,
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      );
              }),
        ),
        Center(
          child: defaultBackButton(context, backButtonFontScale, .5),
        ),
        const SizedBox(height: 10),
      ]),
    );
  }
}

enum Rankings {
  globalRankings,
  weeklyRankings,
}
