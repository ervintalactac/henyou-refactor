import 'package:objectbox/objectbox.dart';

@Entity()
class HenyoWords {
  @Id()
  int id;
  int uploadDate;
  String wordsList;
  String dictionaryList;
  // String multiplayerWordsList;

  HenyoWords({
    this.id = 0,
    this.uploadDate = 0,
    this.wordsList = '',
    this.dictionaryList = '',
    // this.multiplayerWordsList = '',
  });

  void setWordsList(String w) {
    wordsList = w;
  }

  String getWordsList() {
    return wordsList;
  }

  String getDictionaryList() {
    return dictionaryList;
  }

  int getUploadDate() {
    return uploadDate;
  }

  bool isEmpty() => isEmpty();
}

@Entity()
class Secure {
  @Id()
  int id;
  String publicKey;
  String privateKey;

  Secure({
    this.id = 0,
    required this.publicKey,
    required this.privateKey,
  });

  String getPublicKey() {
    return publicKey;
  }

  String getPrivateKey() {
    return privateKey;
  }

  bool isEmpty() => isEmpty();
}

@Entity()
class UserSettings {
  @Id()
  int id;
  int colorTheme;
  String difficulty;
  String locale;
  int splashPageMessageTimestamp;
  String serverPublicKey;
  bool enableSpeechTotext;
  bool removeAds;
  int dailyRewardLastGiven;
  String ablyApiKey;
  int nextRewardTimestamp;
  bool autoStartVoiceEntry;
  bool showHistory;
  bool useCustomKeyboard;

  UserSettings({
    this.id = 0,
    this.colorTheme = 4284572001, // grey.shade700
    this.difficulty = 'e',
    this.locale = 'ph',
    this.splashPageMessageTimestamp = 0,
    this.serverPublicKey = '',
    this.enableSpeechTotext = false,
    this.removeAds = false,
    this.dailyRewardLastGiven = 0,
    this.ablyApiKey = '',
    this.nextRewardTimestamp = 0,
    this.autoStartVoiceEntry = false,
    this.showHistory = false,
    this.useCustomKeyboard = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'difficulty': difficulty,
      'locale': locale,
      'splashPageMessageTimestamp': splashPageMessageTimestamp,
      'enableSpeechTotext': enableSpeechTotext,
      'dailyRewardLastGiven': dailyRewardLastGiven,
      'autoStartVoiceEntry': autoStartVoiceEntry,
      'showHistory': showHistory,
      'useCustomKeyboard': useCustomKeyboard,
    };
  }

  setAblyApiKey(String ablyApiKey) {
    this.ablyApiKey = ablyApiKey;
  }

  String getAblyApiKey() {
    return ablyApiKey;
  }

  setColorTheme(int colorTheme) {
    this.colorTheme = colorTheme;
  }

  int getColorTheme() => colorTheme;

  setDifficulty(String difficulty) {
    this.difficulty = difficulty;
  }

  String getDifficulty() => difficulty;

  setLocale(String locale) {
    this.locale = locale;
  }

  String getLocale() => locale;

  setSplashPageMessageTS(int timestamp) {
    splashPageMessageTimestamp = timestamp;
  }

  int getSplashPageMessageTS() => splashPageMessageTimestamp;

  setDailyRewardLastGiven(int timestamp) {
    dailyRewardLastGiven = timestamp;
  }

  int getDailyRewardLastGiven() => dailyRewardLastGiven;

  setServerPublicKey(String publicKey) {
    serverPublicKey = publicKey;
  }

  String getServerPublicKey() => serverPublicKey;

  setEnableSpeechToText(bool enable) {
    enableSpeechTotext = enable;
  }

  bool getEnableSpeechToText() => enableSpeechTotext;

  setRemoveAds(bool enable) {
    removeAds = enable;
  }

  bool getRemoveAds() => removeAds;

  bool isEmpty() => isEmpty();

  bool getAutoStartVoiceEntry() => autoStartVoiceEntry;

  setAutoStartVoiceEntry(bool enable) {
    autoStartVoiceEntry = enable;
  }

  bool getShowHistory() => showHistory;

  setShowHistory(bool enable) {
    showHistory = enable;
  }

  bool getUseCustomKeyboard() => useCustomKeyboard;

  setUseCustomKeyboard(bool enable) {
    useCustomKeyboard = enable;
  }
}

@Entity()
class User {
  @Id()
  int id;
  String username;
  String alias;
  int score;
  int totalScore;
  int streak;
  int totalStreak;
  int credits;

  User({
    this.id = 0,
    required this.username,
    this.alias = '',
    this.score = 0,
    this.totalScore = 0,
    this.streak = 0,
    this.totalStreak = 0,
    this.credits = 1000,
  });

  setUsername(String name) {
    username = name;
  }

  setAlias(String name) {
    alias = name;
  }

  setScore(int newScore) {
    score = newScore;
  }

  addToScore(int scoreToAdd) {
    score += scoreToAdd;
  }

  setTotalScore(int newScore) {
    totalScore = newScore;
  }

  addToTotalScore(int scoreToAdd) {
    totalScore += scoreToAdd;
  }

  int resetScore() {
    return score = 0;
  }

  int resetTotalScore() {
    return totalScore = 0;
  }

  int resetStreak() {
    return streak = 0;
  }

  int resetTotalStreak() {
    return totalStreak = 0;
  }

  setCredits(int newCredits) {
    credits = newCredits;
  }

  addToCredits(int creditsToAdd) {
    credits = credits + creditsToAdd;
  }

  int incrementStreak() {
    return ++streak;
  }

  int incrementTotalStreak() {
    return ++totalStreak;
  }

  Record convertUserDataToRecord() {
    return Record(
      name: username,
      alias: alias,
      score: score,
      totalScore: totalScore,
      streak: streak,
      totalStreak: totalStreak,
    );
  }
}

@Entity()
@Sync()
class Record {
  @Id()
  int id;
  String name;
  String alias;
  int score;
  int totalScore;
  int streak;
  int totalStreak;
  int created;
  int modified;
  String extraData;
  String secureData;

  final records = ToMany<Record>();

  Record({
    this.id = 0,
    required this.name,
    this.alias = '',
    this.score = 0,
    this.totalScore = 0,
    this.streak = 0,
    this.totalStreak = 0,
    this.created = 0,
    this.modified = 0,
    this.extraData = '{}',
    this.secureData = '{}',
  });

  setScore(int newScore) {
    score = newScore;
  }

  setTotalScore(int newScore) {
    score = newScore;
  }

  setStreak(int newStreak) {
    streak = newStreak;
  }

  setUsername(String username) {
    name = username;
  }

  setAlias(String name) {
    alias = name;
  }

  getRecords() {
    return records;
  }

  Record.fromJson(Map<String, dynamic> json)
      : id = int.parse(json['id']),
        name = json['name'],
        alias = json['alias'],
        score = int.parse(json['score']),
        totalScore = int.parse(json['totalScore']),
        streak = int.parse(json['streak']),
        totalStreak = int.parse(json['totalStreak']),
        created = json['created'],
        modified = json['modified'],
        extraData = json['extraData'],
        secureData = json['secureData'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'alias': alias,
      'score': score,
      'totalScore': totalScore,
      'streak': streak,
      'created': created,
      'modified': modified,
      'extraData': extraData,
      'secureData': secureData,
    };
  }
}

@Entity()
class UserGuesses {
  @Id()
  int id;
  int timestamp;
  String name;
  String word;
  String attempts;
  String extraData;

  UserGuesses({
    this.id = 0,
    this.timestamp = 0,
    this.name = '',
    this.word = '',
    this.attempts = '',
    this.extraData = '',
  });

  bool isEmpty() => isEmpty();

  UserGuesses.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        timestamp = json['timestamp'],
        word = json['word'],
        extraData = json['extraData'],
        attempts = json['attempts'];

  Map<String, dynamic> toJson() {
    return {
      '"name"': '"$name"',
      '"word"': '"$word"',
      '"extraData"': extraData,
      '"attempts"': attempts,
    };
  }
}

@Entity()
class MultiPlayerGuesses {
  @Id()
  int id;
  int timestamp;
  String guesser;
  String cluegiver;
  String word;
  String attempts;
  String extradata;

  MultiPlayerGuesses({
    this.id = 0,
    this.timestamp = 0,
    this.guesser = '',
    this.cluegiver = '',
    this.word = '',
    this.attempts = '',
    this.extradata = '',
  });

  bool isEmpty() => isEmpty();

  MultiPlayerGuesses.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        guesser = json['guesser'],
        cluegiver = json['cluegiver'],
        timestamp = json['timestamp'],
        word = json['word'],
        extradata = json['extradata'],
        attempts = json['attempts'];

  Map<String, dynamic> toJson() {
    return {
      '"guesser"': '"$guesser"',
      '"cluegiver"': '"$cluegiver"',
      '"word"': '"$word"',
      '"extradata"': extradata,
      '"attempts"': attempts,
    };
  }
}

class Gimme5Guesses {
  int id;
  int timestamp;
  String round;
  String name;
  String words;
  String attempts;
  String extradata;

  Gimme5Guesses({
    this.id = 0,
    this.timestamp = 0,
    this.round = '',
    this.name = '',
    this.words = '',
    this.attempts = '',
    this.extradata = '',
  });

  bool isEmpty() => isEmpty();

  Gimme5Guesses.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        round = json['round'],
        name = json['name'],
        timestamp = json['timestamp'],
        words = json['words'],
        extradata = json['extradata'],
        attempts = json['attempts'];

  Map<String, dynamic> toJson() {
    return {
      '"round"': '"$round"',
      '"name"': '"$name"',
      '"words"': '"$words"',
      '"extradata"': extradata,
      '"attempts"': attempts,
    };
  }
}

@Entity()
class MultiPlayerWords {
  int id;
  int uploadDate;
  String multiplayerWordsList;

  MultiPlayerWords({
    this.id = 0,
    this.uploadDate = 0,
    this.multiplayerWordsList = '',
  });

  String getMultiplayerWordsList() {
    return multiplayerWordsList;
  }

  void setMultiPlayerWordsList(String mpw) {
    multiplayerWordsList = mpw;
  }
}

@Entity()
class GlobalMessages {
  @Id()
  int id;
  String howToPlayMessage;
  String howToPlayMessagePH;
  String howToPlayMessageEN;
  String scoreBreakDownMessage;
  String difficultyEasyLabelPH;
  String difficultyEasyLabelEN;
  String difficultyMediumLabelPH;
  String difficultyMediumLabelEN;
  String difficultyHardLabelPH;
  String difficultyHardLabelEN;
  String backupRestoreMessagePH;
  String backupRestoreMessageEN;
  String partyModeMessagePH;
  String partyModeMessageEN;
  String weeklyWinnerFirstPlacePH;
  String weeklyWinnerFirstPlaceEN;
  String weeklyWinnerSecondPlacePH;
  String weeklyWinnerSecondPlaceEN;
  String weeklyWinnerThirdPlacePH;
  String weeklyWinnerThirdPlaceEN;
  String dailyTokenRewardMessagePH;
  String dailyTokenRewardMessageEN;
  String microphoneDeniedTitlePH;
  String microphoneDeniedTitleEN;
  String microphonePermanentlyDeniedMessagePH;
  String microphonePermanentlyDeniedMessageEN;
  String microphoneDeniedMessagePH;
  String microphoneDeniedMessageEN;
  String useHintMessagePH;
  String useHintMessageEN;
  String infoGamePageTitlePH;
  String infoGamePageTitleEN;
  String infoGamePageMessagePH;
  String infoGamePageMessageEN;
  String infoMultiPlayerPageTitlePH;
  String infoMultiPlayerPageTitleEN;
  String infoMultiPlayerPageMessagePH;
  String infoMultiPlayerPageMessageEN;
  String infoMultiPlayerGuesserPageTitlePH;
  String infoMultiPlayerGuesserPageTitleEN;
  String infoMultiPlayerGuesserPageMessagePH;
  String infoMultiPlayerGuesserPageMessageEN;
  String infoMultiPlayerClueGiverTitlePH;
  String infoMultiPlayerClueGiverTitleEN;
  String infoMultiPlayerClueGiverMessagePH;
  String infoMultiPlayerClueGiverMessgaeEN;
  String infoPartyModeTitlePH;
  String infoPartyModeTitleEN;
  String infoPartyModeMessagePH;
  String infoPartyModeMessageEN;
  String infoLeaderBoardTitlePH;
  String infoLeaderBoardTitleEN;
  String infoLeaderBoardMessagePH;
  String infoLeaderBoardMessageEN;
  String infoSettingsPageTitlePH;
  String infoSettingsPageTitleEN;
  String infoSettingsPageMessagePH;
  String infoSettingsPageMessageEN;
  String infoBackupRestoreTitlePH;
  String infoBackupRestoreTitleEN;
  String infoBackupRestoreMessagePH;
  String infoBackupRestoreMessageEN;
  String infoGimme5Round1TitlePH;
  String infoGimme5Round1TitleEN;
  String infoGimme5Round1MessagePH;
  String infoGimme5Round1MessageEN;
  String infoGimme5Round2TitlePH;
  String infoGimme5Round2TitleEN;
  String infoGimme5Round2MessagePH;
  String infoGimme5Round2MessageEN;
  String infoGimme5Round3TitlePH;
  String infoGimme5Round3TitleEN;
  String infoGimme5Round3MessagePH;
  String infoGimme5Round3MessageEN;
  String infoGimme5TitleName;
  String infoMainMenuGimme5Title;
  String infoMainMenuSoloTitle;
  String infoMainMenuMultiPlayer5Title;
  String infoMainMenuPartyTitle;

  GlobalMessages({
    this.id = 0,
    this.howToPlayMessage =
        "Game Instructions:\n\nHenyo U?! (Are you a genius?!)\n\n\$instructions\n\nErvin Talactac\n(Proudly Filipino Made, Magaling Ang Atin!)\n\nSend your inquiries or feedback to henyo@esaflip.com",
    this.howToPlayMessagePH =
        "Ang larong ito ay hango sa Pinoy Henyo ng Eat Bulaga (TM) ngunit para sa isang manlalaro lamang. May isang salitang dapat hulaan na papatak sa isa sa 5 pangunahing kategorya, Tao, Lugar, Bagay, Hayop o Pagkain. Ilagay mo ang iyong hula at tutugon ang app ng \"OO, Pwede o Hindi\" batay sa salitang iyong inilagay. Tukuyin mo ang salita na dapat hulaan sa pamamagitan ng iyong mga sinubukang hula kaya tandaan ang mga salitang nakakakuha ng \"OO o Pwede\". Mayroon kang 2 minuto para hulaan ang salita at sa huling 10 segundo, bibigyan ka ng app ng balasadong salita bilang isang pahiwatig.\n\n2 Player Mode\nPwede na kayong maglaro ng game na 'to kalaro ang ibang tao na meron ding app sa smartphone nila kahit saan man sa mundo. Kailangan din mahulaan sa dalawang minuto at kapag nahulaan ay may puntos at token na makakamit.\n\nSalamat sa paglalaro!",
    this.howToPlayMessageEN =
        "This game is inspired by Eat Bulaga's (TM) Pinoy Henyo (now Gimme 5) but in a one player mode. A random word is selected that can fall into one of the 5 main categories, Person, Place, Thing, Animal or Food. You type in your guess word and the app will respond Yes, Close or No based on the word you entered. You narrow down on the word by your attempted guesses so remember the words that gets a Yes or Close. You'll have 2 minutes to guess the word and on the last 10 seconds, the app will give you the shuffled version of the word to guess as a clue.\n\n2 Player Mode\nPlay with another player who has installed the app, one being the guesser and the other as the one giving clues. Same game play as the one player mode with preset answers and same time limit. Score and tokens are also rewarded.\n\nThanks for playing!",
    this.scoreBreakDownMessage =
        'How points are rewarded:\nDifficulty\t\t\t\t\t\t\t\t\tE\t\t\t\tM\t\t\t\tH\n91-120secs\t\t\t\t12\t\t16\t\t\t20\n61-90secs\t\t\t\t\t\t\t9\t\t\t12\t\t\t15\n31-60secs\t\t\t\t\t\t\t6\t\t\t\t8\t\t\t\t10\n0.1-30secs\t\t\t\t\t\t3\t\t\t\t4\t\t\t\t\t5',
    this.difficultyEasyLabelPH =
        'Only regular words to be guessed are selected',
    this.difficultyEasyLabelEN =
        'Only regular words to be guessed are selected',
    this.difficultyMediumLabelPH = 'Regular and hard words are selected',
    this.difficultyMediumLabelEN = 'Regular and hard words are selected',
    this.difficultyHardLabelPH = 'All words are selected',
    this.difficultyHardLabelEN = 'All words are selected',
    this.backupRestoreMessagePH =
        '(Optional) Enter your email address to back up your records. Your email will only be used to restore your game records in case you lost or obtained a new phone. This data will be stored encrypted on our end. It will never be shared to third party companies.\n\nAnother alternative to restore your account is to email me a screenshot of your home screen. You\'ll then get a return email containing a code you can use to restore your game account records.',
    this.backupRestoreMessageEN =
        '(Optional) Enter your email address to back up your records. Your email will only be used to restore your game records in case you lost or obtained a new phone. This data will be stored encrypted on our end. It will never be shared to third party companies.\n\nAnother alternative to restore your account is to email me a screenshot of your home screen. You\'ll then get a return email containing a code you can use to restore your game account records.',
    this.partyModeMessagePH =
        'Intructions:\nHold the phone above your head if you\'re the guesser after starting the game. Have the other people/person in front of you give you the clue by saying Yes, Close or No based out of the word to guess.\n\nEnable the microphone to detect your answers and automatically give you audible clues.',
    this.partyModeMessageEN =
        'Intructions:\nHold the phone above your head if you\'re the guesser after starting the game. Have the other people/person in front of you give you the clue by saying Yes, Close or No based out of the word to guess.\n\nEnable the microphone to detect your answers and automatically give you audible clues.',
    this.weeklyWinnerFirstPlacePH =
        "Congrats on winning 1st place with last week's tournament! You've earned \$reward token reward!!",
    this.weeklyWinnerFirstPlaceEN =
        "Congrats on winning 1st place with last week's tournament! You've earned \$reward token reward!!",
    this.weeklyWinnerSecondPlacePH =
        "You won 2nd place with last week's tournament! You've earned \$reward token reward!!",
    this.weeklyWinnerSecondPlaceEN =
        "You won 2nd place with last week's tournament! You've earned \$reward token reward!!",
    this.weeklyWinnerThirdPlacePH =
        "You've placed 3rd with last week's tournament! You've earned \$reward token reward!!",
    this.weeklyWinnerThirdPlaceEN =
        "You've placed 3rd with last week's tournament! You've earned \$reward token reward!!",
    this.dailyTokenRewardMessagePH =
        "You just earned \$dailyTokenReward tokens for playing regularly!",
    this.dailyTokenRewardMessageEN =
        "You just earned \$dailyTokenReward tokens for playing regularly!",
    this.microphoneDeniedTitlePH = "Unable to use Voice Entry feature!",
    this.microphoneDeniedTitleEN = "Unable to use Voice Entry feature!",
    this.microphonePermanentlyDeniedMessagePH =
        "The game needs access to the microphone to enable answers by voice. Please enable this from the Phone Settings.\nApple: Settings > Henyo U?!\nAndroid: Settings > Apps & Notifications > Henyo U?!",
    this.microphonePermanentlyDeniedMessageEN =
        "The game needs access to the microphone to enable answers by voice. Please enable this from the Phone Settings.\nApple: Settings > Henyo U?!\nAndroid: Settings > Apps & Notifications > Henyo U?!",
    this.microphoneDeniedMessagePH =
        "The game needs access to the microphone to enable answers by voice",
    this.microphoneDeniedMessageEN =
        "The game needs access to the microphone to enable answers by voice",
    this.useHintMessagePH =
        "This will shuffle guess word and will cost you \$hintFee tokens. Reward will also be cut in half on correct guess.",
    this.useHintMessageEN =
        "This will shuffle guess word and will cost you \$hintFee tokens. Reward will also be cut in half on correct guess.",
    this.infoGamePageTitlePH = "Panno 'to laruin?",
    this.infoGamePageTitleEN = "How To Play?",
    this.infoGamePageMessagePH =
        "Pipili and app ng kahit ano mang salita na nabibilang sa isa sa 5 pangunahing kategorya, Tao, Lugar, Bagay, Hayop o Pagkain. I-type mo ang mga salitang hula (o ngayon ay opsyonal na sabihin ang iyong mga entry) at tutugon ang app ng \"Oo, Pwede o Hindi\" batay sa salitang iyong inilagay. Tukuyin mo ang salita sa pamamagitan ng iyong mga sinubukang hula kaya tandaan ang mga salitang nakakakuha ng Oo o Pwede. Meron kang 2 minuto para hulaan ang salita at sa huling 10 segundo, bibigyan ka ng app ng shuffled na bersyon ng salita para mas madaling mahulaan ang salita. Mananalo ka ng mga token base sa kung gaano kabilis at kahirap ang salitang huhulaan.",
    this.infoGamePageMessageEN =
        "A random word is selected that falls into one of the 5 main categories, Person, Place, Thing, Animal or Food. You type in the guess words (or now optionally speak your entries) and the app will respond \"Yes, Close or No\" based on the word you entered. You narrow down on the word by your attempted guesses so remember the words that gets a Yes or Close. You'll have 2 minutes to guess the word and on the last 10 seconds, the app will give you the shuffled version of the word to guess as a clue. Tokens awarded for how fast and difficult the guess word was.",
    this.infoMultiPlayerPageTitlePH = "Panno 'to laruin?",
    this.infoMultiPlayerPageTitleEN = "How To Play?",
    this.infoMultiPlayerPageMessagePH =
        "Dalawang tao na may kanilang mga sariling smartphone at naka-install ang app na ito ay kinakailangan upang magamit ang tampok na ito. Pinipili ng isa na maging manghuhula at ang isa ay tagabigay ng clue tulad ng game show. Ita-type o ngayon ay masasabi na ni Guesser (opsyonal) ang iyong mga entry sa hula, pagkatapos ay maaaring tumugon ang nagbibigay ng clue ng \"Oo, Pwede o Hindi\" batay sa iyong hulang salita. Mayroon ka ring 2 minuto upang hulaan ang salita. Makakakuha ka rin ng mga token base sa kung gaano kabilis at kahirap ang salitang huhulaan.",
    this.infoMultiPlayerPageMessageEN =
        "Two persons with their individual devices and this app installed is required to use this feature. One chooses to be the guesser and the other the clue giver just like the game show. Guesser will type or now be able to speak (optional) your guess entries, then the clue giver can respond \"Yes, Close or No\" based on your guess word. You also have 2 minutes to guess the word. Tokens awarded for how fast and difficult the guess word was.",
    this.infoMultiPlayerGuesserPageTitlePH = "Panno 'to laruin?",
    this.infoMultiPlayerGuesserPageTitleEN = "How To Play?",
    this.infoMultiPlayerGuesserPageMessagePH =
        "Huhulaan mo ang iba't ibang salita sa screen na ito. I-type o sabihin ang iyong mga sagot at bibigyan ka ng iyon kalaro ng mga sagot na \"Oo, Isara o Hindi\" base sa gaano kalapit yung salita na binigay mo kumpara sa salitang hinuhuluan. Lalabas ang hint button pagkatapos ng 10 pagsubok. Ang mapapalanunang token ay naaayon batay sa bilis at kahirapan ng mga salitang hinuhulaan. I-tap ang \"Start Button\" kapag handa ka na at ang parehong button ay magiging \"Submit\" button upang ipadala ang iyong hula sa iyong kalaro.",
    this.infoMultiPlayerGuesserPageMessageEN =
        "You will be guessing the random word on this screen. Type or speak your answers and the other player will be giving you clues of \"Yes, Close or No\". Hint will be available after 10 tries. Tokens will be rewarded accordingly based on speed and difficulty of the guess word. Hit the \"Start Button\" when you're ready and the same button will become \"Submit\" button to send your guess to the other player.",
    this.infoMultiPlayerClueGiverTitlePH = "Panno 'to laruin?",
    this.infoMultiPlayerClueGiverTitleEN = "How To Play?",
    this.infoMultiPlayerClueGiverMessagePH =
        "Ikaw ang tagabigay ng clue sa screen na ito. Kapag sinimulan na ng manghuhula ang laro, lalabas ang salitang huhulaan sa itaas at magsisimula ang 2 minutong timer. Hintayin ang tugon ng manghuhula pagkatapos ay maaari kang sumagot ng \"Oo, Pwede o Hindi\" batay sa salitang isinumite ng manghuhula sa pamamagitan ng pagpindot sa kaukulang mga pindutan sa ibaba ng screen. Ang mapapalanunang token ay naaayon batay sa bilis at kahirapan ng mga salitang hinuhulaan.",
    this.infoMultiPlayerClueGiverMessgaeEN =
        "You are the clue giver on this screen. Once the guesser starts the game, the guess word will appear on the top and the 2 minute timer will start. Wait for the guesser's response then you can answer \"Yes, Close or No\" based on the word the guesser submitted by tappping on the corresponding buttons below the screen. Tokens will be rewarded accordingly based on speed and difficulty of the guess word.",
    this.infoPartyModeTitlePH = "Panno 'to laruin?",
    this.infoPartyModeTitleEN = "How To Play?",
    this.infoPartyModeMessagePH =
        "Pwede nang gamitin and app na ito para makipaglaro sa mga kapamilya at kaibigan kung saan hawak ng manghuhula ang kanilang smartphone (nakaharap ang screen sa audience) at hulaan ang ipinapakitang salita habang ang iba ay nagbibigay din ng mga sagot na \"Oo, Pwede o Hindi.\" Subukan ang feature na Henyo Assist kung saan ang app ay makikilaro at magbibigay din ng mga pahiwatig na \"Oo, Pwede o Hindi\" sa manghuhula kasama ang ibang taong nagbibigay ng clue. Kaliangan din makuha sa 2 minuto and salitang hinuhulaan.",
    this.infoPartyModeMessageEN =
        "This feature let's you play with families and friends where the guesser hold their mobile phone (screen facing the audience) and guess the word displayed while the rest gives the guesser clues by also giving \"Yes, Close or No\" answers. Try the Henyo Assist feature where the game app will also provide \"Yes, Close or No\" clues to the guesser along with the clue givers. You'll have 2 minutes to guess the word.",
    this.infoLeaderBoardTitlePH = 'About this page',
    this.infoLeaderBoardTitleEN = 'About this page',
    this.infoLeaderBoardMessagePH =
        "Ang pahinang ito ay para makita kung sino ang nagunguna sa mundo sa pagitan ng kabuuang puntos at bilang ng sunod-sunod na panalo. I-tap ang tab na \"Weekly Rankings\" upang makita ang katayuan ng lingguhang paligsahan.",
    this.infoLeaderBoardMessageEN =
        "This page displays Global total score and streak standings. Tap on the \"Weekly Winners\" tab to view the standings of weekly tournament.",
    this.infoSettingsPageTitlePH = 'About this page',
    this.infoSettingsPageTitleEN = 'About this page',
    this.infoSettingsPageMessagePH =
        "Change name\nBinibigyan ka ng opsyong lumipat sa ibang username. Ang mga custom na username ay isasaalang-alang sa hinaharap.\n\nWhat's New\nTingnan kung ano ang bago sa bersyong ito ng app.\n\nBackup/Restore\nNagbibigay-daan sa iyong i-backup ang data ng iyong laro sa pamamagitan ng pagpasok ng iyong email (hindi kailanman ibabahagi at maiimbak na naka-encrypt). Maaari kang makatanggap ng code kapag nakumpleto mo na ang isang backup upang ibalik ang iyong data ng laro sa ibang device.\n\nChange Color Theme\nMaaari mong i-customize ang kulay ng tema ng app ayon sa gusto mo.",
    this.infoSettingsPageMessageEN =
        "Change name\nGives you an option to switch to a different username. Custom usernames will be considered in the future.\n\nWhat's New\nSee what's new in this version of the app.\n\nBackup/Restore\nEnables you to backup your game data by entering your email (will never be shared and stored encrypted). You can receive a code once you have completed a backup to restore your game data on a different device.\n\nChange Color Theme\nYou can customize the color thme of the app to your liking.",
    this.infoBackupRestoreTitlePH = 'About this page',
    this.infoBackupRestoreTitleEN = 'About this page',
    this.infoBackupRestoreMessagePH = '',
    this.infoBackupRestoreMessageEN = '',
    this.infoGimme5Round1TitlePH = "Panno 'to laruin?",
    this.infoGimme5Round1TitleEN = "How To Play?",
    this.infoGimme5Round1MessagePH = """Instructions: 
After selecting amount of tokens as wager,  you just need to get 3 out of 5 correct answers on every round to double your wager.
If you get perfect score by getting all 5 correct answers on every round then you win four times your wager.
You'll lose your wager if you don't get to answer at least 3 correct ones on this and succeeding rounds.
""",
    this.infoGimme5Round1MessageEN = """Instructions: 
After selecting amount of tokens as wager,  you just need to get 3 out of 5 correct answers on every round to double your wager.
If you get perfect score by getting all 5 correct answers on every round then you win four times your wager.
You'll lose your wager if you don't get to answer at least 3 correct ones on this and succeeding rounds.
""",
    this.infoGimme5Round2TitlePH = "Panno 'to laruin?",
    this.infoGimme5Round2TitleEN = "How To Play?",
    this.infoGimme5Round2MessagePH =
        "Pipili and app ng kahit ano mang salita na nabibilang sa isa sa 5 pangunahing kategorya, Tao, Lugar, Bagay, Hayop o Pagkain. I-type mo ang mga salitang hula (o ngayon ay opsyonal na sabihin ang iyong mga entry) at tutugon ang app ng \"Oo, Pwede o Hindi\" batay sa salitang iyong inilagay. Tukuyin mo ang salita sa pamamagitan ng iyong mga sinubukang hula kaya tandaan ang mga salitang nakakakuha ng Oo o Pwede. Meron kang 2 minuto para hulaan ang salita at sa huling 10 segundo, bibigyan ka ng app ng shuffled na bersyon ng salita para mas madaling mahulaan ang salita. Mananalo ka ng mga token base sa kung gaano kabilis at kahirap ang salitang huhulaan.",
    this.infoGimme5Round2MessageEN =
        "A random word is selected that falls into one of the 5 main categories, Person, Place, Thing, Animal or Food. You type in the guess words (or now optionally speak your entries) and the app will respond \"Yes, Close or No\" based on the word you entered. You narrow down on the word by your attempted guesses so remember the words that gets a Yes or Close. You'll have 2 minutes to guess the word and on the last 10 seconds, the app will give you the shuffled version of the word to guess as a clue. Tokens awarded for how fast and difficult the guess word was.",
    this.infoGimme5Round3TitlePH = "Panno 'to laruin?",
    this.infoGimme5Round3TitleEN = "How To Play?",
    this.infoGimme5Round3MessagePH =
        "Pipili and app ng kahit ano mang salita na nabibilang sa isa sa 5 pangunahing kategorya, Tao, Lugar, Bagay, Hayop o Pagkain. I-type mo ang mga salitang hula (o ngayon ay opsyonal na sabihin ang iyong mga entry) at tutugon ang app ng \"Oo, Pwede o Hindi\" batay sa salitang iyong inilagay. Tukuyin mo ang salita sa pamamagitan ng iyong mga sinubukang hula kaya tandaan ang mga salitang nakakakuha ng Oo o Pwede. Meron kang 2 minuto para hulaan ang salita at sa huling 10 segundo, bibigyan ka ng app ng shuffled na bersyon ng salita para mas madaling mahulaan ang salita. Mananalo ka ng mga token base sa kung gaano kabilis at kahirap ang salitang huhulaan.",
    this.infoGimme5Round3MessageEN =
        "A random word is selected that falls into one of the 5 main categories, Person, Place, Thing, Animal or Food. You type in the guess words (or now optionally speak your entries) and the app will respond \"Yes, Close or No\" based on the word you entered. You narrow down on the word by your attempted guesses so remember the words that gets a Yes or Close. You'll have 2 minutes to guess the word and on the last 10 seconds, the app will give you the shuffled version of the word to guess as a clue. Tokens awarded for how fast and difficult the guess word was.",
    this.infoGimme5TitleName = "Gimme 5",
    this.infoMainMenuGimme5Title = "Henyo Gimme5",
    this.infoMainMenuSoloTitle = "Henyo Solo",
    this.infoMainMenuMultiPlayer5Title = "Henyo 2Player",
    this.infoMainMenuPartyTitle = "Henyo Party",
  });

  String getUseHintMessage(String locale) {
    return locale == 'ph' ? useHintMessagePH : useHintMessageEN;
  }

  String getMicrophoneDeniedTitle(String locale) {
    return locale == 'ph' ? microphoneDeniedTitlePH : microphoneDeniedTitleEN;
  }

  String getMicrophoneDeniedMessage(String locale) {
    return locale == 'ph'
        ? microphoneDeniedMessagePH
        : microphoneDeniedMessageEN;
  }

  String getMicrophonePermanentlyDeniedMessage(String locale) {
    return locale == 'ph'
        ? microphonePermanentlyDeniedMessagePH
        : microphonePermanentlyDeniedMessageEN;
  }

  String getDailyTokenRewardMessage(String locale) {
    return locale == 'ph'
        ? dailyTokenRewardMessagePH
        : dailyTokenRewardMessageEN;
  }

  String getWeeklyWinnerFirstPlaceMessage(String locale) {
    return locale == 'ph' ? weeklyWinnerFirstPlacePH : weeklyWinnerFirstPlaceEN;
  }

  String getWeeklySecondPlaceMessage(String locale) {
    return locale == 'ph'
        ? weeklyWinnerSecondPlacePH
        : weeklyWinnerSecondPlaceEN;
  }

  String getWeeklyWinnerThirdPlaceMessage(String locale) {
    return locale == 'ph' ? weeklyWinnerThirdPlacePH : weeklyWinnerThirdPlaceEN;
  }

  String getPartyModeMessage(String locale) {
    return locale == 'ph' ? partyModeMessagePH : partyModeMessageEN;
  }

  String getHowToPlayMessage(String locale) {
    return howToPlayMessage.replaceFirst('\$instructions',
        locale == 'ph' ? howToPlayMessagePH : howToPlayMessageEN);
  }

  String getDifficultyEasyLabel(String locale) {
    return locale == 'ph' ? difficultyEasyLabelPH : difficultyEasyLabelEN;
  }

  String getDifficultyMediumLabel(String locale) {
    return locale == 'ph' ? difficultyMediumLabelPH : difficultyMediumLabelEN;
  }

  String getDifficultyHardLabel(String locale) {
    return locale == 'ph' ? difficultyHardLabelPH : difficultyHardLabelEN;
  }

  String getBackupRestoreMessage(String locale) {
    return locale == 'ph' ? backupRestoreMessagePH : backupRestoreMessageEN;
  }

  String getScoreBreakDownMessage() {
    return scoreBreakDownMessage;
  }

  GlobalMessages.fromJson(Map<String, dynamic> json)
      : id = 1,
        howToPlayMessage = json['howToPlayMessage'],
        howToPlayMessagePH = json['howToPlayMessagePH'],
        howToPlayMessageEN = json['howToPlayMessageEN'],
        scoreBreakDownMessage = json['scoreBreakDownMessage'],
        difficultyEasyLabelPH = json['difficultyEasyLabelPH'],
        difficultyEasyLabelEN = json['difficultyEasyLabelEN'],
        difficultyMediumLabelPH = json['difficultyMediumLabelPH'],
        difficultyMediumLabelEN = json['difficultyMediumLabelEN'],
        difficultyHardLabelPH = json['difficultyHardLabelPH'],
        difficultyHardLabelEN = json['difficultyHardLabelEN'],
        backupRestoreMessagePH = json['backupRestoreMessagePH'],
        backupRestoreMessageEN = json['backupRestoreMessageEN'],
        weeklyWinnerFirstPlacePH = json['weeklyWinnerFirstPlacePH'],
        weeklyWinnerFirstPlaceEN = json['weeklyWinnerFirstPlaceEN'],
        weeklyWinnerSecondPlacePH = json['weeklyWinnerSecondPlacePH'],
        weeklyWinnerSecondPlaceEN = json['weeklyWinnerSecondPlaceEN'],
        weeklyWinnerThirdPlacePH = json['weeklyWinnerThirdPlacePH'],
        weeklyWinnerThirdPlaceEN = json['weeklyWinnerThirdPlaceEN'],
        dailyTokenRewardMessagePH = json['dailyTokenRewardMessagePH'],
        dailyTokenRewardMessageEN = json['dailyTokenRewardMessageEN'],
        microphoneDeniedTitlePH = json['microphoneDeniedTitlePH'],
        microphoneDeniedTitleEN = json['microphoneDeniedTitleEN'],
        microphonePermanentlyDeniedMessagePH =
            json['microphonePermanentlyDeniedMessagePH'],
        microphonePermanentlyDeniedMessageEN =
            json['microphonePermanentlyDeniedMessageEN'],
        microphoneDeniedMessagePH = json['microphoneDeniedMessagePH'],
        microphoneDeniedMessageEN = json['microphoneDeniedMessageEN'],
        useHintMessagePH = json['useHintMessagePH'],
        useHintMessageEN = json['useHintMessageEN'],
        partyModeMessagePH = json['partyModeMessagePH'],
        partyModeMessageEN = json['partyModeMessageEN'],
        infoGamePageTitlePH = json['infoGamePageTitlePH'],
        infoGamePageTitleEN = json['infoGamePageTitleEN'],
        infoGamePageMessagePH = json['infoGamePageMessagePH'],
        infoGamePageMessageEN = json['infoGamePageMessageEN'],
        infoMultiPlayerPageTitlePH = json['infoMultiPlayerPageTitlePH'],
        infoMultiPlayerPageTitleEN = json['infoMultiPlayerPageTitleEN'],
        infoMultiPlayerPageMessagePH = json['infoMultiPlayerPageMessagePH'],
        infoMultiPlayerPageMessageEN = json['infoMultiPlayerPageMessageEN'],
        infoMultiPlayerGuesserPageTitlePH =
            json['infoMultiPlayerGuesserPageTitlePH'],
        infoMultiPlayerGuesserPageTitleEN =
            json['infoMultiPlayerGuesserPageTitleEN'],
        infoMultiPlayerGuesserPageMessagePH =
            json['infoMultiPlayerGuesserPageMessagePH'],
        infoMultiPlayerGuesserPageMessageEN =
            json['infoMultiPlayerGuesserPageMessageEN'],
        infoMultiPlayerClueGiverTitlePH =
            json['infoMultiPlayerClueGiverTitlePH'],
        infoMultiPlayerClueGiverTitleEN =
            json['infoMultiPlayerClueGiverTitleEN'],
        infoMultiPlayerClueGiverMessagePH =
            json['infoMultiPlayerClueGiverMessagePH'],
        infoMultiPlayerClueGiverMessgaeEN =
            json['infoMultiPlayerClueGiverMessgaeEN'],
        infoPartyModeTitlePH = json['infoPartyModeTitlePH'],
        infoPartyModeTitleEN = json['infoPartyModeTitleEN'],
        infoPartyModeMessagePH = json['infoPartyModeMessagePH'],
        infoPartyModeMessageEN = json['infoPartyModeMessageEN'],
        infoLeaderBoardTitlePH = json['infoLeaderBoardTitlePH'],
        infoLeaderBoardTitleEN = json['infoLeaderBoardTitleEN'],
        infoLeaderBoardMessagePH = json['infoLeaderBoardMessagePH'],
        infoLeaderBoardMessageEN = json['infoLeaderBoardMessageEN'],
        infoSettingsPageTitlePH = json['infoSettingsPageTitlePH'],
        infoSettingsPageTitleEN = json['infoSettingsPageTitleEN'],
        infoSettingsPageMessagePH = json['infoSettingsPageMessagePH'],
        infoSettingsPageMessageEN = json['infoSettingsPageMessageEN'],
        infoBackupRestoreTitlePH = json['infoBackupRestoreTitlePH'],
        infoBackupRestoreTitleEN = json['infoBackupRestoreTitleEN'],
        infoBackupRestoreMessagePH = json['infoBackupRestoreMessagePH'],
        infoBackupRestoreMessageEN = json['infoBackupRestoreMessageEN'],
        infoGimme5Round1TitlePH = json['infoGimme5Round1TitlePH'],
        infoGimme5Round1TitleEN = json['infoGimme5Round1TitleEN'],
        infoGimme5Round1MessagePH = json['infoGimme5Round1MessagePH'],
        infoGimme5Round1MessageEN = json['infoGimme5Round1MessageEN'],
        infoGimme5Round2TitlePH = json['infoGimme5Round2TitleEN'],
        infoGimme5Round2TitleEN = json['infoGimme5Round2TitleEN'],
        infoGimme5Round2MessagePH = json['infoGimme5Round2MessagePH'],
        infoGimme5Round2MessageEN = json['infoGimme5Round2MessageEN'],
        infoGimme5Round3TitlePH = json['infoGimme5Round3TitlePH'],
        infoGimme5Round3TitleEN = json['infoGimme5Round3TitleEN'],
        infoGimme5Round3MessagePH = json['infoGimme5Round3MessagePH'],
        infoGimme5Round3MessageEN = json['infoGimme5Round3MessageEN'],
        infoMainMenuGimme5Title = json['infoMainMenuGimme5Title'],
        infoMainMenuSoloTitle = json['infoMainMenuSoloTitle'],
        infoMainMenuMultiPlayer5Title = json['infoMainMenuMultiPlayer5Title'],
        infoMainMenuPartyTitle = json['infoMainMenuPartyTitle'],
        infoGimme5TitleName = json['infoGimme5TitleName'];
}

@Entity()
class GlobalSettings {
  @Id()
  int id;
  bool showTestAds;
  String bannerAdUnitIdAndroid;
  String bannerAdUnitIdIOS;
  String nativeAdUnitIdAndroid;
  String nativeAdUnitIdIOS;
  String interstitialAdUnitIdAndroid;
  String interstitialAdUnitIdIOS;
  String rewardedAdUnitIdAndroid;
  String rewardedAdUnitIdIOS;
  String rewardedInterstitialAdUnitIdAndroid;
  String rewardedInterstitialAdUnitIdIOS;
  String appOpenAdUnitIdAndroid;
  String appOpenAdUnitIdIOS;
  int displayRewardedAdAfterThisManyTries;
  int displayInstertitialAdAfterThisManyTries;
  int rewardedAdAmount;
  int dailyTokenReward;
  int voiceEntryFee;
  int hintFee;
  int maxGuessTriesForAward;
  int msPauseForVoiceEntry;
  bool promptForGamePageVoiceEntry;
  bool promptForHenyoPartyVoiceEntry;
  int gameDuration;
  int rewardedAdNextAvailableInMs;
  int lowTokenCountThreshold;
  int maxTriesForHintToAppear;
  String GoogleApiServerAsia;
  String GoogleApiServerUS;
  String GoogleProjectID;
  String promptCompareTwoWords;
  String promptGimme5Round1;
  String promptValidateUsername;
  bool enableAutoComplete;

  GlobalSettings({
    this.id = 0,
    this.showTestAds = false,
    this.bannerAdUnitIdAndroid = '',
    this.bannerAdUnitIdIOS = '',
    this.nativeAdUnitIdAndroid = '',
    this.nativeAdUnitIdIOS = '',
    this.interstitialAdUnitIdAndroid = '',
    this.interstitialAdUnitIdIOS = '',
    this.rewardedAdUnitIdAndroid = '',
    this.rewardedAdUnitIdIOS = '',
    this.rewardedInterstitialAdUnitIdAndroid = '',
    this.rewardedInterstitialAdUnitIdIOS = '',
    this.appOpenAdUnitIdAndroid = '',
    this.appOpenAdUnitIdIOS = '',
    this.displayRewardedAdAfterThisManyTries = 7,
    this.displayInstertitialAdAfterThisManyTries = 2,
    this.rewardedAdAmount = 150,
    this.dailyTokenReward = 100,
    this.voiceEntryFee = 50,
    this.hintFee = 20,
    this.maxGuessTriesForAward = 3,
    this.msPauseForVoiceEntry = 1000,
    this.promptForGamePageVoiceEntry = true,
    this.promptForHenyoPartyVoiceEntry = true,
    this.gameDuration = 2,
    this.rewardedAdNextAvailableInMs = 180000,
    this.lowTokenCountThreshold = 500,
    this.maxTriesForHintToAppear = 10,
    this.GoogleApiServerAsia = 'asia-southeast1',
    this.GoogleApiServerUS = 'us-central1',
    this.GoogleProjectID = 'coral-sum-422915-m1',
    this.promptCompareTwoWords =
        """You're an english and tagalog dictionary and wikipedia expert and I’ll give you two words separated by colon(:) like 'subject1:subject2' 
and you'll tell me if subject2 directly describes, belongs, part of or equates to subject1 by answering yes. 
If subject2 is not typically subject1 but somewhat like it or relates to it then answer close.
If none of the above fits the criteria then answer no.
Response should only be one of the three, 'yes', 'close' or 'no'.
Words to be compared will be in english and/or tagalog. NO EXPLANATION NEEDED! """,
    this.promptGimme5Round1 =
        """You're an english/tagalog dictionary and wikipedia expert and I’ll give you a list of 5 items plus a word (subject2)
separated by colon(:) like '[item1,item2,item3,item4,item5]:subject2'. You'll tell me which item on the list closely matches,
similar variation, synonymous, partly mispelled to subject2 by returning the index number of the matching item in the list.
If none of the items in the list fits the criteria then reply 0.
Response can only be one of the six possible numbers, 1, 2, 3, 4, 5 or 0.
Words to be compared will be in english and/or tagalog. NO EXPLANATION NEEDED FROM RESPONSE!""",
    this.promptValidateUsername =
        """You're a username validator and I'll give you a username that you need to validate
for profanity or anything inappropriate. Only check for literal profanity words. Reply 'true' if you detect profanity otherwise
'false'. Reply will only be one of these two possible answers.""",
    this.enableAutoComplete = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'showTestAds': showTestAds,
      'bannerAdUnitIdAndroid': bannerAdUnitIdAndroid,
      'bannerAdUnitIdIOS': bannerAdUnitIdIOS,
      'nativeAdUnitIdAndroid': nativeAdUnitIdAndroid,
      'nativeAdUnitIdIOS': nativeAdUnitIdIOS,
      'interstitialAdUnitIdAndroid': interstitialAdUnitIdAndroid,
      'interstitialAdUnitIdIOS': interstitialAdUnitIdIOS,
      'rewardedAdUnitIdAndroid': rewardedAdUnitIdAndroid,
      'rewardedAdUnitIdIOS': rewardedAdUnitIdIOS,
      'rewardedInterstitialAdUnitIdAndroid':
          rewardedInterstitialAdUnitIdAndroid,
      'rewardedInterstitialAdUnitIdIOS': rewardedInterstitialAdUnitIdIOS,
      'appOpenAdUnitIdAndroid': appOpenAdUnitIdAndroid,
      'appOpenAdUnitIdIOS': appOpenAdUnitIdIOS,
      'displayRewardedAdAfterThisManyTries':
          displayRewardedAdAfterThisManyTries,
      'displayInstertitialAdAfterThisManyTries':
          displayInstertitialAdAfterThisManyTries,
      'rewardedAdAmount': rewardedAdAmount,
      'dailyTokenReward': dailyTokenReward,
      'voiceEntryFee': voiceEntryFee,
      'hintFee': hintFee,
      'maxGuessTriesForAward': maxGuessTriesForAward,
      'msPauseForVoiceEntry': msPauseForVoiceEntry,
      'promptForGamePageVoiceEntry': promptForGamePageVoiceEntry,
      'promptForHenyoPartyVoiceEntry': promptForHenyoPartyVoiceEntry,
      'gameDuration': gameDuration,
      'rewardedAdNextAvailableInMs': rewardedAdNextAvailableInMs,
      'lowTokenCountThreshold': lowTokenCountThreshold,
      'maxTriesForHintToAppear': maxTriesForHintToAppear,
      'GoogleApiServerAsia': GoogleApiServerAsia,
      'GoogleApiServerUS': GoogleApiServerUS,
      'GoogleProjectID': GoogleProjectID,
      'promptCompareTwoWords': promptCompareTwoWords,
      'promptGimme5Round1': promptGimme5Round1,
      'promptValidateUsername': promptValidateUsername,
      'enableAutoComplete': enableAutoComplete,
    };
  }

  GlobalSettings.fromJson(Map<String, dynamic> json)
      : id = 1,
        showTestAds = 'true' == json['showTestAds'],
        bannerAdUnitIdAndroid = json['bannerAdUnitIdAndroid'],
        bannerAdUnitIdIOS = json['bannerAdUnitIdIOS'],
        nativeAdUnitIdAndroid = json['nativeAdUnitIdAndroid'],
        nativeAdUnitIdIOS = json['nativeAdUnitIdIOS'],
        interstitialAdUnitIdAndroid = json['interstitialAdUnitIdAndroid'],
        interstitialAdUnitIdIOS = json['interstitialAdUnitIdIOS'],
        rewardedAdUnitIdAndroid = json['rewardedAdUnitIdAndroid'],
        rewardedAdUnitIdIOS = json['rewardedAdUnitIdIOS'],
        rewardedInterstitialAdUnitIdAndroid =
            json['rewardedInterstitialAdUnitIdAndroid'],
        rewardedInterstitialAdUnitIdIOS =
            json['rewardedInterstitialAdUnitIdIOS'],
        appOpenAdUnitIdAndroid = json['appOpenAdUnitIdAndroid'],
        appOpenAdUnitIdIOS = json['appOpenAdUnitIdIOS'],
        displayRewardedAdAfterThisManyTries =
            json['displayRewardedAdAfterThisManyTries'],
        displayInstertitialAdAfterThisManyTries =
            json['displayInstertitialAdAfterThisManyTries'],
        rewardedAdAmount = json['rewardedAdAmount'],
        dailyTokenReward = json['dailyTokenReward'],
        voiceEntryFee = json['voiceEntryFee'],
        hintFee = json['hintFee'],
        maxGuessTriesForAward = json['maxGuessTriesForAward'],
        msPauseForVoiceEntry = json['msPauseForVoiceEntry'],
        promptForGamePageVoiceEntry =
            ('true' == json['promptForGamePageVoiceEntry']),
        promptForHenyoPartyVoiceEntry =
            ('true' == json['promptForHenyoPartyVoiceEntry']),
        gameDuration = json['gameDuration'],
        rewardedAdNextAvailableInMs = json['rewardedAdNextAvailableInMs'],
        lowTokenCountThreshold = json['lowTokenCountThreshold'],
        maxTriesForHintToAppear = json['maxTriesForHintToAppear'],
        GoogleApiServerAsia = json['GoogleApiServerAsia'],
        GoogleApiServerUS = json['GoogleApiServerUS'],
        GoogleProjectID = json['GoogleProjectID'],
        promptCompareTwoWords = json['promptCompareTwoWords'],
        promptGimme5Round1 = json['promptGimme5Round1'],
        promptValidateUsername = json['promptValidateUsername'],
        enableAutoComplete = 'true' == json['enableAutoComplete'];
}

@Entity()
class ShowOnce {
  @Id()
  int id;
  bool infoGamePageShown;
  bool infoGimme5Round1;
  bool infoGimme5Round2;
  bool infoGimme5Round3;
  bool infoMultiPlayerPageShown;
  bool infoMultiPlayerGuesserShown;
  bool infoMultiPlayerClueGiverShown;
  bool infoPartyModeShown;
  bool infoLeaderBoardShown;
  bool infoSettingsPageShown;
  bool infoBackupRestoreShown;
  bool autoStartVoiceEntryFeeNotice;

  ShowOnce({
    this.id = 0,
    this.infoGamePageShown = false,
    this.infoGimme5Round1 = false,
    this.infoGimme5Round2 = false,
    this.infoGimme5Round3 = false,
    this.infoMultiPlayerPageShown = false,
    this.infoMultiPlayerGuesserShown = false,
    this.infoMultiPlayerClueGiverShown = false,
    this.infoPartyModeShown = false,
    this.infoLeaderBoardShown = false,
    this.infoSettingsPageShown = false,
    this.infoBackupRestoreShown = false,
    this.autoStartVoiceEntryFeeNotice = true,
  });
}

class WeeklyRecord {
  int id;
  String name;
  String alias;
  int score;
  int streak;
  int weekNumber;
  int awardPaid;
  int awardAmount;

  WeeklyRecord({
    this.id = 0,
    this.name = '',
    this.alias = '',
    this.score = 0,
    this.streak = 0,
    this.weekNumber = 0,
    this.awardPaid = 0,
    this.awardAmount = 0,
  });

  WeeklyRecord.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        alias = json['alias'],
        score = json['score'],
        streak = json['streak'],
        weekNumber = json['weekNumber'],
        awardPaid = json['awardPaid'],
        awardAmount = json['awardAmount'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'alias': alias,
      'score': score,
      'streak': streak,
      'weekNumber': weekNumber,
      'awardPaid': awardPaid,
      'awardAmount': awardAmount,
    };
  }

  Record convertToRecord() {
    return Record(
        name: name,
        alias: alias,
        score: score,
        streak: streak,
        modified: ((weekNumber * 604800) + 345600));
  }
}

class WeeklyWinners {
  int id;
  int weekNumber;
  String firstPlace;
  String secondPlace;
  String thirdPlace;

  WeeklyWinners({
    this.id = 0,
    this.weekNumber = 0,
    this.firstPlace = '',
    this.secondPlace = '',
    this.thirdPlace = '',
  });

  WeeklyWinners.fromJson(Map<String, dynamic> json)
      : id = int.parse(json['id']),
        weekNumber = int.parse(json['weekNumber']),
        firstPlace = json['firstPlace'],
        secondPlace = json['secondPlace'],
        thirdPlace = json['thirdPlace'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weekNumber': weekNumber,
      'firstPlace': firstPlace,
      'secondPlace': secondPlace,
      'thirdPlace': thirdPlace,
    };
  }
}

@Entity()
class WordsHistory {
  @Id()
  int id;
  String wordsHistoryJson;

  WordsHistory({
    this.id = 0,
    this.wordsHistoryJson = '',
  });
}

@Entity()
class JsonWords {
  @Id()
  int id;
  int wordsDate;
  String wordsJson;
  String wordsReducedJson;
  // String multiplayerWordsList;

  JsonWords({
    this.id = 0,
    this.wordsDate = 0,
    this.wordsJson = '',
    this.wordsReducedJson = '',
    // this.multiplayerWordsList = '',
  });

  void setWordsJson(String w) {
    wordsJson = w;
  }

  String getWordsJson() {
    return wordsJson;
  }

  void setWordsReducedJson(String w) {
    wordsReducedJson = w;
  }

  String getWordsReducedJson() {
    return wordsReducedJson;
  }

  void setwordsDate(int datetime) {
    wordsDate = datetime;
  }

  int getWordsDate() {
    return wordsDate;
  }
}

@Entity()
class JsonDictionary {
  @Id()
  int id;
  int dictionaryDate;
  String dictionaryJson;

  JsonDictionary({
    this.id = 0,
    this.dictionaryDate = 0,
    this.dictionaryJson = '',
  });

  void setDictionaryJson(String w) {
    dictionaryJson = w;
  }

  String getDictionaryJson() {
    return dictionaryJson;
  }

  void setDictionaryDate(int datetime) {
    dictionaryDate = datetime;
  }

  int getDictionaryDate() {
    return dictionaryDate;
  }
}

@Entity()
class JsonMultiplayer {
  @Id()
  int id;
  int multiplayerDate;
  String multiplayerJson;

  JsonMultiplayer({
    this.id = 0,
    this.multiplayerDate = 0,
    this.multiplayerJson = '',
  });

  void setMultiplayerJson(String w) {
    multiplayerJson = w;
  }

  String getMultiplayerJson() {
    return multiplayerJson;
  }

  void setMultiplayerDate(int datetime) {
    multiplayerDate = datetime;
  }

  int getMultiplayerDate() {
    return multiplayerDate;
  }
}

@Entity()
class JsonGimme5Round1 {
  @Id()
  int id;
  int gimme5Round1Date;
  String gimme5Round1Json;

  JsonGimme5Round1({
    this.id = 0,
    this.gimme5Round1Date = 0,
    this.gimme5Round1Json = '',
  });

  void setGimme5Round1Json(String w) {
    gimme5Round1Json = w;
  }

  String getGimme5Round1Json() {
    return gimme5Round1Json;
  }

  void setGimme5Round1Date(int datetime) {
    gimme5Round1Date = datetime;
  }

  int getGimme5Round1Date() {
    return gimme5Round1Date;
  }
}
