import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:mylifepair_matrimony/firebase_options.dart';

class FirebaseService {
  static FirebaseMessaging? _messaging;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      _messaging = FirebaseMessaging.instance;
      
      // Request notification permissions
      await _requestPermissions();
      
      // Configure foreground notifications
      await _configureForegroundNotifications();
      
      // Configure background notifications
      await _configureBackgroundNotifications();
      
      // Get initial message if app was opened from notification
      RemoteMessage? initialMessage = await _messaging?.getInitialMessage();
      if (initialMessage != null) {
        _handleMessage(initialMessage);
      }
      
      // Handle messages when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
      
      _initialized = true;
      
      if (kDebugMode) {
        print('Firebase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firebase initialization error: $e');
      }
    }
  }

  static Future<void> _requestPermissions() async {
    NotificationSettings settings = await _messaging!.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('Notification permission granted: ${settings.authorizationStatus}');
    }
  }

  static Future<void> _configureForegroundNotifications() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Received foreground message: ${message.notification?.title}');
      }
      // Handle foreground notification display
    });
  }

  static Future<void> _configureBackgroundNotifications() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<String?> getToken() async {
    if (!_initialized) {
      await initialize();
    }
    
    String? token = await _messaging?.getToken();
    if (kDebugMode) {
      print('FCM Token: $token');
    }
    return token;
  }

  static void _handleMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Handling message: ${message.data}');
    }
    // Navigate to appropriate screen based on message data
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('Handling background message: ${message.messageId}');
  }
}