import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:kodio_app/app/views/categories_view.dart';
import 'package:kodio_app/app/views/companies_view.dart';
import 'package:kodio_app/app/views/home_view.dart';
import 'package:kodio_app/app/views/profile/profile_view.dart';
import '../../core/theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'views/followed_companies_view.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeView(),
    const CategoriesView(),
    const CompaniesView(),
    const FollowedCompaniesView(),
    const ProfileView(),
  ];

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
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
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
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
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
