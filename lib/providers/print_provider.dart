import 'package:flutter/material.dart';
import '../models/print_request_model.dart';
import '../models/print_preferences_model.dart'; // Add this import

class PrintProvider with ChangeNotifier {
  List<PrintRequest> _printRequests = [];
  bool _isLoading = false;
  String? _error;

  List<PrintRequest> get printRequests => _printRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Mock data for prototype
  PrintProvider() {
    _loadMockData();
  }

  void _loadMockData() {
    _printRequests = [
      PrintRequest(
        id: '1',
        studentId: '2023001',
        printId: '1001',
        fileName: 'assignment.pdf',
        fileUrl: '',
        preferences: PrintPreferences(
          isColor: false,
          isDuplex: true,
          copies: 1,
          pages: 10,
        ),
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        totalCost: 2.00,
        totalPages: 10,
      ),
      PrintRequest(
        id: '2',
        studentId: '2023001',
        printId: '1002',
        fileName: 'research_paper.pdf',
        fileUrl: '',
        preferences: PrintPreferences(
          isColor: true,
          isDuplex: false,
          copies: 2,
          pages: 15,
        ),
        status: 'ready',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        printedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        totalCost: 15.00,
        totalPages: 30,
      ),
    ];
  }

  Future<void> submitPrintRequest(PrintRequest request) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2)); // Simulate API call

    _printRequests.insert(0, request);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updatePrintStatus(String requestId, String status) async {
    final index = _printRequests.indexWhere((req) => req.id == requestId);
    if (index != -1) {
      final updatedRequest = _printRequests[index].copyWith(
        status: status,
        printedAt: status == 'ready' ? DateTime.now() : null,
      );
      _printRequests[index] = updatedRequest;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}