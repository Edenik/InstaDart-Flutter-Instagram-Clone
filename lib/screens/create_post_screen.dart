import 'package:flutter/material.dart';
import 'package:instagram/widgets/default_appBar_widget.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(),
      body: Center(
        child: Text('Create Post Screen'),
      ),
    );
  }
}
