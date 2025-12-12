import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _tokenKey = 'stegcrypt_access_token';
  String? _token;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  Future<void> init() async {
    _token = await _storage.read(key: _tokenKey);
    notifyListeners();
  }

  Future<void> saveToken(String token) async {
    _token = token;
    await _storage.write(key: _tokenKey, value: token);
    notifyListeners();
  }

  Future<void> clear() async {
    _token = null;
    await _storage.delete(key: _tokenKey);
    notifyListeners();
  }
}
