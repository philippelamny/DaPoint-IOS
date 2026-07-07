import 'package:flutter/material.dart';

abstract final class Brand {
  static const start = Color.fromRGBO(46, 66, 212, 1); // 0.18, 0.26, 0.83
  static const end = Color.fromRGBO(125, 36, 212, 1); // 0.49, 0.14, 0.83
  static const accent = Color.fromRGBO(255, 158, 0, 1); // 1.00, 0.62, 0.00

  static const gradient = LinearGradient(
    colors: [start, end],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Mirrors LogoMark from AppIconView.swift: the "D" of DaPoint with its
/// accent-colored "point" dot.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
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
