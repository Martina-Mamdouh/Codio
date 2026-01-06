// lib/app/views/widgets/company_deals_tab.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
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
    // Load deals if not loaded
    if (widget.viewModel.deals.isEmpty && !widget.viewModel.isDealsLoading) {
      if (kDebugMode) {
        print('CompanyDealsTab initState: loading deals for company ${widget.viewModel.company?.name ?? 'unknown'}');
      }
      widget.viewModel.loadDeals();
    } else {
      if (kDebugMode) {
        print('CompanyDealsTab initState: deals already loaded: ${widget.viewModel.deals.length}');
      }
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
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        itemCount: widget.viewModel.deals.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 0.7,
        ),
        itemBuilder: (context, index) {
          final deal = widget.viewModel.deals[index];
          return DealCard(
              deal: deal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DealDetailsView(deal: deal),
                  ),
                );
              },
            );
        },
      ),
    );
  }
}
