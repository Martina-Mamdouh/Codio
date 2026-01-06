import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AppLifecycleState? _appLifecycleState;
  AppLifecycleState? get appLifecycleState => _appLifecycleState;

  Stream<AuthState> get authStateStream => _client.auth.onAuthStateChange;
  User? get currentUser => _client.auth.currentUser;

  AuthViewModel() {
    authStateStream.listen((data) {
      notifyListeners();
    });
  }

  void setAppLifecycleState(AppLifecycleState state) {
    _appLifecycleState = state;
  }

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('An unexpected error occurred.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('An unexpected error occurred.');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> checkIsAdmin() async {
    final user = _client.auth.currentUser;

    if (user == null) return false;

    try {
      // PREFERRED: Use RPC 'is_admin' to avoid RLS recursion on 'admins' table
      // The direct select causes infinite recursion (Code 42P17) because of circular policies.
      final isAdmin = await _client.rpc('is_admin');

      return isAdmin as bool;
    } catch (e) {
      // Fallback: Try reading table directly (only if RPC fails/doesn't exist)
      try {
        final res = await _client
            .from('admins')
            .select('user_id')
            .eq('user_id', user.id)
            .maybeSingle();

        return res != null;
      } catch (tableError) {
        return false;
      }
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}
