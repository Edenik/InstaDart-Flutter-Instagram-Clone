import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String profileImageUrl;
  final String email;
  final String bio;
  final String token;
  // final List<String> favoritePosts;
  // final List<String> blockedUsers;
  // final List<String> hideStoryFromUsers;
  // final List<String> closeFriends;
  // final bool allowStoryMessageReplies;
  // final String role;
  final bool isVerified;
  final String website;

  User({
    this.id,
    this.name,
    this.profileImageUrl,
    this.email,
    this.bio,
    this.token,
    this.isVerified,
    this.website,
  });

  factory User.fromDoc(DocumentSnapshot doc) {
    return User(
      id: doc.documentID,
      name: doc['name'],
      profileImageUrl: doc['profileImageUrl'],
      email: doc['email'],
      bio: doc['bio'] ?? '',
      token: doc['token'] ?? '',
      isVerified: doc['isVerified'] ?? false,
      website: doc['website'] ?? '',
    );
  }
}
