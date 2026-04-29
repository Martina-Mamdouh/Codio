import 'package:flutter/material.dart';
import '../main_layout.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../viewmodels/companies_viewmodel.dart';
import '../viewmodels/map_view_model.dart';
import 'company_profile_view.dart';
import 'widgets/company_card.dart';
import '../viewmodels/user_profile_viewmodel.dart';
import 'widgets/unified_header.dart';

class CompaniesView extends StatefulWidget {
  const CompaniesView({super.key});

  @override
  State<CompaniesView> createState() => _CompaniesViewState();
}

class _CompaniesViewState extends State<CompaniesView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 800;

    /// 🔥 MUST MATCH HEADER HEIGHT (prevents overlap completely)
    final double headerSafeSpace = isTablet ? 40.h : 0;

    return Column(
      children: [
        UnifiedHeader(
          title: 'الشركات',
          subtitle: 'تابع عروض الشركات التي تهمك',
          searchHint: 'ابحث عن شركة...',
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
              /// 🔥 THIS is the real fix (prevents overlap completely)
              Padding(
                padding: EdgeInsets.only(
                  top: headerSafeSpace,
                ),
                child: Consumer2<CompaniesViewModel, UserProfileViewModel>(
                  builder: (context, vm, profileVm, child) {
                    if (vm.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.kElectricLime,
                        ),
                      );
                    }

                    if (vm.errorMessage != null) {
                      return Center(
                        child: Text(vm.errorMessage!),
                      );
                    }

                    final filteredCompanies = vm.companies.where((c) {
                      return c.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                    }).toList();

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
                      onRefresh: () async {
                        await Future.wait([
                          vm.loadCompanies(),
                          context.read<MapViewModel>().refresh(),
                        ]);
                      },
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

                                  final isFollowed =
                                  profileVm.followedCompanies.any(
                                        (c) => c.id == company.id,
                                  );

                                  return CompanyCard(
                                    company: company,
                                    isFollowed: isFollowed,
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