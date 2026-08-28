import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart' as options;

class FirebaseService {
  static FirebaseMessaging? _messaging;
  static bool _initialized = false;
  static bool _available = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Check if Firebase is configured
      await Firebase.initializeApp(
        options: options.DefaultFirebaseOptions.currentPlatform,
      );
      _available = true;
      
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
      _available = false;
      if (kDebugMode) {
        print('Firebase not configured - running without Firebase: $e');
      }
    }
  }

  static Future<void> _requestPermissions() async {
    if (!_available) return;
    
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
    if (!_available) return;
    
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Received foreground message: ${message.notification?.title}');
      }
      // Handle foreground notification display
    });
  }

  static Future<void> _configureBackgroundNotifications() async {
    if (!_available) return;
    
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<String?> getToken() async {
    if (!_available) return null;
    
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