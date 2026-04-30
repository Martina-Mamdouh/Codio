import 'package:flutter/material.dart';
import '../main_layout.dart';
import 'widgets/company_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_utils.dart';
import 'company_profile_view.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_profile_viewmodel.dart';
import 'widgets/unified_header.dart';

class FollowedCompaniesView extends StatefulWidget {
  const FollowedCompaniesView({super.key});

  @override
  State<FollowedCompaniesView> createState() =>
      _FollowedCompaniesViewState();
}

class _FollowedCompaniesViewState extends State<FollowedCompaniesView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 800;

    /// 🔥 MUST match header floating space (tablet only)
    final double headerSafeSpace = isTablet ? 40.h : 0;

    return Column(
      children: [
        UnifiedHeader(
          title: 'المتابعة',
          subtitle: 'تصفح الشركات التي تهمك',
          searchHint: 'ابحث في المتابعة...',
          showBackButton: true,
          onBackTap: () {
            context
                .findAncestorStateOfType<MainLayoutState>()
                ?.switchToTab(0);
          },
          onSearchChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
        ),

        Expanded(
          child: Stack(
            children: [
              /// 🔥 This fixes scroll going under header/search
              Padding(
                padding: EdgeInsets.only(
                  top: headerSafeSpace,
                ),
                child: Consumer<UserProfileViewModel>(
                  builder: (context, profileVm, child) {
                    if (profileVm.isLoadingProfile &&
                        profileVm.followedCompanies.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.kElectricLime,
                        ),
                      );
                    }

                    if (profileVm.followedCompanies.isEmpty) {
                      return const Center(
                        child: Text(
                          'لا يوجد شركات متابعة بعد',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    final companies = profileVm.followedCompanies;

                    final filteredCompanies = companies.where((c) {
                      return c.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                    }).toList();

                    if (filteredCompanies.isEmpty) {
                      return const Center(
                        child: Text(
                          'لا توجد نتائج بحث',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    int crossAxisCount;
                    double childAspectRatio;

                    if (isTablet) {
                      crossAxisCount = width >= 1200 ? 4 : 3;
                      childAspectRatio = 0.9;
                    } else {
                      crossAxisCount = width < 340 ? 1 : 2;
                      childAspectRatio = 0.73;
                    }

                    return RefreshIndicator(
                      onRefresh: profileVm.loadProfileData,
                      color: AppTheme.kElectricLime,
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.only(
                              left: isTablet ? 24.w : 16.w,
                              right: isTablet ? 24.w : 16.w,

                              /// 🔥 prevents overlap feel
                              top: isTablet ? 20.h : 12.h,

                              bottom: AppTheme.bottomNavGap,
                            ),
                            sliver: SliverGrid(
                              gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing:
                                isTablet ? 16.h : 12.h,
                                crossAxisSpacing:
                                isTablet ? 16.w : 12.w,
                                childAspectRatio: childAspectRatio,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                  final company =
                                  filteredCompanies[index];

                                  return CompanyCard(
                                    company: company,
                                    isFollowed: true,
                                    isFollowLoading: false,
                                    onToggleFollow: () async {
                                      await profileVm
                                          .toggleCompanyFollow(
                                        company.id,
                                        company: company,
                                      );
                                    },
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              CompanyProfileView(
                                                companyId: company.id,
                                                company: company,
                                              ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                childCount:
                                filteredCompanies.length,
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
          ),
        ),
      ],
    );
  }
}