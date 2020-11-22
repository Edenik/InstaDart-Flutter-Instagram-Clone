import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/screens/stories_screen/stories_screen.dart';
import 'package:instagram/services/services.dart';
import 'package:instagram/utilities/constants.dart';
import '../../../models/user_model.dart';

class StoriesWidget extends StatefulWidget {
  final List<User> users;
  final String currentUserId;
  const StoriesWidget(this.users, this.currentUserId);

  @override
  _StoriesWidgetState createState() => _StoriesWidgetState();
}

class _StoriesWidgetState extends State<StoriesWidget> {
  bool _isLoading = false;
  List<User> _followingUsers = [];
  List<Story> _stories = [];
  bool _isCurrentUserHasStories = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getStories();
  }

  @override
  void dispose() {
    // TODO: implement initState
    super.dispose();
  }

  Future<void> _getStories() async {
    setState(() => _isLoading = true);
    List<User> followingUsersWithStories = [];
    List<Story> stories = [];
    for (User user in widget.users) {
      List<Story> userStories =
          await StoriesService.getStoriesByUserId(user.id, true);
      if (userStories != null && userStories.isNotEmpty) {
        followingUsersWithStories.add(user);

        if (user.id == widget.currentUserId) {
          setState(() => _isCurrentUserHasStories = true);
        }

        for (Story story in userStories) {
          stories.add(story);
        }
      } else {
        if (widget.currentUserId != user.id) {
          print('no stories');
        }
      }
    }

    setState(() {
      _isLoading = false;
      _followingUsers = followingUsersWithStories;
      _stories = stories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
          child: Text(
            'Stories',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
        ),
        !_isLoading
            ? GestureDetector(
                onTap: () {},
                child: Container(
                    height: 120.0,
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.only(left: 10.0),
                      scrollDirection: Axis.horizontal,
                      itemCount: _followingUsers.length,
                      itemBuilder: (BuildContext context, int index) {
                        User user = _followingUsers[index];
                        List<Story> userStories = _stories
                            .where((Story story) => story.authorId == user.id)
                            .toList();

                        return Column(
                          children: [
                            Container(
                              margin: EdgeInsets.all(10.0),
                              height: 60.0,
                              width: 60.0,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 3.0,
                                  color: widget.currentUserId ==
                                              userStories[0].authorId &&
                                          _isCurrentUserHasStories
                                      ? Colors.blue
                                      : widget.currentUserId !=
                                              userStories[0].authorId
                                          ? Colors.blue
                                          : Colors.grey,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 2),
                                    blurRadius: 6.0,
                                  )
                                ],
                              ),
                              child: GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => StoryScreen(
                                              stories: userStories,
                                              user: user,
                                            ))),
                                child: ClipOval(
                                  child: Image(
                                    image: user.profileImageUrl.isEmpty
                                        ? AssetImage(placeHolderImageRef)
                                        : CachedNetworkImageProvider(
                                            user.profileImageUrl),
                                    height: 60.0,
                                    width: 60.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            // Container(
                            //   width: 50,
                            //   height: 20,
                            //   child: Expanded(
                            //     child: Text(
                            //       user.name,
                            //       textAlign: TextAlign.center,
                            //       overflow: TextOverflow.fade,
                            //     ),
                            //   ),
                            // )
                          ],
                        );
                      },
                    )),
              )
            : Container(
                height: 115,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
      ],
    );
  }
}
