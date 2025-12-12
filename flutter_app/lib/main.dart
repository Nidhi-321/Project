import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'theme.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  await authService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => authService,
        ),
      ],
      child: StegCryptApp(),
    ),
  );
}

class StegCryptApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StegCrypt+',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: appRoutes,
      debugShowCheckedModeBanner: false,
    );
  }
}
