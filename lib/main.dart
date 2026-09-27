import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/theme/app_theme.dart';
import 'controllers/app_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/video_call_controller.dart';
import 'firebase_options.dart';
import 'routes/app_pages.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.initialize();

  // Request Microphone and Camera permission at app startup/earliest point 
  // to avoid Android 14+ FGS SecurityException during background CallKit accept
  try {
    await [
      Permission.microphone,
      Permission.camera,
    ].request();
  } catch (e) {
    debugPrint("Initial permission request error: $e");
  }
  
  Get.put(AppController());
  Get.put(AuthController());
  Get.put(VideoCallController());
  
  runApp(const CherryOnTopApp());
}

class CherryOnTopApp extends StatelessWidget {
  const CherryOnTopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: GetMaterialApp(
        title: 'Cherry on Top',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
      ),
    );
  }
}
