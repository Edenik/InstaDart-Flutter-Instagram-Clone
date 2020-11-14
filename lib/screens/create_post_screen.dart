import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:instagram/utilities/custom_navigation.dart';
import 'package:provider/provider.dart';

import 'package:instagram/models/models.dart';
import 'package:instagram/services/services.dart';

import 'package:instagram/utilities/themes.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CreatePostScreen extends StatefulWidget {
  final Post post;
  final PostStatus postStatus;

  CreatePostScreen({this.post, this.postStatus});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _picker = ImagePicker();
  File _imageFile;
  Address _address;
  TextEditingController _captionController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  Map<String, double> currentLocation = Map();
  String _caption = '';
  bool _isLoading = false;
  bool _isEdited = false;
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

  //method to get Location and save into variables
  initPlatformState() async {
    Address first = await LocationService.getUserLocation();
    if (mounted) {
      setState(() {
        _address = first;
      });
    }
  }

  _showSelectImageDialog() {
    return Platform.isIOS ? _iosBottomSheet() : _androidDialog();
  }

  _iosBottomSheet() {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text('Add Photo'),
            actions: <Widget>[
              CupertinoActionSheetAction(
                onPressed: () => _handleImage(ImageSource.camera),
                child: Text('Take Photo'),
              ),
              CupertinoActionSheetAction(
                onPressed: () => _handleImage(ImageSource.gallery),
                child: Text('Choose From Gallery'),
              )
            ],
            cancelButton: CupertinoActionSheetAction(
              child: Text(
                'Cancel',
                style: kFontColorRedTextStyle,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          );
        });
  }

  _androidDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Add Photo'),
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Take Photo'),
                onPressed: () => _handleImage(ImageSource.camera),
              ),
              SimpleDialogOption(
                child: Text('Choose From Gallery'),
                onPressed: () => _handleImage(ImageSource.gallery),
              ),
              SimpleDialogOption(
                child: Text(
                  'Cancel',
                  style: kFontColorRedTextStyle,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  _handleImage(ImageSource source) async {
    Navigator.pop(context);
    File image;
    PickedFile pickedFile = await _picker.getImage(source: source);
    if (pickedFile != null) {
      image = await _cropImage(File(pickedFile.path));
      setState(() {
        _imageFile = image;
      });
    } else {
      print('No image selected.');
    }
  }

  _cropImage(File imageFile) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
    );
    return croppedImage;
  }

  _submit() async {
    if (!_isLoading &&
        (_imageFile != null || _post.imageUrl != null) &&
        _captionController.text.isNotEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

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
        setState(() {
          _isEdited = true;
        });

        Timer(Duration(seconds: 1), () {
          _goToHomeScreen();
        });
      } else {
        //Create new Post
        String imageUrl = await StroageService.uploadPost(_imageFile);
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

      //Reset Data
      _captionController.clear();
      _locationController.clear();

      if (mounted) {
        setState(() {
          _imageFile = null;
          _post = null;
          _isLoading = false;
        });
      }
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

  _backButton() {
    if (_post == null) {
      setState(() {
        _imageFile = null;
      });
    } else {
      _goToHomeScreen();
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
                      image: _imageFile == null
                          ? CachedNetworkImageProvider(_post.imageUrl)
                          : FileImage(_imageFile),
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
                    hintText: 'Write a caption...', border: InputBorder.none),
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
    return _imageFile == null && _post == null
        ? Scaffold(
            body: Center(
              child: GestureDetector(
                onTap: () => _isEdited ? null : _showSelectImageDialog(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    FaIcon(
                      _isEdited
                          ? FontAwesomeIcons.check
                          : FontAwesomeIcons.cameraRetro,
                      size: 50.0,
                    ),
                    SizedBox(height: 5.0),
                    Text(_isEdited ? 'Edited Successfully' : 'Click')
                  ],
                ),
              ),
            ),
          )
        : Scaffold(
            resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              backgroundColor: Theme.of(context).appBarTheme.color,
              centerTitle: true,
              leading: IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: Theme.of(context).accentColor),
                  onPressed: _backButton),
              title: Text(_imageFile == null ? 'Edit Post' : 'New Post'),
              actions: <Widget>[
                FlatButton(
                    onPressed:
                        _captionController.text.trim() != '' ? _submit : null,
                    child: Text(
                      _imageFile == null ? 'Save' : 'Share',
                      style: TextStyle(
                          color: _captionController.text.trim() != ''
                              ? Theme.of(context).accentColor
                              : Theme.of(context).hintColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                    ))
              ],
            ),
            body: ListView(
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
            ));
  }
}
