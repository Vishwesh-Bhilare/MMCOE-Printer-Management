import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadPdf(File file, String fileName, String studentId) async {
    try {
      // Create a unique file path
      final filePath = 'print_requests/$studentId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      // Upload file
      final uploadTask = _storage.ref().child(filePath).putFile(file);

      // Monitor upload progress
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting file: $e');
    }
  }
}