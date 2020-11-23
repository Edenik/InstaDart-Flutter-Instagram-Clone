import 'package:flutter/material.dart';
import 'package:instagram/models/models.dart';

class UserBadges extends StatelessWidget {
  final User user;
  final double size;
  final bool secondSizedBox;
  UserBadges(
      {@required this.user, @required this.size, this.secondSizedBox = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (user?.isVerified == true) SizedBox(width: 5),
        if (user?.isVerified)
          Tooltip(
            message: 'User is Verified',
            child: Image.asset(
              'assets/images/verified_user_badge.png',
              height: size + 2,
              width: size + 2,
            ),
          ),
        if (user.role == 'admin') SizedBox(width: 5),
        if (user.role == 'admin')
          Tooltip(
            message: 'User is Admin',
            child: Image.asset(
              'assets/images/admin_badge.png',
              height: size + 4,
              width: size + 4,
            ),
          ),
        if (user.role == 'admin' && this.secondSizedBox == true)
          SizedBox(width: 5),
      ],
    );
  }
}
