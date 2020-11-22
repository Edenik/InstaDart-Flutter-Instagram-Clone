import 'package:flutter/material.dart';
import 'package:instagram/models/user_data.dart';
import 'package:instagram/screens/profile_screen/screens/deleted_posts_screen.dart';
import 'package:instagram/screens/screens.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:instagram/utilities/themes.dart';
import 'package:provider/provider.dart';

class ProfileScreenDrawer extends StatelessWidget {
  final String name;
  ProfileScreenDrawer({@required this.name});

  _buildDrawerOption(Icon icon, String title, Function onTap) {
    return ListTile(
      leading: icon,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20.0,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: 250,
        child: Drawer(
          child: Column(
            children: <Widget>[
              Container(
                height: 56,
                child: ListTile(
                    title: Text(
                  name,
                  style: kFontSize18TextStyle,
                )),
              ),
              Divider(height: 3),
              _buildDrawerOption(
                Icon(Icons.history),
                'Archive',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeletedPostsScreen(
                        currentUserId:
                            Provider.of<UserData>(context, listen: false)
                                .currentUserId,
                        postStatus: PostStatus.archivedPost),
                  ),
                ),
              ),
              _buildDrawerOption(
                Icon(Icons.delete),
                'Deleted Posts',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeletedPostsScreen(
                      currentUserId:
                          Provider.of<UserData>(context, listen: false)
                              .currentUserId,
                      postStatus: PostStatus.deletedPost,
                    ),
                  ),
                ),
              ),
              _buildDrawerOption(
                  Icon(Icons.history_toggle_off), 'Your Activity', null),
              _buildDrawerOption(Icon(Icons.bookmark), 'Saved', null),
              // _buildDrawerOption(
              //   Icon(Icons.bookmark),
              //   'Splash Screen test',
              //   () => Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (_) => SplashScreen(),
              //     ),
              //   ),
              // ),
              Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: _buildDrawerOption(
                    Icon(Icons.settings),
                    'Settings',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SettingsScreen(),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
