import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  primaryColor: Colors.black,
  brightness: Brightness.dark,
  backgroundColor: Colors.black,
  appBarTheme: AppBarTheme(color: const Color(0xFF212121)),
  scaffoldBackgroundColor: Colors.black,
  accentColor: Colors.white,
  hintColor: Colors.white54,
  accentIconTheme: IconThemeData(color: Colors.black),
  dividerColor: Colors.white,
  iconTheme: IconThemeData(color: Colors.white),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.black,
    unselectedIconTheme: IconThemeData(color: Colors.white54),
    selectedIconTheme: IconThemeData(color: Colors.white),
  ),
  textSelectionColor: Colors.white54,
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(color: Colors.white),
    enabledBorder: UnderlineInputBorder(
      borderSide: new BorderSide(color: Colors.white38),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
    ),
  ),
  cardColor: Colors.grey[800],
);

final lightTheme = ThemeData(
  primaryColor: Colors.white,
  brightness: Brightness.light,
  backgroundColor: Colors.white,
  appBarTheme: AppBarTheme(color: Colors.white),
  scaffoldBackgroundColor: Colors.white,
  accentColor: Colors.black,
  hintColor: Colors.black54,
  accentIconTheme: IconThemeData(color: Colors.white),
  dividerColor: Colors.black54,
  iconTheme: IconThemeData(color: Colors.black),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    unselectedIconTheme: IconThemeData(color: Colors.black38),
    selectedIconTheme: IconThemeData(color: Colors.black),
  ),
  textSelectionColor: Colors.black38,
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(color: Colors.black),
    enabledBorder: UnderlineInputBorder(
      borderSide: new BorderSide(color: Colors.black45),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
    ),
  ),
  cardColor: Colors.grey[300],
);

const kFontWeightBoldTextStyle = TextStyle(fontWeight: FontWeight.bold);
const kFontColorBlackTextStyle = TextStyle(color: Colors.black);
const kFontColorRedTextStyle = TextStyle(color: Colors.red);
const kFontColorGreyTextStyle = TextStyle(color: Colors.grey);
const kFontColorBlack54TextStyle = TextStyle(color: Colors.black54);
const kFontSize18TextStyle = TextStyle(fontSize: 18.0);
const kFontColorWhiteSize18TextStyle =
    TextStyle(color: Colors.white, fontSize: 18.0);
const kFontSize18FontWeight600TextStyle =
    TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600);
const kBillabongFamilyTextStyle =
    TextStyle(fontSize: 35.0, fontFamily: 'Billabong');
TextStyle kHintColorStyle(BuildContext context) {
  return TextStyle(color: Theme.of(context).hintColor);
}

const kBlueColorTextStyle = TextStyle(color: Colors.blue);
final Color kBlueColorWithOpacity = Colors.blue.withOpacity(0.8);
