import 'dart:io';
import 'package:student_printing_system/services/google_drive_service.dart';

typedef UploadProgressCallback = void Function(double progress);

/// Handles file storage logic for the app.
/// Internally uses Google Drive via a service account.
class StorageService {
  final GoogleDriveService _driveService = GoogleDriveService();

  /// Upload a PDF file to Google Drive and return its download URL.
  Future<String> uploadPdf(
      File file,
      String fileName,
      String studentId, {
        UploadProgressCallback? onProgress,
      }) async {
    try {
      final downloadUrl = await _driveService.uploadFile(
        file: file,
        originalFileName: fileName,
        studentId: studentId,
        onProgress: onProgress,
      );

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file to Google Drive: $e');
    }
  }

  /// Delete a file from Google Drive using its public URL.
  Future<void> deleteFile(String fileUrl) async {
    try {
      // Extract file ID from URL: e.g. https://drive.google.com/uc?id=<ID>
      final regex = RegExp(r'id=([a-zA-Z0-9_-]+)');
      final match = regex.firstMatch(fileUrl);

      if (match != null) {
        final fileId = match.group(1)!;
        await _driveService.deleteFile(fileId);
      } else {
        print('⚠️ No valid file ID found in URL: $fileUrl');
      }
    } catch (e) {
      print('❌ Error deleting Google Drive file: $e');
    }
  }
}
