import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'app/viewmodels/companies_viewmodel.dart';
import 'app/viewmodels/deal_details_view_model.dart';
import 'app/viewmodels/home_view_model.dart';
import 'app/viewmodels/notification_viewmodel.dart';
import 'app/viewmodels/auth_viewmodel.dart';
import 'app/viewmodels/user_profile_viewmodel.dart';
import 'app/viewmodels/categories_viewmodel.dart';
import 'app/viewmodels/map_view_model.dart';
import 'core/services/analytics_service.dart';
import 'app/views/splach_screen.dart';
import 'core/services/onesignal_service.dart';
import 'core/services/version_service.dart';
import 'core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Global navigator key for deep-linking from OneSignal notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://anlixjwtmbduosemcwpv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFubGl4and0bWJkdW9zZW1jd3B2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIxNjA3MzgsImV4cCI6MjA3NzczNjczOH0.iyNA0Kg0cFMKqmi-VaPcGjPzu3UJ_srXzIog0kiQeAc',
  );

  await OneSignalService().initialize(
    '16f05a5a-3fde-49bd-855d-664ef0e381b5',
    navigatorKey: navigatorKey, // Pass navigator key for deep-linking
  );

  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final event = data.event;
    if (event == AuthChangeEvent.signedIn) {
      debugPrint('✅ User signed in after email verification');
    }
  });

  timeago.setLocaleMessages('ar', timeago.ArMessages());
  await VersionService.init();

  // Initialize Firebase for Google Sign In
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('🔥 Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');
  }

  runApp(const CodioApp());
}

class CodioApp extends StatelessWidget {
  const CodioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            Provider(create: (_) => AnalyticsService()),
            ChangeNotifierProvider(create: (_) => AuthViewModel()),
            ChangeNotifierProvider(create: (_) => HomeViewModel()),
            ChangeNotifierProvider(create: (_) => DealDetailsViewModel()),
            ChangeNotifierProvider(create: (_) => UserProfileViewModel()),
            ChangeNotifierProvider(create: (_) => CompaniesViewModel()),
            ChangeNotifierProvider(create: (_) => CategoriesViewModel()),
            ChangeNotifierProvider(create: (_) => NotificationsViewModel()),
            ChangeNotifierProvider(create: (_) => MapViewModel()),
          ],
          child: MaterialApp(
            title: 'كوديو',
            debugShowCheckedModeBanner: false,

            // Localization (عربي + إنجليزي)
            supportedLocales: const [Locale('ar'), Locale('en', 'US')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // نجبر التطبيق يكون عربي
            locale: const Locale('ar'),
            localeResolutionCallback: (locale, supportedLocales) {
              return const Locale('ar');
            },

            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },

            theme: AppTheme.darkTheme,
            debugShowMaterialGrid: false,

            navigatorKey: navigatorKey, // Global key for deep-linking
            home: const AuthWrapper(),
          ),
        );
      },
      child: const SplashScreen(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _wasAuthenticated = false;

  @override
  void initState() {
    super.initState();
    final authVm = context.read<AuthViewModel>();
    _wasAuthenticated = authVm.isAuthenticated;
    authVm.addListener(_onAuthChange);
    
    // Initial load check
    if (_wasAuthenticated) {
      _loadUserData();
    }
  }

  void _onAuthChange() {
    final authVm = context.read<AuthViewModel>();
    final isAuth = authVm.isAuthenticated;

    // Trigger only on transition from false -> true
    if (isAuth && !_wasAuthenticated) {
       _loadUserData();
    } else if (!isAuth && _wasAuthenticated) {
       // User logged out
       context.read<UserProfileViewModel>().clearFavorites();
    }

    _wasAuthenticated = isAuth;
  }

  void _loadUserData() {
    // Reload profile data (Follows, Favorites) whenever we have a user
    // We delay slightly to allow the UI to transition first (Home page to render)
    // This prevents the "Post-Login Slowness" caused by 5+ concurrent network requests
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
         debugPrint('🚀 Triggering background load: Profile & Notifications');
         context.read<UserProfileViewModel>().loadProfileData();
         context.read<NotificationsViewModel>().loadNotifications();
      }
    });
  }

  @override
  void dispose() {
    context.read<AuthViewModel>().removeListener(_onAuthChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Proceed to SplashScreen, which handles navigation logic based on auth
    return const SplashScreen();
  }
}
