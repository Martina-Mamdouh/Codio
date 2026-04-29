import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:provider/provider.dart';
import 'package:kodio_app/app/views/categories_view.dart';
import 'package:kodio_app/app/views/companies_view.dart';
import 'package:kodio_app/app/views/home_view.dart';
import 'package:kodio_app/app/views/profile/profile_view.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/companies_viewmodel.dart';
import 'viewmodels/categories_viewmodel.dart';
import 'viewmodels/map_view_model.dart';
import 'viewmodels/user_profile_viewmodel.dart';
import '../../core/theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'views/followed_companies_view.dart';
import 'views/auth/login_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => MainLayoutState();
}

class MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _scheduleBackgroundDataLoad();
  }

  void _scheduleBackgroundDataLoad() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final categoryVm = context.read<CategoriesViewModel>();
        if (categoryVm.categories.isEmpty && !categoryVm.isLoading) {
          categoryVm.loadCategories();
        }
      }
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        final companiesVm = context.read<CompaniesViewModel>();
        if (companiesVm.companies.isEmpty && !companiesVm.isLoading) {
          companiesVm.loadCompanies();
        }
      }
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        final mapVm = context.read<MapViewModel>();
        if (!mapVm.hasLoaded && !mapVm.isLoading) {
          mapVm.init();
        }
      }
    });
  }

  final List<Widget> _mobileScreens = [
    const HomeView(),
    const CategoriesView(),
    const CompaniesView(),
    const FollowedCompaniesView(),
    const ProfileView(),
  ];

  final List<Widget> _tabletScreens = [
    const HomeView(),
    const CategoriesView(),
    const CompaniesView(),
    const ProfileView(),
  ];

  // ✅ Keep this method for external calls (like from FollowedCompaniesView)
  void switchToTab(int index) {
    _onTabChanged(index);
  }

  void _onTabChanged(int index) {
    final deviceType = getDeviceType(MediaQuery.of(context).size);
    final isMobile = deviceType == DeviceScreenType.mobile;

    if (index == 1) {
      final vm = context.read<CategoriesViewModel>();
      if (vm.categories.isEmpty && !vm.isLoading) {
        vm.loadCategories();
      }
    } else if (index == 2) {
      final vm = context.read<CompaniesViewModel>();
      if (vm.companies.isEmpty && !vm.isLoading) {
        vm.loadCompanies();
      }
    } else if (isMobile && index == 3) {
      final authVm = context.read<AuthViewModel>();
      if (authVm.isGuestMode) {
        _showGuestTabSnackBar();
        return;
      }
      final vm = context.read<UserProfileViewModel>();
      if (vm.followedCompanies.isEmpty && !vm.isLoadingProfile) {
        vm.loadProfileData();
      }
    }

    setState(() {
      _currentIndex = index;
    });
  }

  void _showGuestTabSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.lock_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'سجّل دخولك لعرض الشركات المتابَعة',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.kElectricLime,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              child: const Text('تسجيل الدخول', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        backgroundColor: AppTheme.kDarkBackground,
        elevation: 6,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppTheme.kElectricLime.withAlpha(77), width: 1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => _buildMobileLayout(),
      tablet: (context) => _buildTabletLayout(),
      desktop: (context) => _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: AppTheme.kDarkBackground,
      extendBody: true, 
      body: IndexedStack(index: _currentIndex, children: _mobileScreens),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          height: 64,
          decoration: BoxDecoration(
            color: AppTheme.kLightBackground,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BottomNavigationBar(
              backgroundColor: AppTheme.kLightBackground,
              elevation: 0,
              selectedItemColor: AppTheme.kElectricLime,
              unselectedItemColor: Colors.grey.shade500,
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              onTap: _onTabChanged,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedFontSize: 11,
              unselectedFontSize: 11,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.house, size: 18),
                  label: 'الرئيسية',
                ),
                BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.tableCellsLarge, size: 18),
                  label: 'التصنيفات',
                ),
                BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.store, size: 18),
                  label: 'الشركات',
                ),
                BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.solidStar, size: 18),
                  label: 'متابَعة',
                ),
                BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.user, size: 18),
                  label: 'حسابي',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    // Fixed nav widths to ensure content gets predictable space
    final double navWidth = isLandscape ? 72.0 : 110.0;

    return Scaffold(
      backgroundColor: AppTheme.kDarkBackground,
      body: SizedBox.expand(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Navigation rail with controlled width to avoid taking excessive space
            SizedBox(
              width: navWidth,
              child: NavigationRail(
                backgroundColor: AppTheme.kLightBackground,
                selectedIndex: _currentIndex,
                onDestinationSelected: _onTabChanged,
                labelType: isLandscape ? NavigationRailLabelType.selected : NavigationRailLabelType.all,
                extended: false,
                groupAlignment: 0.0,
                destinations: const [
                  NavigationRailDestination(icon: Icon(Icons.home), label: Text('الرئيسية')),
                  NavigationRailDestination(icon: Icon(Icons.grid_view), label: Text('التصنيفات')),
                  NavigationRailDestination(icon: Icon(Icons.store), label: Text('الشركات')),
                  NavigationRailDestination(icon: Icon(Icons.person), label: Text('حسابي')),
                ],
              ),
            ),

            // Divider to visually separate navigation and content
            Container(width: 1, color: AppTheme.kDivider),

            // Main content area - use full remaining space
            Expanded(
              child: Container(
                color: AppTheme.kDarkBackground,
                // Let inner pages manage their own scrolling; avoid wrapping Scaffolds
                child: IndexedStack(
                  index: _currentIndex,
                  children: _tabletScreens,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() => _buildTabletLayout();
}
