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

  // _goToUserProfile(BuildContext context, Post post) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) => ProfileScreen(
  //         isCameFromBottomNavigation: false,
  //         currentUserId: widget.currentUserId,
  //         userId: post.authorId,
  //       ),
  //     ),
  //   );
  // }
}
