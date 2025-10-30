# Quick Fix: Google Sign-In Error

## The Problem
You're seeing this error when clicking "Continue with Google":
```
PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10:, null, null)
```

## The Solution (5 Minutes)

### Step 1: Get SHA-1 Fingerprint (1 minute)

Open terminal and run:
```bash
cd Dishaajyoti/android
./gradlew signingReport
```

Look for output like this:
```
Variant: debug
Config: debug
Store: ~/.android/debug.keystore
Alias: AndroidDebugKey
MD5: XX:XX:XX:...
SHA1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD
SHA-256: ...
```

**Copy the SHA1 value** (the long string with colons)

### Step 2: Add to Firebase (2 minutes)

1. Go to https://console.firebase.google.com/
2. Select your project
3. Click ⚙️ (Settings) → Project settings
4. Scroll to "Your apps" section
5. Find your Android app
6. Click "Add fingerprint"
7. Paste your SHA-1
8. Click "Save"

### Step 3: Download New Config (1 minute)

1. Still in Firebase Console
2. Click "Download google-services.json"
3. Replace file at: `Dishaajyoti/android/app/google-services.json`

### Step 4: Rebuild App (1 minute)

```bash
cd Dishaajyoti
flutter clean
flutter pub get
flutter run
```

### Step 5: Test (30 seconds)

1. Open app
2. Click "Continue with Google"
3. Select account
4. ✅ Should work!

## Still Not Working?

### Check 1: Verify SHA-1 in Firebase
- Go back to Firebase Console
- Project Settings → Your apps
- Verify SHA-1 is listed under "SHA certificate fingerprints"

### Check 2: Verify Package Name
- In Firebase Console, check package name is: `com.dishaajyoti.app`
- In `android/app/build.gradle`, check `applicationId "com.dishaajyoti.app"`

### Check 3: Enable Google Sign-In
- Firebase Console → Authentication
- Sign-in method tab
- Ensure "Google" is **Enabled**

### Check 4: Google Play Services
- Ensure Google Play Services is installed on your device/emulator
- Update to latest version

## For Release Build

When building for release, you need to add the **release SHA-1** too:

```bash
keytool -list -v -keystore /path/to/your/release.keystore -alias your-key-alias
```

Add this SHA-1 to Firebase Console as well.

## Quick Troubleshooting

| Error | Solution |
|-------|----------|
| Error 10 | SHA-1 not configured (follow steps above) |
| Error 12500 | OAuth client not configured properly |
| "Developer Error" | SHA-1 mismatch or not added |
| Sign-in cancelled | User cancelled (not an error) |
| Network error | Check internet connection |

## Need More Help?

See the detailed guide: `GOOGLE_SIGNIN_FIX.md`

---

**TL;DR**: Get SHA-1 → Add to Firebase → Download new google-services.json → Rebuild app → Test
