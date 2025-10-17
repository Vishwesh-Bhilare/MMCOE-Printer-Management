import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../models/print_request_model.dart';
import '../models/print_preferences_model.dart';
import '../models/user_model.dart';

class PrintProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  List<PrintRequest> _printRequests = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<PrintRequest>>? _subscription;

  // 📊 Getters
  List<PrintRequest> get printRequests => _printRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 🧩 --- REAL-TIME STREAMING ---

  /// 🔹 Listen to a student's print requests in real time
  void startListeningToStudent(String studentId) {
    stopListening();
    _setLoading(true);

    _subscription = _firestoreService
        .streamPrintRequestsByStudent(studentId)
        .listen((requests) {
      _printRequests = requests;
      _setLoading(false);
    }, onError: (error) {
      _setError(error.toString());
    });
  }

  /// 🔹 Listen to all print requests (for printers)
  void startListeningToAll() {
    stopListening();
    _setLoading(true);

    _subscription = _firestoreService.streamAllPrintRequests().listen(
          (requests) {
        _printRequests = requests;
        _setLoading(false);
      },
      onError: (error) {
        _setError(error.toString());
      },
    );
  }

  /// 🔹 Stop Firestore listener to avoid memory leaks
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  // 🧾 --- SUBMISSION & UPLOAD LOGIC ---

  /// ✅ Handles uploading the PDF + saving print request in Firestore
  Future<void> uploadPrintRequest({
    required PlatformFile file,
    required PrintPreferences preferences,
    required UserModel user,
    int? pages, // 👈 Optional now
    Function(double)? onProgress, // 👈 Optional callback
  }) async {
    try {
      _setLoading(true);

      // Upload file to Firebase Storage
      final fileUrl = await _storageService.uploadPdf(
        File(file.path!),
        file.name,
        user.uid, // ✅ match Firebase Auth UID
        onProgress: onProgress,
      );

      // Generate sequential print ID
      final printId = await _firestoreService.getNextPrintId();

      // Use a safe default (1 page) if page count is missing
      final int totalPages = (pages ?? 1) * preferences.copies;

      // Create print request object
      final request = PrintRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        studentId: user.uid,
        printId: printId.toString(),
        fileName: file.name,
        fileUrl: fileUrl,
        preferences: preferences,
        status: 'pending',
        createdAt: DateTime.now(),
        totalCost: preferences.calculateCost(),
        totalPages: totalPages,
      );

      await _firestoreService.savePrintRequest(request);
    } catch (e) {
      _setError("Error uploading print request: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// 🔹 Manually submit already created request (used internally)
  Future<void> submitPrintRequest(PrintRequest request) async {
    _setLoading(true);
    try {
      final printId = await _firestoreService.getNextPrintId();

      final newRequest = PrintRequest(
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

      await _firestoreService.savePrintRequest(newRequest);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// 🔹 Bulk update request statuses
  Future<void> markAllAs(String status) async {
    try {
      for (final request in _printRequests) {
        await updatePrintStatus(request.id, status);
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error marking all as $status: $e");
    }
  }

  /// 🔹 Update single request status
  Future<void> updatePrintStatus(String requestId, String status) async {
    try {
      await _firestoreService.updatePrintStatus(requestId, status);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  /// 🔹 Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ⚙️ --- HELPERS ---
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String value) {
    _error = value;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
