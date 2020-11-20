import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/services/services.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:instagram/utilities/custom_navigation.dart';
import 'package:instagram/utilities/repo_const.dart';
import 'package:instagram/widgets/message_bubble.dart';
import 'package:provider/provider.dart';
import 'package:auto_direction/auto_direction.dart';
import 'package:giphy_get/giphy_get.dart';

class ChatScreen extends StatefulWidget {
  final User receiverUser;
  final File imageFile;

  const ChatScreen({this.receiverUser, this.imageFile});
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
  bool _isSending = false;

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

    checkForImage();
  }

  checkForImage() {
    if (widget.imageFile != null) {
      showDialog(
          context: context,
          child: SimpleDialog(
            backgroundColor: Theme.of(context).backgroundColor.withOpacity(0.8),
            title: Column(
              children: [
                Text(
                  'Send Image To ${widget.receiverUser.name}?',
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                Image.file(
                  widget.imageFile,
                  height: 300,
                ),
                SizedBox(
                  height: 10,
                ),
                SimpleDialogOption(
                  child: Center(
                    child: Text('Send',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        )),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);

                    String imageUrl = await StroageService.uploadMessageImage(
                        widget.imageFile);
                    _sendMessage(
                        text: null, imageUrl: imageUrl, giphyUrl: null);
                  },
                ),
                SimpleDialogOption(
                  child: Center(
                    child: Text('Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        )),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ));
    }
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
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
      decoration: BoxDecoration(
          border:
              Border.all(color: Theme.of(context).accentColor.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: <Widget>[
          Container(
            height: 38,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.lightBlue[400],
            ),
            child: IconButton(
              icon: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () async {
                PickedFile pickedFile = await ImagePicker().getImage(
                  source: ImageSource.camera,
                );
                File imageFile = File(pickedFile.path);

                if (imageFile != null) {
                  String imageUrl =
                      await StroageService.uploadMessageImage(imageFile);
                  _sendMessage(text: null, imageUrl: imageUrl, giphyUrl: null);
                }
              },
            ),
          ),
          Expanded(
            child: AutoDirection(
              text: _messageController.text,
              child: TextField(
                minLines: 1,
                maxLines: 4,
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (messageText) {
                  setState(() => _isComposingMessage = messageText.isNotEmpty);
                },
                decoration: InputDecoration(
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    hintText: 'Message..'),
              ),
            ),
          ),
          if (!_isComposingMessage)
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(0.0),
                    width: 30.0,
                    child: IconButton(
                      icon: Icon(Icons.mic),
                      onPressed: () {},
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(0.0),
                    width: 30.0,
                    child: IconButton(
                      icon: Icon(Icons.photo),
                      onPressed: () async {
                        PickedFile pickedFile = await ImagePicker().getImage(
                          source: ImageSource.gallery,
                        );
                        File imageFile = File(pickedFile.path);

                        if (imageFile != null) {
                          String imageUrl =
                              await StroageService.uploadMessageImage(
                                  imageFile);
                          _sendMessage(
                              text: null, imageUrl: imageUrl, giphyUrl: null);
                        }
                      },
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.all(0.0),
                      width: 30.0,
                      child: IconButton(
                        icon: Icon(Icons.insert_emoticon),
                        onPressed: () async {
                          GiphyGif gif = await GiphyGet.getGif(
                            context: context,
                            apiKey: kGiphyApiKey, //YOUR API KEY HERE
                            lang: GiphyLanguage.spanish,
                          );
                          if (gif != null && mounted) {
                            _sendMessage(
                                text: null,
                                imageUrl: null,
                                giphyUrl: gif.images.original.url);
                          }
                        },
                        tooltip: 'Open Sticker',
                      ))
                ],
              ),
            ),
          if (_isComposingMessage)
            GestureDetector(
              onTap: _isComposingMessage && !_isSending
                  ? () => _sendMessage(
                      text: _messageController.text.trim(),
                      imageUrl: null,
                      giphyUrl: null)
                  : null,
              child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Send',
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold),
                  )),
            )
        ],
      ),
    );
  }

  _sendMessage({String text, String imageUrl, String giphyUrl}) async {
    if ((text != null && text.trim().isNotEmpty) ||
        imageUrl != null ||
        giphyUrl != null) {
      setState(() => _isSending = true);

      if (!_isChatExist) {
        await _createChat(_userIds);
      }

      if (imageUrl == null && giphyUrl == null) {
        _messageController.clear();
        setState(() => _isComposingMessage = false);
      }

      Message message = Message(
        senderId: _currentUser.id,
        text: text,
        imageUrl: imageUrl,
        giphyUrl: giphyUrl,
        timestamp: Timestamp.now(),
        isLiked: false,
      );

      ChatService.sendChatMessage(_chat, message, widget.receiverUser);
      setState(() => _isSending = false);
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
        user: message.senderId == _currentUser.id
            ? _currentUser
            : widget.receiverUser,
        chat: _chat,
        message: message,
      );
      messageBubbles.removeWhere((msgBbl) => message.id == msgBbl.message.id);
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
        }

        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              GestureDetector(
                onTap: () => CustomNavigation.navigateToUserProfile(
                  context: context,
                  userId: widget.receiverUser.id,
                  currentUserId: _currentUser.id,
                  isCameFromBottomNavigation: false,
                ),
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.grey,
                  backgroundImage: widget.receiverUser.profileImageUrl.isEmpty
                      ? AssetImage(placeHolderImageRef)
                      : CachedNetworkImageProvider(
                          widget.receiverUser.profileImageUrl),
                ),
              ),
              SizedBox(width: 15.0),
              GestureDetector(
                  onTap: () => CustomNavigation.navigateToUserProfile(
                        context: context,
                        userId: widget.receiverUser.id,
                        currentUserId: _currentUser.id,
                        isCameFromBottomNavigation: false,
                      ),
                  child: Text(widget.receiverUser.name)),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (_isChatExist && !_isLoading) _buildMessagesStream(),
              if (!_isChatExist && _isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (!_isChatExist && !_isLoading) SizedBox.shrink(),
              _buildMessageTF(),
            ],
          ),
        ),
      ),
    );
  }
}
