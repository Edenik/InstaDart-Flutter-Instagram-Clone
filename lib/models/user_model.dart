import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String profileImageUrl;
  final String email;
  final String bio;
  final String token;
  final bool isBanned;
  // final List<String> favoritePosts;
  // final List<String> blockedUsers;
  // final List<String> hideStoryFromUsers;
  // final List<String> closeFriends;
  // final bool allowStoryMessageReplies;
  final String role;
  final bool isVerified;
  final String website;
  final Timestamp timeCreated;

  User({
    this.id,
    this.name,
    this.profileImageUrl,
    this.email,
    this.bio,
    this.token,
    this.isBanned,
    this.isVerified,
    this.website,
    this.role,
    this.timeCreated,
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
      isBanned: doc['isBanned'],
      website: doc['website'] ?? '',
      role: doc['role'] ?? 'user',
      timeCreated: doc['timeCreated'],
    );
  }
}
