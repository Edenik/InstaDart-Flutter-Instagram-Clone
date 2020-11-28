import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:instagram/models/models.dart';
import 'package:instagram/services/services.dart';
import 'package:instagram/services/core/url_validator_service.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:instagram/utilities/themes.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  final Function updateUser;

  EditProfileScreen({this.user, this.updateUser});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _bio = '';
  String _website = '';
  File _profileImage;
  final picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.user.name;
    _bio = widget.user.bio;
    _website = widget.user.website;
  }

  _handleImageFromGallery() async {
    PickedFile pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  _submit() async {
    if (_formKey.currentState.validate() && !_isLoading) {
      _formKey.currentState.save();

      setState(() => _isLoading = true);
      String url;

      if (_website.trim() != '') {
        url = await UrlValidatorService.isUrlValid(context, _website.trim());
        if (url == null) {
          setState(() => _isLoading = false);
          return;
        }
      }

      //Update user in database
      String _profileImageUrl = '';

      if (_profileImage == null) {
        _profileImageUrl = widget.user.profileImageUrl;
      } else {
        _profileImageUrl = await StroageService.uploadUserProfileImage(
          widget.user.profileImageUrl,
          _profileImage,
        );
      }

      User user = User(
          id: widget.user.id,
          name: _name.trim(),
          profileImageUrl: _profileImageUrl,
          bio: _bio.trim(),
          role: widget.user.role,
          isVerified: widget.user.isVerified,
          website: url);

      //Database Update
      DatabaseService.updateUser(user);

      widget.updateUser(user);

      Navigator.pop(context);
    }
  }

  _displayProfileImage() {
    // No new profile image
    if (_profileImage == null) {
      // No existing profile image
      if (widget.user.profileImageUrl.isEmpty) {
        //display placeholder
        return AssetImage(placeHolderImageRef);
      } else {
        //user profile image exist
        return CachedNetworkImageProvider(widget.user.profileImageUrl);
      }
    } else {
      //new profile image
      return FileImage(_profileImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.color,
        title: Text(
          'Edit Profile',
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          children: <Widget>[
            _isLoading
                ? LinearProgressIndicator(
                    backgroundColor: Colors.blue[200],
                    valueColor: AlwaysStoppedAnimation(Colors.blue),
                  )
                : SizedBox.shrink(),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 60.0,
                      backgroundColor: Colors.grey,
                      backgroundImage: _displayProfileImage(),
                    ),
                    FlatButton(
                      onPressed: _handleImageFromGallery,
                      child: Text(
                        'Change Profile Image',
                        style: TextStyle(color: Colors.blue, fontSize: 16.0),
                      ),
                    ),
                    TextFormField(
                      initialValue: _name,
                      maxLength: 20,
                      textCapitalization: TextCapitalization.words,
                      style: kFontSize18TextStyle,
                      decoration: InputDecoration(
                          icon: Icon(
                            Icons.person,
                            size: 30.0,
                          ),
                          labelText: 'Name'),
                      validator: (input) => input.trim().length < 1
                          ? 'Please enter a valid name'
                          : input.trim().length > 20
                              ? 'Please enter name less than 20 characters'
                              : null,
                      onSaved: (input) => _name = input,
                    ),
                    TextFormField(
                      initialValue: _bio,
                      maxLines: 4,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      style: kFontSize18TextStyle,
                      decoration: InputDecoration(
                          icon: Icon(
                            Icons.book,
                            size: 30.0,
                          ),
                          labelText: 'Bio'),
                      validator: (input) => input.trim().length > 150
                          ? 'Please enter a bio less than 150 characters'
                          : null,
                      onSaved: (input) => _bio = input,
                    ),
                    TextFormField(
                      initialValue: _website,
                      style: kFontSize18TextStyle,
                      decoration: InputDecoration(
                          icon: Icon(
                            Icons.important_devices,
                            size: 30.0,
                          ),
                          labelText: 'Website'),
                      onSaved: (input) => _website = input,
                    ),
                    Container(
                      margin: const EdgeInsets.all(40.0),
                      height: 40.0,
                      width: 250.0,
                      child: FlatButton(
                        onPressed: _submit,
                        color: Colors.blue,
                        textColor: Colors.white,
                        child: Text(
                          'Save Profile',
                          style: kFontSize18TextStyle,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
