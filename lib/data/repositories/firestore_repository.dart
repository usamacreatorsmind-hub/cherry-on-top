import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/tutor_model.dart';
import '../models/session_model.dart';
import '../models/banner_model.dart';
import '../models/subscription_plan_model.dart';
import '../models/refer_and_earn_model.dart';

class FirestoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Operations
  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Future<UserModel?> getUser(String uid) async {
    if (uid.isEmpty) return null;
    var doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  // Tutor Operations
  Future<void> createTutor(TutorModel tutor) async {
    await _firestore.collection('tutors').doc(tutor.id).set(tutor.toMap());
  }

  Stream<List<TutorModel>> getTutors() {
    return _firestore.collection('tutors').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TutorModel.fromMap(doc.data())).toList();
    });
  }

  // Banner Operations
  Stream<List<BannerModel>> getBanners() {
    return _firestore.collection('banners').snapshots().map((snapshot) {
      final banners = snapshot.docs.map((doc) => BannerModel.fromMap(doc.data(), doc.id)).toList();
      banners.sort((a, b) => a.order.compareTo(b.order));
      return banners;
    });
  }

  Stream<List<SessionModel>> getSessionsByDate(DateTime date) {
    DateTime start = DateTime(date.year, date.month, date.day);
    DateTime end = start.add(const Duration(days: 1));
    return _firestore
        .collection('sessions')
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('dateTime', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => SessionModel.fromMap(doc.data())).toList();
        });
  }

  // Session Operations
  Future<void> bookSession(SessionModel session) async {
    await _firestore.collection('sessions').doc(session.id).set(session.toMap());
  }

  Stream<List<SessionModel>> getUserSessions(String userId) {
    return _firestore.collection('sessions').where('userId', isEqualTo: userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => SessionModel.fromMap(doc.data())).toList();
    });
  }

  Stream<List<SessionModel>> getTutorSessions(String tutorId) {
    return _firestore.collection('sessions').where('tutorId', isEqualTo: tutorId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => SessionModel.fromMap(doc.data())).toList();
    });
  }

  Future<void> updateSessionStatus(String sessionId, String status) async {
    await _firestore.collection('sessions').doc(sessionId).set({'status': status}, SetOptions(merge: true));
  }

  Future<void> updateTutorPublicProfile(UserModel user) async {
    Map<String, dynamic> tutorData = {
      'id': user.uid, // Required for TutorModel.fromMap
      'name': user.name,
      'expertise': user.expertise,
      'bio': user.bio ?? '',
      'hourlyRate': user.hourlyRate ?? 0.0,
      'profilePic': user.profilePic,
      'sessionsCount': user.completedSessions, // Sync session count
      'rating': 4.8, // Default rating for new/updated tutors if not exists
      'weeklySchedule': user.weeklySchedule?.map((key, value) => MapEntry(key, value.toMap())),
    };
    await _firestore.collection('tutors').doc(user.uid).set(tutorData, SetOptions(merge: true));
  }

  Future<void> completeSessionAndAddEarnings(SessionModel session) async {
    WriteBatch batch = _firestore.batch();

    // 1. Mark session as completed
    batch.set(_firestore.collection('sessions').doc(session.id), {'status': 'past'}, SetOptions(merge: true));

    // 2. Add earnings to tutor's profile and increment tutor completed sessions
    batch.set(_firestore.collection('tutors').doc(session.tutorId), {
      'totalEarnings': FieldValue.increment(session.price),
      'sessionsCount': FieldValue.increment(1),
    }, SetOptions(merge: true));

    batch.set(_firestore.collection('users').doc(session.tutorId), {
      'totalEarnings': FieldValue.increment(session.price),
      'completedSessions': FieldValue.increment(1),
    }, SetOptions(merge: true));

    // 3. Update the student's completed sessions
    batch.set(_firestore.collection('users').doc(session.userId), {
      'completedSessions': FieldValue.increment(1),
      'availableSessions': FieldValue.increment(-1),
    }, SetOptions(merge: true));

    await batch.commit();
  }

  // Helper to ensure counts are non-negative after updates
  Future<void> sanitizeUserCounts(String uid) async {
    if (uid.isEmpty) return;
    var doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      int available = doc.data()?['availableSessions'] ?? 0;
      if (available < 0) {
        await _firestore.collection('users').doc(uid).set({'availableSessions': 0}, SetOptions(merge: true));
      }
    }
  }

  // Favourite Tutors Operations
  Future<void> toggleFavouriteTutor(String studentId, TutorModel tutor) async {
    if (studentId.isEmpty || tutor.id.isEmpty) return;
    final docRef = _firestore.collection('users').doc(studentId).collection('favourites').doc(tutor.id);

    var doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete();
    } else {
      await docRef.set(tutor.toMap());
    }
  }

  Stream<List<TutorModel>> getFavouriteTutors(String studentId) {
    if (studentId.isEmpty) return Stream.value([]);
    return _firestore.collection('users').doc(studentId).collection('favourites').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TutorModel.fromMap(doc.data())).toList();
    });
  }

  Stream<bool> isFavourite(String studentId, String tutorId) {
    if (studentId.isEmpty || tutorId.isEmpty) return Stream.value(false);
    return _firestore.collection('users').doc(studentId).collection('favourites').doc(tutorId).snapshots().map((doc) => doc.exists);
  }

  // Submit Review, Mark session complete, and update Aggregate Rating Score
  Future<void> submitTutorReview({
    required String sessionId,
    required String tutorId,
    required String studentId,
    required String studentName,
    required double rating,
    required String comment,
  }) async {
    // 1. Submit individual review log
    String reviewId = _firestore.collection('reviews').doc().id;
    await _firestore.collection('reviews').doc(reviewId).set({
      'reviewId': reviewId,
      'sessionId': sessionId,
      'tutorId': tutorId,
      'studentId': studentId,
      'studentName': studentName,
      'rating': rating,
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 2. Fetch specific session and trigger accounting completions updates
    var sessionDoc = await _firestore.collection('sessions').doc(sessionId).get();
    if (sessionDoc.exists) {
      SessionModel session = SessionModel.fromMap(sessionDoc.data()!);
      if (session.status != 'past') {
        await completeSessionAndAddEarnings(session);
      }
    }

    // 3. Recalculate average mathematical rating score for the tutor
    var reviewsSnapshot = await _firestore.collection('reviews').where('tutorId', isEqualTo: tutorId).get();

    if (reviewsSnapshot.docs.isNotEmpty) {
      double totalRatingSum = 0.0;
      for (var doc in reviewsSnapshot.docs) {
        totalRatingSum += (doc.data()['rating'] ?? 0.0).toDouble();
      }
      double averageRating = totalRatingSum / reviewsSnapshot.docs.length;

      // Keep round bounds up to 1 decimal place safely
      averageRating = double.parse(averageRating.toStringAsFixed(1));

      // 4. Atomic update on public tutors listing profiles and internal user document
      await _firestore.collection('tutors').doc(tutorId).set({
        'rating': averageRating,
        'sessionsCount': reviewsSnapshot.docs.length,
      }, SetOptions(merge: true));

      await _firestore.collection('users').doc(tutorId).set({'rating': averageRating}, SetOptions(merge: true));
    }
  }

  // Subscription Plans Operations
  Stream<List<SubscriptionPlanModel>> getSubscriptionPlans() {
    return _firestore.collection('subscription_plans').orderBy('order').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => SubscriptionPlanModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Refer and Earn Operations (Separate collection 'referrals')
  Future<ReferAndEarnModel> getOrCreateReferralData(String userId, String userName) async {
    if (userId.isEmpty) {
      return ReferAndEarnModel(userId: userId, referralCode: 'USER123456', walletBalance: 0, pendingInvites: 0, successfulInvites: 0);
    }
    var docRef = _firestore.collection('referrals').doc(userId);
    var doc = await docRef.get();

    if (doc.exists && doc.data() != null) {
      return ReferAndEarnModel.fromMap(doc.data()!);
    } else {
      String prefix = userName.isNotEmpty ? userName.replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase() : 'USER';
      if (prefix.length > 3) prefix = prefix.substring(0, 3);
      int randomNum = 100000 + DateTime.now().millisecondsSinceEpoch % 900000;
      String code = "$prefix$randomNum";

      ReferAndEarnModel newReferral = ReferAndEarnModel(
        userId: userId,
        referralCode: code,
        walletBalance: 0.0,
        pendingInvites: 0,
        successfulInvites: 0,
      );

      await docRef.set(newReferral.toMap());
      return newReferral;
    }
  }
}
