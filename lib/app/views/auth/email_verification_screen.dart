// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../main_layout.dart';
import '../../viewmodels/auth_viewmodel.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;

  const OTPVerificationScreen({super.key, required this.email});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _lastResendTime; // SECURITY FIX: For rate-limiting
  static const _resendCooldown = Duration(seconds: 60);

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewModel>();
    if (authViewModel.isLoading)
      return; // SECURITY FIX: Prevent double-submission

    final success = await authViewModel.verifyOTP(
      email: widget.email,
      token: _otpController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainLayout()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.errorMessage ?? 'رمز التحقق غير صحيح'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleResend() async {
    // SECURITY FIX: Rate-limiting check
    if (_lastResendTime != null) {
      final elapsed = DateTime.now().difference(_lastResendTime!);
      if (elapsed < _resendCooldown) {
        final remaining = (_resendCooldown - elapsed).inSeconds;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('يمكنك إعادة الإرسال بعد $remaining ثانية'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
    }

    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.resendOTP(widget.email);

    if (!mounted) return;

    if (success) {
      _lastResendTime = DateTime.now(); // Record time
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إعادة إرسال رمز التحقق'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ في إعادة الإرسال'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kDarkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20.h),
                Icon(
                  Icons.mark_email_unread,
                  size: 80.w,
                  color: AppTheme.kElectricLime,
                ),
                SizedBox(height: 24.h),
                Text(
                  'أدخل رمز التحقق',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'تم إرسال رمز التحقق إلى',
                  style: TextStyle(fontSize: 14.sp, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.email,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.kElectricLime,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),

                // OTP Field
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    letterSpacing: 8.w,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '000000',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      letterSpacing: 8.w,
                    ),
                    filled: true,
                    fillColor: AppTheme.kLightBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  maxLength: 6,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رمز التحقق';
                    }
                    // SECURITY FIX: Enforce numeric-only 6 digits
                    if (value.length != 6 ||
                        !RegExp(r'^\d{6}$').hasMatch(value)) {
                      return 'رمز التحقق يجب أن يكون 6 أرقام فقط';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),

                // Verify Button
                Consumer<AuthViewModel>(
                  builder: (context, authViewModel, child) {
                    return ElevatedButton(
                      onPressed: authViewModel.isLoading ? null : _handleVerify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.kElectricLime,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: authViewModel.isLoading
                          ? SizedBox(
                              height: 20.w,
                              width: 20.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : Text(
                              'تحقق',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  },
                ),
                SizedBox(height: 16.h),

                // Resend Button
                TextButton(
                  onPressed: _handleResend,
                  child: const Text(
                    'إعادة إرسال الرمز',
                    style: TextStyle(color: AppTheme.kElectricLime),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
