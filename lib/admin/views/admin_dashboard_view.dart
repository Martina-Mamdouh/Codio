import 'package:flutter/material.dart';
import 'package:kodio_app/admin/views/deals_management_view.dart';
import 'package:kodio_app/admin/views/reviews_management_view.dart';
import 'package:kodio_app/core/theme/app_theme.dart';
import 'companies_management_view.dart';
import 'banners_management_view.dart';
import 'categories_management_view.dart';
import 'dashboard_home_view.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  int _selectedIndex = 0;

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardHomeView(onNavigate: _onDestinationSelected),
      CompaniesManagementView(),
      DealsManagementView(),
      ReviewsManagementView(),
      CategoriesManagementView(),
      BannersManagementView(),
    ];

    final List<String> pageTitles = [
      'الرئيسية',
      'إدارة الشركات',
      'إدارة العروض',
      'إدارة التقييمات',
      'إدارة الفئات',
      'إدارة البانرات',
    ];

    return Scaffold(
      backgroundColor: AppTheme.kDarkBackground,
      body: Row(
        children: [
          // ✨ Sidebar مع اللوجو من فوق
          Container(
            width: 100,
            color: AppTheme.kLightBackground,
            child: Column(
              children: [
                // ✨ اللوجو في الأعلى
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      height: 72,
                      width: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: 1),

                const SizedBox(height: 20),
                // NavigationRail
                Expanded(
                  child: NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _onDestinationSelected,
                    labelType: NavigationRailLabelType.all,
                    backgroundColor: Colors.transparent,
                    indicatorColor: AppTheme.kElectricLime.withAlpha(51),
                    selectedLabelTextStyle: const TextStyle(
                      color: AppTheme.kElectricLime,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    unselectedLabelTextStyle: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    unselectedIconTheme: const IconThemeData(
                      color: Colors.white70,
                      size: 24,
                    ),
                    selectedIconTheme: const IconThemeData(
                      color: AppTheme.kElectricLime,
                      size: 24,
                    ),
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: Text('الرئيسية'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.business_outlined),
                        selectedIcon: Icon(Icons.business),
                        label: Text('الشركات'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.local_offer_outlined),
                        selectedIcon: Icon(Icons.local_offer),
                        label: Text('العروض'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.star_border_outlined),
                        selectedIcon: Icon(Icons.star),
                        label: Text('التقييمات'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.category_outlined),
                        selectedIcon: Icon(Icons.category),
                        label: Text('الفئات'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.image_outlined),
                        selectedIcon: Icon(Icons.image),
                        label: Text('البانرات'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const VerticalDivider(thickness: 1, width: 1),

          // ✨ المحتوى مع Page Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✨ Page Title Header (بديل الـ AppBar)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.kLightBackground,
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.kSubtleText.withAlpha(26),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        pageTitles[_selectedIndex],
                        style: const TextStyle(
                          color: AppTheme.kLightText,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // المحتوى
                Expanded(child: pages[_selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
