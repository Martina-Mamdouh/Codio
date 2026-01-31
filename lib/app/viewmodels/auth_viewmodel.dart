import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/onesignal_service.dart';
import '../../core/models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? currentUser;
  // Start with loading true to prevent premature redirection
  bool isLoading = true;
  String? errorMessage;

  bool get isAuthenticated => _authService.isAuthenticated;

  AuthViewModel() {
    _init();
  }

  Future<void> _init() async {
    debugPrint('🔄 AuthViewModel Initialization...');
    // Ensure we start with loading state
    isLoading = true;
    notifyListeners();

    try {
      // 1. Setup listener first to catch any immediate updates
      _listenToAuthChanges();

      // 2. Load the initial state immediately
      // We use silent: true because we manually set isLoading=true above.
      // This ensures isLoading=false is set only when this completes.
      await _loadCurrentUser(silent: true);
      
      debugPrint('✅ Init completed. User: ${currentUser?.email}');
    } catch (e) {
      debugPrint('❌ Error during Auth initialization: $e');
      isLoading = false;
      notifyListeners();
    }
  }

  void _listenToAuthChanges() {
    _authService.authStateChanges.listen((event) {
      // Reload user on auth change, but don't show full screen loader if not needed
      _loadCurrentUser(silent: false);
    });
  }

  Future<void> _loadCurrentUser({bool silent = false}) async {
    if (!silent) {
      isLoading = true;
      notifyListeners();
    }

    try {
      if (_authService.isAuthenticated) {
        currentUser = await _authService.getCurrentUserProfile();
        debugPrint('👤 Loaded user profile: ${currentUser?.email}');
        
        // Register OneSignal User ID
        if (currentUser != null && currentUser!.id.isNotEmpty) {
           OneSignalService().setExternalUserId(currentUser!.id);
        }
      } else {
        currentUser = null;
      }
    } catch (e) {
      debugPrint('❌ Error loading current user: $e');
      currentUser = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    isLoading = true;
    errorMessage = null;
    if (hasListeners) notifyListeners();

    try {
      final result = await _authService.signIn(email: email, password: password);

      if (result.success) {
        currentUser = result.user;
        errorMessage = null;
      } else {
        errorMessage = result.message;
      }

      return result.success;
    } catch (e) {
      errorMessage = 'حدث خطأ أثناء تسجيل الدخول';
      debugPrint('Error in signIn: $e');
      return false;
    } finally {
      isLoading = false;
      if (hasListeners) notifyListeners();
    }
  }

  // Google Sign In
  Future<bool> signInWithGoogle() async {
    isLoading = true;
    errorMessage = null;
    if (hasListeners) notifyListeners();

    try {
      final result = await _authService.signInWithGoogle();

      if (result.success) {
        currentUser = result.user;
        errorMessage = null;
      } else {
        errorMessage = result.message;
      }

      return result.success;
    } catch (e) {
      errorMessage = 'حدث خطأ غير متوقع';
      debugPrint('Error in signInWithGoogle: $e');
      return false;
    } finally {
      isLoading = false;
      if (hasListeners) notifyListeners();
    }
  }

  Future<bool> signUp({required String email, required String password, required String fullName, required String profession}) async {
    isLoading = true;
    errorMessage = null;
    if (hasListeners) notifyListeners();

    try {
      final result = await _authService.signUp(email: email, password: password, fullName: fullName, profession: profession);

      if (result.success) {
        currentUser = result.user;
        errorMessage = null;
      } else {
        errorMessage = result.message;
      }

      return result.success;
    } catch (e) {
      errorMessage = 'حدث خطأ أثناء إنشاء الحساب';
      debugPrint('Error in signUp: $e');
      return false;
    } finally {
      isLoading = false;
      if (hasListeners) notifyListeners();
    }
  }

  Future<void> signOut() async {
    OneSignalService().removeExternalUserId();
    await _authService.signOut();
    currentUser = null;
    if (hasListeners) notifyListeners();
  }

  // Verify OTP
  Future<bool> verifyOTP({required String email, required String token}) async {
    isLoading = true;
    errorMessage = null;
    if (hasListeners) notifyListeners();

    try {
      final result = await _authService.verifyOTP(email: email, token: token);

      if (result.success) {
        currentUser = result.user;
        errorMessage = null;
      } else {
        errorMessage = result.message;
      }

      return result.success;
    } catch (e) {
      errorMessage = 'حدث خطأ في التحقق';
      debugPrint('Error in verifyOTP: $e');
      return false;
    } finally {
      isLoading = false;
      if (hasListeners) notifyListeners();
    }
  }

  // Resend OTP
  Future<bool> resendOTP(String email) async {
    return await _authService.resendOTP(email);
  }

  // Update Profile
  Future<bool> updateProfile({String? fullName, String? avatarUrl, String? profession}) async {
    try {
      final success = await _authService.updateProfile(fullName: fullName, avatarUrl: avatarUrl, profession: profession);

      if (success) {
        // Reload user profile to reflect changes
        await _loadCurrentUser(silent: true);
      }

      return success;
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      return false;
    }
  }

  // Delete Account
  Future<bool> deleteAccount() async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.deleteAccount();
      
      if (result.success) {
        currentUser = null;
        errorMessage = null;
      } else {
        errorMessage = result.message;
      }
      return result.success;
    } catch (e) {
      debugPrint('❌ Error deleting account: $e');
      errorMessage = 'حدث خطأ غير متوقع';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
