import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/models/category_model.dart';
import '../../core/models/deal_model.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../viewmodels/user_profile_viewmodel.dart';
import 'widgets/deal_card.dart';
import 'widgets/yellow_scaffold.dart';
import 'deal_details_view.dart';
import 'widgets/ads_slider.dart';

class CategoryDealsView extends StatefulWidget {
  final CategoryModel category;

  const CategoryDealsView({super.key, required this.category});

  @override
  State<CategoryDealsView> createState() => _CategoryDealsViewState();
}

class _CategoryDealsViewState extends State<CategoryDealsView> {
  final _supabaseService = SupabaseService();
  List<DealModel> _deals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeals();
  }

  Future<void> _loadDeals() async {
    setState(() => _isLoading = true);
    final deals = await _supabaseService.getDealsByCategory(widget.category.id);
    setState(() {
      _deals = deals;
      _isLoading = false;
      if (kDebugMode) {
        print(
        'DEBUG: Loaded ${deals.length} deals for category ${widget.category.id}',
      );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return YellowScaffold(
      title: widget.category.name,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.kElectricLime),
            )
          : _deals.isEmpty
          ? const Center(
              child: Text(
                'لا توجد عروض في هذه الفئة',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : Consumer<UserProfileViewModel>(
              builder: (context, profileVm, _) {
                return RefreshIndicator(
                  onRefresh: _loadDeals,
                  color: AppTheme.kElectricLime,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Ads slider placed under the title
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          child: AdsSlider(),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: MediaQuery.of(context).orientation == Orientation.portrait
                                ? 0.85
                                : 0.9,
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.h,
                          ),
                          delegate: SliverChildBuilderDelegate((context, index) {
                            final deal = _deals[index];
                            final isFav = profileVm.isDealFavorite(deal.id);

                            return DealCard(
                              deal: deal,
                              isFavorite: isFav,
                              showCategory: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DealDetailsView(deal: deal),
                                  ),
                                );
                              },
                              onFavoriteToggle: () async {
                                final success = await profileVm.toggleFavoriteForDeal(deal.id);
                                if (!success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تعذّر تحديث المفضّلة، حاول مرة أخرى'),
                                    ),
                                  );
                                }
                              },
                            );
                          }, childCount: _deals.length),
                        ),
                      ),
                      // Add bottom padding to clear floating nav
                      SliverPadding(padding: EdgeInsets.only(bottom: AppTheme.bottomNavGap)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
