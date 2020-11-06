import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String imageUrl;
  final String caption;
  final int likeCount;
  final String authorId;
  final String location;
  final Timestamp timestamp;
  final bool commentsAllowed;

  Post({
    this.id,
    this.imageUrl,
    this.caption,
    this.likeCount,
    this.authorId,
    this.location,
    this.timestamp,
    this.commentsAllowed,
  });

  factory Post.fromDoc(DocumentSnapshot doc) {
    return Post(
      id: doc.documentID,
      imageUrl: doc['imageUrl'],
      caption: doc['caption'],
      likeCount: doc['likeCount'],
      authorId: doc['authorId'],
      location: doc['location'] ?? "",
      timestamp: doc['timestamp'],
      commentsAllowed: doc['commentsAllowed'] ?? true,
    );
  }
}
