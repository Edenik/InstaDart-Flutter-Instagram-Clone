import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:instagram/widgets/custom_drawer.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:instagram/models/models.dart';
import 'package:instagram/screens/screens.dart';
import 'package:instagram/services/services.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:instagram/utilities/themes.dart';
import 'package:instagram/widgets/post_view.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  final String currentUserId;
  final Function onProfileEdited;

  ProfileScreen({this.userId, this.currentUserId, this.onProfileEdited});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isFollowing = false;
  int _followersCount = 0;
  int _followingCount = 0;
  List<Post> _posts = [];
  int _displayPosts = 0; // 0 - grid, 1 - column
  User _profileUser;

  @override
  initState() {
    super.initState();
    _setupIsFollowing();
    _setupFollowers();
    _setupFollowing();
    _setupPosts();
    _setupProfileUser();
  }

  _setupIsFollowing() async {
    bool isFollowingUser = await DatabaseService.isFollowingUser(
      currentUserId: widget.currentUserId,
      userId: widget.userId,
    );
    setState(() {
      _isFollowing = isFollowingUser;
    });
  }

  _setupFollowers() async {
    int userFollowersCount = await DatabaseService.numFollowers(widget.userId);
    setState(() {
      _followersCount = userFollowersCount;
    });
  }

  _setupFollowing() async {
    int userFollowingCount = await DatabaseService.numFollowing(widget.userId);
    setState(() {
      _followingCount = userFollowingCount;
    });
  }

  _setupPosts() async {
    List<Post> posts = await DatabaseService.getUserPosts(widget.userId);
    setState(() {
      _posts = posts;
    });
  }

  _setupProfileUser() async {
    User profileUser = await DatabaseService.getUserWithId(widget.userId);
    setState(() {
      _profileUser = profileUser;
    });
  }

  _followOrUnfollow() {
    if (_isFollowing) {
      _unfollowUser();
    } else {
      _followUser();
    }
  }

  _unfollowUser() {
    DatabaseService.unfollowUser(
        currentUserId: widget.currentUserId, userId: widget.userId);
    setState(() {
      _isFollowing = false;
      _followersCount--;
    });
  }

  _followUser() {
    DatabaseService.followUser(
        currentUserId: widget.currentUserId, userId: widget.userId);
    setState(() {
      _isFollowing = true;
      _followersCount++;
    });
  }

  _displayButton(User user) {
    return user.id == widget.currentUserId
        ? Container(
            width: 200.0,
            child: FlatButton(
                onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(
                            user: user,
                            updateUser: (User updateUser) {
                              User updatedUser = User(
                                id: updateUser.id,
                                name: updateUser.name,
                                email: user.email,
                                profileImageUrl: updateUser.profileImageUrl,
                                bio: updateUser.bio,
                              );

                              setState(() {
                                Provider.of<UserData>(context, listen: false)
                                        .profileImageUrl =
                                    updatedUser.profileImageUrl;
                                _profileUser = updatedUser;
                              });
                              widget.onProfileEdited();
                            }),
                      ),
                    ),
                color: Colors.blue,
                textColor: Colors.white,
                child: Text(
                  'Edit Profile',
                  style: kFontSize18TextStyle,
                )),
          )
        : Container(
            width: 200.0,
            child: FlatButton(
              onPressed: _followOrUnfollow,
              color: _isFollowing ? Colors.grey[200] : Colors.blue,
              textColor: _isFollowing ? Colors.black : Colors.white,
              child: Text(
                _isFollowing ? 'Unfollow' : 'Follow',
                style: kFontSize18TextStyle,
              ),
            ),
          );
  }

  _buildProfileInfo(User user) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 0),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 50.0,
                backgroundColor: Colors.grey,
                backgroundImage: user.profileImageUrl.isEmpty
                    ? AssetImage(placeHolderImageRef)
                    : CachedNetworkImageProvider(user.profileImageUrl),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text(
                              NumberFormat.compact().format(_posts.length),
                              style: kFontSize18FontWeight600TextStyle,
                            ),
                            Text(
                              'posts',
                              style: kHintColorStyle(context),
                            )
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FollowersScreen(
                                currenUserId: widget.currentUserId,
                                user: user,
                                followersCount: _followersCount,
                                followingCount: _followingCount,
                                selectedTab: 0,
                                updateFollowersCount: (count) {
                                  setState(() => _followersCount = count);
                                },
                                updateFollowingCount: (count) {
                                  setState(() => _followingCount = count);
                                },
                              ),
                            ),
                          ),
                          child: Column(
                            children: <Widget>[
                              Text(
                                NumberFormat.compact().format(_followersCount),
                                style: kFontSize18FontWeight600TextStyle,
                              ),
                              Text(
                                'followers',
                                style: kHintColorStyle(context),
                              )
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FollowersScreen(
                                currenUserId: widget.currentUserId,
                                user: user,
                                followersCount: _followersCount,
                                followingCount: _followingCount,
                                selectedTab: 1,
                                updateFollowersCount: (count) {
                                  setState(() => _followersCount = count);
                                },
                                updateFollowingCount: (count) {
                                  setState(() => _followingCount = count);
                                },
                              ),
                            ),
                          ),
                          child: Column(
                            children: <Widget>[
                              Text(
                                NumberFormat.compact().format(_followingCount),
                                style: kFontSize18FontWeight600TextStyle,
                              ),
                              Text(
                                'following',
                                style: kHintColorStyle(context),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    _displayButton(user),
                  ],
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                user.name,
                style: kFontSize18FontWeight600TextStyle.copyWith(
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5.0),
              Container(
                height: 80.0,
                child: Text(
                  user.bio,
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              Divider(
                color: Theme.of(context).dividerColor,
                height: 1,
              ),
            ],
          ),
        )
      ],
    );
  }

  _buildToggleButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.grid_on),
          iconSize: 30.0,
          color: _displayPosts == 0
              ? Theme.of(context).accentColor
              : Theme.of(context).hintColor,
          onPressed: () => setState(() {
            _displayPosts = 0;
          }),
        ),
        IconButton(
          icon: Icon(Icons.list),
          iconSize: 30.0,
          color: _displayPosts == 1
              ? Theme.of(context).accentColor
              : Theme.of(context).hintColor,
          onPressed: () => setState(() {
            _displayPosts = 1;
          }),
        )
      ],
    );
  }

  _buildTilePost(Post post) {
    return GridTile(
        child: GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<bool>(
          builder: (BuildContext context) {
            return Center(
              child: Scaffold(
                  appBar: AppBar(
                    title: Text(
                      'Photo',
                    ),
                  ),
                  body: ListView(
                    children: <Widget>[
                      Container(
                        child: PostView(
                          currentUserId: widget.currentUserId,
                          post: post,
                          author: _profileUser,
                        ),
                      ),
                    ],
                  )),
            );
          },
        ),
      ),
      child: Image(
        image: CachedNetworkImageProvider(post.imageUrl),
        fit: BoxFit.cover,
      ),
    ));
  }

  _buildDisplayPosts() {
    if (_displayPosts == 0) {
      // Grid
      List<GridTile> tiles = [];
      _posts.forEach((post) => tiles.add(_buildTilePost(post)));
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 2.0,
        crossAxisSpacing: 2.0,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: tiles,
      );
    } else {
      // Column
      List<PostView> postViews = [];
      _posts.forEach((post) {
        postViews.add(PostView(
          currentUserId: widget.currentUserId,
          post: post,
          author: _profileUser,
        ));
      });
      return Column(
        children: postViews,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.color,

        automaticallyImplyLeading:
            widget.userId == widget.currentUserId ? false : true,
        title:
            _profileUser != null ? Text(_profileUser.name) : SizedBox.shrink(),
        // actions: <Widget>[
        //   IconButton(
        //     icon: Icon(Icons.exit_to_app),
        //     onPressed: AuthService.logout,
        //   )
        // ],
      ),
      endDrawer: _profileUser != null && widget.userId == widget.currentUserId
          ? CustomDrawer(
              name: _profileUser.name,
            )
          : null,
      body: FutureBuilder(
        future: usersRef.document(widget.userId).get(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          User user = User.fromDoc(snapshot.data);
          return ListView(
            physics: AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              _buildProfileInfo(user),
              _buildToggleButtons(),
              Divider(color: Theme.of(context).dividerColor),
              _buildDisplayPosts(),
            ],
          );
        },
      ),
    );
  }
}
