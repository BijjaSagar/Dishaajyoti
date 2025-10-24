# Localization Guide

This guide explains how to use and maintain localization in the DishaAjyoti app.

## Overview

The app supports two languages:
- **English (en)** - Default language
- **Hindi (hi)** - Secondary language

## File Structure

```
lib/
├── l10n/
│   ├── app_en.arb          # English translations
│   ├── app_hi.arb          # Hindi translations
│   ├── app_localizations.dart        # Generated base class
│   ├── app_localizations_en.dart     # Generated English class
│   └── app_localizations_hi.dart     # Generated Hindi class
├── providers/
│   └── language_provider.dart        # Language state management
└── utils/
    └── localization_helper.dart      # Helper extension
```

## Using Localized Strings

### Method 1: Using the Helper Extension (Recommended)

```dart
import '../utils/localization_helper.dart';

// In your widget build method:
Text(context.l10n.appName)
Text(context.l10n.welcomeBack)
Text(context.l10n.login)
```

### Method 2: Direct Access

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// In your widget build method:
Text(AppLocalizations.of(context)!.appName)
```

## Changing Language

Users can change the language from the Settings screen. Programmatically:

```dart
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

// Get the provider
final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

// Change to Hindi
await languageProvider.setLanguage('hi');

// Change to English
await languageProvider.setLanguage('en');
```

## Adding New Strings

### Step 1: Add to English ARB file

Edit `lib/l10n/app_en.arb`:

```json
{
  "myNewString": "My New String",
  "stringWithParameter": "Hello {name}!",
  "@stringWithParameter": {
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}
```

### Step 2: Add to Hindi ARB file

Edit `lib/l10n/app_hi.arb`:

```json
{
  "myNewString": "मेरी नई स्ट्रिंग",
  "stringWithParameter": "नमस्ते {name}!"
}
```

### Step 3: Generate Localization Files

```bash
flutter gen-l10n
```

### Step 4: Use in Your Code

```dart
Text(context.l10n.myNewString)
Text(context.l10n.stringWithParameter('John'))
```

## String Parameters

### Simple Parameters

```json
{
  "greeting": "Hello {name}!",
  "@greeting": {
    "placeholders": {
      "name": {"type": "String"}
    }
  }
}
```

Usage:
```dart
Text(context.l10n.greeting('John'))
```

### Multiple Parameters

```json
{
  "stepXOfY": "Step {current} of {total}",
  "@stepXOfY": {
    "placeholders": {
      "current": {"type": "int"},
      "total": {"type": "int"}
    }
  }
}
```

Usage:
```dart
Text(context.l10n.stepXOfY(1, 3))
```

## Best Practices

1. **Always use localized strings** - Never hardcode user-facing text
2. **Use descriptive keys** - `loginButton` instead of `btn1`
3. **Group related strings** - Use prefixes like `onboarding`, `auth`, `dashboard`
4. **Test both languages** - Switch languages in settings to verify translations
5. **Keep ARB files in sync** - Every key in `app_en.arb` should exist in `app_hi.arb`

## Common Strings

The app includes commonly used strings:

- **Navigation**: `home`, `services`, `reports`, `profile`, `settings`
- **Actions**: `save`, `delete`, `edit`, `close`, `confirm`, `cancel`
- **Auth**: `login`, `signUp`, `email`, `password`, `forgotPassword`
- **Common**: `loading`, `ok`, `yes`, `no`, `back`, `next`, `done`

## Troubleshooting

### Strings not updating after changes

1. Run `flutter gen-l10n` to regenerate localization files
2. Restart the app (hot reload may not work for localization changes)

### Missing translation error

Ensure the key exists in both `app_en.arb` and `app_hi.arb` files.

### Reserved keywords

Avoid using Dart reserved keywords as keys (e.g., `continue`, `class`, `return`). Use alternatives like `continueButton` instead.

## Configuration Files

### l10n.yaml

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

### pubspec.yaml

```yaml
flutter:
  generate: true

dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2
```

## Language Provider

The `LanguageProvider` manages the current language state:

```dart
class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('en');
  
  Locale get locale => _locale;
  bool get isEnglish => _locale.languageCode == 'en';
  bool get isHindi => _locale.languageCode == 'hi';
  
  Future<void> setLanguage(String languageCode) async {
    // Changes language and persists preference
  }
}
```

## Testing

To test localization:

1. Run the app
2. Navigate to Settings
3. Tap on "Language"
4. Select "Hindi" or "English"
5. Verify all screens show translated text

## Resources

- [Flutter Internationalization](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [ARB File Format](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)
- [Intl Package](https://pub.dev/packages/intl)
