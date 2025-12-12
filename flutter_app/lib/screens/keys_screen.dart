import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widgets/modern_button.dart';

class KeysScreen extends StatefulWidget {
  @override
  State<KeysScreen> createState() => _KeysScreenState();
}

class _KeysScreenState extends State<KeysScreen> {
  final _storage = FlutterSecureStorage();
  final _keyCtl = TextEditingController();
  String? _storedKey;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future _load() async {
    final k = await _storage.read(key: 'aes_key_b64');
    setState(() => _storedKey = k);
  }

  Future _save() async {
    if (_keyCtl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Key cannot be empty')));
      return;
    }
    await _storage.write(key: 'aes_key_b64', value: _keyCtl.text.trim());
    _load();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved')));
  }

  Future _clear() async {
    await _storage.delete(key: 'aes_key_b64');
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Keys')),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(children: [
          TextField(controller: _keyCtl, decoration: InputDecoration(labelText: 'AES key (base64)')),
          SizedBox(height: 12),
          Row(children: [
            Expanded(child: ModernButton(label: 'Save key', onPressed: _save)),
            SizedBox(width: 10),
            ElevatedButton(onPressed: _clear, child: Text('Clear')),
          ]),
          SizedBox(height: 18),
          if (_storedKey != null) Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Stored AES key:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                SelectableText(_storedKey!),
              ]),
            ),
          )
        ]),
      ),
    );
  }
}
