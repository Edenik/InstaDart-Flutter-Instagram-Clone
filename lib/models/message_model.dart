import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String text;
  final String imageUrl;
  final String giphyUrl;
  final Timestamp timestamp;
  final bool isLiked;

  Message(
      {this.id,
      this.senderId,
      this.text,
      this.imageUrl,
      this.timestamp,
      this.giphyUrl,
      this.isLiked});

  factory Message.fromDoc(DocumentSnapshot doc) {
    return Message(
      id: doc.documentID,
      senderId: doc['senderId'],
      text: doc['text'],
      imageUrl: doc['imageUrl'],
      timestamp: doc['timestamp'],
      isLiked: doc['isLiked'],
      giphyUrl: doc['giphyUrl'] ?? "",
    );
  }
}
