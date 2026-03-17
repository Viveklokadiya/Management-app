class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Shree Giriraj Engineering';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String sitesCollection = 'sites';
  static const String siteUsersCollection = 'site_users';
  static const String transactionsCollection = 'transactions';
  static const String auditLogsCollection = 'audit_logs';

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  // Card elevation
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;

  // Pagination
  static const int defaultPageSize = 20;
  static const int recentTransactionLimit = 5;

  // Timeouts
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration locationTimeout = Duration(seconds: 10);

  // SharedPreferences keys
  static const String prefLanguageCode = 'language_code';
  static const String prefLanguageName = 'language_name';
}
