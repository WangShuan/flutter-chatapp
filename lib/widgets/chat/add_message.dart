import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddMessages extends StatefulWidget {
  const AddMessages({super.key});

  @override
  State<AddMessages> createState() => _AddMessagesState();
}

class _AddMessagesState extends State<AddMessages> {
  String _enterMsg = '';
  final _msgController = TextEditingController();
  void _sendMsg() {
    FocusScope.of(context).unfocus();

    FirebaseFirestore.instance.collection('chat').add({
      'text': _enterMsg,
      'created_at': Timestamp.now(),
      'user_id': FirebaseAuth.instance.currentUser?.uid,
    }).then(
      (value) => setState(() {
        _msgController.clear();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      color: Theme.of(context).primaryColorLight,
      width: double.infinity,
      child: SafeArea(
        child: Row(children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: '請輸入訊息',
                ),
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                controller: _msgController,
                onChanged: (value) {
                  setState(() {
                    _enterMsg = value;
                  });
                },
              ),
            ),
          ),
          IconButton(
            onPressed: _enterMsg.trim().isEmpty ? null : _sendMsg,
            icon: Icon(
              Icons.send,
              color: _enterMsg.trim().isEmpty
                  ? Theme.of(context).disabledColor
                  : Theme.of(context).primaryColorDark,
            ),
          ),
        ]),
      ),
    );
  }
}
