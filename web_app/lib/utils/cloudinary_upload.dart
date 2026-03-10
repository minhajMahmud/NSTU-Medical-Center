import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class CloudinaryUpload {
  static const String cloudName = 'dfrzizwb1';
  static const String uploadPreset = 'sabbir';

  static Uri _uploadUri() =>
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/auto/upload');

  static bool _isPdfName(String fileName) =>
      fileName.toLowerCase().trim().endsWith('.pdf');

  static MediaType _contentTypeForName(String fileName, {required bool isPdf}) {
    if (isPdf) return MediaType('application', 'pdf');
    final name = fileName.toLowerCase().trim();
    if (name.endsWith('.png')) return MediaType('image', 'png');
    if (name.endsWith('.jpg') || name.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    }
    return MediaType('application', 'octet-stream');
  }

  static String _sanitizeFileName(String fileName) {
    final trimmed = fileName.trim();
    if (trimmed.isEmpty) {
      return 'upload_${DateTime.now().millisecondsSinceEpoch}';
    }
    return trimmed.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
  }

  static Future<String?> uploadAuto({
    required Uint8List bytes,
    required String folder,
    required String fileName,
  }) {
    final safeName = _sanitizeFileName(fileName);
    return uploadBytes(
      bytes: bytes,
      folder: folder,
      fileName: safeName,
      isPdf: _isPdfName(safeName),
    );
  }

  static Future<String?> uploadBytes({
    required Uint8List bytes,
    required String folder,
    required String fileName,
    bool isPdf = false,
  }) async {
    try {
      final safeName = _sanitizeFileName(fileName);
      final inferredIsPdf = isPdf || _isPdfName(safeName);
      final request = http.MultipartRequest('POST', _uploadUri())
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = folder
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: safeName,
            contentType: _contentTypeForName(safeName, isPdf: inferredIsPdf),
          ),
        );

      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        return data['secure_url']?.toString();
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
