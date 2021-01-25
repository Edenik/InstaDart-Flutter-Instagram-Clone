const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp(functions.config().firebase);

exports.onFollowUser = functions.firestore
  .document("/followers/{userId}/userFollowers/{followerId}")
  .onCreate(async (snapshot, context) => {
    const userId = context.params.userId;
    const followerId = context.params.followerId;

    // Followed User posts
    const followedUserPostsRef = admin
      .firestore()
      .collection("posts")
      .doc(userId)
      .collection("userPosts");

    // Current User feed
    const userFeedRef = admin
      .firestore()
      .collection("feeds")
      .doc(followerId)
      .collection("userFeed");

    // Get all posts from followed user
    const followedUserPostsSnapshot = await followedUserPostsRef.get();
    followedUserPostsSnapshot.forEach((doc) => {
      if (doc.exists) {
        // Add followed user posts to current user feed
        userFeedRef.doc(doc.id).set(doc.data());
      }
    });
  });

exports.onUnfollowUser = functions.firestore
  .document("/followers/{userId}/userFollowers/{followerId}")
  .onDelete(async (snapshot, context) => {
    const userId = context.params.userId;
    const followerId = context.params.followerId;

    // All posts from unfollowed user in current user feed
    const userFeedRef = admin
      .firestore()
      .collection("feeds")
      .doc(followerId)
      .collection("userFeed")
      .where("authorId", "==", userId);

    // Get all posts unfollowed user
    const userPostsSnapshot = await userFeedRef.get();
    userPostsSnapshot.forEach((doc) => {
      if (doc.exists) {
        // Delete each unfollowed user post from current user feed
        doc.ref.delete();
      }
    });
  });

exports.onUploadPost = functions.firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onCreate(async (snapshot, context) => {
    const userId = context.params.userId;
    const postId = context.params.postId;

    // All the current user followers
    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");

    // Get current user followers
    const userFollowersSnapshot = await userFollowersRef.get();

    userFollowersSnapshot.forEach((doc) => {
      // Uploading post to followers feed
      admin
        .firestore()
        .collection("feeds")
        .doc(doc.id)
        .collection("userFeed")
        .doc(postId)
        .set(snapshot.data());
    });

    // Uploading post to author feed
    admin
      .firestore()
      .collection("feeds")
      .doc(userId)
      .collection("userFeed")
      .doc(postId)
      .set(snapshot.data());
  });

exports.onUpdatePost = functions.firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onUpdate(async (snapshot, context) => {
    const userId = context.params.userId;
    const postId = context.params.postId;
    const newPostData = snapshot.after.data();

    // All the current user followers
    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");

    // Get current user followers
    const userFollowersSnapshot = await userFollowersRef.get();

    userFollowersSnapshot.forEach(async (userDoc) => {
      // Updating post to current user followers feed
      const postRef = admin
        .firestore()
        .collection("feeds")
        .doc(userDoc.id)
        .collection("userFeed");
      const postDoc = await postRef.doc(postId).get();
      if (postDoc.exists) {
        postDoc.ref.update(newPostData);
      }
    });

    // Updating post to author feed
    const postRef = admin
      .firestore()
      .collection("feeds")
      .doc(userId)
      .collection("userFeed");
    const postDoc = await postRef.doc(postId).get();
    if (postDoc.exists) {
      postDoc.ref.update(newPostData);
    }
  });

exports.onDeletePost = functions.firestore
  .document("/posts/{authorId}/userPosts/{postId}")
  .onDelete(async (snapshot, context) => {
    const postId = context.params.postId;
    const authorId = context.params.authorId;

    /* Deleting post from followers feeds*/
    const authorFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(authorId)
      .collection("userFollowers");

    //Get author followers
    const authorFollowersSnapshot = await authorFollowersRef.get();

    authorFollowersSnapshot.docs.forEach(async (userDoc) => {
      const postRef = admin
        .firestore()
        .collection("feeds")
        .doc(userDoc.id)
        .collection("userFeed");
      // Delete post for each follower feed
      await postRef.doc(postId).delete();
    });
    /* End of Deleting post from followers feeds */

    /* Deleting post from author feed */
    const authorFeedRef = admin
      .firestore()
      .collection("feeds")
      .doc(authorId)
      .collection("userFeed");

    authorFeedRef.doc(postId).delete();
    /* End of Deleting post from author feed */
  });

exports.addChatMessage = functions.firestore
  .document("/chats/{chatId}/messages/{messageId}")
  .onCreate(async (snapshot, context) => {
    const chatId = context.params.chatId;
    const messageData = snapshot.data();

    const chatRef = admin.firestore().collection("chats").doc(chatId);
    // Get chat document
    const chatDoc = await chatRef.get();
    const chatData = chatDoc.data();

    if (chatDoc.exists) {
      // Update read status to false
      const readStatus = chatData.readStatus;
      for (let userId in readStatus) {
        if (
          readStatus.hasOwnProperty(userId) &&
          userId !== messageData.senderId
        ) {
          readStatus[userId] = false;
        }
      }
      // Update the chat doc
      chatRef.update({
        recentMessage: messageData.text,
        recentSender: messageData.senderId,
        recentTimestamp: messageData.timestamp,
        readStatus: readStatus,
      });
    }
  });

exports.onNewActivity = functions.firestore
  .document("/activities/{userId}/userActivities/{activityId}")
  .onCreate(async (snapshot, context) => {
    const activityData = snapshot.data();
    const senderUserRef = admin
      .firestore()
      .collection("users")
      .doc(activityData.fromUserId);

    // Get the message sender - user document
    const senderUserSnapshot = await senderUserRef.get();
    if (!senderUserSnapshot.exists) {
      return;
    }

    const senderUserData = senderUserSnapshot.data();
    let event;
    let senderName = senderUserData.name;
    let body;

    // Check for the message event
    if (activityData.isFollowEvent === true) {
      event = "isFollowEvent";
      body = "Started follow you!";
    } else if (activityData.isLikeEvent === true) {
      event = "isLikeEvent";
      if (activityData.comment !== null) {
        body = `Liked your post: "${activityData.comment}"`;
      } else {
        body = `Liked your post`;
      }
    } else if (activityData.isCommentEvent === true) {
      event = "isCommentEvent";
      body = `Commented on your post: "${activityData.comment}"`;
    } else if (activityData.isMessageEvent === true) {
      event = "isMessageEvent";
      if (activityData.comment !== null) {
        body = `Sent a message: "${activityData.comment}"`;
      } else {
        body = `Sent a file message`;
      }
    } else if (activityData.isLikeMessageEvent === true) {
      event = "isLikeMessageEvent";
      if (activityData.comment !== null) {
        body = `Liked your message: "${activityData.comment}"`;
      } else {
        body = `Liked your message file`;
      }
    }

    // If there is a receiver token && the message event matches the events above
    if (
      activityData.recieverToken !== null &&
      activityData.recieverToken.length > 1 &&
      event !== null
    ) {
      const payload = {
        notification: {
          title: senderName,
          body: body,
          image: senderUserData.profileImageUrl,
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
      };
      const options = {
        priority: "high",
        timeToLive: 60 * 60 * 24,
      };
      // Send push notifications
      admin
        .messaging()
        .sendToDevice(activityData.recieverToken, payload, options);
    }

    // If this activity is message event or like message event - delete doc
    if (activityData.isLikeMessageEvent || activityData.isMessageEvent) {
      snapshot.ref.delete();
    }
  });

exports.onCreateUser = functions.auth.user().onCreate((user) => {
  // this method creates newUser activity that admin can watch
  const isViewedByAdmin = false;
  const isPassedVerification = false;
  const isBanned = false;
  const timestamp = admin.firestore.FieldValue.serverTimestamp();
  const newUserActivity = {
    timestamp,
    isViewedByAdmin,
    isPassedVerification,
  };

  admin
    .firestore()
    .collection("newUsers")
    .doc(`${user.uid}`)
    .set(newUserActivity)
    .then((result) => functions.logger.log(result))
    .catch((err) => functions.logger.warn(err));

  admin
    .firestore()
    .collection("users")
    .doc(`${user.uid}`)
    .set({ isBanned }, { merge: true })
    .then((result) => functions.logger.log(result))
    .catch((err) => functions.logger.warn(err));
});

exports.onUpdateUser = functions.firestore
  .document("users/{userId}")
  .onUpdate((change, context) => {
    const newValue = change.after.data();
    const previousValue = change.before.data();
    if (newValue.isBanned && !previousValue.isBanned) {
      disableUser(context.params.userId, true);
    } else if (!newValue.isBanned && previousValue.isBanned) {
      disableUser(context.params.userId, false);
    }
  });

const disableUser = (userId, bool) => {
  functions.app.admin
    .auth()
    .updateUser(userId, { disabled: bool })
    .then((result) => functions.logger.log(result))
    .catch((err) => functions.logger.warn(err));
};

const updateMultiDocs = (collection, updateOBJ) => {
  const collecRef = admin.firestore().collection(collection);
  return collecRef.get().then((snapshot) => {
    const promises = [];

    snapshot.forEach((doc) => {
      const ref = doc.ref;

      promises.push(ref.update(updateOBJ));
    });

    return Promise.all(promises)
      .then((result) => functions.logger.log(result))
      .catch((err) => functions.logger.warn(err));
  });
};
