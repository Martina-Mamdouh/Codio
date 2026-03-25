import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import '../../core/models/deal_model.dart';
import '../../core/theme/app_theme.dart';
import '../viewmodels/deal_details_view_model.dart';
import 'company_profile_view.dart';

class DealDetailsView extends StatefulWidget {
  final DealModel deal;

  const DealDetailsView({super.key, required this.deal});

  @override
  State<DealDetailsView> createState() => _DealDetailsViewState();
}

class _DealDetailsViewState extends State<DealDetailsView> {
  @override
  void initState() {
    super.initState();
    // تحميل بيانات الشركة بعد البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<DealDetailsViewModel>();
      viewModel.incrementDealViews();
      viewModel.loadCompanyData(
        widget.deal.companyId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = intl.DateFormat(
      'dd/MM/yyyy',
    ).format(widget.deal.expiresAt);

    return ChangeNotifierProvider(
      create: (_) => DealDetailsViewModel(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppTheme.kDarkBackground,
          appBar: AppBar(
            backgroundColor: AppTheme.kDarkBackground,
            elevation: 0,
            shape: const Border(
              bottom: BorderSide(color: Colors.white10, width: 1),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Consumer<DealDetailsViewModel>(
                builder: (context, viewModel, _) => IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () => viewModel.shareDeal(widget.deal),
                ),
              ),
            ],
          ),

          body: Consumer<DealDetailsViewModel>(
            builder: (context, viewModel, _) {
              return RefreshIndicator(
                onRefresh: () =>
                    viewModel.loadCompanyData(widget.deal.companyId),
                color: AppTheme.kElectricLime,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => viewModel.incrementImageClick(),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16.r),
                            bottomRight: Radius.circular(16.r),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: widget.deal.imageUrl,
                            height: 250.h,
                            width: double.infinity,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Container(
                              height: 250.h,
                              color: Colors.grey[800],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.kElectricLime,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 250.h,
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.error,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(16.0.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.deal.isForStudents ||
                                widget.deal.discountValue.isNotEmpty) ...[
                              Row(
                                children: [
                                  if (widget.deal.isForStudents)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.kElectricLime
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                        border: Border.all(
                                          color: AppTheme.kElectricLime,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.school,
                                            size: 12.w,
                                            color: AppTheme.kElectricLime,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            'للطلاب',
                                            style: TextStyle(
                                              color: AppTheme.kElectricLime,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const Spacer(),
                                  if (widget.deal.discountValue.isNotEmpty)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius: BorderRadius.circular(
                                          20.r,
                                        ),
                                      ),
                                      child: Text(
                                        widget.deal.discountValue,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                            ],

                            Text(
                              widget.deal.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.h),

                            Text(
                              widget.deal.description,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14.sp,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 8.h),

                            // مؤشر نجاح العرض
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 16.w,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'شغّال (${(widget.deal.successRate ?? 90.0).toStringAsFixed(0)}%)',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),

                            // تقييم سريع
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'تقييم سريع للعرض:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildFeedbackEmoji('😊', '${(widget.deal.feedbackHappy ?? 80.0).toStringAsFixed(0)}%', Colors.green),
                                      _buildFeedbackEmoji('😐', '${(widget.deal.feedbackNeutral ?? 15.0).toStringAsFixed(0)}%', Colors.yellow),
                                      _buildFeedbackEmoji('😞', '${(widget.deal.feedbackSad ?? 5.0).toStringAsFixed(0)}%', Colors.red),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // تتبع التفاعل
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'تتبع التفاعل:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  _buildInteractionStats(viewModel),
                                ],
                              ),
                            ),

                            SizedBox(height: 16.h),

                            Row(
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  color: Colors.redAccent,
                                  size: 16.w,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'ينتهي في $formattedDate',
                                  style: TextStyle(
                                    color: Colors.redAccent[100],
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 24.h),

                            // كارت الشركة مع اللوجو الفعلي
                            Consumer<DealDetailsViewModel>(
                              builder: (context, viewModel, _) {
                                final companyLogo = widget.deal.companyLogo;

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CompanyProfileView(
                                              companyId: widget.deal.companyId,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 64.h,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2C2C2E),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(color: Colors.white10),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40.w,
                                          height: 40.w,
                                          decoration: BoxDecoration(
                                            color: AppTheme.kElectricLime,
                                            shape: BoxShape.circle,
                                          ),
                                          child: companyLogo != null
                                              ? ClipOval(
                                                  child: CachedNetworkImage(
                                                    imageUrl: companyLogo,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context, url) =>
                                                        const CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.black87,
                                                        ),
                                                    errorWidget:
                                                        (
                                                          context,
                                                          url,
                                                          error,
                                                        ) => Icon(
                                                          Icons.store,
                                                          color: Colors.black87,
                                                          size: 20.w,
                                                        ),
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.store,
                                                  color: Colors.black87,
                                                  size: 20.w,
                                                ),
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.deal.companyName ??
                                                    'متجر',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'اضغط لعرض المتجر',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 10.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: Colors.grey,
                                          size: 24.w,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: 32.h),

                            Text(
                              widget.deal.dealType == 'code'
                                  ? 'كود الخصم'
                                  : 'رابط العرض',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12.h),

                            Consumer<DealDetailsViewModel>(
                              builder: (context, viewModel, _) {
                                if (widget.deal.dealType == 'code') {
                                  return Container(
                                    height: 65.h,
                                    decoration: BoxDecoration(
                                      color: AppTheme.kElectricLime,
                                      borderRadius: BorderRadius.circular(16.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.kElectricLime
                                              .withValues(alpha: 0.3),
                                          blurRadius: 15.w,
                                          offset: Offset(0, 4.h),
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20.w,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          widget.deal.dealValue,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 2.0,
                                          ),
                                        ),
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () => viewModel.copyCode(
                                              context,
                                              widget.deal.dealValue,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 16.w,
                                                vertical: 8.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(
                                                  alpha: 0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                                border: Border.all(
                                                  color: Colors.black12,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Text(
                                                    'نسخ',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  SizedBox(width: 6.w),
                                                  Icon(
                                                    Icons.copy,
                                                    size: 18.w,
                                                    color: Colors.black,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return Container(
                                  height: 60.h,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppTheme.kElectricLime,
                                    borderRadius: BorderRadius.circular(16.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.kElectricLime
                                            .withValues(alpha: 0.3),
                                        blurRadius: 15.w,
                                        offset: Offset(0, 4.h),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => viewModel.openDealLink(
                                        widget.deal.dealValue,
                                      ),
                                      borderRadius: BorderRadius.circular(16.r),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'اذهب للعرض',
                                            style: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Icon(
                                            Icons.open_in_new,
                                            size: 22.w,
                                            color: Colors.black,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: 32.h),

                            if (widget.deal.termsConditions.isNotEmpty) ...[
                              Text(
                                'الشروط والاحكام',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1C1C1E),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      color: Colors.grey,
                                      size: 20.w,
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Text(
                                        widget.deal.termsConditions,
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 13.sp,
                                          height: 1.6,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackEmoji(String emoji, String percentage, Color color) {
    return Column(
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: 24.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          percentage,
          style: TextStyle(
            color: color,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInteractionStats(DealDetailsViewModel viewModel) {
    return Column(
      children: [
        _buildStatRow(Icons.content_copy, 'نسخ كود الخصم', viewModel.copyCodeCount),
        SizedBox(height: 6.h),
        _buildStatRow(Icons.launch, 'فتح الرابط الخارجي', viewModel.openLinkCount),
        SizedBox(height: 6.h),
        _buildStatRow(Icons.image, 'الضغط على الصور', viewModel.imageClickCount),
        SizedBox(height: 6.h),
        _buildStatRow(Icons.visibility, 'زيارات العرض', viewModel.dealViews),
        SizedBox(height: 6.h),
        _buildStatRow(Icons.business, 'زيارات الشركة', viewModel.companyViews),
      ],
    );
  }

  Widget _buildStatRow(IconData icon, String label, int count) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: AppTheme.kElectricLime.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: AppTheme.kElectricLime,
            size: 18.w,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            '$label: $count',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    );
  }
}
