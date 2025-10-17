import 'package:cloud_firestore/cloud_firestore.dart';
import 'print_preferences_model.dart';
import '../utils/firestore_date.dart';

class PrintRequest {
  final String id;
  final String studentId;
  final String printId;
  final String fileName;
  final String fileUrl;
  final PrintPreferences preferences;
  final String status;
  final DateTime createdAt;
  final double totalCost;
  final int totalPages;
  final DateTime? printedAt;
  final DateTime? collectedAt;

  PrintRequest({
    required this.id,
    required this.studentId,
    required this.printId,
    required this.fileName,
    required this.fileUrl,
    required this.preferences,
    required this.status,
    DateTime? createdAt, // optional; auto-set below
    required this.totalCost,
    required this.totalPages,
    this.printedAt,
    this.collectedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ✅ Convert object to Firestore-safe map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'printId': printId,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'preferences': preferences.toMap(),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'totalCost': totalCost,
      'totalPages': totalPages,
      if (printedAt != null) 'printedAt': Timestamp.fromDate(printedAt!),
      if (collectedAt != null) 'collectedAt': Timestamp.fromDate(collectedAt!),
    };
  }

  // ✅ Parse Firestore data safely using helper
  factory PrintRequest.fromMap(Map<String, dynamic> map) {
    return PrintRequest(
      id: map['id']?.toString() ?? '',
      studentId: map['studentId']?.toString() ?? '',
      printId: map['printId']?.toString() ?? '',
      fileName: map['fileName']?.toString() ?? '',
      fileUrl: map['fileUrl']?.toString() ?? '',
      preferences: PrintPreferences.fromMap(
        Map<String, dynamic>.from(map['preferences'] ?? {}),
      ),
      status: map['status']?.toString() ?? 'pending',
      createdAt: parseFirestoreDate(map['createdAt']),
      printedAt: parseFirestoreDate(map['printedAt']),
      collectedAt: parseFirestoreDate(map['collectedAt']),
      totalCost: (map['totalCost'] is num)
          ? (map['totalCost'] as num).toDouble()
          : double.tryParse(map['totalCost']?.toString() ?? '0') ?? 0.0,
      totalPages: (map['totalPages'] is int)
          ? map['totalPages']
          : int.tryParse(map['totalPages']?.toString() ?? '0') ?? 0,
    );
  }

  // ✅ Copy an instance safely
  PrintRequest copyWith({
    String? id,
    String? studentId,
    String? printId,
    String? fileName,
    String? fileUrl,
    PrintPreferences? preferences,
    String? status,
    DateTime? createdAt,
    double? totalCost,
    int? totalPages,
    DateTime? printedAt,
    DateTime? collectedAt,
  }) {
    return PrintRequest(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      printId: printId ?? this.printId,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      preferences: preferences ?? this.preferences,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      totalCost: totalCost ?? this.totalCost,
      totalPages: totalPages ?? this.totalPages,
      printedAt: printedAt ?? this.printedAt,
      collectedAt: collectedAt ?? this.collectedAt,
    );
  }
}
