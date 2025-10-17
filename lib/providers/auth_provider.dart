import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive.file'],
  );

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _restoreSession();
    _authService.user.listen((firebaseUser) {
      _user = firebaseUser;
      notifyListeners();
    });
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedEmail = prefs.getString('user_email');
    await _googleSignIn.signInSilently();

    if (cachedEmail != null) {
      final cachedUser = await _firestoreService.getUserByEmail(cachedEmail);
      if (cachedUser != null) {
        _user = cachedUser;
        notifyListeners();
      }
    }
  }

  // ✅ Updated login with optional phone verification
  Future<bool> login(String email, String password, {String? phone}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.loginWithEmail(email, password);
      if (user != null) {
        final existingUser =
        await _firestoreService.getUserByEmail(email);

        if (existingUser != null && phone != null && phone.isNotEmpty) {
          if (existingUser.phone != phone) {
            throw Exception("Phone number does not match our records.");
          }
        }

        await _firestoreService.saveUser(user);
        _user = user;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);

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

  Future<bool> signup(
      String email, String password, String name, String phone, String studentId) async {
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
      final user = await _authService.signUpWithEmail(
          email, password, name, phone, studentId);

      if (user != null) {
        await _firestoreService.saveUser(user);
        _user = user;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);

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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');

    await _googleSignIn.signOut();
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
