// ignore_for_file: constant_identifier_names

enum Language {
  EN,
  FR,
  DE,
  AR,
  PH,
}

enum Layout {
  QWERTY,
  QWERTZ,
  AZERTY,
  ARABIC,
  QWERTN,
}

var languageConfig = {
  Language.EN: englishConfig,
  Language.FR: frenchConfig,
  Language.DE: germanConfig,
  Language.AR: arabicConfig,
  Language.PH: tagalogConfig,
};

// Languages Configurations

var tagalogConfig = {
  Layout.QWERTN: <String, String>{
    // 'layout': 'QWERTYUIOPASDFGHJKLZXCVBNMÑ',
    'layout': 'qwertyuiopasdfghjklzxcvbnm',
    'horizontalSpacing': '5.0',
    'topLength': '10',
    'middleLength': '9',
  }
};

var englishConfig = {
  Layout.QWERTY: <String, String>{
    // 'layout': 'QWERTYUIOPASDFGHJKLZXCVBNM',
    'layout': 'qwertyuiopasdfghjklzxcvbnm',
    'horizontalSpacing': '6.0',
    'topLength': '10',
    'middleLength': '9',
  },
  Layout.QWERTZ: <String, String>{
    'layout': 'QWERTZUIOPASDFGHJKLYXCVBNM',
    'horizontalSpacing': '6.0',
    'topLength': '10',
    'middleLength': '9',
  },
};

var frenchConfig = {
  Layout.QWERTY: <String, String>{
    'layout': 'QWERTYUIOPASDFGHJKLZXCVBNM',
    'horizontalSpacing': '6.0',
    'topLength': '10',
    'middleLength': '9',
  },
  Layout.AZERTY: <String, String>{
    'layout': 'AZERTYUIOPQSDFGHJKLMWXCVBN',
    'horizontalSpacing': '6.0',
    'topLength': '10',
    'middleLength': '9',
  },
};

var germanConfig = {
  Layout.QWERTY: <String, String>{
    'layout': 'QWERTYUIOPÜASDFGHJKLÖÄZXCVBNMSS',
    'horizontalSpacing': '2.5',
    'topLength': '11',
    'middleLength': '11',
  },
  Layout.QWERTZ: <String, String>{
    'layout': 'QWERTZUIOPÜASDFGHJKLÖÄYXCVBNMß',
    'horizontalSpacing': '2.5',
    'topLength': '11',
    'middleLength': '11',
  },
};

var arabicConfig = {
  Layout.ARABIC: <String, String>{
    'layout': 'ثةورزدذطظكمنتالبيسشجحخهعغفقصض',
    'horizontalSpacing': '2.8',
    'topLength': '11',
    'middleLength': '10',
  },
};
