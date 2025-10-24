# iOS Project Setup

## Current Status

The iOS project structure is incomplete. To enable iOS app icons and splash screens, you need to properly set up the iOS project.

## Setup Steps

### Option 1: Recreate iOS Project (Recommended)

If you have a backup of your project or can recreate it:

1. **Backup your current code:**
   ```bash
   # Backup lib, assets, and configuration files
   cp -r lib lib_backup
   cp -r assets assets_backup
   cp pubspec.yaml pubspec.yaml.backup
   ```

2. **Create a new Flutter project with the same name:**
   ```bash
   cd ..
   flutter create --org com.dishaajyoti dishaajyoti_new
   ```

3. **Copy your code back:**
   ```bash
   cp -r lib_backup/* dishaajyoti_new/lib/
   cp -r assets_backup/* dishaajyoti_new/assets/
   # Merge pubspec.yaml dependencies
   ```

4. **Enable iOS icons and splash:**
   - Update `pubspec.yaml`: Set `ios: true` in both `flutter_launcher_icons` and `flutter_native_splash` sections
   - Run: `dart run flutter_launcher_icons`
   - Run: `dart run flutter_native_splash:create`

### Option 2: Manual iOS Project Setup

If you want to keep the current project structure:

1. **Create the Xcode project structure:**
   ```bash
   mkdir -p ios/Runner.xcodeproj
   mkdir -p ios/Runner.xcworkspace
   ```

2. **Use Flutter to regenerate iOS files:**
   ```bash
   flutter create --platforms=ios .
   ```
   
   This will regenerate the iOS project files without affecting your existing code.

3. **Update pubspec.yaml:**
   - Set `ios: true` in `flutter_launcher_icons` configuration
   - Set `ios: true` in `flutter_native_splash` configuration
   - Uncomment iOS-specific settings

4. **Generate iOS assets:**
   ```bash
   flutter pub get
   dart run flutter_launcher_icons
   dart run flutter_native_splash:create
   ```

### Option 3: Android-Only Development

If you're only targeting Android for now:

- The current setup is complete for Android
- iOS can be added later when needed
- All app icons and splash screens are properly configured for Android

## Verification

After setting up iOS, verify the following files exist:

### App Icons
```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
├── Contents.json
├── Icon-App-20x20@1x.png
├── Icon-App-20x20@2x.png
├── Icon-App-20x20@3x.png
├── Icon-App-29x29@1x.png
├── Icon-App-29x29@2x.png
├── Icon-App-29x29@3x.png
├── Icon-App-40x40@1x.png
├── Icon-App-40x40@2x.png
├── Icon-App-40x40@3x.png
├── Icon-App-60x60@2x.png
├── Icon-App-60x60@3x.png
├── Icon-App-76x76@1x.png
├── Icon-App-76x76@2x.png
├── Icon-App-83.5x83.5@2x.png
└── Icon-App-1024x1024@1x.png
```

### Splash Screen
```
ios/Runner/Assets.xcassets/LaunchImage.imageset/
├── Contents.json
├── LaunchImage.png
├── LaunchImage@2x.png
└── LaunchImage@3x.png
```

### Xcode Project
```
ios/Runner.xcodeproj/project.pbxproj
ios/Runner.xcworkspace/contents.xcworkspacedata
```

## Testing

### Android
```bash
flutter run -d android
```

### iOS (after setup)
```bash
flutter run -d ios
# Or open in Xcode:
open ios/Runner.xcworkspace
```

## Troubleshooting

### "No such file or directory" errors
- The iOS project structure is incomplete
- Follow Option 1 or Option 2 above to set up iOS properly

### Icons not showing on iOS
1. Clean the build: `flutter clean`
2. Regenerate icons: `dart run flutter_launcher_icons`
3. Rebuild: `flutter run`
4. If still not working, open in Xcode and clean build folder (Cmd+Shift+K)

### Splash screen not showing on iOS
1. Ensure `flutter_native_splash` ran successfully
2. Check that LaunchScreen.storyboard exists
3. Clean and rebuild the project

## Resources

- [Flutter iOS Setup](https://docs.flutter.dev/get-started/install/macos#ios-setup)
- [Xcode Setup](https://developer.apple.com/xcode/)
- [iOS App Icon Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [iOS Launch Screen](https://developer.apple.com/design/human-interface-guidelines/launching)
