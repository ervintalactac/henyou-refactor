// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:HenyoU/ad_helper.dart';
import 'package:HenyoU/debug.dart';
import 'package:HenyoU/multiplayercluegiver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'gamepage.dart';
import 'helper.dart';
import 'multiplayerdata.dart';
import 'package:ably_flutter/ably_flutter.dart' as ably;

class MultiPlayerPage extends StatefulWidget {
  const MultiPlayerPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  MultiPlayer createState() => MultiPlayer();
}

class MultiPlayer extends State<MultiPlayerPage> {
  BannerAd? _bannerAd;
  int rankNumber = 0;
  double? widthColumn1;
  double? widthColumn3;
  TextStyle? textStyleLB;
  double textSize = 12.0;
  int delay = 10;
  MultiPlayerRoomData? _roomData;
  var myInputController = TextEditingController();
  var myRandomClientId = '';
  StateSetter? _setStateMessage, _setStateButton;
  String displayMsg = 'Waiting for other player to join';
  bool dialogDisplayed = false;
  MultiPlayerTransaction? _txn;
  StreamSubscription<ably.Message>? msgSubscription;
  StreamController<List<MultiPlayerRoomData>>? _mprdRooms;

  @override
  void initState() {
    currentShowOnceValue =
        setInfoStrings(ShowOnceValues.multiplayerPage, infoLocale);
    super.initState();

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

    connectToHenyouChannel();
    _mprdRooms = StreamController<List<MultiPlayerRoomData>>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!showOnce.infoMultiPlayerPageShown) {
        showInfoDialog(context);
        showOnce.infoMultiPlayerPageShown = true;
        objectBox.setShowOnce(showOnce);
      }
    });
  }

  @override
  void dispose() {
    player3.playBackspaceSound();
    resetInfoData();
    if (txnSubscription != null) txnSubscription!.cancel();
    if (msgSubscription != null) msgSubscription!.cancel();
    chatChannel!.realtime.close();
    // roomState.removeListener(() {});
    if (_setStateMessage != null) {
      _setStateMessage = null;
    }
    if (_setStateButton != null) {
      _setStateButton = null;
    }
    gameMode = GameMode.unset;
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

  void connectToHenyouChannel() async {
    // if (chatChannel != null) {
    //   return;
    // }
    ably.ClientOptions options =
        ably.ClientOptions(clientId: username, key: await getAblyApiKey());
    final realtime = ably.Realtime(options: options);
    chatChannel = realtime.channels.get(henyou);
    // need these here since we need chatChannel initialized first
    if (/*!getRoomsFromHistory() && */ mprdRooms.isEmpty) {
      getRooms().then((rooms) => setState(() {
            mprdRooms = rooms;
            chatChannel!.presence.get().then((value) {
              for (var msg in value) {
                debug('PRESENCE GET: $msg');
                updateMultiPlayerRoomData(msg, mprdRooms, false);
              }
            });
          }));
    }

    // presenceSubscription =
    chatChannel!.presence.subscribe().listen((msg) {
      // debug('PRESENCE: ${msg.clientId} : ${msg.data}');
      setState(() {
        updateMultiPlayerRoomData(msg, mprdRooms, true);
      });
    });

    setState(() {
      mprdRooms = getRoomsFromPresenceHistory();
    });
  }

  void updateMultiPlayerRoomData(
      ably.PresenceMessage msg, List<MultiPlayerRoomData> rooms, bool notify) {
    if (rooms.isEmpty) return;
    Map<String, dynamic> data = jsonDecode(msg.data.toString());
    debug('PRESENCE: ${msg.clientId} : ${msg.data}');
    int index = getIndexByRoomName(data['room']);
    MPRoomState roomState = MPRoomState();
    if (index >= 0) roomState.setRoomState(rooms[index].status);
    switch (msg.action) {
      case ably.PresenceAction.present:
      case ably.PresenceAction.enter:
        if (data.containsKey('message') && data['message'] == 'room created') {
          notify = false;
          debug('presence update - created room $msg');
          getRooms().then((rooms) {
            mprdRooms = rooms;
            _mprdRooms!.add(rooms);
          });
        } else if (data['enteredAs'] == 'guesser' &&
            rooms[index].guesser.isEmpty) {
          rooms[index].guesser = data['clientId'];
          rooms[index].status = roomState.guesserJoined().getRoomState;
        } else if (data['enteredAs'] == 'cluegiver' &&
            rooms[index].cluegiver.isEmpty) {
          rooms[index].cluegiver = data['clientId'];
          rooms[index].status = roomState.cluegiverJoined().getRoomState;
        }
        break;
      case ably.PresenceAction.leave:
        if (data['enteredAs'] == 'guesser') {
          if (rooms[index].guesser.isNotEmpty) {
            rooms[index].guesser = '';
            rooms[index].status = roomState.guesserLeft().getRoomState;
          }
        } else if (data['enteredAs'] == 'cluegiver') {
          if (rooms[index].cluegiver.isNotEmpty) {
            rooms[index].cluegiver = '';
            rooms[index].status = roomState.cluegiverLeft().getRoomState;
          }
        }
        if (_txn != null) _txn!.message = roomState.getMessage;
        setState(() {
          mprdRooms; // = rooms;
        });
        notify = false;
        break;
      case ably.PresenceAction.update:
        //       chatChannel!.presence.leaveClient(username,
        // '{"action":"update","clientId":"$username","message":"room created","room":"${playerData.room}"}');
        if (data.containsKey('message') && data['message'] == 'room created') {
          notify = false;
          debug('presence update - created room $msg');
          getRooms().then((rooms) {
            mprdRooms = rooms;
            _mprdRooms!.add(rooms);
          });
        } else if (data['clientId'] == username ||
            rooms[index].status == data['state']) {
          notify = false;
        }
        break;
      case ably.PresenceAction.absent:
        debug("PRESENCE ABSENT: $msg");
        break;
      case null:
        debug("PRESENCE NULL: $msg");
        break;
    }
    if (index < 0) return;
    rooms[index].created = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      displayMsg = roomState.getMessage;
    });
    setState(() {
      roomIsReady = roomState.isReady;
    });
    setState(() {
      mprdRooms = rooms;
    });
    if (notify) {
      MultiPlayerTransaction txn =
          MultiPlayerTransaction.copyFromMultiPlayerRoomData(rooms[index]);
      txn.sender = data['enteredAs'];
      txn.locale = wordLocale;
      txn.difficulty = wordDifficulty;
      sendUserNegotiation(txn);
    }
  }

  ably.PaginatedResult<ably.PresenceMessage>? historyPresenceMsgs;
  List<MultiPlayerRoomData> getRoomsFromPresenceHistory() {
    if (chatChannel == null || gameStarted) {
      debug('getRoomsFromHistory returning false');
      return [];
    }
    try {
      debug('getting last rooms data');
      List<MultiPlayerRoomData> tempRooms = mprdRooms;
      chatChannel!.presence
          .history(ably.RealtimeHistoryParams(
        direction: 'forwards',
        // limit: 10,
      ))
          .then((msgHistory) {
        if (msgHistory.items.isEmpty) {
          return [];
        }
        for (ably.PresenceMessage msg in msgHistory.items) {
          updateMultiPlayerRoomData(msg, tempRooms, false);
        }
        return tempRooms;
      });
    } catch (e) {
      debug('getRoomsFromPresenceHistory: $e');
    }
    return [];
  }

  void listenToChannel(MultiPlayerTransaction mpTxn) {
    debug('transacting with playertype ${mpTxn.sender}');
    // listen to guesser channel as a clue giver
    String ablyRoom = mpTxn.room;
    //'txnhenyou';
    String otherLocale;
    txnSubscription = chatChannel!
        .subscribe(name: ablyRoom)
        .listen((ably.Message message) async {
      var newMsgFromAbly;
      try {
        newMsgFromAbly = message.data;
        String msg = newMsgFromAbly["text"];
        debug("New message arrived (listenToChannel): $msg");
        if (!msg.startsWith('{') ||
            msg.contains('guesserResponse:') ||
            msg.contains('cluegiverResponse:')) return;
        MPRoomState roomState = MPRoomState();
        MultiPlayerTransaction dataFrom =
            MultiPlayerTransaction.fromJson(jsonDecode(msg));
        _roomData = await getRoom(mpTxn.room);
        setRoomData(_roomData!); // for gamepage and multiplayercluegiver
        // assert(_roomData!.guesser == multiPlayerData.user);
        // make sure we're processing incoming data for the same room
        bool roomCompare = mpTxn.room != dataFrom.room;
        debug('room compare: $roomCompare = ${mpTxn.room} != ${dataFrom.room}');
        if (roomCompare) {
          return;
        }
        int i = 0;
        debug('${++i}');
        // int roomIndex = getIndexByRoomName(info.data.room);
        RoomState state = convertStringToRoomState(newMsgFromAbly['type']);
        debug(newMsgFromAbly['type']);
        switch (state) {
          case RoomState.guesserJoined:
            if (dataFrom.sender != MultiPlayerType.guesser.name) {
              debug('${++i}');
              return;
            }
            _roomData!.status = roomState.guesserJoined().getNextRoomState;
            debug('${++i}');
            break;
          case RoomState.guesserCluegiverAccepted:
            if (dataFrom.sender == MultiPlayerType.guesser.name ||
                dataFrom.guesser.isEmpty) {
              debug('${++i}');
              return;
            }
            _roomData!.status =
                roomState.guesserCluegiverAccepted().getNextRoomState;
            debug('${++i}');
            break;
          case RoomState.guesserLeft:
            if (dataFrom.sender != MultiPlayerType.guesser.name) {
              debug('${++i}');
              return;
            }
            _roomData!.status = roomState.guesserLeft().getRoomState;
            dataFrom.transaction = _roomData!.status.name;
            dataFrom.message = roomState.getMessage;
            debug(roomState.message);
            sendUserResponse(
                jsonEncode(dataFrom.toJson()), dataFrom.room, delay);
            debug('${++i}');
            return;
          case RoomState.guesserReady:
            if (mpTxn.sender != MultiPlayerType.guesser.name) {
              debug('${++i}');
              return;
            }
            otherLocale = getOtherPlayersLocale(dataFrom);
            // debug('other player\'s locale: $otherLocale - ' +
            //     jsonEncode(dataFrom.toJson()));
            multiplayerLocale = setMultiPlayerLocale(wordLocale, otherLocale);
            Navigator.of(context).pop();
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const GamePage())); //.
            _roomData!.status = roomState.guesserReady().getNextRoomState;
            debug('${++i}');
            break;
          case RoomState.cluegiverJoined:
            if (dataFrom.sender != MultiPlayerType.cluegiver.name) {
              debug('${++i}');
              return;
            }
            _roomData!.status = roomState.cluegiverJoined().getNextRoomState;
            break;
          case RoomState.cluegiverGuesserAccepted:
            if (dataFrom.sender == MultiPlayerType.cluegiver.name ||
                dataFrom.cluegiver.isEmpty) {
              debug('${++i}');
              return;
            }
            _roomData!.status =
                roomState.clugiverGuesserAccepted().getNextRoomState;
            debug('${++i}');
            break;
          case RoomState.cluegiverLeft:
            if (dataFrom.sender != MultiPlayerType.cluegiver.name) {
              debug('${++i}');
              return;
            }
            _roomData!.status = roomState.cluegiverLeft().getRoomState;
            dataFrom.message = roomState.getMessage;
            dataFrom.transaction = _roomData!.status.name;
            debug(roomState.message);
            sendUserResponse(
                jsonEncode(dataFrom.toJson()), dataFrom.room, delay);
            debug('${++i}');
            return;
          case RoomState.cluegiverReady:
            if (dataFrom.sender != MultiPlayerType.cluegiver.name) {
              debug('${++i}');
              return;
            }
            otherLocale = getOtherPlayersLocale(dataFrom);
            debug('other player\'s locale: $otherLocale');
            multiplayerLocale = setMultiPlayerLocale(wordLocale, otherLocale);
            Navigator.of(context).pop();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MultiPlayerClueGiver()));
            _roomData!.status = roomState.cluegiverReady().getNextRoomState;
            debug('${++i}');
            break;
          case RoomState.ready:
            otherLocale = getOtherPlayersLocale(dataFrom);
            // debug('other player\'s locale: $otherLocale - ' +
            //     jsonEncode(dataFrom.toJson()));
            multiplayerLocale = setMultiPlayerLocale(wordLocale, otherLocale);
            _roomData!.status = roomState.setRoomReady().getRoomState;
            dataFrom =
                MultiPlayerTransaction.copyFromMultiPlayerRoomData(_roomData!);
            dataFrom.message = roomState.getMessage;
            _txn = dataFrom;
            debug('${++i}');
            return;
          case RoomState.open:
          case RoomState.waitingForPlayers:
            break;
        }
        debug('${++i}');
        if (!state.name.toLowerCase().contains('open') &&
            // !state.name.toLowerCase().contains('ready') &&
            !state.name.toLowerCase().contains('waiting')) {
          dataFrom =
              MultiPlayerTransaction.copyFromMultiPlayerRoomData(_roomData!);
          dataFrom.message = roomState.getMessage;
          _txn = dataFrom;
          sendUserResponse(jsonEncode(dataFrom.toJson()), dataFrom.room, delay);
          // updateRoom(_roomData!);
          sendUserNegotiation(dataFrom);
        }
        debug('${++i}');
      } catch (e) {
        debug('listenToChannel: $e');
      }
    });
  }

  double getHeight(double height) {
    return sqrt(height) * (height > 1000 ? 1.9 : 1.5);
  }

  List<Widget> _getTitleWidget() {
    return [
      _getTitleItemWidget('Room name', widthColumn3!),
      _getTitleItemWidget('Guesser', widthColumn1!),
      _getTitleItemWidget('Clue Giver', widthColumn1!),
    ];
  }

  Widget _getTitleItemWidget(String label, double width) {
    ScreenScaler scaler = ScreenScaler()..init(context);
    double screenH = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      height: getHeight(screenH),
      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
      child: Text(
          textScaler: customTextScaler(context),
          label,
          style: textStyleDarkCustomFontSize(scaler.getTextSize(11))),
    );
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    double screenH = MediaQuery.of(context).size.height;
    double screenW = MediaQuery.of(context).size.width;
    return Row(
      children: <Widget>[
        Container(
          width: widthColumn3,
          height: getHeight(screenH),
          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          color: Colors.transparent,
          child: Text(
            textScaler:
                customTextScaler(context, max: screenW > 430 ? 1.6 : 1.4),
            mprdRooms.elementAt(index).roomName,
            style: textStyleLB,
          ),
        ),
      ],
    );
  }

  Widget generateRightHandSideColumnRow(BuildContext context, int index) {
    double screenH = MediaQuery.of(context).size.height;
    return Row(
      children: <Widget>[
        Container(
          width: widthColumn1,
          height: getHeight(screenH),
          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          color: Colors.transparent,
          child: Stack(children: [
            Visibility(
                visible: mprdRooms.elementAt(index).guesser.isEmpty,
                child: niceButton(context, getHeight(screenH) - 1,
                    widthColumn1! / 1.2, 'Join', () {
                  player3.playOpenPage();
                  String room = mprdRooms.elementAt(index).roomName;
                  mpInfo ??= MultiPlayerInfo();
                  mpInfo!.type = MultiPlayerType.guesser;
                  mpInfo!.data = MultiPlayerData(
                      cluegiver: mprdRooms.elementAt(index).cluegiver,
                      guesser: username,
                      room: room,
                      txnStatus: RoomState.guesserJoined.name,
                      locale: wordLocale,
                      difficulty: wordDifficulty);
                  MultiPlayerTransaction txn = MultiPlayerTransaction(
                      sender: MultiPlayerType.guesser.name,
                      guesser: username,
                      // cluegiver: data.cluegiver,
                      room: room,
                      transaction: RoomState.guesserJoined.name,
                      message: 'Guesser has joined',
                      locale: wordLocale,
                      difficulty: wordDifficulty,
                      timestamp: DateTime.now().toString());
                  setState(() {
                    joinRoom(txn).then((mpRoomData) {
                      if (roomJoined) {
                        _txn = txn;
                        displayDialog(context, txn);
                        gameMode = GameMode.multiPlayer;
                      } else {
                        debug('joinRoom returned false');
                        showTryAgainDialog(context, mpInfo!.data.room);
                      }
                    });
                  });
                })),
            Visibility(
              visible: mprdRooms.elementAt(index).guesser.isNotEmpty,
              child: Text(
                  textScaler: customTextScaler(context, max: 1.0),
                  'Joined',
                  style: textStyleDark(context)),
            ),
          ]),
        ),
        Container(
          width: widthColumn1,
          height: getHeight(screenH),
          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          color: Colors.transparent,
          child: Stack(
            children: [
              Visibility(
                  visible: mprdRooms.elementAt(index).cluegiver.isEmpty,
                  child: niceButton(
                    context,
                    getHeight(screenH) - 2,
                    widthColumn1! / 1.2,
                    'Join',
                    () {
                      player3.playOpenPage();
                      String room = mprdRooms.elementAt(index).roomName;
                      mpInfo ??= MultiPlayerInfo();
                      mpInfo!.type = MultiPlayerType.cluegiver;
                      mpInfo!.data = MultiPlayerData(
                          cluegiver: username,
                          guesser: mprdRooms.elementAt(index).guesser,
                          room: room,
                          txnStatus: RoomState.cluegiverJoined.name,
                          locale: wordLocale,
                          difficulty: wordDifficulty);
                      MultiPlayerTransaction txn = MultiPlayerTransaction(
                          sender: MultiPlayerType.cluegiver.name,
                          // guesser: data.guesser,
                          cluegiver: username,
                          room: room,
                          transaction: RoomState.cluegiverJoined.name,
                          message: 'Clue giver has joined',
                          locale: wordLocale,
                          difficulty: wordDifficulty,
                          timestamp: DateTime.now().toString());
                      setState(() {
                        joinRoom(txn).then((mpRoomData) {
                          if (roomJoined) {
                            _txn = txn;
                            displayDialog(context, txn);
                          } else {
                            debug('joinRoom returned false');
                            showTryAgainDialog(context, room);
                          }
                        });
                      });
                    },
                  )),
              Visibility(
                visible: mprdRooms.elementAt(index).cluegiver.isNotEmpty,
                child: Text(
                    textScaler: customTextScaler(context, max: 1.0),
                    'Joined',
                    style: textStyleDark(context)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  String setMultiPlayerLocale(String guesserLocale, String cluegiverLocale) {
    if (guesserLocale == 'en' || cluegiverLocale == 'en') {
      return 'en';
    } else {
      return 'ph';
    }
  }

  Future<MultiPlayerRoomData> joinRoom(MultiPlayerTransaction mpTxn) async {
    // ably.RealtimeChannelOptions options = const ably.RealtimeChannelOptions(
    //     params: {'occupancy': 'metrics.subscribers'});
    // var ablyChannel = ably.RealtimeChannel(chatChannel!.realtime, mpTxn.room);
    // ably.RealtimePresenceParams params =
    //     ably.RealtimePresenceParams(clientId: username);
    // var messages = await ablyChannel.presence.get(params);
    // messages.
    chatChannel!.params = {'occupancy': 'metrics.subscribers'};
    chatChannel!.subscribe(name: '[meta]occupancy').listen((data) {
      debug('occupancy: ${data.data}');
    });
    popOnce = false;
    createRoom(mpTxn.room);
    MultiPlayerRoomData roomData = await getRoom(mpTxn.room);
    chatChannel!.presence.enterClient(username,
        '{"action":"enter","clientId":"$username","enteredAs":"${mpTxn.sender}","room":"${mpTxn.room}"}');
    roomJoined = true;
    return roomData;
  }

  String getMessage() {
    return displayMsg;
  }

  bool getRoomIsReady() {
    return roomIsReady;
  }

  String getOtherPlayersLocale(MultiPlayerTransaction t) {
    debug('LOCALE: $username: ${jsonEncode(t.toJson())}');
    if ((t.sender == MultiPlayerType.cluegiver.name && t.guesser == username) ||
        (t.sender == MultiPlayerType.guesser.name && t.cluegiver == username)) {
      return t.locale;
    }
    return 'ph';
  }

  void messageListener(MultiPlayerTransaction mpTxn) {
    // dialogDisplayed = true;
    msgSubscription = chatChannel!.subscribe(name: mpTxn.room).listen((event) {
      var data;
      data = event.data;
      String text = data["text"];
      debug('INCOMING MESSAGE: $text');
      if (!text.startsWith('{')) return;
      _txn = MultiPlayerTransaction.fromJson(jsonDecode(text));
      // listHistoryMessages.add(_txn!);
      if (mpTxn.room != _txn!.room /*|| mpTxn.sender == _txn!.sender*/) {
        return;
      }

      _setStateMessage!(() => displayMsg = _txn!.message);
      _setStateButton!(() =>
          roomIsReady = _txn!.transaction.toLowerCase().contains('ready'));
    });
  }

  bool popOnce = false;
  void displayDialog(BuildContext contex, MultiPlayerTransaction mpTxn) {
    listenToChannel(mpTxn);
    messageListener(mpTxn);

    chatChannel!.subscribe(name: mpTxn.room).listen((ably.Message message) {
      // txnSubscription!.onData((message) {
      var newMsgFromAbly;
      newMsgFromAbly = message.data;
      String msg = newMsgFromAbly["text"];
      debug(msg);
      if (!msg.startsWith('{')) return;
      _txn = MultiPlayerTransaction.fromJson(jsonDecode(msg));
      MPRoomState roomState = MPRoomState();
      if (msg.contains('guesserReady') || msg.contains('cluegiverReady')) {
        if (!popOnce) {
          if (_txn!.guesser == username) {
            _txn!.transaction = roomState.guesserReady().getRoomState.name;
            _txn!.sender = MultiPlayerType.guesser.name;
          } else if (_txn!.cluegiver == username) {
            _txn!.transaction = roomState.cluegiverReady().getRoomState.name;
            _txn!.sender = MultiPlayerType.cluegiver.name;
          }
          _txn!.message = roomState.getMessage;
          // if (!popOnce) {
          popOnce = !popOnce;

          sendUserResponse(jsonEncode(_txn!.toJson()), _txn!.room, delay);
          sendUserNegotiation(_txn!);

          Navigator.of(context).pop();
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => mpTxn.guesser == username
                    ? const GamePage()
                    : const MultiPlayerClueGiver(),
              )).then((value) => setState(() {
                currentShowOnceValue =
                    setInfoStrings(ShowOnceValues.multiplayerPage, infoLocale);
                // leaveRoom(mpInfo!.data).then((value) => roomJoined = false);
              }));
        }
      }
    });

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(.5),
      barrierDismissible: false,
      builder: (BuildContext context) => Center(
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(.9),
          title: Text(
            'Room: ${mpInfo!.data.room}',
            style: textStyleAutoScaledByPercent(context, 14, darkTextColor),
            textScaler: defaultTextScaler(context),
          ),
          // insetPadding: const EdgeInsets.all(20),
          // contentPadding: const EdgeInsets.all(0),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              _setStateMessage = setState;
              return Text(
                getMessage(),
                style: textStyleAutoScaledByPercent(context, 12, darkTextColor),
                textScaler: defaultTextScaler(context),
              );
            },
          ),
          actions: <Widget>[
            StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              _setStateButton = setState;
              return Visibility(
                visible: roomIsReady,
                child: TextButton(
                  child: Text(
                      style: textStyleAutoScaledByPercent(
                          context, 13, darkTextColor),
                      textScaler: defaultTextScaler(context),
                      "Continue"),
                  onPressed: () {
                    if (_txn!.guesser == username) {
                      _txn!.message = 'Guesser ready';
                      _txn!.transaction = RoomState.guesserReady.name;
                      _txn!.sender = MultiPlayerType.guesser.name;
                    } else if (_txn!.cluegiver == username) {
                      _txn!.message = 'Clue giver ready';
                      _txn!.transaction = RoomState.cluegiverReady.name;
                      _txn!.sender = MultiPlayerType.cluegiver.name;
                    }
                    sendUserResponse(
                        jsonEncode(_txn!.toJson()), _txn!.room, delay);
                    sendUserNegotiation(_txn!);
                    // txnSubscription!.cancel();x
                    // msgSubscription!.cancel();
                  }, //closes popup
                ),
              );
            }),
            TextButton(
                onPressed: () {
                  player3.playBackspaceSound();
                  debug('popOnce: $popOnce');
                  if (!popOnce && roomJoined) {
                    leaveRoom(mpInfo!.data);
                  }
                  // presenceSubscription!.resume();
                  Navigator.of(context).pop();
                  popOnce = false;
                },
                child: Text(
                    style: textStyleAutoScaledByPercent(
                        context, 13, darkTextColor),
                    textScaler: defaultTextScaler(context),
                    'Go Back')),
          ],
        ),
      ),
    );
  }

  Stream<List<MultiPlayerRoomData>> _getRooms() {
    if (mprdRooms.isEmpty) {
      getRooms().then((rooms) {
        _mprdRooms!.add(rooms);
      });
    }
    return _mprdRooms!.stream;
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final bool widerScreen = w > 375.0;
    widthColumn1 = w * (widerScreen ? .23 : .25);
    widthColumn3 = w * (widerScreen ? .54 : .5);
    textStyleLB = TextStyle(
        fontFamily: fontName,
        fontSize: calculateFixedFontSize(context) * .9,
        fontWeight: FontWeight.bold,
        color: appThemeColor);
    double screenH = MediaQuery.of(context).size.height;

    debug('building multiplayer rooms ${DateTime.now()}');
    return lightBulbBackgroundWidget(
      context,
      'Play with another person',
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
        Center(
          child:
              defaultButton(context, 1, 1, 'Tap here to create a new room', () {
            player3.playOpenPage();
            setState(() {
              createRoom('').then((rooms) {
                _mprdRooms!.add(rooms);
              });
            });
          }),
        ),
        Expanded(
          child: StreamBuilder<List<MultiPlayerRoomData>>(
              stream: _getRooms(),
              builder: (context, snapshot) {
                if (snapshot.hasData && mprdRooms != snapshot.data!) {
                  mprdRooms = snapshot.data!;
                }
                return snapshot.hasData
                    ? HorizontalDataTable(
                        leftHandSideColumnWidth: widthColumn3!,
                        rightHandSideColumnWidth: widthColumn1! + widthColumn1!,
                        isFixedHeader: true,
                        headerWidgets: _getTitleWidget(),
                        isFixedFooter: false,
                        // footerWidgets: _getTitleWidget(w),
                        leftSideItemBuilder: _generateFirstColumnRow,
                        rightSideItemBuilder: generateRightHandSideColumnRow,
                        itemCount: mprdRooms.length,
                        rowSeparatorWidget: const Divider(
                          color: Colors.black38,
                          height: 1.0,
                          thickness: 0.0,
                        ),
                        leftHandSideColBackgroundColor: Colors.transparent,
                        rightHandSideColBackgroundColor: Colors.transparent,
                        itemExtent: getHeight(screenH) + 4,
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      );
              }),
        ),
        Row(children: [
          const Spacer(),
          Center(
            child: defaultBackButton(context, backButtonFontScale, .5),
          ),
          const Spacer(),
          // Center(
          //   child: defaultButton(context, .8, .5, 'Create a new room', () {
          //     player3.playOpenPage();
          //     setState(() {
          //       createRoom('').then((rooms) {
          //         _mprdRooms!.add(rooms);
          //       });
          //     });
          //   }),
          // ),
          // const Spacer(),
        ]),
        const SizedBox(height: 10),
      ]),
    );
  }
}
