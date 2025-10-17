import 'package:cloud_firestore/cloud_firestore.dart';

DateTime parseFirestoreDate(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  if (value is Timestamp) return value.toDate();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) {
    final maybeInt = int.tryParse(value);
    if (maybeInt != null) return DateTime.fromMillisecondsSinceEpoch(maybeInt);
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  return DateTime.now();
}
