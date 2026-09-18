import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

enum PrimaryButtonVariant { filled, outlined, glass }

class PrimaryButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;
  final bool expanded;
  final PrimaryButtonVariant variant;
  final Color? color;
  final Color? textColor;
  final double fontSize;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? elevation;

  const PrimaryButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.loading = false,
    this.expanded = true,
    this.variant = PrimaryButtonVariant.filled,
    this.color,
    this.textColor,
    this.fontSize = 16,
    this.borderRadius = 14,
    this.padding,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = color ?? AppColors.icePrimary;
    final fgColor = textColor ?? Colors.white;
    final effectivePadding = padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 22);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius));

    final effectiveChild = loading
        ? SizedBox(
            height: 24, width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.6,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == PrimaryButtonVariant.outlined ? bgColor : fgColor,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: variant == PrimaryButtonVariant.outlined ? bgColor : fgColor),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: variant == PrimaryButtonVariant.outlined ? bgColor : fgColor,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          );

    final Widget button;

    if (variant == PrimaryButtonVariant.glass) {
      button = GlassContainer(
        backgroundColor: isDark
            ? AppColors.darkGlass.withAlpha(180)
            : AppColors.lightGlassStrong.withAlpha(200),
        borderRadius: borderRadius,
        onTap: loading ? null : onPressed,
        padding: effectivePadding,
        child: Center(child: effectiveChild),
      );
    } else if (variant == PrimaryButtonVariant.outlined) {
      button = OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: effectivePadding,
          minimumSize: expanded ? const Size(double.infinity, 52) : null,
          shape: shape,
          foregroundColor: bgColor,
          side: BorderSide(color: bgColor, width: 1.5),
          textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700),
        ),
        child: effectiveChild,
      );
    } else {
      button = ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: effectivePadding,
          minimumSize: expanded ? const Size(double.infinity, 52) : null,
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          disabledBackgroundColor: bgColor.withAlpha(100),
          shape: shape,
          elevation: elevation ?? 0,
          shadowColor: bgColor.withAlpha(120),
          textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
        child: effectiveChild,
      );
    }

    return expanded && variant != PrimaryButtonVariant.filled
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
