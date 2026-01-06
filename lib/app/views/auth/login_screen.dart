// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../main_layout.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import '../widgets/social_login_button.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewModel>();
    if (authViewModel.isLoading)
      return; // SECURITY FIX: Prevent double-submission

    final success = await authViewModel.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    _handleAuthResult(success, authViewModel.errorMessage);
  }

  Future<void> _handleGoogleLogin() async {
    final authViewModel = context.read<AuthViewModel>();
    if (authViewModel.isLoading)
      return; // SECURITY FIX: Prevent double-submission

    final success = await authViewModel.signInWithGoogle();
    _handleAuthResult(success, authViewModel.errorMessage);
  }

  void _handleAuthResult(bool success, String? errorMessage) {
    if (!mounted) return;
    
    // Success is handled by AuthWrapperApp listening to AuthViewModel
    // which will rebuild and show MainLayout automatically.
    
    if (!success) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text('خطأ في تسجيل الدخول', style: TextStyle(color: Colors.white)),
          content: Text(
            errorMessage ?? 'فشل تسجيل الدخول',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً', style: TextStyle(color: Color(0xFFE5FF17))), // AppTheme.kElectricLime
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5FF17), // Custom Yellow
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Section (Lime)
          Padding(
            padding: EdgeInsets.only(
              right: 16.w,
              left: 16.w,
              top: 120.h,
              bottom: 24.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تسجيل الدخول',
                  style: TextStyle(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'قم بإدخال البريد الإلكتروني وكلمة المرور لتسجيل الدخول',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Bottom Section (Black)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF000000), // Pure Black for contrast
                borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 40.h, 16.w, 24.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email
                      AuthTextField(
                        controller: _emailController,
                        label: 'البريد الإلكتروني',
                        icon: Icons.email_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال البريد الإلكتروني';
                          }
                          // SECURITY FIX: Stronger email validation
                          final emailRegex = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          );
                          if (!emailRegex.hasMatch(value)) {
                            return 'البريد الإلكتروني غير صحيح';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Password
                      AuthTextField(
                        controller: _passwordController,
                        label: 'كلمة المرور',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        obscureText: _obscurePassword,
                        onTogglePassword: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال كلمة المرور';
                          }
                          if (value.length < 6) {
                            return 'كلمة المرور قصيرة جداً';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16.h),
                      // Forgot Password
                      Padding(
                        padding: EdgeInsets.only(top: 12.h, bottom: 24.h),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'نسيت كلمة المرور؟',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Login Button (White Pill)
                      Consumer<AuthViewModel>(
                        builder: (context, vm, _) {
                          return ElevatedButton(
                            onPressed: vm.isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.only(right: 8.w),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999.r),
                              ),
                              elevation: 0,
                            ),
                            child: vm.isLoading
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
                                          'تسجيل الدخول',
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(16.w),
                                          decoration: const BoxDecoration(
                                            color: Colors.black,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.arrow_forward,
                                            color: Colors.white,
                                            size: 24.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          );
                        },
                      ),

                      SizedBox(height: 32.h),

                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white54)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Text(
                              'أو',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.white54)),
                        ],
                      ),

                      SizedBox(height: 32.h),

                      // Social Buttons
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Row(
                          children: [
                            SocialLoginButton(
                              text: 'جوجل',
                              icon: FontAwesomeIcons.google,
                              onPressed: _handleGoogleLogin,
                            ),
                            SizedBox(width: 16.w),
                            SocialLoginButton(
                              text: 'أبل',
                              icon: FontAwesomeIcons.apple,
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'تسجيل الدخول عبر أبل قريباً',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 40.h),

                      // Sign Up Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "ليس لديك حساب؟",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'إنشاء حساب',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
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
