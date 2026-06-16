# Android APK Build & Release - Complete Setup Guide

## Overview

Your PDF Chef project is now configured to automatically build and release Android APKs targeting Android 11+ (API level 30+). The APK wraps your web application in a native Android WebView.

## What Was Created

### 1. Android Project Structure (`/android/`)

```
android/
├── app/
│   ├── build.gradle                    # App-level build configuration
│   ├── proguard-rules.pro              # Code obfuscation rules
│   └── src/main/
│       ├── AndroidManifest.xml         # App manifest
│       ├── java/com/pdfchef/app/
│       │   └── MainActivity.kt         # WebView activity (Kotlin)
│       └── res/
│           ├── layout/activity_main.xml
│           ├── values/
│           │   ├── colors.xml
│           │   ├── strings.xml
│           │   └── styles.xml
│           └── xml/
│               ├── file_paths.xml      # File provider config
│               ├── data_extraction_rules.xml
│               └── backup_rules.xml
├── build.gradle                         # Root gradle config
├── settings.gradle                      # Project settings
├── gradle.properties                    # Gradle properties
└── gradle/wrapper/                      # Gradle wrapper (reproducible builds)
```

### 2. GitHub Actions Workflow (`.github/workflows/build-android.yml`)

- **Trigger**: Automatically on version tags (`git tag v1.0.0`)
- **Manual Trigger**: Available via GitHub Actions interface
- **Process**:
  1. Checks out code
  2. Sets up JDK 11
  3. Decodes keystore from secrets
  4. Builds release APK with signing
  5. Creates GitHub Release
  6. Uploads APK to release
  7. Saves as artifact

### 3. Documentation & Scripts

- `android/README.md` - Comprehensive setup and troubleshooting guide
- `android/QUICK_START.md` - Quick reference for common tasks
- `android/setup-keystore.sh` - Automated keystore setup script
- `android/.gitignore` - Prevents committing keystore files

## Quick Setup (5 minutes)

### Step 1: Generate and Configure Keystore

```bash
cd android
chmod +x setup-keystore.sh
./setup-keystore.sh
```

This script will:
- Generate a keystore (or use existing one)
- Encode it to Base64
- Display the value to copy

### Step 2: Add GitHub Secrets

Go to: **GitHub Repository → Settings → Secrets and variables → Actions**

Click **"New repository secret"** and add these 4 secrets:

1. **KEYSTORE_ENCODED**
   - Paste the Base64-encoded keystore from the script output

2. **KEYSTORE_PASSWORD**
   - The password you entered when creating the keystore

3. **KEY_ALIAS**
   - The key alias (default: `pdf-chef-key`)

4. **KEY_PASSWORD**
   - The key password you entered

### Step 3: Trigger the Build

Option A - Create a version tag:
```bash
git tag v1.0.0
git push origin v1.0.0
```

Option B - Manual trigger in GitHub Actions UI:
- Go to Actions → "Build Android APK" → "Run workflow"

### Step 4: Download the APK

After the workflow completes:
1. Go to GitHub Releases
2. Download the APK (e.g., `pdf-chef-v1.0.0.apk`)
3. Install on Android device or emulator

## App Configuration

### Target URL
By default, the app loads from `https://pdfchef.dev`. To change this:

Edit `android/app/src/main/java/com/pdfchef/app/MainActivity.kt`:
```kotlin
private fun loadWebApp() {
    binding.webview.loadUrl("https://your-domain.com")
}
```

Or to load a local HTML file:
```kotlin
binding.webview.loadUrl("file:///android_asset/index.html")
```

### App Name and Branding
Edit `android/app/src/main/res/values/strings.xml`:
```xml
<string name="app_name">Your App Name</string>
```

### App Colors
Edit `android/app/src/main/res/values/colors.xml`:
```xml
<color name="primary_color">#4F46E5</color>
<color name="primary_dark_color">#4338CA</color>
<color name="accent_color">#06B6D4</color>
```

## Permissions

The app requests these permissions:
- `INTERNET` - Web access (required)
- `CAMERA` - Optional for camera features
- `READ_EXTERNAL_STORAGE` - File access
- `WRITE_EXTERNAL_STORAGE` - File saving
- `ACCESS_FINE_LOCATION` - Optional location services

To customize, edit `android/app/src/main/AndroidManifest.xml`.

## Building Locally

### Without Signing (Debug APK)
```bash
cd android
./gradlew assembleDebug
# Output: app/build/outputs/apk/debug/app-debug.apk
```

### With Signing (Release APK)
```bash
cd android
./gradlew clean assembleRelease \
  -Pandroid.injected.signing.store.file=release-keystore.jks \
  -Pandroid.injected.signing.store.password=YOUR_PASSWORD \
  -Pandroid.injected.signing.key.alias=pdf-chef-key \
  -Pandroid.injected.signing.key.password=YOUR_PASSWORD
# Output: app/build/outputs/apk/release/app-release.apk
```

## Testing

### On Android Emulator
```bash
# List emulators
emulator -list-avds

# Start emulator
emulator -avd <emulator_name>

# Install APK
adb install -r app/build/outputs/apk/debug/app-debug.apk

# View logs
adb logcat
```

### On Physical Device
1. Enable Developer Mode (tap Build Number 7 times)
2. Enable USB Debugging
3. Connect via USB
4. Run: `adb install -r app/build/outputs/apk/release/app-release.apk`

## Specifications

| Feature | Value |
|---------|-------|
| **Min SDK** | 30 (Android 11) |
| **Target SDK** | 34 (Android 14) |
| **Compile SDK** | 34 |
| **Language** | Kotlin |
| **Build System** | Gradle 8.2 |
| **JDK** | Java 11+ |
| **APK Size** | ~50-70 MB |
| **Architectures** | ARM64, x86_64 |

## Version Numbering

The app uses semantic versioning:
- **vMAJOR.MINOR.PATCH** (e.g., v1.0.0, v1.2.3)
- Increments trigger new builds and releases
- Each version gets its own APK on GitHub Releases

## Security Features

✓ Keystore stored securely in GitHub Secrets  
✓ APK signed for app store compatibility  
✓ ProGuard code obfuscation  
✓ Cleartext traffic disabled (HTTPS only)  
✓ Whitelisted domains for security  
✓ File provider for safe file sharing  

## Troubleshooting

### "Keystore not found" error
```bash
# Regenerate keystore
cd android
./setup-keystore.sh
```

### Build fails with Gradle error
```bash
cd android
./gradlew clean --no-daemon
./gradlew assembleRelease --no-daemon -i
```

### Permissions denied
```bash
chmod +x android/gradlew
```

### APK won't install on device
- Check Android version (requires 11+)
- Uninstall previous version: `adb uninstall com.pdfchef.app`
- Reinstall: `adb install -r app/build/outputs/apk/release/app-release.apk`

### WebView not loading content
- Check internet connection
- Verify URL in MainActivity.kt
- Check logcat for network errors: `adb logcat`

## Next Steps

1. ✅ Run the keystore setup script
2. ✅ Add GitHub Secrets
3. ✅ Create and push a version tag
4. ✅ Monitor the build in GitHub Actions
5. ✅ Download and test the APK
6. ✅ Publish to app stores (optional)

## Additional Resources

- [Android Developer Guide](https://developer.android.com)
- [Gradle Documentation](https://gradle.org/guides)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Kotlin Language](https://kotlinlang.org)

## Support

For issues:
- Check `android/README.md` for detailed troubleshooting
- Review GitHub Actions logs: Actions → Build Android APK → Failed run
- Check `adb logcat` for app runtime errors

---

**Build Status**: ✅ Ready to build  
**Last Updated**: 2026-06-16  
**Android Support**: API 30+ (Android 11+)
