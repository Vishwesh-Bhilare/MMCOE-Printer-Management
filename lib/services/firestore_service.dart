import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/print_request_model.dart';
import '../models/user_model.dart'; // make sure you have this model

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Save user details (used in auth_provider)
  Future<void> saveUser(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user: $e');
    }
  }

  /// 🔹 Get print requests for a specific student
  Future<List<PrintRequest>> getPrintRequestsByStudent(String studentId) async {
    try {
      final querySnapshot = await _firestore
          .collection('print_requests')
          .where('studentId', isEqualTo: studentId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PrintRequest.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to load student print requests: $e');
    }
  }

  /// 🔹 Get all print requests (for printer dashboard)
  Future<List<PrintRequest>> getAllPrintRequests() async {
    try {
      final querySnapshot = await _firestore
          .collection('print_requests')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PrintRequest.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to load all print requests: $e');
    }
  }

  /// 🔹 Generate next print ID
  Future<int> getNextPrintId() async {
    try {
      final counterRef = _firestore.collection('metadata').doc('print_counter');

      return _firestore.runTransaction<int>((transaction) async {
        final snapshot = await transaction.get(counterRef);

        int current = 0;
        if (snapshot.exists) {
          current = snapshot.data()?['value'] ?? 0;
        }

        final next = current + 1;
        transaction.set(counterRef, {'value': next});
        return next;
      });
    } catch (e) {
      throw Exception('Failed to get next print ID: $e');
    }
  }

  /// 🔹 Save a new print request
  Future<void> savePrintRequest(PrintRequest request) async {
    try {
      await _firestore.collection('print_requests').add(request.toMap());
    } catch (e) {
      throw Exception('Failed to save print request: $e');
    }
  }

  /// 🔹 Update print request status
  Future<void> updatePrintStatus(String requestId, String status) async {
    try {
      await _firestore.collection('print_requests').doc(requestId).update({
        'status': status,
        if (status == 'ready') 'printedAt': DateTime.now().millisecondsSinceEpoch,
        if (status == 'collected')
          'collectedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to update print status: $e');
    }
  }
}
