// // lib/utils/web_recaptcha.dart
// import 'dart:js' as js;
// import 'package:flutter/foundation.dart';
// import 'package:cropconnect/utils/app_logger.dart';

// /// Helper class to interact with reCAPTCHA from web
// class WebRecaptcha {
//   /// Shows the reCAPTCHA widget if it exists
//   static void showRecaptcha() {
//     if (!kIsWeb) return;

//     try {
//       final container = js.context.callMethod(
//           'eval', ['document.getElementById("recaptcha-container")']);
//       if (container != null) {
//         js.context.callMethod('eval', [
//           'document.getElementById("recaptcha-container").style.visibility = "visible"'
//         ]);
//         AppLogger.debug('reCAPTCHA container made visible');
//       } else {
//         AppLogger.error('reCAPTCHA container not found in DOM');
//       }
//     } catch (e) {
//       AppLogger.error('Error showing reCAPTCHA', e);
//     }
//   }

//   /// Hides the reCAPTCHA widget
//   static void hideRecaptcha() {
//     if (!kIsWeb) return;

//     try {
//       js.context.callMethod('eval', [
//         'document.getElementById("recaptcha-container").style.visibility = "hidden"'
//       ]);
//       AppLogger.debug('reCAPTCHA container hidden');
//     } catch (e) {
//       AppLogger.error('Error hiding reCAPTCHA', e);
//     }
//   }

//   /// Checks if reCAPTCHA is available
//   static bool isRecaptchaAvailable() {
//     if (!kIsWeb) return false;

//     try {
//       return js.context.hasProperty('recaptchaVerifier');
//     } catch (e) {
//       AppLogger.error('Error checking reCAPTCHA availability', e);
//       return false;
//     }
//   }

//   /// Resets the reCAPTCHA (for when it expires or errors)
//   static void resetRecaptcha() {
//     if (!kIsWeb) return;

//     try {
//       if (js.context.hasProperty('recaptchaWidgetId')) {
//         final widgetId = js.context['recaptchaWidgetId'];
//         js.context['grecaptcha']?.callMethod('reset', [widgetId]);
//         AppLogger.debug('reCAPTCHA reset successfully');
//       }
//     } catch (e) {
//       AppLogger.error('Error resetting reCAPTCHA', e);
//     }
//   }
// }
