# Android Build & Release Quick Start

## 1. Set Up Keystore (One-time setup)

```bash
cd android
chmod +x setup-keystore.sh
./setup-keystore.sh
```

This script will:
- Generate a keystore if needed
- Encode it to Base64
- Show you what to add to GitHub Secrets

## 2. Add GitHub Secrets

Go to your repository → Settings → Secrets and variables → Actions

Add 4 secrets:
- `KEYSTORE_ENCODED` - Base64-encoded keystore
- `KEYSTORE_PASSWORD` - Your keystore password
- `KEY_ALIAS` - Key alias (default: pdf-chef-key)
- `KEY_PASSWORD` - Key password

## 3. Create a Release

```bash
git tag v1.0.0
git push origin v1.0.0
```

The GitHub Action will automatically:
- ✓ Build the APK
- ✓ Sign it with your keystore
- ✓ Create a GitHub Release
- ✓ Upload the APK to the release
- ✓ Save it as an artifact

## 4. Download and Install

1. Go to GitHub Releases page
2. Download the APK
3. Install on your Android device (Android 11+)

---

## Manual Local Build

```bash
cd android
./gradlew clean assembleRelease
```

APK location: `app/build/outputs/apk/release/app-release.apk`

## Troubleshooting

**Keystore issues?**
```bash
keytool -list -v -keystore release-keystore.jks
```

**Build fails?**
```bash
cd android
./gradlew clean --no-daemon
./gradlew assembleRelease -i
```

**See full setup guide:** `android/README.md`
