import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:instagram/models/models.dart';
import 'package:instagram/services/services.dart';

import 'package:instagram/utilities/themes.dart';

class CreatePostScreen extends StatefulWidget {
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

  @override
  initState() {
    super.initState();
    //variables with location assigned as 0.0
    currentLocation['latitude'] = 0.0;
    currentLocation['longitude'] = 0.0;
    initPlatformState(); //method to call location
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
        _imageFile != null &&
        _captionController.text.isNotEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      //Create Post
      String imageUrl = await StroageService.uploadPost(_imageFile);
      Post post = Post(
        imageUrl: imageUrl,
        caption: _captionController.text,
        location: _locationController.text,
        likeCount: 0,
        authorId: Provider.of<UserData>(context, listen: false).currentUserId,
        timestamp: Timestamp.fromDate(DateTime.now()),
        commentsAllowed: true,
      );

      DatabaseService.createPost(post);

      //Reset Data
      _captionController.clear();
      _locationController.clear();

      if (mounted) {
        setState(() {
          _imageFile = null;
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
              color: Theme.of(context).appBarTheme.color,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Center(
              child: Text(
                locationName,
                style: kFontColorGreyTextStyle,
              ),
            ),
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  _clearImage() {
    setState(() {
      _imageFile = null;
    });
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
                      image: FileImage(_imageFile),
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
    return _imageFile == null
        ? IconButton(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  FontAwesomeIcons.cameraRetro,
                  size: 50.0,
                ),
                Text('Click'),
              ],
            ),
            onPressed: () => _showSelectImageDialog(),
          )
        : Scaffold(
            resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              backgroundColor: Theme.of(context).appBarTheme.color,
              centerTitle: true,
              leading: IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: Theme.of(context).accentColor),
                  onPressed: _clearImage),
              title: Text('New Post'),
              actions: <Widget>[
                FlatButton(
                    onPressed: _caption.trim() != '' ? _submit : null,
                    child: Text(
                      'Share',
                      style: TextStyle(
                          color: _caption.trim() != ''
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
