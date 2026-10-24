import 'package:flutter/material.dart';
import 'dart:ui';

// =====================================================================
// OfficialAI — Apple (iOS) Tasarım Sistemi
// • Zemin   : Grouped Background (açık #F2F2F7 / koyu #000000)
// • Kartlar : tam beyaz (#FFFFFF) / #1C1C1E, squircle 14pt ovallik
// • Vurgu   : tek ana renk = System Blue (#007AFF / #0A84FF)
// • Ayraç   : hairline 0.5pt (separator)
// =====================================================================

class AppColors {
  // Vurgu rengi (Accent)
  static const Color accent = Color(0xFF007AFF);
  static const Color accentDark = Color(0xFF0A84FF);

  // Geriye dönük uyumluluk için korunmuş eski isimler
  static const Color icePrimary = Color(0xFF007AFF);
  static const Color iceSecondary = Color(0xFF0055CC);
  static const Color iceAccent = Color(0xFF0A84FF);
  static const Color iceHint = Color(0xFF5AC8FA);
  static const Color iceCream = Color(0xFFE8F1FF);

  // Zemin / Kart — Koyu
  static const Color darkBgStart = Color(0xFF000000);
  static const Color darkBgMid = Color(0xFF000000);
  static const Color darkBgEnd = Color(0xFF1C1C1E);
  static const Color darkGlass = Color(0xFF1C1C1E);
  static const Color darkGlassStrong = Color(0xFF2C2C2E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0x99EBEBF5);
  static const Color darkTextHint = Color(0x4DEBEBF5);
  static const Color darkBorder = Color(0x33545458);
  static const Color darkBorderStrong = Color(0x80545458);

  // Zemin / Kart — Açık
  static const Color lightBgStart = Color(0xFFF2F2F7);
  static const Color lightBgMid = Color(0xFFF2F2F7);
  static const Color lightBgEnd = Color(0xFFFFFFFF);
  static const Color lightGlass = Color(0xFFFFFFFF);
  static const Color lightGlassStrong = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0x993C3C43);
  static const Color lightTextHint = Color(0x4D3C3C43);
  static const Color lightBorder = Color(0x293C3C43);
  static const Color lightBorderStrong = Color(0x5C3C3C43);

  // Sistem dolguları (fill) — giriş alanları için
  static const Color lightFill = Color(0x1F767680);
  static const Color darkFill = Color(0x5C787880);

  // Durum renkleri (iOS)
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color error = Color(0xFFFF3B30);
  static const Color info = Color(0xFF007AFF);
}

class AppGlass {
  static const double blurX = 30.0;
  static const double blurY = 30.0;
  static const double borderRadius = 14.0;
  static const double borderWidth = 0.5;
}

class AppTheme {
  // ====== KOYU TEMA ======
  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.accentDark,
      onPrimary: Colors.white,
      primaryContainer: AppColors.iceSecondary,
      onPrimaryContainer: Colors.white,
      secondary: AppColors.iceHint,
      onSecondary: Colors.black,
      secondaryContainer: AppColors.darkGlassStrong,
      onSecondaryContainer: AppColors.darkTextPrimary,
      surface: AppColors.darkGlass,
      onSurface: AppColors.darkTextPrimary,
      surfaceContainerHighest: AppColors.darkGlassStrong,
      error: AppColors.error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBgStart,
      canvasColor: AppColors.darkBgStart,
      textTheme: _darkTextTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBgStart,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
        iconTheme: IconThemeData(color: AppColors.accentDark, size: 22),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.darkGlass,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppGlass.borderRadius)),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentDark,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.darkGlassStrong,
          disabledForegroundColor: AppColors.darkTextHint,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          minimumSize: const Size(44, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentDark,
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          minimumSize: const Size(44, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: AppColors.accentDark, width: 1.5),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentDark,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          minimumSize: const Size(44, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkFill,
        hintStyle: const TextStyle(color: AppColors.darkTextHint, fontWeight: FontWeight.w400),
        labelStyle: const TextStyle(color: AppColors.darkTextSecondary, fontWeight: FontWeight.w400),
        floatingLabelStyle: const TextStyle(color: AppColors.accentDark, fontWeight: FontWeight.w500),
        prefixIconColor: AppColors.darkTextHint,
        suffixIconColor: AppColors.darkTextHint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _hairline(Colors.transparent),
        enabledBorder: _hairline(Colors.transparent),
        focusedBorder: _hairline(AppColors.accentDark, width: 2),
        errorBorder: _hairline(AppColors.error, width: 1.5),
        focusedErrorBorder: _hairline(AppColors.error, width: 2),
        disabledBorder: _hairline(Colors.transparent),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.accentDark,
        unselectedItemColor: AppColors.darkTextHint,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        height: 52,
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.darkTextHint),
        ),
        iconTheme: const WidgetStatePropertyAll(
          IconThemeData(size: 26, color: AppColors.darkTextHint),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.darkBorder, thickness: 0.5, space: 0.5),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentDark,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkGlassStrong,
        disabledColor: AppColors.darkGlass,
        selectedColor: AppColors.accentDark,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w500, fontSize: 15),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide.none,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.accentDark,
        textColor: AppColors.darkTextPrimary,
        minVerticalPadding: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppGlass.borderRadius))),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.success : AppColors.darkGlassStrong,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      tabBarTheme: const TabBarThemeData(
        dividerColor: Colors.transparent,
        labelColor: AppColors.accentDark,
        unselectedLabelColor: AppColors.darkTextHint,
        indicatorColor: AppColors.accentDark,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accentDark,
        circularTrackColor: AppColors.darkGlassStrong,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkGlassStrong,
        contentTextStyle: const TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w500, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkGlassStrong,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        titleTextStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
      ),
    );
  }

  // ====== AÇIK TEMA ======
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.accent,
      onPrimary: Colors.white,
      primaryContainer: AppColors.iceCream,
      onPrimaryContainer: AppColors.lightTextPrimary,
      secondary: AppColors.iceSecondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.iceCream,
      onSecondaryContainer: AppColors.lightTextPrimary,
      surface: AppColors.lightGlass,
      onSurface: AppColors.lightTextPrimary,
      surfaceContainerHighest: AppColors.lightBgStart,
      error: AppColors.error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBgStart,
      canvasColor: AppColors.lightBgStart,
      textTheme: _lightTextTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBgStart,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary),
        iconTheme: IconThemeData(color: AppColors.accent, size: 22),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.lightGlass,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppGlass.borderRadius)),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.lightFill,
          disabledForegroundColor: AppColors.lightTextHint,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          minimumSize: const Size(44, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          minimumSize: const Size(44, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: AppColors.accent, width: 1.5),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          minimumSize: const Size(44, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightFill,
        hintStyle: const TextStyle(color: AppColors.lightTextHint, fontWeight: FontWeight.w400),
        labelStyle: const TextStyle(color: AppColors.lightTextSecondary, fontWeight: FontWeight.w400),
        floatingLabelStyle: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w500),
        prefixIconColor: AppColors.lightTextHint,
        suffixIconColor: AppColors.lightTextHint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _hairline(Colors.transparent),
        enabledBorder: _hairline(Colors.transparent),
        focusedBorder: _hairline(AppColors.accent, width: 2),
        errorBorder: _hairline(AppColors.error, width: 1.5),
        focusedErrorBorder: _hairline(AppColors.error, width: 2),
        disabledBorder: _hairline(Colors.transparent),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.lightTextHint,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        height: 52,
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.lightTextHint),
        ),
        iconTheme: const WidgetStatePropertyAll(
          IconThemeData(size: 26, color: AppColors.lightTextHint),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.lightBorder, thickness: 0.5, space: 0.5),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightBgStart,
        disabledColor: AppColors.lightFill,
        selectedColor: AppColors.accent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w500, fontSize: 15),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide.none,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.accent,
        textColor: AppColors.lightTextPrimary,
        minVerticalPadding: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppGlass.borderRadius))),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.success : AppColors.lightFill,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      tabBarTheme: const TabBarThemeData(
        dividerColor: Colors.transparent,
        labelColor: AppColors.accent,
        unselectedLabelColor: AppColors.lightTextHint,
        indicatorColor: AppColors.accent,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
        circularTrackColor: AppColors.lightFill,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkGlassStrong,
        contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightGlass,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        titleTextStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary),
      ),
    );
  }

  static InputBorder _hairline(Color color, {double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static TextTheme get _darkTextTheme => const TextTheme(
        displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary, letterSpacing: 0.4),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary),
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
        titleLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
        titleSmall: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
        bodyLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: AppColors.darkTextPrimary, height: 1.35),
        bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.darkTextSecondary, height: 1.4),
        bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.darkTextSecondary, height: 1.4),
        labelLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
        labelMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.darkTextSecondary),
        labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.darkTextHint),
      );

  static TextTheme get _lightTextTheme => const TextTheme(
        displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary, letterSpacing: 0.4),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary),
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary),
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary),
        titleLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary),
        titleSmall: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary),
        bodyLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: AppColors.lightTextPrimary, height: 1.35),
        bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.lightTextSecondary, height: 1.4),
        bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.lightTextSecondary, height: 1.4),
        labelLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary),
        labelMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.lightTextSecondary),
        labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.lightTextHint),
      );
}

// ====== GROUPED BACKGROUND (düz zemin) ======
class GlassBackground {
  static List<Color> darkIceColors = const [AppColors.darkBgStart, AppColors.darkBgEnd];
  static List<Alignment> darkIceAlignments = const [Alignment.topCenter, Alignment.bottomCenter];
  static List<double> darkIceStops = const [0.0, 1.0];
  static List<Color> lightIceColors = const [AppColors.lightBgStart, AppColors.lightBgEnd];

  static Widget iceDarkGradient({Widget? child}) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.darkBgStart),
      child: Stack(
        children: [
          if (child != null) Positioned.fill(child: child),
        ],
      ),
    );
  }

  static Widget iceLightGradient({Widget? child}) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.lightBgStart),
      child: Stack(
        children: [
          if (child != null) Positioned.fill(child: child),
        ],
      ),
    );
  }
}

// ====== KART (squircle, tam beyaz / #1C1C1E) ======
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
    final shadows = boxShadow ?? const <BoxShadow>[];
    final translucent = bg.a < 1.0;
    final accent = isDark ? AppColors.accentDark : AppColors.accent;

    Widget inner = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        border: effectiveBorder,
        boxShadow: shadows,
      ),
      alignment: alignment,
      child: child,
    );

    if (translucent) {
      inner = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurX, sigmaY: blurY, tileMode: TileMode.clamp),
        child: inner,
      );
    }

    Widget body = Container(
      width: width,
      height: height,
      alignment: alignment,
      margin: margin,
      child: ClipRRect(
        borderRadius: radius,
        clipBehavior: clipBehavior ?? Clip.antiAlias,
        child: inner,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: radius,
        highlightColor: accent.withValues(alpha: 0.10),
        splashColor: accent.withValues(alpha: 0.08),
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
      color: color ?? (isDark ? AppColors.darkBorder : AppColors.lightBorder),
    );
  }
}
