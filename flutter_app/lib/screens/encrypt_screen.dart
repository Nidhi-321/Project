// lib/screens/encrypt_screen.dart
import 'dart:io' show File;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

import '../services/api_service.dart'; // update if your path differs

class EncryptScreen extends StatefulWidget {
  const EncryptScreen({Key? key}) : super(key: key);

  @override
  _EncryptScreenState createState() => _EncryptScreenState();
}

class _EncryptScreenState extends State<EncryptScreen> {
  PlatformFile? _pickedFileMeta;
  Uint8List? _pickedBytes; // for web
  File? _pickedFile;       // for mobile/desktop
  final ApiService api = ApiService(baseUrl: 'http://127.0.0.1:5001/api');

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // IMPORTANT for web: ensures bytes are available
    );
    if (result == null) return;
    final pf = result.files.first;

    setState(() {
      _pickedFileMeta = pf;
      _pickedBytes = pf.bytes;
      // only set File on non-web and when a real path exists
      _pickedFile = (pf.path != null && !kIsWeb) ? File(pf.path!) : null;
    });
  }

  Widget _preview() {
    if (_pickedBytes != null) {
      return Image.memory(_pickedBytes!, width: 200, height: 200, fit: BoxFit.cover);
    } else if (_pickedFile != null) {
      return Image.file(_pickedFile!, width: 200, height: 200, fit: BoxFit.cover);
    } else {
      return Container(
        width: 200,
        height: 200,
        color: Colors.grey[200],
        child: const Icon(Icons.image, size: 48),
      );
    }
  }

  Future<void> upload(String message) async {
    if (_pickedFileMeta == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pick an image first')));
      return;
    }

    final mimeType = lookupMimeType(_pickedFileMeta!.name) ?? 'image/png';
    final fileName = _pickedFileMeta!.name;
    final uri = Uri.parse('${api.baseUrl}/steg/encrypt_embed');

    final request = http.MultipartRequest('POST', uri);
    request.fields['message'] = message;

    if (kIsWeb) {
      final bytes = _pickedBytes!;
      final multipart = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
        contentType: http_parser.MediaType.parse(mimeType),
      );
      request.files.add(multipart);
    } else {
      final picked = _pickedFile!;
      final stream = http.ByteStream(picked.openRead());
      final length = await picked.length();
      final multipart = http.MultipartFile(
        'file',
        stream,
        length,
        filename: fileName,
        contentType: http_parser.MediaType.parse(mimeType),
      );
      request.files.add(multipart);
    }

    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploaded successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${resp.statusCode}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _msgCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Encrypt & Embed')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _preview(),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: pickFile, child: const Text('Pick Image')),
            const SizedBox(height: 12),
            TextField(controller: _msgCtrl, decoration: const InputDecoration(labelText: 'Message')),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () => upload(_msgCtrl.text), child: const Text('Upload')),
          ],
        ),
      ),
    );
  }
}
