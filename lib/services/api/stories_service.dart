import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/utilities/constants.dart';

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
    final DateTime dateNow = DateTime.now();
    final Timestamp timeEnd = Timestamp.fromDate(DateTime(
      dateNow.year,
      dateNow.month,
      dateNow.day - 1,
      dateNow.hour,
      dateNow.minute,
      dateNow.second,
      dateNow.microsecond,
    ));
    QuerySnapshot snapshot;
    List<Story> userStories = [];

    if (checkDate) {
      snapshot = await storiesRef
          .document(userId)
          .collection('stories')
          .where('timeEnd', isGreaterThanOrEqualTo: timeEnd)
          .getDocuments();
    } else {
      snapshot = await storiesRef
          .document(userId)
          .collection('stories')
          .getDocuments();
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

  static void setNewStoryView(String currentUserId, Story story) async {
    final Timestamp timestamp = Timestamp.now();
    Map<dynamic, dynamic> storyViews = story.views;
    storyViews[currentUserId] = timestamp;

    DocumentSnapshot storySnapshot = await storiesRef
        .document(story.authorId)
        .collection('stories')
        .document(story.id)
        .get();

    Story storyFromDoc = Story.fromDoc(storySnapshot);

    if (!storyFromDoc.views.containsKey(currentUserId)) {
      await storiesRef
          .document(story.authorId)
          .collection('stories')
          .document(story.id)
          .updateData({'views': storyViews});
    }
  }
}
