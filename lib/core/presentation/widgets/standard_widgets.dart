import 'package:flutter/material.dart';
import 'package:cropconnect/core/constants/app_spacing.dart';
import 'package:cropconnect/core/theme/app_colors.dart';

/// Standardized loading widget for consistent loading states across the app
class StandardLoading extends StatelessWidget {
  const StandardLoading({
    super.key,
    this.message,
    this.fullScreen = false,
    this.size = 24.0,
    this.color,
    this.showMessage = true,
  });

  /// Custom loading message
  final String? message;

  /// Whether to display as full screen loading
  final bool fullScreen;

  /// Size of the loading indicator
  final double size;

  /// Color of the loading indicator
  final Color? color;

  /// Whether to show the loading message
  final bool showMessage;

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            color: color ?? AppColors.primary,
            strokeWidth: size > 30 ? 4.0 : 2.0,
          ),
        ),
        if (showMessage) ...[
          SizedBox(height: AppSpacing.md),
          Text(
            message ?? 'Loading...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (fullScreen) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(child: content),
      );
    }

    return Center(child: content);
  }
}

/// Standardized empty state widget for consistent empty states across the app
class StandardEmptyState extends StatelessWidget {
  const StandardEmptyState({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.actionText,
    this.onAction,
    this.iconSize = 64.0,
  });

  /// Main title for empty state
  final String? title;

  /// Subtitle description
  final String? subtitle;

  /// Icon to display
  final IconData? icon;

  /// Action button text
  final String? actionText;

  /// Action button callback
  final VoidCallback? onAction;

  /// Size of the icon
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: iconSize,
              color: AppColors.grey400,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              title ?? 'No data available',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.grey700,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Standardized skeleton loading widget for list items and cards
class StandardSkeleton extends StatefulWidget {
  const StandardSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16.0,
    this.borderRadius = 4.0,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<StandardSkeleton> createState() => _StandardSkeletonState();
}

class _StandardSkeletonState extends State<StandardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: [
                AppColors.skeletonBase,
                AppColors.skeletonHighlight,
                AppColors.skeletonBase,
              ],
              stops: [
                0.0,
                _animation.value,
                1.0,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        );
      },
    );
  }
}
