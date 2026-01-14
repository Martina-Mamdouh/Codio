import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/auth_text_field.dart';
import 'new_password_screen.dart';

class ResetPasswordOTPScreen extends StatefulWidget {
  final String email;

  const ResetPasswordOTPScreen({super.key, required this.email});

  @override
  State<ResetPasswordOTPScreen> createState() => _ResetPasswordOTPScreenState();
}

class _ResetPasswordOTPScreenState extends State<ResetPasswordOTPScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  DateTime? _lastResendTime; // SECURITY FIX: For rate-limiting
  static const _resendCooldown = Duration(seconds: 60);

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return; // FIX #1: Prevent double submission

    setState(() => _isLoading = true);

    try {
      // Verify OTP with Supabase
      final response = await Supabase.instance.client.auth.verifyOTP(
        email: widget.email,
        token: _otpController.text.trim(),
        type: OtpType.recovery,
      );

      if (!mounted) return;

      if (response.user != null) {
        // OTP verified successfully - navigate to password screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NewPasswordScreen(
              email: widget.email, // FIX #4: Removed token parameter
            ),
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('رمز التحقق غير صحيح'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      debugPrint('❌ Supabase OTP Verify Error: ${e.message}, Code: ${e.statusCode}');
      
      String errorMessage = 'رمز التحقق غير صحيح أو منتهي الصلاحية';
      if (e.statusCode == '429') {
        errorMessage = 'كثير من المحاولات. برجاء الانتظار قليلاً';
      } else if (e.message.contains('expired')) {
        errorMessage = 'رمز التحقق منتهي الصلاحية. الرجاء طلب رمز جديد';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      debugPrint('❌ Unexpected OTP Verify Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ غير متوقع. حاول مرة أخرى'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        widget.email,
        redirectTo: 'io.supabase.kodioapp://reset-callback/',
      );

      if (mounted) {
        _lastResendTime = DateTime.now(); // Record time
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إعادة إرسال رمز التحقق'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        debugPrint('❌ Supabase OTP Resend Error: ${e.message}, Code: ${e.statusCode}');
        String message = 'حدث خطأ في إعادة الإرسال';
        if (e.statusCode == '429') {
          message = 'برجاء الانتظار قليلاً قبل إعادة المحاولة';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        debugPrint('❌ Unexpected OTP Resend Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ غير متوقع'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5FF17), // Theme Lime
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Section (Lime)
          Padding(
            padding: EdgeInsets.only(
              right: 16.w,
              left: 16.w,
              top: 10.h,
              bottom: 16.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أدخل رمز التحقق',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'تم إرسال رمز التحقق إلى',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.email,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // Bottom Section (Black)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF000000), // Pure Black
                borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 32.h, 16.w, 24.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // OTP Field
                      AuthTextField(
                        controller: _otpController,
                        label: 'رمز التحقق',
                        icon: Icons.lock_clock_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال رمز التحقق';
                          }
                          // FIX #3: Validate 6 digits only (numeric)
                          if (value.length != 6 ||
                              !RegExp(r'^\d{6}$').hasMatch(value)) {
                            return 'رمز التحقق يجب أن يكون 6 أرقام فقط';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 32.h),

                      // Verify Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleVerify,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.only(right: 8.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 32.h,
                                width: 32.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Padding(
                                padding: EdgeInsets.only(
                                  left: 4.w,
                                  right: 16.w,
                                  top: 4.h,
                                  bottom: 4.h,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'التالي',
                                      style: TextStyle(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(12.w),
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                        size: 20.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),

                      SizedBox(height: 16.h),

                      // Resend Button
                      TextButton(
                        onPressed: _handleResend,
                        child: Text(
                          'إعادة إرسال الرمز',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
