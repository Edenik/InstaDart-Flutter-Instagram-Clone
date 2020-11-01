import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/services/services.dart';
import 'package:instagram/widgets/default_appBar_widget.dart';

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

  _goToUserProfile(Post post) {
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

  _buildPost(Post post, User author) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () => _goToUserProfile(post),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 25.0,
                  backgroundColor: Colors.grey,
                  backgroundImage: author.profileImageUrl.isEmpty
                      ? AssetImage('assets/images/user_placeholder.jpg')
                      : CachedNetworkImageProvider(author.profileImageUrl),
                ),
                SizedBox(
                  width: 8.0,
                ),
                Text(
                  author.name,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
                )
              ],
            ),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: CachedNetworkImageProvider(post.imageUrl),
              fit: BoxFit.cover,
            ),
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
                    icon: Icon(Icons.favorite_border),
                    iconSize: 30.0,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.comment),
                    iconSize: 30.0,
                    onPressed: () {},
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  '0 Likes',
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
                      onTap: () => _goToUserProfile(post),
                      child: Text(
                        author.name,
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                      child: Text(
                    post.caption,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(),
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

                      return _buildPost(post, author);
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
