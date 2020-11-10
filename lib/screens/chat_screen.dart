import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/services/services.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;
  final User receiverUser;

  const ChatScreen(this.chat, this.receiverUser);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isComposingMessage = false;
  Chat _chat;
  bool _isChatExist = false;
  User _currentUser;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  _setup() async {
    User currentUser =
        Provider.of<UserData>(context, listen: false).currentUser;

    List<String> userIds = [];
    userIds.add(currentUser.id);
    userIds.add(widget.receiverUser.id);
    bool isChatExist = await ChatService.checkIfChatExist(userIds);
    print('chat exist: $isChatExist');

    setState(() {
      _currentUser = currentUser;
      _isChatExist = isChatExist;
    });

    if (isChatExist) {
      ChatService.setChatRead(context, widget.chat, true);
    }
    if (widget.chat != null) {
      setState(() => _chat = widget.chat);
    }
  }

  submit() async {
    if (!_isChatExist) {
      List<String> userIds = [];
      userIds.add(_currentUser.id);
      userIds.add(widget.receiverUser.id);
      // userIds.add('CGc5lhJJKFX3EYfrxcjxfKCi7GD3'); //a@a.com
      // userIds.add('iCmGphU8FNVxGVrNfxYN2ofOzwP2'); //edenik5@gmail.com
      bool res = await ChatService.createChat(userIds);
      if (!res) return;
    }
  }

  Container _buildMessageTF() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: Icon(Icons.photo),
              onPressed: () {
                submit();
                // List<String> users = [];
                // users.add('CGc5lhJJKFX3EYfrxcjxfKCi7GD3'); //a@a.com
                // users.add('iCmGphU8FNVxGVrNfxYN2ofOzwP2'); //edenik5@gmail.com

                // ChatService.checkIfChatExist(users);
                // PickedFile pickedFile = await ImagePicker().getImage(
                //   source: ImageSource.camera,
                // );
                // File imageFile = File(pickedFile.path);

                // if (imageFile != null) {
                //   // StroageService
                //   //         .uploadMessageImage(imageFile);
                //   // _sendMessage(null, imageUrl);
                // }
              },
            ),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (messageText) {
                setState(() => _isComposingMessage = messageText.isNotEmpty);
              },
              decoration: InputDecoration.collapsed(hintText: 'Send a message'),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: Icon(Icons.send),
              onPressed: _isComposingMessage
                  ? () => _sendMessage(_messageController.text, null)
                  : null,
            ),
          )
        ],
      ),
    );
  }

  _sendMessage(String text, String imageUrl) {
    if ((text != null && text.trim().isEmpty) || imageUrl != null) {
      if (imageUrl == null) {
        _messageController.clear();
        setState(() => _isComposingMessage = false);
      }

      Message message = Message(
        senderId: Provider.of<UserData>(context, listen: false).currentUserId,
        text: text,
        imageUrl: imageUrl,
        timestamp: Timestamp.now(),
      );

      ChatService.sendChatMessage(_chat, message);
    }
  }

  _buildMessagesStream() {
    return StreamBuilder(
      stream: chatsRef
          .document(_chat.id)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .snapshots(),
      builder: (BuildContext contex, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }
        return Expanded(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: ListView(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        ChatService.setChatRead(context, widget.chat, true);
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: Colors.grey,
                backgroundImage: widget.receiverUser.profileImageUrl.isEmpty
                    ? AssetImage(placeHolderImageRef)
                    : CachedNetworkImageProvider(
                        widget.receiverUser.profileImageUrl),
              ),
              SizedBox(width: 5.0),
              Text(widget.receiverUser.name),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // _buildMessagesStream(),
              Divider(height: 1.0),
              _buildMessageTF(),
            ],
          ),
        ),
      ),
    );
  }
}
