import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/screens.dart';

class CustomNavigation {
  static void navigateToUserProfile({
    BuildContext context,
    bool isCameFromBottomNavigation,
    String currentUserId,
    String userId,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          isCameFromBottomNavigation: isCameFromBottomNavigation,
          currentUserId: currentUserId,
          userId: userId,
        ),
      ),
    );
  }

  // static void navigateToShowErrorDialog(
  //     BuildContext context, String errorMessage) {
  //   Navigator.push(context,
  //       MaterialPageRoute(builder: (_) => ShowErrorDialog(errorMessage)));
  // }

  static void navigateToHomeScreen(BuildContext context, String currentUserId) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(currentUserId),
      ),
      (Route<dynamic> route) => false,
    );
  }
}
