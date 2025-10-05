class AppConstants {
  static const String appName = 'Student Print System';
  static const String universityName = 'University Name';

  // Print settings
  static const double colorPrintCost = 0.50;
  static const double bwPrintCost = 0.10;
  static const double duplexMultiplier = 1.5;
  static const double simplexMultiplier = 2.0;

  // File upload
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  static const List<String> allowedFileTypes = ['pdf'];

  // Print ID
  static const int printIdLength = 4;
  static const int printIdResetDays = 2;
}

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String upload = '/upload';
  static const String status = '/status';
  static const String history = '/history';
  static const String printerDashboard = '/printer-dashboard';
}