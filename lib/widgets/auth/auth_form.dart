import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import './user_image_picker.dart';

class AuthForm extends StatefulWidget {
  final void Function(
    bool isSignup,
    String name,
    String email,
    String password,
    File? userImageFile,
  ) submitFn;

  final bool isLoading;

  const AuthForm(this.submitFn, this.isLoading, {super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _isSignup = false;
  String _name = '';
  String _email = '';
  String _password = '';
  File? _userImageFile;
  // bool _isShowImgErr = false;
  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_userImageFile == null && _isSignup) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      // _isShowImgErr = false;
    });
    _formKey.currentState!.save();
    widget.submitFn(_isSignup, _name, _email, _password, _userImageFile);
  }

  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 10),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(60),
                    topLeft: Radius.circular(60),
                    bottomLeft: Radius.circular(60),
                  ),
                  color: Theme.of(context).primaryColorDark,
                ),
                child: Text(
                  "CHATROOM*",
                  style: GoogleFonts.bubblegumSans(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      height: 1.5,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              if (_isSignup) UserImagePicker(_pickedImage),
              if (_userImageFile == null && _isSignup)
                Text(
                  '請上傳用戶頭像',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    height: 2,
                  ),
                ),
              if (_isSignup)
                TextFormField(
                  key: const ValueKey('name'),
                  decoration: const InputDecoration(
                    labelText: '暱稱',
                  ),
                  autocorrect: true,
                  textCapitalization: TextCapitalization.words,
                  enableSuggestions: false,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 2) {
                      return '暱稱不得少於兩個字';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _name = value!;
                  },
                ),
              TextFormField(
                key: const ValueKey('email'),
                autocorrect: false,
                enableSuggestions: false,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                ],
                decoration: const InputDecoration(
                  labelText: '電子信箱',
                ),
                validator: (val) {
                  final bool emailValid = RegExp(
                          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                      .hasMatch(val!);
                  if (val.isEmpty || !emailValid) {
                    return '請輸入正確的電子信箱';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) {
                  _email = value!;
                },
              ),
              TextFormField(
                key: const ValueKey('password'),
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                ],
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: '密碼',
                ),
                validator: (value) {
                  if (value!.isEmpty || value.length < 5) {
                    return '密碼不得少於六個字';
                  } else {
                    return null;
                  }
                },
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: _isSignup ? TextInputAction.next : TextInputAction.done,
                onSaved: (value) {
                  _password = value!;
                },
                onFieldSubmitted: (value) => _submit(),
              ),
              if (_isSignup)
                TextFormField(
                  key: const ValueKey('passwordconfirm'),
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                  decoration: const InputDecoration(
                    labelText: '確認密碼',
                  ),
                  validator: (value) {
                    if (value!.isEmpty || value != _passwordController.text) {
                      return '密碼不相符';
                    }
                    return null;
                  },
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: _submit,
                child: widget.isLoading
                    ? Container(
                        padding: const EdgeInsets.all(4),
                        height: 24,
                        width: 24,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _isSignup ? '註冊' : '登入',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isSignup = !_isSignup;
                  });
                },
                child: Text(
                  _isSignup ? '切換為登入帳號' : '創建新帳號',
                  style: const TextStyle(
                      // fontWeight: FontWeight.bold,
                      ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
