import 'dart:async';
import 'dart:convert';

import 'package:faker/faker.dart';
import 'package:flutter/material.dart';

import 'debug.dart';
import 'helper.dart';
import 'package:http/http.dart' as http;
import 'package:ably_flutter/ably_flutter.dart' as ably;

class MultiPlayerRoomData {
  int id;
  String roomName;
  String guesser;
  String cluegiver;
  RoomState status;
  int created;

  MultiPlayerRoomData({
    this.id = 0,
    this.roomName = '',
    this.guesser = '',
    this.cluegiver = '',
    this.status = RoomState.open,
    this.created = 0,
  });

  MultiPlayerRoomData.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        roomName = json['roomName'] as String,
        guesser = json['guesser'] as String,
        cluegiver = json['cluegiver'] as String,
        status = convertStringToRoomState(json['status']),
        created = json['created'] as int;

  Map<String, dynamic> toJson() => {
        'id': id,
        'roomName': roomName,
        'guesser': guesser,
        'cluegiver': cluegiver,
        'status': status.name,
        'created': created,
      };

  bool isEqual(MultiPlayerRoomData data) {
    if (id != data.id) {
      return false;
    } else if (roomName != data.roomName) {
      return false;
    } else if (guesser != data.guesser) {
      return false;
    } else if (cluegiver != data.cluegiver) {
      return false;
    } else if (status != data.status) {
      return false;
    }

    return true;
  }
}

class MultiPlayerTransaction {
  String sender;
  String guesser;
  String cluegiver;
  String room;
  String transaction;
  String message;
  String difficulty;
  String locale;
  String timestamp;

  MultiPlayerTransaction({
    this.sender = '',
    this.guesser = '',
    this.cluegiver = '',
    this.room = '',
    this.transaction = '',
    this.message = '',
    this.difficulty = '',
    this.locale = '',
    this.timestamp = '',
  });

  MultiPlayerTransaction.fromJson(Map<String, dynamic> json)
      : sender = json['sender'] as String,
        guesser = json['guesser'] as String,
        cluegiver = json['cluegiver'] as String,
        room = json['room'] as String,
        transaction = json['transaction'] as String,
        message = json['message'] as String,
        difficulty = json['difficulty'] as String,
        locale = json['locale'] as String,
        timestamp = json['timestamp'] as String;

  Map<String, dynamic> toJson() => {
        'sender': sender,
        'guesser': guesser,
        'cluegiver': cluegiver,
        'room': room,
        'transaction': transaction,
        'message': message,
        'difficulty': difficulty,
        'locale': locale,
        'timestamp': timestamp,
      };

  static MultiPlayerTransaction copyFromMultiPlayerRoomData(
      MultiPlayerRoomData data) {
    MultiPlayerTransaction txn = MultiPlayerTransaction();
    txn.sender = data.guesser == username
        ? MultiPlayerType.guesser.name
        : data.cluegiver == username
            ? MultiPlayerType.cluegiver.name
            : '';
    txn.guesser = data.guesser;
    txn.cluegiver = data.cluegiver;
    txn.room = data.roomName;
    if (data.guesser == username || data.cluegiver == username) {
      txn.difficulty = wordDifficulty;
      txn.locale = wordLocale;
    }
    txn.timestamp = DateTime.now().toString();
    txn.transaction = data.status.name;
    return txn;
  }
}

class MultiPlayerData {
  String guesser;
  String cluegiver;
  String room;
  String txnStatus;
  String locale;
  String difficulty;

  MultiPlayerData({
    this.guesser = '',
    this.cluegiver = '',
    this.room = '',
    this.txnStatus = 'open',
    this.locale = 'ph',
    this.difficulty = 'e',
  });

  void setGuesser(String user) {
    guesser = user;
  }

  void setCluegiver(String user) {
    cluegiver = user;
  }

  void setTxnStatus(String status) {
    txnStatus = status;
  }

  MultiPlayerData.fromJson(Map<String, dynamic> json)
      : guesser = json['guesser'] as String,
        cluegiver = json['cluegiver'] as String,
        room = json['room'] as String,
        txnStatus = json['txnStatus'] as String,
        locale = json['locale'] as String,
        difficulty = json['difficulty'] as String;

  Map<String, dynamic> toJson() => {
        'guesser': guesser,
        'cluegiver': cluegiver,
        'room': room,
        'txnStatus': txnStatus,
        'locale': locale,
        'difficulty': difficulty,
      };
}

class MultiPlayerInfo {
  late MultiPlayerType type;
  late MultiPlayerData data;
}

class AblyUser {
  final int id;
  final String name;

  AblyUser({
    this.id = 0,
    this.name = '',
  });
}

class AblyMessage {
  final AblyUser? sender;
  final String? time;
  final String? text;
  final bool? unread;

  AblyMessage({this.sender, this.time, this.text, this.unread, x});
}

// CURRENT USER
AblyUser guesser = AblyUser(
  id: 0,
  name: _roomData!.guesser,
);

// OTHER USER
AblyUser cluegiver = AblyUser(
  id: 1,
  name: _roomData!.cluegiver,
);

List<MultiPlayerRoomData> mprdRooms = [];
ably.Realtime? realtimeInstance;
MultiPlayerRoomData? _roomData;
StreamSubscription<ably.Message>? txnSubscription, roomDataSubscription;
// StreamSubscription<ably.PresenceMessage>? presenceSubscription,
//     displayPresenceSubscription;
bool txnSubscribed = false;
MultiPlayerData? mpData;
StateSetter? _setState;
String confirmationMessage = 'Configuring room...';
bool roomIsReady = false;

MultiPlayerRoomData getRoomData() {
  return _roomData!;
}

void setRoomData(MultiPlayerRoomData data) {
  _roomData = data;
}

bool roomExists(String roomName) {
  for (MultiPlayerRoomData mpdr in mprdRooms) {
    if (mpdr.roomName == roomName) {
      return true;
    }
  }
  return false;
}

int getIndexByRoomName(String name) {
  return mprdRooms.indexWhere((element) => element.roomName == name);
}

Future<List<MultiPlayerRoomData>> createRoom(String roomName) async {
  List<MultiPlayerRoomData> tempRooms = [];
  if (roomName.isEmpty || !roomExists(roomName)) {
    do {
      roomName = '${Faker().color.commonColor()}${Faker().animal.name()}';
    } while (roomExists(roomName));
    http.Response resp = await createNewRoom(roomName);
    debug(resp.body);
    tempRooms = [
      MultiPlayerRoomData(
          roomName: roomName,
          created: DateTime.now().millisecondsSinceEpoch,
          status: RoomState.open)
    ];
    tempRooms.addAll(mprdRooms);
    chatChannel!.presence.update(
        '{"action":"update","clientId":"$username","message":"room created","room":"$roomName","enteredAs":""}');
  } else {
    tempRooms = mprdRooms;
  }
  return tempRooms;
}

// TO DO:
int delay = 5;
Future<bool> leaveRoom(MultiPlayerData playerData) async {
  debug('LEAVE ROOM: ${jsonEncode(playerData.toJson())}');

  chatChannel!.presence.leaveClient(
      username,
      jsonEncode(<String, dynamic>{
        "action": "leave",
        "clientId": username,
        "enteredAs": mpInfo!.type.name,
        "room": playerData.room,
      }));

  roomJoined = false;
  MultiPlayerRoomData roomData = await getRoom(playerData.room);
  MultiPlayerTransaction txn =
      MultiPlayerTransaction.copyFromMultiPlayerRoomData(roomData);

  if (roomData.roomName == playerData.room) {
    if (playerData.guesser == username) {
      txn.message = 'Guesser player left the room';
      txn.transaction = RoomState.guesserLeft.name;
    } else if (playerData.cluegiver == username) {
      txn.message = 'Clue giver player left the room';
      txn.transaction = RoomState.cluegiverLeft.name;
    }
  }
  sendUserResponse(jsonEncode(txn.toJson()), txn.room, delay);
  sendUserNegotiation(txn);
  return roomJoined;
}

void setMessage(String msg) {
  debug('setting state for alert dialog');
  if (_setState != null) {
    _setState!(() {
      roomIsReady = _roomData!.status == RoomState.ready;
      confirmationMessage = msg;
    });
  }
}

enum RoomState {
  guesserJoined,
  guesserCluegiverAccepted,
  guesserLeft,
  guesserReady,
  cluegiverJoined,
  cluegiverGuesserAccepted,
  cluegiverLeft,
  cluegiverReady,
  waitingForPlayers,
  ready,
  open,
}

enum MultiPlayerType { guesser, cluegiver }

class MPRoomState /* extends ChangeNotifier */ {
  RoomState _roomState = RoomState.waitingForPlayers;
  RoomState _nextRoomState = RoomState.open;
  String message = 'Waiting for players to join';
  bool get isReady => _roomState == RoomState.ready;
  bool get isCluegiverJoined => _roomState == RoomState.cluegiverJoined;
  bool get isGuesserJoined => _roomState == RoomState.guesserJoined;
  bool get isActive => _roomState == RoomState.ready;
  final String _locale = 'ph';
  String get getLocale => _locale;
  String get getMessage => message;
  RoomState get getRoomState => _roomState;
  RoomState get getNextRoomState => _nextRoomState;

  void setMessage(String msg) {
    message = msg;
  }

  MPRoomState guesserJoined() {
    _roomState = RoomState.guesserJoined;
    _nextRoomState = RoomState.cluegiverGuesserAccepted;
    message = 'Guesser player joined';
    // notifyListeners();
    return this;
  }

  MPRoomState cluegiverJoined() {
    _roomState = RoomState.cluegiverJoined;
    _nextRoomState = RoomState.guesserCluegiverAccepted;
    message = 'Clue giver player joined';
    // notifyListeners();
    return this;
  }

  MPRoomState setRoomActive() {
    return setRoomReady();
  }

  MPRoomState setRoomReady() {
    String lang = 'english';
    if (multiplayerLocale == 'ph') {
      lang = 'tagalog & english';
    }
    message =
        'Both players joined the room. Language set to $lang. Select \'Go Back\' to pick a different room or Continue to proceed to the room';
    _roomState = RoomState.ready;
    _nextRoomState = RoomState.ready;
    // notifyListeners();
    return this;
  }

  MPRoomState setWaitingForPlayers() {
    _roomState = RoomState.waitingForPlayers;
    message = 'Waiting for players to join.';
    // notifyListeners();
    return this;
  }

  MPRoomState clugiverGuesserAccepted() {
    _roomState = RoomState.cluegiverGuesserAccepted;
    _nextRoomState = RoomState.ready;
    message = 'Guesser accepted';
    // notifyListeners();
    return this;
  }

  MPRoomState guesserCluegiverAccepted() {
    message = 'Clue giver accepted';
    _nextRoomState = RoomState.ready;
    _roomState = RoomState.guesserCluegiverAccepted;
    // notifyListeners();
    return this;
  }

  MPRoomState guesserReady() {
    message = 'Guesser ready';
    _roomState = RoomState.guesserReady;
    _nextRoomState = RoomState.ready;
    // notifyListeners();
    return this;
  }

  MPRoomState cluegiverReady() {
    message = 'Clue Giver ready';
    _roomState = RoomState.cluegiverReady;
    _nextRoomState = RoomState.ready;
    // notifyListeners();
    return this;
  }

  MPRoomState guesserLeft() {
    message = 'Guesser left the room';
    _roomState = RoomState.guesserLeft;
    // notifyListeners();
    return this;
  }

  MPRoomState cluegiverLeft() {
    message = 'Clue giver left the room';
    _roomState = RoomState.cluegiverLeft;
    // notifyListeners();
    return this;
  }

  void setRoomState(RoomState status) {
    _roomState = status;
  }
}

void showTryAgainDialog(BuildContext context, String roomName) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(.5),
    builder: (BuildContext context) => Center(
      child: AlertDialog(
        backgroundColor: Colors.white.withOpacity(.9),
        title: Text(
          'Failed to join room: $roomName',
          style: textStyleAutoScaledByPercent(context, 14, darkTextColor),
          textScaler: defaultTextScaler(context),
        ),
        // insetPadding: const EdgeInsets.all(20),
        // contentPadding: const EdgeInsets.all(0),
        content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Text(
              'Try joining room again.',
              style: textStyleAutoScaledByPercent(context, 12, darkTextColor),
              textScaler: defaultTextScaler(context),
            )),
        actions: <Widget>[
          TextButton(
            child: Text(
              "Continue",
              style: textStyleAutoScaledByPercent(context, 13, darkTextColor),
              textScaler: defaultTextScaler(context),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }, //closes popup
          ),
        ],
      ),
    ),
  );
}
