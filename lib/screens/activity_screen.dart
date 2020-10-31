import 'package:flutter/material.dart';
import 'package:instagram/widgets/default_appBar_widget.dart';

class ActivityScreen extends StatefulWidget {
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(),
      body: Center(
        child: Text('Activity Screen'),
      ),
    );
  }
}
