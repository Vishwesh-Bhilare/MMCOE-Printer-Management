class FirestoreConstants {
  static const String usersCollection = 'users';
  static const String printRequestsCollection = 'print_requests';
  static const String countersCollection = 'counters';

  // User fields
  static const String userId = 'userId';
  static const String studentId = 'studentId';
  static const String phone = 'phone';
  static const String email = 'email';
  static const String name = 'name';
  static const String userType = 'userType';

  // Print request fields
  static const String printId = 'printId';
  static const String fileName = 'fileName';
  static const String fileUrl = 'fileUrl';
  static const String preferences = 'preferences';
  static const String status = 'status';
  static const String createdAt = 'createdAt';
  static const String printedAt = 'printedAt';
  static const String collectedAt = 'collectedAt';
  static const String totalPages = 'totalPages';
  static const String totalCost = 'totalCost';
}

class UserType {
  static const String student = 'student';
  static const String printer = 'printer';
}

class PrintStatus {
  static const String pending = 'pending';
  static const String processing = 'processing';
  static const String ready = 'ready';
  static const String collected = 'collected';
  static const String cancelled = 'cancelled';
}