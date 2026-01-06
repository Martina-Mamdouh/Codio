import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'admin/viewmodels/categories_management_viewmodel.dart';
import 'admin/views/widgets/auth_wrapper.dart';
import 'firebase_options.dart';
import 'admin/viewmodels/auth_viewmodel.dart';
import 'admin/viewmodels/banners_management_viewmodel.dart';
import 'admin/viewmodels/companies_management_viewmodel.dart';
import 'admin/viewmodels/deals_management_viewmodel.dart';
import 'admin/viewmodels/dashboard_viewmodel.dart';
import 'core/services/analytics_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://anlixjwtmbduosemcwpv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFubGl4and0bWJkdW9zZW1jd3B2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIxNjA3MzgsImV4cCI6MjA3NzczNjczOH0.iyNA0Kg0cFMKqmi-VaPcGjPzu3UJ_srXzIog0kiQeAc',
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => DealsManagementViewModel()),
        ChangeNotifierProvider(create: (_) => CompaniesManagementViewModel()),
        ChangeNotifierProvider(create: (_) => BannersManagementViewModel()),
        ChangeNotifierProvider(create: (_) => CategoriesManagementViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Codio Admin Panel',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
    );
  }
}
