import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:provider/provider.dart';

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

  void sendChatMessage(Chat chat, Message message) {
    chatsRef.document(chat.id).collection('messages').add({
      'senderId': message.senderId,
      'text': message.text,
      'imageUrl': message.imageUrl,
      'timeStamp': message.timestamp,
    });
  }

  void setChatRead(BuildContext context, Chat chat, bool read) async {
    String currentUserId =
        Provider.of<UserData>(context, listen: false).currentUserId;
    chatsRef.document(chat.id).updateData({
      'readStatus.$currentUserId': read,
    });
  }
}
