import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/models/category_model.dart';
import '../../core/theme/app_theme.dart';
import '../viewmodels/categories_viewmodel.dart';
import 'category_deals_view.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  String _searchQuery = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<CategoriesViewModel>();
      if (vm.categories.isEmpty && !vm.isLoading) {
        vm.loadCategories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
                              'التصنيفات',
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
                              'تصفح العروض حسب اهتماماتك',
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
                            hintText: 'ابحث عن تصنيف...',
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
              child: Consumer<CategoriesViewModel>(
                builder: (context, vm, child) {
                  final filteredCategories = _searchQuery.isEmpty
                      ? vm.categories
                      : vm.categories.where((c) => c.name.contains(_searchQuery)).toList();
                  if (vm.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.kElectricLime),
                    );
                  }
                  if (filteredCategories.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا توجد فئات',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: vm.loadCategories,
                    color: AppTheme.kElectricLime,
                    child: GridView.builder(
                      padding: EdgeInsets.only(
                        top: 16.h,
                        bottom: 16.h,
                        left: 16.w,
                        right: 8.w,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.w,
                        mainAxisSpacing: 16.h,
                        childAspectRatio: 3.5,
                      ),
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = filteredCategories[index];
                        return _CategoryCard(category: category);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDealsView(category: category),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8.w,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Stack(
            children: [
              Positioned.fill(
                child: category.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: category.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey[800]),
                        errorWidget: (context, url, error) =>
                            Container(color: Colors.grey[800]),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors
                                  .primaries[category.id %
                                      Colors.primaries.length]
                                  .withValues(alpha: 0.8),
                              Colors
                                  .primaries[(category.id + 1) %
                                      Colors.primaries.length]
                                  .withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
              ),

              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                right: 12.w,
                bottom: 12.h,
                left: 12.w,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(color: Colors.black, blurRadius: 6.w),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
