import 'dart:convert';

import 'package:HenyoU/wordselection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'debug.dart';
import 'entities.dart';
import 'objectbox.g.dart';

class ObjectBox {
  /// The Store of this app.
  late final Store _store;
  late final Box<User> _userBox;
  // late final Box<Record> _recordBox;
  late final Box<HenyoWords> _henyoWordsList;
  late final Box<Secure> _secureKeys;
  late final Box<UserSettings> _userSettings;
  late final Box<UserGuesses> _userGuesses;
  late final Box<MultiPlayerWords> _multiplayerWords;
  late final Box<GlobalMessages> _globalMessages;
  late final Box<GlobalSettings> _globalSettings;
  late final Box<ShowOnce> _showOnce;
  late final Box<WordsHistory> _wordsHistory;
  late final Box<JsonWords> _jsonWords;
  late final Box<JsonGimme5Round1> _jsonGimme5Round1;
  late final Box<JsonDictionary> _jsonDictionary;
  late final Box<JsonMultiplayer> _jsonMultiplayer;

  ObjectBox._create(this._store) {
    _userBox = Box<User>(_store);
    _henyoWordsList = Box<HenyoWords>(_store);
    _multiplayerWords = Box<MultiPlayerWords>(_store);
    _secureKeys = Box<Secure>(_store);
    _userSettings = Box<UserSettings>(_store);
    _userGuesses = Box<UserGuesses>(_store);
    _globalMessages = Box<GlobalMessages>(_store);
    _globalSettings = Box<GlobalSettings>(_store);
    _showOnce = Box<ShowOnce>(_store);
    _wordsHistory = Box<WordsHistory>(_store);
    _jsonWords = Box<JsonWords>(_store);
    _jsonGimme5Round1 = Box<JsonGimme5Round1>(_store);
    _jsonMultiplayer = Box<JsonMultiplayer>(_store);
    _jsonDictionary = Box<JsonDictionary>(_store);
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
    final store = await openStore(directory: p.join(docsDir.path, "objectbox"));

    // if (Sync.isAvailable()) {
    //   const serverIp = '192.168.1.40';
    //   final syncClient =
    //       Sync.client(store, 'ws://$serverIp:9999', SyncCredentials.none());
    //   syncClient.connectionEvents.listen((event) {
    //     debug(event.name);
    //   });
    //   syncClient.start();
    // }

    return ObjectBox._create(store);
  }

  bool isJsonDictionaryNotEmpty() {
    return !_jsonDictionary.isEmpty();
  }

  bool setJsonDictionary(JsonDictionary words) {
    words.id = isJsonDictionaryNotEmpty() ? 1 : 0;
    return _jsonDictionary.put(words) > 0;
  }

  int getJsonDictionaryDate() {
    return _jsonDictionary.get(1)!.dictionaryDate;
  }

  String getJsonDictionaryWords() {
    if (isJsonDictionaryNotEmpty()) {
      return _jsonDictionary.get(1)!.dictionaryJson;
    } else {
      return '';
    }
  }

  bool isJsonGimme5Round1NotEmpty() {
    return !_jsonGimme5Round1.isEmpty();
  }

  bool setJsonGimme5Round1(JsonGimme5Round1 words) {
    words.id = isJsonGimme5Round1NotEmpty() ? 1 : 0;
    return _jsonGimme5Round1.put(words) > 0;
  }

  int getJsonGimme5Round1Date() {
    return _jsonGimme5Round1.get(1)!.gimme5Round1Date;
  }

  String getJsonGimme5Round1Words() {
    if (isJsonGimme5Round1NotEmpty()) {
      return _jsonGimme5Round1.get(1)!.gimme5Round1Json;
    } else {
      return '';
    }
  }

  bool isJsonMultiplayerNotEmpty() {
    return !_jsonMultiplayer.isEmpty();
  }

  bool setJsonMultiplayer(JsonMultiplayer multiplayer) {
    multiplayer.id = isJsonMultiplayerNotEmpty() ? 1 : 0;
    return _jsonMultiplayer.put(multiplayer) > 0;
  }

  int getJsonMultiplayerDate() {
    return _jsonMultiplayer.get(1)!.multiplayerDate;
  }

  String getJsonMultiplayerWords() {
    if (isJsonMultiplayerNotEmpty()) {
      return _jsonMultiplayer.get(1)!.multiplayerJson;
    } else {
      return '';
    }
  }

  bool isJsonWordsNotEmpty() {
    return !_jsonWords.isEmpty();
  }

  bool setJsonWords(JsonWords jsonWords) {
    jsonWords.id = isJsonWordsNotEmpty() ? 1 : 0;
    return _jsonWords.put(jsonWords) > 0;
  }

  int getJsonWordsDate() {
    return _jsonWords.get(1)!.wordsDate;
  }

  String getJsonWords() {
    if (isJsonWordsNotEmpty()) {
      return _jsonWords.get(1)!.wordsJson;
    } else {
      return '';
    }
  }

  bool setWordsHistory(String json) {
    WordsHistory words = WordsHistory();
    words.id = _wordsHistory.count() > 0 ? 1 : 0;
    words.wordsHistoryJson = json;
    return _wordsHistory.put(words) == 1;
  }

  WordsHistory? getWordsHistory() => _wordsHistory.get(1);

  bool setShowOnce(ShowOnce showOnce) {
    showOnce.id = _showOnce.count() > 0 ? 1 : 0;
    return _showOnce.put(showOnce) == 1;
  }

  ShowOnce? getShowOnce() => _showOnce.get(1);
  bool isShowOnceNotEmpty() => _showOnce.count() > 0;

  bool setGlobalSettings(GlobalSettings settings) {
    settings.id = _globalSettings.count() > 0 ? 1 : 0;
    return _globalSettings.put(settings) == 1;
  }

  GlobalSettings? getGlobalSettings() => _globalSettings.get(1);
  bool isGlobalSettingsNotEmpty() => _globalSettings.count() > 0;

  bool setGlobalMessages(GlobalMessages messages) {
    messages.id = _globalMessages.count() > 0 ? 1 : 0;
    return _globalMessages.put(messages) == 1;
  }

  GlobalMessages? getGlobalMessages() => _globalMessages.get(1);
  bool isGlobalMessagesNotEmpty() => _globalMessages.count() > 0;

  bool isEmpty() => !_userBox.contains(1);
  User? getUser(int id) => _userBox.get(id);
  List<User> getAllUsers() => _userBox.getAll();
  int insertUser(User user) => _userBox.put(user);
  int setUser(User user) {
    int id = isEmpty() ? 0 : 1;
    user.id = id;
    insertUser(user);
    return id;
  }

  Stream<List<User>> getUsers() => _userBox
      .query()
      .watch(triggerImmediately: true)
      .map((query) => query.find());
  bool deleteUser(int id) => _userBox.remove(id);
  int updateScore(int scoreToAdd) {
    User u = getUser(1)!;
    u.score = u.score + scoreToAdd;
    return insertUser(u);
  }

  bool isWordListEmpty() => _henyoWordsList.isEmpty();
  int storeWords(HenyoWords words) => _henyoWordsList.put(words);
  int updateWords(HenyoWords words) {
    words.id = _henyoWordsList.isEmpty() ? 0 : 1;
    return _henyoWordsList.put(words);
  }

  int updateBackupWords(HenyoWords words) {
    words.id = _henyoWordsList.getAll().length > 1 ? 2 : 0;
    return _henyoWordsList.put(words);
  }

  String getWordsList() => _henyoWordsList.get(1)!.getWordsList();
  String getBackupWordsList() => _henyoWordsList.get(2)!.getWordsList();
  void setWordsList(String updatedWordsList) =>
      _henyoWordsList.get(1)!.setWordsList(updatedWordsList);
  String getDictionaryList() => _henyoWordsList.get(1)!.getDictionaryList();
  int getWordsUploadDate() => _henyoWordsList.get(1)!.getUploadDate();
  int dictionarySize() {
    if (_henyoWordsList.isEmpty()) {
      return 0;
    }
    return _henyoWordsList.get(1)!.getDictionaryList().length;
  }

  MultiPlayerWords getMPWordsList() => _multiplayerWords.get(1)!;
  void setMPWordsList(MultiPlayerWords wordsList) {
    if (_multiplayerWords.isEmpty()) {
      wordsList.id = 0;
      _multiplayerWords.put(wordsList);
    } else {
      wordsList.id = 1;
    }
    _multiplayerWords.put(wordsList);
  }

  List<String> getAllWords() {
    List<String> list = <String>[];
    List<WordSelection> wList = jsonDecode(getBackupWordsList());
    Map<String, dynamic> dList = jsonDecode(getDictionaryList());
    for (int i = 0; i < wList.length; i++) {
      if (!list.contains(wList[i].guessWord)) {
        list.add(wList[i].guessWord);
      }
      List<dynamic> tempList = wList[i].associatedWords;
      for (String w in tempList) {
        if (w.startsWith('@')) {
          List<String> dict = dList[w];
          for (String d in dict) {
            if (!list.contains(d)) {
              list.add(d);
            }
          }
        } else if (!list.contains(w)) {
          list.add(w);
        }
      }
      tempList = wList[i].possibleWords;
      for (String w in tempList) {
        if (w.startsWith('@')) {
          List<String> dict = dList[w];
          for (String d in dict) {
            if (!list.contains(d)) {
              list.add(d);
            }
          }
        } else if (!list.contains(w)) {
          list.add(w);
        }
      }
    }
    return list;
  }

  int wordsSize() {
    if (_henyoWordsList.isEmpty()) {
      return 0;
    }
    return _henyoWordsList.getAll().length;
  }

  int getLatestWordsListDateEntry() {
    int size = wordsSize();
    debug('words list size: $size');
    if (size > 0) {
      return _henyoWordsList.get(size)!.uploadDate;
    }
    return 0;
  }

  int storeKeys(Secure keys) => _secureKeys.put(keys);
  Secure getKeys() => _secureKeys.get(1)!;
  bool isKeysNotEmpty() => _secureKeys.contains(1);
  int getKeysSize() => _secureKeys.count();

  int storeUserSettings(UserSettings settings) => _userSettings.put(settings);
  UserSettings getUserSettings() => _userSettings.get(1)!;
  bool isUserSettingsNotEmpty() => _userSettings.contains(1);
  int getUserSettingsSize() => _userSettings.count();
  // void setAblyApiKey(String key) => _userSettings.get(1)!.setAblyApiKey(key); // use store instead
  String getAblyApiKey() => _userSettings.get(1)!.getAblyApiKey();
  int setAblyApiKey(String key) => _userSettings.get(1)!.setAblyApiKey(key);

  int addUserGuess(UserGuesses guess) => _userGuesses.put(guess);

  // int addMultiPlayerGuess(MultiPlayerGuesses guess) => _userGuesses.put(guess);

  // Future<List<Record>> getRecords() => _recordBox.getAllAsync();
  // Stream<List<Record>> getAllRecords() => _recordBox
  //     .query()
  //     .watch(triggerImmediately: true)
  //     .map((query) => query.find());
  // int addRecord(Record record) => _recordBox.put(record);
  // int getIdFromRecords(String username) {
  //   Query<Record> query =
  //       _recordBox.query(Record_.name.equals(username)).build();
  //   List<Record> recs = query.find();
  //   //assert(users.length == 1);
  //   query.close();
  //   if (recs.isEmpty) return 0;
  //   return recs.first.id;
  // }

  // Record? getRecordFromRecords(String username) {
  //   Query<Record> query =
  //       _recordBox.query(Record_.name.equals(username)).build();
  //   List<Record> recs = query.find();
  //   //assert(users.length == 1);
  //   query.close();
  //   if (recs.isEmpty) return null;
  //   return recs.first;
  // }

  // int updateRecordScore(int score) {
  //   record.score = score;
  //   return _recordBox.put(record);
  // }
}
