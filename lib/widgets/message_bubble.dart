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
  }

  @override
  Widget build(BuildContext context) {
    final User currentUser =
        Provider.of<UserData>(context, listen: false).currentUser;

    final bool isMe = widget.message.senderId == currentUser.id;

    int receiverIndex = widget.chat.memberInfo
        .indexWhere((member) => member.id != widget.message.senderId);

    _buildText(bool isMe) {
      return GestureDetector(
        onDoubleTap: widget.message.senderId == currentUser.id
            ? null
            : () => _likeUnLikeMessage(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
          child: Text(
            widget.message.text,
            style: TextStyle(color: Colors.white, fontSize: 15.0),
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
        child: Container(
          height: size.height * 0.2,
          width: size.width * 0.6,
          child: Hero(
            tag: widget.message.imageUrl,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(widget.message.imageUrl),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
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
                    ? const EdgeInsets.only(right: 10.0)
                    : const EdgeInsets.only(left: 10.0),
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
                  IconButton(
                    icon: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.red : Colors.grey[200],
                    ),
                    onPressed: widget.message.senderId == currentUser.id
                        ? null
                        : () => _likeUnLikeMessage(),
                  ),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.65,
                    ),
                    decoration: BoxDecoration(
                      color: widget.message.imageUrl == null
                          ? isMe
                              ? Colors.lightBlue
                              : Colors.green[400]
                          : Colors.transparent,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    child: widget.message.imageUrl == null
                        ? _buildText(isMe)
                        : _buildImage(context),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
