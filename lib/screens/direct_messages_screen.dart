import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/screens/chat_screen.dart';
import 'package:instagram/screens/screens.dart';
import 'package:instagram/services/database_service.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:instagram/utilities/themes.dart';
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
        List<dynamic> memberIds = chatFromDoc.memberIds;
        int receiverIndex;

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

        dataToReturn.removeWhere((chat) => chat.id == chatWithUserInfo.id);

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
    int receiverIndex = users.indexWhere((user) => user.id != _currentUser.id);
    int senderIndex = users.indexWhere((user) => user.id == chat.recentSender);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 28.0,
        backgroundImage: users[receiverIndex].profileImageUrl.isEmpty
            ? AssetImage(placeHolderImageRef)
            : CachedNetworkImageProvider(users[receiverIndex].profileImageUrl),
      ),
      title: Text(
        users[receiverIndex].name,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Container(
        height: 35,
        child: chat.recentSender.isEmpty
            ? Text(
                'Chat Created',
                overflow: TextOverflow.ellipsis,
                style: readStyle,
              )
            : chat.recentMessage != null
                ? Text(
                    '${chat.memberInfo[senderIndex].name} : ${chat.recentMessage}',
                    overflow: TextOverflow.ellipsis,
                    style: readStyle,
                  )
                : Text(
                    '${chat.memberInfo[senderIndex].name} : sent an attachment',
                    overflow: TextOverflow.ellipsis,
                    style: readStyle,
                  ),
      ),
      trailing: Text(
        timeFormat.format(
          chat.recentTimestamp.toDate(),
        ),
        style: readStyle,
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(users[receiverIndex]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Direct'),
      ),
      body: StreamBuilder(
        stream: getChats(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Column(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => SearchScreen(
                              searchFrom: SearchFrom.messagesScreen,
                            ))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width * 0.9,
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(5.0)),
                    child: Row(
                      children: [
                        Icon(Icons.search),
                        SizedBox(width: 5),
                        Text('Search'),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 10),
                    child: Text(
                      'Messages',
                      style: kFontSize18TextStyle,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView.separated(
                  itemBuilder: (BuildContext context, int index) {
                    Chat chat = snapshot.data[index];
                    return _buildChat(chat, _currentUser.id);
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(thickness: 1.0);
                  },
                  itemCount: snapshot.data.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
