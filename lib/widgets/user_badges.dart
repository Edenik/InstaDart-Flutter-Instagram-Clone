import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:instagram/models/models.dart';

class UserBadges extends StatelessWidget {
  final User user;
  final double size;
  final bool firstSizedBox;
  UserBadges(
      {@required this.user, @required this.size, this.firstSizedBox = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (user?.isVerified == true && this.firstSizedBox == true)
          SizedBox(width: 5),
        if (user?.isVerified)
          Image.asset(
            'assets/images/verifiedUserBadge.png',
            height: size,
            width: size,
          ),
        if (user?.isVerified) SizedBox(width: 5),
        if (user.role == 'admin')
          FaIcon(
            FontAwesomeIcons.userShield,
            size: size - 2,
            color: Colors.blue,
          ),
        if (user.role == 'admin') SizedBox(width: 5),
      ],
    );
  }
}
