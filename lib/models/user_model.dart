import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/firestore_date.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String studentId;
  final String userType;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.studentId,
    required this.userType,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ✅ Convert to Firestore-safe map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'studentId': studentId,
      'userType': userType,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // ✅ Parse safely from Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      studentId: map['studentId']?.toString() ?? '',
      userType: map['userType']?.toString() ?? '',
      createdAt: parseFirestoreDate(map['createdAt']),
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? studentId,
    String? userType,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      studentId: studentId ?? this.studentId,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
