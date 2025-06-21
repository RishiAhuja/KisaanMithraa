import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable rounded icon button widget following Kisaan Mithraa design system
/// Provides consistent styling for action buttons across the app
class RoundedIconButton extends StatelessWidget {
  const RoundedIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
    this.size = 22,
    this.padding = const EdgeInsets.all(10),
    this.borderRadius = 14,
    this.borderWidth = 1.5,
    this.enableShadow = true,
    this.margin,
  });

  /// The icon to display
  final IconData icon;

  /// Callback function when the button is tapped
  final VoidCallback onTap;

  /// Optional tooltip text
  final String? tooltip;

  /// Icon color, defaults to theme.colorScheme.onBackground
  final Color? iconColor;

  /// Background color, defaults to theme.colorScheme.background
  final Color? backgroundColor;

  /// Border color, defaults to theme.colorScheme.onBackground.withOpacity(0.1)
  final Color? borderColor;

  /// Icon size
  final double size;

  /// Container padding
  final EdgeInsets padding;

  /// Border radius
  final double borderRadius;

  /// Border width
  final double borderWidth;

  /// Whether to show shadow
  final bool enableShadow;

  /// Optional margin around the button
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Add haptic feedback for better UX
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? theme.colorScheme.background,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ??
                  theme.colorScheme.onBackground.withOpacity(0.1),
              width: borderWidth,
            ),
            boxShadow: enableShadow
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            color: iconColor ?? theme.colorScheme.onBackground,
            size: size,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    if (margin != null) {
      button = Container(
        margin: margin,
        child: button,
      );
    }

    return button;
  }
}
