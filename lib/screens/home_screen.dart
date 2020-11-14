import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import 'package:instagram/models/models.dart';
import 'package:instagram/screens/screens.dart';
import 'package:instagram/services/services.dart';
import 'package:instagram/utilities/constants.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;
  HomeScreen(this.currentUserId);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  int _currentTab = 0;
  PageController _pageController;
  User _currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _pageController = PageController();
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

    AuthService.updateToken();
  }

  _getCurrentUser() async {
    User currentUser =
        await DatabaseService.getUserWithId(widget.currentUserId);

    Provider.of<UserData>(context, listen: false).currentUser = currentUser;
    setState(() {
      _currentUser = currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          FeedScreen(currentUserId: widget.currentUserId),
          SearchScreen(
            searchFrom: SearchFrom.homeScreen,
          ),
          CreatePostScreen(),
          ActivityScreen(currentUser: _currentUser),
          ProfileScreen(
            isCameFromBottomNavigation: true,
            onProfileEdited: _getCurrentUser,
            userId: widget.currentUserId,
            currentUserId: widget.currentUserId,
          ),
        ],
        onPageChanged: (int index) {
          setState(() {
            _currentTab = index;
          });
        },
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: _currentTab,
        backgroundColor:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        activeColor:
            Theme.of(context).bottomNavigationBarTheme.selectedIconTheme.color,
        inactiveColor: Theme.of(context)
            .bottomNavigationBarTheme
            .unselectedIconTheme
            .color,
        onTap: (int index) {
          setState(() {
            _currentTab = index;
          });
          _pageController.animateToPage(index,
              duration: Duration(milliseconds: 200), curve: Curves.easeIn);
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 32.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              size: 32.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_camera,
              size: 32.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.notifications,
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
                    : CachedNetworkImageProvider(_currentUser.profileImageUrl),
              ),
            ),
        ],
      ),
    );
  }
}
