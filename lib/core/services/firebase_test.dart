import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseTest {
  static Future<void> testFirebaseConnection() async {
    try {
      print('🔄 Testing Firebase initialization...');

      // Test Core
      final app = await Firebase.initializeApp();
      print('✅ Firebase Core initialized: ${app.name}');

      // Test Auth
      final auth = FirebaseAuth.instance;
      print('✅ Firebase Auth initialized');

      // Test Firestore
      final firestore = FirebaseFirestore.instance;
      print('✅ Firestore initialized');

      // Test Storage
      final storage = FirebaseStorage.instance;
      print('✅ Firebase Storage initialized');

      print('🎉 All Firebase services initialized successfully!');

    } catch (e) {
      print('❌ Firebase initialization error: $e');
      rethrow;
    }
  }
}