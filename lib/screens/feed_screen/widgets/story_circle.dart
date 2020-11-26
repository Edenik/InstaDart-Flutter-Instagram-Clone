import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/screens/stories_screen/stories_screen.dart';
import 'package:instagram/utilities/constants.dart';

class StoryCircle extends StatefulWidget {
  final List<Story> userStories;
  final String currentUserId;
  final User user;
  final double size;
  final bool showUserName;

  StoryCircle({
    @required this.userStories,
    @required this.user,
    @required this.currentUserId,
    this.size = 60,
    this.showUserName = true,
  });
  @override
  _StoryCircleState createState() => _StoryCircleState();
}

class _StoryCircleState extends State<StoryCircle> {
  int _seenStories = 0;
  @override
  void initState() {
    super.initState();

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

    if (_seenStories == widget.userStories.length) {
      circleColor = Colors.grey;
    } else {
      circleColor = Colors.blue;
    }
    return Container(
      width: widget.size + 10,
      margin: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.all(5.0),
            height: widget.size,
            width: widget.size,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 3.0, color: circleColor),
            ),
            child: GestureDetector(
              onTap: () => Navigator.push(
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
                      : CachedNetworkImageProvider(widget.user.profileImageUrl),
                  height: widget.size,
                  width: widget.size,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          if (widget.showUserName)
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
