import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Convert Firebase User to our UserModel
  UserModel? _userFromFirebase(User? user) {
    if (user == null) return null;

    return UserModel(
      uid: user.uid,
      studentId: user.email?.split('@').first ?? '',
      phone: user.phoneNumber ?? '',
      email: user.email ?? '',
      name: user.displayName ?? 'Student',
      userType: 'student',
      createdAt: DateTime.now(),
    );
  }

  // Stream of user auth state changes
  Stream<UserModel?> get user {
    return _auth.authStateChanges().asyncMap(_userFromFirebase);
  }

  // Student Signup with Email/Password
  Future<UserModel?> signUpWithEmail(
      String email,
      String password,
      String name,
      String phone,
      String studentId,
      ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user!.updateDisplayName(name);

      return _userFromFirebase(userCredential.user);
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }

  // Student Login with Email/Password
  Future<UserModel?> loginWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return _userFromFirebase(userCredential.user);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Printer Login (Simple password-based for now)
  Future<UserModel?> printerLogin(String printerId, String password) async {
    // For prototype, use simple check. In production, use proper auth
    if (printerId == 'printer' && password == 'print123') {
      return UserModel(
        uid: 'printer-uid',
        studentId: 'PRINTER001',
        phone: '0000000000',
        email: 'printer@university.edu',
        name: 'Printing Station',
        userType: 'printer',
        createdAt: DateTime.now(),
      );
    }
    throw Exception('Invalid printer credentials');
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get current user
  UserModel? getCurrentUser() {
    return _userFromFirebase(_auth.currentUser);
  }
}