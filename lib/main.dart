import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/screens/screens.dart';
import 'package:instagram/utilities/themes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((prefs) {
    var darkModeOn = prefs.getBool('darkMode') ?? false;

    //Set Navigation bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: darkModeOn ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness:
            darkModeOn ? Brightness.light : Brightness.dark));

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserData>(create: (context) => UserData()),
          ChangeNotifierProvider<ThemeNotifier>(
              create: (context) =>
                  ThemeNotifier(darkModeOn ? darkTheme : lightTheme))
        ],
        child: MyApp(),
      ),
    );
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isTimerDone = false;

  @override
  void initState() {
    Timer(Duration(seconds: 3), () => setState(() => _isTimerDone = true));
    super.initState();
  }

  Widget _getScreenId() {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !_isTimerDone) {
          return SplashScreen();
        }
        if (snapshot.hasData && _isTimerDone) {
          Provider.of<UserData>(context, listen: false).currentUserId =
              snapshot.data.uid;
          return HomeScreen(
            currentUserId: snapshot.data.uid,
          );
        } else {
          return LoginScreen();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      title: 'InstaDart',
      debugShowCheckedModeBanner: false,
      theme: themeNotifier.getTheme(),
      home: _getScreenId(),
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        SignupScreen.id: (context) => SignupScreen(),
        FeedScreen.id: (context) => FeedScreen(),
      },
    );
  }
}
