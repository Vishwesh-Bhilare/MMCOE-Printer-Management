import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../models/print_request_model.dart';

class PrintProvider with ChangeNotifier {
  List<PrintRequest> _printRequests = [];
  bool _isLoading = false;
  String? _error;

  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  List<PrintRequest> get printRequests => _printRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load print requests for student
  Future<void> loadStudentPrintRequests(String studentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _printRequests = await _firestoreService.getPrintRequestsByStudent(studentId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all print requests for printer
  Future<void> loadAllPrintRequests() async {
    _isLoading = true;
    notifyListeners();

    try {
      _printRequests = await _firestoreService.getAllPrintRequests();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Submit new print request
  Future<void> submitPrintRequest(PrintRequest request) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get next print ID
      final printId = await _firestoreService.getNextPrintId();

      // Update request with print ID
      final updatedRequest = PrintRequest(
        id: request.id,
        studentId: request.studentId,
        printId: printId.toString(),
        fileName: request.fileName,
        fileUrl: request.fileUrl,
        preferences: request.preferences,
        status: 'pending',
        createdAt: request.createdAt,
        totalCost: request.totalCost,
        totalPages: request.totalPages,
      );

      await _firestoreService.savePrintRequest(updatedRequest);

      // Reload requests
      await loadStudentPrintRequests(request.studentId);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update print status
  Future<void> updatePrintStatus(String requestId, String status) async {
    try {
      await _firestoreService.updatePrintStatus(requestId, status);

      // Update local state
      final index = _printRequests.indexWhere((req) => req.id == requestId);
      if (index != -1) {
        final updatedRequest = _printRequests[index].copyWith(
          status: status,
          printedAt: status == 'ready' ? DateTime.now() : _printRequests[index].printedAt,
          collectedAt: status == 'collected' ? DateTime.now() : _printRequests[index].collectedAt,
        );
        _printRequests[index] = updatedRequest;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}