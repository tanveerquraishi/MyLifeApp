# Firebase Setup Guide for MyLifePair Matrimony

This guide will help you configure Firebase for the MyLifePair Matrimony Flutter application, including Firebase Core and Firebase Cloud Messaging (FCM) for push notifications.

## 📋 Prerequisites

- A Google account
- Firebase Console access
- Flutter project set up (see README.md)
- Android Studio installed
- Package name: `com.mylifepair.app`

## 🔥 Step 1: Create Firebase Project

1. **Go to Firebase Console**
   - Visit https://console.firebase.google.com/
   - Sign in with your Google account

2. **Create New Project**
   - Click "Add project"
   - Enter project name: `MyLifePair Matrimony`
   - Accept Firebase terms
   - Click "Create project"

3. **Configure Google Analytics** (Optional)
   - You can enable or skip Google Analytics
   - For production apps, it's recommended to enable it
   - Choose an existing Analytics account or create new one
   - Click "Create project"

## 📱 Step 2: Add Android App to Firebase

1. **Add Android App**
   - In Firebase Console, click the Android icon
   - Enter package name: `com.mylifepair.app`
   - App nickname: `MyLifePair Matrimony` (optional)
   - Debug signing certificate: Leave empty for now
   - Click "Register app"

2. **Download Configuration File**
   - Download `google-services.json`
   - Place it in: `android/app/google-services.json`
   - Click "Next"

## ⚙️ Step 3: Configure Android Project

### 3.1 Add Google Services Plugin

**File: `android/build.gradle`**

Add the Google Services dependency in the `dependencies` block:

```gradle
buildscript {
    // ... existing code ...
    
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.4'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        classpath 'com.google.gms:google-services:4.4.0'  // Add this line
    }
}
```

### 3.2 Apply Google Services Plugin

**File: `android/app/build.gradle`**

Add the Google Services plugin at the top of the file:

```gradle
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
    id "com.google.gms.google-services"  // Add this line
}
```

### 3.3 Add Firebase BOM and Dependencies

**File: `android/app/build.gradle`**

Add Firebase dependencies in the `dependencies` block:

```gradle
dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    implementation 'androidx.multidex:multidex:2.0.1'
    
    // Firebase BOM
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    
    // Firebase Analytics
    implementation 'com.google.firebase:firebase-analytics'
    
    // Firebase Cloud Messaging
    implementation 'com.google.firebase:firebase-messaging'
}
```

## 🔧 Step 4: Update Firebase Options

### 4.1 Install FlutterFire CLI

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Verify installation
flutterfire --version
```

### 4.2 Configure Firebase for Flutter

```bash
# Navigate to project root
cd MyLifeApp

# Configure Firebase
flutterfire configure
```

This will:
- Detect your Firebase project
- Generate `firebase_options.dart` with proper configuration
- Update necessary configuration files

### 4.3 Manual Configuration (Alternative)

If FlutterFire CLI doesn't work, manually update `firebase_options.dart`:

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY_FROM_FIREBASE_CONSOLE',
    appId: 'YOUR_APP_ID_FROM_FIREBASE_CONSOLE',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  );
}
```

To get these values:
1. Go to Firebase Console → Project Settings
2. Scroll to "Your apps" section
3. Select your Android app
4. Copy the values from the configuration snippet

## 🔔 Step 5: Configure Cloud Messaging

### 5.1 Add Notification Icon

Create notification icons in `android/app/src/main/res/`:

- `drawable/ic_notification.png` (24x24px)
- `drawable/ic_notification_large.png` (96x96px)

### 5.2 Configure Notification Channels (Android 8.0+)

The app already handles notification channels in the Firebase service. The default channel is created automatically.

### 5.3 Test FCM Setup

Add test code to verify FCM is working:

```dart
// In your main.dart or a test file
import 'package:mylifepair_matrimony/core/services/firebase_service.dart';

void testFCM() async {
  // Initialize Firebase
  await FirebaseService.initialize();
  
  // Get FCM Token
  String? token = await FirebaseService.getToken();
  print('FCM Token: $token');
}
```

## 🧪 Step 6: Test Firebase Integration

### 6.1 Run the App

```bash
flutter run
```

### 6.2 Check Firebase Console

1. Go to Firebase Console
2. Navigate to your project
3. Check "Project Overview" - you should see your Android app listed
4. Check "Cloud Messaging" - verify it's enabled

### 6.3 Send Test Notification

1. In Firebase Console, go to "Cloud Messaging"
2. Click "Send your first message"
3. Enter notification title and body
4. Select your app as target
5. Click "Send test message"
6. Enter your FCM token (from Step 5.3)
7. Click "Test"

### 6.4 Verify Token Generation

The app should log the FCM token in the console when it starts. You can also add this to your UI for testing:

```dart
// In home_screen.dart or similar
@override
void initState() {
  super.initState();
  _getFCMToken();
}

Future<void> _getFCMToken() async {
  String? token = await FirebaseService.getToken();
  print('FCM Token: $token');
  // You can display this in UI for testing
}
```

## 🌐 Step 7: Server-Side Integration (Optional)

If you want to send notifications from your Laravel backend:

### 7.1 Firebase Admin SDK for PHP

Install the Firebase Admin SDK for PHP:

```bash
composer require kreait/firebase-php
```

### 7.2 Send Notifications from Laravel

```php
use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

$factory = (new Factory)->withServiceAccount('path/to/service-account.json');
$messaging = $factory->createMessaging();

$notification = Notification::create('Title', 'Body');
$message = CloudMessage::withTarget('token', $deviceToken)
    ->withNotification($notification);

$messaging->send($message);
```

### 7.3 Get Service Account Key

1. Go to Firebase Console → Project Settings
2. Go to "Service accounts" tab
3. Click "Generate new private key"
4. Save the JSON file securely
5. Use this file in your Laravel backend

## 🔐 Step 8: Security Best Practices

### 8.1 Never Commit Sensitive Files

Add these to `.gitignore`:

```
android/app/google-services.json
firebase_options.dart (if it contains real keys)
*.json
```

### 8.2 Use Separate Environments

- Use different Firebase projects for development and production
- Never use production keys in development

### 8.3 Secure Your Service Account

- Never commit service account keys
- Store them securely (environment variables, secret management)
- Rotate keys regularly

## 🐛 Troubleshooting

### Issue: "google-services.json not found"

**Solution:**
- Ensure `google-services.json` is in `android/app/` directory
- Check file name spelling
- Verify the file was downloaded for the correct package name

### Issue: "Firebase initialization failed"

**Solution:**
- Check internet connection
- Verify `firebase_options.dart` configuration
- Ensure Google Services plugin is applied correctly
- Check Android logcat for detailed error messages

### Issue: "FCM token is null"

**Solution:**
- Ensure Google Play Services is installed on the test device
- Check if the app has notification permissions
- Verify Firebase project is set up correctly
- Try clearing app data and restarting

### Issue: "Notifications not received"

**Solution:**
- Check notification permissions are granted
- Verify the device is not in Doze mode
- Check if the app is in background/foreground
- Test with the device connected to Android Studio to see logs
- Verify the FCM token is correct

### Issue: "Build fails after adding Firebase"

**Solution:**
- Clean and rebuild: `flutter clean && flutter pub get`
- Update Gradle: `cd android && ./gradlew clean`
- Check for dependency conflicts
- Ensure all versions are compatible

## 📚 Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Cloud Messaging Guide](https://firebase.google.com/docs/cloud-messaging)
- [Firebase Admin SDK for PHP](https://firebase.google.com/docs/admin/setup)

## ✅ Verification Checklist

Before considering Firebase setup complete:

- [ ] Firebase project created
- [ ] Android app added to Firebase
- [ ] `google-services.json` placed in `android/app/`
- [ ] Google Services plugin added to build.gradle
- [ ] Firebase dependencies added
- [ ] `firebase_options.dart` configured
- [ ] App builds successfully
- [ ] Firebase initializes without errors
- [ ] FCM token is generated
- [ ] Test notification received
- [ ] Background notifications work
- [ ] Foreground notifications work
- [ ] Notification click opens app

## 🎯 Next Steps

After completing Firebase setup:

1. Implement server-side notification sending
2. Create notification handling logic in your app
3. Test notification scenarios (foreground, background, terminated)
4. Set up notification analytics
5. Configure notification sounds and icons
6. Test on multiple Android versions

---

**Generated with [Devin](https://devin.ai)**

**Co-Authored-By: Devin <158243242+devin-ai-integration[bot]@users.noreply.github.com>**