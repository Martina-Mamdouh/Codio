import 'package:flutter/material.dart';
import 'package:kodio_app/admin/viewmodels/auth_viewmodel.dart';
import 'package:kodio_app/admin/views/admin_dashboard_view.dart';
import 'package:kodio_app/admin/views/login_view.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    if (authVM.currentUser == null) {
      return LoginView();
    }

    return FutureBuilder<bool>(
      future: authVM.checkIsAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return AdminDashboardView();
        } else {
          // Optional: Show "Unauthorized" message or redirect to login
          // Using LoginView so they can try a different account
          return LoginView();
        }
      },
    );
  }
}
