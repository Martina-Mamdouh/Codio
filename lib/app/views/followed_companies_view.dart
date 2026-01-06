import 'package:flutter/material.dart';
import '../../core/models/company_model.dart';
import '../../core/services/supabase_service.dart';
import 'widgets/company_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_theme.dart';
import 'company_profile_view.dart';

class FollowedCompaniesView extends StatefulWidget {
  const FollowedCompaniesView({super.key});

  @override
  State<FollowedCompaniesView> createState() => _FollowedCompaniesViewState();
}

class _FollowedCompaniesViewState extends State<FollowedCompaniesView>
    with WidgetsBindingObserver {
  late Future<List<CompanyModel>> _futureCompanies;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _futureCompanies = SupabaseService().getFollowedCompanies();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _futureCompanies = SupabaseService().getFollowedCompanies();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                            'المتابعة',
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
                            'تصفح الشركات التي تهمك',
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
                          hintText: 'ابحث في الشركات التي تتابعها...',
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
            child: FutureBuilder<List<CompanyModel>>(
              future: _futureCompanies,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('حدث خطأ أثناء تحميل الشركات'));
                }
                final companies = snapshot.data ?? [];
                final filteredCompanies = _searchQuery.isEmpty
                    ? companies
                    : companies.where((c) => c.name.contains(_searchQuery)).toList();
                if (filteredCompanies.isEmpty) {
                  return Center(child: Text('لا يوجد شركات متابعة بعد'));
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
                          isFollowed: true,
                          isFollowLoading: false,
                          onToggleFollow: () async {
                            await SupabaseService().toggleCompanyFollow(company.id);
                            setState(() {
                              _futureCompanies = SupabaseService().getFollowedCompanies();
                            });
                          },
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
