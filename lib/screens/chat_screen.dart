import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/services/services.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:instagram/widgets/message_bubble.dart';
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
  List<String> _userIds;
  List<User> _memberInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  _setup() async {
    setState(() => _isLoading = true);
    User currentUser =
        Provider.of<UserData>(context, listen: false).currentUser;

    List<String> userIds = [];
    userIds.add(currentUser.id);
    userIds.add(widget.receiverUser.id);

    List<User> users = [];
    users.add(currentUser);
    users.add(widget.receiverUser);

    Chat chat = await ChatService.getChatByUsers(userIds);

    bool isChatExist = chat != null;

    if (isChatExist) {
      ChatService.setChatRead(context, chat, true);

      Chat chatWithMemberInfo = Chat(
        id: chat.id,
        memberIds: chat.memberIds,
        memberInfo: users,
        readStatus: chat.readStatus,
        recentMessage: chat.recentMessage,
        recentSender: chat.recentSender,
        recentTimestamp: chat.recentTimestamp,
      );

      setState(() {
        _chat = chatWithMemberInfo;
      });
    }

    setState(() {
      _currentUser = currentUser;
      _isChatExist = isChatExist;
      _memberInfo = users;
      _userIds = userIds;
      _isLoading = false;
    });
  }

  Future<void> _createChat(userIds) async {
    Chat chat = await ChatService.createChat(_memberInfo, userIds);

    setState(() {
      _chat = chat;
      _isChatExist = true;
    });
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
              onPressed: _isComposingMessage
                  ? () => _sendMessage(_messageController.text, null)
                  : null,
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

  _sendMessage(String text, String imageUrl) async {
    print('chat exist: $_isChatExist');
    if ((text != null && text.trim().isNotEmpty) || imageUrl != null) {
      if (!_isChatExist) {
        await _createChat(_userIds);
      }

      if (imageUrl == null) {
        _messageController.clear();
        setState(() => _isComposingMessage = false);
      }

      Message message = Message(
        senderId: _currentUser.id,
        text: text,
        imageUrl: imageUrl,
        timestamp: Timestamp.now(),
      );

      ChatService.sendChatMessage(_chat, message);
    }
  }

  _buildMessagesStream() {
    print(_chat.id);
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
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              physics: AlwaysScrollableScrollPhysics(),
              reverse: true,
              children: _buildMessageBubbles(snapshot),
            ),
          ),
        );
      },
    );
  }

  List<MessageBubble> _buildMessageBubbles(
    AsyncSnapshot<QuerySnapshot> messages,
  ) {
    List<MessageBubble> messageBubbles = [];

    messages.data.documents.forEach((doc) {
      Message message = Message.fromDoc(doc);
      MessageBubble messageBubble = MessageBubble(
        chat: _chat,
        message: message,
      );
      messageBubbles.add(messageBubble);
    });
    return messageBubbles;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (_chat != null) {
          ChatService.setChatRead(context, _chat, true);
        } else if (widget.chat != null) {
          ChatService.setChatRead(context, _chat, true);
        }
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
              if (_isChatExist && !_isLoading) _buildMessagesStream(),
              Divider(height: 1.0),
              _buildMessageTF(),
            ],
          ),
        ),
      ),
    );
  }
}
