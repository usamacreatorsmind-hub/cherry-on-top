import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../routes/app_pages.dart';
import '../widgets/review_feedback_sheet.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart' as callkit;
import 'package:flutter_callkit_incoming/entities/entities.dart';

class VideoCallController extends GetxController {
  static VideoCallController get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Agora Credentials
  static const String appId = "f1ad2916506b4d4189f0939fb4fdd24a";

  RtcEngine? engine;

  var isMuted = false.obs;
  var isCameraOff = false.obs;
  var remoteUid = 0.obs;
  var isLocalUserJoined = false.obs;
  var isEngineInitialized = false.obs;

  StreamSubscription<QuerySnapshot>? _callStreamSubscription;
  StreamSubscription<DocumentSnapshot>? _currentCallSubscription;

  Timer? _sessionTimer;
  Timer? _warningTimer;
  Timer? _uiCountdownTimer;

  var remainingTimeStr = "00:00".obs;
  var currentCallData = <String, dynamic>{}.obs;
  var hasIncomingCall = false.obs;

  var isRemoteVideoMuted = false.obs;
  bool _isCleaningUp = false;

  @override
  void onInit() {
    super.onInit();
    _listenerCallkitEvents();
    _checkActiveCalls(); // Check if app was opened via a call accept
    // Start listening for incoming calls as soon as the user logs in
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        listenToIncomingCalls(user.uid);
      } else {
        _callStreamSubscription?.cancel();
        _currentCallSubscription?.cancel();
      }
    });
  }

  // Listen to incoming calls in Firestore
  void listenToIncomingCalls(String currentUid) {
    _callStreamSubscription?.cancel();
    _callStreamSubscription = _firestore
        .collection('calls')
        .where('receiverId', isEqualTo: currentUid)
        .where('status', isEqualTo: 'dialing')
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            var callDoc = snapshot.docs.first;
            currentCallData.value = callDoc.data();
            currentCallData['docId'] = callDoc.id;
            hasIncomingCall.value = true;

            // Update status to ringing
            _firestore.collection('calls').doc(callDoc.id).update({'status': 'ringing'});

            // Listen to this specific call document for changes (e.g. caller cancels)
            _subscribeToCurrentCall(callDoc.id);

            // Show Incoming Call Notification via CallKit
            _showCallkitIncoming(currentCallData);
          }
        });
  }

  void _listenerCallkitEvents() {
    try {
      callkit.FlutterCallkitIncoming.onEvent.listen((event) {
        if (event == null) return;
        debugPrint("CallKit Event: ${event.eventName}");

        if (event is CallEventActionCallAccept) {
          acceptCall(callId: event.id);
        } else if (event is CallEventActionCallDecline) {
          if (!_isCleaningUp) rejectCall();
        } else if (event is CallEventActionCallTimeout) {
          if (!_isCleaningUp) rejectCall();
        } else if (event is CallEventActionCallEnded) {
          if (!_isCleaningUp) _cleanupCall();
        }
      });
    } catch (e) {
      debugPrint("CallKit Event Error: $e");
    }
  }

  Future<void> _checkActiveCalls() async {
    await Future.delayed(const Duration(milliseconds: 1000)); // Increased delay for stability
    try {
      var calls = await callkit.FlutterCallkitIncoming.activeCalls();
      if (calls.isNotEmpty) {
        var call = calls.first;
        if (call.isAccepted) {
          debugPrint("Resuming accepted call from activeCalls: ${call.id}");

          // Reconstruct currentCallData from extra if available
          if (call.extra != null && call.extra!.isNotEmpty) {
            currentCallData.value = Map<String, dynamic>.from(call.extra!);
            currentCallData['callId'] = call.id;
            currentCallData['docId'] = call.id; // Usually same as callId
          } else {
            // Fallback for basic info
            currentCallData.value = {'callId': call.id, 'docId': call.id, 'callerName': call.nameCaller, 'status': 'accepted'};
          }

          await initAgoraEngine();
          if (!Get.currentRoute.contains(Routes.VIDEO_CALL)) {
            // Use offAllNamed to ensure we clear the Splash and land on Call Screen
            Get.offAllNamed(Routes.VIDEO_CALL, arguments: {'isCaller': false});
          }
        }
      }
    } catch (e) {
      debugPrint("Check Active Calls Error: $e");
    }
  }

  Future<void> _showCallkitIncoming(Map<String, dynamic> data) async {
    final params = CallKitParams(
      id: data['callId'],
      nameCaller: data['callerName'] ?? 'Someone',
      appName: 'Cherry On Top',
      avatar: data['callerAvatar'] ?? 'assets/applogo/app_logo.png',
      handle: 'Video Call',
      type: 1, // 0: text, 1: video
      duration: 30000,
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),
      // Pass ALL required data in extra so it persists if app is killed
      extra: <String, dynamic>{
        'callId': data['callId'],
        'docId': data['docId'],
        'callerId': data['callerId'],
        'callerName': data['callerName'],
        'receiverId': data['receiverId'],
        'receiverName': data['receiverName'],
        'channelName': data['channelName'],
        'duration': data['duration'],
        'isTutorCalling': data['isTutorCalling'],
      },
      headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      android: AndroidParams(
        isCustomNotification: false,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#09121F',
        backgroundUrl: data['callerAvatar'] ?? 'assets/applogo/app_logo.png',
        actionColor: '#4CAF50',
        incomingCallNotificationChannelName: "Incoming Call",
        missedCallNotificationChannelName: "Missed Call",
        textAccept: 'Accept',
        textDecline: 'Reject',
        isFullScreen: false, // Changed to false for pop-up behavior as requested
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );
    await callkit.FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  void _subscribeToCurrentCall(String docId) {
    _currentCallSubscription?.cancel();
    _currentCallSubscription = _firestore.collection('calls').doc(docId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        currentCallData.value = data;
        currentCallData['docId'] = snapshot.id;

        String status = data['status'] ?? '';
        if (status == 'ended' || status == 'rejected') {
          debugPrint("Call Status changed to $status, cleaning up...");
          if (!_isCleaningUp) _cleanupCall();
        }
      } else {
        debugPrint("Call document deleted, cleaning up...");
        if (!_isCleaningUp) _cleanupCall();
      }
    });
  }

  // Make an Outgoing Call
  Future<void> makeCall({
    required String receiverId,
    required String receiverName,
    required String callerName,
    int durationInMinutes = 25,
    bool isTutorCalling = false,
  }) async {
    String currentUid = _auth.currentUser?.uid ?? '';
    if (currentUid.isEmpty) return;

    String callId = const Uuid().v4();
    String channelName = "call_${currentUid.substring(0, 5)}_${receiverId.substring(0, 5)}";

    Map<String, dynamic> callInfo = {
      'callId': callId,
      'callerId': currentUid,
      'callerName': callerName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'channelName': channelName,
      'status': 'dialing',
      'duration': durationInMinutes,
      'timestamp': FieldValue.serverTimestamp(),
      'isTutorCalling': isTutorCalling,
    };

    await _firestore.collection('calls').doc(callId).set(callInfo);
    currentCallData.value = callInfo;
    currentCallData['docId'] = callId;

    _subscribeToCurrentCall(callId);

    // Initialize Agora before navigating
    await initAgoraEngine();

    // Navigate to Call Screen
    Get.toNamed(Routes.VIDEO_CALL, arguments: {'isCaller': true});
  }

  // Accept Call
  Future<void> acceptCall({Map<String, dynamic>? eventData, String? callId}) async {
    // If we have eventData, populate currentCallData first
    if (eventData != null && eventData.isNotEmpty) {
      var extra = eventData['extra'] ?? eventData;
      if (extra is Map) {
        currentCallData.value = Map<String, dynamic>.from(extra);
        if (eventData['id'] != null) currentCallData['callId'] = eventData['id'];
        if (eventData['id'] != null) currentCallData['docId'] = eventData['id'];
      }
    }

    // If docId is still null but we have callId, try to find it in active calls
    if (currentCallData['docId'] == null && callId != null) {
      try {
        var activeCalls = await callkit.FlutterCallkitIncoming.activeCalls();
        for (var call in activeCalls) {
          if (call.id == callId && call.extra != null) {
            currentCallData.value = Map<String, dynamic>.from(call.extra!);
            currentCallData['callId'] = call.id;
            currentCallData['docId'] = call.id;
            break;
          }
        }
      } catch (e) {
        debugPrint("Error finding active call data: $e");
      }
    }

    String? docId = currentCallData['docId'];
    if (docId == null) {
      debugPrint("Cannot accept call: docId is null");
      return;
    }

    if (Get.isDialogOpen ?? false) Get.back();

    try {
      await _firestore.collection('calls').doc(docId).update({'status': 'accepted'});
      // CRITICAL: Must subscribe to current call updates even when accepting
      // to ensure we hear the 'ended' status from the other side
      _subscribeToCurrentCall(docId);
    } catch (e) {
      debugPrint("Error updating call status to accepted: $e");
    }

    hasIncomingCall.value = false;

    // Initialize Agora before navigating
    await initAgoraEngine();

    // Navigate to Call Screen
    if (!Get.currentRoute.contains(Routes.VIDEO_CALL)) {
      // If we are on Splash or somewhere else, clear and go to Call
      if (Get.currentRoute == Routes.SPLASH || Get.currentRoute == '/') {
        Get.offAllNamed(Routes.VIDEO_CALL, arguments: {'isCaller': false});
      } else {
        Get.toNamed(Routes.VIDEO_CALL, arguments: {'isCaller': false});
      }
    }
  }

  // Reject Call
  Future<void> rejectCall() async {
    String? docId = currentCallData['docId'];
    if (docId == null) return;

    if (Get.isDialogOpen ?? false) Get.back();

    await _firestore.collection('calls').doc(docId).update({'status': 'rejected'});
    await _cleanupCall();
  }

  // End Call
  Future<void> endCall() async {
    String? docId = currentCallData['docId'];
    if (docId != null) {
      try {
        await _firestore.collection('calls').doc(docId).update({'status': 'ended'});
      } catch (e) {
        debugPrint("Error updating call status to ended: $e");
      }
    }
    await _cleanupCall();
  }

  Future<void> _cleanupCall() async {
    if (_isCleaningUp) return;
    _isCleaningUp = true;
    debugPrint("Cleaning up call session...");

    try {
      // Immediately turn off camera and mic state indicators
      isCameraOff.value = true;
      isMuted.value = true;

      _warningTimer?.cancel();
      _sessionTimer?.cancel();
      _uiCountdownTimer?.cancel();
      _warningTimer = null;
      _sessionTimer = null;
      _uiCountdownTimer = null;

      if (Get.isDialogOpen ?? false) Get.back();

      _currentCallSubscription?.cancel();
      _currentCallSubscription = null;
      hasIncomingCall.value = false;

      // Cache parameters before cleaning up engine states
      String callerId = currentCallData['callerId'] ?? '';
      String callerName = currentCallData['callerName'] ?? 'Student';
      String receiverId = currentCallData['receiverId'] ?? '';
      String receiverName = currentCallData['receiverName'] ?? 'Tutor';
      String callId = currentCallData['callId'] ?? '';
      bool isTutorCalling = currentCallData['isTutorCalling'] ?? false;

      // Detection for review sheet
      bool isStudent = isTutorCalling ? (_auth.currentUser?.uid == receiverId) : (_auth.currentUser?.uid == callerId);
      bool shouldShowReview = isStudent && (remoteUid.value != 0 || isLocalUserJoined.value);

      // 1. Force navigation back FIRST to unmount VideoCallScreen
      if (Get.currentRoute.contains(Routes.VIDEO_CALL)) {
        debugPrint("Navigating away from VideoCallScreen");
        // Force clear the stack and go to home if we are stuck
        Get.offAllNamed(Routes.HOME);
      }

      // 2. Clear system UI
      try {
        await callkit.FlutterCallkitIncoming.endAllCalls();
      } catch (e) {
        debugPrint("Error ending CallKit calls: $e");
      }

      // 3. Release Agora resources
      await leaveChannel();

      // 4. Trigger review sheet if needed (delayed to ensure navigation is complete)
      if (shouldShowReview && callId.isNotEmpty && receiverId.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.bottomSheet(
            ReviewFeedbackSheet(
              sessionId: callId,
              tutorId: receiverId,
              tutorName: receiverName,
              studentId: callerId,
              studentName: callerName,
            ),
            isScrollControlled: true,
            ignoreSafeArea: true,
            backgroundColor: Colors.transparent,
            barrierColor: Colors.black.withAlpha(100),
          );
        });
      }

      // Reset local data
      currentCallData.value = {};
    } catch (e) {
      debugPrint("Error during call cleanup: $e");
    } finally {
      _isCleaningUp = false;
      debugPrint("Cleanup complete.");
    }
  }

  void startCallTimers() {
    // Cancel any existing timers first to be safe
    _warningTimer?.cancel();
    _sessionTimer?.cancel();
    _uiCountdownTimer?.cancel();

    int durationMinutes = currentCallData['duration'] ?? 25;
    int totalSeconds = durationMinutes * 60;

    // 1. Start UI display countdown string timer
    _uiCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (totalSeconds <= 0) {
        _uiCountdownTimer?.cancel();
      } else {
        totalSeconds--;
        int mins = totalSeconds ~/ 60;
        int secs = totalSeconds % 60;
        remainingTimeStr.value = "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
      }
    });

    // 2. Warning alert 1 minute before ending
    if (durationMinutes > 1) {
      _warningTimer = Timer(Duration(minutes: durationMinutes - 1), () {
        Get.snackbar(
          "Session Alert",
          "Your session will automatically end in 1 minute.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.amber,
          colorText: Colors.black,
          duration: const Duration(seconds: 5),
        );
      });
    }

    // 3. Force disconnect timer
    _sessionTimer = Timer(Duration(minutes: durationMinutes), () {
      Get.snackbar(
        "Session Ended",
        "The session duration set by the tutor has been completed.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blueAccent,
        colorText: Colors.white,
      );
      endCall();
    });
  }

  // Initialize Agora Engine
  // Initialize Agora Engine
  Future<void> initAgoraEngine() async {
    if (engine != null) return; // Prevent multiple initializations

    try {
      // Request permissions
      await [Permission.camera, Permission.microphone].request();

      // Create Agora engine
      engine = createAgoraRtcEngine();

      // Initialize Agora
      await engine!.initialize(const RtcEngineContext(appId: appId, channelProfile: ChannelProfileType.channelProfileCommunication));

      // Register event handler
      engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            isLocalUserJoined.value = true;

            // Set initial placeholder before remote joins
            final int durationMinutes = currentCallData['duration'] ?? 25;

            remainingTimeStr.value = "${durationMinutes.toString().padLeft(2, '0')}:00";
          },

          onUserJoined: (RtcConnection connection, int remoteUidValue, int elapsed) {
            remoteUid.value = remoteUidValue;
            isRemoteVideoMuted.value = false;

            // Start timers only when remote user joins
            // (call is accepted/connected)
            startCallTimers();
          },

          onUserOffline: (RtcConnection connection, int remoteUidValue, UserOfflineReasonType reason) {
            remoteUid.value = 0;
            isRemoteVideoMuted.value = false;

            if (!_isCleaningUp) {
              _cleanupCall();
            }
          },

          onUserMuteVideo: (RtcConnection connection, int remoteUidValue, bool muted) {
            if (remoteUidValue == remoteUid.value) {
              isRemoteVideoMuted.value = muted;
            }
          },

          onConnectionStateChanged: (RtcConnection connection, ConnectionStateType state, ConnectionChangedReasonType reason) {
            debugPrint("Agora Connection State: $state, Reason: $reason");
            if (state == ConnectionStateType.connectionStateFailed) {
              if (!_isCleaningUp) _cleanupCall();
            }
          },

          onLeaveChannel: (RtcConnection connection, RtcStats stats) {
            isLocalUserJoined.value = false;
            remoteUid.value = 0;
            isRemoteVideoMuted.value = false;
          },
        ),
      );

      // Set video encoder configuration for better compatibility across devices
      await engine!.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 640, height: 360),
          frameRate: 15,
          bitrate: 0,
          orientationMode: OrientationMode.orientationModeAdaptive,
        ),
      );

      // Enable video and audio
      await engine!.enableVideo();
      await engine!.enableAudio();

      // Set audio scenario for better voice quality in calls
      await engine!.setAudioScenario(AudioScenarioType.audioScenarioGameStreaming);

      // Setup local video for preview
      await engine!.setupLocalVideo(const VideoCanvas(uid: 0, renderMode: RenderModeType.renderModeHidden));

      // Start local camera preview
      await engine!.startPreview();
      isEngineInitialized.value = true;
    } catch (e) {
      debugPrint('Agora initialization error: $e');
      engine = null; // Ensure engine is null if init fails
      isEngineInitialized.value = false;
    }
  }

  // Join Agora Channel
  Future<void> joinChannel() async {
    if (isLocalUserJoined.value) return; // Prevent -17: already joined
    if (engine == null) await initAgoraEngine();

    String channelName = currentCallData['channelName'] ?? '';
    if (channelName.isEmpty) return;

    int durationMinutes = currentCallData['duration'] ?? 25;
    String rtcToken = '';

    try {
      final HttpsCallable callable = _functions.httpsCallable('generateAgoraToken');
      final response = await callable.call(<String, dynamic>{'channelName': channelName, 'uid': 0, 'duration': durationMinutes});

      if (response.data != null && response.data['token'] != null) {
        rtcToken = response.data['token'];
        debugPrint("Agora Token fetched successfully");
      }
    } catch (e) {
      debugPrint("Error fetching Agora Token from Firebase Cloud Function: $e");
    }

    // Explicitly configure client role and audio routing parameters
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
      publishCameraTrack: true,
      publishMicrophoneTrack: true,
      autoSubscribeAudio: true,
      autoSubscribeVideo: true,
      publishScreenTrack: false,
    );

    try {
      debugPrint("Joining Agora channel: $channelName with UID: 0");
      await engine!.joinChannel(token: rtcToken, channelId: channelName, uid: 0, options: options);

      // Ensure speakerphone is on by default for video calls
      await engine!.setEnableSpeakerphone(true);
    } catch (e) {
      debugPrint("Agora Join Error: $e");
    }
  }

  // Leave Agora Channel
  Future<void> leaveChannel() async {
    if (engine != null) {
      try {
        // Explicitly mute local streams and disable camera & mic hardware
        await engine!.muteLocalAudioStream(true);
        await engine!.muteLocalVideoStream(true);
        await engine!.disableAudio();
        await engine!.disableVideo();

        // Add timeout to prevent hanging on leaveChannel if network is bad
        await engine!.leaveChannel().timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            debugPrint("Agora leaveChannel timed out, proceeding to release...");
          },
        );
      } catch (e) {
        debugPrint("Agora leaveChannel error: $e");
      }
      try {
        await engine!.release();
      } catch (e) {
        debugPrint("Agora release error: $e");
      }
      engine = null;
    }
    isLocalUserJoined.value = false;
    isEngineInitialized.value = false;
    remoteUid.value = 0;
    isMuted.value = false;
    isCameraOff.value = false;
  }

  // Mute Audio Toggle
  void toggleMute() {
    isMuted.value = !isMuted.value;
    engine?.muteLocalAudioStream(isMuted.value);
  }

  // Toggle Camera
  void toggleCamera() {
    isCameraOff.value = !isCameraOff.value;
    engine?.muteLocalVideoStream(isCameraOff.value);
  }

  // Switch Front/Rear Camera
  void switchCamera() {
    engine?.switchCamera();
  }

  @override
  void onClose() {
    _callStreamSubscription?.cancel();
    _currentCallSubscription?.cancel();
    leaveChannel();
    super.onClose();
  }
}
