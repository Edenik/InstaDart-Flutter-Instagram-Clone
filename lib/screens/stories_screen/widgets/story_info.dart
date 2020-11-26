import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/screens/stories_screen/widgets/swipe_up.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:instagram/common_widgets/user_badges.dart';
import 'package:timeago/timeago.dart' as timeago;

class StoryInfo extends StatelessWidget {
  final User user;
  final Story story;
  final double height;
  final Function onSwipeUp;
  const StoryInfo({
    @required this.user,
    @required this.story,
    @required this.height,
    @required this.onSwipeUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildUserInfo(),
          if (story.caption != '') _buildStoryCaption(),
          if (story.linkUrl != '') SwipeUp(onSwipeUp: onSwipeUp),
        ],
      ),
    );
  }

  _buildStoryCaption() {
    return Center(
      child: Text(
        story.caption,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30, color: Colors.white),
      ),
    );
  }

  _buildUserInfo() {
    return Container(
      height: 70,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Row(
                children: [
                  CircleAvatar(
                    radius: 30.0,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: user.profileImageUrl.isEmpty
                        ? AssetImage(placeHolderImageRef)
                        : CachedNetworkImageProvider(user.profileImageUrl),
                  ),
                  const SizedBox(width: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          UserBadges(user: user, size: 20),
                        ],
                      ),
                      Row(
                        children: [
                          story.filter != ''
                              ? Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: Text('Filter: ${story.filter}',
                                      style: TextStyle(color: Colors.white)),
                                )
                              : SizedBox.shrink(),
                          Text(
                            '${timeago.format(story.timeStart.toDate(), locale: 'en_short')}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      story.location != ''
                          ? Row(
                              children: [
                                Text(
                                  story.location,
                                  style: TextStyle(color: Colors.white),
                                ),
                                Icon(
                                  Icons.location_pin,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ],
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: null,
              )
            ],
          ),
        ],
      ),
    );
  }
}
