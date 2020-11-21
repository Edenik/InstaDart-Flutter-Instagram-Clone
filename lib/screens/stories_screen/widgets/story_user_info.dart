import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:instagram/utilities/themes.dart';

class StoryUserInfo extends StatelessWidget {
  final User user;
  final Story story;
  final Size size;
  const StoryUserInfo({
    Key key,
    @required this.user,
    @required this.story,
    @required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20.0,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: user.profileImageUrl.isEmpty
                            ? AssetImage(placeHolderImageRef)
                            : CachedNetworkImageProvider(user.profileImageUrl),
                      ),
                      const SizedBox(width: 10.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: kFontSize18FontWeight600TextStyle.copyWith(
                                color: Colors.white),
                          ),
                          story.filter != ''
                              ? Text('Filter: ${story.filter}')
                              : SizedBox.shrink()
                        ],
                      ),
                    ],
                  ),
                  story.location != ''
                      ? Row(
                          children: [
                            Icon(Icons.location_pin),
                            Text(story.location)
                          ],
                        )
                      : SizedBox.shrink(),
                  IconButton(
                    icon: const Icon(Icons.close,
                        size: 30.0, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
            ],
          ),
          story.caption != ''
              ? Text(
                  story.caption,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30),
                )
              : const SizedBox.shrink(),
          const SizedBox.shrink()
        ],
      ),
    );
  }
}
