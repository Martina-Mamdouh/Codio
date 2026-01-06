import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/models/category_model.dart';
import '../../core/models/deal_model.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../viewmodels/user_profile_viewmodel.dart';
import 'widgets/deal_card.dart';
import 'deal_details_view.dart';

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kDarkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.kDarkBackground,
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(color: Colors.white10, width: 1),
        ),
        title: Text(
          widget.category.name,
          style: const TextStyle(color: Colors.white),
        ),
      ),
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
                return LayoutBuilder(
                  builder: (context, constraints) {
                    // Force exact column count
                    int crossAxisCount;
                    final width = constraints.maxWidth;

                    if (width < 360) {
                      crossAxisCount = 1; // Single column for small screens
                    } else {
                      crossAxisCount = 2; // Always 2 columns
                    }

                    return RefreshIndicator(
                      onRefresh: _loadDeals,
                      color: AppTheme.kElectricLime,
                      child: GridView.builder(
                        padding: EdgeInsets.symmetric(
                          vertical: 16.h,
                          horizontal: 16.w,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 16.h,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: _deals.length,
                        itemBuilder: (context, index) {
                          final deal = _deals[index];
                          final isFav = profileVm.isDealFavorite(deal.id);

                          return DealCard(
                            deal: deal,
                            isFavorite: isFav,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DealDetailsView(deal: deal),
                                ),
                              );
                            },
                            onFavoriteToggle: () async {
                              final success = await profileVm
                                  .toggleFavoriteForDeal(deal.id);
                              if (!success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'تعذّر تحديث المفضّلة، حاول مرة أخرى',
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
