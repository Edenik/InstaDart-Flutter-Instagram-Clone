import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:provider/provider.dart';

class ChatService {
  static Future<bool> createChat(
    List<String> userIds,
  ) async {
    Map<String, dynamic> readStatus = {};

    for (String userId in userIds) {
      readStatus[userId] = false;
    }

    await chatsRef.add({
      'recentMessage': 'Chat Created',
      'recentSender': '',
      'recentTimestamp': Timestamp.now(),
      'memberIds': userIds,
      'readStatus': readStatus,
    });
    return true;
  }

  static void sendChatMessage(Chat chat, Message message) {
    chatsRef.document(chat.id).collection('messages').add({
      'senderId': message.senderId,
      'text': message.text,
      'imageUrl': message.imageUrl,
      'timeStamp': message.timestamp,
    });
  }

  static void setChatRead(BuildContext context, Chat chat, bool read) async {
    String currentUserId =
        Provider.of<UserData>(context, listen: false).currentUserId;
    chatsRef.document(chat.id).updateData({
      'readStatus.$currentUserId': read,
    });
  }

  static Future<bool> checkIfChatExist(List<String> users) async {
    print(users);
    QuerySnapshot snapshot =
        await chatsRef.where('memberIds', isEqualTo: users).getDocuments();

    // print(snapshot.documents);
    // print(snapshot.documents.isNotEmpty);
    return snapshot.documents.isNotEmpty;
  }
}
