import 'package:flutter/material.dart';

import '../utils/color_utils.dart';

enum AppButtonVariant {
  primary,
  secondary,
  inverted,
  outlined,
}

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.leading,
    this.fullWidth = true,
    this.padding,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final Widget? leading;
  final bool fullWidth;
  final EdgeInsetsGeometry? padding;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors(context, variant);

    final style = OutlinedButton.styleFrom(
      backgroundColor: colors.background,
      foregroundColor: colors.foreground,
      disabledBackgroundColor: colors.backgroundDisabled,
      disabledForegroundColor: colors.foregroundDisabled,
      side: BorderSide(color: colors.border, width: 1),
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );

    final child = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(colors.foreground),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (leading != null) ...[
          IconTheme(
            data: IconThemeData(color: colors.foreground, size: 18),
            child: leading!,
          ),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: OutlinedButton(
        style: style,
        onPressed: _enabled ? onPressed : null,
        child: child,
      ),
    );
  }
}

({Color background, Color foreground, Color border, Color backgroundDisabled, Color foregroundDisabled})
    _resolveColors(BuildContext context, AppButtonVariant variant) {
  final disabledBg = AppColors.neutral.withValues(alpha: 0.10);
  final disabledFg = AppColors.neutral.withValues(alpha: 0.45);

  switch (variant) {
    case AppButtonVariant.primary:
      return (
        background: AppColors.primary,
        foreground: Colors.white,
        border: Colors.transparent,
        backgroundDisabled: disabledBg,
        foregroundDisabled: disabledFg,
      );

    case AppButtonVariant.secondary:
      return (
        background: AppColors.secondary,
        foreground: AppColors.neutral,
        border: Colors.transparent,
        backgroundDisabled: AppColors.secondary.withValues(alpha: 0.5),
        foregroundDisabled: disabledFg,
      );

    case AppButtonVariant.inverted:
      return (
        background: AppColors.neutral,
        foreground: AppColors.secondary,
        border: Colors.transparent,
        backgroundDisabled: disabledBg,
        foregroundDisabled: disabledFg,
      );

    case AppButtonVariant.outlined:
      return (
        background: Colors.transparent,
        foreground: AppColors.primary,
        border: AppColors.primary,
        backgroundDisabled: Colors.transparent,
        foregroundDisabled: disabledFg,
      );
  }
}

