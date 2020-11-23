import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:instagram/widgets/user_badges.dart';
import 'package:ionicons/ionicons.dart';
import 'package:timeago/timeago.dart' as timeago;

class StoryInfo extends StatelessWidget {
  final User user;
  final Story story;
  final double height;
  final Function onSwipeUp;
  const StoryInfo(
      {Key key,
      @required this.user,
      @required this.story,
      @required this.height,
      @required this.onSwipeUp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildUserInfo(),
          story.caption != ''
              ? Center(
                  child: Text(
                    story.caption,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                )
              : const SizedBox.shrink(),
          const SizedBox.shrink(),
          story.linkUrl != ''
              ? GestureDetector(
                  onTap: onSwipeUp,
                  child: Column(
                    children: [
                      Icon(
                        Ionicons.arrow_up_circle,
                        color: Colors.white,
                        size: 30,
                      ),
                      Text(
                        'Swipe Up',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ],
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
