import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/screens/stories_screen/stories_screen.dart';
import 'package:instagram/utilities/constants.dart';

class StoryCircle extends StatefulWidget {
  final List<Story> userStories;
  final String currentUserId;
  final User user;
  StoryCircle({this.userStories, this.user, this.currentUserId});
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

  _checkForSeenStories() {
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

  _updateSeenStories(index) {
    if (widget.userStories.length == index + 1) {
      setState(() => _seenStories = index + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.all(5.0),
            height: 60.0,
            width: 60.0,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 3.0,
                color: widget.currentUserId == widget.userStories[0].authorId &&
                        _seenStories != widget.userStories.length
                    ? Colors.blue
                    : _seenStories != widget.userStories.length
                        ? Colors.blue
                        : Colors.grey,
              ),
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
                  height: 60.0,
                  width: 60.0,
                  fit: BoxFit.cover,
                ),
              ),
            ),
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
