// lib/app/views/widgets/company_deals_tab.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../viewmodels/company_profile_view_model.dart';
import '../deal_details_view.dart';
import '../widgets/deal_card.dart';

class CompanyDealsTab extends StatefulWidget {
  final CompanyProfileViewModel viewModel;
  const CompanyDealsTab({super.key, required this.viewModel});

  @override
  State<CompanyDealsTab> createState() => _CompanyDealsTabState();
}

class _CompanyDealsTabState extends State<CompanyDealsTab> {
  @override
  void initState() {
    super.initState();
    // Removed redundant loadDeals() as it's already handled by loadCompanyData
    if (kDebugMode) {
      print('CompanyDealsTab: Deals count = ${widget.viewModel.deals.length}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.viewModel.isDealsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.kElectricLime),
      );
    }
    if (widget.viewModel.deals.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد عروض لهذه الشركة حالياً',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: widget.viewModel.refreshDeals,
      color: AppTheme.kElectricLime,
      child: GridView.builder(
        padding: EdgeInsets.only(
          top: 16.h,
          left: 16.w,
          right: 16.w,
          bottom: MediaQuery.of(context).padding.bottom + 16.h,
        ),
        itemCount: widget.viewModel.deals.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveUtils.adaptiveCount(
            availableWidth: MediaQuery.of(context).size.width - 32.w,
            minTileWidth: ResponsiveUtils.isTablet(context) ? 220 : 170,
            minCount: 1,
            maxCount: 4,
          ),
          childAspectRatio:
              MediaQuery.of(context).orientation == Orientation.portrait
              ? 0.85
              : 0.9,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
        ),
        itemBuilder: (context, index) {
          final deal = widget.viewModel.deals[index];
          return DealCard(
            deal: deal,
            showCategory: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DealDetailsView(deal: deal)),
              );
            },
          );
        },
      ),
    );
  }
}
