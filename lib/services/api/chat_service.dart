import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/services/api/database_service.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:provider/provider.dart';

class ChatService {
  static Future<Chat> createChat(List<User> users, List<String> userIds) async {
    Map<String, dynamic> readStatus = {};

    for (User user in users) {
      readStatus[user.id] = false;
    }

    Timestamp timestamp = Timestamp.now();

    DocumentReference res = await chatsRef.add({
      'recentMessage': 'Chat Created',
      'recentSender': '',
      'recentTimestamp': timestamp,
      'memberIds': userIds,
      'readStatus': readStatus,
    });

    return Chat(
      id: res.documentID,
      recentMessage: 'Chat Created',
      recentSender: '',
      recentTimestamp: timestamp,
      memberIds: userIds,
      readStatus: readStatus,
      memberInfo: users,
    );
  }

  static void sendChatMessage(Chat chat, Message message, User receiverUser) {
    chatsRef.document(chat.id).collection('messages').add({
      'senderId': message.senderId,
      'text': message.text,
      'imageUrl': message.imageUrl,
      'timestamp': message.timestamp,
      'isLiked': message.isLiked ?? false,
      'giphyUrl': message.giphyUrl,
    });

    Post post = Post(
      authorId: receiverUser.id,
    );

    DatabaseService.addActivityItem(
      comment: message.text,
      currentUserId: message.senderId,
      isCommentEvent: false,
      isFollowEvent: false,
      isLikeEvent: false,
      isMessageEvent: true,
      post: post,
      recieverToken: receiverUser.token,
    );
  }

  static void setChatRead(BuildContext context, Chat chat, bool read) async {
    String currentUserId =
        Provider.of<UserData>(context, listen: false).currentUserId;
    chatsRef.document(chat.id).updateData({
      'readStatus.$currentUserId': read,
    });
  }

  // static Future<bool> checkIfChatExist(List<String> users) async {
  //   print(users);
  //   QuerySnapshot snapshot = await chatsRef
  //       .where('memberIds', arrayContainsAny: users)
  //       .getDocuments();

  //   return snapshot.documents.isNotEmpty;
  // }

  static Future<Chat> getChatById(String chatId) async {
    DocumentSnapshot chatDocSnapshot = await chatsRef.document(chatId).get();
    if (chatDocSnapshot.exists) {
      return Chat.fromDoc(chatDocSnapshot);
    }
    return Chat();
  }

  static Future<Chat> getChatByUsers(List<String> users) async {
    QuerySnapshot snapshot = await chatsRef.where('memberIds', whereIn: [
      [users[1], users[0]]
    ]).getDocuments();

    if (snapshot.documents.isEmpty) {
      snapshot = await chatsRef.where('memberIds', whereIn: [
        [users[0], users[1]]
      ]).getDocuments();
    }

    if (snapshot.documents.isNotEmpty) {
      return Chat.fromDoc(snapshot.documents[0]);
    }
    return null;
  }

  static Future<Null> likeUnlikeMessage(Message message, String chatId,
      bool isLiked, User receiverUser, String currentUserId) {
    chatsRef
        .document(chatId)
        .collection('messages')
        .document(message.id)
        .updateData({'isLiked': isLiked});

    Post post = Post(
      authorId: receiverUser.id,
    );

    if (isLiked == true) {
      DatabaseService.addActivityItem(
        comment: message.text ?? null,
        currentUserId: currentUserId,
        isCommentEvent: false,
        isFollowEvent: false,
        isLikeEvent: false,
        isMessageEvent: false,
        isLikeMessageEvent: true,
        post: post,
        recieverToken: receiverUser.token,
      );
    } else {
      DatabaseService.deleteActivityItem(
        comment: message.text ?? null,
        currentUserId: currentUserId,
        isFollowEvent: false,
        post: post,
        isCommentEvent: false,
        isLikeEvent: false,
        isLikeMessageEvent: true,
        isMessageEvent: false,
      );
    }
    return null;
  }
}
