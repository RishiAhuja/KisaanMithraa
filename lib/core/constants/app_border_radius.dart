/// App border radius constants for consistent design
/// Provides standardized border radius values throughout the application
class AppBorderRadius {
  AppBorderRadius._(); // Private constructor to prevent instantiation

  /// Small border radius - 8px
  /// Used for: small buttons, chips, text fields
  static const double sm = 8.0;

  /// Medium border radius - 12px
  /// Used for: cards, containers, form fields
  static const double md = 12.0;

  /// Large border radius - 16px
  /// Used for: larger cards, dialogs, major containers
  static const double lg = 16.0;

  /// Extra large border radius - 20px
  /// Used for: hero elements, prominent cards, alerts
  static const double xl = 20.0;

  /// Double extra large border radius - 24px
  /// Used for: bottom sheets, large containers, feature cards
  static const double xxl = 24.0;

  /// Component-specific border radius
  static const double button = md; // 12px for buttons
  static const double card = md; // 12px for cards
  static const double textField = md; // 12px for input fields
  static const double dialog = lg; // 16px for dialogs
  static const double bottomSheet = xxl; // 24px for bottom sheets
  static const double fab = lg; // 16px for floating action button
  static const double avatar = 20.0; // 20px for avatars
  static const double actionButton = 14.0; // 14px for RoundedIconButton
  static const double chip = xl; // 20px for chips
  static const double alert = xl; // 20px for alert cards

  /// Circular border radius for fully rounded elements
  static const double circular = 1000.0;
}
