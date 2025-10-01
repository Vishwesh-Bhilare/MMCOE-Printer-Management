import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Student login
  Future<bool> login(String studentId, String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _user = UserModel(
      uid: 'mock-uid-$studentId',
      studentId: studentId,
      phone: phone,
      email: '$studentId@university.edu',
      name: 'Student $studentId',
      userType: 'student',
      createdAt: DateTime.now(),
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Student signup
  Future<bool> signup(String studentId, String phone, String name, String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _user = UserModel(
      uid: 'mock-uid-$studentId',
      studentId: studentId,
      phone: phone,
      email: email,
      name: name,
      userType: 'student',
      createdAt: DateTime.now(),
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Printer login
  Future<bool> printerLogin(String printerId, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    // Mock printer credentials check
    if (printerId == 'printer' && password == 'print123') {
      _user = UserModel(
        uid: 'mock-printer-uid',
        studentId: 'PRINTER001',
        phone: '0000000000',
        email: 'printer@university.edu',
        name: 'Printing Station',
        userType: 'printer',
        createdAt: DateTime.now(),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = 'Invalid printer credentials';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  bool get isStudent => _user?.userType == 'student';
  bool get isPrinter => _user?.userType == 'printer';
}