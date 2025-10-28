# Multi-Language Support

DishaAjyoti now supports 6 languages:

1. **English** (en)
2. **हिंदी Hindi** (hi)
3. **मराठी Marathi** (mr)
4. **தமிழ் Tamil** (ta)
5. **తెలుగు Telugu** (te)
6. **ಕನ್ನಡ Kannada** (kn)

## Setup Complete ✅

All translation files have been created in `lib/l10n/`:
- `app_en.arb` - English
- `app_hi.arb` - Hindi
- `app_mr.arb` - Marathi
- `app_ta.arb` - Tamil
- `app_te.arb` - Telugu
- `app_kn.arb` - Kannada

## How to Generate Localization Files

Run this command to generate the localization classes:

```bash
flutter gen-l10n
```

Or simply run:

```bash
flutter pub get
```

This will automatically generate the `AppLocalizations` class.

## How to Use in Code

### 1. Import the localizations:

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
```

### 2. Use in widgets:

```dart
Text(AppLocalizations.of(context)!.appName)
Text(AppLocalizations.of(context)!.home_welcome)
Text(AppLocalizations.of(context)!.service_free_kundali)
```

### 3. Configure in MaterialApp:

```dart
MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: _selectedLocale, // Your selected locale
  // ... rest of your app
)
```

## Language Selection Screen

A complete language selection screen has been created at:
`lib/screens/language_selection_screen.dart`

### Usage:

```dart
// Navigate to language selection
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => LanguageSelectionScreen(),
  ),
);

// Or for onboarding
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => LanguageSelectionScreen(isOnboarding: true),
  ),
);
```

## Changing Language

The selected language is stored in SharedPreferences with key: `language`

```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setString('language', 'hi'); // Change to Hindi
```

## Adding New Translations

1. Open the appropriate `.arb` file in `lib/l10n/`
2. Add your new key-value pair:

```json
{
  "my_new_key": "My translated text"
}
```

3. Run `flutter gen-l10n` to regenerate
4. Use in code: `AppLocalizations.of(context)!.my_new_key`

## Translation Keys Available

### Common
- `common_ok`, `common_cancel`, `common_yes`, `common_no`
- `common_save`, `common_delete`, `common_edit`
- `common_back`, `common_next`, `common_submit`, `common_retry`
- `common_loading`, `common_error`, `common_success`

### Navigation
- `nav_home`, `nav_services`, `nav_reports`, `nav_profile`

### Home Screen
- `home_welcome`, `home_explore_services`
- `home_reports`, `home_spent`
- `home_featured_services`, `home_view_all`

### Services
- `service_free_kundali`, `service_ai_kundali`
- `service_palmistry`, `service_numerology`, `service_compatibility`
- Service descriptions with `_desc` suffix

### Kundali
- `kundali_choose_method`, `kundali_free_generation`
- `kundali_quick_generate`, `kundali_professional`
- `kundali_my_kundalis`, `kundali_new_kundali`

### Orders & Payment
- `order_confirm`, `order_summary`, `order_total_amount`
- `payment_title`, `payment_methods`, `payment_success`

### Errors & Success
- `error_network`, `error_server`, `error_unknown`
- `success_kundali_deleted`, `success_payment`

### Profile
- `profile_information`, `profile_settings`
- `profile_help_support`, `profile_logout`

## Testing Languages

1. Open the app
2. Go to Settings → Language
3. Select your preferred language
4. The app will update immediately

## Notes

- All translations are complete for the main features
- RTL (Right-to-Left) support can be added if needed for Arabic/Urdu
- Translations can be updated anytime by editing the `.arb` files
- The app remembers the user's language preference

## Admin Backend Integration

When the admin backend is ready, you can:
1. Fetch available languages from API
2. Download translation files dynamically
3. Update translations without app updates
4. Add new languages on-the-fly

For now, all 6 languages are built into the app.
