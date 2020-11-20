import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:instagram/screens/create_post_screen.dart';
import 'dart:ui' as ui;

import 'package:instagram/utilities/filters.dart';
import 'package:path_provider/path_provider.dart';

class EditPhotoScreen extends StatefulWidget {
  final File imageFile;
  EditPhotoScreen({@required this.imageFile});
  @override
  _EditPhotoScreenState createState() => _EditPhotoScreenState();
}

class _EditPhotoScreenState extends State<EditPhotoScreen> {
  final GlobalKey _globalKey = GlobalKey();

  int _selectedIndex = 0;

  void convertFilteredImageToImageFile() async {
    RenderRepaintBoundary repaintBoundary =
        _globalKey.currentContext.findRenderObject();
    ui.Image boxImage = await repaintBoundary.toImage(pixelRatio: 1);
    ByteData byteData =
        await boxImage.toByteData(format: ui.ImageByteFormat.png);
    String tempPath = (await getTemporaryDirectory()).path;
    File file = File('$tempPath/filteredImage.png');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    Navigator.of(_globalKey.currentContext).push(MaterialPageRoute(
        builder: (context) => CreatePostScreen(
              imageFile: file,
            )));
  }

  _buildFilterThumbnail(int index, Image image) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: _selectedIndex == index
                ? Theme.of(context).accentColor
                : Theme.of(context).primaryColor,
            width: 4),
      ),
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(filters[index].matrixValues),
        child: Container(
          height: 80,
          width: 80,
          child: image,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final Image image = Image.file(
      widget.imageFile,
      width: size.width,
      fit: BoxFit.cover,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Filter",
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.color,
        actions: [
          IconButton(
              icon: Icon(
                Icons.arrow_forward,
                color: Colors.blue,
              ),
              onPressed: convertFilteredImageToImageFile)
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          RepaintBoundary(
            key: _globalKey,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: size.width,
                maxHeight: size.width,
              ),
              child: ColorFiltered(
                colorFilter:
                    ColorFilter.matrix(filters[_selectedIndex].matrixValues),
                child: image,
              ),
              // child: PageView.builder(
              //     itemCount: filters.length,
              //     itemBuilder: (context, index) {
              //       return ColorFiltered(
              //         colorFilter: ColorFilter.matrix(filters[index]),
              //         child: image,
              //       );
              //     }),
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).backgroundColor,
              alignment: Alignment.center,
              child: Container(
                height: 130,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filters.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              _buildFilterThumbnail(index, image),
                              SizedBox(
                                height: 5.0,
                              ),
                              Text(
                                filters[index].name,
                              )
                            ],
                          ),
                        ),
                        onTap: () => setState(() => _selectedIndex = index),
                      );
                    }),
              ),
            ),
          )
        ],
      ),
    );
  }
}
