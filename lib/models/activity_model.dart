import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String fromUserId;
  final String postId;
  final String postImageUrl;
  final String comment;
  final bool isFollowEvent;
  final bool isLikeEvent;
  final bool isMessageEvent;
  final bool isCommentEvent;
  final bool isLikeMessageEvent;

  final String recieverToken;
  final Timestamp timestamp;

  Activity({
    this.id,
    this.fromUserId,
    this.postId,
    this.postImageUrl,
    this.comment,
    this.timestamp,
    this.isFollowEvent,
    this.isLikeEvent,
    this.isMessageEvent,
    this.isCommentEvent,
    this.isLikeMessageEvent,
    this.recieverToken,
  });

  factory Activity.fromDoc(DocumentSnapshot doc) {
    return Activity(
      id: doc.documentID,
      fromUserId: doc['fromUserId'],
      postId: doc['postId'],
      postImageUrl: doc['postImageUrl'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
      isFollowEvent: doc['isFollowEvent'] ?? false,
      isCommentEvent: doc['isCommentEvent'] ?? false,
      isLikeEvent: doc['isLikeEvent'] ?? false,
      isMessageEvent: doc['isMessageEvent'] ?? false,
      isLikeMessageEvent: doc['isMessageEvent'] ?? false,
      recieverToken: doc['receiverToken'] ?? '',
    );
  }
}
