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
          Image.asset(
            'assets/images/verified_user_badge.png',
            height: size + 2,
            width: size + 2,
          ),
        if (user?.isVerified) SizedBox(width: 5),
        if (user.role == 'admin')
          Image.asset(
            'assets/images/admin_badge.png',
            height: size + 4,
            width: size + 4,
          ),
        if (user.role == 'admin' && this.secondSizedBox == true)
          SizedBox(width: 5),
      ],
    );
  }
}
