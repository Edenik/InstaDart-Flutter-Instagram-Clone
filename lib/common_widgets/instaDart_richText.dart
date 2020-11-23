import 'package:flutter/material.dart';

class InstaDartRichText extends StatelessWidget {
  final TextStyle textStyle;
  InstaDartRichText(this.textStyle);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
          text: 'Insta',
          style: textStyle.copyWith(color: Theme.of(context).accentColor),
          children: <TextSpan>[
            TextSpan(
                text: 'Dart', style: textStyle.copyWith(color: Colors.blue))
          ]),
    );
  }
}
