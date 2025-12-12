// lib/screens/login_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  final _pubkey = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('current_user')) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  Future<void> _register() async {
    final username = _username.text.trim();
    final pubkey = _pubkey.text.trim();
    if (username.isEmpty) {
      setState(() => _error = 'Username required');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final resp = await ApiService.register(username: username, publicKeyPem: pubkey.isEmpty ? null : pubkey);
    setState(() => _loading = false);
    if (resp == null) {
      setState(() => _error = 'No response from server');
      return;
    }
    if (resp.containsKey('error')) {
      setState(() => _error = resp['error'].toString());
      return;
    }
    final userJson = resp['user'] as Map<String, dynamic>;
    final user = User.fromJson(userJson);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', jsonEncode(userJson));
    // navigate to home
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  void dispose() {
    _username.dispose();
    _pubkey.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          const Text('Enter username and optional public key'),
          const SizedBox(height: 12),
          TextField(controller: _username, decoration: const InputDecoration(labelText: 'Username')),
          const SizedBox(height: 8),
          TextField(controller: _pubkey, decoration: const InputDecoration(labelText: 'Public key (PEM)'), maxLines: 4),
          const SizedBox(height: 12),
          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loading ? null : _register,
            child: _loading ? const CircularProgressIndicator() : const Text('Register / Login'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
            child: const Text('Continue as guest'),
          )
        ]),
      ),
    );
  }
}
