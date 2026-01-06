import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../core/models/deal_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../viewmodels/user_profile_viewmodel.dart';
import '../deal_details_view.dart';
import '../view_all_deals_screen.dart';
import 'deal_card.dart';

class DealSection extends StatelessWidget {
  final String title;
  final List<DealModel> deals;
  final VoidCallback? onSeeAllTap;

  const DealSection({
    super.key,
    required this.title,
    required this.deals,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    if (deals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header (العنوان + عرض الكل)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 12.0.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.kLightText,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ViewAllDealsScreen(title: title, deals: deals),
                    ),
                  );
                },
                child: Text(
                  'عرض الكل',
                  style: TextStyle(
                    color: AppTheme.kElectricLime,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Horizontal ListView
        Container(
          constraints: BoxConstraints(minHeight: 230.h, maxHeight: 240.h),
          child: Consumer<UserProfileViewModel>(
            builder: (context, profileVm, child) {
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: deals.length,
                separatorBuilder: (_, __) =>
                    SizedBox(width: 12.w), // مسافة بين الكروت
                itemBuilder: (context, index) {
                  final deal = deals[index];
                  final isFav = profileVm.isDealFavorite(deal.id);

                  return SizedBox(
                    width: 230.w,
                    child: DealCard(
                      deal: deal,
                      isFavorite: isFav,
                      onTap: () {
                        debugPrint('Pressed on deal: ${deal.title}');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DealDetailsView(deal: deal),
                          ),
                        );
                      },
                      onFavoriteToggle: () async {
                        final success = await profileVm.toggleFavoriteForDeal(
                          deal.id,
                        );
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
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
