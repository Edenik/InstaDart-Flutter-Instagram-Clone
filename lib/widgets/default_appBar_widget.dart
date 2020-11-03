import 'package:flutter/material.dart';
import 'package:instagram/utilities/styles.dart';

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
        style: kBillabongFamilyTextStyle,
      ),
    );
  }
}
