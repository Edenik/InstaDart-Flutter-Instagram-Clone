import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram/screens/screens.dart';
import 'package:instagram/services/services.dart';
import 'package:instagram/utilities/themes.dart';
import 'package:instagram/common_widgets/instaDart_richText.dart';

class LoginScreen extends StatefulWidget {
  static final String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email, _password;
  bool _isLoading = false;

  _submit() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      _formKey.currentState.save();
      //Logging the user
      try {
        await AuthService.loginUser(_email.trim(), _password.trim());
      } on PlatformException catch (err) {
        _showErrorDialog(err.message);
        setState(() {
          _isLoading = false;
        });
        throw (err);
      }
    }
  }

  _showErrorDialog(String errorMessage) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(errorMessage),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                InstaDartRichText(
                    kBillabongFamilyTextStyle.copyWith(fontSize: 50.0)),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 10.0),
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Email'),
                          validator: (input) => !input.contains('@')
                              ? 'Please enter a valid email'
                              : null,
                          onSaved: (input) => _email = input,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 10.0),
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (input) => input.length < 6
                              ? 'Password must be at least 6 characters'
                              : null,
                          onSaved: (input) => _password = input,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      if (_isLoading) CircularProgressIndicator(),
                      if (!_isLoading)
                        Container(
                          width: 250.0,
                          child: FlatButton(
                            onPressed: _submit,
                            color: Colors.blue,
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              'Login',
                              style: kFontColorWhiteSize18TextStyle,
                            ),
                          ),
                        ),
                      SizedBox(height: 20.0),
                      if (!_isLoading)
                        Container(
                          width: 250.0,
                          child: FlatButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, SignupScreen.id),
                            color: Colors.blue,
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              'Go to Signup',
                              style: kFontColorWhiteSize18TextStyle,
                            ),
                          ),
                        )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
