import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

class ApiService {
  // Change baseUrl to your backend host. For Android emulator use 10.0.2.2
  final String baseUrl;
  ApiService({this.baseUrl = 'http://10.0.2.2:8000/api'});

  Future<Map<String, dynamic>> encryptAndEmbed({
    required String message,
    required File imageFile,
    String? aesKeyB64,
    String? password,
    int? maxDepth,
  }) async {
    final uri = Uri.parse('$baseUrl/steg/encrypt_embed');
    final request = http.MultipartRequest('POST', uri);
    request.fields['message'] = message;
    if (aesKeyB64 != null) request.fields['aes_key_b64'] = aesKeyB64;
    if (password != null) {
      request.fields['aes_key_mode'] = 'derive';
      request.fields['password'] = password;
    }
    if (maxDepth != null) request.fields['max_depth'] = maxDepth.toString();

    final mimeType = lookupMimeType(imageFile.path) ?? 'image/png';
    final fileStream = http.MultipartFile(
      'file',
      imageFile.openRead(),
      await imageFile.length(),
      filename: path.basename(imageFile.path),
      contentType: MediaType.parse(mimeType),
    );
    request.files.add(fileStream);

    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);
    return _parseResponse(resp);
  }

  Future<Map<String, dynamic>> extractAndDecrypt({
    required File imageFile,
    String? aesKeyB64,
    String? password,
    String? saltB64,
  }) async {
    final uri = Uri.parse('$baseUrl/steg/extract_decrypt');
    final request = http.MultipartRequest('POST', uri);
    if (aesKeyB64 != null) request.fields['aes_key_b64'] = aesKeyB64;
    if (password != null && saltB64 != null) {
      request.fields['password'] = password;
      request.fields['salt_b64'] = saltB64;
    }

    final mimeType = lookupMimeType(imageFile.path) ?? 'image/png';
    final fileStream = http.MultipartFile(
      'file',
      imageFile.openRead(),
      await imageFile.length(),
      filename: path.basename(imageFile.path),
      contentType: MediaType.parse(mimeType),
    );
    request.files.add(fileStream);

    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);
    return _parseResponse(resp);
  }

  Map<String, dynamic> _parseResponse(http.Response resp) {
    try {
      final decoded = json.decode(resp.body) as Map<String, dynamic>;
      return decoded;
    } catch (e) {
      return {'error': 'Invalid server response: ${resp.statusCode}'};
    }
  }
}

// Helper MediaType to avoid adding extra dependency
class MediaType {
  final String type;
  final String subtype;
  MediaType(this.type, this.subtype);
  static MediaType parse(String mime) {
    final parts = mime.split('/');
    return MediaType(parts[0], parts[1]);
  }

  @override
  String toString() => '$type/$subtype';
}
