const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp()

exports.onFollowUser = functions.firestore
.document('/followers/{userId}/userFollowers/{followerId}')
.onCreate(async (snapshot, context) => {
    console.log(snapshot.data());
    const userId = context.params.userId;
    const followerId = context.params.followerId;
    const followedUserPostsRef = admin.firestore().collection('posts').doc(userId).collection('usersPosts');
    const userFeedRef = admin.firestore().collection('feeds').doc(followerId).collection('userFeed');
    const followdUserPostsSnapShot = await followedUserPostsRef .get();
    followdUserPostsSnapShot.forEach(doc => {
        if(doc.exist){
            userFeedRef.doc(doc.id).set(doc.data());
        }
    });

});