// import 'dart:async';
import 'package:flutter/material.dart';
import 'package:instagram/utilities/themes.dart';
import 'package:instagram/common_widgets/instaDart_richText.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => new SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          new Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Developed with ♥ by:'),
              Padding(
                padding: EdgeInsets.only(bottom: 30.0, top: 10),
                child: GestureDetector(
                  onTap: () async {
                    const url = 'https://Edenik.com';
                    if (await canLaunch(url)) {
                      await launch(
                        url,
                        forceSafariVC: true,
                        forceWebView: true,
                        enableJavaScript: true,
                      );
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: Text(
                    'Edenik.Com',
                    style: kBillabongFamilyTextStyle.copyWith(fontSize: 45),
                  ),
                ),
              ),
            ],
          ),
          new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              InstaDartRichText(
                  kBillabongFamilyTextStyle.copyWith(fontSize: 70)),
              SizedBox(
                height: 50,
              ),
              Image.asset(
                'assets/images/instagram_logo.png',
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
