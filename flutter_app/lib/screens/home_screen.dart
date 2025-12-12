import 'package:flutter/material.dart';
import '../widgets/modern_button.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('StegCrypt+'),
        actions: [
          IconButton(onPressed: () async {
            await auth.clear();
            Navigator.pushReplacementNamed(context, '/login');
          }, icon: Icon(Icons.logout))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Quick actions', style: Theme.of(context).textTheme.headline6),
          SizedBox(height: 16),
          Row(children: [
            Expanded(child: ModernButton(label: 'Encrypt & Embed', onPressed: () => Navigator.pushNamed(context, '/encrypt'))),
            SizedBox(width: 12),
            Expanded(child: ModernButton(label: 'Extract & Decrypt', onPressed: () => Navigator.pushNamed(context, '/decrypt'))),
          ]),
          SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Tips', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('- Use PNG cover images for reliable embedding.\n- Higher-complexity images allow larger payloads.\n- Keep backups of AES keys / salts.'),
              ]),
            ),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/keys'),
        child: Icon(Icons.vpn_key),
      ),
    );
  }
}
