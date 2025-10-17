import 'dart:io';
import 'dart:async';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

typedef UploadProgressCallback = void Function(double progress);

class GoogleDriveService {
  static const _scopes = [drive.DriveApi.driveFileScope];
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);
  drive.DriveApi? _driveApi;

  Future<void> _init() async {
    if (_driveApi != null) return;

    final GoogleSignInAccount? account = await _googleSignIn.signIn();
    if (account == null) throw Exception("Google Sign-In was cancelled.");

    final auth = await account.authentication;
    final headers = {"Authorization": "Bearer ${auth.accessToken}"};
    final client = _GoogleAuthClient(headers);
    _driveApi = drive.DriveApi(client);
  }

  Future<String> uploadFile({
    required File file,
    required String originalFileName,
    required String studentId,
    UploadProgressCallback? onProgress,
  }) async {
    await _init();

    final dateFolderName = _formattedDate();
    final dateFolderId = await _getOrCreateFolder(dateFolderName);

    final cleanName = _cleanFileName(originalFileName);
    final shortId = studentId.length > 8 ? studentId.substring(0, 8) : studentId;
    final newFileName = '${shortId}_$cleanName';

    final driveFile = drive.File()
      ..name = newFileName
      ..parents = [dateFolderId];

    final length = await file.length();
    final stream = file.openRead();
    final progressStream = _progressStream(stream, length, onProgress);
    final media = drive.Media(progressStream, length);

    final uploadedFile =
    await _driveApi!.files.create(driveFile, uploadMedia: media);

    return 'https://drive.google.com/uc?id=${uploadedFile.id}&export=download';
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

  Future<String> _getOrCreateFolder(String name) async {
    final query =
        "mimeType='application/vnd.google-apps.folder' and name='$name' and trashed=false";
    final folders = await _driveApi!.files.list(q: query, $fields: 'files(id,name)');
    if (folders.files?.isNotEmpty ?? false) return folders.files!.first.id!;

    final folder = drive.File()
      ..name = name
      ..mimeType = 'application/vnd.google-apps.folder';
    final created = await _driveApi!.files.create(folder);
    return created.id!;
  }

  Future<void> deleteFile(String fileId) async {
    await _init();
    try {
      await _driveApi!.files.delete(fileId);
    } catch (e) {
      print("Error deleting file: $e");
    }
  }

  String _formattedDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
  }

  String _cleanFileName(String name) {
    return name
        .replaceAll(RegExp(r'[^a-zA-Z0-9_.-]'), '_')
        .replaceAll('.pdf', '')
        .replaceAll('__', '_') +
        '.pdf';
  }
}

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();
  _GoogleAuthClient(this._headers);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _client.send(request..headers.addAll(_headers));
}
