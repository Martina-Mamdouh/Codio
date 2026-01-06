import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kodio_app/core/models/deal_model.dart';
import 'package:provider/provider.dart';
import 'package:kodio_app/core/theme/app_theme.dart';
import 'package:kodio_app/app/views/widgets/deal_card.dart';

import '../viewmodels/user_profile_viewmodel.dart';
import 'deal_details_view.dart';

class ViewAllDealsScreen extends StatelessWidget {
  final String title;
  final List<DealModel> deals;
  final String? categoryId;

  const ViewAllDealsScreen({
    super.key,
    required this.title,
    required this.deals,
    this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.kDarkBackground,
        appBar: AppBar(
          elevation: 2,
          backgroundColor: AppTheme.kDarkBackground,
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: deals.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_offer_outlined,
                      size: 80.w,
                      color: Colors.white30,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'لا توجد عروض حاليًا',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 16.sp,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              )
            : Consumer<UserProfileViewModel>(
                builder: (context, profileVm, _) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      // Force exact column count
                      int crossAxisCount;
                      final screenWidth = constraints.maxWidth;

                      if (screenWidth < 360) {
                        crossAxisCount =
                            1; // Single column for very small screens
                      } else {
                        crossAxisCount =
                            2; // Always 2 columns for larger screens
                      }

                      return GridView.builder(
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
                        itemCount: deals.length,
                        itemBuilder: (context, index) {
                          final deal = deals[index];
                          final isFav = profileVm.isDealFavorite(deal.id);

                          return DealCard(
                            deal: deal,
                            isFavorite: isFav,
                            onTap: () {
                              debugPrint('Pressed on deal: ${deal.title}');
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
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
