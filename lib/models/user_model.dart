class UserModel {
  final String uid;
  final String studentId;
  final String phone;
  final String email;
  final String name;
  final String userType;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.studentId,
    required this.phone,
    required this.email,
    required this.name,
    required this.userType,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'studentId': studentId,
      'phone': phone,
      'email': email,
      'name': name,
      'userType': userType,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      studentId: map['studentId'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      userType: map['userType'] ?? 'student',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }
}