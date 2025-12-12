import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/encrypt_screen.dart';
import 'screens/decrypt_screen.dart';
import 'screens/keys_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (ctx) => SplashScreen(),
  '/login': (ctx) => LoginScreen(),
  '/home': (ctx) => HomeScreen(),
  '/encrypt': (ctx) => EncryptScreen(),
  '/decrypt': (ctx) => DecryptScreen(),
  '/keys': (ctx) => KeysScreen(),
};
