import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onTogglePassword;
  final String? Function(String?)? validator;
  final String? initialValue; // Just in case, though controller is preferred

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.obscureText = false,
    this.onTogglePassword,
    this.validator,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 66.h, // Removed fixed height to prevent overflow
      padding: EdgeInsets.symmetric(horizontal: 1.w),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withAlpha(85)),
      ),
      child: Row(
        children: [
          /// ICON BOX
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: Colors.white.withAlpha(180), size: 26.sp),
          ),

          SizedBox(width: 14.w),

          /// TEXT FIELD
          Expanded(
            child: TextFormField(
              controller: controller,
              onChanged: (val) {
                controller.text = val;
                controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length),
                );
              },
              obscureText: obscureText,
              validator: validator,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                label: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withAlpha(180),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                fillColor: Colors.transparent,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                errorStyle: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          /// PASSWORD TOGGLE
          if (isPassword)
            GestureDetector(
              onTap: onTogglePassword,
              child: Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white.withAlpha(180),
                  size: 24.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
