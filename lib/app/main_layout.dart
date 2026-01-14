import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:provider/provider.dart';
import 'package:kodio_app/app/views/categories_view.dart';
import 'package:kodio_app/app/views/companies_view.dart';
import 'package:kodio_app/app/views/home_view.dart';
import 'package:kodio_app/app/views/profile/profile_view.dart';
import 'viewmodels/companies_viewmodel.dart';
import 'viewmodels/categories_viewmodel.dart';
import 'viewmodels/map_view_model.dart';
import 'viewmodels/user_profile_viewmodel.dart';
import '../../core/theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'views/followed_companies_view.dart';

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
    // Pre-fetch data for other tabs after Home has likely started rendering
    _scheduleBackgroundDataLoad();
  }

  void _scheduleBackgroundDataLoad() {
    // Wait 3 seconds to let Home & Splash finish animations/loading
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final categoryVm = context.read<CategoriesViewModel>();
        // Only load if not already loaded/loading
        if (categoryVm.categories.isEmpty && !categoryVm.isLoading) {
           debugPrint('🚀 Triggering background load: Categories');
           categoryVm.loadCategories();
        }
      }
    });

    // Wait 4 seconds for Companies (staggered)
    Future.delayed(const Duration(seconds: 4), () {
       if (mounted) {
         final companiesVm = context.read<CompaniesViewModel>();
         if (companiesVm.companies.isEmpty && !companiesVm.isLoading) {
            debugPrint('🚀 Triggering background load: Companies');
            companiesVm.loadCompanies();
         }
       }
    });

    // Wait 5 seconds for Map (staggered)
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
         final mapVm = context.read<MapViewModel>();
         if (!mapVm.hasLoaded && !mapVm.isLoading) {
            mapVm.init(); 
         }
      }
    });
  }

  final List<Widget> _screens = [
    const HomeView(),
    const CategoriesView(),
    const CompaniesView(),
    const FollowedCompaniesView(),
    const ProfileView(),
  ];

  void switchToTab(int index) {
    _onTabChanged(index);
  }

  void _onTabChanged(int index) {
    // Lazy Load Logic
    if (index == 1) { // Categories
      final vm = context.read<CategoriesViewModel>();
      if (vm.categories.isEmpty && !vm.isLoading) {
        vm.loadCategories();
      }
    } else if (index == 2) { // Companies
      final vm = context.read<CompaniesViewModel>();
      if (vm.companies.isEmpty && !vm.isLoading) {
        vm.loadCompanies();
      }
      // Map init
      final mapVm = context.read<MapViewModel>();
      if (!mapVm.hasLoaded && !mapVm.isLoading) {
          mapVm.init(); 
      }
    } else if (index == 3) { // Followed Companies
      final vm = context.read<UserProfileViewModel>();
      // Reload if empty or stale? Just ensure it's loaded.
      if (vm.followedCompanies.isEmpty && !vm.isLoadingProfile) {
        vm.loadProfileData();
      }
    }
    
    setState(() {
      _currentIndex = index;
    });
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
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 16, left: 12, right: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.kLightBackground,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppTheme.kElectricLime,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              onTap: _onTabChanged,
              items: const [
                BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.house), label: 'الرئيسية'),
                BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.thLarge), label: 'التصنيفات'),
                BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.store), label: 'الشركات'),
                BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.solidStar), label: 'متابَعة'),
                BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.user), label: 'حسابي'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      backgroundColor: AppTheme.kDarkBackground,
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: AppTheme.kLightBackground,
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTabChanged,
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('الرئيسية'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.grid_view),
                label: Text('التصنيفات'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.store),
                label: Text('الشركات'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person),
                label: Text('حسابي'),
              ),
            ],
          ),
          Expanded(
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return _buildTabletLayout(); // Same as tablet for now
  }
}
