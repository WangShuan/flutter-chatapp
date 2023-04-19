import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OtherUserItem extends StatelessWidget {
  final String message;
  final String userId;
  final File? userImageUrl;
  const OtherUserItem(this.message, this.userId, this.userImageUrl, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        FutureBuilder(
          builder: (context, snap) => snap.connectionState == ConnectionState.waiting
              ? const Center()
              : Flexible(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, left: 5),
                    padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 30),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (snap.data!.data()!['user_image_url'] != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(snap.data!.data()!['user_image_url']),
                            ),
                          ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snap.data!.data()!['username'],
                                style: TextStyle(
                                  color: Theme.of(context).primaryColorDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                message,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColorDark,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        ),
      ],
    );
  }
}
