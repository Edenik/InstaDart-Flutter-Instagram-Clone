import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:provider/provider.dart';

import 'package:instagram/models/models.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final Firestore _firestore = Firestore.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging();

  static Future<void> signUpUser(
      BuildContext context, String name, String email, String password) async {
    try {
      AuthResult authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      FirebaseUser signedInUser = authResult.user;
      if (signedInUser != null) {
        String token = await _messaging.getToken();
        _firestore.collection('/users').document(signedInUser.uid).setData({
          'name': name,
          'email': email,
          'profileImageUrl': '',
          'token': token,
          'isVerified': false,
          'role': 'user',
          'timeCreated': Timestamp.now(),
        });
      }
      Provider.of<UserData>(context, listen: false).currentUserId =
          signedInUser.uid;

      Navigator.pop(context);
    } on PlatformException catch (err) {
      throw (err);
    }
  }

  static Future<void> signUp(
      BuildContext context, String email, String password) async {
    try {
      AuthResult authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      FirebaseUser signedInUser = authResult.user;
    } on PlatformException catch (err) {
      throw (err);
    }
  }

  static Future<void> loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on PlatformException catch (err) {
      throw (err);
    }
  }

  static Future<void> removeToken() async {
    final currentUser = await _auth.currentUser();
    await usersRef
        .document(currentUser.uid)
        .setData({'token': ''}, merge: true);
  }

  static Future<void> updateToken() async {
    final currentUser = await _auth.currentUser();
    final token = await _messaging.getToken();
    final userDoc = await usersRef.document(currentUser.uid).get();
    if (userDoc.exists) {
      User user = User.fromDoc(userDoc);
      if (token != user.token) {
        usersRef
            .document(currentUser.uid)
            .setData({'token': token}, merge: true);
      }
    }
  }

  static Future<void> updateTokenWithUser(User user) async {
    final token = await _messaging.getToken();
    if (token != user.token) {
      await usersRef.document(user.id).updateData({'token': token});
    }
  }

  static Future<void> logout() async {
    await removeToken();
    Future.wait([
      _auth.signOut(),
    ]);
  }
}
