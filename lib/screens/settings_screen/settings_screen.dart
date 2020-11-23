import 'package:flutter/material.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/screens/settings_screen/theme_screen.dart';
import 'package:instagram/services/services.dart';
import 'package:instagram/utilities/themes.dart';
import 'package:instagram/screens/settings_screen/widgets/about_app_dialog.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentUserId;

  _buildOptionTile(Icon icon, String title, Function onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
      leading: icon,
      title: Text(
        title,
        style: kFontSize18TextStyle,
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    _currentUserId =
        Provider.of<UserData>(context, listen: false).currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
        ),
      ),
      body: Column(
        children: [
          _buildOptionTile(Icon(Ionicons.person_add_outline),
              'Follow and Invite Friends', null),
          _buildOptionTile(Icon(Ionicons.lock_closed_outline), 'Privacy', null),
          _buildOptionTile(
              Icon(Ionicons.information_circle_outline),
              'About',
              () => showDialog(
                  context: context,
                  builder: (_) => AboutAppDialog(_currentUserId))),
          _buildOptionTile(
              Icon(Ionicons.color_palette_outline),
              'Theme',
              () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ThemeScreen(),
                    ),
                  )),
          Expanded(
              child: Align(
            alignment: FractionalOffset.bottomCenter,
            child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                title: Text(
                  'Log Out',
                  style: kFontSize18FontWeight600TextStyle.copyWith(
                      color: Colors.blue),
                ),
                onTap: () {
                  AuthService.logout();
                  Navigator.pop(context);
                }),
          ))
        ],
      ),
    );
  }
}
