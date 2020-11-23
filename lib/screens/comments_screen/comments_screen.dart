import 'package:auto_direction/auto_direction.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:instagram/utilities/custom_navigation.dart';
import 'package:instagram/common_widgets/user_badges.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:instagram/models/models.dart';
import 'package:instagram/services/services.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:instagram/utilities/themes.dart';

class CommentsScreen extends StatefulWidget {
  final Post post;
  final int likeCount;
  final User author;
  final PostStatus postStatus;

  CommentsScreen(
      {this.post, this.likeCount, this.author, @required this.postStatus});

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

_goToUserProfile(BuildContext context, Comment comment, String currentUserId) {
  CustomNavigation.navigateToUserProfile(
      context: context,
      currentUserId: currentUserId,
      userId: comment.authorId,
      isCameFromBottomNavigation: false);
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isCommenting = false;

  _buildComment(Comment comment, String currentUserId) {
    return FutureBuilder(
      future: DatabaseService.getUserWithId(comment.authorId),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }
        User author = snapshot.data;

        return _buildListTile(context, author, comment, currentUserId);
      },
    );
  }

  _buildListTile(BuildContext context, User author, Comment comment,
      String currentUserId) {
    return ListTile(
      leading: GestureDetector(
        onTap: () => _goToUserProfile(context, comment, currentUserId),
        child: CircleAvatar(
          radius: 25.0,
          backgroundColor: Colors.grey,
          backgroundImage: author.profileImageUrl.isEmpty
              ? AssetImage(placeHolderImageRef)
              : CachedNetworkImageProvider(author.profileImageUrl),
        ),
      ),
      title: GestureDetector(
          onTap: () => _goToUserProfile(context, comment, currentUserId),
          child: Row(
            children: [
              Text(
                author.name,
                style: kFontWeightBoldTextStyle,
              ),
              UserBadges(user: widget.author, size: 15)
            ],
          )),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 6.0,
          ),
          Text(comment.content),
          SizedBox(
            height: 6.0,
          ),
          Text(timeago.format(comment.timestamp.toDate())),
        ],
      ),
    );
  }

  _buildCommentTF() {
    String hintText;
    if (widget.postStatus == PostStatus.feedPost) {
      if (widget.post.commentsAllowed) {
        hintText = 'Add a comment...';
      } else {
        hintText = 'Comment aren\'t allowed here...';
      }
    } else if (widget.postStatus == PostStatus.archivedPost) {
      hintText = 'This post was archived...';
    } else {
      hintText = 'This post was deleted...';
    }
    final currentUserId =
        Provider.of<UserData>(context, listen: false).currentUserId;
    final profileImageUrl = Provider.of<UserData>(context, listen: false)
        .currentUser
        .profileImageUrl;
    return IconTheme(
      data: IconThemeData(
        color: _isCommenting
            ? Theme.of(context).accentColor
            : Theme.of(context).disabledColor,
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            profileImageUrl != null
                ? CircleAvatar(
                    radius: 18.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: profileImageUrl.isEmpty
                        ? AssetImage(placeHolderImageRef)
                        : CachedNetworkImageProvider(profileImageUrl),
                  )
                : SizedBox.shrink(),
            SizedBox(width: 20.0),
            Expanded(
              child: AutoDirection(
                text: _commentController.text,
                child: TextField(
                  enabled: widget.post.commentsAllowed &&
                      widget.postStatus == PostStatus.feedPost,
                  controller: _commentController,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (comment) {
                    setState(() {
                      _isCommenting = comment.length > 0;
                    });
                  },
                  decoration: InputDecoration(
                    isCollapsed: true,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    hintText: hintText,
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: widget.postStatus != PostStatus.feedPost ||
                        !widget.post.commentsAllowed
                    ? null
                    : () {
                        if (_isCommenting) {
                          DatabaseService.commentOnPost(
                            currentUserId: currentUserId,
                            post: widget.post,
                            comment: _commentController.text,
                            recieverToken: widget.author.token,
                          );
                          _commentController.clear();
                          setState(() {
                            _isCommenting = false;
                          });
                        }
                      },
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId =
        Provider.of<UserData>(context, listen: false).currentUserId;

    Comment postDescription = Comment(
        authorId: widget.author.id,
        content: widget.post.caption,
        id: widget.post.id,
        timestamp: widget.post.timestamp);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.color,
          title: Text(
            'Comments',
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: <Widget>[
              SizedBox(height: 10.0),
              _buildListTile(
                  context, widget.author, postDescription, currentUserId),
              Divider(),
              StreamBuilder(
                stream: commentsRef
                    .document(widget.post.id)
                    .collection('postComments')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        Comment comment =
                            Comment.fromDoc(snapshot.data.documents[index]);
                        return _buildComment(comment, currentUserId);
                      },
                    ),
                  );
                },
              ),
              Divider(
                height: 1.0,
              ),
              _buildCommentTF(),
            ],
          ),
        ));
  }
}
