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
      print('DEBUG: Loaded ${deals.length} deals for category ${widget.category.id}');
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
                  child: GridView.builder(
                    padding: EdgeInsets.symmetric(
                      vertical: 16.h,
                      horizontal: 16.w,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: MediaQuery.of(context).orientation == Orientation.portrait ? 0.78 : 0.85,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                    ),
                    itemCount: _deals.length,
                    itemBuilder: (context, index) {
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
            ),
    );
  }
}
