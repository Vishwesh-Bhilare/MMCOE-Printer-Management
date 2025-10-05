import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Convert Firebase user to our UserModel (load from Firestore or create new)
  Future<UserModel?> _userFromFirebase(User? user) async {
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }

      // Create a new user entry if not found
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
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  /// Stream of user authentication state changes
  Stream<UserModel?> get user {
    return _auth.authStateChanges().asyncMap(_userFromFirebase);
  }

  /// Student Signup with Email/Password
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
      throw Exception('Signup failed: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected signup error: $e');
    }
  }

  /// Student Login with Email/Password
  Future<UserModel?> loginWithEmail(String email, String password) async {
    try {
      final userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _userFromFirebase(userCred.user);
    } on FirebaseAuthException catch (e) {
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected login error: $e');
    }
  }

  /// Printer Login (from Firestore collection)
  Future<UserModel?> printerLogin(String printerId, String password) async {
    try {
      final doc =
      await _firestore.collection('printers').doc(printerId).get();

      if (doc.exists && doc.data()?['password'] == password) {
        return UserModel.fromMap(doc.data()!);
      } else {
        throw Exception('Invalid printer credentials');
      }
    } catch (e) {
      throw Exception('Printer login failed: $e');
    }
  }

  /// Logout user
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Get current logged-in user
  Future<UserModel?> getCurrentUser() async {
    return await _userFromFirebase(_auth.currentUser);
  }
}
