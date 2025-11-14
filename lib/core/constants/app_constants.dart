class AppConstants {
  // App Info
  static const String appName = 'MindFlow';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyThemeMode = 'theme_mode';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int maxJournalEntryLength = 5000;
  static const int maxMoodNoteLength = 500;

  // Premium Limits
  static const int freeMeditationsCount = 5;
  static const int freeJournalEntriesPerMonth = 10;

  // Mood Range
  static const int minMoodValue = 1;
  static const int maxMoodValue = 10;

  // Date Formats
  static const String dateFormatDisplay = 'dd/MM/yyyy';
  static const String dateTimeFormatDisplay = 'dd/MM/yyyy HH:mm';
  static const String timeFormatDisplay = 'HH:mm';
}
