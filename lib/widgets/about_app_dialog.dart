import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:instagram/utilities/custom_navigation.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:instagram/services/services.dart';
import 'package:instagram/utilities/repo_const.dart';
import 'package:instagram/utilities/themes.dart';

class AboutAppDialog extends StatefulWidget {
  final String currentUserId;
  AboutAppDialog(this.currentUserId);
  @override
  _AboutAppDialogState createState() => _AboutAppDialogState();
}

class _AboutAppDialogState extends State<AboutAppDialog> {
  bool _isFollowing = false;
  String _followText = 'Follow ME!';

  @override
  void initState() {
    super.initState();
    _setupIsFollowing();
  }

  Future _setupIsFollowing() async {
    bool isFollowingUser = await DatabaseService.isFollowingUser(
      currentUserId: widget.currentUserId,
      userId: kAdminUId,
    );
    setState(() {
      _isFollowing = isFollowingUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Developed With ♥ By:',
            style: kFontSize18FontWeight600TextStyle.copyWith(
                color: Theme.of(context).accentColor.withOpacity(0.8)),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(blurRadius: 2, color: Colors.black54, spreadRadius: 2)
              ],
            ),
            child: GestureDetector(
              onTap: () => CustomNavigation.navigateToUserProfile(
                  context: context,
                  currentUserId: widget.currentUserId,
                  isCameFromBottomNavigation: false,
                  userId: kAdminUId),
              child: CircleAvatar(
                radius: 50.0,
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(
                    'https://edenik.com/assets/images/profile.png'),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Eden Nahum',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              'I hope you Enjoyed here :)',
              textAlign: TextAlign.center,
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
            child: Text('Edenik.com',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                )),
          ),
          onPressed: () async {
            const url = 'https://Edenik.com';
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              throw 'Could not launch $url';
            }
            Navigator.pop(context);
          },
        ),
        Divider(),
        SimpleDialogOption(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(FontAwesomeIcons.github),
              Text(
                ' Github Repo',
                style: kFontSize18TextStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          onPressed: () async {
            const url = 'https://github.com/Edenik/Flutter-Instagram-Clone';
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              throw 'Could not launch $url';
            }
            Navigator.pop(context);
          },
        ),
        Divider(),
        _isFollowing
            ? SizedBox.shrink()
            : SimpleDialogOption(
                child: Center(
                  child: Text(
                    _followText,
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onPressed: _followText == 'Thanks ♥'
                    ? null
                    : () {
                        setState(() {
                          _followText = 'Thanks ♥';
                        });
                        DatabaseService.followUser(
                            currentUserId: widget.currentUserId,
                            userId: kAdminUId);
                      }),
      ],
    );
  }
}
