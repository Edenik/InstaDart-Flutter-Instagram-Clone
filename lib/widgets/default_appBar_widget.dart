import 'package:flutter/material.dart';

class DefaultAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Text(
        'Instagram',
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'Billabong',
          fontSize: 35.0,
        ),
      ),
    );
  }
}
