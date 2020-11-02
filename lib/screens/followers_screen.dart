import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/user_data.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/services/database_service.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:provider/provider.dart';

class FollowersScreen extends StatefulWidget {
  final User user;
  final List<String> followers;
  final List<String> following;
  final int selectedTab; // 0 - Followers / 1 - Following

  const FollowersScreen(
      {this.user, this.followers, this.following, this.selectedTab});

  @override
  _FollowersScreenState createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  List<User> _userFollowers = [];
  List<User> _userFollowing = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupFollowers();
    _setupFollowing();
  }

  // Future<

  _setupFollowers() async {
    setState(() {
      _isLoading = true;
    });
    List<User> userFollowers = [];
    for (String userId in widget.followers) {
      User user = await DatabaseService.getUserWithId(userId);
      userFollowers.add(user);
    }

    setState(() {
      _userFollowers = userFollowers;
      _isLoading = false;
    });
  }

  _setupFollowing() async {
    setState(() {
      _isLoading = true;
    });
    List<User> userFollowing = [];
    for (String userId in widget.following) {
      User user = await DatabaseService.getUserWithId(userId);
      userFollowing.add(user);
    }

    setState(() {
      _userFollowing = userFollowing;
      _isLoading = false;
    });
  }

  _buildFollower(User user) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25.0,
        backgroundColor: Colors.grey,
        backgroundImage: user.profileImageUrl.isEmpty
            ? AssetImage(placeHolderImageRef)
            : CachedNetworkImageProvider(user.profileImageUrl),
      ),
      title: Text(user.name),
      subtitle: Text(user.email),
      trailing: FlatButton(onPressed: () {}, child: Text('Remove')),
      onTap: () {
        String currentUserId =
            Provider.of<UserData>(context, listen: false).currentUserId;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileScreen(
              currentUserId: currentUserId,
              userId: user.id,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.selectedTab,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              widget.user.name,
              style: TextStyle(color: Colors.black),
            ),
            bottom: TabBar(
              labelColor: Colors.black,
              tabs: [
                Tab(
                  text: '${widget.followers.length} Followers',
                ),
                Tab(
                  text: '${widget.following.length} Following',
                ),
              ],
            )),
        body: !_isLoading
            ? TabBarView(
                children: [
                  RefreshIndicator(
                    onRefresh: () => _setupFollowers(),
                    child: ListView.builder(
                      itemCount: _userFollowers.length,
                      itemBuilder: (BuildContext context, int index) {
                        User follower = _userFollowers[index];
                        return _buildFollower(follower);
                      },
                    ),
                  ),
                  RefreshIndicator(
                    onRefresh: () => _setupFollowing(),
                    child: ListView.builder(
                      itemCount: _userFollowing.length,
                      itemBuilder: (BuildContext context, int index) {
                        User follower = _userFollowing[index];
                        return _buildFollower(follower);
                      },
                    ),
                  ),
                ],
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
