import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/screens/direct_messages/nested_screens/full_screen_image.dart';
import 'package:instagram/services/api/chat_service.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:instagram/common_widgets/heart_anime.dart';
import 'package:provider/provider.dart';

class MessageBubble extends StatefulWidget {
  final Chat chat;
  final Message message;
  final User user;

  const MessageBubble({this.chat, this.message, this.user});

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

  _likeUnLikeMessage(String currentUserId) {
    ChatService.likeUnlikeMessage(
        widget.message, widget.chat.id, !_isLiked, widget.user, currentUserId);
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
            : () => _likeUnLikeMessage(currentUser.id),
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

    _imageFullScreen(url) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullScreenImage(url),
          ));
    }

    _buildImage(BuildContext context) {
      final size = MediaQuery.of(context).size;
      return GestureDetector(
        onDoubleTap: widget.message.senderId == currentUser.id
            ? null
            : () => _likeUnLikeMessage(currentUser.id),
        onTap: () => _imageFullScreen(widget.message.imageUrl),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: size.height * 0.4,
              width: size.width * 0.6,
              decoration: BoxDecoration(
                border:
                    Border.all(width: 1, color: Theme.of(context).accentColor),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Hero(
                  tag: widget.message.imageUrl,
                  child: CachedNetworkImage(
                    progressIndicatorBuilder: (context, url, downloadProgress) {
                      return Center(
                        child: CircularProgressIndicator(
                            value: downloadProgress.progress),
                      );
                    },
                    fadeInDuration: Duration(milliseconds: 500),
                    imageUrl: widget.message.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            _heartAnim ? HeartAnime(80.0) : SizedBox.shrink(),
          ],
        ),
      );
    }

    _buildGiphy(BuildContext context) {
      final size = MediaQuery.of(context).size;
      return GestureDetector(
        onDoubleTap: widget.message.senderId == currentUser.id
            ? null
            : () => _likeUnLikeMessage(currentUser.id),
        onTap: () => _imageFullScreen(widget.message.giphyUrl),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: size.height * 0.3,
              width: size.width * 0.6,
              decoration: BoxDecoration(
                border:
                    Border.all(width: 1, color: Theme.of(context).accentColor),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Hero(
                  tag: widget.message.giphyUrl,
                  child: CachedNetworkImage(
                    progressIndicatorBuilder: (context, url, downloadProgress) {
                      return Center(
                        child: CircularProgressIndicator(
                            value: downloadProgress.progress),
                      );
                    },
                    fadeInDuration: Duration(milliseconds: 500),
                    imageUrl: widget.message.giphyUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            _heartAnim ? HeartAnime(80.0) : SizedBox.shrink(),
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
              : () => _likeUnLikeMessage(currentUser.id),
          child: Icon(
            widget.message.isLiked ? Icons.favorite : Icons.favorite_border,
            color: widget.message.isLiked ? Colors.red : Colors.grey[400],
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
                      color: widget.message.text != null
                          ? isMe
                              ? Theme.of(context).cardColor
                              : Theme.of(context).primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                      border: Border.all(
                          color: widget.message.text != null
                              ? isMe
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).cardColor
                              : Colors.transparent),
                    ),
                    child: widget.message.text != null
                        ? _buildText()
                        : widget.message.imageUrl != null
                            ? _buildImage(context)
                            : _buildGiphy(context),
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
