# App Icons and Splash Screen Setup

This document explains how to set up app icons and splash screens for the DishaAjyoti Flutter application.

## Overview

The app uses:
- **App Icon**: 1024x1024 PNG with gradient background (blue to orange) and "DA" initials
- **Adaptive Icon** (Android): Foreground layer with "DA" on white circle, blue background
- **Splash Screen**: Blue background with white "DA" logo

## Color Scheme

- Primary Blue: `#0066CC`
- Accent Orange: `#FF6B35`
- Text/Logo: White `#FFFFFF`

## Current Status

✅ **Android**: App icons and splash screens are fully configured and generated
⚠️ **iOS**: Requires iOS project setup (see IOS_SETUP.md)

The placeholder assets have been created and Android platform-specific assets have been generated successfully.

## Quick Setup

### Option 1: Using Pre-generated Assets (Recommended)

If you have the design assets ready:

1. Place your app icon (1024x1024 PNG) at: `assets/icons/app_icon.png`
2. Place your adaptive icon foreground (432x432 PNG) at: `assets/icons/app_icon_foreground.png`
3. Place your splash logo (512x512 PNG) at: `assets/images/splash_logo.png`

Then run:

```bash
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

**Note**: Currently configured for Android only. For iOS setup, see IOS_SETUP.md

### Option 2: Regenerate Placeholder Assets

Placeholder assets have already been generated. To regenerate them:

```bash
node create_minimal_pngs.js
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

**Note**: The current placeholders are solid color PNGs. For production, replace with professionally designed assets.

### Option 3: Manual Creation

Create the following assets manually using your preferred design tool (Figma, Photoshop, etc.):

#### 1. App Icon (`assets/icons/app_icon.png`)
- Size: 1024x1024 px
- Format: PNG
- Design: Gradient background (blue #0066CC to orange #FF6B35) with white "DA" text

#### 2. Adaptive Icon Foreground (`assets/icons/app_icon_foreground.png`)
- Size: 432x432 px
- Format: PNG with transparency
- Design: White circle with blue "DA" text
- Note: Keep important content within the safe zone (center 264x264 px)

#### 3. Splash Logo (`assets/images/splash_logo.png`)
- Size: 512x512 px
- Format: PNG with transparency
- Design: White circle with blue "DA" text

## Configuration

The `pubspec.yaml` file is already configured with:

### Flutter Launcher Icons

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"
  adaptive_icon_background: "#0066CC"
  adaptive_icon_foreground: "assets/icons/app_icon_foreground.png"
  remove_alpha_ios: true
  min_sdk_android: 21
```

### Flutter Native Splash

```yaml
flutter_native_splash:
  color: "#0066CC"
  image: assets/images/splash_logo.png
  android_12:
    image: assets/images/splash_logo.png
    icon_background_color: "#0066CC"
  android: true
  ios: true
  android_gravity: center
  ios_content_mode: center
  fullscreen: true
```

## Platform-Specific Notes

### Android

- **Adaptive Icons**: Automatically generated for Android 8.0+ (API 26+)
- **Android 12+**: Uses the new splash screen API with icon and background color
- **Legacy**: Uses traditional splash screen for older Android versions

### iOS

- **App Icon**: Generates all required sizes automatically
- **Launch Screen**: Uses storyboard-based launch screen
- **Safe Area**: Automatically handles notch and home indicator

## Verification

After running the generation commands, verify:

### Android
- Check `android/app/src/main/res/mipmap-*` for app icons
- Check `android/app/src/main/res/drawable*/launch_background.xml` for splash

### iOS
- Check `ios/Runner/Assets.xcassets/AppIcon.appiconset/` for app icons
- Check `ios/Runner/Assets.xcassets/LaunchImage.imageset/` for splash

## Troubleshooting

### Icons not updating on device

1. Uninstall the app completely
2. Clean build: `flutter clean`
3. Rebuild: `flutter run`

### Splash screen not showing

1. Ensure assets exist in the correct paths
2. Run: `dart run flutter_native_splash:create`
3. Clean and rebuild the app

### Android 12+ splash issues

The Android 12+ splash screen has specific requirements:
- Icon should be 288x288 dp (432x432 px at xxxhdpi)
- Icon is displayed in a circle (safe zone: 192x192 dp)
- Background color is solid (no gradients)

## Design Guidelines

### App Icon Best Practices

1. **Simplicity**: Keep the design simple and recognizable at small sizes
2. **Contrast**: Ensure good contrast between foreground and background
3. **Consistency**: Match your brand colors and style
4. **Testing**: Test on various device backgrounds (light/dark)

### Splash Screen Best Practices

1. **Fast Loading**: Keep it simple for quick display
2. **Brand Identity**: Reflect your app's brand
3. **Consistency**: Match the app's first screen for smooth transition
4. **Accessibility**: Ensure sufficient contrast

## Resources

- [Flutter Launcher Icons Package](https://pub.dev/packages/flutter_launcher_icons)
- [Flutter Native Splash Package](https://pub.dev/packages/flutter_native_splash)
- [Android Adaptive Icons Guide](https://developer.android.com/guide/practices/ui_guidelines/icon_design_adaptive)
- [iOS App Icon Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [Android 12 Splash Screen](https://developer.android.com/guide/topics/ui/splash-screen)
