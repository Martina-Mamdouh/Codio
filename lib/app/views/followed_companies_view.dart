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
    return Scaffold(
      backgroundColor: AppTheme.kDarkBackground,
      // No AppBar, UnifiedHeader in body
      body: Column(
        children: [
// Invalid lines removed

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
            
                return LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount;
                    final width = constraints.maxWidth;
                    if (width < 340) {
                      crossAxisCount = 1;
                    } else {
                      crossAxisCount = 2;
                    }
                    return GridView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: filteredCompanies.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.73,
                      ),
                      itemBuilder: (context, index) {
                        final company = filteredCompanies[index];
                        return CompanyCard(
                          company: company,
                          // We pass true because this LIST only contains followed companies!
                          // But to be safe and reactive, we could check IDs.
                          // However, optimizing: UserProfileVM ensures this list is valid.
                          isFollowed: true, 
                          isFollowLoading: false,
                          onToggleFollow: () async {
                             // Use VM to toggle, which handles optimistic updates
                             await profileVm.toggleCompanyFollow(company.id, company: company);
                          },
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CompanyProfileView(
                                  companyId: company.id, 
                                  company: company, // Pass instant load data!
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
