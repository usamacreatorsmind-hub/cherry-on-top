import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../data/models/tutor_model.dart';
import '../../../data/models/banner_model.dart';
import '../../../data/repositories/firestore_repository.dart';

class HomeController extends GetxController {
  final FirestoreRepository _repository = FirestoreRepository();
  var topTutors = <TutorModel>[].obs;
  var banners = <BannerModel>[].obs;
  var trialPrice = 100.obs;
  var isLoading = true.obs;
  var currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTopTutors();
    fetchBanners();
    fetchTrialPrice();
  }

  void fetchTrialPrice() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('config').doc('pricing').get();
      if (doc.exists && doc.data()?['trialPrice'] != null) {
        trialPrice.value = int.tryParse(doc.data()?['trialPrice'].toString() ?? '100') ?? 100;
      }
    } catch (_) {
      trialPrice.value = 100;
    }
  }

  void fetchTopTutors() {
    _repository.getTutors().listen((tutors) {
      topTutors.assignAll(tutors.take(8).toList());
      isLoading.value = false;
    });
  }

  void fetchBanners() {
    _repository.getBanners().listen((bannerList) {
      banners.assignAll(bannerList);
    });
  }

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}
