import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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

  Future<void> _openGoogleMaps(double lat, double lng) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح خرائط جوجل')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = DealDetailsViewModel();
        vm.incrementDealViews(widget.deal.id);
        vm.loadCompanyData(widget.deal.companyId, widget.deal.id);
        return vm;
      },
      child: Consumer<DealDetailsViewModel>(
        builder: (context, viewModel, _) {
          return DefaultTabController(
            length: 4,
            child: Scaffold(
              backgroundColor: AppTheme.kDarkBackground,
              body: RefreshIndicator(
                onRefresh: () => viewModel.loadCompanyData(
                  widget.deal.companyId,
                  widget.deal.id,
                ),
                color: AppTheme.kElectricLime,
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      // Transparent standard AppBar
                      SliverAppBar(
                        backgroundColor: AppTheme.kDarkBackground,
                        elevation: 0,
                        floating: true,
                        pinned: false,
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      // Image Carousel
                      SliverToBoxAdapter(
                        child: _buildImageCarousel(viewModel),
                      ),
                      // Header Info (Title, Rating, Expiry)
                      SliverToBoxAdapter(
                        child: _buildHeaderInfo(context, viewModel),
                      ),
                      // Sticky TabBar
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverAppBarDelegate(
                          TabBar(
                            isScrollable: true,
                            tabAlignment: TabAlignment.start,
                            indicatorColor: AppTheme.kElectricLime,
                            labelColor: AppTheme.kElectricLime,
                            unselectedLabelColor: Colors.grey,
                            indicatorWeight: 3,
                            labelStyle: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14.sp),
                            unselectedLabelStyle: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 14.sp),
                            tabs: const [
                              Tab(text: 'محتويات العرض'),
                              Tab(text: 'الفروع'),
                              Tab(text: 'الشروط والأحكام'),
                              Tab(text: 'معلومات التاجر'),
                            ],
                          ),
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    children: [
                      _buildDealContentsTab(context, viewModel),
                      _buildBranchesTab(context, viewModel),
                      _buildTermsTab(context),
                      _buildMerchantInfoTab(context, viewModel),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context, DealDetailsViewModel viewModel) {
    final formattedDate = intl.DateFormat('dd-MM-yyyy').format(widget.deal.expiresAt);
    final ratingValue = (viewModel.calculatedSuccessRate / 20).toStringAsFixed(1);

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Flags / Tags
          if (widget.deal.isForStudents || widget.deal.discountValue.isNotEmpty)
            Row(
              children: [
                if (widget.deal.discountValue.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.r),
                        bottomRight: Radius.circular(8.r),
                        bottomLeft: Radius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      widget.deal.discountValue,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                const Spacer(),
                if (widget.deal.isForStudents)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: AppTheme.kElectricLime.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppTheme.kElectricLime, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.school, size: 10.w, color: AppTheme.kElectricLime),
                        SizedBox(width: 4.w),
                        Text(
                          'للطلاب',
                          style: TextStyle(
                            color: AppTheme.kElectricLime,
                            fontWeight: FontWeight.bold,
                            fontSize: 9.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          SizedBox(height: 12.h),

          // Company Name & Partner Badge
          Row(
            children: [
              Flexible(
                child: Text(
                  widget.deal.companyName ?? 'متجر غير معروف',
                  style: TextStyle(
                    color: AppTheme.kElectricLime,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (widget.deal.companyIsPartner) ...[
                SizedBox(width: 4.w),
                Icon(
                  Icons.verified,
                  color: AppTheme.kElectricLime,
                  size: 16.sp,
                ),
              ],
            ],
          ),
          SizedBox(height: 4.h),

          // Deal Title
          Text(
            widget.deal.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          SizedBox(height: 12.h),

          // Rating and Expiry Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.timer_outlined, color: Colors.redAccent, size: 16.w),
                  SizedBox(width: 6.w),
                  Text(
                    'ينتهي في: $formattedDate',
                    style: TextStyle(
                      color: Colors.redAccent[100],
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.star_rounded, color: Colors.amber, size: 20.w),
                  SizedBox(width: 4.w),
                  Text(
                    ratingValue,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '(${viewModel.totalEmojiCount} تقييم)',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildDealContentsTab(BuildContext context, DealDetailsViewModel viewModel) {
    final showCode = widget.deal.dealType == 'code' || widget.deal.dealType == 'both';
    final showLink = widget.deal.dealType == 'link' || widget.deal.dealType == 'both';

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coupon-style Card
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppTheme.kDarkBackground,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppTheme.kElectricLime.withValues(alpha: 0.5),
                width: 2,
              ),
              // Optional: Add dashed effect custom painter later if strictly needed,
              // for now the bright border fits the "coupon" vibe in dark mode perfectly.
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تفاصيل العرض:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  widget.deal.description,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14.sp,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 24.h),
                
                // Code / Link Actions
                if (showCode) ...[
                  Text(
                    'كود الخصم',
                    style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    height: 55.h,
                    decoration: BoxDecoration(
                      color: AppTheme.kElectricLime.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppTheme.kElectricLime),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.deal.dealValue,
                          style: TextStyle(
                            color: AppTheme.kElectricLime,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            final isGuest = context.read<AuthViewModel>().isGuestMode;
                            if (isGuest) {
                              _showGuestSnackBar(context, 'سجّل دخولك لنسخ كود الخصم');
                            } else {
                              viewModel.copyCode(context, widget.deal.id, widget.deal.dealValue);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: AppTheme.kElectricLime,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'نسخ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Icon(Icons.copy, size: 14.w, color: Colors.black),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showLink) SizedBox(height: 16.h),
                ],
                
                if (showLink) ...[
                  Text(
                    'رابط العرض',
                    style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                  ),
                  SizedBox(height: 6.h),
                  InkWell(
                    onTap: () {
                      final isGuest = context.read<AuthViewModel>().isGuestMode;
                      if (isGuest) {
                        _showGuestSnackBar(context, 'سجّل دخولك للوصول لرابط العرض');
                      } else {
                        final url = widget.deal.dealType == 'both'
                            ? (widget.deal.linkUrl ?? '')
                            : widget.deal.dealValue;
                        viewModel.openDealLink(widget.deal.id, url);
                      }
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      height: 55.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.kElectricLime,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.kElectricLime.withValues(alpha: 0.3),
                            blurRadius: 10.w,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'اذهب للعرض',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(Icons.open_in_new, size: 20.w, color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          SizedBox(height: 24.h),

          // Shared Stats / Success block (Original Visual)
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.kElectricLime.withValues(alpha: 0.1),
                  AppTheme.kElectricLime.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppTheme.kElectricLime.withValues(alpha: 0.3),
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
                    borderRadius: BorderRadius.circular(12.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final rating = (viewModel.calculatedSuccessRate / 100) * 5;
                          final bool isFull = rating >= (index + 1);
                          final bool isHalf = rating > index && rating < (index + 1);

                          return Icon(
                            isFull
                                ? Icons.star_rounded
                                : (isHalf
                                      ? Icons.star_half_rounded
                                      : Icons.star_border_rounded),
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
          ),
          
          SizedBox(height: 24.h),

          // Rating UI (Emojis)
          Container(
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
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInteractiveEmoji(
                      context, viewModel, widget.deal.id, '😊', 'happy', 'ممتاز',
                      Colors.green,
                      viewModel.totalEmojiCount > 0 ? '${viewModel.emotionalHappy.toStringAsFixed(0)}%' : '-',
                    ),
                    _buildInteractiveEmoji(
                      context, viewModel, widget.deal.id, '😐', 'neutral', 'عادي',
                      Colors.orange,
                      viewModel.totalEmojiCount > 0 ? '${viewModel.emotionalNeutral.toStringAsFixed(0)}%' : '-',
                    ),
                    _buildInteractiveEmoji(
                      context, viewModel, widget.deal.id, '😞', 'sad', 'سيء',
                      Colors.red,
                      viewModel.totalEmojiCount > 0 ? '${viewModel.emotionalSad.toStringAsFixed(0)}%' : '-',
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildBranchesTab(BuildContext context, DealDetailsViewModel viewModel) {
    if (viewModel.isLoadingCompany) {
      return Center(
        child: CircularProgressIndicator(color: AppTheme.kElectricLime),
      );
    }
    
    final groupedBranches = viewModel.getBranchesGroupedByCity();

    if (groupedBranches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_outlined, size: 64.w, color: Colors.white24),
            SizedBox(height: 16.h),
            Text(
              'لا توجد فروع مسجلة لهذا التاجر حالياً',
              style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: groupedBranches.length,
      itemBuilder: (context, index) {
        final cityName = groupedBranches.keys.elementAt(index);
        final cityBranches = groupedBranches[cityName]!;

        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.white10),
            ),
            child: ExpansionTile(
              initiallyExpanded: true,
              iconColor: AppTheme.kElectricLime,
              collapsedIconColor: Colors.white54,
              title: Row(
                children: [
                  Icon(Icons.location_city, color: AppTheme.kElectricLime, size: 20.w),
                  SizedBox(width: 8.w),
                  Text(
                    cityName,
                    style: TextStyle(
                      color: AppTheme.kElectricLime,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              children: cityBranches.map((loc) {
                final double lat = (loc['lat'] as num?)?.toDouble() ?? 0.0;
                final double lng = (loc['lng'] as num?)?.toDouble() ?? 0.0;
                final bool hasCoords = lat != 0 && lng != 0;

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: loc['isMain'] == true 
                          ? AppTheme.kElectricLime.withAlpha(77)
                          : Colors.white10,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            loc['isMain'] == true ? Icons.home_work : Icons.location_on, 
                            color: AppTheme.kElectricLime, 
                            size: 20.w
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              loc['name'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (hasCoords)
                            IconButton(
                              icon: const Icon(Icons.directions, color: AppTheme.kElectricLime),
                              tooltip: 'الاتجاهات',
                              onPressed: () => _openGoogleMaps(lat, lng),
                            ),
                        ],
                      ),
                      if (loc['address'] != null && loc['address'].isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          loc['address'],
                          style: TextStyle(color: Colors.grey[400], fontSize: 13.sp),
                        ),
                      ],
                      if (loc['phone'] != null && loc['phone'].isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(Icons.phone, color: Colors.grey, size: 16.w),
                            SizedBox(width: 6.w),
                            Text(
                              loc['phone'],
                              style: TextStyle(color: Colors.grey[300], fontSize: 13.sp),
                            ),
                          ],
                        ),
                      ],
                      if (hasCoords) ...[
                        SizedBox(height: 12.h),
                        InkWell(
                          onTap: () => _openGoogleMaps(lat, lng),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: AppTheme.kElectricLime.withAlpha(25),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: AppTheme.kElectricLime.withAlpha(51)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.map, size: 16, color: AppTheme.kElectricLime),
                                SizedBox(width: 8.w),
                                Text(
                                  'فتح في خرائط جوجل',
                                  style: TextStyle(
                                    color: AppTheme.kElectricLime,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTermsTab(BuildContext context) {
    if (widget.deal.termsConditions.isEmpty) {
      return Center(
        child: Text(
          'لا توجد شروط وأحكام خاصة بهذا العرض',
          style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, color: AppTheme.kElectricLime, size: 24.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                widget.deal.termsConditions,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14.sp,
                  height: 1.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMerchantInfoTab(BuildContext context, DealDetailsViewModel viewModel) {
    final companyLogo = widget.deal.companyLogo;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompanyProfileView(companyId: widget.deal.companyId),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.white10),
          ),
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: AppTheme.kElectricLime,
                  shape: BoxShape.circle,
                ),
                child: companyLogo != null
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: companyLogo,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.black87,
                          ),
                          errorWidget: (context, url, err) => Icon(
                            Icons.store, color: Colors.black87, size: 28.w,
                          ),
                        ),
                      )
                    : Icon(Icons.store, color: Colors.black87, size: 28.w),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.deal.companyName ?? 'متجر',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (widget.deal.companyIsPartner) ...[
                          SizedBox(width: 6.w),
                          Icon(
                            Icons.verified,
                            color: AppTheme.kElectricLime,
                            size: 20.sp,
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'اضغط لعرض الملف للمتجر، أوقات العمل والمزيد...',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.kElectricLime, size: 28.w),
            ],
          ),
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

    return Container(
      color: AppTheme.kDarkBackground,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
        child: SizedBox(
          height: 250.h,
          child: Stack(
            children: [
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
                      fit: BoxFit.cover,
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
                        child: const Icon(Icons.error, color: Colors.white54),
                      ),
                    ),
                  );
                },
              ),
              if (_hasMultipleImages)
                Positioned(
                  left: 12.w,
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
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16.w),
                      ),
                    ),
                  ),
                ),
              if (_hasMultipleImages)
                Positioned(
                  right: 12.w,
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
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16.w),
                      ),
                    ),
                  ),
                ),
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
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: isActive ? 24.w : 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          color: isActive ? AppTheme.kElectricLime : Colors.white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveEmoji(
    BuildContext context, DealDetailsViewModel viewModel, int dealId, String emoji, String emojiType, String label, Color color, String percentage,
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
            Text(emoji, style: TextStyle(fontSize: 28.sp)),
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
                fontSize: 12.sp,
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
              child: Text(message, style: TextStyle(fontSize: 13.sp, color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.kElectricLime,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              child: Text('تسجيل الدخول', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
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
          side: BorderSide(color: AppTheme.kElectricLime.withValues(alpha: 0.3), width: 1),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height + 1.h; // +1 for the bottom border
  @override
  double get maxExtent => _tabBar.preferredSize.height + 1.h;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.kDarkBackground,
      child: Column(
        children: [
          _tabBar,
          Container(
            height: 1.h,
            color: Colors.white10, // Bottom border for TabBar
          )
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
