import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PostCaptionForm extends StatefulWidget {
  final File imageFile;
  final String imageUrl;
  final TextEditingController controller;
  final Size screenSize;
  final Function onChanged;
  PostCaptionForm({
    @required this.imageFile,
    @required this.imageUrl,
    @required this.controller,
    @required this.screenSize,
    @required this.onChanged,
  });
  @override
  _PostCaptionFormState createState() => _PostCaptionFormState();
}

class _PostCaptionFormState extends State<PostCaptionForm> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15.0),
          height: 45.0,
          width: 45.0,
          child: AspectRatio(
            aspectRatio: 487 / 451,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  alignment: FractionalOffset.topCenter,
                  image: widget.imageFile == null
                      ? CachedNetworkImageProvider(widget.imageUrl)
                      : FileImage(widget.imageFile),
                ),
              ),
            ),
          ),
        ),
        Container(
          width: widget.screenSize.width - 92,
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TextFormField(
              onChanged: (value) => widget.onChanged(value),
              validator: (input) => input.trim().length > 150
                  ? 'Please enter a caption less than 150 characters'
                  : input.trim().length < 3
                      ? 'Please enter a caption more than 3 characters'
                      : null,
              maxLength: 150,
              controller: widget.controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: 'Write a caption...',
                  border: InputBorder.none),
            ),
          ),
        ),
      ],
    );
  }
}
