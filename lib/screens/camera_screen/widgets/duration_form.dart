import 'package:flutter/material.dart';
import 'package:instagram/models/user_model.dart';

class DurationForm extends StatefulWidget {
  final Function onChange;
  final Size screenSize;
  final int duration;
  final User currentUser;

  DurationForm(
      {@required this.screenSize,
      @required this.onChange,
      @required this.duration,
      @required this.currentUser});
  @override
  _DurationFormState createState() => _DurationFormState();
}

class _DurationFormState extends State<DurationForm> {
  double _currentSliderValue;
  double _maxValue = 10;

  double _minValue = 5;

  @override
  void initState() {
    super.initState();

    // if current user is admin
    if (widget.currentUser.role == 'admin') setState(() => _maxValue = 15);
    _currentSliderValue = widget.duration.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Duration '),
            Text(
              '${_currentSliderValue.toInt()} sec',
              style: TextStyle(
                  color: Theme.of(context).accentColor.withOpacity(0.5)),
            )
          ],
        ),
        Row(
          children: [
            Text(_minValue.round().toString()),
            Expanded(
              child: Slider(
                value: _currentSliderValue,
                min: _minValue,
                max: _maxValue,
                divisions: 5,
                label: _currentSliderValue.round().toString(),
                onChanged: (double value) {
                  widget.onChange(value);
                  setState(() {
                    _currentSliderValue = value;
                  });
                },
              ),
            ),
            Text(_maxValue.round().toString()),
          ],
        )
      ],
    );
  }
}
