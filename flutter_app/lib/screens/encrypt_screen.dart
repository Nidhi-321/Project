import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../widgets/file_tile.dart';
import '../widgets/modern_button.dart';
import '../widgets/result_card.dart';
import 'dart:convert';

class EncryptScreen extends StatefulWidget {
  @override
  State<EncryptScreen> createState() => _EncryptScreenState();
}

class _EncryptScreenState extends State<EncryptScreen> {
  File? _image;
  final _msgCtl = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _metrics;
  String? _stegoB64;
  final ApiService api = ApiService();

  Future pickImage() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image);
    if (res == null) return;
    setState(() => _image = File(res.files.single.path!));
  }

  Future upload() async {
    if (_image == null || _msgCtl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Message and image required')));
      return;
    }
    setState(() => _loading = true);
    final resp = await api.encryptAndEmbed(message: _msgCtl.text.trim(), imageFile: _image!);
    setState(() => _loading = false);
    if (resp['error'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resp['error'].toString())));
      return;
    }
    setState(() {
      _metrics = Map<String, dynamic>.from(resp['metrics'] ?? {});
      _stegoB64 = resp['stego_image_b64'];
    });
  }

  Future saveStego() async {
    if (_stegoB64 == null) return;
    final bytes = base64Decode(_stegoB64!);
    final docDir = (await FilePicker.platform.getDirectoryPath()) ?? '';
    if (docDir.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pick a folder to save')));
      return;
    }
    final out = File('$docDir/stego_${DateTime.now().millisecondsSinceEpoch}.png');
    await out.writeAsBytes(bytes);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved to ${out.path}')));
  }

  @override
  void dispose() {
    _msgCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Encrypt & Embed')),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(children: [
          TextField(controller: _msgCtl, decoration: InputDecoration(labelText: 'Message to hide')),
          SizedBox(height: 12),
          Row(children: [
            ElevatedButton.icon(onPressed: pickImage, icon: Icon(Icons.photo), label: Text('Pick cover image')),
            SizedBox(width: 12),
            if (_image != null) Expanded(child: FileTile(file: _image!)),
          ]),
          SizedBox(height: 12),
          ModernButton(label: 'Encrypt & Embed', onPressed: upload, loading: _loading),
          SizedBox(height: 12),
          if (_metrics != null) ResultCard(title: 'Quality Metrics', metrics: _metrics),
          if (_stegoB64 != null) Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Column(children: [
              ElevatedButton.icon(onPressed: saveStego, icon: Icon(Icons.save), label: Text('Save stego image')),
              SizedBox(height: 8),
              Text('AES key was returned by server: save it securely for extraction.', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            ]),
          ),
        ]),
      ),
    );
  }
}
