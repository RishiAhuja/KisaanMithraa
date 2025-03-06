import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

class WebPlatformHelper {
  static bool get isWebPlatform => kIsWeb;

  static void ensureRecaptchaVisible() {
    if (kIsWeb) {
      final recaptchaContainer =
          html.document.getElementById('recaptcha-container');
      if (recaptchaContainer != null) {
        recaptchaContainer.style.visibility = 'visible';
        recaptchaContainer.style.position = 'fixed';
        recaptchaContainer.style.top = '50%';
        recaptchaContainer.style.left = '50%';
        recaptchaContainer.style.transform = 'translate(-50%, -50%)';
        recaptchaContainer.style.zIndex = '9999';
      }
    }
  }

  static void hideRecaptcha() {
    if (kIsWeb) {
      final recaptchaContainer =
          html.document.getElementById('recaptcha-container');
      if (recaptchaContainer != null) {
        recaptchaContainer.style.visibility = 'hidden';
      }
    }
  }
}
