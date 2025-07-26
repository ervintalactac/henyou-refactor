import 'dart:convert';
import 'dart:math';
import 'debug.dart';
import 'helper.dart';

class WordObject {
  List alternate = [];
  String guessword = '';
  List associatedWords = [];
  List possibleWords = [];
  String locale = '';
  String difficulty = '';
  String category = '';
  WordObject(
      {required this.alternate,
      required this.guessword,
      required this.associatedWords,
      required this.possibleWords,
      required this.locale,
      required this.difficulty,
      required this.category});

  WordObject.fromJson(var json)
      : alternate = json['alternate'] as List,
        guessword = json['guessword'] as String,
        associatedWords = json['associatedWords'] as List,
        possibleWords = json['possibleWords'] as List,
        locale = json['locale'] as String,
        difficulty = json['difficulty'] as String,
        category = json['category'] as String;

  WordObject copy(WordObject object) {
    WordObject obj = this;
    if (obj.alternate.isNotEmpty) debug(obj.alternate.toString());
    if (object.alternate.isNotEmpty) debug(object.alternate.toString());
    obj.associatedWords.addAll(object.associatedWords);
    obj.possibleWords.addAll(object.possibleWords);
    return obj;
  }

  Map<String, dynamic> toJson() {
    return {
      'difficulty': difficulty,
      'locale': locale,
      'category': category,
      'guessword': guessword,
      'associated': associatedWords,
      'possible': possibleWords,
      'alternate': alternate,
    };
  }

  String getGuessWord() {
    debug(guessword);
    return guessword;
  }

  List getAlternateWords() {
    List temp = [];
    alternate.forEach((value) => temp.add(value.toString().toLowerCase()));
    return temp;
  }

  List getAssociatedWords(Map<String, dynamic> dictionaryMap) {
    List<String> temp = [];
    for (int i = 0; i < associatedWords.length; i++) {
      String text = WordSelection.sanitize(associatedWords[i]);
      if (text.contains('@')) {
        // use unsanitized version of the word to get a match
        // debug(dictionaryMap[associatedWords[i]].toString());
        WordSelection.copyList(temp, dictionaryMap[associatedWords[i]]);
      } else if (!temp.contains(text)) {
        temp.add(text);
      }
    }
    temp.add(category);
    int i = getGimme5Categories('en').indexOf(category.toUpperCase());
    temp.add(getGimme5Categories('ph')[i].toLowerCase());
    temp.addAll(
        locale == 'ph' ? ['tagalog', 'filipino'] : ['english', 'ingles']);
    switch (difficulty) {
      case 'e':
        temp.add('easy');
        break;
      case 'm':
        temp.add('medium');
        break;
      case 'h':
        temp.add('hard');
        break;
    }

    debug(temp.toString());
    return temp;
  }

  List getPossibleWords(Map<String, dynamic> dictionaryMap) {
    List<String> temp = [];
    for (int i = 0; i < possibleWords.length; i++) {
      String text = WordSelection.sanitize(possibleWords[i]);
      if (text.contains('@')) {
        // use unsanitized version of the word to get a match
        // debug(dictionaryMap[possibleWords[i]].toString());
        WordSelection.copyList(temp, dictionaryMap[possibleWords[i]]);
      } else if (!temp.contains(text)) {
        temp.add(text);
      }
    }
    debug(temp.toString());
    return temp;
  }
}

class WordSelection {
  String guessWord;
  List associatedWords;
  List possibleWords;
  String locale;
  String difficulty;
  String category;

  WordSelection(
      {required this.guessWord,
      required this.associatedWords,
      required this.possibleWords,
      required this.locale,
      required this.difficulty,
      required this.category});

  WordSelection.fromJson(Map<String, dynamic> json)
      : guessWord = json['guessWord'] as String,
        associatedWords = json['associatedWords'] as List,
        possibleWords = json['possibleWords'] as List,
        locale = json['locale'] as String,
        difficulty = json['difficulty'] as String,
        category = json['category'] as String;

  String getGuessWord() {
    return guessWord;
  }

  List getAssociatedWords(Map<String, dynamic> dictionaryMap) {
    List<String> temp = [];
    for (int i = 0; i < associatedWords.length; i++) {
      String text = sanitize(associatedWords[i]);
      if (text.contains('@')) {
        // use unsanitized version of the word to get a match
        // debug(dictionaryMap[associatedWords[i]].toString());
        copyList(temp, dictionaryMap[associatedWords[i]]);
      } else if (!temp.contains(text)) {
        temp.add(text);
      }
    }
    debug(temp.toString());
    return temp;
  }

  List getPossibleWords(Map<String, dynamic> dictionaryMap) {
    List<String> temp = [];
    for (int i = 0; i < possibleWords.length; i++) {
      String text = sanitize(possibleWords[i]);
      if (text.contains('@')) {
        // use unsanitized version of the word to get a match
        // debug(dictionaryMap[possibleWords[i]].toString());
        copyList(temp, dictionaryMap[possibleWords[i]]);
      } else if (!temp.contains(text)) {
        temp.add(text);
      }
    }
    debug(temp.toString());
    return temp;
  }

  static void copyList(List<dynamic> copyTo, List<dynamic> copyFrom) {
    for (String item in copyFrom) {
      copyTo.add(item.replaceAll(' ', ''));
    }
  }

  static String sanitize(String word) {
    String text = word.toLowerCase().replaceAll('\'', '');
    if (text.startsWith("mga ")) {
      text = text.replaceFirst("mga ", "");
    } else if (text.startsWith("sa ")) {
      text = text.replaceFirst("sa ", "");
    }
    return text.toLowerCase().replaceAll(" ", "").replaceAll("-", "");
  }
}

class MPWordSelection extends WordSelection {
  MPWordSelection(
      {required super.guessWord,
      required super.associatedWords,
      required super.possibleWords,
      required super.locale,
      required super.difficulty,
      required super.category});
}

class HenyoMPWordsList extends HenyoWordsList {
  MPWordSelection selectRandomMPWord() {
    if (multiplayerWordsMap.isEmpty || getMPWordsListSize() == 0) {
      loadMPWordsList();
    }
    var map = removePreviouslyUsedWords(multiplayerWordsMap, gameMode);
    var index = Random().nextInt(map.keys.length);
    MPWordSelection mpws = MPWordSelection(
      guessWord: map.keys.elementAt(index),
      associatedWords: [],
      possibleWords: [],
      locale: map.values.elementAt(index)['locale'],
      difficulty: map.values.elementAt(index)['difficulty'],
      category: map.values.elementAt(index)['category'],
    );
    // new way: let's keep track of used mp words instead (party needs to use mp list)
    // remove last guess word used to ensure unique words selected next
    // multiplayerWordsMap.remove(multiplayerWordsMap.keys.elementAt(index));
    // MultiPlayerWords mpWords = objectBox.getMPWordsList();
    // mpWords.multiplayerWordsList = jsonEncode(multiplayerWordsMap);
    // objectBox.setMPWordsList(mpWords);
    return mpws;
  }

  void loadMPWordsList() async {
    if (!objectBox.isWordListEmpty()) {
      try {
        multiplayerWordsMap =
            json.decode(objectBox.getMPWordsList().multiplayerWordsList);
        if (multiplayerWordsMap.isNotEmpty) return;
      } catch (e) {
        debug('loadMPWordsList: $e');
      }
    }
    multiplayerWordsMap = jsonDecode(objectBox.getJsonMultiplayerWords());
  }

  int getMPWordsListSize() {
    return multiplayerWordsMap.length;
  }
}

class HenyoWordsList {
  WordObject selectRandomWordObject() {
    // if (wordsMap.isEmpty || getWordsListSize() == 0) {
    //   loadWordsList();
    // }
    // if (dictionaryMap.isEmpty) {
    //   loadDictionaryList();
    // }

    assert(wordsMap.isNotEmpty);

    var map = removePreviouslyUsedWords(wordsMap, gameMode);
    var index = Random().nextInt(map.keys.length);
    WordObject ws = WordObject(
      alternate: map.values.elementAt(index).alternate,
      guessword: map.values.elementAt(index).guessword,
      associatedWords: map.values.elementAt(index).associatedWords,
      possibleWords: map.values.elementAt(index).possibleWords,
      locale: map.values.elementAt(index).locale,
      difficulty: map.values.elementAt(index).difficulty,
      category: map.values.elementAt(index).category,
    );
    // new logic of keeping track previously used words - 08-23-24
    // remove last guess word used to ensure unique words selected next
    // wordsMap.remove(wordsMap.keys.elementAt(index));
    // objectBox.setWordsList(jsonEncode(wordsMap));
    return ws;
  }

  WordSelection selectRandomWord() {
    if (wordsMap.isEmpty || getWordsListSize() == 0) {
      loadWordsList();
    }
    if (dictionaryMap.isEmpty) {
      loadDictionaryList();
    }

    var map = removePreviouslyUsedWords(wordsMap, gameMode);
    var index = Random().nextInt(map.keys.length);
    WordSelection ws = WordSelection(
      guessWord: map.keys.elementAt(index),
      associatedWords: map.values.elementAt(index)['associated'],
      possibleWords: map.values.elementAt(index)['possible'],
      locale: map.values.elementAt(index)['locale'],
      difficulty: map.values.elementAt(index)['difficulty'],
      category: map.values.elementAt(index)['category'],
    );
    // new logic of keeping track previously used words - 08-23-24
    // remove last guess word used to ensure unique words selected next
    // wordsMap.remove(wordsMap.keys.elementAt(index));
    // objectBox.setWordsList(jsonEncode(wordsMap));
    return ws;
  }

  List<WordObject> selectGimme5RandomWords(
      String locale, String difficulty, String category) {
    if (wordsMap.isEmpty || getWordsListSize() == 0) {
      loadWordsList();
    }
    if (dictionaryMap.isEmpty) {
      loadDictionaryList();
    }
    List<WordObject> wordsList = [];
    Map<String, dynamic> tempMap = {};

    if (category.isEmpty) {
      tempMap = wordsMap;
    } else {
      wordsMap.forEach((key, value) {
        if (value.category == category && value.difficulty == difficulty) {
          if ((locale == 'en' && value.locale == 'en') || locale == 'ph') {
            tempMap.putIfAbsent(key, () => value);
          }
        }
      });
    }
    Map<String, dynamic> keyMap = {};
    while (wordsList.length < 5) {
      var map = removePreviouslyUsedWords(tempMap, gameMode);
      var index = Random().nextInt(map.length);
      keyMap.putIfAbsent(map.keys.elementAt(index), () {
        var temp = map.values.elementAt(index).associatedWords;
        temp.addAll(
            locale == 'ph' ? ['tagalog', 'filipino'] : ['english', 'ingles']);
        try {
          temp.add(category);
          int i = getGimme5Categories('en').indexOf(category.toUpperCase());
          temp.add(getGimme5Categories('ph')[i].toLowerCase());
        } catch (e) {
          debug(e.toString());
        }
        wordsList.add(WordObject(
          guessword: map.values.elementAt(index).guessword,
          alternate: map.values.elementAt(index).alternate,
          associatedWords: temp,
          possibleWords: map.values.elementAt(index).possibleWords,
          locale: map.values.elementAt(index).locale,
          difficulty: map.values.elementAt(index).difficulty,
          category: map.values.elementAt(index).category,
        ));
        usedHenyoWordsToGuess.add(tempMap.keys.elementAt(index));
        saveWordsHistory();
      });
    }
    // remove last guess word used to ensure unique words selected next
    return wordsList;
  }

  int getWordsListSize() {
    return wordsMap.length;
  }

  // static void loadWord() {
  //   //await wait(3);
  //   loadJson().then((value) {
  //     parsedJson = json.decode(value);
  //   });
  // }

  void loadWordsList() async {
    // if (objectBox.wordsSize() > 0) {
    //   wordsMap = json.decode(objectBox.getWordsList());
    //   return;
    // }
    fetchLatestWordsList();
    // fetchJsonWords();
    // wordsMap = jsonDecode(objectBox.getJsonWords());
  }

  void loadDictionaryList() async {
    if (objectBox.dictionarySize() > 0) {
      dictionaryMap = json.decode(objectBox.getDictionaryList());
      return;
    }
    dictionaryMap = jsonDecode(objectBox.getJsonDictionaryWords());
  }
}
