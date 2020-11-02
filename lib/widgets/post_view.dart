import 'dart:async';
import 'dart:io';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/screens/comments_screen.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/services/database_service.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:image_downloader/image_downloader.dart';

class PostView extends StatefulWidget {
  final String currentUserId;
  final Post post;
  final User author;

  PostView({this.currentUserId, this.post, this.author});

  @override
  _PostViewState createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  int _likeCount = 0;
  bool _isLiked = false;
  bool _heartAnim = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likeCount;
    _initPostLiked();
  }

  @override
  didUpdateWidget(PostView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.likeCount != widget.post.likeCount) {
      _likeCount = widget.post.likeCount;
    }
  }

  _goToUserProfile(BuildContext context, Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          currentUserId: widget.currentUserId,
          userId: post.authorId,
        ),
      ),
    );
  }

  _initPostLiked() async {
    bool isLiked = await DatabaseService.didLikePost(
        currentUserId: widget.currentUserId, post: widget.post);
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
          currentUserId: widget.currentUserId, post: widget.post);
      setState(() {
        _isLiked = false;
        _likeCount--;
      });
    } else {
      // Like Post
      DatabaseService.likePost(
          currentUserId: widget.currentUserId, post: widget.post);
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

  _showMenuDialog() {
    return Platform.isIOS ? _iosBottomSheet() : _androidDialog();
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
                style: TextStyle(color: Colors.red),
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
              widget.post.authorId == widget.currentUserId
                  ? SimpleDialogOption(
                      child: Text('Delete Post'),
                      onPressed: () {
                        DatabaseService.deletePost(widget.post);
                        Navigator.pop(context);
                      },
                    )
                  : SizedBox.shrink(),
              SimpleDialogOption(
                child: Text('Download Image'),
                onPressed: () async {
                  await ImageDownloader.downloadImage(
                    widget.post.imageUrl,
                  );
                  Navigator.pop(context);
                },
              ),
              // SimpleDialogOption(
              //   child: Text(
              //     'Download Image',
              //     style: TextStyle(color: Colors.red),
              //   ),
              //   onPressed: () => Navigator.pop(context),
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
        GestureDetector(
          onTap: () => _goToUserProfile(context, widget.post),
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey,
                  backgroundImage: widget.author.profileImageUrl.isEmpty
                      ? AssetImage(placeHolderImageRef)
                      : CachedNetworkImageProvider(
                          widget.author.profileImageUrl),
                ),
                title: Text(
                  widget.author.name,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
                ),
                trailing: IconButton(
                    icon: Icon(Icons.more_vert), onPressed: _showMenuDialog),
              )),
          //    Row(
          //   children: <Widget>[

          //     SizedBox(
          //       width: 8.0,
          //     ),
          //     Text(
          //       widget.author.name,
          //       style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
          //     ),
          //     IconButton(icon: Icon(Icons.menu), onPressed: null)
          //   ],
          // ),
        ),
        GestureDetector(
          onDoubleTap: _likePost,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(widget.post.imageUrl),
                    fit: BoxFit.cover,
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
                          size: 100.0,
                          color: Colors.red[400],
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    icon: _isLiked
                        ? Icon(
                            Icons.favorite,
                            color: Colors.red,
                          )
                        : Icon(Icons.favorite_border),
                    iconSize: 30.0,
                    onPressed: _likePost,
                  ),
                  IconButton(
                    icon: Icon(Icons.comment),
                    iconSize: 30.0,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommentsScreen(
                          post: widget.post,
                          likeCount: _likeCount,
                          author: widget.author,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  '${_likeCount.toString()} Likes',
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
                      onTap: () => _goToUserProfile(context, widget.post),
                      child: Text(
                        widget.author.name,
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                      child: Text(
                    widget.post.caption,
                    style: TextStyle(fontSize: 16.0),
                    overflow: TextOverflow.ellipsis,
                  ))
                ],
              ),
              SizedBox(height: 12.0)
            ],
          ),
        )
      ],
    );
  }
}
