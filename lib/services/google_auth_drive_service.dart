import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';

typedef UploadProgressCallback = void Function(double progress);

class GoogleDriveService {
  static const _scopes = [drive.DriveApi.driveFileScope];
  final String _serviceAccountPath = 'assets/drive_service_account.json';
  drive.DriveApi? _driveApi;

  // ✅ Use a folder shared with your service account (not owned by it!)
  static const String _sharedRootFolderId = '1OCVVs37_3BF3NWUhkjc2ARwXD-jrzCx-'; // replace with your shared folder ID

  Future<void> init() async {
    if (_driveApi != null) return;

    final jsonString = await rootBundle.loadString(_serviceAccountPath);
    final credentials =
    ServiceAccountCredentials.fromJson(json.decode(jsonString));

    final client = await clientViaServiceAccount(credentials, _scopes);
    _driveApi = drive.DriveApi(client);
  }

  /// Upload file into the shared folder (by date)
  Future<String> uploadFile({
    required File file,
    required String originalFileName,
    required String studentId,
    UploadProgressCallback? onProgress,
  }) async {
    await init();

    // ✅ Create (or reuse) a date-based subfolder inside the shared root
    final dateFolderId =
    await _getOrCreateFolder(_formattedDate(), parentId: _sharedRootFolderId);

    final shortId =
    studentId.length > 8 ? studentId.substring(0, 8) : studentId;
    final renamedFile =
        '${shortId}_${_cleanFileName(originalFileName)}_${_formattedDate()}.pdf';

    final driveFile = drive.File()
      ..name = renamedFile
      ..parents = [dateFolderId];

    final length = await file.length();
    final stream = file.openRead();
    final media = drive.Media(_progressStream(stream, length, onProgress), length);

    try {
      // ✅ Uploads file *into the shared folder*
      final uploaded = await _driveApi!.files.create(
        driveFile,
        uploadMedia: media,
        supportsAllDrives: true, // ✅ key flag for shared drives / shared folders
      );

      await _makeFilePublic(uploaded.id!);
      return 'https://drive.google.com/uc?id=${uploaded.id}&export=download';
    } catch (e) {
      throw Exception(
        'Failed to upload file. Ensure the shared folder is correctly shared with the service account.\n$e',
      );
    }
  }

  Stream<List<int>> _progressStream(
      Stream<List<int>> source,
      int totalBytes,
      UploadProgressCallback? callback,
      ) async* {
    int bytesSent = 0;
    await for (var chunk in source) {
      bytesSent += chunk.length;
      callback?.call(bytesSent / totalBytes);
      yield chunk;
    }
  }

  Future<String> _getOrCreateFolder(
      String name, {
        required String parentId,
      }) async {
    final query =
        "mimeType='application/vnd.google-apps.folder' and name='$name' "
        "and '$parentId' in parents and trashed=false";

    final folders = await _driveApi!.files.list(
      q: query,
      $fields: 'files(id, name)',
      supportsAllDrives: true,
      includeItemsFromAllDrives: true,
    );

    if (folders.files?.isNotEmpty ?? false) {
      return folders.files!.first.id!;
    }

    final folder = drive.File()
      ..name = name
      ..mimeType = 'application/vnd.google-apps.folder'
      ..parents = [parentId];

    final created = await _driveApi!.files.create(
      folder,
      supportsAllDrives: true, // ✅ needed for shared folders
    );

    return created.id!;
  }

  Future<void> _makeFilePublic(String fileId) async {
    final permission = drive.Permission()
      ..type = 'anyone'
      ..role = 'reader';
    await _driveApi!.permissions.create(
      permission,
      fileId,
      supportsAllDrives: true, // ✅ important for shared folder access
    );
  }

  Future<void> deleteFile(String fileId) async {
    await init();
    await _driveApi!.files.delete(fileId, supportsAllDrives: true);
  }

  String _formattedDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.year}';
  }

  String _cleanFileName(String name) {
    return name.replaceAll(RegExp(r'[^a-zA-Z0-9_.-]'), '_').replaceAll('.pdf', '');
  }
}
