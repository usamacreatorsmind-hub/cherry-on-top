import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../controllers/video_call_controller.dart';
import '../../core/theme/app_theme.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final VideoCallController controller = Get.find<VideoCallController>();

  // Draggable local window offsets
  double xOffset = 20.0;
  double yOffset = 20.0;

  @override
  void initState() {
    super.initState();
    controller.joinChannel();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCaller = Get.arguments?['isCaller'] ?? true;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // 1. MAIN RENDER VIEW (Full Screen Remote Video or Dialing State)
          Positioned.fill(
            child: Obx(() {
              String? channelName = controller.currentCallData['channelName'];
              
              if (controller.remoteUid.value != 0 && controller.engine != null && channelName != null) {
                if (controller.isRemoteVideoMuted.value) {
                  return Container(
                    color: const Color(0xFF1E1E24),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.white.withAlpha(20),
                            child: const CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, size: 60, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "${isCaller ? (controller.currentCallData['receiverName'] ?? 'Tutor') : (controller.currentCallData['callerName'] ?? 'Student')} turned off camera",
                            style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: controller.engine!,
                    canvas: VideoCanvas(uid: controller.remoteUid.value, renderMode: RenderModeType.renderModeHidden),
                    connection: RtcConnection(channelId: channelName),
                  ),
                );
              } else {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0.8, end: 1.1),
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeInOut,
                          onEnd: () {},
                          builder: (context, double val, child) {
                            return Transform.scale(
                              scale: val,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: AppTheme.maroon.withAlpha(50),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: AppTheme.maroon,
                                  child: const Icon(Icons.person, size: 45, color: Colors.white),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        Text(
                          isCaller
                              ? "Calling ${controller.currentCallData['receiverName'] ?? 'Tutor'}"
                              : "Connecting call with ${controller.currentCallData['callerName'] ?? 'Student'}",
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withAlpha(20), borderRadius: BorderRadius.circular(20)),
                          child: Obx(
                            () => Text(
                              (controller.currentCallData['status'] ?? 'dialing').toString().toUpperCase(),
                              style: const TextStyle(color: Colors.pinkAccent, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }),
          ),

          // 2. PREMIUM TOP HEADER WITH LIVE TIMER CARD
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: Colors.black.withAlpha(100), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      const Icon(Icons.security, size: 16, color: Colors.greenAccent),
                      const SizedBox(width: 6),
                      Text(
                        isCaller ? "Tutor Session" : "Student Session",
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.maroon.withAlpha(220),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: AppTheme.maroon.withAlpha(100), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timelapse, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                      Obx(
                        () => Text(
                          controller.remainingTimeStr.value,
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. DRAGGABLE LOCAL CAMERA PREVIEW WINDOW
          Positioned(
            left: xOffset,
            top: yOffset,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  xOffset += details.delta.dx;
                  yOffset += details.delta.dy;
                  // Restrict bounds so it stays within safe viewport
                  xOffset = xOffset.clamp(10.0, size.width - 140.0);
                  yOffset = yOffset.clamp(60.0, size.height - 240.0);
                });
              },
              child: Card(
                elevation: 12,
                shadowColor: Colors.black.withAlpha(150),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 120,
                    height: 170,
                    color: const Color(0xFF1E1E24),
                    child: Obx(() {
                      // Show local preview if engine exists and camera is on
                      // (even if local user hasn't fully joined the channel yet)
                      if (controller.isEngineInitialized.value && !controller.isCameraOff.value && controller.engine != null) {
                        return AgoraVideoView(
                          controller: VideoViewController(
                            rtcEngine: controller.engine!,
                            canvas: const VideoCanvas(uid: 0, renderMode: RenderModeType.renderModeHidden),
                          ),
                        );
                      } else {
                        return const Center(child: Icon(Icons.videocam_off_rounded, color: Colors.white54, size: 32));
                      }
                    }),
                  ),
                ),
              ),
            ),
          ),

          // 4. FLOATING GLASSMORPHISM CONTROL DOCK (BOTTOM BAR)
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withAlpha(40), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Audio Mute toggle button
                      Obx(
                        () => _buildControlButton(
                          icon: controller.isMuted.value ? Icons.mic_off_rounded : Icons.mic_rounded,
                          color: controller.isMuted.value ? Colors.amber : Colors.white.withAlpha(30),
                          iconColor: controller.isMuted.value ? Colors.black : Colors.white,
                          onTap: () => controller.toggleMute(),
                        ),
                      ),

                      // Camera video stream toggle button
                      Obx(
                        () => _buildControlButton(
                          icon: controller.isCameraOff.value ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                          color: controller.isCameraOff.value ? Colors.amber : Colors.white.withAlpha(30),
                          iconColor: controller.isCameraOff.value ? Colors.black : Colors.white,
                          onTap: () => controller.toggleCamera(),
                        ),
                      ),

                      // Flip front/rear camera button
                      _buildControlButton(
                        icon: Icons.flip_camera_ios_rounded,
                        color: Colors.white.withAlpha(30),
                        iconColor: Colors.white,
                        onTap: () => controller.switchCamera(),
                      ),

                      // Absolute Termination End Call Button
                      _buildControlButton(
                        icon: Icons.call_end_rounded,
                        color: Colors.redAccent,
                        iconColor: Colors.white,
                        isLarge: true,
                        onTap: () => controller.endCall(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
    bool isLarge = false,
  }) {
    double size = isLarge ? 60.0 : 48.0;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: isLarge ? [BoxShadow(color: Colors.redAccent.withAlpha(100), blurRadius: 15, offset: const Offset(0, 6))] : null,
        ),
        child: Icon(icon, color: iconColor, size: isLarge ? 28 : 22),
      ),
    );
  }
}
