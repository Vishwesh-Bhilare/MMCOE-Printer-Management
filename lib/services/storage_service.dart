import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

typedef UploadProgressCallback = void Function(double progress);

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a PDF file and return its download URL.
  /// [onProgress] reports upload progress as a value between 0.0 and 1.0
  Future<String> uploadPdf(
      File file,
      String fileName,
      String studentId, {
        UploadProgressCallback? onProgress,
      }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = 'print_requests/$studentId/${timestamp}_$fileName';

      final ref = _storage.ref().child(filePath);
      final uploadTask = ref.putFile(file);

      // Listen for progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (onProgress != null && snapshot.totalBytes > 0) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        }
      });

      // Wait until complete
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Delete a file from Firebase Storage using its download URL
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting file: $e');
    }
  }
}
