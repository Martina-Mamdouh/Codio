import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'package:kodio_app/app/views/auth/auth_wrapper_app.dart';
import 'package:kodio_app/core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> dot1;
  late Animation<double> dot2;
  late Animation<double> dot3;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();

    dot1 = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6),
    );
    dot2 = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8),
    );
    dot3 = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0),
    );

    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthWrapperApp()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kDarkBackground,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // اللوغو القديم
            Image.asset(
              "assets/images/splach_screen.PNG",
              width: 230.w,
              height: 140.w,
              fit: BoxFit.fitWidth,
              cacheWidth: 600,
            ),
            // الثلاث نقط
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(dot1),
                SizedBox(width: 12.w),
                _buildDot(dot2),
                SizedBox(width: 12.w),
                _buildDot(dot3),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(Animation<double> anim) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, __) => Opacity(
        opacity: anim.value,
        child: Container(
          width: 14.w,
          height: 14.w,
          decoration: const BoxDecoration(
            color: AppTheme.kElectricLime,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
