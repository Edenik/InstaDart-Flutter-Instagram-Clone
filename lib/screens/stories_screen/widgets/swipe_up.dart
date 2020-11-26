import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class SwipeUp extends StatefulWidget {
  final Function onSwipeUp;
  SwipeUp({@required this.onSwipeUp, Key key}) : super(key: key);
  @override
  _SwipeUpState createState() => _SwipeUpState();
}

class _SwipeUpState extends State<SwipeUp> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCirc,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onSwipeUp,
      child: Column(
        children: <Widget>[
          ScaleTransition(
            scale: _animation,
            child: Icon(
              Ionicons.arrow_up_sharp,
              color: Colors.white,
              size: 50,
            ),
          ),
          Chip(
            backgroundColor: Colors.black26,
            label: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(
                'Swipe Up',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
