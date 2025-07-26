import 'package:flutter/foundation.dart';

/// Environment configuration for HenyoU app
/// 
/// Usage:
/// - Development: flutter run --dart-define=API_URL=http://localhost:8000/v2/api
/// - Production: flutter build apk --dart-define=API_URL=https://api.henyou.com/v2/api
class Environment {
  // Prevent instantiation
  Environment._();

  /// App name
  static const String appName = 'HenyoU';
  
  /// App version - should match pubspec.yaml
  static const String appVersion = '2024.9.0';

  /// API Configuration
  static String get apiUrl {
    // Check for runtime override first
    const override = String.fromEnvironment('API_URL');
    if (override.isNotEmpty) {
      return override;
    }
    
    // Use different URLs for debug/release
    if (kDebugMode) {
      return 'http://10.0.2.2:8000/v2/api'; // Android emulator localhost
    } else {
      return 'https://your-domain.com/v2/api'; // Production URL
    }
  }

  /// WebSocket URL for real-time features
  static String get websocketUrl {
    final api = apiUrl;
    if (api.startsWith('https://')) {
      return api.replaceFirst('https://', 'wss://').replaceFirst('/api', '/ws');
    } else {
      return api.replaceFirst('http://', 'ws://').replaceFirst('/api', '/ws');
    }
  }

  /// API request timeout
  static const Duration apiTimeout = Duration(seconds: 30);

  /// Feature flags
  static const bool enableAds = bool.fromEnvironment(
    'ENABLE_ADS',
    defaultValue: true,
  );

  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: true,
  );

  static const bool enableCrashReporting = bool.fromEnvironment(
    'ENABLE_CRASH_REPORTING',
    defaultValue: !kDebugMode, // Disabled in debug mode
  );

  static const bool enableMultiplayer = bool.fromEnvironment(
    'ENABLE_MULTIPLAYER',
    defaultValue: true,
  );

  /// Game configuration
  static const int gameTimerSeconds = int.fromEnvironment(
    'GAME_TIMER_SECONDS',
    defaultValue: 120, // 2 minutes
  );

  static const int maxGuessAttempts = int.fromEnvironment(
    'MAX_GUESS_ATTEMPTS',
    defaultValue: 20,
  );

  /// Ad configuration
  static const String androidAdAppId = String.fromEnvironment(
    'ANDROID_AD_APP_ID',
    defaultValue: 'ca-app-pub-3940256099942544~3347511713', // Test ID
  );

  static const String iosAdAppId = String.fromEnvironment(
    'IOS_AD_APP_ID',
    defaultValue: 'ca-app-pub-3940256099942544~1458002511', // Test ID
  );

  /// Analytics configuration
  static const String googleAnalyticsId = String.fromEnvironment(
    'GOOGLE_ANALYTICS_ID',
    defaultValue: '',
  );

  static const String mixpanelToken = String.fromEnvironment(
    'MIXPANEL_TOKEN',
    defaultValue: '',
  );

  /// Development/Debug settings
  static const bool showDebugBanner = bool.fromEnvironment(
    'SHOW_DEBUG_BANNER',
    defaultValue: kDebugMode,
  );

  static const bool enableLogging = bool.fromEnvironment(
    'ENABLE_LOGGING',
    defaultValue: kDebugMode,
  );

  static const bool mockApiResponses = bool.fromEnvironment(
    'MOCK_API_RESPONSES',
    defaultValue: false,
  );

  /// Build configuration
  static bool get isProduction => kReleaseMode;
  static bool get isDevelopment => kDebugMode;
  static bool get isStaging => !isProduction && !isDevelopment;

  /// Platform checks
  static bool get isWeb => kIsWeb;
  static bool get isMobile => !kIsWeb && (isAndroid || isIOS);
  static bool get isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  static bool get isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isDesktop => !kIsWeb && (isMacOS || isWindows || isLinux);
  static bool get isMacOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
  static bool get isWindows => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  static bool get isLinux => !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;

  /// Get current environment name
  static String get environmentName {
    if (isProduction) return 'production';
    if (isDevelopment) return 'development';
    return 'staging';
  }

  /// Log current environment (for debugging)
  static void logEnvironment() {
    if (!enableLogging) return;
    
    debugPrint('========== HenyoU Environment ==========');
    debugPrint('Environment: $environmentName');
    debugPrint('API URL: $apiUrl');
    debugPrint('WebSocket URL: $websocketUrl');
    debugPrint('Platform: ${defaultTargetPlatform.toString()}');
    debugPrint('Features:');
    debugPrint('  - Ads: $enableAds');
    debugPrint('  - Analytics: $enableAnalytics');
    debugPrint('  - Crash Reporting: $enableCrashReporting');
    debugPrint('  - Multiplayer: $enableMultiplayer');
    debugPrint('=======================================');
  }
}

/// Environment-specific API endpoints
class ApiEndpoints {
  // Prevent instantiation
  ApiEndpoints._();

  static String get baseUrl => Environment.apiUrl;

  // User endpoints
  static String get createUser => '$baseUrl/createuserrecord.php';
  static String get fetchUser => '$baseUrl/fetchuserrecord.php';
  static String get updateUser => '$baseUrl/updateuserrecord.php';
  static String get fetchRecords => '$baseUrl/fetchrecords.php';

  // Game endpoints
  static String get userGuess => '$baseUrl/userguess.php';
  static String get gimme5Guess => '$baseUrl/gimme5guess.php';
  static String get partyModeGuess => '$baseUrl/partymodeguess.php';

  // Multiplayer endpoints
  static String get createRoom => '$baseUrl/createroom.php';
  static String get getRoom => '$baseUrl/getroom.php';
  static String get updateRoom => '$baseUrl/updateroom.php';
  static String get multiplayerGuess => '$baseUrl/multiplayerguess.php';

  // Content endpoints
  static String get fetchWords => '$baseUrl/fetchjsonwords.php';
  static String get fetchDictionary => '$baseUrl/fetchjsondictionary.php';
  static String get fetchGimme5Words => '$baseUrl/fetchjsongimme5round1.php';
  static String get fetchMultiplayerWords => '$baseUrl/fetchjsonmultiplayer.php';

  // Weekly competition endpoints
  static String get createWeeklyRecord => '$baseUrl/createuserweeklyrecord.php';
  static String get getWeeklyRecord => '$baseUrl/getuserweeklyrecord.php';
  static String get getWeeklyRecords => '$baseUrl/getweeklyrecords.php';
  static String get getWeeklyWinners => '$baseUrl/getweeklywinners.php';

  // Configuration endpoints
  static String get getAblyKey => '$baseUrl/getablykey.php';
  static String get getServiceAccountKey => '$baseUrl/getserviceaccountkey.php';
  static String get globalSettings => '$baseUrl/globalsettings.php';
  static String get globalMessages => '$baseUrl/globalmessages.php';
  static String get whatsNew => '$baseUrl/whatsnew.php';

  // Utility endpoints
  static String get backup => '$baseUrl/createrecordbackup.php';
  static String get restore => '$baseUrl/restorewithcode.php';
}