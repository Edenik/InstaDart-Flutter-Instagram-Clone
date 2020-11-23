import 'package:flutter/material.dart';

class CircularIconButton extends StatelessWidget {
  final Function onTap;
  final Widget icon;
  final double containerRadius;
  final EdgeInsets padding;
  final Color backColor;
  final Color splashColor;

  const CircularIconButton(
      {this.icon,
      this.onTap,
      this.containerRadius = 36,
      this.backColor = Colors.black45,
      this.splashColor = Colors.blue,
      this.padding = const EdgeInsets.all(0)});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: InkWell(
        onTap: onTap,
        child: ClipOval(
          child: Material(
            color: backColor, // button color
            child: InkWell(
              splashColor: backColor == Colors.blue
                  ? backColor
                  : splashColor, // inkwell color
              child: SizedBox(
                  width: containerRadius, height: containerRadius, child: icon),
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }
}
