// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

class ApiService {
  // point to your backend
  static const String baseUrl = 'http://127.0.0.1:5001';

  // register or update user
  static Future<Map<String, dynamic>?> register({
    required String username,
    String? publicKeyPem,
  }) async {
    final uri = Uri.parse('$baseUrl/register');
    final body = <String, dynamic>{'username': username};
    if (publicKeyPem != null && publicKeyPem.isNotEmpty) body['public_key_pem'] = publicKeyPem;
    final resp = await http.post(uri, body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      try {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      } catch (_) {
        return {'error': 'server_error', 'status': resp.statusCode, 'body': resp.body};
      }
    }
  }

  // list users
  static Future<List<Map<String, dynamic>>?> getUsers() async {
    final uri = Uri.parse('$baseUrl/users');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final j = jsonDecode(resp.body) as Map<String, dynamic>;
      final users = j['users'] as List<dynamic>? ?? [];
      return users.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return null;
  }

  // upload ciphertext or stego image (multipart). Accepts plaintext ciphertext string OR file.
  static Future<Map<String, dynamic>> uploadCiphertext({
    String? ciphertext,
    File? file,
    required int senderId,
    required int receiverId,
  }) async {
    final uri = Uri.parse('$baseUrl/upload_ciphertext');
    if (file != null) {
      final req = http.MultipartRequest('POST', uri);
      req.fields['sender_id'] = senderId.toString();
      req.fields['receiver_id'] = receiverId.toString();
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      final parts = mimeType.split('/');
      final filePart = http.MultipartFile(
        'file',
        file.openRead(),
        await file.length(),
        filename: path.basename(file.path),
        contentType: MediaType(parts[0], parts.length > 1 ? parts[1] : 'octet-stream'),
      );
      req.files.add(filePart);
      final streamed = await req.send();
      final resp = await http.Response.fromStream(streamed);
      try {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      } catch (_) {
        return {'error': 'invalid_response', 'status': resp.statusCode};
      }
    } else {
      final body = {'sender_id': senderId, 'receiver_id': receiverId, 'ciphertext': ciphertext ?? ''};
      final resp = await http.post(uri, body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
      try {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      } catch (_) {
        return {'error': 'invalid_response', 'status': resp.statusCode};
      }
    }
  }
}
