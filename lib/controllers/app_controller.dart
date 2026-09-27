import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/user_model.dart';
import '../data/repositories/firestore_repository.dart';

class AppController extends GetxController {
  final FirestoreRepository _repository = FirestoreRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var user = Rxn<UserModel>();
  var userName = "Ananya".obs;
  var walletBalance = 0.obs;
  var completedSessions = 0.obs;
  var availableSessions = 0.obs;
  var remainingDays = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to Auth state changes to load user data
    _auth.authStateChanges().listen((User? firebaseUser) {
      if (firebaseUser != null) {
        loadUserData(firebaseUser.uid);
      } else {
        user.value = null;
      }
    });
  }

  Future<void> loadUserData(String uid) async {
    UserModel? data = await _repository.getUser(uid);
    if (data != null) {
      user.value = data;
      userName.value = data.name;
      walletBalance.value = data.walletBalance;
      completedSessions.value = data.completedSessions;
      availableSessions.value = data.availableSessions;
      remainingDays.value = data.remainingDays;
    }
  }

  void updateWallet(int amount) {
    walletBalance.value += amount;
    // In a real app, you'd also update Firestore here
  }

  void clearUserData() {
    user.value = null;
    userName.value = "";
    walletBalance.value = 0;
    completedSessions.value = 0;
    availableSessions.value = 0;
    remainingDays.value = 0;
  }
}
