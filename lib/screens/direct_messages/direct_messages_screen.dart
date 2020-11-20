import 'package:flutter/material.dart';
import 'package:instagram/screens/screens.dart';
import 'package:instagram/utilities/constants.dart';

class DirectMessagesScreen extends StatefulWidget {
  final Function backToHomeScreen;
  DirectMessagesScreen(this.backToHomeScreen);
  @override
  _DirectMessagesScreenState createState() => _DirectMessagesScreenState();
}

class _DirectMessagesScreenState extends State<DirectMessagesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: widget.backToHomeScreen,
        ),
        title: Text('Direct'),
      ),
      body: DirectMessagesWidget(
        searchFrom: SearchFrom.messagesScreen,
      ),
    );
  }
}
