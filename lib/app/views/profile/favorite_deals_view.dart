import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../widgets/yellow_scaffold.dart';
import '../../../core/theme/app_theme.dart';
import '../../viewmodels/user_profile_viewmodel.dart';
import '../../views/widgets/deal_card.dart';
import '../deal_details_view.dart';

class FavoriteDealsView extends StatefulWidget {
  const FavoriteDealsView({super.key});

  @override
  State<FavoriteDealsView> createState() => _FavoriteDealsViewState();
}

class _FavoriteDealsViewState extends State<FavoriteDealsView> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (mounted) {
        context.read<UserProfileViewModel>().loadFavoriteDeals();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileVm = context.watch<UserProfileViewModel>();

    return YellowScaffold(
      title: 'العروض المفضّلة',
      // showBackButton: true, // Default
      body: Builder(
        builder: (context) {
          if (profileVm.isLoadingFavorites) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.kElectricLime),
            );
          }

          if (profileVm.favoriteDeals.isEmpty) {
            return RefreshIndicator(
              onRefresh: profileVm.loadFavoriteDeals,
              color: AppTheme.kElectricLime,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 120.h),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'لا توجد عروض مفضّلة حالياً',
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

          return RefreshIndicator(
            onRefresh: profileVm.loadFavoriteDeals,
            color: AppTheme.kElectricLime,
            child: GridView.builder(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              itemCount: profileVm.favoriteDeals.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: MediaQuery.of(context).orientation == Orientation.portrait ? 0.78 : 0.85,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
              ),
              itemBuilder: (context, index) {
                final deal = profileVm.favoriteDeals[index];

                return DealCard(
                  deal: deal,
                  isFavorite: true,
                  showCategory: true,
                  onFavoriteToggle: () async {
                    final success = await profileVm.toggleFavoriteForDeal(
                      deal.id,
                    );
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تعذر تحديث المفضّلة، حاول مرة أخرى'),
                        ),
                      );
                    }
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DealDetailsView(deal: deal),
                      ),
                    );
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
