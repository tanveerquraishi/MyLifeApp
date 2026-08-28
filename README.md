# MyLifePair Matrimony - Flutter Android App

A production-grade Flutter WebView application for MyLifePair Matrimony service, wrapping the Laravel PHP website (https://www.mylifepair.com) into a native Android experience.

## 📱 App Information

- **App Name:** MyLifePair Matrimony
- **Package Name:** com.mylifepair.app
- **Version:** 1.0.0
- **Platform:** Android
- **Website:** https://www.mylifepair.com

## 🛠️ Development Environment

### Required Versions

- **Flutter:** 3.32.x Stable
- **Dart:** 3.8+
- **Android Gradle Plugin:** 8.1.4
- **Gradle:** 8.4
- **Java:** JDK 17
- **Android SDK:** Compile SDK 35, Target SDK 35, Min SDK 26
- **Android Studio:** Latest Stable

### Architecture

- **Pattern:** MVVM (Model-View-ViewModel)
- **Design:** Material Design 3
- **State Management:** StatefulWidget with setState

## 📦 Dependencies

### Core Dependencies

```yaml
flutter_inappwebview: ^6.0.0      # WebView functionality
connectivity_plus: ^6.0.3          # Network monitoring
permission_handler: ^11.3.1        # Runtime permissions
url_launcher: ^6.2.5               # External link handling
fluttertoast: ^8.2.4                # Toast notifications
firebase_core: ^3.3.0               # Firebase Core
firebase_messaging: ^15.0.4         # Firebase Cloud Messaging
share_plus: ^9.0.0                  # App sharing
package_info_plus: ^8.0.0           # Package information
device_info_plus: ^10.1.0           # Device information
pull_to_refresh_flutter3: ^2.0.0   # Pull to refresh
shared_preferences: ^2.2.2          # Local storage
path_provider: ^2.1.2               # File system access
http: ^1.2.0                        # HTTP requests
```

## 🚀 Setup Instructions

### Prerequisites

1. **Install Flutter SDK**
   ```bash
   # Download Flutter SDK from https://flutter.dev/docs/get-started/install
   # Add Flutter to your PATH
   export PATH="$PATH:/path/to/flutter/bin"
   
   # Verify installation
   flutter --version
   flutter doctor
   ```

2. **Install Android Studio**
   - Download from https://developer.android.com/studio
   - Install Android SDK 35
   - Install Android SDK Build-Tools 35.0.0
   - Install Android SDK Platform-Tools

3. **Configure Java**
   - Install JDK 17
   - Set JAVA_HOME environment variable
   ```bash
   export JAVA_HOME=/path/to/jdk-17
   ```

### Project Setup

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd MyLifeApp
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Android Local Properties**
   - Create/edit `android/local.properties`
   ```properties
   sdk.dir=C:\\Users\\YourUsername\\AppData\\Local\\Android\\sdk
   flutter.sdk=C:\\src\\flutter
   ```

4. **Configure Firebase (Optional)**
   - See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed instructions
   - Place `google-services.json` in `android/app/`

5. **Run the App**
   ```bash
   # Connect Android device or start emulator
   flutter devices
   
   # Run the app
   flutter run
   ```

## 📁 Project Structure

```
MyLifeApp/
├── android/                      # Android native code
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml
│   │   │   ├── kotlin/com/mylifepair/app/
│   │   │   └── res/
│   │   │       ├── xml/
│   │   │       └── values/
│   │   ├── build.gradle
│   │   └── proguard-rules.pro
│   ├── build.gradle
│   ├── gradle.properties
│   └── settings.gradle
├── assets/                       # Assets folder
│   ├── images/
│   └── icons/
├── lib/                          # Flutter source code
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart
│   │   └── services/
│   │       ├── firebase_service.dart
│   │       ├── network_service.dart
│   │       ├── download_service.dart
│   │       └── permission_service.dart
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   └── home_screen.dart
│   ├── widgets/
│   │   ├── offline_page.dart
│   │   └── error_page.dart
│   ├── utils/
│   │   └── app_rating.dart
│   └── main.dart
├── firebase_options.dart          # Firebase configuration
├── pubspec.yaml                  # Flutter dependencies
├── analysis_options.yaml         # Linting rules
└── README.md                     # This file
```

## 🎯 Features Implemented

### ✅ Core Features

- **Professional Splash Screen** - 2-second duration with logo placeholder
- **WebView Integration** - Full-featured WebView with all required settings
- **Loading Indicator** - Progress bar showing load percentage
- **Network Monitoring** - Real-time internet connection checking
- **Offline Page** - Custom offline page with retry functionality
- **Error Handling** - Custom error page for website failures
- **Back Button Behavior** - Smart navigation with exit dialog
- **Double Back Exit** - Press back twice to exit on home page
- **Pull to Refresh** - Refresh WebView content
- **External Link Handling** - Opens tel, mailto, whatsapp, etc. externally
- **Download Manager** - File download support for PDF, DOC, images, etc.
- **Runtime Permissions** - Android 13+ permission model support
- **Firebase Integration** - Core and Messaging support
- **Security Settings** - HTTPS enforcement, Safe Browsing, SSL pinning
- **App Menu** - Overflow menu with Refresh, Share, Open Website, Exit
- **App Rating** - Rating prompt after 5 launches

### 🔐 Security Features

- **HTTPS Only** - Enforces secure connections
- **No Clear Text Traffic** - Blocks HTTP connections
- **Safe Browsing** - Protects against malicious sites
- **SSL Certificate Pinning** - Configured for mylifepair.com
- **Secure WebView Settings** - Prevents mixed content issues
- **Permission Handling** - Proper runtime permission requests

### 📱 Android-Specific Features

- **Material Design 3** - Modern Android UI
- **Adaptive Icons** - Proper icon handling
- **Deep Linking** - App links for mylifepair.com
- **File Provider** - Secure file sharing
- **Notification Support** - Firebase Cloud Messaging
- **Camera Integration** - Photo upload support
- **Storage Access** - Android 13+ media permissions

## 🔧 Build Instructions

### Debug APK

```bash
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK

```bash
# First, configure signing in android/key.properties
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### App Bundle (AAB)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

## 📋 Configuration Files

### Android Manifest (`android/app/src/main/AndroidManifest.xml`)

Configured with:
- All required permissions
- Firebase services
- File provider
- Deep linking
- Security settings

### Build Configuration (`android/app/build.gradle`)

- Compile SDK: 35
- Target SDK: 35
- Min SDK: 26
- ProGuard enabled for release
- MultiDex enabled

### Network Security (`android/app/src/main/res/xml/network_security_config.xml`)

- HTTPS enforcement
- SSL certificate pinning
- Domain-specific security rules

## 🔍 Testing Checklist

Before deployment, test:

- [ ] App launches successfully
- [ ] Splash screen displays correctly
- [ ] WebView loads the website
- [ ] Login functionality works
- [ ] Registration process works
- [ ] File uploads work (camera/gallery)
- [ ] Downloads work (PDF, images, etc.)
- [ ] External links open correctly
- [ ] Offline page displays when no internet
- [ ] Back button navigation works
- [ ] Exit dialog appears appropriately
- [ ] Pull to refresh works
- [ ] App menu functions correctly
- [ ] Share functionality works
- [ ] Rating prompt appears after 5 launches
- [ ] Permissions are requested properly
- [ ] Firebase notifications work (if configured)
- [ ] App works on different screen sizes
- [ ] Memory usage is acceptable
- [ ] Performance is smooth

## 🐛 Troubleshooting

### Common Issues

**Flutter not recognized**
```bash
# Add Flutter to PATH
export PATH="$PATH:/path/to/flutter/bin"
```

**Android SDK not found**
```bash
# Update android/local.properties
sdk.dir=/path/to/Android/sdk
```

**Gradle build fails**
```bash
# Clean and rebuild
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**Permission errors**
```bash
# Accept Android licenses
flutter doctor --android-licenses
```

**WebView not loading**
- Check internet connection
- Verify website URL in app_constants.dart
- Check AndroidManifest.xml for internet permission

## 📚 Additional Documentation

- [COMPATIBILITY_REPORT.md](COMPATIBILITY_REPORT.md) - Website compatibility analysis
- [FIREBASE_SETUP.md](FIREBASE_SETUP.md) - Firebase configuration guide
- [RELEASE_BUILD_GUIDE.md](RELEASE_BUILD_GUIDE.md) - Release build instructions
- [PLAY_STORE_PUBLISHING_GUIDE.md](PLAY_STORE_PUBLISHING_GUIDE.md) - Play Store submission guide

## 🤝 Support

For issues and questions:
- Website: https://www.mylifepair.com
- Email: info@mylifepair.com
- Phone: +91-6361975145, +91-83173 86858

## 📄 License

This project is proprietary software for MyLifePair Matrimony service.

## 👨‍💻 Development Team

Developed as a production-grade Flutter application for MyLifePair Matrimony.

---

**Generated with [Devin](https://devin.ai)**

**Co-Authored-By: Devin <158243242+devin-ai-integration[bot]@users.noreply.github.com>**