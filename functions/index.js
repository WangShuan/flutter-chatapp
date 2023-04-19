const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.myFunction = functions.firestore
  .document("chat/{message}")
  .onCreate( (snap, context) => {
    return admin.firestore().collection("users").doc(snap.data().user_id).get().then((data) =>
      admin.messaging().sendToTopic("chat", {
        notification: {
          title: data.data().username,
          body: snap.data().text,
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      }),
    );
  });
