import 'package:flutter/material.dart';
import 'package:instagram/screens/screens.dart';
import 'package:instagram/utilities/styles.dart';

class CustomDrawer extends StatelessWidget {
  final String name;
  CustomDrawer({@required this.name});

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
              _buildDrawerOption(Icon(Icons.history), 'Archive', null),
              _buildDrawerOption(
                  Icon(Icons.history_toggle_off), 'Your Activity', null),
              _buildDrawerOption(Icon(Icons.bookmark), 'Saved', null),
              _buildDrawerOption(
                Icon(Icons.bookmark),
                'Camera test',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SplashScreen(),
                  ),
                ),
              ),
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
