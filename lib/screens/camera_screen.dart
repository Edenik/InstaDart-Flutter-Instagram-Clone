import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/screens/screens.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Function backToHomeScreen;
  CameraScreen(this.cameras, this.backToHomeScreen);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  String imagePath;
  bool _toggleCamera = false;
  CameraController controller;
  final _picker = ImagePicker();
  CameraConsumer _cameraConsumer = CameraConsumer.post;

  @override
  void initState() {
    try {
      onCameraSelected(widget.cameras[0]);
    } catch (e) {
      print(e.toString());
    }
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cameras.isEmpty) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No Camera Found',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
      );
    }

    if (!controller.value.isInitialized) {
      return Container();
    }
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Center(
            child: Transform.scale(
              scale: controller.value.aspectRatio / deviceRatio,
              child: new AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: new CameraPreview(controller),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                topLeft: Radius.circular(15))),
                        onPressed: () => changeConsumer(CameraConsumer.post),
                        color: _cameraConsumer == CameraConsumer.post
                            ? Colors.black54
                            : Colors.grey.withOpacity(0.7),
                        child: Text(
                          'Post',
                          style: TextStyle(
                            fontSize: 18,
                            color: _cameraConsumer == CameraConsumer.post
                                ? Colors.white
                                : Colors.black,
                            fontWeight: _cameraConsumer == CameraConsumer.post
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(15),
                                topRight: Radius.circular(15))),
                        onPressed: () => changeConsumer(CameraConsumer.story),
                        color: _cameraConsumer == CameraConsumer.story
                            ? Colors.black54
                            : Colors.grey.withOpacity(0.7),
                        child: Text(
                          'Story',
                          style: TextStyle(
                            fontSize: 18,
                            color: _cameraConsumer == CameraConsumer.story
                                ? Colors.white
                                : Colors.black,
                            fontWeight: _cameraConsumer == CameraConsumer.story
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: widget.backToHomeScreen,
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
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: 120.0,
              padding: EdgeInsets.all(20.0),
              color: Colors.black45,
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                        onTap: () {
                          _captureImage();
                        },
                        child: Container(
                          padding: EdgeInsets.all(4.0),
                          child: Image.asset(
                            'assets/images/shutter.png',
                            width: 72.0,
                            height: 72.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                        onTap: () {
                          if (!_toggleCamera) {
                            onCameraSelected(widget.cameras[1]);
                            setState(() {
                              _toggleCamera = true;
                            });
                          } else {
                            onCameraSelected(widget.cameras[0]);
                            setState(() {
                              _toggleCamera = false;
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(4.0),
                          child: Image.asset(
                            'assets/images/switch_camera.png',
                            color: Colors.grey[200],
                            width: 42.0,
                            height: 42.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                        onTap: getGalleryImage,
                        child: Container(
                          padding: EdgeInsets.all(4.0),
                          child: Image.asset(
                            'assets/images/gallery_button.png',
                            color: Colors.grey[200],
                            width: 42.0,
                            height: 42.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void changeConsumer(CameraConsumer cameraConsumer) {
    if (_cameraConsumer != cameraConsumer) {
      setState(() => _cameraConsumer = cameraConsumer);
    }
  }

  void onCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) await controller.dispose();
    controller =
        CameraController(cameraDescription, ResolutionPreset.ultraHigh);

    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showMessage('Camera Error: ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      showException(e);
    }

    if (mounted) setState(() {});
  }

  String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();

  void _captureImage() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
        });
        if (filePath != null) {
          showMessage('Picture saved to $filePath');
          setCameraResult();
        }
      }
    });
  }

  void getGalleryImage() async {
    PickedFile pickedFile = await _picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
      setCameraResult();
    } else {
      print('No image selected.');
    }
  }

  void setCameraResult() async {
    if (_cameraConsumer == CameraConsumer.post) {
      File croppedImage = await _cropImage(File(imagePath));
      if (croppedImage == null) {
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => EditPhotoScreen(
                  imageFile: croppedImage,
                )
            //  CreatePostScreen(
            //   imageFile: croppedImage,
            // ),
            ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreateStoryScreen(File(imagePath)),
        ),
      );
    }
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showMessage('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/InstaDart/Images';
    await new Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      showException(e);
      return null;
    }
    return filePath;
  }

  _cropImage(File imageFile) async {
    File croppedImage = await ImageCropper.cropImage(
      androidUiSettings: AndroidUiSettings(
        backgroundColor: Theme.of(context).backgroundColor,
        toolbarColor: Theme.of(context).primaryColor,
        toolbarWidgetColor: Theme.of(context).accentColor,
        toolbarTitle: 'Crop Photo',
        activeControlsWidgetColor: Colors.white,
      ),
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
    );
    return croppedImage;
  }

  void showException(CameraException e) {
    logError(e.code, e.description);
    print('Error: ${e.code}\n${e.description}');
  }

  void showMessage(String message) {
    print(message);
  }

  void logError(String code, String message) =>
      print('Error: $code\nMessage: $message');
}
