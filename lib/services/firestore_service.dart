import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/print_request_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Management
  Future<void> saveUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  // Print Request Management
  Future<void> savePrintRequest(PrintRequest request) async {
    await _firestore.collection('print_requests').doc(request.id).set(request.toMap());
  }

  Future<List<PrintRequest>> getPrintRequestsByStudent(String studentId) async {
    final query = await _firestore
        .collection('print_requests')
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs.map((doc) => PrintRequest.fromMap(doc.data())).toList();
  }

  Future<List<PrintRequest>> getAllPrintRequests() async {
    final query = await _firestore
        .collection('print_requests')
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs.map((doc) => PrintRequest.fromMap(doc.data())).toList();
  }

  Future<void> updatePrintStatus(String requestId, String status) async {
    final updateData = <String, dynamic>{
      'status': status,
      if (status == 'ready') 'printedAt': DateTime.now().millisecondsSinceEpoch,
      if (status == 'collected') 'collectedAt': DateTime.now().millisecondsSinceEpoch,
    };

    await _firestore.collection('print_requests').doc(requestId).update(updateData);
  }

  // Print ID Counter Management
  Future<int> getNextPrintId() async {
    final counterRef = _firestore.collection('counters').doc('print_id');

    return _firestore.runTransaction<int>((transaction) async {
      final counterDoc = await transaction.get(counterRef);
      int currentId = 1001; // Start from 1001

      if (counterDoc.exists) {
        currentId = counterDoc.data()!['currentId'] + 1;
      }

      // Reset after 9999
      if (currentId > 9999) {
        currentId = 1001;
      }

      transaction.set(counterRef, {'currentId': currentId});
      return currentId;
    });
  }
}