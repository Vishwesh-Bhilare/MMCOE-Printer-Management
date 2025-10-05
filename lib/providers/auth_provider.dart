import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    // Listen to Firebase Auth state changes
    _authService.user.listen((firebaseUser) {
      _user = firebaseUser;
      notifyListeners();
    });
  }

  // Student login with Firebase
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.loginWithEmail(email, password);
      if (user != null) {
        await _firestoreService.saveUser(user);
        _user = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Student signup with Firebase (college emails only)
  Future<bool> signup(String email, String password, String name, String phone, String studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (!email.endsWith('@mmcoe.edu.in')) {
      _error = 'Please use your college email ending with @mmcoe.edu.in';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      final user = await _authService.signUpWithEmail(email, password, name, phone, studentId);
      if (user != null) {
        await _firestoreService.saveUser(user);
        _user = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Printer login
  Future<bool> printerLogin(String printerId, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.printerLogin(printerId, password);
      if (user != null) {
        _user = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() async {
    await _authService.logout();
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
