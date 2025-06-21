import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cropconnect/core/presentation/widgets/rounded_icon_button.dart';

/// Common AppBar widget following Kisaan Mithraa design system
/// Provides consistent styling and behavior across all screens
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.centerTitle = false,
    this.onBackPressed,
    this.showNotificationIcon = true,
    this.showProfileIcon = true,
    this.customHeight,
    this.titleStyle,
    this.customActions,
    this.showBottomBorder = true,
  });

  /// Main title text
  final String title;

  /// Optional subtitle below title
  final String? subtitle;

  /// Action widgets in the app bar (overrides default actions)
  final List<Widget>? actions;

  /// Custom leading widget
  final Widget? leading;

  /// Whether to show the back button
  final bool showBackButton;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom foreground color
  final Color? foregroundColor;

  /// AppBar elevation
  final double elevation;

  /// Whether to center the title
  final bool centerTitle;

  /// Custom back button callback
  final VoidCallback? onBackPressed;

  /// Show notification icon in default actions
  final bool showNotificationIcon;

  /// Show profile icon in default actions
  final bool showProfileIcon;

  /// Custom height for the app bar
  final double? customHeight;

  /// Custom title style
  final TextStyle? titleStyle;

  /// Custom actions (alternative to actions)
  final List<Widget>? customActions;

  /// Whether to show bottom border
  final bool showBottomBorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      systemOverlayStyle: _getSystemOverlayStyle(context),
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      foregroundColor: foregroundColor ?? theme.colorScheme.onSurface,
      elevation: elevation,
      shadowColor: Colors.black.withOpacity(0.08),
      centerTitle: centerTitle,
      titleSpacing: showBackButton || leading != null ? 24 : 32,
      toolbarHeight: customHeight ?? kToolbarHeight,

      // Leading widget
      leading: leading ??
          (showBackButton && Navigator.canPop(context)
              ? _buildBackButton(context)
              : null),

      // Title section
      title: _buildTitle(context),

      // Actions
      actions: actions ?? customActions ?? _buildDefaultActions(context),

      // Conditional bottom border for visual separation
      shape: showBottomBorder
          ? Border(
              bottom: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.1),
                width: 0.5,
              ),
            )
          : null,
    );
  }

  SystemUiOverlayStyle _getSystemOverlayStyle(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    );
  }

  Widget _buildBackButton(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      icon: Icon(
        Icons.arrow_back,
        size: 24,
        color: theme.colorScheme.onSurface,
      ),
      onPressed: onBackPressed ??
          () {
            HapticFeedback.lightImpact();
            Get.back();
          },
    );
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);

    if (subtitle != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: titleStyle ??
                theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: -0.3,
                  height: 1.2,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 12,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    return Text(
      title,
      style: titleStyle ??
          theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.3,
            height: 1.2,
          ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  List<Widget> _buildDefaultActions(BuildContext context) {
    final actions = <Widget>[];

    if (showNotificationIcon) {
      actions.add(_buildNotificationIcon(context));
      actions.add(const SizedBox(width: 12));
    }

    if (showProfileIcon) {
      actions.add(_buildProfileIcon(context));
      actions.add(const SizedBox(width: 16));
    }

    return actions;
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return RoundedIconButton(
      icon: Icons.notifications_outlined,
      onTap: () => Get.toNamed('/notifications'),
      tooltip: 'Notifications',
    );
  }

  Widget _buildProfileIcon(BuildContext context) {
    return RoundedIconButton(
      icon: Icons.person_rounded,
      onTap: () => Get.toNamed('/profile'),
      tooltip: 'Profile',
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(customHeight ?? kToolbarHeight);
}

/// Specialized AppBar for chat screens
class ChatAppBar extends CommonAppBar {
  const ChatAppBar({
    super.key,
    required super.title,
    this.isOnline = false,
    this.onVoicePressed,
    this.onResetPressed,
  }) : super(
          showNotificationIcon: false,
          showProfileIcon: false,
        );

  final bool isOnline;
  final VoidCallback? onVoicePressed;
  final VoidCallback? onResetPressed;

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      title: title,
      subtitle: isOnline ? 'Online' : 'Offline',
      showNotificationIcon: false,
      showProfileIcon: false,
      customActions: [
        if (onVoicePressed != null) _buildVoiceButton(context),
        if (onVoicePressed != null) const SizedBox(width: 8),
        if (onResetPressed != null) _buildResetButton(context),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildVoiceButton(BuildContext context) {
    final theme = Theme.of(context);

    return RoundedIconButton(
      icon: Icons.mic_outlined,
      onTap: onVoicePressed ?? () {},
      tooltip: 'Voice Input',
      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      borderColor: theme.colorScheme.primary.withOpacity(0.2),
      iconColor: theme.colorScheme.primary,
      size: 20,
      borderRadius: 12,
    );
  }

  Widget _buildResetButton(BuildContext context) {
    final theme = Theme.of(context);

    return RoundedIconButton(
      icon: Icons.refresh_rounded,
      onTap: onResetPressed ?? () {},
      tooltip: 'Reset Chat',
      backgroundColor: theme.colorScheme.surface,
      borderColor: theme.colorScheme.outline.withOpacity(0.2),
      iconColor: theme.colorScheme.onSurface.withOpacity(0.8),
      size: 20,
      borderRadius: 12,
    );
  }
}

/// Specialized AppBar for forms and creation screens
class FormAppBar extends CommonAppBar {
  const FormAppBar({
    super.key,
    required super.title,
    this.onSavePressed,
    this.isSaving = false,
  }) : super(
          showNotificationIcon: false,
          showProfileIcon: false,
        );

  final VoidCallback? onSavePressed;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return CommonAppBar(
      title: title,
      showNotificationIcon: false,
      showProfileIcon: false,
      customActions: onSavePressed != null
          ? [
              _buildSaveButton(context, localizations),
              const SizedBox(width: 16),
            ]
          : null,
    );
  }

  Widget _buildSaveButton(
      BuildContext context, AppLocalizations localizations) {
    final theme = Theme.of(context);

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: isSaving ? null : onSavePressed,
          child: Center(
            child: isSaving
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Text(
                    'Save',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
