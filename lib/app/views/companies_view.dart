import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../viewmodels/companies_viewmodel.dart';
import '../viewmodels/map_view_model.dart';
import 'company_profile_view.dart';
import 'widgets/company_card.dart';
import 'widgets/mini_map_widget.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<CompaniesViewModel>();
      if (vm.companies.isEmpty && !vm.isLoading) {
        vm.loadCompanies();
      }

      final mapVm = context.read<MapViewModel>();
      if (!mapVm.hasLoaded && !mapVm.isLoading) {
        mapVm.init();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.kDarkBackground,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 140.h,
            decoration: const BoxDecoration(
              color: Color(0xFFE5FF17),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(18),
              ),
            ),
          ),
          // Header row: titles left, arrow right, aligned
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'الشركات',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: Theme.of(context).textTheme.titleLarge?.fontFamily,
                              height: 1.1,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'تابع عروض الشركات التي تهمك',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14.sp,
                              fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black, size: 24),
                      onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false),
                      tooltip: 'الرجوع للرئيسية',
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Search bar (centered, interactive)
          Positioned(
            top: 110.h,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.88,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppTheme.kLightBackground,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Colors.white10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppTheme.kElectricLime),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'ابحث عن شركة...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 15.sp,
                            fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                        ),
                        onChanged: (query) {
                          setState(() {
                            _searchQuery = query;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Main content
          Padding(
            padding: EdgeInsets.only(top: 180.h),
            child: Consumer<CompaniesViewModel>(
              builder: (context, vm, child) {
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

                final filteredCompanies = _searchQuery.isEmpty
                    ? vm.companies
                    : vm.companies.where((c) => c.name.contains(_searchQuery)).toList();

                // حساب عدد الأعمدة حسب عرض الشاشة
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
                      onRefresh: () async {
                        await Future.wait([
                          vm.loadCompanies(),
                          context.read<MapViewModel>().refresh(),
                        ]);
                      },
                      color: AppTheme.kElectricLime,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          children: [
                            const MiniMapWidget(focusNearby: false),
                            SizedBox(height: 16.h),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
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
                                  isFollowed: false,
                                  isFollowLoading: false,
                                  onToggleFollow: () {},
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CompanyProfileView(companyId: company.id),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
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
