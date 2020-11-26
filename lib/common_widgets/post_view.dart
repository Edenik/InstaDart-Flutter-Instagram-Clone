import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/screens/screens.dart';
import 'package:instagram/services/api/database_service.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:instagram/utilities/custom_navigation.dart';
import 'package:instagram/utilities/themes.dart';
import 'package:instagram/utilities/zoomOverlay.dart';
import 'package:instagram/common_widgets/heart_anime.dart';
import 'package:instagram/common_widgets/user_badges.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:http/http.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';

class PostView extends StatefulWidget {
  final String currentUserId;
  final Post post;
  final User author;
  final PostStatus postStatus;

  PostView(
      {this.currentUserId, this.post, this.author, @required this.postStatus});

  @override
  _PostViewState createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  int _likeCount = 0;
  bool _isLiked = false;
  bool _heartAnim = false;
  Post _post;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likeCount;
    _post = widget.post;
    _initPostLiked();
  }

  @override
  didUpdateWidget(PostView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.likeCount != _post.likeCount) {
      _likeCount = widget.post.likeCount;
    }
  }

  _goToUserProfile(BuildContext context, Post post) {
    CustomNavigation.navigateToUserProfile(
        context: context,
        currentUserId: widget.currentUserId,
        userId: post.authorId,
        isCameFromBottomNavigation: false);
  }

  _initPostLiked() async {
    bool isLiked = await DatabaseService.didLikePost(
        currentUserId: widget.currentUserId, post: _post);
    if (mounted) {
      setState(() {
        _isLiked = isLiked;
      });
    }
  }

  _likePost() {
    if (_isLiked) {
      // Unlike Post
      DatabaseService.unlikePost(
          currentUserId: widget.currentUserId, post: _post);
      setState(() {
        _isLiked = false;
        _likeCount--;
      });
    } else {
      // Like Post
      DatabaseService.likePost(
          currentUserId: widget.currentUserId,
          post: _post,
          receiverToken: widget.author.token);
      setState(() {
        _heartAnim = true;
        _isLiked = true;
        _likeCount++;
      });
      Timer(Duration(milliseconds: 350), () {
        setState(() {
          _heartAnim = false;
        });
      });
    }
  }

  _goToHomeScreen(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (_) => HomeScreen(
                currentUserId: widget.currentUserId,
              )),
      (Route<dynamic> route) => false,
    );
  }

  _showMenuDialog() {
    return Platform.isIOS ? _iosBottomSheet() : _androidDialog();
  }

  _saveAndShareFile() async {
    final RenderBox box = context.findRenderObject();

    var response = await get(widget.post.imageUrl);
    final documentDirectory = (await getExternalStorageDirectory()).path;
    File imgFile = new File('$documentDirectory/${widget.post.id}.png');
    imgFile.writeAsBytesSync(response.bodyBytes);

    Share.shareFiles([imgFile.path],
        subject: 'Have a look at ${widget.author.name} post!',
        text: '${widget.author.name} : ${widget.post.caption}',
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  _iosBottomSheet() {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text('Add Photo'),
            actions: <Widget>[
              CupertinoActionSheetAction(
                onPressed: () {},
                child: Text('Take Photo'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {},
                child: Text('Choose From Gallery'),
              )
            ],
            cancelButton: CupertinoActionSheetAction(
              child: Text(
                'Cancel',
                style: kFontColorRedTextStyle,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          );
        });
  }

  _androidDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            // title: Text('Add Photo'),
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Share Post'),
                onPressed: () {
                  _saveAndShareFile();
                  Navigator.pop(context);
                },
              ),
              _post.authorId == widget.currentUserId &&
                      widget.postStatus != PostStatus.archivedPost
                  ? SimpleDialogOption(
                      child: Text('Archive Post'),
                      onPressed: () {
                        DatabaseService.archivePost(
                            widget.post, widget.postStatus);
                        _goToHomeScreen(context);
                      },
                    )
                  : SizedBox.shrink(),
              _post.authorId == widget.currentUserId &&
                      widget.postStatus != PostStatus.deletedPost
                  ? SimpleDialogOption(
                      child: Text('Delete Post'),
                      onPressed: () {
                        DatabaseService.deletePost(_post, widget.postStatus);
                        _goToHomeScreen(context);
                      },
                    )
                  : SizedBox.shrink(),
              _post.authorId == widget.currentUserId &&
                      widget.postStatus != PostStatus.feedPost
                  ? SimpleDialogOption(
                      child: Text('Show on profile'),
                      onPressed: () {
                        DatabaseService.recreatePost(_post, widget.postStatus);
                        _goToHomeScreen(context);
                      },
                    )
                  : SizedBox.shrink(),

              _post.authorId == widget.currentUserId
                  ? SimpleDialogOption(
                      child: Text('Edit Post'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreatePostScreen(
                              post: _post,
                              postStatus: widget.postStatus,
                            ),
                          ),
                        );
                      },
                    )
                  : SizedBox.shrink(),
              _post.authorId == widget.currentUserId &&
                      widget.postStatus == PostStatus.feedPost
                  ? SimpleDialogOption(
                      child: Text(_post.commentsAllowed
                          ? 'Turn off commenting'
                          : 'Allow comments'),
                      onPressed: () {
                        DatabaseService.allowDisAllowPostComments(
                            _post, !_post.commentsAllowed);
                        Navigator.pop(context);
                        setState(() {
                          _post = new Post(
                              authorId: widget.post.authorId,
                              caption: widget.post.caption,
                              commentsAllowed: !_post.commentsAllowed,
                              id: _post.id,
                              imageUrl: _post.imageUrl,
                              likeCount: _post.likeCount,
                              location: _post.location,
                              timestamp: _post.timestamp);
                        });
                      },
                    )
                  : SizedBox.shrink(),
              // SimpleDialogOption(
              //   child: Text('Download Image'),
              //   onPressed: () async {
              //     await ImageDownloader.downloadImage(
              //       _post.imageUrl,
              //       outputMimeType: "image/jpg",
              //     );
              //     Navigator.pop(context);
              //   },
              // ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          child: ListTile(
            leading: GestureDetector(
              onTap: () => _goToUserProfile(context, _post),
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: widget.author.profileImageUrl.isEmpty
                    ? AssetImage(placeHolderImageRef)
                    : CachedNetworkImageProvider(
                        widget.author.profileImageUrl,
                      ),
              ),
            ),
            title: GestureDetector(
              onTap: () => _goToUserProfile(context, _post),
              child: Row(
                children: [
                  Text(
                    widget.author.name,
                    style: kFontSize18FontWeight600TextStyle,
                  ),
                  UserBadges(user: widget.author, size: 15)
                ],
              ),
            ),
            subtitle: _post.location.isNotEmpty ? Text(_post.location) : null,
            trailing: IconButton(
                icon: Icon(Icons.more_vert), onPressed: _showMenuDialog),
          ),
        ),
        GestureDetector(
          onDoubleTap:
              widget.postStatus == PostStatus.feedPost ? _likePost : () {},
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                  height: MediaQuery.of(context).size.width,
                  child: ZoomOverlay(
                      twoTouchOnly: true,
                      child: CachedNetworkImage(
                          fadeInDuration: Duration(milliseconds: 500),
                          imageUrl: _post.imageUrl))),
              _heartAnim ? HeartAnime(100.0) : SizedBox.shrink(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: [
                      IconButton(
                        icon: _isLiked
                            ? Icon(
                                Ionicons.heart_sharp,
                                size: 36,
                                color: Colors.red,
                              )
                            : Icon(Ionicons.heart_outline, size: 36),
                        iconSize: 30.0,
                        onPressed: widget.postStatus == PostStatus.feedPost
                            ? _likePost
                            : () {},
                      ),
                      IconButton(
                        icon: Icon(Ionicons.chatbubble_ellipses_outline),
                        iconSize: 28.0,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CommentsScreen(
                              postStatus: widget.postStatus,
                              post: _post,
                              likeCount: _likeCount,
                              author: widget.author,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // TODO: Favorire Post
                  // IconButton(
                  //   icon: _isLiked
                  //       ? FaIcon(
                  //           FontAwesomeIcons.solidHeart,
                  //           color: Colors.red,
                  //         )
                  //       : FaIcon(FontAwesomeIcons.heart),
                  //   iconSize: 30.0,
                  //   onPressed: _likePost,
                  // ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  '${NumberFormat.compact().format(_likeCount)} Likes',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 4.0),
              Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(
                      left: 12.0,
                      right: 6.0,
                    ),
                    child: GestureDetector(
                      onTap: () => _goToUserProfile(context, _post),
                      child: Row(
                        children: [
                          Text(
                            widget.author.name,
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          UserBadges(
                              user: widget.author,
                              size: 15,
                              secondSizedBox: false)
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                      child: Text(
                    _post.caption,
                    style: TextStyle(fontSize: 16.0),
                    overflow: TextOverflow.ellipsis,
                  )),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Text(
                  timeago.format(_post.timestamp.toDate()),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                  ),
                ),
              ),
              SizedBox(height: 12.0),
            ],
          ),
        )
      ],
    );
  }
}
