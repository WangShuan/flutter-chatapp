import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../widgets/auth/auth_form.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  bool isLoading = false;
  void _submitAuthForm(
      bool isSignup, String name, String email, String password, File? userImageFile) async {
    try {
      dynamic authResult;
      setState(() {
        isLoading = true;
      });
      if (isSignup) {
        authResult = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        await _auth.currentUser?.updateDisplayName(name);
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child('${_auth.currentUser!.uid}.jpg');
        UploadTask uploadTask = ref.putFile(userImageFile!);
        String imgurl = await (await uploadTask).ref.getDownloadURL();

        FirebaseFirestore.instance.collection('users').doc(authResult.user.uid).set({
          'username': name,
          'email': email,
          'user_image_url': imgurl,
        });
      } else {
        authResult = await _auth.signInWithEmailAndPassword(email: email, password: password);
      }
    } on FirebaseAuthException catch (err) {
      var errMsg = '系統出現問題，請重新啟動。';
      if (err.code == 'invalid-email') {
        errMsg = '無效的電子信箱！';
      } else if (err.code == 'user-disabled') {
        errMsg = '此帳號已被管理員禁用！';
      } else if (err.code == 'user-not-found') {
        errMsg = '帳號不存在，請先建立帳號。';
      } else if (err.code == 'wrong-password') {
        errMsg = '密碼錯誤！';
      } else if (err.code == 'email-already-in-use') {
        errMsg = '此帳號已被使用。';
      } else if (err.code == 'operation-not-allowed') {
        errMsg = '不允許操作！';
      } else if (err.code == 'weak-password') {
        errMsg = '密碼強度不足。';
      } else if (err.code == 'too-many-requests') {
        errMsg = '請求次數過多，請稍後再試。';
      }
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: Platform.isIOS ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
        elevation: 0,
        content: Text(errMsg),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: AuthForm(_submitAuthForm, isLoading),
    );
  }
}
