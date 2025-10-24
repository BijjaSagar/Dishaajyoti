# DishaAjyoti App Assets

This directory contains all documentation and scripts for managing app icons and splash screens.

## 📚 Documentation Files

- **ASSETS_SETUP.md** - Complete guide for app icons and splash screen setup
- **IOS_SETUP.md** - Instructions for iOS project configuration
- **TASK_27_SUMMARY.md** - Implementation summary and status

## 🛠️ Scripts

- **generate_assets.js** - Generates SVG placeholder assets
- **create_minimal_pngs.js** - Generates PNG placeholder assets

## 📁 Asset Locations

```
assets/
├── icons/
│   ├── app_icon.png              # Main app icon (1024x1024)
│   ├── app_icon_foreground.png   # Adaptive icon foreground (432x432)
│   └── *.svg                     # SVG versions for reference
└── images/
    ├── splash_logo.png           # Splash screen logo (512x512)
    └── *.svg                     # SVG version for reference
```

## ✅ Current Status

### Android
- ✅ App icons generated for all densities
- ✅ Adaptive icons configured (Android 8.0+)
- ✅ Splash screens generated for all densities
- ✅ Android 12+ splash screens configured
- ✅ Ready for testing and deployment

### iOS
- ⚠️ Requires iOS project setup
- See `IOS_SETUP.md` for instructions

## 🚀 Quick Commands

### Regenerate All Assets
```bash
# 1. Update PNG files in assets/ directory
# 2. Run:
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

### Generate Placeholder Assets
```bash
node create_minimal_pngs.js
```

### Clean and Rebuild
```bash
flutter clean
flutter pub get
flutter run
```

## 🎨 Design Guidelines

### Colors
- Primary Blue: `#0066CC`
- Accent Orange: `#FF6B35`
- White: `#FFFFFF`

### Sizes
- App Icon: 1024x1024 px
- Adaptive Foreground: 432x432 px (safe zone: 264x264 px center)
- Splash Logo: 512x512 px

## ⚠️ Important Notes

1. **Current assets are placeholders** - Replace with professional designs before production
2. **iOS setup required** - Follow IOS_SETUP.md to enable iOS assets
3. **Test on devices** - Always test icons and splash on physical devices
4. **Version control** - Commit generated platform assets to git

## 📖 For More Information

- Read `ASSETS_SETUP.md` for detailed setup instructions
- Read `IOS_SETUP.md` for iOS configuration
- Read `TASK_27_SUMMARY.md` for implementation details

## 🆘 Troubleshooting

### Icons not updating
```bash
flutter clean
flutter pub get
dart run flutter_launcher_icons
flutter run
```

### Splash not showing
```bash
dart run flutter_native_splash:create
flutter clean
flutter run
```

### Need to change colors
1. Update `pubspec.yaml` configurations
2. Regenerate: `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create`

## 📞 Support

For issues or questions:
1. Check the documentation files in this directory
2. Review Flutter documentation: https://docs.flutter.dev
3. Check package documentation:
   - flutter_launcher_icons: https://pub.dev/packages/flutter_launcher_icons
   - flutter_native_splash: https://pub.dev/packages/flutter_native_splash
