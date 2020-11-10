import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/screens/screens.dart';
import 'package:instagram/services/database_service.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:provider/provider.dart';

class DirectMessagesScreen extends StatefulWidget {
  @override
  _DirectMessagesScreenState createState() => _DirectMessagesScreenState();
}

class _DirectMessagesScreenState extends State<DirectMessagesScreen> {
  Stream<List<Chat>> chatsStream;
  User _currentUser;

  @override
  void initState() {
    super.initState();

    final User currentUser =
        Provider.of<UserData>(context, listen: false).currentUser;
    setState(() {
      _currentUser = currentUser;
    });

    getChats();
  }

  Stream<List<Chat>> getChats() async* {
    List<Chat> dataToReturn = List();

    Stream<QuerySnapshot> stream = Firestore.instance
        .collection('chats')
        .where('memberIds', arrayContains: _currentUser.id)
        .orderBy('recentTimestamp', descending: true)
        .snapshots();

    await for (QuerySnapshot q in stream) {
      for (var doc in q.documents) {
        Chat chatFromDoc = Chat.fromDoc(doc);
        int receiverIndex = 0;
        List<dynamic> memberIds = chatFromDoc.memberIds;

        // Getting receiver index
        memberIds.forEach((userId) {
          if (userId != _currentUser.id) {
            receiverIndex = memberIds.indexOf(userId);
          }
        });

        List<User> membersInfo = [];

        User receiverUser =
            await DatabaseService.getUserWithId(memberIds[receiverIndex]);
        membersInfo.add(_currentUser);
        membersInfo.add(receiverUser);

        Chat chatWithUserInfo = Chat(
          id: chatFromDoc.id,
          memberIds: chatFromDoc.memberIds,
          memberInfo: membersInfo,
          readStatus: chatFromDoc.readStatus,
          recentMessage: chatFromDoc.recentMessage,
          recentSender: chatFromDoc.recentSender,
          recentTimestamp: chatFromDoc.recentTimestamp,
        );

        dataToReturn.add(chatWithUserInfo);
      }
      yield dataToReturn;
    }
  }

  _buildChat(Chat chat, String currentUserId) {
    final bool isRead = chat.readStatus[currentUserId];
    final TextStyle readStyle =
        TextStyle(fontWeight: isRead ? FontWeight.w400 : FontWeight.bold);

    List<User> users = chat.memberInfo;
    int receiverIndex = 0;
    users.forEach((user) {
      if (user.id != _currentUser.id) {
        receiverIndex = users.indexOf(user);
      }
    });

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 28.0,
        backgroundImage:
            CachedNetworkImageProvider(users[receiverIndex].profileImageUrl),
      ),
      title: Text(
        users[receiverIndex].name,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: chat.recentSender.isEmpty
          ? Text(
              'Chat Created',
              overflow: TextOverflow.ellipsis,
              style: readStyle,
            )
          : chat.recentMessage != null
              ? Text(
                  '${"chat.memberInfo[chat.recentSender]['name']"} : ${chat.recentMessage}',
                  overflow: TextOverflow.ellipsis,
                  style: readStyle,
                )
              : Text(
                  '${"chat.memberInfo[chat.recentSender]['name']"} : sent an image',
                  overflow: TextOverflow.ellipsis,
                  style: readStyle,
                ),
      trailing: Text(
        timeFormat.format(
          chat.recentTimestamp.toDate(),
        ),
        style: readStyle,
      ),
      onTap: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Direct'),
        // filled: true,
      ),
      body: StreamBuilder(
        stream: getChats(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              Chat chat = snapshot.data[index];
              return _buildChat(chat, _currentUser.id);
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(thickness: 1.0);
            },
            itemCount: snapshot.data.length,
          );
        },
      ),
    );
  }
}
