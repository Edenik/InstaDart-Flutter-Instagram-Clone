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
  // TextEditingController _searchController = TextEditingController();
  // Future<QuerySnapshot> _users;

  // _buildUserTile(User user) {
  //   return ListTile(
  //     leading: CircleAvatar(
  //       backgroundColor: Colors.grey,
  //       radius: 20.0,
  //       backgroundImage: user.profileImageUrl.isEmpty
  //           ? AssetImage(placeHolderImageRef)
  //           : CachedNetworkImageProvider(user.profileImageUrl),
  //     ),
  //     title: Text(user.name),
  //     onTap: () => Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (_) => ProfileScreen(
  //           isCameFromBottomNavigation: false,
  //           userId: user.id,
  //           currentUserId:
  //               Provider.of<UserData>(context, listen: false).currentUserId,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // _clearSearch() {
  //   WidgetsBinding.instance
  //       .addPostFrameCallback((_) => _searchController.clear());
  //   setState(() {
  //     _users = null;
  //   });
  // }

  _buildChat(Chat chat, String currentUserId) {
    final bool isRead = chat.readStatus[currentUserId];
    final TextStyle readStyle =
        TextStyle(fontWeight: isRead ? FontWeight.w400 : FontWeight.bold);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 28.0,
        backgroundImage: CachedNetworkImageProvider(''),
      ),
      title: Text(
        chat.name,
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
                  '${chat.memberInfo[chat.recentSender]['name']} : ${chat.recentMessage}',
                  overflow: TextOverflow.ellipsis,
                  style: readStyle,
                )
              : Text(
                  '${chat.memberInfo[chat.recentSender]['name']} : sent an image',
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
    final String currentUserId = Provider.of<UserData>(context).currentUserId;
    return Scaffold(
      appBar: AppBar(
        title: Text('Direct'),
        // filled: true,
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('chats')
            .where('memberIds', arrayContains: currentUserId)
            .orderBy('recentTimestamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              Chat chat = Chat.fromDoc(snapshot.data.documents[index]);

              return _buildChat(chat, currentUserId);
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(thickness: 1.0);
            },
            itemCount: snapshot.data.documents.length,
          );
        },
      ),
    );
  }
}
