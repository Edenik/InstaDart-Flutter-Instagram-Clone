import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/utilities/constants.dart';

class ChatService {
  Future<bool> createChat(
    BuildContext context,
    String name,
    File file,
    List<String> users,
  ) async {
    Map<String, dynamic> readStatus = {};

    for (String userId in users) {
      readStatus[userId] = false;
    }

    await chatsRef.add({
      'recentMessage': 'Chat Created',
      'recentSender': '',
      'recentTimestamp': Timestamp.now(),
      'memberIds': users,
      'readStatus': readStatus,
    });
    return true;
  }

  void sendChatMessage(Chat chat, Message message) {}
}
