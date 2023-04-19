import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CurrentUserItem extends StatelessWidget {
  final String message;
  final String userId;
  final String? userImageUrl;
  const CurrentUserItem(this.message, this.userId, this.userImageUrl, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FutureBuilder(
          future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
          builder: (context, snap) => snap.connectionState == ConnectionState.waiting
              ? const Center()
              : Flexible(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, right: 5),
                    padding: const EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 30),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              StreamBuilder(
                                stream: FirebaseAuth.instance.userChanges(),
                                builder: (context, userChangesSnapshot) => Text(
                                  userChangesSnapshot.connectionState == ConnectionState.waiting
                                      ? ''
                                      : userChangesSnapshot.data!.displayName.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                message,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ],
                          ),
                        ),
                        if (snap.data!.data()!['user_image_url'] != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(snap.data!.data()!['user_image_url']),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
