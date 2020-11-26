import 'package:flutter/material.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/screens/feed_screen/widgets/blank_story_circle.dart';
import 'package:instagram/screens/feed_screen/widgets/story_circle.dart';
import 'package:instagram/services/services.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';

class StoriesWidget extends StatefulWidget {
  final List<User> users;
  final Function goToCameraScreen;
  const StoriesWidget(this.users, this.goToCameraScreen);

  @override
  _StoriesWidgetState createState() => _StoriesWidgetState();
}

class _StoriesWidgetState extends State<StoriesWidget> {
  bool _isLoading = false;
  List<User> _followingUsers = [];
  List<Story> _stories = [];
  User _currentUser;
  bool _isCurrentUserHasStories = false;

  @override
  void initState() {
    super.initState();
    _getStories();
  }

  Future<void> _getStories() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _currentUser = Provider.of<UserData>(context, listen: false).currentUser;
    });

    if (!mounted) return;

    List<User> followingUsersWithStories = [];

    List<Story> stories = [];

    List<Story> currentUserStories =
        await StoriesService.getStoriesByUserId(_currentUser.id, true);

    if (currentUserStories != null) {
      followingUsersWithStories.add(_currentUser);
      stories = currentUserStories;
      if (!mounted) return;
      setState(() => _isCurrentUserHasStories = true);
    }

    for (User user in widget.users) {
      List<Story> userStories =
          await StoriesService.getStoriesByUserId(user.id, true);
      if (!mounted) return;

      if (userStories != null && userStories.isNotEmpty) {
        followingUsersWithStories.add(user);

        for (Story story in userStories) {
          stories.add(story);
        }
      }
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _followingUsers = followingUsersWithStories;
      _stories = stories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return !_isLoading
        ? Container(
            height: 88.0,
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.only(left: 5.0),
              scrollDirection: Axis.horizontal,
              itemCount: _isCurrentUserHasStories
                  ? _followingUsers.length
                  : (_followingUsers.length + 1),
              itemBuilder: (BuildContext context, int index) {
                if (index == 0 && !_isCurrentUserHasStories) {
                  return _buildBlankStoryCircle();
                } else if (index > 0 && !_isCurrentUserHasStories) {
                  return _buildStoryCircle(index - 1);
                }
                return _buildStoryCircle(index);
              },
            ))
        : Container(
            height: 88,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }

  BlankStoryCircle _buildBlankStoryCircle() {
    return BlankStoryCircle(
      goToCameraScreen: widget.goToCameraScreen,
      user: _currentUser,
    );
  }

  StoryCircle _buildStoryCircle(int index) {
    User user = _followingUsers[index];
    List<Story> userStories =
        _stories.where((Story story) => story.authorId == user.id).toList();

    return StoryCircle(
      currentUserId: _currentUser.id,
      user: user,
      userStories: userStories,
      size: 60,
    );
  }
}
