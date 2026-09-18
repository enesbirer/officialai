import 'package:flutter/material.dart';
import 'dart:ui';

class AppColors {
  static const Color icePrimary = Color(0xFF00A8E1);
  static const Color iceSecondary = Color(0xFF0077B6);
  static const Color iceAccent = Color(0xFF48CAE4);
  static const Color iceHint = Color(0xFF90E0EF);
  static const Color iceCream = Color(0xFFCAF0F8);

  static const Color darkBgStart = Color(0xFF020B1C);
  static const Color darkBgMid = Color(0xFF0A1E3C);
  static const Color darkBgEnd = Color(0xFF112B56);
  static const Color darkGlass = Color(0x6614284A);
  static const Color darkGlassStrong = Color(0x991A2A4A);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFB8C5D6);
  static const Color darkTextHint = Color(0xFF7C8CA8);
  static const Color darkBorder = Color(0x33FFFFFF);
  static const Color darkBorderStrong = Color(0x55FFFFFF);

  static const Color lightBgStart = Color(0xFFE0F2FE);
  static const Color lightBgMid = Color(0xFFF0F9FF);
  static const Color lightBgEnd = Color(0xFFFFFFFF);
  static const Color lightGlass = Color(0x88FFFFFF);
  static const Color lightGlassStrong = Color(0xCCFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0B1A36);
  static const Color lightTextSecondary = Color(0xFF334155);
  static const Color lightTextHint = Color(0xFF64748B);
  static const Color lightBorder = Color(0x330A1E3C);
  static const Color lightBorderStrong = Color(0x550A1E3C);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}

class AppGlass {
  static const double blurX = 18.0;
  static const double blurY = 18.0;
  static const double borderRadius = 20.0;
  static const double borderWidth = 1.0;
}

class AppTheme {
  // ====== BUZLU CAM Koyu Tema ======
  static ThemeData get darkTheme {
    const primary = AppColors.icePrimary;
    const onPrimary = Color(0xFF020B1C);
    const background = AppColors.darkBgMid;
    const surface = Color(0x11FFFFFF);
    const onSurface = AppColors.darkTextPrimary;
    const error = AppColors.error;

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: AppColors.iceSecondary,
      onPrimaryContainer: AppColors.iceCream,
      secondary: AppColors.iceAccent,
      onSecondary: onPrimary,
      secondaryContainer: AppColors.darkBgEnd,
      onSecondaryContainer: AppColors.darkTextPrimary,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: AppColors.darkBgEnd,
      error: error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
      fontFamily: 'Roboto',
      textTheme: _darkTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: _darkTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary, size: 24),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.darkGlass,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppGlass.borderRadius),
          side: const BorderSide(color: AppColors.darkBorder, width: AppGlass.borderWidth),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.icePrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.darkBgEnd,
          disabledForegroundColor: AppColors.darkTextHint,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 0.4),
          shadowColor: AppColors.icePrimary.withAlpha(120),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.iceAccent,
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: const BorderSide(color: AppColors.iceAccent, width: 1.4),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.iceHint,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkGlass,
        hintStyle: const TextStyle(color: AppColors.darkTextHint, fontWeight: FontWeight.w400),
        labelStyle: const TextStyle(color: AppColors.darkTextSecondary, fontWeight: FontWeight.w500),
        prefixIconColor: AppColors.iceAccent,
        suffixIconColor: AppColors.iceAccent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: _glassBorder(Colors.transparent),
        enabledBorder: _glassBorder(AppColors.darkBorder),
        focusedBorder: _glassBorder(AppColors.icePrimary, width: 1.6),
        errorBorder: _glassBorder(AppColors.error),
        focusedErrorBorder: _glassBorder(AppColors.error, width: 1.6),
        disabledBorder: _glassBorder(AppColors.darkBorder.withAlpha(60)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.icePrimary.withAlpha(60),
        height: 70,
        labelTextStyle: WidgetStatePropertyAll(TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.darkTextSecondary)),
        iconTheme: const WidgetStatePropertyAll(IconThemeData(size: 26, color: AppColors.darkTextSecondary)),
      ),
      dividerTheme: DividerThemeData(color: AppColors.darkBorder.withAlpha(80), thickness: 1),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.icePrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkGlass,
        disabledColor: AppColors.darkBgEnd,
        selectedColor: AppColors.icePrimary.withAlpha(180),
        secondarySelectedColor: AppColors.iceSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: const BorderSide(color: AppColors.darkBorder, width: 0.6),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.iceAccent,
        textColor: AppColors.darkTextPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.icePrimary : AppColors.darkTextHint),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.iceSecondary.withAlpha(140) : AppColors.darkBgEnd),
      ),
      tabBarTheme: TabBarTheme(
        dividerColor: Colors.transparent,
        labelColor: AppColors.darkTextPrimary,
        unselectedLabelColor: AppColors.darkTextHint,
        indicatorColor: AppColors.icePrimary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: AppColors.icePrimary, circularTrackColor: AppColors.darkBgEnd),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkBgEnd,
        contentTextStyle: const TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.darkGlassStrong,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: const BorderSide(color: AppColors.darkBorderStrong)),
        titleTextStyle: _darkTextTheme.titleLarge,
      ),
    );
  }

  // ====== BUZLU CAM Açık Tema ======
  static ThemeData get lightTheme {
    const primary = AppColors.iceSecondary;
    const onPrimary = Colors.white;
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: AppColors.iceHint,
      onPrimaryContainer: AppColors.lightTextPrimary,
      secondary: AppColors.icePrimary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.iceCream,
      onSecondaryContainer: AppColors.lightTextPrimary,
      surface: Color(0x88FFFFFF),
      onSurface: AppColors.lightTextPrimary,
      surfaceContainerHighest: Color(0xCCFFFFFF),
      error: AppColors.error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
      fontFamily: 'Roboto',
      textTheme: _lightTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: _lightTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.lightGlass,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppGlass.borderRadius),
          side: const BorderSide(color: AppColors.lightBorder, width: AppGlass.borderWidth),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: primary.withAlpha(180), width: 1.4),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.iceSecondary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightGlass,
        hintStyle: const TextStyle(color: AppColors.lightTextHint),
        labelStyle: const TextStyle(color: AppColors.lightTextSecondary, fontWeight: FontWeight.w500),
        prefixIconColor: AppColors.iceSecondary,
        suffixIconColor: AppColors.iceSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: _glassBorder(Colors.transparent),
        enabledBorder: _glassBorder(AppColors.lightBorder),
        focusedBorder: _glassBorder(AppColors.iceSecondary, width: 1.6),
        errorBorder: _glassBorder(AppColors.error),
        focusedErrorBorder: _glassBorder(AppColors.error, width: 1.6),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: AppColors.icePrimary.withAlpha(50),
        height: 70,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightGlassStrong,
        selectedColor: AppColors.icePrimary.withAlpha(120),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: const BorderSide(color: AppColors.lightBorder, width: 0.6),
        labelStyle: const TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w500),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.lightGlassStrong,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: const BorderSide(color: AppColors.lightBorderStrong)),
      ),
    );
  }

  static InputBorder _glassBorder(Color color, {double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
      gapPadding: 4,
    );
  }

  static TextTheme get _darkTextTheme {
    const primary = AppColors.darkTextPrimary;
    const secondary = AppColors.darkTextSecondary;
    const hint = AppColors.darkTextHint;
    return TextTheme(
      displayLarge: TextStyle(fontSize: 52, fontWeight: FontWeight.w800, color: primary, letterSpacing: -1.2),
      displayMedium: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: primary, letterSpacing: -0.8),
      headlineLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: primary, letterSpacing: -0.4),
      headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: primary),
      headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: primary),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: primary, letterSpacing: 0.2),
      titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: primary),
      titleSmall: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: primary),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: primary, height: 1.45),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: secondary, height: 1.5),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: hint, height: 1.5),
      labelLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: primary, letterSpacing: 0.3),
      labelMedium: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: secondary),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: hint),
    );
  }

  static TextTheme get _lightTextTheme {
    const primary = AppColors.lightTextPrimary;
    const secondary = AppColors.lightTextSecondary;
    const hint = AppColors.lightTextHint;
    return TextTheme(
      displayLarge: TextStyle(fontSize: 52, fontWeight: FontWeight.w800, color: primary, letterSpacing: -1.2),
      displayMedium: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: primary, letterSpacing: -0.8),
      headlineLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: primary, letterSpacing: -0.4),
      headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: primary),
      headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: primary),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: primary, letterSpacing: 0.2),
      titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: primary),
      titleSmall: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: primary),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: primary, height: 1.45),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: secondary, height: 1.5),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: hint, height: 1.5),
      labelLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: primary),
      labelMedium: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: secondary),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: hint),
    );
  }
}

// ====== BUZLU ARKA PLAN GRADYANLARI ======
class GlassBackground {
  static List<Color> darkIceColors = const [
    AppColors.darkBgStart,
    Color(0xFF041028),
    AppColors.darkBgMid,
    Color(0xFF0F254A),
    AppColors.darkBgEnd,
  ];

  static List<Alignment> darkIceAlignments = const [
    Alignment.topLeft,
    Alignment.topRight,
    Alignment.center,
    Alignment.bottomLeft,
    Alignment.bottomRight,
  ];

  static List<double> darkIceStops = const [0.0, 0.25, 0.5, 0.75, 1.0];

  static List<Color> lightIceColors = const [
    Color(0xFFBAE6FD),
    AppColors.lightBgStart,
    AppColors.lightBgMid,
    Color(0xFFE0F7FF),
    AppColors.lightBgEnd,
  ];

  static Widget iceDarkGradient({Widget? child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: darkIceColors,
          stops: darkIceStops,
        ),
      ),
      child: Stack(
        children: [
          // Ice blobs
          Positioned(
            top: -100, left: -60,
            child: _blob(AppColors.icePrimary.withAlpha(35), 260),
          ),
          Positioned(
            top: 120, right: -80,
            child: _blob(AppColors.iceSecondary.withAlpha(30), 240),
          ),
          Positioned(
            bottom: -60, left: 100,
            child: _blob(AppColors.iceAccent.withAlpha(25), 220),
          ),
          Positioned(
            bottom: 100, right: 40,
            child: _blob(AppColors.iceHint.withAlpha(18), 180),
          ),
          if (child != null) Positioned.fill(child: child),
        ],
      ),
    );
  }

  static Widget iceLightGradient({Widget? child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: lightIceColors,
          stops: darkIceStops,
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -80, left: -40, child: _blob(AppColors.icePrimary.withAlpha(50), 240)),
          Positioned(top: 180, right: -60, child: _blob(AppColors.iceHint.withAlpha(70), 200)),
          Positioned(bottom: -60, left: 80, child: _blob(AppColors.iceAccent.withAlpha(40), 220)),
          if (child != null) Positioned.fill(child: child),
        ],
      ),
    );
  }

  static Widget _blob(Color color, double size) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ====== GlassContainer: BUZLU KART ======
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final double blurX;
  final double blurY;
  final Color? backgroundColor;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final AlignmentGeometry? alignment;
  final Clip? clipBehavior;
  final void Function()? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blurX = AppGlass.blurX,
    this.blurY = AppGlass.blurY,
    this.backgroundColor,
    this.border,
    this.boxShadow,
    this.alignment,
    this.clipBehavior,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(borderRadius ?? AppGlass.borderRadius);
    final bg = backgroundColor ?? (isDark ? AppColors.darkGlass : AppColors.lightGlass);
    final effectiveBorder = border ??
        Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: AppGlass.borderWidth,
        );
    final shadows = boxShadow ??
        [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 15),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ];

    Widget body = Container(
      width: width,
      height: height,
      alignment: alignment,
      margin: margin,
      child: ClipRRect(
        borderRadius: radius,
        clipBehavior: clipBehavior ?? Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurX, sigmaY: blurY, tileMode: TileMode.clamp),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: radius,
              border: effectiveBorder,
              boxShadow: shadows,
            ),
            alignment: alignment,
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: radius,
        highlightColor: AppColors.icePrimary.withAlpha(20),
        splashColor: AppColors.icePrimary.withAlpha(15),
        child: body,
      );
    }
    return body;
  }
}

class GlassDivider extends StatelessWidget {
  final double? height;
  final double thickness;
  final double? indent;
  final double? endIndent;
  final Color? color;
  const GlassDivider({
    super.key,
    this.height,
    this.thickness = 0.5,
    this.indent,
    this.endIndent,
    this.color,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: height ?? 16,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: color ?? (isDark ? AppColors.darkBorder.withAlpha(80) : AppColors.lightBorder.withAlpha(80)),
    );
  }
}
