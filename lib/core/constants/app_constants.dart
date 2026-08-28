import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'MyLifePair Matrimony';
  static const String packageName = 'com.mylifepair.app';
  static const String version = '1.0.0';
  static const int buildNumber = 1;

  // Website URL
  static const String websiteUrl = 'https://www.mylifepair.com';

  // Colors
  static const Color primaryColor = Color(0xFFE91E63); // Pink
  static const Color secondaryColor = Color(0xFF9C27B0); // Purple
  static const Color accentColor = Color(0xFFFF5722); // Orange
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color textColor = Color(0xFF212121);
  static const Color secondaryTextColor = Color(0xFF757575);

  // Splash Screen
  static const int splashDuration = 2; // seconds

  // WebView Settings
  static const bool enableJavaScript = true;
  static const bool enableDomStorage = true;
  static const bool enableCookies = true;
  static const bool enableCache = true;
  static const bool enableZoom = true;
  static const bool enableDefaultContextMenu = true;

  // Download Settings
  static const List<String> supportedFileTypes = [
    '.pdf',
    '.doc',
    '.docx',
    '.png',
    '.jpg',
    '.jpeg',
    '.zip',
  ];

  // External Link Patterns
  static const List<String> externalLinkPatterns = [
    'tel:',
    'mailto:',
    'sms:',
    'whatsapp://',
    'wa.me',
    'maps.google.com',
    'geo:',
  ];

  // Rating
  static const int ratingPromptLaunchCount = 5;
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=$packageName';

  // Storage Keys
  static const String keyLaunchCount = 'launch_count';
  static const String keyRated = 'has_rated';
  static const String keyLastRatingPrompt = 'last_rating_prompt';

  // Timeout
  static const int backPressTimeout = 2; // seconds
  static const int connectionTimeout = 30; // seconds
}