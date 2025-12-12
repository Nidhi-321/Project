import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../widgets/file_tile.dart';
import '../widgets/modern_button.dart';

class DecryptScreen extends StatefulWidget {
  @override
  State<DecryptScreen> createState() => _DecryptScreenState();
}

class _DecryptScreenState extends State<DecryptScreen> {
  File? _image;
  final ApiService api = ApiService();
  bool _loading = false;
  String? _message;
  final _aesKeyCtl = TextEditingController();

  Future pickImage() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image);
    if (res == null) return;
    setState(() => _image = File(res.files.single.path!));
  }

  Future extract() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pick an image first')));
      return;
    }
    setState(() => _loading = true);
    final resp = await api.extractAndDecrypt(imageFile: _image!, aesKeyB64: _aesKeyCtl.text.trim().isEmpty ? null : _aesKeyCtl.text.trim());
    setState(() => _loading = false);
    if (resp['error'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resp['error'].toString())));
      return;
    }
    setState(() => _message = resp['message'] ?? '');
  }

  @override
  void dispose() {
    _aesKeyCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Extract & Decrypt')),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(children: [
          Row(children: [
            ElevatedButton.icon(onPressed: pickImage, icon: Icon(Icons.photo_library), label: Text('Pick stego image')),
            SizedBox(width: 12),
            if (_image != null) Expanded(child: FileTile(file: _image!)),
          ]),
          SizedBox(height: 12),
          TextField(controller: _aesKeyCtl, decoration: InputDecoration(labelText: 'AES key (base64) — optional')),
          SizedBox(height: 12),
          ModernButton(label: 'Extract & Decrypt', onPressed: extract, loading: _loading),
          SizedBox(height: 16),
          if (_message != null) Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SelectableText(_message!, style: TextStyle(fontSize: 16)),
            ),
          ),
        ]),
      ),
    );
  }
}
