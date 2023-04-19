import 'package:chatapp/screens/setting_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import './screens/auth_screen.dart';
import './screens/chat_screen.dart';

import './firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatroom',
      theme: ThemeData(
        primaryColor: Colors.brown,
        primaryColorDark: Colors.brown[900],
        primaryColorLight: Colors.brown[100],
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.brown,
        ).copyWith(
          error: const Color.fromARGB(255, 250, 111, 111),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(60),
                  topLeft: Radius.circular(60),
                  bottomLeft: Radius.circular(60)),
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(60),
                  topLeft: Radius.circular(60),
                  bottomLeft: Radius.circular(60)),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.brown,
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
            side: const BorderSide(
              color: Colors.brown,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(60),
                  topLeft: Radius.circular(60),
                  bottomLeft: Radius.circular(60)),
            ),
          ),
        ),
      ),
      home: StreamBuilder(
        builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting
            ? const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : snapshot.hasData
                ? const ChatScreen()
                : const AuthScreen(),
        stream: FirebaseAuth.instance.userChanges(),
      ),
      routes: {
        AuthScreen.routeName: (context) => const AuthScreen(),
        ChatScreen.routeName: (context) => const ChatScreen(),
        SettingScreen.routeName: (context) => const SettingScreen(),
      },
    );
  }
}
