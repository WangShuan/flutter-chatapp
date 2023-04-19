import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../screens/setting_screen.dart';

import '../widgets/chat/messages.dart';
import '../widgets/chat/add_message.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat';
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    final fbm = FirebaseMessaging.instance;
    fbm.requestPermission();

    FirebaseMessaging.onMessage.listen((message) {
      // print('onMessage:$message');
      return;
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // print('onMessageOpenedApp:$message');
      return;
    });

    fbm.subscribeToTopic('chat');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Chatroom'),
        actions: [
          DropdownButton(
            underline: const Divider(
              color: Colors.transparent,
            ),
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            items: const [
              DropdownMenuItem(
                value: 'setting',
                child: Text('設置'),
              ),
              DropdownMenuItem(
                value: 'logout',
                child: Text('登出'),
              ),
            ],
            onChanged: (val) {
              if (val == 'logout') {
                FirebaseAuth.instance.signOut();
              }
              if (val == 'setting') {
                Navigator.of(context).pushNamed(SettingScreen.routeName);
              }
            },
          )
        ],
      ),
      body: Column(
        children: const [
          Expanded(
            child: Messages(),
          ),
          AddMessages()
        ],
      ),
    );
  }
}
