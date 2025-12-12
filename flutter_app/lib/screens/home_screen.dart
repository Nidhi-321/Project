// lib/screens/home_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<User> users = [];
  User? me;
  final socket = SocketService();
  bool socketConnected = false;

  @override
  void initState() {
    super.initState();
    _loadMe();
    _fetchUsers();
    socket.connect(url: 'http://127.0.0.1:5001');
    socket.usersStream.listen((u) {
      setState(() {
        users = u.map((e) => User.fromJson(Map<String, dynamic>.from(e))).toList();
      });
    });
    socket.messagesStream.listen((msg) {
      // optionally show notification/snackbar when new message arrives
      if (msg['receiver_id'] == me?.id) {
        final s = 'New msg from ${msg['sender_id']}';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
      }
    });
  }

  Future<void> _loadMe() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('current_user')) {
      final j = jsonDecode(prefs.getString('current_user')!) as Map<String, dynamic>;
      setState(() {
        me = User.fromJson(j);
      });
      socket.identify(me!.id);
    }
  }

  Future<void> _fetchUsers() async {
    final list = await ApiService.getUsers();
    if (list != null) {
      setState(() {
        users = list.map((e) => User.fromJson(e)).toList();
      });
    }
  }

  void _openChat(User u) {
    final myId = me?.id ?? 0;
    Navigator.pushNamed(context, '/chat', arguments: {'recipient': u, 'myUserId': myId});
  }

  @override
  Widget build(BuildContext context) {
    final title = me != null ? 'Logged in: ${me!.username}' : 'Not logged in';
    return Scaffold(
      appBar: AppBar(title: Text('Home — $title')),
      body: RefreshIndicator(
        onRefresh: _fetchUsers,
        child: ListView.builder(
          itemCount: users.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return ListTile(
                title: const Text('Users'),
                trailing: IconButton(
                  icon: const Icon(Icons.login),
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  tooltip: 'Login / Register',
                ),
              );
            }
            final u = users[index - 1];
            return ListTile(
              title: Text(u.username),
              subtitle: Text('id: ${u.id}'),
              onTap: () => _openChat(u),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        onPressed: _fetchUsers,
      ),
    );
  }
}
