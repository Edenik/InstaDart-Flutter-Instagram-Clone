import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/models/models.dart';

class Chat {
  final String id;
  final String recentMessage;
  final String recentSender;
  final Timestamp recentTimestamp;
  final List<dynamic> memberIds;
  final List<User> memberInfo;
  final dynamic readStatus;

  Chat({
    this.id,
    this.recentMessage,
    this.recentSender,
    this.recentTimestamp,
    this.memberIds,
    this.memberInfo,
    this.readStatus,
  });

  factory Chat.fromDoc(DocumentSnapshot doc) {
    return Chat(
      id: doc.documentID,
      recentMessage: doc['recentMessage'],
      recentSender: doc['recentSender'],
      recentTimestamp: doc['recentTimestamp'],
      memberIds: doc['memberIds'],
      readStatus: doc['readStatus'],
    );
  }
}
