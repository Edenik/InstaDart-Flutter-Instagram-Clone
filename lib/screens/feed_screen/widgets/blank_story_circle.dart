import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:provider/provider.dart';

class BlankStoryCircle extends StatelessWidget {
  final User user;
  final Function goToCameraScreen;
  final double size;
  final bool showUserName;

  BlankStoryCircle({
    @required this.user,
    @required this.goToCameraScreen,
    this.size = 60,
    this.showUserName = true,
  });
  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserData>(context).currentUser;
    bool isCurrentUser = currentUser.id == user.id ? true : false;
    return Container(
      width: size + 10,
      margin: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                margin: EdgeInsets.all(5.0),
                height: size,
                width: size,
                padding: const EdgeInsets.all(2),
                decoration: isCurrentUser
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 3.0, color: Colors.grey),
                      )
                    : null,
                child: GestureDetector(
                  onTap: isCurrentUser ? goToCameraScreen : () {},
                  child: ClipOval(
                    child: Image(
                      image: user.profileImageUrl.isEmpty
                          ? AssetImage(placeHolderImageRef)
                          : CachedNetworkImageProvider(user.profileImageUrl),
                      height: 60.0,
                      width: 60.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              if (isCurrentUser)
                Positioned(
                  bottom: 5,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add_circle,
                        color: Colors.blue,
                        size: size == 60 ? 21 : 30,
                      ),
                    ),
                  ),
                )
            ],
          ),
          if (showUserName)
            Expanded(
              child: Text(
                user.name,
                textAlign: TextAlign.center,
                overflow: TextOverflow.clip,
              ),
            )
        ],
      ),
    );
  }
}
