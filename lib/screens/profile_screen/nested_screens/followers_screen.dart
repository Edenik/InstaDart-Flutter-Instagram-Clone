import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:instagram/models/models.dart';
import 'package:instagram/services/services.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:instagram/utilities/custom_navigation.dart';
import 'package:instagram/utilities/themes.dart';
import 'package:instagram/common_widgets/user_badges.dart';
import 'package:intl/intl.dart';

class FollowersScreen extends StatefulWidget {
  final User user;
  final int followersCount;
  final int followingCount;
  final int selectedTab; // 0 - Followers / 1 - Following
  final String currenUserId;
  final Function updateFollowersCount;
  final Function updateFollowingCount;

  const FollowersScreen(
      {this.user,
      this.followersCount,
      this.followingCount,
      this.selectedTab,
      this.currenUserId,
      this.updateFollowersCount,
      this.updateFollowingCount});

  @override
  _FollowersScreenState createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  List<User> _userFollowers = [];
  List<User> _userFollowing = [];
  bool _isLoading = false;
  List<bool> _userFollowersState = [];
  List<bool> _userFollowingState = [];
  int _followingCount;
  int _followersCount;

  @override
  void initState() {
    super.initState();
    setState(() {
      _followersCount = widget.followersCount;
      _followingCount = widget.followingCount;
    });
    _setupAll();
  }

  _setupAll() async {
    setState(() {
      _isLoading = true;
    });
    await _setupFollowers();
    await _setupFollowing();
    setState(() {
      _isLoading = false;
    });
  }

  Future _setupFollowers() async {
    List<String> userFollowersIds =
        await DatabaseService.getUserFollowersIds(widget.user.id);

    List<User> userFollowers = [];
    List<bool> userFollowersState = [];
    for (String userId in userFollowersIds) {
      User user = await DatabaseService.getUserWithId(userId);
      userFollowersState.add(true);
      userFollowers.add(user);
    }

    setState(() {
      _userFollowersState = userFollowersState;
      _userFollowers = userFollowers;
      _followersCount = userFollowers.length;
      if (_followersCount != widget.followersCount) {
        widget.updateFollowersCount(_followersCount);
      }
    });
  }

  Future _setupFollowing() async {
    List<String> userFollowingIds =
        await DatabaseService.getUserFollowingIds(widget.user.id);

    List<User> userFollowing = [];
    List<bool> userFollowingState = [];
    for (String userId in userFollowingIds) {
      User user = await DatabaseService.getUserWithId(userId);
      userFollowingState.add(true);
      userFollowing.add(user);
    }
    setState(() {
      _userFollowingState = userFollowingState;
      _userFollowing = userFollowing;
      _followingCount = userFollowing.length;
      if (_followingCount != widget.followingCount) {
        widget.updateFollowingCount(_followingCount);
      }
    });
  }

  _removeFollowerDialog(User user, int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 50.0,
                  backgroundColor: Colors.grey,
                  backgroundImage: user.profileImageUrl.isEmpty
                      ? AssetImage(placeHolderImageRef)
                      : CachedNetworkImageProvider(user.profileImageUrl),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'Remove Follower?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: Text(
                    'Instagram won\'t tell ${user.name} they were removed from your followers.',
                    textAlign: TextAlign.center,
                    style: kHintColorStyle(context),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
            children: <Widget>[
              Divider(),
              SimpleDialogOption(
                child: Center(
                    child: Text(
                  'Remove',
                  style: kFontSize18TextStyle.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                )),
                onPressed: () {
                  DatabaseService.unfollowUser(
                      userId: widget.currenUserId, currentUserId: user.id);
                  setState(() {
                    _userFollowersState.removeAt(index);
                    _userFollowers.removeAt(index);
                    _followersCount--;
                    widget.updateFollowersCount(_followersCount);
                  });
                  Navigator.pop(context);
                },
              ),
              Divider(),
              SimpleDialogOption(
                child: Center(
                  child: Text(
                    'Cancel',
                    style: kFontSize18TextStyle,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  _buildFollowerButton(User user, int index) {
    return FlatButton(
      onPressed: () {
        _removeFollowerDialog(user, index);
      },
      child: Text('Remove'),
    );
  }

  _goToUserProfile(BuildContext context, User user) {
    CustomNavigation.navigateToUserProfile(
        context: context,
        currentUserId: widget.currenUserId,
        userId: user.id,
        isCameFromBottomNavigation: false);
  }

  _buildFollower(User user, int index) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25.0,
        backgroundColor: Colors.grey,
        backgroundImage: user.profileImageUrl.isEmpty
            ? AssetImage(placeHolderImageRef)
            : CachedNetworkImageProvider(user.profileImageUrl),
      ),
      title: Row(
        children: [
          Text(user.name),
          UserBadges(user: user, size: 15),
        ],
      ),
      subtitle: Text(user.email),
      trailing: widget.user.id == widget.currenUserId
          ? _buildFollowerButton(user, index)
          : SizedBox.shrink(),
      onTap: () => _goToUserProfile(context, user),
    );
  }

  _buildFollowingButton(User user, int index) {
    return FlatButton(
      color: _userFollowingState[index] ? Colors.transparent : Colors.blue,
      onPressed: () {
        if (_userFollowingState[index] == true) {
          // Unfollow User
          DatabaseService.unfollowUser(
              currentUserId: widget.currenUserId, userId: user.id);
          setState(() {
            _userFollowingState[index] = false;
            _followingCount--;
          });
          widget.updateFollowingCount(_followingCount);
        } else {
          // Follow User
          DatabaseService.followUser(
              currentUserId: widget.currenUserId,
              userId: user.id,
              receiverToken: user.token);
          setState(() {
            _userFollowingState[index] = true;
            _followingCount++;
          });
          widget.updateFollowingCount(_followingCount);
        }
      },
      child: Text(
        _userFollowingState[index] ? 'Unfollow' : 'Follow',
        style: TextStyle(
            color: _userFollowingState[index]
                ? Theme.of(context).accentColor
                : Theme.of(context).primaryColor),
      ),
    );
  }

  _buildFollowing(User user, int index) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25.0,
        backgroundColor: Colors.grey,
        backgroundImage: user.profileImageUrl.isEmpty
            ? AssetImage(placeHolderImageRef)
            : CachedNetworkImageProvider(user.profileImageUrl),
      ),
      title: Row(
        children: [
          Text(user.name),
          UserBadges(user: user, size: 15),
        ],
      ),
      subtitle: Text(user.email),
      trailing: widget.user.id == widget.currenUserId
          ? _buildFollowingButton(user, index)
          : SizedBox.shrink(),
      onTap: () => _goToUserProfile(context, user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.selectedTab,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.color,
            title: Row(
              children: [
                Text(widget.user.name),
                UserBadges(user: widget.user, size: 15),
              ],
            ),
            bottom: TabBar(
              tabs: [
                Tab(
                  text:
                      '${NumberFormat.compact().format(_followersCount)} Followers',
                ),
                Tab(
                  text:
                      '${NumberFormat.compact().format(_followingCount)} Following',
                ),
              ],
            )),
        body: !_isLoading
            ? TabBarView(
                children: [
                  RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      await _setupFollowers();
                      setState(() {
                        _isLoading = false;
                      });
                    },
                    child: ListView.builder(
                      itemCount: _userFollowers.length,
                      itemBuilder: (BuildContext context, int index) {
                        User follower = _userFollowers[index];
                        return _buildFollower(follower, index);
                      },
                    ),
                  ),
                  RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      await _setupFollowing();
                      setState(() {
                        _isLoading = false;
                      });
                    },
                    child: ListView.builder(
                      itemCount: _userFollowing.length,
                      itemBuilder: (BuildContext context, int index) {
                        User follower = _userFollowing[index];
                        return _buildFollowing(follower, index);
                      },
                    ),
                  ),
                ],
              )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
