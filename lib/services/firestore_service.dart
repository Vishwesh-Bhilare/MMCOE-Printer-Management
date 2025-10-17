import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/print_request_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // 🔹 USER MANAGEMENT
  // ---------------------------------------------------------------------------

  Future<void> saveUser(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('❌ Failed to save user: $e');
    }
  }

  /// ✅ Fetch user by UID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      return UserModel.fromMap({
        ...data,
        'uid': uid,
      });
    } catch (e) {
      print('⚠️ Error getting user by ID: $e');
      return null;
    }
  }

  /// ✅ Fetch user by email (used for silent login restore)
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final doc = query.docs.first;
      final data = doc.data();
      return UserModel.fromMap({
        ...data,
        'uid': doc.id,
      });
    } catch (e) {
      print('⚠️ Error getting user by email: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // 🔹 FETCH METHODS (PRINT REQUESTS)
  // ---------------------------------------------------------------------------

  Future<List<PrintRequest>> getPrintRequestsByStudent(String studentId) async {
    try {
      final querySnapshot = await _firestore
          .collection('print_requests')
          .where('studentId', isEqualTo: studentId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final rawData = doc.data();
        final Map<String, dynamic> data = {
          ...rawData,
          'id': doc.id,
        };
        return PrintRequest.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('❌ Failed to load student print requests: $e');
    }
  }

  Future<List<PrintRequest>> getAllPrintRequests() async {
    try {
      final querySnapshot = await _firestore
          .collection('print_requests')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final rawData = doc.data();
        final Map<String, dynamic> data = {
          ...rawData,
          'id': doc.id,
        };
        return PrintRequest.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('❌ Failed to load all print requests: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 🔹 STREAM METHODS
  // ---------------------------------------------------------------------------

  Stream<List<PrintRequest>> streamPrintRequestsByStudent(String studentId) {
    return _firestore
        .collection('print_requests')
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final rawData = doc.data();
      final Map<String, dynamic> data = {
        ...rawData,
        'id': doc.id,
      };
      return PrintRequest.fromMap(data);
    }).toList());
  }

  Stream<List<PrintRequest>> streamAllPrintRequests() {
    return _firestore
        .collection('print_requests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final rawData = doc.data();
      final Map<String, dynamic> data = {
        ...rawData,
        'id': doc.id,
      };
      return PrintRequest.fromMap(data);
    }).toList());
  }

  // ---------------------------------------------------------------------------
  // 🔹 PRINT REQUEST MANAGEMENT
  // ---------------------------------------------------------------------------

  Future<void> savePrintRequest(PrintRequest request) async {
    try {
      await _firestore.collection('print_requests').add(request.toMap());
    } catch (e) {
      throw Exception('❌ Failed to save print request: $e');
    }
  }

  Future<void> updatePrintStatus(String requestId, String status) async {
    try {
      final updateData = {'status': status};

      if (status == 'ready') {
        updateData['printedAt'] =
            DateTime.now().millisecondsSinceEpoch.toString();
      } else if (status == 'collected') {
        updateData['collectedAt'] =
            DateTime.now().millisecondsSinceEpoch.toString();
      }

      await _firestore
          .collection('print_requests')
          .doc(requestId)
          .update(updateData);
    } catch (e) {
      throw Exception('❌ Failed to update print status: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 🔹 COUNTER MANAGEMENT
  // ---------------------------------------------------------------------------

  Future<int> getNextPrintId() async {
    try {
      final counterRef = _firestore.collection('metadata').doc('print_counter');

      return _firestore.runTransaction<int>((transaction) async {
        final snapshot = await transaction.get(counterRef);

        int current = 0;
        if (snapshot.exists) {
          final data = snapshot.data();
          if (data != null && data['value'] is int) {
            current = data['value'];
          }
        }

        final next = current + 1;
        transaction.set(counterRef, {'value': next});
        return next;
      });
    } catch (e) {
      throw Exception('❌ Failed to generate next print ID: $e');
    }
  }
}
