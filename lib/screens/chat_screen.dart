import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/services/chat_service.dart';
import 'package:instagram/services/services.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  const ChatScreen(this.chat);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isComposingMessage = false;
  Chat _chat;

  @override
  void initState() {
    super.initState();
    if (widget.chat != null) {
      setState(() => _chat = widget.chat);
    }
    ChatService.setChatRead(context, widget.chat, true);
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
              onPressed: () async {
                PickedFile pickedFile = await ImagePicker().getImage(
                  source: ImageSource.camera,
                );
                File imageFile = File(pickedFile.path);

                if (imageFile != null) {
                  // StroageService
                  //         .uploadMessageImage(imageFile);
                  // _sendMessage(null, imageUrl);
                }
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        ChatService.setChatRead(context, widget.chat, true);
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('widget.chat.name'),
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
