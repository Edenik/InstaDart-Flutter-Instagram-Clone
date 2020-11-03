import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/comment_model.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/user_data.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/services/database_service.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:instagram/utilities/styles.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentsScreen extends StatefulWidget {
  final Post post;
  final int likeCount;
  final User author;

  CommentsScreen({this.post, this.likeCount, this.author});

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

_goToUserProfile(BuildContext context, Post post, String currentUserId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ProfileScreen(
        currentUserId: currentUserId,
        userId: post.authorId,
      ),
    ),
  );
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
        onTap: () => _goToUserProfile(context, widget.post, currentUserId),
        child: CircleAvatar(
          radius: 25.0,
          backgroundColor: Colors.grey,
          backgroundImage: author.profileImageUrl.isEmpty
              ? AssetImage(placeHolderImageRef)
              : CachedNetworkImageProvider(author.profileImageUrl),
        ),
      ),
      title: GestureDetector(
          onTap: () => _goToUserProfile(context, widget.post, currentUserId),
          child: Text(
            author.name,
            style: kFontWeightBoldTextStyle,
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
    final currentUserId =
        Provider.of<UserData>(context, listen: false).currentUserId;
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
            CircleAvatar(
              radius: 18.0,
              backgroundColor: Colors.grey,
              backgroundImage: widget.author.profileImageUrl.isEmpty
                  ? AssetImage(placeHolderImageRef)
                  : CachedNetworkImageProvider(widget.author.profileImageUrl),
            ),
            SizedBox(width: 20.0),
            Expanded(
              child: TextField(
                controller: _commentController,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (comment) {
                  setState(() {
                    _isCommenting = comment.length > 0;
                  });
                },
                decoration:
                    InputDecoration.collapsed(hintText: 'Add a comment...'),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  if (_isCommenting) {
                    DatabaseService.commentOnPost(
                      currentUserId: currentUserId,
                      post: widget.post,
                      comment: _commentController.text,
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
    // final String currentUserId =
    //     Provider.of<UserData>(context, listen: false).currentUserId;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Comments',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Column(
          children: <Widget>[
            SizedBox(height: 10.0),
            _buildListTile(
                context, widget.author, postDescription, currentUserId),
            Divider(),
            // Padding(
            //   padding: const EdgeInsets.all(12.0),
            //   child: Text(
            //     '${widget.likeCount} likes',
            //     style: TextStyle(
            //       fontSize: 20.0,
            //       fontWeight: FontWeight.w600,
            //     ),
            //   ),
            // ),
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
        ));
  }
}
