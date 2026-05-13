import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late IO.Socket socket;
  final msgCtrl = TextEditingController();
  final List<String> messages = [];

  @override
  void initState() {
    super.initState();
    socket = IO.io('http://10.0.2.2:5000', IO.OptionBuilder().setTransports(['websocket']).build());
    socket.onConnect((_) => print('Connected'));
    socket.on('receiveMessage', (data) => setState(() => messages.add(data)));
  }

  void sendMessage() {
    socket.emit('sendMessage', msgCtrl.text);
    msgCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, i) => ListTile(title: Text(messages[i])),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            Expanded(child: TextField(controller: msgCtrl)),
            IconButton(icon: const Icon(Icons.send), onPressed: sendMessage),
          ]),
        )
      ]),
    );
  }
}