import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cropconnect/core/constants/localization_standards.dart';
import 'package:cropconnect/core/theme/app_colors.dart';

/// Standardized error handler for consistent error handling across the app
/// Provides localized error messages and consistent UI feedback
class StandardErrorHandler {
  StandardErrorHandler._(); // Private constructor to prevent instantiation

  /// Handle any error with standardized UI feedback
  static void handleError(
    BuildContext context,
    dynamic error, {
    String? customMessage,
    bool showSnackbar = true,
    bool logError = true,
    Duration snackbarDuration = const Duration(seconds: 4),
  }) {
    final appLocalizations = LocalizationStandards.getLocalizations(context);

    String message = customMessage ?? _getErrorMessage(error, appLocalizations);

    if (showSnackbar) {
      showErrorSnackbar(
        message: message,
        duration: snackbarDuration,
      );
    }

    if (logError) {
      _logError(error, message);
    }
  }

  /// Show a standardized error snackbar
  static void showErrorSnackbar({
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    Get.snackbar(
      'Error', // This should be localized, but Get.snackbar needs immediate access
      message,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(
        Icons.error_outline,
        color: Colors.white,
      ),
      shouldIconPulse: false,
    );
  }

  /// Show a standardized success snackbar
  static void showSuccessSnackbar({
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      'Success', // This should be localized
      message,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(
        Icons.check_circle_outline,
        color: Colors.white,
      ),
      shouldIconPulse: false,
    );
  }

  /// Show a standardized warning snackbar
  static void showWarningSnackbar({
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    Get.snackbar(
      'Warning', // This should be localized
      message,
      backgroundColor: AppColors.warning,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(
        Icons.warning_amber_outlined,
        color: Colors.white,
      ),
      shouldIconPulse: false,
    );
  }

  /// Show a standardized info snackbar
  static void showInfoSnackbar({
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      'Info', // This should be localized
      message,
      backgroundColor: AppColors.info,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(
        Icons.info_outline,
        color: Colors.white,
      ),
      shouldIconPulse: false,
    );
  }

  /// Show a standardized error dialog
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String message,
    String? title,
    String? actionText,
    VoidCallback? onAction,
  }) {
    final appLocalizations = LocalizationStandards.getLocalizations(context);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? appLocalizations.error),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(appLocalizations.ok),
          ),
          if (actionText != null && onAction != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onAction();
              },
              child: Text(actionText),
            ),
        ],
      ),
    );
  }

  /// Get appropriate error message based on error type
  static String _getErrorMessage(
      dynamic error, AppLocalizations localizations) {
    if (error is FirebaseException) {
      return _handleFirebaseError(error, localizations);
    }

    if (error is FormatException) {
      return localizations.invalidDataFormat;
    }

    if (error.toString().toLowerCase().contains('network')) {
      return localizations.networkError;
    }

    if (error.toString().toLowerCase().contains('timeout')) {
      return localizations.timeoutError;
    }

    // Default error message
    return localizations.somethingWentWrong;
  }

  /// Handle Firebase-specific errors
  static String _handleFirebaseError(
      FirebaseException error, AppLocalizations localizations) {
    switch (error.code) {
      case 'user-not-found':
        return localizations.userNotFound;
      case 'wrong-password':
        return localizations.wrongPassword;
      case 'email-already-in-use':
        return localizations.emailAlreadyInUse;
      case 'weak-password':
        return localizations.weakPassword;
      case 'invalid-email':
        return localizations.invalidEmail;
      case 'user-disabled':
        return localizations.userDisabled;
      case 'too-many-requests':
        return localizations.tooManyRequests;
      case 'operation-not-allowed':
        return localizations.operationNotAllowed;
      case 'network-request-failed':
        return localizations.networkError;
      case 'permission-denied':
        return localizations.permissionDenied;
      case 'unavailable':
        return localizations.serviceUnavailable;
      default:
        return localizations.somethingWentWrong;
    }
  }

  /// Log error for debugging purposes
  static void _logError(dynamic error, String message) {
    // In production, this could send to crash analytics (Firebase Crashlytics, Sentry, etc.)
    debugPrint('StandardErrorHandler: $error');
    debugPrint('User Message: $message');

    // If you have a logging service, you can add it here:
    // AppLogger.error('Error: $error, Message: $message');
  }

  /// Validate network connectivity and show appropriate error
  static Future<bool> validateNetworkAndShowError(BuildContext context) async {
    try {
      // Add network connectivity check here if needed
      // For now, assuming network is available
      return true;
    } catch (e) {
      final appLocalizations = LocalizationStandards.getLocalizations(context);
      showErrorSnackbar(message: appLocalizations.noInternetConnection);
      return false;
    }
  }

  /// Handle async operations with standardized error handling
  static Future<T?> handleAsyncOperation<T>(
    BuildContext context,
    Future<T> operation, {
    String? customErrorMessage,
    bool showLoadingIndicator = false,
    bool showSuccessMessage = false,
    String? successMessage,
  }) async {
    try {
      if (showLoadingIndicator) {
        // Show loading indicator
        // This could be enhanced with a loading overlay
      }

      final result = await operation;

      if (showSuccessMessage && successMessage != null) {
        showSuccessSnackbar(message: successMessage);
      }

      return result;
    } catch (error) {
      handleError(
        context,
        error,
        customMessage: customErrorMessage,
      );
      return null;
    } finally {
      if (showLoadingIndicator) {
        // Hide loading indicator
      }
    }
  }
}
