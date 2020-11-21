import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/services/database_service.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:provider/provider.dart';

class StoriesService {
  static Future<void> createStory(Story story) async {
    storiesRef.document(story.authorId).collection('stories').add({
      'timeStart': story.timeStart,
      'timeEnd': story.timeEnd,
      'authorId': story.authorId,
      'imageUrl': story.imageUrl,
      'caption': story.caption,
      'views': story.views,
      'location': story.location,
      'filter': story.filter,
    });
  }

  static Future<Story> getStoryById(String storyId) async {
    DocumentSnapshot storyDocSnapshot =
        await storiesRef.document(storyId).get();
    if (storyDocSnapshot.exists) {
      return Story.fromDoc(storyDocSnapshot);
    }
    return Story();
  }

  static Future<List<Story>> getStoriesByUserId(
      String userId, bool checkDate) async {
    final Timestamp timestamp = Timestamp.now();
    QuerySnapshot snapshot;
    List<Story> userStories = [];

    if (checkDate) {
      snapshot = await chatsRef
          .document(userId)
          .collection('stories')
          .where('timeStart', isLessThanOrEqualTo: timestamp)
          .where('timeEnd', isGreaterThanOrEqualTo: timestamp)
          .getDocuments();
    } else {
      snapshot =
          await chatsRef.document(userId).collection('stories').getDocuments();
    }

    if (snapshot.documents.isNotEmpty) {
      for (var doc in snapshot.documents) {
        Story story = Story.fromDoc(doc);
        userStories.add(story);
      }
      return userStories;
    }
    return null;
  }

  static void setNewStoryView(String currentUserId, Story story) {
    final Timestamp timestamp = Timestamp.now();
    Map<String, Timestamp> storyViews = story.views;
    storyViews[currentUserId] = timestamp;

    storiesRef
        .document(story.authorId)
        .collection('stories')
        .document(story.id)
        .updateData({'views': storyViews});
  }
}
