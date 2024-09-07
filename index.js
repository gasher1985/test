const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendDataMessage = functions.firestore
    .document('dataMessages/{messageId}')
    .onCreate(async (snap, context) => {
        const message = snap.data();
        const recipientId = message.recipientId;

        // Get the recipient's FCM token
        const recipientDoc = await admin.firestore().collection('users').doc(recipientId).get();
        const fcmToken = recipientDoc.data().fcmToken;

        if (!fcmToken) {
            console.log('No FCM token found for recipient');
            return;
        }

        const payload = {
            token: fcmToken,
            data: message.data,  // Your custom data here
        };

        try {
            // Using the new FCM v1 API
            await admin.messaging().send(payload);
            console.log('Data message sent successfully');
        } catch (error) {
            console.error('Error sending data message:', error);
        }
    });