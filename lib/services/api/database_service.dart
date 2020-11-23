import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/utilities/constants.dart';

class DatabaseService {
  static void updateUser(User user) {
    usersRef.document(user.id).updateData({
      'name': user.name,
      'profileImageUrl': user.profileImageUrl,
      'bio': user.bio,
      'website': user.website,
    });
  }

  static Future<QuerySnapshot> searchUsers(String name) {
    Future<QuerySnapshot> users =
        usersRef.where('name', isGreaterThanOrEqualTo: name).getDocuments();
    return users;
  }

  static void createPost(Post post) {
    try {
      postsRef.document(post.authorId).collection('userPosts').add({
        'imageUrl': post.imageUrl,
        'caption': post.caption,
        'likeCount': post.likeCount,
        'authorId': post.authorId,
        'location': post.location,
        'timestamp': post.timestamp
      });
    } catch (e) {
      print(e);
    }
  }

  static void editPost(
    Post post,
    PostStatus postStatus,
  ) {
    String collection;
    if (postStatus == PostStatus.archivedPost) {
      collection = 'archivedPosts';
    } else if (postStatus == PostStatus.feedPost) {
      collection = 'userPosts';
    } else {
      collection = 'deletedPosts';
    }

    postsRef
        .document(post.authorId)
        .collection(collection)
        .document(post.id)
        .updateData({
      'caption': post.caption,
      'location': post.location,
    });
  }

  static void allowDisAllowPostComments(Post post, bool commentsAllowed) {
    try {
      postsRef
          .document(post.authorId)
          .collection('userPosts')
          .document(post.id)
          .updateData({
        'commentsAllowed': commentsAllowed,
      });
    } catch (e) {
      print(e);
    }
  }

  static void deletePost(Post post, PostStatus postStatus) {
    postsRef
        .document(post.authorId)
        .collection('deletedPosts')
        .document(post.id)
        .setData({
      'imageUrl': post.imageUrl,
      'caption': post.caption,
      'likeCount': post.likeCount,
      'authorId': post.authorId,
      'location': post.location,
      'timestamp': post.timestamp
    });
    String collection;
    postStatus == PostStatus.feedPost
        ? collection = 'userPosts'
        : collection = 'archivedPosts';
    postsRef
        .document(post.authorId)
        .collection(collection)
        .document(post.id)
        .delete();
  }

  static void archivePost(Post post, PostStatus postStatus) {
    postsRef
        .document(post.authorId)
        .collection('archivedPosts')
        .document(post.id)
        .setData({
      'imageUrl': post.imageUrl,
      'caption': post.caption,
      'likeCount': post.likeCount,
      'authorId': post.authorId,
      'location': post.location,
      'timestamp': post.timestamp
    });
    String collection;
    postStatus == PostStatus.feedPost
        ? collection = 'userPosts'
        : collection = 'deletedPosts';

    postsRef
        .document(post.authorId)
        .collection(collection)
        .document(post.id)
        .delete();
  }

  static void recreatePost(Post post, PostStatus postStatus) {
    try {
      postsRef
          .document(post.authorId)
          .collection('userPosts')
          .document(post.id)
          .setData({
        'imageUrl': post.imageUrl,
        'caption': post.caption,
        'likeCount': post.likeCount,
        'authorId': post.authorId,
        'location': post.location,
        'timestamp': post.timestamp
      });

      String collection;
      postStatus == PostStatus.archivedPost
          ? collection = 'archivedPosts'
          : collection = 'deletedPosts';

      postsRef
          .document(post.authorId)
          .collection(collection)
          .document(post.id)
          .delete();
    } catch (e) {
      print(e);
    }
  }

  static void followUser(
      {String currentUserId, String userId, String receiverToken}) {
    // Add user to current user's following collection
    followingRef
        .document(currentUserId)
        .collection(userFollowing)
        .document(userId)
        .setData({'timestamp': Timestamp.fromDate(DateTime.now())});

    // Add current user to user's followers collection
    followersRef
        .document(userId)
        .collection(usersFollowers)
        .document(currentUserId)
        .setData({'timestamp': Timestamp.fromDate(DateTime.now())});

    Post post = Post(
      authorId: userId,
    );

    addActivityItem(
      comment: null,
      currentUserId: currentUserId,
      isFollowEvent: true,
      post: post,
      isCommentEvent: false,
      isLikeEvent: false,
      isLikeMessageEvent: false,
      isMessageEvent: false,
      recieverToken: receiverToken,
    );
  }

  static void unfollowUser({String currentUserId, String userId}) {
    // Remove user from current user's following collection
    followingRef
        .document(currentUserId)
        .collection(userFollowing)
        .document(userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    // Remove current user from user's followers collection
    followersRef
        .document(userId)
        .collection(usersFollowers)
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    Post post = Post(
      authorId: userId,
    );

    deleteActivityItem(
      comment: null,
      currentUserId: currentUserId,
      isFollowEvent: true,
      post: post,
      isCommentEvent: false,
      isLikeEvent: false,
      isLikeMessageEvent: false,
      isMessageEvent: false,
    );
  }

  static Future<bool> isFollowingUser(
      {String currentUserId, String userId}) async {
    DocumentSnapshot followingDoc = await followersRef
        .document(userId)
        .collection(usersFollowers)
        .document(currentUserId)
        .get();

    return followingDoc.exists;
  }

  static Future<int> numFollowing(String userId) async {
    QuerySnapshot followingSnapshot = await followingRef
        .document(userId)
        .collection(userFollowing)
        .getDocuments();
    return followingSnapshot.documents.length;
  }

  static Future<int> numFollowers(String userId) async {
    QuerySnapshot followersSnapshot = await followersRef
        .document(userId)
        .collection(usersFollowers)
        .getDocuments();

    return followersSnapshot.documents.length;
  }

  static Future<List<String>> getUserFollowingIds(String userId) async {
    QuerySnapshot followingSnapshot = await followingRef
        .document(userId)
        .collection(userFollowing)
        .getDocuments();

    List<String> following =
        followingSnapshot.documents.map((doc) => doc.documentID).toList();
    return following;
  }

  static Future<List<User>> getUserFollowingUsers(String userId) async {
    List<String> followingUserIds = await getUserFollowingIds(userId);
    List<User> followingUsers = [];

    for (var userId in followingUserIds) {
      DocumentSnapshot userSnapshot = await usersRef.document(userId).get();
      User user = User.fromDoc(userSnapshot);
      followingUsers.add(user);
    }

    return followingUsers;
  }

  static Future<List<String>> getUserFollowersIds(String userId) async {
    QuerySnapshot followersSnapshot = await followersRef
        .document(userId)
        .collection(usersFollowers)
        .getDocuments();

    List<String> followers =
        followersSnapshot.documents.map((doc) => doc.documentID).toList();
    return followers;
  }

  static Future<List<Post>> getFeedPosts(String userId) async {
    QuerySnapshot feedSnapshot = await feedsRef
        .document(userId)
        .collection('userFeed')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List<Post> posts =
        feedSnapshot.documents.map((doc) => Post.fromDoc(doc)).toList();
    return posts;
  }

  static Future<List<Post>> getAllFeedPosts() async {
    List<Post> allPosts = [];

    QuerySnapshot usersSnapshot = await usersRef.getDocuments();

    for (var userDoc in usersSnapshot.documents) {
      QuerySnapshot feedSnapshot = await postsRef
          .document(userDoc.documentID)
          .collection('userPosts')
          .orderBy('timestamp', descending: true)
          .getDocuments();

      for (var postDoc in feedSnapshot.documents) {
        Post post = Post.fromDoc(postDoc);
        allPosts.add(post);
      }
    }
    return allPosts;
  }

  static Future<List<Post>> getDeletedPosts(
      String userId, PostStatus postStatus) async {
    String collection;
    postStatus == PostStatus.archivedPost
        ? collection = 'archivedPosts'
        : collection = 'deletedPosts';

    QuerySnapshot feedSnapshot = await postsRef
        .document(userId)
        .collection(collection)
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List<Post> posts =
        feedSnapshot.documents.map((doc) => Post.fromDoc(doc)).toList();
    return posts;
  }

  static Future<List<Post>> getUserPosts(String userId) async {
    QuerySnapshot userPostsSnapshot = await postsRef
        .document(userId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List<Post> posts =
        userPostsSnapshot.documents.map((doc) => Post.fromDoc(doc)).toList();
    return posts;
  }

  static Future<User> getUserWithId(String userId) async {
    DocumentSnapshot userDocSnapshot = await usersRef.document(userId).get();
    if (userDocSnapshot.exists) {
      return User.fromDoc(userDocSnapshot);
    }
    return User();
  }

  static void likePost(
      {String currentUserId, Post post, String receiverToken}) {
    DocumentReference postRef = postsRef
        .document(post.authorId)
        .collection('userPosts')
        .document(post.id);
    postRef.get().then((doc) {
      int likeCount = doc.data['likeCount'];
      postRef.updateData({'likeCount': likeCount + 1});
      likesRef
          .document(post.id)
          .collection('postLikes')
          .document(currentUserId)
          .setData({});
    });

    addActivityItem(
      currentUserId: currentUserId,
      post: post,
      comment: post.caption ?? null,
      isFollowEvent: false,
      isLikeMessageEvent: false,
      isLikeEvent: true,
      isCommentEvent: false,
      isMessageEvent: false,
      recieverToken: receiverToken,
    );
  }

  static void unlikePost({String currentUserId, Post post}) {
    DocumentReference postRef = postsRef
        .document(post.authorId)
        .collection('userPosts')
        .document(post.id);
    postRef.get().then((doc) {
      int likeCount = doc.data['likeCount'];
      postRef.updateData({'likeCount': likeCount + -1});
      likesRef
          .document(post.id)
          .collection('postLikes')
          .document(currentUserId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    });

    deleteActivityItem(
      comment: null,
      currentUserId: currentUserId,
      isFollowEvent: false,
      post: post,
      isCommentEvent: false,
      isLikeMessageEvent: false,
      isLikeEvent: true,
      isMessageEvent: false,
    );
  }

  static Future<bool> didLikePost({String currentUserId, Post post}) async {
    DocumentSnapshot userDoc = await likesRef
        .document(post.id)
        .collection('postLikes')
        .document(currentUserId)
        .get();
    return userDoc.exists;
  }

  static void commentOnPost(
      {String currentUserId, Post post, String comment, String recieverToken}) {
    commentsRef.document(post.id).collection('postComments').add({
      'content': comment,
      'authorId': currentUserId,
      'timestamp': Timestamp.fromDate(DateTime.now())
    });
    addActivityItem(
      currentUserId: currentUserId,
      post: post,
      comment: comment,
      isFollowEvent: false,
      isLikeMessageEvent: false,
      isCommentEvent: true,
      isLikeEvent: false,
      isMessageEvent: false,
      recieverToken: recieverToken,
    );
  }

  static void addActivityItem({
    String currentUserId,
    Post post,
    String comment,
    bool isFollowEvent,
    bool isCommentEvent,
    bool isLikeEvent,
    bool isMessageEvent,
    bool isLikeMessageEvent,
    String recieverToken,
  }) {
    if (currentUserId != post.authorId) {
      activitiesRef.document(post.authorId).collection('userActivities').add({
        'fromUserId': currentUserId,
        'postId': post.id,
        'postImageUrl': post.imageUrl,
        'comment': comment,
        'timestamp': Timestamp.fromDate(DateTime.now()),
        'isFollowEvent': isFollowEvent,
        'isCommentEvent': isCommentEvent,
        'isLikeEvent': isLikeEvent,
        'isMessageEvent': isMessageEvent,
        'isLikeMessageEvent': isLikeMessageEvent,
        'recieverToken': recieverToken,
      });
    }
  }

  static void deleteActivityItem(
      {String currentUserId,
      Post post,
      String comment,
      bool isFollowEvent,
      bool isCommentEvent,
      bool isLikeEvent,
      bool isMessageEvent,
      bool isLikeMessageEvent}) async {
    String boolCondition;

    if (isFollowEvent) {
      boolCondition = 'isFollowEvent';
    } else if (isCommentEvent) {
      boolCondition = 'isCommentEvent';
    } else if (isLikeEvent) {
      boolCondition = 'isLikeEvent';
    } else if (isMessageEvent) {
      boolCondition = 'isMessageEvent';
    } else if (isLikeMessageEvent) {
      boolCondition = 'isLikeMessageEvent';
    }

    QuerySnapshot activities = await activitiesRef
        .document(post.authorId)
        .collection('userActivities')
        .where('fromUserId', isEqualTo: currentUserId)
        .where('postId', isEqualTo: post.id)
        .where(boolCondition, isEqualTo: true)
        .getDocuments();

    activities.documents.forEach((element) {
      activitiesRef
          .document(post.authorId)
          .collection('userActivities')
          .document(element.documentID)
          .delete();
    });
  }

  static Future<List<Activity>> getActivities(String userId) async {
    QuerySnapshot userActivitiesSnapshot = await activitiesRef
        .document(userId)
        .collection('userActivities')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List<Activity> activity = userActivitiesSnapshot.documents
        .map((doc) => Activity.fromDoc(doc))
        .toList();
    return activity;
  }

  static Future<Post> getUserPost(String userId, String postId) async {
    DocumentSnapshot postDocSnapshot = await postsRef
        .document(userId)
        .collection('userPosts')
        .document(postId)
        .get();
    return Post.fromDoc(postDocSnapshot);
  }
}
