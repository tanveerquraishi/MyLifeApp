# Release Build Guide for MyLifePair Matrimony

This guide provides step-by-step instructions for creating production-ready release builds of the MyLifePair Matrimony Flutter application, including signed APK and App Bundle (AAB) files.

## 📋 Prerequisites

- Flutter SDK installed and configured
- Android Studio installed
- JDK 17 installed
- Android SDK 35 installed
- Project set up and tested in debug mode
- Keystore file for signing (or instructions to create one)

## 🔐 Step 1: Generate Signing Keystore

### 1.1 Create Keystore File

Generate a keystore file for signing your release builds:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Important Information:**
- Store the keystore file securely
- Remember the passwords (store password and key password)
- Never commit the keystore file to version control
- Keep backup copies of the keystore file

**During Keystore Creation:**
- Enter a strong store password (minimum 6 characters)
- Re-enter store password
- Enter your name, organization, city, state, and country code
- Enter a strong key password (can be same as store password)
- Re-enter key password

### 1.2 Store Keystore Securely

```bash
# Move keystore to a secure location
mv ~/upload-keystore.jks /secure/location/

# Set appropriate permissions
chmod 600 /secure/location/upload-keystore.jks
```

## ⚙️ Step 2: Configure Signing in Project

### 2.1 Create key.properties File

Create `android/key.properties` file:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=/path/to/your/upload-keystore.jks
```

**Important:**
- Replace `YOUR_STORE_PASSWORD` with your actual store password
- Replace `YOUR_KEY_PASSWORD` with your actual key password
- Replace `/path/to/your/upload-keystore.jks` with actual path to your keystore
- Never commit this file to version control
- Add `android/key.properties` to `.gitignore`

### 2.2 Update .gitignore

Add these lines to `.gitignore`:

```
android/key.properties
*.jks
*.keystore
```

### 2.3 Verify Build Configuration

The `android/app/build.gradle` file should already be configured with signing (as set up in the project). Verify it contains:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

## 🏗️ Step 3: Build Release APK

### 3.1 Clean Previous Builds

```bash
flutter clean
cd android
./gradlew clean
cd ..
```

### 3.2 Get Dependencies

```bash
flutter pub get
```

### 3.3 Build Release APK

```bash
flutter build apk --release
```

**Output Location:**
`build/app/outputs/flutter-apk/app-release.apk`

### 3.4 Verify APK

```bash
# Check APK size
ls -lh build/app/outputs/flutter-apk/app-release.apk

# Verify APK signature
apksigner verify build/app/outputs/flutter-apk/app-release.apk

# Get APK info
aapt dump badging build/app/outputs/flutter-apk/app-release.apk
```

## 📦 Step 4: Build App Bundle (AAB)

### 4.1 Build Release AAB

```bash
flutter build appbundle --release
```

**Output Location:**
`build/app/outputs/bundle/release/app-release.aab`

### 4.2 Verify AAB

```bash
# Check AAB size
ls -lh build/app/outputs/bundle/release/app-release.aab

# Verify AAB structure
unzip -l build/app/outputs/bundle/release/app-release.aab
```

## 🧪 Step 5: Test Release Build

### 5.1 Install Release APK

```bash
# Install on connected device
adb install build/app/outputs/flutter-apk/app-release.apk

# Or install with replacement
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

### 5.2 Test Critical Features

Test all features in release mode:
- [ ] App launches successfully
- [ ] Splash screen displays
- [ ] WebView loads website
- [ ] Login works
- [ ] Registration works
- [ ] File uploads work
- [ ] Downloads work
- [ ] Permissions are requested
- [ ] Network handling works
- [ ] Back button behavior
- [ ] Pull to refresh
- [ ] External links
- [ ] App menu
- [ ] Share functionality
- [ ] Rating prompt
- [ ] Firebase notifications (if configured)

### 5.3 Check Logs

```bash
# View logs while testing
adb logcat | grep -E "flutter|mylifepair"

# Or filter by package
adb logcat | grep "com.mylifepair.app"
```

## 🔍 Step 6: Optimize Build Size

### 6.1 Analyze APK Size

```bash
# Analyze APK contents
flutter build apk --analyze-size
```

### 6.2 Enable Code Shrinking

The project already has ProGuard enabled in release builds. Verify `android/app/build.gradle`:

```gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

### 6.3 Split APK by ABI (Optional)

To create separate APKs for different architectures:

```bash
flutter build apk --release --split-per-abi
```

This creates:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM)
- `app-x86_64-release.apk` (x86_64)

## 🚀 Step 7: Build Variants

### 7.1 Debug Build

```bash
flutter build apk --debug
```

### 7.2 Profile Build

```bash
flutter build apk --profile
```

### 7.3 Release Build with Specific Flavor

If you have build flavors configured:

```bash
flutter build apk --release --flavor production
flutter build appbundle --release --flavor production
```

## 📊 Step 8: Version Management

### 8.1 Update Version Numbers

Update version in `pubspec.yaml`:

```yaml
version: 1.0.0+1  # version+buildNumber
```

### 8.2 Update Android Version

The build.gradle automatically uses version from pubspec.yaml, but you can also set manually:

```gradle
defaultConfig {
    versionCode 1
    versionName "1.0.0"
}
```

### 8.3 Version Naming Convention

Use semantic versioning: `MAJOR.MINOR.PATCH`
- MAJOR: Incompatible changes
- MINOR: New features, backward compatible
- PATCH: Bug fixes, backward compatible

## 🔧 Step 9: Troubleshooting Build Issues

### Issue: "Keystore file not found"

**Solution:**
- Verify `key.properties` file exists
- Check the path in `key.properties`
- Ensure keystore file exists at specified location
- Check file permissions

### Issue: "Invalid keystore password"

**Solution:**
- Verify passwords in `key.properties`
- Ensure no extra spaces or special characters
- Try recreating keystore if password is lost

### Issue: "Build fails with ProGuard errors"

**Solution:**
- Check `android/app/proguard-rules.pro`
- Add missing ProGuard rules
- Temporarily disable minification to test:
  ```gradle
  buildTypes {
      release {
          minifyEnabled false
          shrinkResources false
      }
  }
  ```

### Issue: "Out of memory during build"

**Solution:**
- Increase Gradle memory in `android/gradle.properties`:
  ```properties
  org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=512m
  ```

### Issue: "Dependency conflicts"

**Solution:**
- Clean and rebuild
- Update dependencies in `pubspec.yaml`
- Check for conflicting library versions
- Use `flutter pub deps` to analyze dependencies

## 📝 Step 10: Build Verification Checklist

Before releasing, verify:

- [ ] Keystore file is secure and backed up
- [ ] `key.properties` is configured correctly
- [ ] Build completes without errors
- [ ] APK/AAB is generated successfully
- [ ] App installs without issues
- [ ] All features work in release build
- [ ] App size is acceptable
- [ ] Version number is correct
- [ ] Package name is correct
- [ ] Permissions are correct
- [ ] Firebase is configured (if used)
- [ ] Security settings are enabled
- [ ] ProGuard is working correctly
- [ ] No debug code remains
- [ ] Logs are disabled in release

## 🎯 Step 11: Pre-Release Testing

### 11.1 Beta Testing

Distribute beta builds to testers:
- Use Firebase App Distribution
- Use Google Play Console internal testing
- Use direct APK distribution

### 11.2 Performance Testing

Test app performance:
- Launch time
- Memory usage
- Battery consumption
- Network usage
- WebView loading speed

### 11.3 Compatibility Testing

Test on different devices:
- Various Android versions (8.0+)
- Different screen sizes
- Different manufacturers
- Low-end and high-end devices

## 📦 Step 12: Archive Builds

### 12.1 Archive Release Builds

Create a systematic archive structure:

```
releases/
├── v1.0.0/
│   ├── app-release.apk
│   ├── app-release.aab
│   ├── build-info.txt
│   └── checksums.txt
├── v1.0.1/
│   └── ...
```

### 12.2 Generate Checksums

```bash
# Generate SHA-256 checksums
shasum -a 256 build/app/outputs/flutter-apk/app-release.apk > checksums.txt
shasum -a 256 build/app/outputs/bundle/release/app-release.aab >> checksums.txt
```

### 12.3 Document Build Information

Create `build-info.txt` with:
- Version number
- Build date
- Flutter version
- Dependencies
- Changes made
- Known issues

## 🔐 Step 13: Security Considerations

### 13.1 Protect Signing Keys

- Never commit keystore files
- Store keystore in secure location
- Use strong passwords
- Limit access to keystore
- Keep backup copies
- Document keystore location and passwords securely

### 13.2 Verify Release Integrity

```bash
# Verify APK signature
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk

# Check for tampering
apksigner verify build/app/outputs/flutter-apk/app-release.apk
```

### 13.3 Remove Debug Information

Ensure release builds don't contain:
- Debug logs
- Debug menus
- Test data
- Hardcoded credentials
- Debug certificates

## 📚 Additional Resources

- [Flutter Build and Release](https://flutter.dev/docs/deployment/android)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [Google Play App Bundle](https://developer.android.com/guide/app-bundle)
- [ProGuard Guide](https://developer.android.com/studio/build/shrink-code)

## ✅ Build Commands Summary

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Build release AAB
flutter build appbundle --release

# Build with split APKs
flutter build apk --release --split-per-abi

# Analyze size
flutter build apk --analyze-size

# Install on device
adb install build/app/outputs/flutter-apk/app-release.apk
```

## 🎉 Next Steps

After successful release build:

1. Complete Play Store publishing (see PLAY_STORE_PUBLISHING_GUIDE.md)
2. Distribute to beta testers
3. Gather feedback
4. Monitor crash reports
5. Plan next release

---

**Generated with [Devin](https://devin.ai)**

**Co-Authored-By: Devin <158243242+devin-ai-integration[bot]@users.noreply.github.com>**