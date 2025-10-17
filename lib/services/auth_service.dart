import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/firestore_date.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Convert Firebase User to our custom model (including Firestore lookup)
  Future<UserModel?> _userFromFirebase(User? user) async {
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }

    // If not found in Firestore (first login), create new record
    final newUser = UserModel(
      uid: user.uid,
      studentId: user.email?.split('@').first ?? '',
      phone: user.phoneNumber ?? '',
      email: user.email ?? '',
      name: user.displayName ?? 'Student',
      userType: 'student',
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
    return newUser;
  }

  // Stream of user auth state changes
  Stream<UserModel?> get user {
    return _auth.authStateChanges().asyncMap(_userFromFirebase);
  }

  // Student signup with email/password
  Future<UserModel?> signUpWithEmail(
      String email,
      String password,
      String name,
      String phone,
      String studentId,
      ) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCred.user!.updateDisplayName(name);

      final newUser = UserModel(
        uid: userCred.user!.uid,
        studentId: studentId,
        phone: phone,
        email: email,
        name: name,
        userType: 'student',
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap());
      return newUser;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered.';
          break;
        case 'invalid-email':
          errorMessage = 'The email format is invalid.';
          break;
        case 'weak-password':
          errorMessage = 'Password must be at least 6 characters.';
          break;
        default:
          errorMessage = e.message ?? 'Signup failed';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }

  // Student login
  Future<UserModel?> loginWithEmail(String email, String password) async {
    try {
      final userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _userFromFirebase(userCred.user);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'invalid-email':
          errorMessage = 'The email format is invalid.';
          break;
        default:
          errorMessage = e.message ?? 'Login failed';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Printer login (from Firestore printers collection)
  // Printer login (from Firestore printers collection)
  Future<UserModel?> printerLogin(String printerId, String password) async {
    try {
      final doc = await _firestore.collection('printers').doc(printerId).get();

      if (!doc.exists) {
        throw Exception('Printer not found');
      }

      final data = doc.data()!;
      if (data['password'] != password) {
        throw Exception('Invalid printer credentials');
      }

      // ✅ Create UserModel manually instead of parsing via fromMap()
      return UserModel(
        uid: printerId,
        studentId: printerId,
        email: '',
        phone: '',
        name: data['name'] ?? 'Printer Station',
        userType: 'printer',
        createdAt: parseFirestoreDate(data['createdAt']),
      );
    } catch (e) {
      throw Exception('Printer login failed: $e');
    }
  }

  // Logout
  Future<void> logout() async => await _auth.signOut();

  // Current user getter
  Future<UserModel?> getCurrentUser() async {
    return await _userFromFirebase(_auth.currentUser);
  }
}
