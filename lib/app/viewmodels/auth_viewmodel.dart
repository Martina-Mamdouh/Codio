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

  // Guest mode flag
  bool isGuestMode = false;

  // Prevents the Supabase auth state listener from interfering
  // while a sign-in / sign-up operation is already in progress.
  bool _isSigningIn = false;

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
      // Always use silent=true so that delayed auth events (e.g. from Google Sign In
      // OAuth which fires multiple events) never flip isLoading back to true after
      // a successful login, which would trap the UI on the loading screen.
      if (_isSigningIn) return;
      _loadCurrentUser(silent: true);
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
    _isSigningIn = true;
    isLoading = true;
    errorMessage = null;
    if (hasListeners) notifyListeners();

    try {
      final result = await _authService.signIn(
        email: email,
        password: password,
      );

      if (result.success) {
        currentUser = result.user;
        isGuestMode = false;
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
      _isSigningIn = false;
      isLoading = false;
      if (hasListeners) notifyListeners();
    }
  }

  // Google Sign In
  Future<bool> signInWithGoogle() async {
    _isSigningIn = true;
    isLoading = true;
    errorMessage = null;
    if (hasListeners) notifyListeners();

    try {
      final result = await _authService.signInWithGoogle();

      if (result.success) {
        currentUser = result.user;
        isGuestMode = false;
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
      _isSigningIn = false;
      isLoading = false;
      if (hasListeners) notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String profession,
  }) async {
    _isSigningIn = true;
    isLoading = true;
    errorMessage = null;
    if (hasListeners) notifyListeners();

    try {
      final result = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        profession: profession,
      );

      if (result.success) {
        currentUser = result.user;
        isGuestMode = false;
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
      _isSigningIn = false;
      isLoading = false;
      if (hasListeners) notifyListeners();
    }
  }

  Future<void> signOut() async {
    OneSignalService().removeExternalUserId();
    await _authService.signOut();
    currentUser = null;
    isGuestMode = false;
    if (hasListeners) notifyListeners();
  }

  // Guest Mode
  void enterGuestMode() {
    isGuestMode = true;
    notifyListeners();
  }

  void exitGuestMode() {
    isGuestMode = false;
    notifyListeners();
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
  Future<bool> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? profession,
  }) async {
    try {
      final success = await _authService.updateProfile(
        fullName: fullName,
        avatarUrl: avatarUrl,
        profession: profession,
      );

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

  // Change Password
  Future<bool> changePassword(String newPassword) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.updatePassword(newPassword);
      if (!result.success) {
        errorMessage = result.message;
      }
      return result.success;
    } catch (e) {
      debugPrint('❌ Error changing password: $e');
      errorMessage = 'حدث خطأ غير متوقع';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
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
