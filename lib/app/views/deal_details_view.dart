import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import '../../core/models/deal_model.dart';
import '../../core/theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/deal_details_view_model.dart';
import 'company_profile_view.dart';
import 'auth/login_screen.dart';

class DealDetailsView extends StatefulWidget {
  final DealModel deal;

  const DealDetailsView({super.key, required this.deal});

  @override
  State<DealDetailsView> createState() => _DealDetailsViewState();
}

class _DealDetailsViewState extends State<DealDetailsView> {
  late final PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentPage = 0;

  List<String> get _allImages => widget.deal.allImages;
  bool get _hasMultipleImages => _allImages.length > 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    if (!_hasMultipleImages) return;
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final nextPage = (_currentPage + 1) % _allImages.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = intl.DateFormat(
      'dd/MM/yyyy',
    ).format(widget.deal.expiresAt);

    return ChangeNotifierProvider(
      create: (_) {
        final vm = DealDetailsViewModel();
        // Load data immediately
        vm.incrementDealViews(widget.deal.id);
        vm.loadCompanyData(widget.deal.companyId, widget.deal.id);
        return vm;
      },
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
        ),

        body: Consumer<DealDetailsViewModel>(
          builder: (context, viewModel, _) {
            return RefreshIndicator(
              onRefresh: () => viewModel.loadCompanyData(
                widget.deal.companyId,
                widget.deal.id,
              ),
              color: AppTheme.kElectricLime,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== Image Carousel =====
                    _buildImageCarousel(viewModel),

                    Padding(
                      padding: EdgeInsets.all(16.0.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.deal.isForStudents ||
                              widget.deal.discountValue.isNotEmpty) ...[
                            Row(
                              children: [
                                if (widget.deal.discountValue.isNotEmpty)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(20.r),
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
                                const Spacer(),
                                if (widget.deal.isForStudents)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.kElectricLime.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(8.r),
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
                          SizedBox(height: 16.h),

                          // عداد الزيارات وتقييم النجاح
                          Consumer<DealDetailsViewModel>(
                            builder: (context, viewModel, _) {
                              return Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.kElectricLime.withValues(
                                        alpha: 0.1,
                                      ),
                                      AppTheme.kElectricLime.withValues(
                                        alpha: 0.05,
                                      ),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: AppTheme.kElectricLime.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // زر مشاركة العرض
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          viewModel.shareDeal(widget.deal);
                                        },
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.share_rounded,
                                              color: AppTheme.kElectricLime,
                                              size: 32.w,
                                            ),
                                            SizedBox(height: 8.h),
                                            Text(
                                              'مشاركة',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              'شارك مع أصدقائك',
                                              style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    Container(
                                      width: 1,
                                      height: 60.h,
                                      color: Colors.white10,
                                    ),

                                    // Success rate
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.check_circle_rounded,
                                            color: Colors.green,
                                            size: 32.w,
                                          ),
                                          SizedBox(height: 8.h),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: List.generate(5, (index) {
                                              // Calculate rating from 0 to 5 based on percentage (0-100)
                                              final rating =
                                                  (viewModel
                                                          .calculatedSuccessRate /
                                                      100) *
                                                  5;
                                              final bool isFull =
                                                  rating >= (index + 1);
                                              final bool isHalf =
                                                  rating > index &&
                                                  rating < (index + 1);

                                              return Icon(
                                                isFull
                                                    ? Icons.star_rounded
                                                    : (isHalf
                                                          ? Icons
                                                                .star_half_rounded
                                                          : Icons
                                                                .star_border_rounded),
                                                color: Colors.amber,
                                                size: 20.w,
                                              );
                                            }),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            'تقييم',
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 16.h),

                          // تقييم سريع بالإيموجي - تفاعلي
                          Consumer<DealDetailsViewModel>(
                            builder: (context, viewModel, _) {
                              return Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'قيّم تجربتك مع العرض:',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildInteractiveEmoji(
                                          context,
                                          viewModel,
                                          widget.deal.id,
                                          '😊',
                                          'happy',
                                          'ممتاز',
                                          Colors.green,
                                          viewModel.totalEmojiCount > 0
                                              ? '${viewModel.emotionalHappy.toStringAsFixed(0)}%'
                                              : '-',
                                        ),
                                        _buildInteractiveEmoji(
                                          context,
                                          viewModel,
                                          widget.deal.id,
                                          '😐',
                                          'neutral',
                                          'عادي',
                                          Colors.orange,
                                          viewModel.totalEmojiCount > 0
                                              ? '${viewModel.emotionalNeutral.toStringAsFixed(0)}%'
                                              : '-',
                                        ),
                                        _buildInteractiveEmoji(
                                          context,
                                          viewModel,
                                          widget.deal.id,
                                          '😞',
                                          'sad',
                                          'سيء',
                                          Colors.red,
                                          viewModel.totalEmojiCount > 0
                                              ? '${viewModel.emotionalSad.toStringAsFixed(0)}%'
                                              : '-',
                                        ),
                                      ],
                                    ),
                                    if (viewModel.totalEmojiCount > 0) ...[
                                      SizedBox(height: 12.h),
                                      Center(
                                        child: Text(
                                          '${viewModel.totalEmojiCount} تقييم',
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 11.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 16.h),

                          SizedBox(height: 8.h),

                          // كارت الشركة مع اللوجو الفعلي
                          Text(
                            'الشركة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Consumer<DealDetailsViewModel>(
                            builder: (context, viewModel, _) {
                              final companyLogo = widget.deal.companyLogo;

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CompanyProfileView(
                                        companyId: widget.deal.companyId,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  constraints: BoxConstraints(minHeight: 64.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2C2C2E),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 12.h,
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
                                                      (context, url, error) =>
                                                          Icon(
                                                            Icons.store,
                                                            color:
                                                                Colors.black87,
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
                                              widget.deal.companyName ?? 'متجر',
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

                          SizedBox(height: 16.h),

                          // عنوان ديناميكي حسب نوع العرض
                          Text(
                            widget.deal.dealType == 'code'
                                ? 'كود الخصم'
                                : widget.deal.dealType == 'both'
                                    ? 'كود الخصم ورابط العرض'
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
                              // كود الخصم (يظهر في code و both)
                              final showCode = widget.deal.dealType == 'code' ||
                                  widget.deal.dealType == 'both';
                              // رابط العرض (يظهر في link و both)
                              final showLink = widget.deal.dealType == 'link' ||
                                  widget.deal.dealType == 'both';

                              return Column(
                                children: [
                                  // === كود الخصم ===
                                  if (showCode)
                                    Container(
                                      height: 65.h,
                                      decoration: BoxDecoration(
                                        color: AppTheme.kElectricLime,
                                        borderRadius:
                                            BorderRadius.circular(16.r),
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
                                              onTap: () {
                                                final isGuest = context
                                                    .read<AuthViewModel>()
                                                    .isGuestMode;
                                                if (isGuest) {
                                                  _showGuestSnackBar(
                                                    context,
                                                    'سجّل دخولك لنسخ كود الخصم',
                                                  );
                                                } else {
                                                  viewModel.copyCode(
                                                    context,
                                                    widget.deal.id,
                                                    widget.deal.dealValue,
                                                  );
                                                }
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(
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
                                                      BorderRadius.circular(
                                                          8.r),
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
                                    ),

                                  // مسافة بين الكود والرابط لو الاثنين موجودين
                                  if (showCode && showLink)
                                    SizedBox(height: 12.h),

                                  // === رابط العرض ===
                                  if (showLink)
                                    Container(
                                      height: 60.h,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: widget.deal.dealType == 'both'
                                            ? const Color(0xFF2C2C2E)
                                            : AppTheme.kElectricLime,
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                        border: widget.deal.dealType == 'both'
                                            ? Border.all(
                                                color: AppTheme.kElectricLime
                                                    .withValues(alpha: 0.5),
                                                width: 1.5,
                                              )
                                            : null,
                                        boxShadow: [
                                          BoxShadow(
                                            color: widget.deal.dealType ==
                                                    'both'
                                                ? Colors.black.withValues(
                                                    alpha: 0.2)
                                                : AppTheme.kElectricLime
                                                    .withValues(alpha: 0.3),
                                            blurRadius: 15.w,
                                            offset: Offset(0, 4.h),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            final isGuest = context
                                                .read<AuthViewModel>()
                                                .isGuestMode;
                                            if (isGuest) {
                                              _showGuestSnackBar(
                                                context,
                                                'سجّل دخولك للوصول لرابط العرض',
                                              );
                                            } else {
                                              // في حالة both الرابط يكون في linkUrl، في حالة link يكون في dealValue
                                              final url =
                                                  widget.deal.dealType ==
                                                          'both'
                                                      ? (widget.deal.linkUrl ??
                                                          '')
                                                      : widget
                                                          .deal.dealValue;
                                              viewModel.openDealLink(
                                                widget.deal.id,
                                                url,
                                              );
                                            }
                                          },
                                          borderRadius:
                                              BorderRadius.circular(16.r),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'اذهب للعرض',
                                                style: TextStyle(
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: widget.deal
                                                              .dealType ==
                                                          'both'
                                                      ? AppTheme.kElectricLime
                                                      : Colors.black,
                                                ),
                                              ),
                                              SizedBox(width: 10.w),
                                              Icon(
                                                Icons.open_in_new,
                                                size: 22.w,
                                                color: widget.deal
                                                            .dealType ==
                                                        'both'
                                                    ? AppTheme.kElectricLime
                                                    : Colors.black,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
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
    );
  }

  Widget _buildImageCarousel(DealDetailsViewModel viewModel) {
    final images = _allImages;
    if (images.isEmpty) {
      return Container(
        height: 250.h,
        color: Colors.grey[800],
        child: const Icon(Icons.image_not_supported, color: Colors.white54),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(16.r),
        bottomRight: Radius.circular(16.r),
      ),
      child: SizedBox(
        height: 250.h,
        child: Stack(
          children: [
            // PageView
            PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => viewModel.incrementImageClick(widget.deal.id),
                  child: CachedNetworkImage(
                    imageUrl: images[index],
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
                );
              },
            ),

            // Left arrow
            if (_hasMultipleImages)
              Positioned(
                left: 8.w,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      final prevPage = (_currentPage - 1 + images.length) % images.length;
                      _goToPage(prevPage);
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 18.w,
                      ),
                    ),
                  ),
                ),
              ),

            // Right arrow
            if (_hasMultipleImages)
              Positioned(
                right: 8.w,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      final nextPage = (_currentPage + 1) % images.length;
                      _goToPage(nextPage);
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 18.w,
                      ),
                    ),
                  ),
                ),
              ),

            // Page indicator dots
            if (_hasMultipleImages)
              Positioned(
                bottom: 12.h,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (index) {
                    final isActive = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      width: isActive ? 24.w : 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppTheme.kElectricLime
                            : Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveEmoji(
    BuildContext context,
    DealDetailsViewModel viewModel,
    int dealId,
    String emoji,
    String emojiType,
    String label,
    Color color,
    String percentage,
  ) {
    final isSelected = viewModel.userSelectedEmoji == emojiType;

    return GestureDetector(
      onTap: () async {
        final success = await viewModel.submitEmojiFeedback(dealId, emojiType);
        if (context.mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('شكراً لتقييمك! $emoji'),
                duration: const Duration(seconds: 2),
                backgroundColor: color,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('يجب تسجيل الدخول للتقييم'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? color : Colors.white10,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: 32.sp)),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey[400],
                fontSize: 11.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              percentage,
              style: TextStyle(
                color: color,
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGuestSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.white, size: 20.w),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 13.sp, color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.kElectricLime,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: Text(
                'تسجيل الدخول',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.kDarkBackground,
        elevation: 6,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(
            color: AppTheme.kElectricLime.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
    );
  }
}
