// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';
import 'models/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StegCrypt+',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/':
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case '/chat':
            final args = settings.arguments as Map<String, dynamic>?;
            final recipient = args?['recipient'];
            final myUserId = args?['myUserId'];
            if (recipient == null || myUserId == null) {
              return MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text('Missing args')),
                  body: const Center(child: Text('recipient and myUserId required')),
                ),
              );
            }
            User userObj;
            if (recipient is User) {
              userObj = recipient;
            } else if (recipient is Map) {
              userObj = User.fromJson(Map<String, dynamic>.from(recipient));
            } else {
              return MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text('Invalid recipient')),
                  body: const Center(child: Text('recipient must be a User or a Map')),
                ),
              );
            }
            return MaterialPageRoute(
              builder: (_) => ChatScreen(recipient: userObj, myUserId: myUserId as int),
            );
          default:
            return MaterialPageRoute(
                builder: (_) => Scaffold(
                      appBar: AppBar(title: const Text('Not found')),
                      body: const Center(child: Text('Route not found')),
                    ));
        }
      },
    );
  }
}
