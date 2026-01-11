// lib/app/views/profile/following_companies_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../viewmodels/user_profile_viewmodel.dart';
import '../company_profile_view.dart';
import '../widgets/company_card.dart';

class FollowingCompaniesView extends StatefulWidget {
  const FollowingCompaniesView({super.key});

  @override
  State<FollowingCompaniesView> createState() => _FollowingCompaniesViewState();
}

class _FollowingCompaniesViewState extends State<FollowingCompaniesView> {
  @override
  void initState() {
    super.initState();
    // Ensure fresh data is loaded when entering screen
    Future.microtask(() {
      if (mounted) {
        context.read<UserProfileViewModel>().loadFollowedCompanies();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Consume global UserProfileViewModel
    final profileVm = context.watch<UserProfileViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.kDarkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.kDarkBackground,
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(color: Colors.white10, width: 1),
        ),
        title: Text(
          'الشركات التي أتابعها',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Builder(
        builder: (context) {
          // Loading state could be complex if combined with other calls, 
          // but we can assume if list is empty and we just triggered load, we wait?
          // Or we utilize a specific loading flag if we added one (we didn't add isLoadingFollowed specifically, but we could use local state if needed)
          // For now, let's just show list or empty message.
          
          if (profileVm.followedCompanies.isEmpty) {
             // Maybe it's loading?
             // Since we don't have a specific 'isLoadingFollows' exposed efficiently yet, 
             // checks might flicker. But let's assume if count > 0 but list empty -> loading
             // actually current VM implementation clears list on load start? No, it replaces it.
             
             // Let's just return empty view for now, allowing pull-to-refresh
             return RefreshIndicator(
                onRefresh: profileVm.loadFollowedCompanies,
                color: AppTheme.kElectricLime,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: 200.h),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'لا توجد شركات متابعة حالياً',
                            style: TextStyle(color: Colors.white70, fontSize: 16.sp),
                          ),
                          if (profileVm.errorMessage != null)
                            Padding(
                              padding: EdgeInsets.only(top: 16.h),
                              child: Text(
                                profileVm.errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.redAccent, fontSize: 14.sp),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
          }

          // List Layout
          return LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount;
              final width = constraints.maxWidth;
              if (width < 340) {
                crossAxisCount = 1;
              } else {
                crossAxisCount = 2;
              }

              return RefreshIndicator(
                onRefresh: profileVm.loadFollowedCompanies,
                color: AppTheme.kElectricLime,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  child: GridView.builder(
                    itemCount: profileVm.followedCompanies.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 16.w,
                      childAspectRatio: MediaQuery.of(context).orientation == Orientation.portrait ? 0.65 : 0.9,
                    ),
                    itemBuilder: (context, index) {
                      final company = profileVm.followedCompanies[index];

                      return CompanyCard(
                        company: company,
                        isFollowed: true,
                        isFollowLoading: false, // We check optimistic within VM, handled by UI updates
                        onToggleFollow: () async {
                           await profileVm.toggleCompanyFollow(
                             company.id,
                             company: company,
                           );
                        },
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CompanyProfileView(companyId: company.id),
                            ),
                          );
                          // Refresh on return
                          if (context.mounted) {
                            profileVm.loadFollowedCompanies();
                          }
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
