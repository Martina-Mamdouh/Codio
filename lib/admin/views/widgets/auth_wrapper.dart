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
          // Access Denied Screen
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.gpp_bad_outlined, size: 64, color: Colors.orange),
                    const SizedBox(height: 16),
                    const Text(
                      'غير مصرح بالدخول',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'هذا الحساب لا يملك صلاحيات المسؤول.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('تسجيل الخروج'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        await context.read<AuthViewModel>().signOut();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
