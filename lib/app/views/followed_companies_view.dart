import 'package:flutter/material.dart';
import '../main_layout.dart';
import '../../core/models/company_model.dart';
import '../../core/services/supabase_service.dart';
import 'widgets/company_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_theme.dart';
import 'company_profile_view.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_profile_viewmodel.dart';
import 'widgets/unified_header.dart'; // Import UnifiedHeader

class FollowedCompaniesView extends StatefulWidget {
  const FollowedCompaniesView({super.key});

  @override
  State<FollowedCompaniesView> createState() => _FollowedCompaniesViewState();
}

class _FollowedCompaniesViewState extends State<FollowedCompaniesView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UnifiedHeader(
          title: 'المتابعة',
          subtitle: 'تصفح الشركات التي تهمك',
          searchHint: 'ابحث في المتابعة...',
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
          child: Consumer<UserProfileViewModel>(
            builder: (context, profileVm, child) {
              // Show loading ONLY if initial load and empty (to avoid empty state flash)
              if (profileVm.isLoadingProfile && profileVm.followedCompanies.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.kElectricLime));
              }
          
              // If truly empty
              if (profileVm.followedCompanies.isEmpty) {
                return Center(child: Text('لا يوجد شركات متابعة بعد', style: TextStyle(color: Colors.white70)));
              }
          
              final companies = profileVm.followedCompanies;
              final filteredCompanies = companies.where((c) {
                 return c.name.toLowerCase().contains(_searchQuery.toLowerCase());
              }).toList();
          
              if (filteredCompanies.isEmpty) {
                 return Center(child: Text('لا توجد نتائج بحث', style: TextStyle(color: Colors.white70)));
              }
          
              final width = MediaQuery.of(context).size.width;
              final crossAxisCount = width < 340 ? 1 : 2;

              return RefreshIndicator(
                onRefresh: () async {
                  await profileVm.loadProfileData();
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
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: MediaQuery.of(context).orientation == Orientation.portrait ? 0.73 : 1.1,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final company = filteredCompanies[index];
                            return CompanyCard(
                              company: company,
                              isFollowed: true, 
                              isFollowLoading: false,
                              onToggleFollow: () async {
                                 await profileVm.toggleCompanyFollow(company.id, company: company);
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
