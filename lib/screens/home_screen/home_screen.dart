import 'package:camera/camera.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:instagram/screens/camera_screen/camera_screen.dart';
import 'package:instagram/screens/direct_messages/direct_messages_screen.dart';
import 'package:instagram/utilities/show_error_dialog.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

import 'package:instagram/models/models.dart';
import 'package:instagram/screens/screens.dart';
import 'package:instagram/services/services.dart';
import 'package:instagram/utilities/constants.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;
  final int initialPage;
  final List<CameraDescription> cameras;
  HomeScreen({this.currentUserId, this.initialPage = 1, this.cameras});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  int _currentTab = 0;
  int _currentPage = 0;
  int _lastTab = 0;
  PageController _pageController;
  User _currentUser;
  List<CameraDescription> _cameras;
  CameraConsumer _cameraConsumer = CameraConsumer.post;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _getCameras();

    _initPageView();
    _listenToNotifications();
    AuthService.updateToken();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  Future<Null> _getCameras() async {
    if (widget.cameras != null) {
      setState(() {
        _cameras = widget.cameras;
      });
    } else {
      try {
        _cameras = await availableCameras();
      } on CameraException catch (_) {
        ShowErrorDialog.showAlertDialog(
            errorMessage: 'Cant get cameras!', context: context);
      }
    }
  }

  void _initPageView() async {
    _pageController = PageController(initialPage: widget.initialPage);
    setState(() => _currentPage = widget.initialPage);
  }

  void _listenToNotifications() {
    _firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('On message: $message');
    }, onResume: (Map<String, dynamic> message) {
      print('On resume: $message');
    }, onLaunch: (Map<String, dynamic> message) {
      print('On launch: $message');
    });

    _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
        sound: true,
        badge: true,
        alert: true,
      ),
    );
    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      print('settings registered:  $settings');
    });
  }

  void _selectTab(int index) {
    if (index == 2) {
      // go to CameraScreen
      _pageController.animateToPage(0,
          duration: Duration(milliseconds: 200), curve: Curves.easeIn);
      _selectPage(2);
    }
    setState(() {
      _lastTab = _currentTab;
      _currentTab = index;
    });
  }

  void _selectPage(int index) {
    if (index == 1 && _currentTab == 2) {
      // Come back from CameraScreen to FeedScreen
      _selectTab(_lastTab);
      if (_cameraConsumer != CameraConsumer.post) {
        setState(() => _cameraConsumer = CameraConsumer.post);
      }
    }

    setState(() {
      _currentPage = index;
    });
  }

  void _goToDirect() {
    _selectPage(2);
    _pageController.animateToPage(2,
        duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  void _backToHomeScreenFromDirect() {
    _selectPage(1);
    _pageController.animateToPage(1,
        duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  void _goToCameraScreen() {
    setState(() => _cameraConsumer = CameraConsumer.story);
    _selectPage(0);
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  void _backToHomeScreenFromCameraScreen() {
    _selectPage(1);
    _pageController.animateToPage(1,
        duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  void _getCurrentUser() async {
    User currentUser =
        await DatabaseService.getUserWithId(widget.currentUserId);

    Provider.of<UserData>(context, listen: false).currentUser = currentUser;

    print('i have the current user now');
    setState(() => _currentUser = currentUser);
    AuthService.updateTokenWithUser(currentUser);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = [
      FeedScreen(
        currentUserId: widget.currentUserId,
        goToDirectMessages: _goToDirect,
        goToCameraScreen: _goToCameraScreen,
      ),
      SearchScreen(
        searchFrom: SearchFrom.homeScreen,
      ),
      SizedBox.shrink(),
      ActivityScreen(
        currentUser: _currentUser,
      ),
      ProfileScreen(
        goToCameraScreen: _goToCameraScreen,
        isCameFromBottomNavigation: true,
        onProfileEdited: _getCurrentUser,
        userId: widget.currentUserId,
        currentUserId: widget.currentUserId,
      ),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          CameraScreen(
              _cameras, _backToHomeScreenFromCameraScreen, _cameraConsumer),
          _pages[_currentTab],
          DirectMessagesScreen(_backToHomeScreenFromDirect)
        ],
        onPageChanged: (int index) => _selectPage(index),
      ),
      bottomNavigationBar: _currentPage == 1
          ? CupertinoTabBar(
              currentIndex: _currentTab,
              backgroundColor:
                  Theme.of(context).bottomNavigationBarTheme.backgroundColor,
              activeColor: Theme.of(context)
                  .bottomNavigationBarTheme
                  .selectedIconTheme
                  .color,
              inactiveColor: Theme.of(context)
                  .bottomNavigationBarTheme
                  .unselectedIconTheme
                  .color,
              onTap: _selectTab,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Ionicons.home_outline,
                    size: 32.0,
                  ),
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Ionicons.search_outline,
                    size: 32.0,
                  ),
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Ionicons.add_circle_outline,
                    size: 32.0,
                  ),
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Ionicons.notifications_outline,
                    size: 32.0,
                  ),
                ),
                if (_currentUser == null)
                  BottomNavigationBarItem(
                    icon: SizedBox.shrink(),
                  ),
                if (_currentUser != null)
                  BottomNavigationBarItem(
                    activeIcon: Container(
                      padding: const EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 2.0,
                          color: Theme.of(context)
                              .bottomNavigationBarTheme
                              .selectedIconTheme
                              .color,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 15.0,
                        backgroundImage: _currentUser.profileImageUrl.isEmpty
                            ? AssetImage(placeHolderImageRef)
                            : CachedNetworkImageProvider(
                                _currentUser.profileImageUrl),
                      ),
                    ),
                    icon: CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 15.0,
                      backgroundImage: _currentUser.profileImageUrl.isEmpty
                          ? AssetImage(placeHolderImageRef)
                          : CachedNetworkImageProvider(
                              _currentUser.profileImageUrl),
                    ),
                  ),
              ],
            )
          : SizedBox.shrink(),
    );
  }
}
