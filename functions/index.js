const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { RtcTokenBuilder, RtcRole } = require("agora-access-token");

admin.initializeApp();

const APP_ID = "f1ad2916506b4d4189f0939fb4fdd24a";
const APP_CERTIFICATE = "2a8eeeb61bd8430cb56315e592be2c43";

exports.generateAgoraToken = functions.https.onCall(async (data, context) => {
  // Ensure the user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "The function must be called while authenticated."
    );
  }

  const channelName = data.channelName;
  if (!channelName) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "The function must be called with a valid channelName."
    );
  }

  // Optional uid provided by client, defaults to 0
  const uid = data.uid || 0;

  // Optional duration provided by client (in minutes), defaults to 25
  const durationInMinutes = data.duration || 25;

  // Calculate privilege expire time in seconds
  const expirationTimeInSeconds = durationInMinutes * 60 + 300; // adding 5 mins grace period
  const currentTimestamp = Math.floor(Date.now() / 1000);
  const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;

  try {
    // Generate token
    const token = RtcTokenBuilder.buildTokenWithUid(
      APP_ID,
      APP_CERTIFICATE,
      channelName,
      uid,
      RtcRole.PUBLISHER,
      privilegeExpiredTs
    );

    return {
      token: token
    };
  } catch (error) {
    throw new functions.https.HttpsError(
      "internal",
      error.message || "Failed to generate Agora token."
    );
  }
});

// 1. Trigger when a student books a session -> Notify Tutor
exports.onSessionCreated = functions.firestore
    .document("sessions/{sessionId}")
    .onCreate(async (snap, context) => {
      const session = snap.data();
      const tutorId = session.tutorId;
      const studentName = session.userName || "Student";
      const dateTime = session.dateTime ? session.dateTime.toDate() : new Date();

      const options = { weekday: "short", month: "short", day: "numeric", hour: "2-digit", minute: "2-digit" };
      const formattedTime = dateTime.toLocaleString("en-US", options);

      await admin.firestore().collection("notifications").add({
        title: "New Session Booked! 📅",
        body: `${studentName} booked a session with you on ${formattedTime}.`,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        isRead: false,
        target: "tutor",
        userId: tutorId,
      });

      return null;
    });

// 2. Scheduled Function: 15-Minute Session Reminder for Student and Tutor
exports.sendSessionReminders = functions.pubsub
    .schedule("every 5 minutes")
    .onRun(async (context) => {
      const now = new Date();
      const windowStart = new Date(now.getTime() + 12 * 60 * 1000);
      const windowEnd = new Date(now.getTime() + 18 * 60 * 1000);

      const db = admin.firestore();
      const sessionsSnapshot = await db
          .collection("sessions")
          .where("status", "==", "upcoming")
          .where("reminderSent", "!=", true)
          .where("dateTime", ">=", admin.firestore.Timestamp.fromDate(windowStart))
          .where("dateTime", "<=", admin.firestore.Timestamp.fromDate(windowEnd))
          .get();

      const batch = db.batch();

      for (const doc of sessionsSnapshot.docs) {
        const session = doc.data();
        const tutorId = session.tutorId;
        const studentId = session.userId;
        const studentName = session.userName || "Student";
        const tutorName = session.tutorName || "Tutor";
        const dateTime = session.dateTime.toDate();

        const options = { hour: "2-digit", minute: "2-digit" };
        const timeStr = dateTime.toLocaleTimeString("en-US", options);

        // Notification for Student
        const studentNotifRef = db.collection("notifications").doc();
        batch.set(studentNotifRef, {
          title: "Session Reminder ⏰",
          body: `Your session with ${tutorName} starts in 15 minutes (at ${timeStr}). Get ready!`,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          isRead: false,
          target: "student",
          userId: studentId,
        });

        // Notification for Tutor
        const tutorNotifRef = db.collection("notifications").doc();
        batch.set(tutorNotifRef, {
          title: "Session Reminder ⏰",
          body: `Your session with ${studentName} starts in 15 minutes (at ${timeStr}). Get ready!`,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          isRead: false,
          target: "tutor",
          userId: tutorId,
        });

        batch.update(doc.ref, { reminderSent: true });
      }

      await batch.commit();
      return null;
    });

// ==========================================
// MSG91 OTP Integration
// ==========================================
const MSG91_AUTH_KEY = "404117AQvUYpgj64e33a96P1";
const MSG91_TEMPLATE_ID = "64e3441ad6fc05126946fb23";

exports.sendMsg91Otp = functions.https.onCall(async (data, context) => {
  const phoneNumber = data.phoneNumber;
  if (!phoneNumber || phoneNumber.length !== 10) {
    throw new functions.https.HttpsError("invalid-argument", "Valid 10-digit phone number is required.");
  }

  const mobile = `91${phoneNumber}`;
  const url = `https://control.msg91.com/api/v5/otp?template_id=${MSG91_TEMPLATE_ID}&mobile=${mobile}&otp_length=4`;

  try {
    const response = await fetch(url, {
      method: "POST",
      headers: {
        "authkey": MSG91_AUTH_KEY,
        "content-type": "application/json",
      },
    });
    const result = await response.json();
    if (result.type === "success" || result.status === "success") {
      return { success: true, message: "OTP sent successfully" };
    } else {
      throw new Error(result.message || "Failed to send OTP via MSG91");
    }
  } catch (error) {
    throw new functions.https.HttpsError("internal", error.message || "Failed to send OTP");
  }
});

exports.verifyMsg91Otp = functions.https.onCall(async (data, context) => {
  const phoneNumber = data.phoneNumber;
  const otp = data.otp;

  if (!phoneNumber || !otp) {
    throw new functions.https.HttpsError("invalid-argument", "Phone number and OTP are required.");
  }

  const mobile = `91${phoneNumber}`;
  const formattedPhone = `+${mobile}`;
  const url = `https://control.msg91.com/api/v5/otp/verify?otp=${otp}&mobile=${mobile}`;

  try {
    const response = await fetch(url, {
      method: "GET",
      headers: {
        "authkey": MSG91_AUTH_KEY,
      },
    });
    const result = await response.json();

    if (result.type === "success" || result.status === "success" || (result.message && result.message.toLowerCase().includes("already verified"))) {
      let uid;
      try {
        const existingUser = await admin.auth().getUserByPhoneNumber(formattedPhone);
        uid = existingUser.uid;
      } catch (err) {
        uid = `phone_${mobile}`;
        try {
          await admin.auth().getUser(uid);
        } catch (e) {
          try {
            await admin.auth().createUser({
              uid: uid,
              phoneNumber: formattedPhone,
            });
          } catch (createErr) {
            if (createErr.code === 'auth/phone-number-already-exists') {
              const clashUser = await admin.auth().getUserByPhoneNumber(formattedPhone);
              uid = clashUser.uid;
            } else {
              throw createErr;
            }
          }
        }
      }

      const customToken = await admin.auth().createCustomToken(uid);
      return { success: true, customToken: customToken };
    } else {
      throw new Error(result.message || "Invalid OTP");
    }
  } catch (error) {
    throw new functions.https.HttpsError("invalid-argument", error.message || "OTP verification failed");
  }
});

