import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/screens/stories_screen/stories_screen.dart';
import 'package:instagram/utilities/constants.dart';

class StoryCircle extends StatefulWidget {
  final List<Story> userStories;
  final String currentUserId;
  final User user;
  final Function goToCameraScreen;

  StoryCircle({
    this.userStories,
    this.user,
    this.currentUserId,
    this.goToCameraScreen,
  });
  @override
  _StoryCircleState createState() => _StoryCircleState();
}

class _StoryCircleState extends State<StoryCircle> {
  int _seenStories = 0;
  bool _isCurrentUserHasStories = true;
  @override
  void initState() {
    super.initState();

    if (widget.userStories[0].id?.isEmpty == null) {
      // Checks if the story circle came with real stories..
      // If not, its the current user circle avatar without stories.
      setState(() => _isCurrentUserHasStories = false);
    }

    _checkForSeenStories();
  }

  void _checkForSeenStories() {
    int seenStories = 0;

    for (Story story in widget.userStories) {
      if (story.views.containsKey(widget.currentUserId)) {
        seenStories++;
      }
    }

    if (!mounted) return;
    setState(() {
      _seenStories = seenStories;
    });
  }

  void _updateSeenStories(index) {
    setState(() => _seenStories = index + 1);
  }

  @override
  Widget build(BuildContext context) {
    Color circleColor;

    if (widget.currentUserId == widget.userStories[0].authorId) {
      if (!_isCurrentUserHasStories ||
          _seenStories == widget.userStories.length) {
        circleColor = Colors.grey;
      } else {
        circleColor = Colors.blue;
      }
    } else {
      if (_seenStories == widget.userStories.length) {
        circleColor = Colors.grey;
      } else {
        circleColor = Colors.blue;
      }
    }
    return Container(
      width: 70,
      margin: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                margin: EdgeInsets.all(5.0),
                height: 60.0,
                width: 60.0,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 3.0, color: circleColor),
                ),
                child: GestureDetector(
                  onTap: () => !_isCurrentUserHasStories &&
                          widget.user.id == widget.currentUserId
                      ? widget.goToCameraScreen()
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StoryScreen(
                              stories: widget.userStories,
                              user: widget.user,
                              seenStories: _seenStories,
                            ),
                          ),
                        ).then((value) {
                          _updateSeenStories(value);
                        }),
                  child: ClipOval(
                    child: Image(
                      image: widget.user.profileImageUrl.isEmpty
                          ? AssetImage(placeHolderImageRef)
                          : CachedNetworkImageProvider(
                              widget.user.profileImageUrl),
                      height: 60.0,
                      width: 60.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              if (_isCurrentUserHasStories == false &&
                  widget.currentUserId == widget.userStories[0].authorId)
                Positioned(
                  bottom: 5,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.plusCircle,
                        color: Colors.blue,
                        size: 18,
                      ),
                    ),
                  ),
                )
            ],
          ),
          Expanded(
            child: Text(
              widget.user.name,
              textAlign: TextAlign.center,
              overflow: TextOverflow.clip,
            ),
          )
        ],
      ),
    );
  }
}
