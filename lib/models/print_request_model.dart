import 'print_preferences_model.dart';

class PrintRequest {
  final String id;
  final String studentId;
  final String printId;
  final String fileName;
  final String fileUrl;
  final PrintPreferences preferences;
  final String status;
  final DateTime createdAt;
  final DateTime? printedAt;
  final DateTime? collectedAt;
  final double totalCost;
  final int totalPages;

  PrintRequest({
    required this.id,
    required this.studentId,
    required this.printId,
    required this.fileName,
    required this.fileUrl,
    required this.preferences,
    required this.status,
    required this.createdAt,
    this.printedAt,
    this.collectedAt,
    required this.totalCost,
    required this.totalPages,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'printId': printId,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'preferences': preferences.toMap(),
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'printedAt': printedAt?.millisecondsSinceEpoch,
      'collectedAt': collectedAt?.millisecondsSinceEpoch,
      'totalCost': totalCost,
      'totalPages': totalPages,
    };
  }

  factory PrintRequest.fromMap(Map<String, dynamic> map) {
    return PrintRequest(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      printId: map['printId'] ?? '',
      fileName: map['fileName'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      preferences: PrintPreferences.fromMap(Map<String, dynamic>.from(map['preferences'] ?? {})),
      status: map['status'] ?? 'pending',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      printedAt: map['printedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['printedAt']) : null,
      collectedAt: map['collectedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['collectedAt']) : null,
      totalCost: (map['totalCost'] ?? 0).toDouble(),
      totalPages: map['totalPages'] ?? 1,
    );
  }

  PrintRequest copyWith({
    String? status,
    DateTime? printedAt,
    DateTime? collectedAt,
  }) {
    return PrintRequest(
      id: id,
      studentId: studentId,
      printId: printId,
      fileName: fileName,
      fileUrl: fileUrl,
      preferences: preferences,
      status: status ?? this.status,
      createdAt: createdAt,
      printedAt: printedAt ?? this.printedAt,
      collectedAt: collectedAt ?? this.collectedAt,
      totalCost: totalCost,
      totalPages: totalPages,
    );
  }
}