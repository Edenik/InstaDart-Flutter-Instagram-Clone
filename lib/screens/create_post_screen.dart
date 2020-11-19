import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:instagram/utilities/custom_navigation.dart';
import 'package:provider/provider.dart';

import 'package:instagram/models/models.dart';
import 'package:instagram/services/services.dart';

import 'package:cached_network_image/cached_network_image.dart';

class CreatePostScreen extends StatefulWidget {
  final Post post;
  final PostStatus postStatus;
  final File imageFile;
  CreatePostScreen({
    this.post,
    this.postStatus,
    this.imageFile,
  });

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  Address _address;
  TextEditingController _captionController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  Map<String, double> currentLocation = Map();
  String _caption = '';
  bool _isLoading = false;
  Post _post;
  String _currentUserId;
  @override
  initState() {
    super.initState();

    //variables with location assigned as 0.0
    currentLocation['latitude'] = 0.0;
    currentLocation['longitude'] = 0.0;
    initPlatformState(); //method to call location

    String currentUserId =
        Provider.of<UserData>(context, listen: false).currentUserId;

    setState(() {
      _currentUserId = currentUserId;
    });
    if (widget.post != null) {
      setState(() {
        _captionController.value = TextEditingValue(text: widget.post.caption);
        _locationController.value =
            TextEditingValue(text: widget.post.location);
        _post = widget.post;
      });
    }
  }

  @override
  void dispose() {
    _captionController?.dispose();
    _locationController?.dispose();
    super.dispose();
  }

  //method to get Location and save into variables
  initPlatformState() async {
    Address first = await LocationService.getUserLocation();
    if (mounted) {
      setState(() {
        _address = first;
      });
    }
  }

  _submit() async {
    FocusScope.of(context).unfocus();

    if (!_isLoading &&
        (widget.imageFile != null || _post.imageUrl != null) &&
        _captionController.text.isNotEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      print(_post != null);
      if (_post != null) {
        // Edit existing Post
        Post post = Post(
          id: _post.id,
          imageUrl: _post.imageUrl,
          caption: _captionController.text,
          location: _locationController.text,
          likeCount: _post.likeCount,
          authorId: _post.authorId,
          timestamp: _post.timestamp,
          commentsAllowed: _post.commentsAllowed,
        );

        DatabaseService.editPost(post, widget.postStatus);
        // _goToHomeScreen();

        // Timer(Duration(seconds: 1), () {
        // });
      } else {
        //Create new Post
        String imageUrl = await StroageService.uploadPost(widget.imageFile);
        Post post = Post(
          imageUrl: imageUrl,
          caption: _captionController.text,
          location: _locationController.text,
          likeCount: 0,
          authorId: _currentUserId,
          timestamp: Timestamp.fromDate(DateTime.now()),
          commentsAllowed: true,
        );

        DatabaseService.createPost(post);
      }
      _goToHomeScreen();

      // Reset Data
      // _captionController.clear();
      // _locationController.clear();

      // if (mounted) {
      //   setState(() {
      //     _post = null;
      //     _isLoading = false;
      //   });
      // }
    }
  }

  //method to build buttons with location.
  _buildLocationButton(String locationName) {
    if (locationName != null ?? locationName.isNotEmpty) {
      return InkWell(
        onTap: () {
          _locationController.text = locationName;
        },
        child: Center(
          child: Container(
            //width: 100.0,
            height: 30.0,
            padding: EdgeInsets.only(left: 8.0, right: 8.0),
            margin: EdgeInsets.only(right: 3.0, left: 3.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Center(
              child: Text(
                locationName,
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  _goToHomeScreen() {
    CustomNavigation.navigateToHomeScreen(context, _currentUserId);
  }

  _buildForm() {
    return Column(
      children: <Widget>[
        _isLoading ? LinearProgressIndicator() : SizedBox.shrink(),
        Divider(),
        Row(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15.0),
              height: 45.0,
              width: 45.0,
              child: AspectRatio(
                aspectRatio: 487 / 451,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      alignment: FractionalOffset.topCenter,
                      image: widget.imageFile == null
                          ? CachedNetworkImageProvider(_post.imageUrl)
                          : FileImage(widget.imageFile),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 250.0,
              child: TextField(
                onChanged: (value) => {
                  setState(() {
                    _caption = value;
                  })
                },
                controller: _captionController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    hintText: 'Write a caption...',
                    border: InputBorder.none),
              ),
            ),
          ],
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.pin_drop),
          title: Container(
            width: 250.0,
            child: TextField(
              controller: _locationController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: 'Where was this photo taken?',
                  border: InputBorder.none),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.color,
          centerTitle: true,
          title: Text(widget.imageFile == null ? 'Edit Post' : 'New Post'),
          actions: <Widget>[
            FlatButton(
                onPressed:
                    _captionController.text.trim() != '' ? _submit : null,
                child: Text(
                  widget.imageFile == null ? 'Save' : 'Share',
                  style: TextStyle(
                      color: _captionController.text.trim() != ''
                          ? Theme.of(context).accentColor
                          : Theme.of(context).hintColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0),
                ))
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(
            children: <Widget>[
              _buildForm(),
              Divider(),
              (_address == null)
                  ? SizedBox.shrink()
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(right: 5.0, left: 5.0),
                      child: Row(
                        children: <Widget>[
                          _buildLocationButton(_address.featureName),
                          _buildLocationButton(_address.subLocality),
                          _buildLocationButton(_address.locality),
                          _buildLocationButton(_address.subAdminArea),
                          _buildLocationButton(_address.adminArea),
                          _buildLocationButton(_address.countryName),
                        ],
                      ),
                    ),
              (_address == null) ? SizedBox.shrink() : Divider(),
            ],
          ),
        ));
  }
}
