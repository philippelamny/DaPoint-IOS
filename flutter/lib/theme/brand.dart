import 'package:flutter/material.dart';

abstract final class Brand {
  static const start = Color.fromRGBO(46, 66, 212, 1); // 0.18, 0.26, 0.83
  static const end = Color.fromRGBO(125, 36, 212, 1); // 0.49, 0.14, 0.83
  static const accent = Color.fromRGBO(255, 158, 0, 1); // 1.00, 0.62, 0.00
  static const surfaceTint = Color.fromRGBO(46, 66, 212, 0.06);

  static const gradient = LinearGradient(
    colors: [start, end],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData theme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: start,
      primary: start,
      secondary: accent,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF6F6FB),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: Color(0xFF1B1B2A),
        titleTextStyle: TextStyle(
          color: Color(0xFF1B1B2A),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: start,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: start,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE3E3EE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE3E3EE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: start, width: 1.6),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFECECF4)),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? start : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? start.withValues(alpha: 0.5)
              : null,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: start,
          selectedForegroundColor: Colors.white,
        ),
      ),
    );
  }
}

/// Mirrors LogoMark from AppIconView.swift: the "D" of DaPoint with its
/// accent-colored "point" dot.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 120, this.pointProgress = 1.0});

  final double size;

  /// 0 = point above its resting spot (mid-fall), 1 = point at rest.
  /// Drive this with a bounce curve (e.g. [Curves.bounceOut]) for a
  /// dropping-ball entrance; values stay within 0..1.
  final double pointProgress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Text(
            'D',
            style: TextStyle(
              fontSize: size * 0.68,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1,
            ),
          ),
          Positioned(
            left: size / 2 + size * 0.265 - size * 0.1,
            top: size / 2 + size * 0.225 - size * 0.1,
            child: Transform.translate(
              offset: Offset(0, (1 - pointProgress.clamp(0.0, 1.0)) * -size * 0.6),
              child: Container(
                width: size * 0.2,
                height: size * 0.2,
                decoration: BoxDecoration(
                  color: Brand.accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: size * 0.05,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mirrors AppIconView.swift: gradient background + LogoMark overlay.
class AppIconMark extends StatelessWidget {
  const AppIconMark({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.225),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(gradient: Brand.gradient),
        child: Center(child: LogoMark(size: size)),
      ),
    );
  }
}
