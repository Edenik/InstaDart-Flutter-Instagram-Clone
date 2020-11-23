import 'package:flutter/material.dart';

class CircularIconButton extends StatelessWidget {
  final Function onTap;
  final Widget icon;
  final double containerRadius;
  final EdgeInsets padding;
  final Color backColor;

  const CircularIconButton(
      {this.icon,
      this.onTap,
      this.containerRadius = 38,
      this.backColor = Colors.black45,
      this.padding = const EdgeInsets.all(0)});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: backColor,
            borderRadius: BorderRadius.circular(30),
          ),
          height: containerRadius,
          width: containerRadius,
          child: Center(
            child: icon,
          ),
        ),
      ),
    );
  }
}
