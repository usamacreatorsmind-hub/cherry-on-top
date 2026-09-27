const admin = require('firebase-admin');

// 1. Download your service account key from Firebase Console
// Project Settings -> Service Accounts -> Generate new private key
// 2. Rename the file to serviceAccountKey.json and place it in the same directory as this script.
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

const tutors = [
  {
    name: "Dr. Hangshamita",
    rating: 4.9,
    sessionsCount: 694,
    expertise: ["Business English", "Public Speaking"],
    bio: "Certified English language trainer with a background in dentistry, helping professionals speak with confidence.",
    emoji: "👩‍🏫",
    nextAvailability: "Today at 2:00 PM",
    weeklySchedule: {
      "Monday": { isAvailable: true, startTime: "09:00", endTime: "17:00", slotDuration: 25 },
      "Wednesday": { isAvailable: true, startTime: "10:00", endTime: "18:00", slotDuration: 25 },
      "Friday": { isAvailable: true, startTime: "09:00", endTime: "15:00", slotDuration: 25 }
    }
  },
  {
    name: "Jaijeet Singh",
    rating: 4.8,
    sessionsCount: 2942,
    expertise: ["Interview skills", "Business English", "Soft Skills"],
    bio: "Corporate trainer with 10+ years of experience in communication coaching and leadership development.",
    emoji: "👨‍🏫",
    nextAvailability: "Tomorrow at 10:00 AM",
    weeklySchedule: {
      "Tuesday": { isAvailable: true, startTime: "08:00", endTime: "16:00", slotDuration: 25 },
      "Thursday": { isAvailable: true, startTime: "11:00", endTime: "19:00", slotDuration: 25 }
    }
  },
  {
    name: "Leena K.",
    rating: 4.7,
    sessionsCount: 1520,
    expertise: ["IELTS", "TOEFL", "Spoken English"],
    bio: "Specialize in exam preparation and helping students achieve their target bands in international English tests.",
    emoji: "👩‍🏫",
    nextAvailability: "Today at 4:30 PM",
    weeklySchedule: {
      "Monday": { isAvailable: true, startTime: "14:00", endTime: "20:00", slotDuration: 25 },
      "Saturday": { isAvailable: true, startTime: "10:00", endTime: "14:00", slotDuration: 25 }
    }
  },
  {
    name: "Rahul Sharma",
    rating: 4.9,
    sessionsCount: 850,
    expertise: ["Conversational English", "Slang & Idioms"],
    bio: "Make learning fun! I focus on real-world conversations and natural speaking patterns.",
    emoji: "👨‍🏫",
    nextAvailability: "Monday at 9:00 AM",
    weeklySchedule: {
      "Monday": { isAvailable: true, startTime: "09:00", endTime: "12:00", slotDuration: 25 },
      "Wednesday": { isAvailable: true, startTime: "09:00", endTime: "12:00", slotDuration: 25 }
    }
  }
];

async function seedTutors() {
  console.log("Starting to seed tutors...");
  const batch = db.batch();

  tutors.forEach((tutor) => {
    const docRef = db.collection('tutors').doc(); // Auto-generate ID
    batch.set(docRef, {
      id: docRef.id,
      ...tutor
    });
  });

  try {
    await batch.commit();
    console.log("Successfully seeded tutors to Firestore!");
  } catch (error) {
    console.error("Error seeding tutors: ", error);
  }
}

seedTutors();
