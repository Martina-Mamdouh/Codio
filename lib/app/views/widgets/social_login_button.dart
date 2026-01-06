import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(
            255,
            54,
            54,
            54,
          ), // Match input field bg
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            vertical: 2.h,
            horizontal: 2.w,
          ), // Taller to match inputs
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999.r),
            side: const BorderSide(
              color: Color.fromARGB(26, 48, 46, 46),
            ), // Subtle border
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp, // Reduced slightly
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 16.w), // Reduced from 16.w
            Container(
              padding: EdgeInsets.all(12.r), // Reduced from 16.r
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(221, 12, 12, 12),
              ),
              child: Icon(
                icon,
                size: 20.sp,
                color: Colors.white,
              ), // Reduced size slightly
            ),
          ],
        ),
      ),
    );
  }
}
