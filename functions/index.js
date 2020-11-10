const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.onFollowUser = functions.firestore
    .document('/followers/{userId}/userFollowers/{followerId}')
    .onCreate(async (snapshot, context) => {
        console.log(snapshot.data());
        const userId = context.params.userId;
        const followerId = context.params.followerId;
        const followedUserPostsRef = admin
            .firestore()
            .collection('posts')
            .doc(userId)
            .collection('userPosts');
        const userFeedRef = admin
            .firestore()
            .collection('feeds')
            .doc(followerId)
            .collection('userFeed');
        const followedUserPostsSnapshot = await followedUserPostsRef.get();
        followedUserPostsSnapshot.forEach(doc => {
            if (doc.exists) {
                userFeedRef.doc(doc.id).set(doc.data());
            }
        });
    });

exports.onUnfollowUser = functions.firestore
    .document('/followers/{userId}/userFollowers/{followerId}')
    .onDelete(async (snapshot, context) => {
        const userId = context.params.userId;
        const followerId = context.params.followerId;
        const userFeedRef = admin
            .firestore()
            .collection('feeds')
            .doc(followerId)
            .collection('userFeed')
            .where('authorId', '==', userId);
        const userPostsSnapshot = await userFeedRef.get();
        userPostsSnapshot.forEach(doc => {
            if (doc.exists) {
                doc.ref.delete();
            }
        });
    });

exports.onUploadPost = functions.firestore
    .document('/posts/{userId}/userPosts/{postId}')
    .onCreate(async (snapshot, context) => {
        const userId = context.params.userId;
        const postId = context.params.postId;

        const userFollowersRef = admin
            .firestore()
            .collection('followers')
            .doc(userId)
            .collection('userFollowers');

        const userFollowersSnapshot = await userFollowersRef.get();

        userFollowersSnapshot.forEach(doc => {
            //Uploading post to followers feed
            admin
                .firestore()
                .collection('feeds')
                .doc(doc.id)
                .collection('userFeed')
                .doc(postId)
                .set(snapshot.data());
        })

        //Uploading post to author feed
        admin
            .firestore()
            .collection('feeds')
            .doc(userId)
            .collection('userFeed')
            .doc(postId)
            .set(snapshot.data());
    });


exports.onUpdatePost = functions.firestore
    .document('/posts/{userId}/userPosts/{postId}')
    .onUpdate(async (snapshot, context) => {
        const userId = context.params.userId;
        const postId = context.params.postId;
        const newPostData = snapshot.after.data();
        console.log(newPostData);
        const userFollowersRef = admin
            .firestore()
            .collection('followers')
            .doc(userId)
            .collection('userFollowers');


        const userFollowersSnapshot = await userFollowersRef.get();
        userFollowersSnapshot.forEach(async userDoc => {
            //Updating post to followers feed
            const postRef = admin
                .firestore()
                .collection('feeds')
                .doc(userDoc.id)
                .collection('userFeed');
            const postDoc = await postRef.doc(postId).get();
            if (postDoc.exists) {
                postDoc.ref.update(newPostData);
            }
        });


        //Updating post to author feed
        const postRef = admin
            .firestore()
            .collection('feeds')
            .doc(userId)
            .collection('userFeed');
        const postDoc = await postRef.doc(postId).get();
        if (postDoc.exists) {
            postDoc.ref.update(newPostData);
        }

    });

exports.onDeletePost = functions.firestore
    .document('/posts/{authorId}/userPosts/{postId}')
    .onDelete(async (snapshot, context) => {
        const postId = context.params.postId;
        const authorId = context.params.authorId;

        /* Deleting post from followers feeds*/
        const authorFollowersRef = admin.firestore()
            .collection('followers')
            .doc(authorId)
            .collection('userFollowers');

        // get author followers
        const authorFollowersSnapshot = await authorFollowersRef.get();

        authorFollowersSnapshot.docs.forEach(async userDoc => {
            const postRef = admin
                .firestore()
                .collection('feeds')
                .doc(userDoc.id)
                .collection('userFeed');

            await postRef.doc(postId).delete();
        });
        /* End of Deleting post from followers feeds */

        /* Deleting post from author feed */
        const authorFeedRef = admin
            .firestore()
            .collection('feeds')
            .doc(authorId)
            .collection('userFeed');

        authorFeedRef.doc(postId).delete();
        /* End of Deleting post from author feed */

    });


exports.addChatMessage = functions.firestore
    .document('/chats/{chatId}/messages/{messageId}')
    .onCreate(async (snapshot, context) => {
        const chatId = context.params.chatId;
        const messageData = snapshot.data();
        const chatRef = admin
            .firestore()
            .collection('chats')
            .doc(chatId);
        const chatDoc = await chatRef.get();
        const chatData = chatDoc.data();
        if (chatDoc.exists) {
            const readStatus = chatData.readStatus;
            for (let userId in readStatus) {
                if (
                    readStatus.hasOwnProperty(userId) &&
                    userId !== messageData.senderId
                ) {
                    readStatus[userId] = false;
                }
            }
            chatRef.update({
                recentMessage: messageData.text,
                recentSender: messageData.senderId,
                recentTimestamp: messageData.timestamp,
                readStatus: readStatus
            });

        }
    });