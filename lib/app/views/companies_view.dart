import 'package:flutter/material.dart';
import '../main_layout.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../viewmodels/companies_viewmodel.dart';
import '../viewmodels/map_view_model.dart';
import 'company_profile_view.dart';
import 'widgets/company_card.dart';
import 'widgets/mini_map_widget.dart';
import '../viewmodels/user_profile_viewmodel.dart';
import 'widgets/unified_header.dart'; // Import UnifiedHeader

class CompaniesView extends StatefulWidget {
  const CompaniesView({super.key});

  @override
  State<CompaniesView> createState() => _CompaniesViewState();
}

class _CompaniesViewState extends State<CompaniesView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Trigger load securely if needed, or rely on main_app/init
    // Using simple Consumer approach assuming parent provider exists
    // Lazy loading handled by MainLayout

    return Column(
      children: [
        UnifiedHeader(
          title: 'الشركات',
          subtitle: 'تابع عروض الشركات التي تهمك',
          searchHint: 'ابحث عن شركة...',
          showBackButton: true,
          onBackTap: () {
            context.findAncestorStateOfType<MainLayoutState>()?.switchToTab(0);
          },
          onSearchChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
        ),
        Expanded(
          child: Consumer2<CompaniesViewModel, UserProfileViewModel>(
            builder: (context, vm, profileVm, child) {
              if (vm.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.kElectricLime),
                );
              }

              if (vm.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 40.w),
                      SizedBox(height: 12.h),
                      Text(
                        vm.errorMessage!,
                        style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: vm.loadCompanies,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                );
              }

              if (vm.companies.isEmpty) {
                return Center(
                  child: Text(
                    'لا توجد شركات حالياً',
                    style: TextStyle(color: Colors.white70, fontSize: 16.sp),
                  ),
                );
              }

              final filteredCompanies = vm.companies.where((c) {
                return c.name.toLowerCase().contains(_searchQuery.toLowerCase());
              }).toList();

              if (filteredCompanies.isEmpty) {
                return Center(
                  child: Text(
                    'لا توجد نتائج بحث',
                    style: TextStyle(color: Colors.white70, fontSize: 16.sp),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([
                    vm.loadCompanies(),
                    context.read<MapViewModel>().refresh(),
                  ]);
                },
                color: AppTheme.kElectricLime,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.only(
                        left: 16.w,
                        right: 16.w,
                        top: 24.h,
                        bottom: 16.h,
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : (MediaQuery.of(context).size.width < 900 ? 3 : 4),
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: MediaQuery.of(context).orientation == Orientation.portrait ? 0.65 : 1.1,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final company = filteredCompanies[index];
                            final isFollowed = profileVm.followedCompanies.any((c) => c.id == company.id);

                            return CompanyCard(
                              company: company,
                              isFollowed: isFollowed,
                              isFollowLoading: false,
                              onToggleFollow: () async {
                                await profileVm.toggleCompanyFollow(
                                  company.id,
                                  company: company,
                                );
                              },
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CompanyProfileView(
                                      companyId: company.id,
                                      company: company,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: filteredCompanies.length,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
