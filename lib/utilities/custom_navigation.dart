import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/screens.dart';
import 'package:instagram/utilities/show_error_dialog.dart';

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
          goToCameraScreen: () =>
              navigateToHomeScreen(context, currentUserId, initialPage: 0),
        ),
      ),
    );
  }

  // static void navigateToShowErrorDialog(
  //     BuildContext context, String errorMessage) {
  //   Navigator.push(context,
  //       MaterialPageRoute(builder: (_) => ShowErrorDialog(errorMessage)));
  // }
  static Future<List<CameraDescription>> getCameras(
      BuildContext context) async {
    List<CameraDescription> _cameras;
    try {
      _cameras = await availableCameras();
    } on CameraException catch (_) {
      ShowErrorDialog.showAlertDialog(
          errorMessage: 'Cant get cameras!', context: context);
    }

    return _cameras;
  }

  static void navigateToHomeScreen(BuildContext context, String currentUserId,
      {int initialPage = 1}) async {
    List<CameraDescription> _cameras;
    if (initialPage == 0) {
      _cameras = await getCameras(context);
      if (_cameras == null) {
        return;
      }
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            currentUserId: currentUserId,
            initialPage: initialPage,
            cameras: _cameras,
          ),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            currentUserId: currentUserId,
            initialPage: initialPage,
          ),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }
}
