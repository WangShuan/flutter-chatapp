import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  static const routeName = '/setting';
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey();
    var name = FirebaseAuth.instance.currentUser?.displayName;
    void submitForm() {
      formKey.currentState!.save();
      FirebaseAuth.instance.currentUser!
          .updateDisplayName(name)
          .then((value) => Navigator.of(context).pop());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('設置'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '暱稱',
                ),
                initialValue: name,
                onSaved: (newValue) => name = newValue,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: submitForm,
                child: const Text('更新'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
