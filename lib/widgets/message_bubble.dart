import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/services/chat_service.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:provider/provider.dart';

class MessageBubble extends StatefulWidget {
  final Chat chat;
  final Message message;

  const MessageBubble({this.chat, this.message});

  @override
  _MessageBubbleState createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _isLiked = false;
  bool _heartAnim = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLiked = widget.message.isLiked;
    });
  }

  _likeUnLikeMessage() {
    ChatService.likeUnlikeMessage(widget.message.id, widget.chat.id, !_isLiked);
    setState(() => _isLiked = !_isLiked);

    if (_isLiked) {
      setState(() {
        _heartAnim = true;
      });
      Timer(Duration(milliseconds: 350), () {
        setState(() {
          _heartAnim = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final User currentUser =
        Provider.of<UserData>(context, listen: false).currentUser;

    final bool isMe = widget.message.senderId == currentUser.id;

    int receiverIndex = widget.chat.memberInfo
        .indexWhere((member) => member.id != widget.message.senderId);

    _buildText() {
      return GestureDetector(
        onDoubleTap: widget.message.senderId == currentUser.id
            ? null
            : () => _likeUnLikeMessage(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
          child: Text(
            widget.message.text,
            style:
                TextStyle(color: Theme.of(context).accentColor, fontSize: 15.0),
          ),
        ),
      );
    }

    _imageFullScreen() {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Scaffold(
                body: Stack(
              children: [
                Container(
                  child: Hero(
                    tag: widget.message.imageUrl,
                    child: Image(
                      image:
                          CachedNetworkImageProvider(widget.message.imageUrl),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 40.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(30)),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      iconSize: 30.0,
                      color: Colors.black,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            )),
          ));
    }

    _buildImage(BuildContext context) {
      final size = MediaQuery.of(context).size;
      return GestureDetector(
        onDoubleTap: widget.message.senderId == currentUser.id
            ? null
            : () => _likeUnLikeMessage(),
        onTap: _imageFullScreen,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: size.height * 0.2,
              width: size.width * 0.6,
              child: Hero(
                tag: widget.message.imageUrl,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).accentColor.withOpacity(0.7)),
                    borderRadius: BorderRadius.circular(20.0),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image:
                          CachedNetworkImageProvider(widget.message.imageUrl),
                    ),
                  ),
                ),
              ),
            ),
            _heartAnim
                ? Animator(
                    duration: Duration(milliseconds: 300),
                    tween: Tween(begin: 0.5, end: 1.4),
                    curve: Curves.elasticOut,
                    builder: (context, anim, child) => Transform.scale(
                      scale: anim.value,
                      child: Icon(
                        Icons.favorite,
                        size: 80.0,
                        color: Colors.white54,
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      );
    }

    Padding _buildLikeIcon() {
      return Padding(
        padding: isMe
            ? const EdgeInsets.only(left: 10)
            : const EdgeInsets.only(right: 10),
        child: GestureDetector(
          onTap: widget.message.senderId == currentUser.id
              ? null
              : () => _likeUnLikeMessage(),
          child: Icon(
            _isLiked ? Icons.favorite : Icons.favorite_border,
            color: _isLiked ? Colors.red : Colors.grey[400],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: isMe
                    ? const EdgeInsets.only(right: 40.0)
                    : const EdgeInsets.only(left: 40.0),
                child: Text(
                  isMe
                      ? '${timeFormat.format(widget.message.timestamp.toDate())}'
                      : '${widget.chat.memberInfo[receiverIndex].name} • ${timeFormat.format(widget.message.timestamp.toDate())}',
                  style: TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ),
              const SizedBox(
                height: 6.0,
              ),
              Row(
                children: [
                  if (!isMe) _buildLikeIcon(),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.65,
                    ),
                    decoration: BoxDecoration(
                      color: widget.message.imageUrl == null
                          ? isMe
                              ? Theme.of(context).cardColor
                              : Theme.of(context).primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                      border: Border.all(
                          color: widget.message.imageUrl == null
                              ? isMe
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).cardColor
                              : Colors.transparent),
                    ),
                    child: widget.message.imageUrl == null
                        ? _buildText()
                        : _buildImage(context),
                  ),
                  if (isMe) _buildLikeIcon()
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}