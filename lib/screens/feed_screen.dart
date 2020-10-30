import 'package:flutter/material.dart';
import 'package:instagram/services/services.dart';

class FeedScreen extends StatefulWidget {
  static final String id = 'feed_screen';
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: FlatButton(
          onPressed: () => AuthService.logout(),
          child: Text('LOGOUT'),
        ),
      ),
    );
  }
}
