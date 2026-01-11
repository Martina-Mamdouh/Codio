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
                  return ListView.separated(
                    padding: EdgeInsets.all(16.w),
                    itemCount: deals.length,
                    separatorBuilder: (context, index) => SizedBox(height: 16.h),
                    itemBuilder: (context, index) {
                      final deal = deals[index];
                      final isFav = profileVm.isDealFavorite(deal.id);

                      return DealCard(
                        deal: deal,
                        isFavorite: isFav,
                        showCategory: true,
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
                          final success = await profileVm
                              .toggleFavoriteForDeal(deal.id);
                          if (!success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'تعذّر تحديث المفضّلة، حاول مرة أخرى'),
                              ),
                            );
                          }
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
