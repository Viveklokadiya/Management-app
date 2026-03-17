import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, danger }

enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.size = AppButtonSize.medium,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            height: _loaderSize,
            width: _loaderSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_loaderColor),
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: _iconSize),
                  const SizedBox(width: 8),
                  Text(label, style: _textStyle),
                ],
              )
            : Text(label, style: _textStyle);

    final button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            padding: _padding,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: child,
        ),
      AppButtonVariant.secondary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.textOnPrimary,
            padding: _padding,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: child,
        ),
      AppButtonVariant.outline => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: _padding,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: child,
        ),
      AppButtonVariant.danger => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.textOnPrimary,
            padding: _padding,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: child,
        ),
    };

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }

  EdgeInsets get _padding => switch (size) {
        AppButtonSize.small =>
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        AppButtonSize.medium =>
          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        AppButtonSize.large =>
          const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
      };

  TextStyle get _textStyle => switch (size) {
        AppButtonSize.small => AppTextStyles.buttonMedium,
        AppButtonSize.medium => AppTextStyles.buttonLarge,
        AppButtonSize.large => AppTextStyles.buttonLarge,
      };

  double get _iconSize => size == AppButtonSize.small ? 16 : 20;
  double get _loaderSize => size == AppButtonSize.small ? 16 : 20;

  Color get _loaderColor => variant == AppButtonVariant.outline
      ? AppColors.primary
      : AppColors.textOnPrimary;
}
