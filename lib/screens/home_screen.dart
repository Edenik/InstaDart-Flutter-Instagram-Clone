import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/user_data.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/screens/screens.dart';
import 'package:instagram/services/database_service.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;
  HomeScreen(this.currentUserId);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  PageController _pageController;
  User _currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _pageController = PageController();
  }

  _getCurrentUser() async {
    User currentUser =
        await DatabaseService.getUserWithId(widget.currentUserId);

    Provider.of<UserData>(context, listen: false).profileImageUrl =
        currentUser.profileImageUrl;
    setState(() {
      _currentUser = currentUser;
    });
    print(_currentUser.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          FeedScreen(currentUserId: widget.currentUserId),
          SearchScreen(),
          CreatePostScreen(),
          ActivityScreen(currentUserId: widget.currentUserId),
          ProfileScreen(
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
        activeColor: Colors.black,
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 2.0,
                    color: Colors.black,
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
