import 'package:flutter/material.dart';
import '../widgets/modern_button.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  // NOTE: This example uses a fake login and stores a dummy token.
  // Replace with real backend auth endpoints when available.
  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(Duration(seconds: 1)); // simulate network
    // On success save token
    final auth = Provider.of<AuthService>(context, listen: false);
    await auth.saveToken('demo-token-${_username.text}');
    setState(() => _loading = false);
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome')),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(children: [
          SizedBox(height: 12),
          Text('Sign in to StegCrypt+', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          SizedBox(height: 18),
          Form(
            key: _form,
            child: Column(children: [
              TextFormField(controller: _username, decoration: InputDecoration(labelText: 'Username'), validator: notEmptyValidator),
              SizedBox(height: 12),
              TextFormField(controller: _password, decoration: InputDecoration(labelText: 'Password'), obscureText: true, validator: notEmptyValidator),
              SizedBox(height: 20),
              ModernButton(label: 'Login', onPressed: _login, loading: _loading),
            ]),
          ),
          Spacer(),
          TextButton(onPressed: ()=> Navigator.pushNamed(context, '/keys'), child: Text('Manage Keys')),
        ]),
      ),
    );
  }
}
