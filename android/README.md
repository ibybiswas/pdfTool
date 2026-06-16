# PDF Chef Android Build Setup

This guide explains how to set up the Android build environment and configure the GitHub Actions workflow to automatically build and release Android APKs.

## Prerequisites

- Android SDK (API level 30+)
- Java Development Kit 11 or higher
- Gradle 8.2+
- Keystore file for signing

## Project Structure

```
android/
├── app/
│   ├── src/
│   │   └── main/
│   │       ├── java/com/pdfchef/app/
│   │       │   └── MainActivity.kt
│   │       ├── res/
│   │       │   ├── layout/
│   │       │   ├── values/
│   │       │   └── xml/
│   │       └── AndroidManifest.xml
│   ├── build.gradle
│   └── proguard-rules.pro
├── build.gradle
├── settings.gradle
└── gradle/
    └── wrapper/
        └── gradle-wrapper.properties
```

## Local Build

### 1. Build Unsigned APK

```bash
cd android
chmod +x gradlew
./gradlew clean assembleRelease
```

The APK will be generated at: `app/build/outputs/apk/release/app-release-unsigned.apk`

### 2. Create/Import Keystore

If you don't have a keystore, create one:

```bash
keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias
```

Keep this file secure and never commit it to version control.

### 3. Build Signed APK

```bash
cd android
./gradlew clean assembleRelease \
  -Pandroid.injected.signing.store.file=/path/to/keystore.jks \
  -Pandroid.injected.signing.store.password=your-keystore-password \
  -Pandroid.injected.signing.key.alias=your-key-alias \
  -Pandroid.injected.signing.key.password=your-key-password
```

## GitHub Actions Automation

### Setup

1. **Generate Keystore (if not already done)**

   ```bash
   keytool -genkey -v -keystore release-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias pdf-chef-key
   ```

2. **Encode Keystore to Base64**

   ```bash
   base64 -i release-keystore.jks -o keystore.b64
   # On macOS: base64 -i release-keystore.jks -o keystore.b64
   ```

3. **Add GitHub Secrets**

   Go to your GitHub repository settings → Secrets and variables → Actions → New repository secret

   Add the following secrets:

   - **KEYSTORE_ENCODED**: Paste the contents of `keystore.b64`
   - **KEYSTORE_PASSWORD**: Your keystore password
   - **KEY_ALIAS**: Your key alias (e.g., `pdf-chef-key`)
   - **KEY_PASSWORD**: Your key password

### Automated Build Trigger

The workflow automatically builds and releases an APK whenever you push a tag starting with `v`:

```bash
git tag v1.0.0
git push origin v1.0.0
```

This will:
1. Build the release APK
2. Create a GitHub Release
3. Upload the APK to the release
4. Generate release notes

### Manual Trigger

You can also manually trigger the build from GitHub Actions without creating a tag:

1. Go to Actions → Build Android APK
2. Click "Run workflow"
3. The APK will be built and available as an artifact

## APK Details

- **Target SDK**: 34 (Android 14)
- **Min SDK**: 30 (Android 11)
- **Architecture**: Supports ARM64 and x86_64
- **Size**: ~50-70 MB (depending on build)

## Testing the APK

### On Emulator

```bash
# List connected devices
adb devices

# Install APK
adb install -r app/build/outputs/apk/release/app-release.apk

# Or with a specific device
adb -s <device_id> install -r app/build/outputs/apk/release/app-release.apk
```

### On Physical Device

1. Enable Developer Mode (tap Build Number 7 times in Settings)
2. Enable USB Debugging
3. Connect device via USB
4. Run: `adb install -r app/build/outputs/apk/release/app-release.apk`

## Configuration

### App Configuration

Edit `android/app/src/main/java/com/pdfchef/app/MainActivity.kt`:

```kotlin
private fun loadWebApp() {
    // Change this URL to your production domain
    binding.webview.loadUrl("https://pdfchef.dev")
}
```

### Permissions

Edit `android/app/src/main/AndroidManifest.xml` to customize permissions:

- `INTERNET` - Required for web access
- `CAMERA` - Optional, for PDF capture
- `READ_EXTERNAL_STORAGE` - For file access
- `WRITE_EXTERNAL_STORAGE` - For saving files

### App Name and Colors

- **App Name**: Edit `android/app/src/main/res/values/strings.xml`
- **Colors**: Edit `android/app/src/main/res/values/colors.xml`
- **Theme**: Edit `android/app/src/main/res/values/styles.xml`

## Security Considerations

1. **Never commit keystore files** - Keep `release-keystore.jks` out of version control
2. **Use strong passwords** - Keystore and key passwords should be strong
3. **Rotate keys periodically** - Consider updating your signing key annually
4. **Store secrets safely** - Use GitHub Secrets, not environment variables

## Troubleshooting

### Build Fails with Gradle Error

```bash
cd android
./gradlew clean --no-daemon
./gradlew assembleRelease --no-daemon
```

### Permission Denied on Linux

```bash
chmod +x android/gradlew
```

### Keystore Invalid Password

Verify your keystore file and password:

```bash
keytool -list -v -keystore release-keystore.jks
```

### APK Not Found

Check the build output:

```bash
cd android
./gradlew clean assembleRelease -i
# Look for the output path in the logs
```

## Release Notes

The GitHub Action automatically generates release notes including:
- Build timestamp
- Commit hash
- Installation instructions
- Android compatibility information

## Support

For issues with:
- **Android build**: Check Gradle documentation
- **GitHub Actions**: See `.github/workflows/build-android.yml`
- **App functionality**: Check the web app documentation in the main repository

## License

Same as the main PDF Chef project - see LICENSE file.
