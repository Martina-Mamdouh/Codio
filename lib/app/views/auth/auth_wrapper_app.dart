import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main_layout.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'login_screen.dart';

class AuthWrapperApp extends StatelessWidget {
  const AuthWrapperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        // Loading initial state
        if (authViewModel.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFF0A0A0A),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFCDFD02)),
            ),
          );
        }

        // Logged in
        if (authViewModel.isAuthenticated) {
          return const MainLayout();
        }

        // Not logged in
        return const LoginScreen();
      },
    );
  }
}
