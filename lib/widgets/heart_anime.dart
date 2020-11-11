import 'package:animator/animator.dart';
import 'package:flutter/material.dart';

class HeartAnime extends StatelessWidget {
  final double size;
  HeartAnime(this.size);
  @override
  Widget build(BuildContext context) {
    return Animator(
      duration: Duration(milliseconds: 300),
      tween: Tween(begin: 0.5, end: 1.4),
      curve: Curves.elasticOut,
      builder: (context, anim, child) => Transform.scale(
        scale: anim.value,
        child: Icon(
          Icons.favorite,
          size: size,
          color: Colors.white54,
        ),
      ),
    );
  }
}
