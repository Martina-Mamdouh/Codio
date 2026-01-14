import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService {
  final _supabase = Supabase.instance.client;
  // Use Web client ID as serverClientId for Supabase OAuth
  // This is the OAuth client ID that Supabase expects
  final GoogleSignIn _googleSignIn = GoogleSignIn(serverClientId: '75334850507-l89vbmniujl1f4ptv30rpieqab9f8pt1.apps.googleusercontent.com');

  User? get currentUser => _supabase.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  String? get userId => currentUser?.id;
  String? get userEmail => currentUser?.email;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Google Sign In
  Future<AuthResult> signInWithGoogle() async {
    try {
      // 1. Trigger Google Sign In
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult(success: false, message: 'تم إلغاء تسجيل الدخول');
      }

      // 2. Get Headers (Auth)
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        return AuthResult(success: false, message: 'فشل الحصول على رمز الدخول من Google');
      }

      // 3. Authenticate with Supabase (with Retry Logic)
      int retryCount = 0;
      const maxRetries = 2; // Total attempts = 1 + 2 = 3

      while (true) {
        try {
          final response = await _supabase.auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
            accessToken: accessToken,
          );

          if (response.user == null) {
            return AuthResult(success: false, message: 'فشل تسجيل الدخول باستخدام Google');
          }

          // 4. Create/Get User Profile
          final profile = await _getOrCreateUserProfile(userId: response.user!.id, email: response.user!.email!);

          // Update full name and avatar from Google if new
          if (profile != null && (profile.fullName.isEmpty)) {
            await updateProfile(fullName: googleUser.displayName, avatarUrl: googleUser.photoUrl);
            // Reload profile
            final updatedProfile = await _getUserProfile(response.user!.id);
            return AuthResult(success: true, user: updatedProfile);
          }

          return AuthResult(success: true, user: profile);
        } catch (e) {
          debugPrint('❌ Google Sign In error (attempt ${retryCount + 1}): $e');
          final errorStr = e.toString().toLowerCase();
          
          bool isRetryable = errorStr.contains('connection reset') ||
              errorStr.contains('authretryablefetchexception') ||
              errorStr.contains('socketexception') ||
              errorStr.contains('timeout');

          if (isRetryable && retryCount < maxRetries) {
            retryCount++;
            await Future.delayed(Duration(milliseconds: 1000 * retryCount)); // Exponential backoff
            continue;
          }
          
          if (errorStr.contains('network') || errorStr.contains('connection')) {
             return AuthResult(success: false, message: 'خطأ في الاتصال. حاول مرة أخرى.');
          }

          return AuthResult(success: false, message: 'حدث خطأ أثناء تسجيل الدخول باستخدام Google');
        }
      }
    } catch (e) {
      debugPrint('❌ Google Sign In initialization error: $e');
      return AuthResult(success: false, message: 'حدث خطأ غير متوقع');
    }
  }


  // Sign In with Retry Logic
  Future<AuthResult> signIn({required String email, required String password}) async {
    int retryCount = 0;
    const maxRetries = 2;
    
    while (retryCount <= maxRetries) {
      try {
        final response = await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (response.user == null) {
          return AuthResult(success: false, message: 'فشل تسجيل الدخول');
        }

        final profile = await _getOrCreateUserProfile(
          userId: response.user!.id,
          email: email,
        );

        return AuthResult(success: true, user: profile);
      } catch (e) {
        debugPrint('❌ Login error (attempt ${retryCount + 1}/$maxRetries): $e');
        final errorStr = e.toString().toLowerCase();
        
        // Check if it's a retryable network error
        bool isRetryable = errorStr.contains('connection reset') ||
            errorStr.contains('authretryablefetchexception') ||
            errorStr.contains('socketexception') ||
            errorStr.contains('timeout');
        
        if (isRetryable && retryCount < maxRetries) {
          retryCount++;
          debugPrint('🔄 Retrying login... (attempt ${retryCount + 1})');
          await Future.delayed(Duration(milliseconds: 500 * retryCount)); // Exponential backoff
          continue;
        }
        
        // Non-retryable error or max retries reached
        if (errorStr.contains('captcha')) {
          return AuthResult(
            success: false,
            message: 'خطأ في التحقق (CAPTCHA). يرجى تعطيل حماية CAPTCHA من إعدادات Supabase.',
          );
        }
        if (errorStr.contains('timeout') || errorStr.contains('socket') || errorStr.contains('connection')) {
          return AuthResult(
            success: false,
            message: 'فشل الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت وحاول مرة أخرى.',
          );
        }
        return AuthResult(
          success: false,
          message: 'تحقق من البريد الإلكتروني وكلمة المرور',
        );
      }
    }
    
    // Should never reach here, but just in case
    return AuthResult(
      success: false,
      message: 'فشل الاتصال بالخادم بعد عدة محاولات',
    );
  }

  // Sign Up with OTP & Retry Logic
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
    required String profession,
  }) async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount <= maxRetries) {
      try {
        final response = await _supabase.auth.signUp(
          email: email,
          password: password,
          emailRedirectTo: 'io.supabase.kodioapp://login-callback/',
          data: {'full_name': fullName, 'profession': profession},
        );

        if (response.user == null) {
          return AuthResult(success: false, message: 'فشل إنشاء الحساب');
        }

        // Check if email confirmation is required
        if (response.user!.emailConfirmedAt == null) {
          // Send OTP
          return AuthResult(
            success: true,
            user: null,
            message: 'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
            needsVerification: true,
          );
        }

        // Email already confirmed - create profile
        await _supabase.from('users').upsert({
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'profession': profession,
          'avatar_url': null,
          'created_at': DateTime.now().toIso8601String(),
        });

        final profile = await _getUserProfile(response.user!.id);
        return AuthResult(
          success: true,
          user: profile,
          message: 'تم إنشاء الحساب بنجاح',
        );
      } catch (e) {
        debugPrint('❌ Register error (attempt ${retryCount + 1}/$maxRetries): $e');
        final errorStr = e.toString().toLowerCase();

        // Check if it's a retryable network error
        bool isRetryable = errorStr.contains('connection reset') ||
            errorStr.contains('authretryablefetchexception') ||
            errorStr.contains('socketexception') ||
            errorStr.contains('timeout') ||
            errorStr.contains('upstream request timeout') ||
            errorStr.contains('statuscode: 50');

        if (isRetryable && retryCount < maxRetries) {
          retryCount++;
          debugPrint('🔄 Retrying registration... (attempt ${retryCount + 1})');
          await Future.delayed(Duration(milliseconds: 2000 * retryCount)); // Exponential backoff
          continue;
        }

        if (errorStr.contains('captcha')) {
          return AuthResult(
            success: false,
            message: 'خطأ في التحقق (CAPTCHA). يرجى تعطيل حماية CAPTCHA من إعدادات Supabase.',
          );
        }
        if (errorStr.contains('timeout') || errorStr.contains('socket') || errorStr.contains('upstream')) {
          return AuthResult(
            success: false,
            message: 'فشل الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت وحاول مرة أخرى.',
          );
        }
        return AuthResult(success: false, message: 'حدث خطأ في إنشاء الحساب');
      }
    }
    
    return AuthResult(success: false, message: 'فشل الاتصال بالخادم بعد عدة محاولات');
  }

  // Verify OTP
  Future<AuthResult> verifyOTP({required String email, required String token}) async {
    try {
      AuthResponse response;
      try {
        // First try with signup type
        response = await _supabase.auth.verifyOTP(email: email, token: token, type: OtpType.signup);
      } catch (e) {
        // If signup type fails, try with email type (common for resends or magic links)
        debugPrint('⚠️ Signup OTP failed, trying Email OTP...');
        response = await _supabase.auth.verifyOTP(email: email, token: token, type: OtpType.email);
      }

      if (response.user == null) {
        return AuthResult(success: false, message: 'رمز التحقق غير صحيح');
      }

      return await _handleVerificationSuccess(response.user!);
    } catch (e) {
      debugPrint('❌ Verify OTP error: $e');
      return AuthResult(success: false, message: 'رمز التحقق غير صحيح أو منتهي الصلاحية');
    }
  }

  // Private: Handle successful verification
  Future<AuthResult> _handleVerificationSuccess(User user) async {
    try {
      final userEmail = user.email!;
      final fullName = user.userMetadata?['full_name'] ?? userEmail.split('@')[0];
      final profession = user.userMetadata?['profession'] ?? '';

      await _supabase.from('users').upsert({
        'id': user.id,
        'email': userEmail,
        'full_name': fullName,
        'profession': profession,
        'avatar_url': null,
        'created_at': DateTime.now().toIso8601String(),
      }, onConflict: 'id');

      final profile = await _getUserProfile(user.id);
      return AuthResult(success: true, user: profile, message: 'تم التحقق بنجاح');
    } catch (e) {
      debugPrint('❌ Handle verification success error: $e');

      // FALLBACK: Always try without profession if first attempt fails
      try {
        await _supabase.from('users').upsert({
          'id': user.id,
          'email': user.email!,
          'full_name': user.userMetadata?['full_name'] ?? user.email!.split('@')[0],
          // 'profession': '', // Omitted
          'avatar_url': null,
          'created_at': DateTime.now().toIso8601String(),
        });
        final profile = await _getUserProfile(user.id);
        return AuthResult(success: true, user: profile, message: 'تم التحقق بنجاح');
      } catch (retryError) {
        debugPrint('❌ Retry verification success error: $retryError');
      }

      return AuthResult(
        success: true, // Auth worked, but profile creation might have issues
        user: UserModel(
          id: user.id,
          email: user.email!,
          fullName: user.userMetadata?['full_name'] ?? '',
          profession: '',
          avatarUrl: null,
          createdAt: DateTime.now(),
        ),
        message: 'تم التحقق بنجاح',
      );
    }
  }

  // Resend OTP
  Future<bool> resendOTP(String email) async {
    try {
      await _supabase.auth.resend(type: OtpType.signup, email: email, emailRedirectTo: 'io.supabase.kodioapp://login-callback/');
      return true;
    } catch (e) {
      debugPrint('❌ Resend OTP error: $e');
      // If signup resend fails, try generic
      try {
        debugPrint('⚠️ Resend Signup failed, trying generic resend...');
        // Note: Some SDKs allow omitting type or using different one.
        // We'll just stick to signup as primary, but if it fails, return false.
        // Or we could try magiclink if we supported it.
      } catch (_) {}
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('❌ Logout error: $e');
    }
  }

  // Get Current User Profile
  Future<UserModel?> getCurrentUserProfile() async {
    if (userId == null) return null;

    // Ensure profile exists if we have a valid session
    if (userEmail != null) {
      // Pass existing meta data if available to avoid empty profession on first load
      final metaProfession = currentUser?.userMetadata?['profession'] as String?;
      return _getOrCreateUserProfile(userId: userId!, email: userEmail!, initialProfession: metaProfession);
    }

    return _getUserProfile(userId!);
  }

  // Update Profile
  Future<bool> updateProfile({String? fullName, String? avatarUrl, String? profession}) async {
    if (userId == null) return false;

    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (profession != null) updates['profession'] = profession;

    if (updates.isEmpty) return true;

    try {
      await _supabase.from('users').update(updates).eq('id', userId!);
      return true;
    } catch (e) {
      debugPrint('❌ Update profile error: $e');
      // Always try updating without 'profession' if first attempt fails
      if (updates.containsKey('profession')) {
        updates.remove('profession');
        if (updates.isNotEmpty) {
          try {
            await _supabase.from('users').update(updates).eq('id', userId!);
            return true;
          } catch (retryError) {
            debugPrint('❌ Retry update profile error: $retryError');
          }
        }
      }
      return false;
    }
  }

  // SECURITY FIX: Deprecated - conflicts with OTP-based password reset
  // Use ForgotPasswordScreen (OTP flow) instead of magic links
  @Deprecated('Use OTP-based password reset via ForgotPasswordScreen. This method uses deprecated magic link approach.')
  Future<bool> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email, redirectTo: 'io.supabase.kodioapp://reset-password/');
      return true;
    } catch (e) {
      debugPrint('❌ Reset password error: $e');
      return false;
    }
  }

  // Private: Get user profile
  Future<UserModel?> _getUserProfile(String userId) async {
    try {
      final data = await _supabase.from('users').select().eq('id', userId).maybeSingle();

      if (data == null) return null;
      return UserModel.fromJson(data);
    } catch (e) {
      debugPrint('❌ Get profile error: $e');
      return null;
    }
  }

  Future<UserModel?> _getOrCreateUserProfile({required String userId, required String email, String? initialProfession}) async {
    var profile = await _getUserProfile(userId);

    // Create if doesn't exist
    if (profile == null) {
      try {
        await _supabase.from('users').upsert({
          'id': userId,
          'email': email,
          'full_name': email.split('@')[0],
          'profession': initialProfession ?? '',
          'avatar_url': null,
          'created_at': DateTime.now().toIso8601String(),
        });
        profile = await _getUserProfile(userId);
      } catch (e) {
        debugPrint('❌ Create profile error: $e');
        // Fallback: Always try creating without 'profession' if first attempt fails
        try {
          await _supabase.from('users').upsert({
            'id': userId,
            'email': email,
            'full_name': email.split('@')[0],
            // 'profession': initialProfession ?? '', // Omitted in retry
            'avatar_url': null,
            'created_at': DateTime.now().toIso8601String(),
          });
          profile = await _getUserProfile(userId);
        } catch (retryError) {
          debugPrint('❌ Retry create profile error: $retryError');
        }
      }
    } else if (profile.profession.isEmpty && initialProfession != null && initialProfession.isNotEmpty) {
      // Update profession if profile exists but profession is empty and we have it in metadata
      await updateProfile(profession: initialProfession);
      profile = profile.copyWith(profession: initialProfession);
    }

    return profile;
  }
}
// End of auth service

// Auth Result Model
class AuthResult {
  final bool success;
  final String? message;
  final UserModel? user;
  final bool needsVerification;

  AuthResult({required this.success, this.message, this.user, this.needsVerification = false});
}
