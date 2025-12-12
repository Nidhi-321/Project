// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/socket_service.dart';

class ChatScreen extends StatefulWidget {
  final User recipient;
  final int myUserId;

  const ChatScreen({super.key, required this.recipient, required this.myUserId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final socket = SocketService();
  final _ctrl = TextEditingController();
  final List<Map<String, dynamic>> messages = []; // store simple message objects

  @override
  void initState() {
    super.initState();
    socket.connect(url: 'http://127.0.0.1:5001');
    socket.identify(widget.myUserId);
    socket.messagesStream.listen((msg) {
      // append incoming message if relevant
      setState(() {
        messages.add(msg);
      });
    });
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    // for demo: send ciphertext as plain text to backend (server will store and forward)
    socket.sendMessage(widget.myUserId, widget.recipient.id, text);
    // local echo
    setState(() {
      messages.add({'sender_id': widget.myUserId, 'receiver_id': widget.recipient.id, 'ciphertext': text});
      _ctrl.clear();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.recipient.username}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (c, idx) {
                final m = messages[idx];
                final mine = m['sender_id'] == widget.myUserId;
                return ListTile(
                  title: Text(m['ciphertext']?.toString() ?? ''),
                  subtitle: Text('from ${m['sender_id']}'),
                  tileColor: mine ? Colors.green[50] : null,
                );
              },
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(controller: _ctrl, decoration: const InputDecoration(hintText: 'Type ciphertext or image URL')),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: _send)
              ],
            ),
          )
        ],
      ),
    );
  }
}
