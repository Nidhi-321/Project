import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _go();
  }

  Future _go() async {
    await Future.delayed(Duration(milliseconds: 800));
    final auth = Provider.of<AuthService>(context, listen: false);
    if (auth.isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.asset('assets/images/logo.png', width: 120, height: 120),
          SizedBox(height: 14),
          Text('StegCrypt+', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text('Secure steganography + hybrid crypto', style: TextStyle(color: Colors.grey[600])),
        ]),
      ),
    );
  }
}
