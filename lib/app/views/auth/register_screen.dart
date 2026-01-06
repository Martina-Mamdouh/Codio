// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../main_layout.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'email_verification_screen.dart';
import '../widgets/social_login_button.dart';
import 'login_screen.dart';
import '../widgets/auth_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  String? _selectedProfession;

  final List<String> _professions = ['طالب', 'موظف', 'متقاعد', 'صاحب عمل'];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewModel>();
    if (authViewModel.isLoading)
      return; // SECURITY FIX: Prevent double-submission

    final success = await authViewModel.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _emailController.text.trim().split('@')[0],
      profession: _selectedProfession!,
    );

    if (!mounted) return;

    if (success) {
      if (authViewModel.currentUser == null) {
        // Needs Verification
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تحقق من بريدك الإلكتروني لإدخال رمز التحقق'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OTPVerificationScreen(email: _emailController.text.trim()),
          ),
        );
      } else {
        // Logged In
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.errorMessage ?? 'فشل إنشاء الحساب'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleGoogleLogin() async {
    final authViewModel = context.read<AuthViewModel>();
    if (authViewModel.isLoading)
      return; // SECURITY FIX: Prevent double-submission

    final success = await authViewModel.signInWithGoogle();

    if (!mounted) return;
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainLayout()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.errorMessage ?? 'فشل تسجيل الدخول'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5FF17), // Custom Yellow

      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                right: 16.w,
                left: 16.w,
                top: 85.h,
                bottom: 16.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إنشاء حساب',
                    style: TextStyle(
                      fontSize: 32.sp, // Reduced from 40.sp
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'يرجى إدخال البيانات المطلوبة للتسجيل',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF000000), // Pure Black
                borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
              ),
              padding: EdgeInsets.fromLTRB(16.w, 32.h, 16.w, 24.w),
              child: Form(
                key: _formKey,
                child: Column(
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
                      onTogglePassword: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
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

                    // Profession Dropdown
                    Container(
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
                            child: Icon(
                              Icons.work_outline,
                              color: Colors.white.withAlpha(180),
                              size: 26.sp,
                            ),
                          ),

                          SizedBox(width: 14.w),

                          /// DROPDOWN
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedProfession,
                              dropdownColor: const Color(0xFF2C2C2E),
                              borderRadius: BorderRadius.circular(12.r),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                label: Text(
                                  'المهنة',
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
                                errorStyle: const TextStyle(
                                  height: 0,
                                  color: Colors.transparent,
                                ),
                              ),
                              items: _professions.map((String profession) {
                                return DropdownMenuItem<String>(
                                  value: profession,
                                  child: Text(profession),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedProfession = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'يرجى اختيار المهنة';
                                }
                                return null;
                              },
                              icon: Padding(
                                padding: EdgeInsets.only(left: 8.w),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.white.withAlpha(180),
                                  size: 24.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Register Button
                    Consumer<AuthViewModel>(
                      builder: (context, vm, _) {
                        return ElevatedButton(
                          onPressed: vm.isLoading ? null : _handleRegister,
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
                                      Flexible(
                                        child: Text(
                                          'إنشاء حساب',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize:
                                                16.sp, // Reduced from 18.sp
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(
                                          12.w,
                                        ), // Reduced from 16.w
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward,
                                          color: Colors.white,
                                          size: 20.sp, // Reduced from 24.sp
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        );
                      },
                    ),

                    SizedBox(height: 32.h),

                    // Disclaimer Text (Privacy Policy)
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'بالنقر على "إنشاء حساب"، فإنك توافق على ',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12.sp,
                        ),
                        children: [
                          TextSpan(
                            text: 'سياسة الخصوصية',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white54)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                                  content: Text('تسجيل الدخول عبر أبل قريباً'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Login Link
                    SizedBox(height: 20.h),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: "لديك حساب بالفعل؟ ",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14.sp,
                              fontFamily: 'Cairo',
                            ),
                            children: [
                              TextSpan(
                                text: 'تسجيل الدخول',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
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
