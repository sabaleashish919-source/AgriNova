class AppConstants {
  AppConstants._();

  static const String appName = 'AgroSurplus';

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  static const String tokenKey = 'access_token';

  static const String userKey = 'current_user';

  static const String roleFarmer = 'FARMER';

  static const String roleConsumer = 'CONSUMER';

  static const String roleInternationalBuyer = 'INTERNATIONAL_BUYER';

  static const String roleAdmin = 'ADMIN';

  static const double defaultSurplusThreshold = 0.20;
}
