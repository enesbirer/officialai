import 'package:flutter/material.dart';
import 'dart:ui';
import '../core/theme/app_theme.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enableSuggestions;
  final bool autocorrect;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool expands;
  final bool readOnly;
  final bool? enabled;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final String? initialValue;
  final TextAlign textAlign;
  final double borderRadius;
  final double blurX;
  final double blurY;
  final List<String>? autofillHints;
  final TextStyle? style;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.keyboardType,
    this.obscureText = false,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.expands = false,
    this.readOnly = false,
    this.enabled,
    this.onTap,
    this.onChanged,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.focusNode,
    this.initialValue,
    this.textAlign = TextAlign.start,
    this.borderRadius = 14,
    this.blurX = 18,
    this.blurY = 18,
    this.autofillHints,
    this.style,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(widget.borderRadius);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: widget.blurX, sigmaY: widget.blurY),
        child: TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText ? _obscured : false,
          enableSuggestions: widget.enableSuggestions,
          autocorrect: widget.autocorrect,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.obscureText ? 1 : widget.minLines,
          maxLength: widget.maxLength,
          expands: widget.expands,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          validator: widget.validator,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onFieldSubmitted,
          focusNode: widget.focusNode,
          textAlign: widget.textAlign,
          autofillHints: widget.autofillHints,
          style: widget.style ??
              TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            alignLabelWithHint: (widget.maxLines ?? 1) > 1,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: AppColors.iceAccent, size: 22)
                : null,
            suffixIcon: widget.obscureText
                ? InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() => _obscured = !_obscured),
                    child: Icon(
                      _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.iceAccent,
                      size: 22,
                    ),
                  )
                : (widget.suffixIcon != null
                    ? InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: widget.onSuffixTap,
                        child: Icon(widget.suffixIcon, color: AppColors.iceAccent, size: 22),
                      )
                    : null),
            filled: true,
            fillColor: isDark ? AppColors.darkGlass : AppColors.lightGlass,
            labelStyle: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
            hintStyle: TextStyle(
              color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
              fontWeight: FontWeight.w400,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: (widget.maxLines ?? 1) > 1 ? 18 : 16,
            ),
            border: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: const BorderSide(color: AppColors.icePrimary, width: 1.6),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: const BorderSide(color: AppColors.error, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: const BorderSide(color: AppColors.error, width: 1.6),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder.withAlpha(60) : AppColors.lightBorder.withAlpha(60),
                width: 0.8,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
