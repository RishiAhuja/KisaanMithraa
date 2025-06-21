import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const primary = Color(0xFF1E8449); // Deeper green for better contrast
  static const primaryLight = Color(0xFF2ECC71); // Lighter shade for accents
  static const primaryDark = Color(0xFF196F3D); // Darker shade for depth

  // Secondary colors
  static const secondary = Color(0xFFF39C12); // Warm orange for CTAs
  static const secondaryLight =
      Color(0xFFFFD152); // Light yellow for highlights

  // Splash screen colors (from design)
  static const splashGreen = Color(0xFF1F844A);
  static const splashYellow = Color(0xFFF2CB22);
  static const splashOrange = Color(0xFFFF9800);
  static const splashLightGreen = Color(0xFF8BC34A);

  // Accent colors
  static const accent = Color(0xFF3498DB); // Blue for interactive elements
  static const accentLight =
      Color(0xFF85C1E9); // Light blue for subtle highlights

  // Background colors
  static const backgroundLight =
      Color(0xFFF5F9F6); // Very light green tint for background
  static const backgroundCard = Color(0xFFFFFFFF); // White for cards
  static const backgroundSecondary =
      Color(0xFFF1F8E9); // Light green for secondary backgrounds

  // Text colors
  static const textPrimary = Color(0xFF212121); // Nearly black for primary text
  static const textSecondary =
      Color(0xFF757575); // Medium gray for secondary text
  static const textLight = Color(0xFFFFFFFF); // White text for dark backgrounds

  // Dark theme colors
  static const backgroundDark =
      Color(0xFF1E272E); // Dark blue-gray for dark theme background
  static const surfaceDark =
      Color(0xFF2C3A47); // Slightly lighter for dark theme surfaces
  static const textDark = Color(0xFFF5F5F5); // Off-white for dark theme text
  static const textDarkSecondary =
      Color(0xFFB0BEC5); // Light gray for dark theme secondary text

  // Status colors
  static const success = Color(0xFF27AE60); // Green for success states
  static const warning = Color(0xFFFF9800); // Orange for warnings
  static const error = Color(0xFFE74C3C); // Red for errors
  static const info = Color(0xFF3498DB); // Blue for information

  // Special UI elements
  static const divider = Color(0xFFEEEEEE); // Very light gray for dividers
  static const shadow = Color(0x1A000000); // Transparent black for shadows
  static const shimmer = Color(0xFFE0E0E0); // Light gray for loading states
  static const overlay =
      Color(0x80000000); // Semi-transparent black for overlays

  // Surface colors
  static const surface = Colors.white;
  static const surfaceVariant =
      Color(0xFFF5F5F5); // Light gray for alternative surfaces

  // Semantic gray colors (replace hardcoded Colors.grey usage)
  static const grey50 = Color(0xFFFAFAFA); // Very light gray
  static const grey100 = Color(0xFFF5F5F5); // Light gray
  static const grey200 = Color(0xFFEEEEEE); // Lighter gray
  static const grey300 = Color(0xFFE0E0E0); // Light medium gray
  static const grey400 = Color(0xFFBDBDBD); // Medium gray
  static const grey500 = Color(0xFF9E9E9E); // Medium dark gray
  static const grey600 = Color(0xFF757575); // Dark gray
  static const grey700 = Color(0xFF616161); // Darker gray
  static const grey800 = Color(0xFF424242); // Very dark gray
  static const grey900 = Color(0xFF212121); // Nearly black gray

  // Status colors with variations
  static const successLight =
      Color(0xFF81C784); // Light green for success backgrounds
  static const warningLight =
      Color(0xFFFFB74D); // Light orange for warning backgrounds
  static const errorLight =
      Color(0xFFE57373); // Light red for error backgrounds
  static const infoLight = Color(0xFF64B5F6); // Light blue for info backgrounds

  // Semantic colors for components
  static const cardBackground = backgroundCard;
  static const inputBackground = Colors.white;
  static const skeletonBase = grey200;
  static const skeletonHighlight = grey100;
  static const borderLight = grey200;
  static const borderMedium = grey300;
  static const borderDark = grey400;

  static Color getColorFromKeyForQuickAccess(String colorKey) {
    switch (colorKey) {
      case 'purple':
        return const Color(0xFF6C5CE7); // AppColors.featurePurple
      case 'green':
        return const Color(0xFF00B894); // AppColors.featureGreen
      case 'orange':
        return const Color(0xFFFF9F43); // AppColors.featureOrange
      case 'blue':
        return const Color(0xFF54A0FF); // AppColors.featureBlue
      default:
        return AppColors.primary;
    }
  }
}
