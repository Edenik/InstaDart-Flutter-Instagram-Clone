import 'package:flutter/material.dart';

class CustomTextForm extends StatelessWidget {
  final TextEditingController controller;
  final Size screenSize;
  final String hintText;
  final int maxLength;

  CustomTextForm({
    @required this.controller,
    @required this.screenSize,
    @required this.hintText,
    @required this.maxLength,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: screenSize.width - 20,
              child: TextFormField(
                validator: (input) => input.trim().length > maxLength
                    ? 'Please enter a $hintText less than $maxLength characters'
                    : null,
                maxLength: maxLength,
                controller: controller,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    hintText: 'Add a $hintText...',
                    border: InputBorder.none),
              ),
            ),
          ],
        ),
        Divider(),
      ],
    );
  }
}
