import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  final String id;
  final Timestamp timeEnd;
  final Timestamp timeStart;
  final String authorId;
  final String imageUrl;
  final String caption;
  final Map<String, Timestamp> views;
  final String location;
  final String filter;

  Story({
    this.id,
    this.timeStart,
    this.timeEnd,
    this.authorId,
    this.imageUrl,
    this.caption,
    this.views,
    this.location,
    this.filter,
  });

  factory Story.fromDoc(DocumentSnapshot doc) {
    return Story(
      id: doc.documentID,
      timeStart: doc['timeStart'],
      timeEnd: doc['timeEnd'],
      authorId: doc['authorId'],
      imageUrl: doc['imageUrl'],
      caption: doc['caption'],
      views: doc['views'],
      location: doc['location'],
      filter: doc['filter'],
    );
  }
}
