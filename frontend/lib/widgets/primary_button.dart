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
    this.fontSize = 17,
    this.borderRadius = 12,
    this.padding,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;
    final bgColor = color ?? accent;
    final fgColor = textColor ?? Colors.white;
    final effectivePadding = padding ?? const EdgeInsets.symmetric(vertical: 14, horizontal: 20);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius));

    final effectiveChild = loading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == PrimaryButtonVariant.outlined ? accent : fgColor,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: variant == PrimaryButtonVariant.outlined ? accent : fgColor),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: variant == PrimaryButtonVariant.outlined ? accent : fgColor,
                  letterSpacing: 0,
                ),
              ),
            ],
          );

    final Widget button;

    if (variant == PrimaryButtonVariant.glass) {
      button = GlassContainer(
        backgroundColor: isDark
            ? const Color(0xFF1C1C1E).withValues(alpha: 0.75)
            : Colors.white.withValues(alpha: 0.80),
        borderRadius: borderRadius,
        blurX: 30,
        blurY: 30,
        onTap: loading ? null : onPressed,
        padding: effectivePadding,
        child: Center(child: effectiveChild),
      );
    } else if (variant == PrimaryButtonVariant.outlined) {
      button = OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: effectivePadding,
          minimumSize: expanded ? const Size(double.infinity, 50) : const Size(44, 50),
          shape: shape,
          foregroundColor: accent,
          side: BorderSide(color: accent, width: 1.5),
          textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
        ),
        child: effectiveChild,
      );
    } else {
      button = ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: effectivePadding,
          minimumSize: expanded ? const Size(double.infinity, 50) : const Size(44, 50),
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          disabledBackgroundColor: bgColor.withValues(alpha: 0.40),
          shape: shape,
          elevation: elevation ?? 0,
          shadowColor: Colors.transparent,
          textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
        ),
        child: effectiveChild,
      );
    }

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
