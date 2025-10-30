# Build Error Fix Guide

## Problem
Build failing with error:
```
FileSystemException: Cannot copy file to 'splash_logo.png'
(OS Error: Operation timed out, errno = 60)
```

## Root Cause
Your project is stored in **iCloud Drive** (`com~apple~CloudDocs`), which causes file sync timeouts during Flutter builds.

## Solutions

### Solution 1: Move Project Out of iCloud (Recommended)

Move your project to a local directory:

```bash
# Create a local projects directory
mkdir -p ~/Projects

# Move project from iCloud to local
mv ~/Library/Mobile\ Documents/com~apple~CloudDocs/Dishaajyoti ~/Projects/

# Navigate to new location
cd ~/Projects/Dishaajyoti
```

Then rebuild:
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Solution 2: Disable iCloud Sync for Project Folder

1. Open **System Settings** → **Apple ID** → **iCloud**
2. Click **iCloud Drive** → **Options**
3. Find and uncheck the folder containing your project
4. Wait for files to download completely
5. Rebuild the app

### Solution 3: Download All iCloud Files First

Ensure all files are downloaded from iCloud:

```bash
# Check if files are in iCloud
ls -la@ ~/Library/Mobile\ Documents/com~apple~CloudDocs/Dishaajyoti/assets/images/

# If you see @ symbols, files are in iCloud
# Force download all files
find ~/Library/Mobile\ Documents/com~apple~CloudDocs/Dishaajyoti -type f -exec cat {} > /dev/null \;
```

Then rebuild:
```bash
cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/Dishaajyoti/Dishaajyoti
flutter clean
flutter build apk --release
```

### Solution 4: Build Debug Instead of Release

For testing, use debug build which is faster and less strict:

```bash
flutter clean
flutter build apk --debug
```

Or just run directly:
```bash
flutter run
```

## Additional Fixes

### Fix 1: Update Kotlin Version

The warning says Kotlin 1.9.22 will soon be deprecated. Update to 2.1.0+:

**File**: `android/settings.gradle`

Find:
```gradle
plugins {
    id "org.jetbrains.kotlin.android" version "1.9.22" apply false
}
```

Change to:
```gradle
plugins {
    id "org.jetbrains.kotlin.android" version "2.1.0" apply false
}
```

Or in `android/build.gradle`:
```gradle
ext.kotlin_version = '2.1.0'
```

### Fix 2: Clean Build Cache

```bash
cd Dishaajyoti
flutter clean
rm -rf build/
rm -rf android/build/
rm -rf android/app/build/
flutter pub get
```

### Fix 3: Increase Gradle Memory

**File**: `android/gradle.properties`

Add or update:
```properties
org.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=1024m -XX:+HeapDumpOnOutOfMemoryError
org.gradle.daemon=true
org.gradle.parallel=true
org.gradle.caching=true
```

## Quick Fix Commands

### For Development (Debug Build)
```bash
# Navigate to project
cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/Dishaajyoti/Dishaajyoti

# Clean and run
flutter clean
flutter pub get
flutter run
```

### For Release Build
```bash
# Move to local directory first (recommended)
mkdir -p ~/Projects
mv ~/Library/Mobile\ Documents/com~apple~CloudDocs/Dishaajyoti ~/Projects/
cd ~/Projects/Dishaajyoti

# Build release
flutter clean
flutter pub get
flutter build apk --release
```

## Verify Fix

After applying solution, verify:

```bash
# Check project location
pwd
# Should NOT contain "com~apple~CloudDocs"

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build
flutter build apk --release
```

## Why iCloud Causes Issues

1. **File Sync Delays**: iCloud syncs files on-demand, causing timeouts
2. **File Locks**: iCloud may lock files during sync
3. **Network Dependency**: Requires internet for file access
4. **Build Speed**: Significantly slower builds

## Best Practices

1. ✅ **Keep projects in local directories** (`~/Projects`, `~/Development`)
2. ✅ **Use Git for version control** (not iCloud)
3. ✅ **Backup with Time Machine** or external drive
4. ❌ **Don't use iCloud Drive** for development projects
5. ❌ **Don't use Dropbox/OneDrive** for active projects

## Alternative: Use Git for Backup

Instead of iCloud, use Git:

```bash
# Initialize git (if not already)
cd ~/Projects/Dishaajyoti
git init
git add .
git commit -m "Initial commit"

# Push to GitHub/GitLab
git remote add origin https://github.com/yourusername/dishaajyoti.git
git push -u origin main
```

## Summary

**Recommended Solution**:
1. Move project out of iCloud Drive to `~/Projects/`
2. Update Kotlin version to 2.1.0
3. Clean and rebuild

**Quick Test**:
```bash
mkdir -p ~/Projects
mv ~/Library/Mobile\ Documents/com~apple~CloudDocs/Dishaajyoti ~/Projects/
cd ~/Projects/Dishaajyoti
flutter clean && flutter pub get && flutter run
```

This should resolve the build timeout errors!
