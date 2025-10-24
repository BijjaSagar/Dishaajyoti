import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Extension to easily access localized strings from BuildContext
/// Usage: context.l10n.appName
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
