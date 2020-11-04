import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/services/services.dart';
import 'package:instagram/utilities/styles.dart';
import 'package:instagram/widgets/about_app_dialog.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentUserId;

  _buildOptionTile(FaIcon icon, String title, Function onTap) {
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
        backgroundColor: Colors.white,
        title: Text(
          'Settings',
          style: kFontColorBlackTextStyle,
        ),
      ),
      body: Column(
        children: [
          _buildOptionTile(FaIcon(FontAwesomeIcons.userPlus),
              'Follow and Invite Friends', null),
          _buildOptionTile(FaIcon(FontAwesomeIcons.lock), 'Privacy', null),
          _buildOptionTile(
              FaIcon(FontAwesomeIcons.infoCircle),
              'About',
              () => showDialog(
                  context: context,
                  builder: (_) => AboutAppDialog(_currentUserId))),
          _buildOptionTile(FaIcon(FontAwesomeIcons.palette), 'Theme', null),
          Expanded(
              child: Align(
            alignment: FractionalOffset.bottomCenter,
            child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                title: Text(
                  'Log Out',
                  style: kFontSize18FontWeight600TextStyle.copyWith(
                      color: Theme.of(context).primaryColor),
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
