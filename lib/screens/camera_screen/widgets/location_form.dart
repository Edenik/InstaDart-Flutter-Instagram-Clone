import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:instagram/services/core/location_service.dart';
import 'package:ionicons/ionicons.dart';

class LocationForm extends StatefulWidget {
  final TextEditingController controller;
  final Size screenSize;
  LocationForm({
    @required this.controller,
    @required this.screenSize,
  });
  @override
  _LocationFormState createState() => _LocationFormState();
}

class _LocationFormState extends State<LocationForm> {
  Address _address;
  Map<String, double> _currentLocation = Map();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() => _isLoading = true);
    //variables with location assigned as 0.0
    _currentLocation['latitude'] = 0.0;
    _currentLocation['longitude'] = 0.0;
    initPlatformState(); //method to call location
  }

  //method to get Location and save into variables
  void initPlatformState() async {
    Address first = await LocationService.getUserLocation();
    if (mounted) {
      setState(() {
        _address = first;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: Icon(
            Ionicons.location_sharp,
          ),
          title: Container(
            child: TextFormField(
              validator: (input) => input.trim().length > 30
                  ? 'Please enter a location less than 30 characters'
                  : null,
              maxLength: 30,
              controller: widget.controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: 'Where was this photo taken?',
                  border: InputBorder.none),
            ),
          ),
        ),
        Divider(),
        if (_address != null)
          Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 5.0, left: 5.0),
                child: Row(
                  children: <Widget>[
                    _buildLocationButton(_address.featureName),
                    _buildLocationButton(_address.subLocality),
                    _buildLocationButton(_address.locality),
                    _buildLocationButton(_address.subAdminArea),
                    _buildLocationButton(_address.adminArea),
                    _buildLocationButton(_address.countryName),
                  ],
                ),
              ),
              Divider()
            ],
          ),
        if (_isLoading)
          Column(
            children: [
              Container(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Center(
                      child: SizedBox(
                    child: CircularProgressIndicator(),
                    height: 20.0,
                    width: 20.0,
                  )),
                ),
              ),
              Divider()
            ],
          ),
      ],
    );
  }

  //method to build buttons with location.
  _buildLocationButton(String locationName) {
    if (locationName != null ?? locationName.isNotEmpty) {
      return InkWell(
        onTap: () {
          widget.controller.text = locationName;
        },
        child: Center(
          child: Container(
            //width: 100.0,
            height: 30.0,
            padding: EdgeInsets.only(left: 8.0, right: 8.0),
            margin: EdgeInsets.only(right: 3.0, left: 3.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Center(
              child: Text(
                locationName,
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
