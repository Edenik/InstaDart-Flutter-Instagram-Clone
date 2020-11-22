import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/screens/screens.dart';
import 'package:instagram/services/services.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:instagram/utilities/custom_navigation.dart';
import 'package:instagram/utilities/filters.dart';
import 'package:path_provider/path_provider.dart';
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
  bool _isLoading = false;

  Address _address;
  TextEditingController _captionController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  Map<String, double> currentLocation = Map();
  String _caption = '';
  String _location = '';
  Size screenSize;

  @override
  void initState() {
    super.initState();
    //variables with location assigned as 0.0
    currentLocation['latitude'] = 0.0;
    currentLocation['longitude'] = 0.0;
    initPlatformState(); //method to call location
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  //method to get Location and save into variables
  void initPlatformState() async {
    Address first = await LocationService.getUserLocation();
    if (mounted) {
      setState(() {
        _address = first;
      });
    }
  }

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

  showEditStory() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
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
                SizedBox(height: 10),
                FlatButton(
                    onPressed: () {
                      setState(() {
                        _caption = _captionController.text.trim();
                        _location = _locationController.text.trim();
                      });
                      Navigator.pop(context);
                    },
                    color: Colors.blue,
                    child: Text('Save')),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          );
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
              width: screenSize.width - 20,
              child: TextField(
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

  void createStory(String currentUserId) async {
    if (!_isLoading && widget.imageFile != null) {
      setState(() => _isLoading = true);
      File imageFile = await convertFilteredImageToImageFile();
      String imageUrl = await StroageService.uploadStoryImage(imageFile);
      final DateTime dateNow = DateTime.now();
      final Timestamp timeStart = Timestamp.fromDate(dateNow);
      final Timestamp timeEnd = Timestamp.fromDate(DateTime(
        dateNow.year,
        dateNow.month,
        dateNow.day + 1,
        dateNow.hour,
        dateNow.minute,
        dateNow.second,
        dateNow.microsecond,
      ));

      Story story = Story(
        timeStart: timeStart,
        timeEnd: timeEnd,
        authorId: currentUserId,
        imageUrl: imageUrl,
        caption: _caption,
        views: {},
        location: _location,
        filter: _filterTitle,
      );

      await StoriesService.createStory(story);
      setState(() => _isLoading == false);

      CustomNavigation.navigateToHomeScreen(context, currentUserId);
    }
  }

  void _shareImageToMessages() async {
    File imageFile = await convertFilteredImageToImageFile();
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        context: context,
        builder: (context) {
          return DirectMessagesWidget(
            searchFrom: SearchFrom.createStoryScreen,
            imageFile: imageFile,
          );
        });
  }

  Future<File> convertFilteredImageToImageFile() async {
    RenderRepaintBoundary repaintBoundary =
        _globalKey.currentContext.findRenderObject();
    ui.Image boxImage = await repaintBoundary.toImage(pixelRatio: 1);
    ByteData byteData =
        await boxImage.toByteData(format: ui.ImageByteFormat.png);
    String tempPath = (await getTemporaryDirectory()).path;
    File file = File('$tempPath/${Timestamp.now().toString()}.png');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  @override
  Widget build(BuildContext context) {
    final User _currentUser = Provider.of<UserData>(context).currentUser;
    final Image image = Image.file(
      widget.imageFile,
      fit: BoxFit.cover,
    );
    setState(() {
      screenSize = MediaQuery.of(context).size;
    });

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
          if (_caption != '')
            Align(
              alignment:
                  Alignment.lerp(Alignment.center, Alignment.bottomCenter, 0.4),
              child: Text(
                _caption,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
            ),
          if (_location != '')
            Align(
              alignment:
                  Alignment.lerp(Alignment.center, Alignment.bottomCenter, 0.6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pin_drop,
                    size: 20,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    _location,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ],
              ),
            ),
          if (_isLoading)
            Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            ),
          if (!_isLoading)
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
                    _selectedIndex != 0 || _location != '' || _caption != ''
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                _caption = '';
                                _location = '';
                              });
                              _locationController.clear();
                              _captionController.clear();
                              _pageController.jumpToPage(0);
                            },
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
                    GestureDetector(
                      onTap: () => showEditStory(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        height: 34,
                        width: 34,
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          if (!_isLoading)
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    onPressed: () => createStory(_currentUser.id),
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
                          width: 10.0,
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
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    onPressed: () => _shareImageToMessages(),
                    color: Theme.of(context).primaryColor.withOpacity(0.8),
                    child: Text(
                      'Share to..',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}
