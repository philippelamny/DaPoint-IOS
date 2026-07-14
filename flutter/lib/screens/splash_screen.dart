import 'package:flutter/material.dart';

import '../theme/brand.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _dAnim;
  late final Animation<double> _pointAnim;
  late final Animation<double> _textAnim;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    // Staggered reveal: the "D" pops in, then the orange point bounces
    // into place, then the wordmark fades up.
    _dAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
    );
    _pointAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.85, curve: Curves.elasticOut),
    );
    _textAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
    );
    _runAnimation();
  }

  Future<void> _runAnimation() async {
    setState(() => _visible = true);
    await _controller.forward();
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: Brand.gradient),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final dScale = _visible ? 0.55 + 0.45 * _dAnim.value : 0.55;
              final dOpacity = _visible ? _dAnim.value.clamp(0.0, 1.0) : 0.0;
              final pointProgress = _visible ? _pointAnim.value : 0.0;
              final textOpacity = _visible ? _textAnim.value.clamp(0.0, 1.0) : 0.0;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: dScale,
                    child: Opacity(
                      opacity: dOpacity,
                      child: LogoMark(size: 140, pointProgress: pointProgress),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Opacity(
                    opacity: textOpacity,
                    child: Transform.translate(
                      offset: Offset(0, (1 - textOpacity) * 12),
                      child: Column(
                        children: [
                          const Text(
                            'DaPoint',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'SUIVI DE JEUX',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.7),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
