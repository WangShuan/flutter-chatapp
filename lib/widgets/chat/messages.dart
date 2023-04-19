import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import './current_user_item.dart';
import './other_user_item.dart';

class Messages extends StatelessWidget {
  const Messages({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting
          ? Container(
              color: Theme.of(context).primaryColorDark,
              child: const Center(child: CircularProgressIndicator()),
            )
          : Container(
              color: Theme.of(context).primaryColorDark,
              padding: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                reverse: true,
                itemBuilder: (context, index) {
                  final data = snapshot.data?.docs[index].data();
                  final isCurrentUser = FirebaseAuth.instance.currentUser?.uid == data!['user_id'];
                  return isCurrentUser
                      ? CurrentUserItem(
                          data['text'],
                          FirebaseAuth.instance.currentUser!.uid,
                          data['user_image_url'],
                          key: ValueKey(snapshot.data?.docs[index].id),
                        )
                      : OtherUserItem(
                          data['text'],
                          data['user_id'],
                          data['user_image_url'],
                          key: ValueKey(snapshot.data?.docs[index].id),
                        );
                },
                itemCount: snapshot.data?.docs.length,
              ),
            ),
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy(
            'created_at',
            descending: true,
          )
          .snapshots(),
    );
  }
}
