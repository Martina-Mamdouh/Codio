import 'package:cached_network_image/cached_network_image.dart';
import '../main_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/models/category_model.dart';
import '../../core/theme/app_theme.dart';
import '../viewmodels/categories_viewmodel.dart';
import 'category_deals_view.dart';
import 'widgets/unified_header.dart'; // Import the new header

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
    // Lazy loading handled by MainLayout
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UnifiedHeader(
          title: 'التصنيفات',
          subtitle: 'تصفح العروض حسب الفئة',
          searchHint: 'ابحث عن تصنيف...',
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
          child: Consumer<CategoriesViewModel>(
            builder: (context, vm, child) {
              if (vm.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.kElectricLime),
                );
              }
              if (vm.categories.isEmpty) {
                return const Center(
                  child: Text(
                    'لا توجد فئات',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              
              final filtered = vm.categories.where((c) {
                 return c.name.toLowerCase().contains(_searchQuery.toLowerCase());
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    'لا توجد نتائج بحث',
                    style: TextStyle(color: Colors.white70, fontSize: 16.sp),
                  ),
                );
              }

              final width = MediaQuery.of(context).size.width;
              int crossAxisCount = 2;
              if (width > 900) {
                crossAxisCount = 4;
              } else if (width > 600) {
                crossAxisCount = 3;
              }

              return RefreshIndicator(
                onRefresh: vm.loadCategories,
                color: AppTheme.kElectricLime,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.only(
                        top: 24.h,
                        bottom: 16.h,
                        left: 16.w,
                        right: 8.w,
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16.w,
                          mainAxisSpacing: 16.h,
                          childAspectRatio: 3.5,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final category = filtered[index];
                            return _CategoryCard(category: category);
                          },
                          childCount: filtered.length,
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
