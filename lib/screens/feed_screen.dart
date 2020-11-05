import 'package:flutter/material.dart';

import 'package:instagram/models/models.dart';
import 'package:instagram/services/services.dart';
import 'package:instagram/utilities/themes.dart';
import 'package:instagram/widgets/post_view.dart';

class FeedScreen extends StatefulWidget {
  static final String id = 'feed_screen';
  final String currentUserId;

  FeedScreen({this.currentUserId});
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Post> _posts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupFeed();
  }

  _setupFeed() async {
    setState(() => _isLoading = true);
    List<Post> posts = await DatabaseService.getFeedPosts(widget.currentUserId);
    setState(() {
      _posts = posts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.color,
        centerTitle: true,
        title: Text(
          'Instagram',
          style: kBillabongFamilyTextStyle,
        ),
      ),
      body: !_isLoading
          ? RefreshIndicator(
              // If posts finished loading
              onRefresh: () => _setupFeed(),
              child: ListView.builder(
                itemCount: _posts.length > 0 ? _posts.length : 1,
                itemBuilder: (BuildContext context, int index) {
                  if (_posts.length == 0) {
                    //If there is no posts
                    return Container(
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                        child: Text('No posts found, Start following users'),
                      ),
                    );
                  }

                  Post post = _posts[index];

                  return FutureBuilder(
                    future: DatabaseService.getUserWithId(post.authorId),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (!snapshot.hasData) {
                        return SizedBox.shrink();
                      }

                      User author = snapshot.data;

                      return PostView(
                        currentUserId: widget.currentUserId,
                        author: author,
                        post: post,
                      );
                    },
                  );
                },
              ),
            )
          : Center(
              // If posts is loading
              child: CircularProgressIndicator(),
            ),
    );
  }
}
