import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Standardized localization access patterns and utilities
/// Ensures consistent localization usage across the app
class LocalizationStandards {
  /// Standard way to access AppLocalizations with proper error handling
  /// Use this instead of AppLocalizations.of(context) directly
  static AppLocalizations getLocalizations(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    assert(
      localizations != null,
      'AppLocalizations not found in context. '
      'Make sure AppLocalizations.delegate is added to MaterialApp.localizationsDelegates',
    );
    return localizations!;
  }

  /// Standard variable name to use throughout the app
  /// Always use: final appLocalizations = LocalizationStandards.getLocalizations(context);
  static const String standardVariableName = 'appLocalizations';

  /// Helper method to safely get a localized string with fallback
  static String safeGetString(
    BuildContext context,
    String Function(AppLocalizations) getter,
    String fallback,
  ) {
    try {
      final localizations = AppLocalizations.of(context);
      if (localizations == null) return fallback;
      return getter(localizations);
    } catch (e) {
      return fallback;
    }
  }

  /// Validates that all required localizations are available
  /// Call this during app initialization in debug mode
  static bool validateLocalizations(BuildContext context) {
    try {
      final localizations = getLocalizations(context);
      
      // Test access to critical keys
      final criticalKeys = [
        () => localizations.appTitle,
        () => localizations.welcome,
        () => localizations.createCooperative,
        () => localizations.askAnything,
      ];

      for (final keyGetter in criticalKeys) {
        final result = keyGetter();
        if (result.isEmpty) {
          debugPrint('Warning: Empty localization key found');
          return false;
        }
      }

      return true;
    } catch (e) {
      debugPrint('Localization validation failed: $e');
      return false;
    }
  }
}

/// Extension to make localization access more convenient
extension BuildContextLocalization on BuildContext {
  /// Quick access to localized strings
  /// Usage: context.l10n.appTitle
  AppLocalizations get l10n => LocalizationStandards.getLocalizations(this);
}
