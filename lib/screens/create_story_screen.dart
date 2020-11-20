import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:instagram/utilities/filters.dart';
import 'package:provider/provider.dart';

class CreateStoryScreen extends StatefulWidget {
  final File imageFile;
  CreateStoryScreen(this.imageFile);
  @override
  _CreateStoryScreenState createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final GlobalKey _globalKey = GlobalKey();
  String _filterTitle = '';
  bool _newTitle = false;
  PageController _pageController = PageController();
  int _selectedIndex = 0;

  void setTitle(title) {
    setState(() {
      _filterTitle = filters[title].name;
      _newTitle = true;
    });
    Timer(Duration(milliseconds: 1000), () {
      if (_filterTitle == filters[title].name) {
        setState(() => _newTitle = false);
      }
    });
  }

  void postStory(BuildContext context) {
    showDialog(
        context: context,
        child: SimpleDialog(
          title: Column(
            children: [
              Text('Stories on Progress'),
              SizedBox(
                height: 20,
              ),
              Icon(
                Icons.timer,
                size: 30,
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final User _currentUser = Provider.of<UserData>(context).currentUser;
    final Image image = Image.file(
      widget.imageFile,
      fit: BoxFit.cover,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      body: Stack(
        children: <Widget>[
          Center(
            child: RepaintBoundary(
              key: _globalKey,
              child: Container(
                child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (value) {
                      setState(() => _selectedIndex = value);
                      setTitle(value);
                    },
                    itemCount: filters.length,
                    itemBuilder: (context, index) {
                      return ColorFiltered(
                        colorFilter:
                            ColorFilter.matrix(filters[index].matrixValues),
                        child: image,
                      );
                    }),
              ),
            ),
          ),
          if (_newTitle)
            Align(
              alignment: Alignment.center,
              child: Text(
                _filterTitle,
                style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      height: 34,
                      width: 34,
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.times,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  _selectedIndex != 0
                      ? GestureDetector(
                          onTap: () => _pageController.jumpToPage(0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            height: 34,
                            width: 34,
                            child: Center(
                              child: FaIcon(
                                FontAwesomeIcons.eraser,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              onPressed: () => postStory(context),
              color: Theme.of(context).primaryColor.withOpacity(0.8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: 15.0,
                    backgroundImage: _currentUser.profileImageUrl.isEmpty
                        ? AssetImage(placeHolderImageRef)
                        : CachedNetworkImageProvider(
                            _currentUser.profileImageUrl),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    'Post Story',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
