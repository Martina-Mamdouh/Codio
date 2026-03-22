import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/company_model.dart';
import '../../core/models/deal_model.dart';
import '../../core/theme/app_theme.dart';
import '../viewmodels/map_view_model.dart';
import 'company_profile_view.dart';
import 'deal_details_view.dart';

class MapView extends StatefulWidget {
  final bool startNearby;
  const MapView({super.key, this.startNearby = false});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapViewModel>().init(focusNearby: widget.startNearby);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kDarkBackground,
      appBar: AppBar(
        title: const Text('الخريطة والعروض القريبة'),
        backgroundColor: AppTheme.kDarkBackground,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              context.read<MapViewModel>().refresh();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<MapViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && !vm.hasLoaded) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.kElectricLime),
            );
          }

          if (vm.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 42,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    vm.errorMessage!,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: vm.refresh,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _CategoryFilterRow(viewModel: vm),
              Expanded(
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: vm.mapController,
                      options: MapOptions(
                        initialCenter: vm.initialCenter,
                        initialZoom: vm.initialZoom,
                        onPositionChanged: vm.onPositionChanged,
                        onTap: (_, __) => vm.clearSelection(),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.kodio.app',
                        ),
                        // User location marker
                        if (vm.hasLocation)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(
                                  vm.userPosition!.latitude,
                                  vm.userPosition!.longitude,
                                ),
                                width: 24,
                                height: 24,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        // Company markers
                        MarkerLayer(markers: _buildCompanyMarkers(vm)),
                      ],
                    ),
                    // Control buttons
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Column(
                        children: [
                          _MapIconButton(
                            icon: Icons.my_location,
                            label: 'موقعي',
                            isActive: vm.hasLocation,
                            onTap: () => vm.centerOnUser(),
                          ),
                          const SizedBox(height: 8),
                          _MapIconButton(
                            icon: Icons.local_fire_department,
                            label: 'العروض القريبة',
                            isActive: vm.nearbyOnly,
                            onTap: () => vm.toggleNearby(),
                          ),
                          const SizedBox(height: 8),
                          _MapIconButton(
                            icon: Icons.refresh,
                            label: 'إعادة التمركز',
                            onTap: () => vm.disableNearbyMode(),
                          ),
                        ],
                      ),
                    ),
                    if (vm.locationError != null)
                      Positioned(
                        left: 16,
                        right: 16,
                        top: 12,
                        child: _InfoBanner(text: vm.locationError!),
                      ),
                    if (vm.isLocationLoading)
                      Positioned(
                        left: 16,
                        right: 16,
                        top: 12,
                        child: _InfoBanner(text: 'جاري تحديد موقعك...'),
                      ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SafeArea(
                        top: false,
                        minimum: EdgeInsets.zero,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 520),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            final curved = CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            );
                            final offset = Tween<Offset>(
                              begin: const Offset(0, 0.22),
                              end: Offset.zero,
                            ).animate(curved);
                            final scale = Tween<double>(
                              begin: 0.97,
                              end: 1,
                            ).animate(curved);
                            return SlideTransition(
                              position: offset,
                              child: FadeTransition(
                                opacity: curved,
                                child: ScaleTransition(
                                  scale: scale,
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: AnimatedSize(
                            key: ValueKey(vm.selectedCompany?.id ?? -1),
                            duration: const Duration(milliseconds: 340),
                            curve: Curves.easeOutCubic,
                            alignment: Alignment.bottomCenter,
                            child: _SelectedCompanyCard(
                              viewModel: vm,
                              onClose: vm.clearSelection,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Marker> _buildCompanyMarkers(MapViewModel vm) {
    return vm.filteredCompanies.where((c) => c.lat != 0 && c.lng != 0).map((
      company,
    ) {
      final discount = vm.discountLabelFor(company.id);
      final isSelected = vm.selectedCompany?.id == company.id;

      return Marker(
        point: LatLng(company.lat, company.lng),
        width: discount.isNotEmpty ? 128 : 56,
        height: discount.isNotEmpty ? 126 : 56,
        child: GestureDetector(
          onTap: () => vm.selectCompany(company),
          child: _CompanyMarkerWidget(
            company: company,
            discount: discount,
            isSelected: isSelected,
          ),
        ),
      );
    }).toList();
  }
}

class _CompanyMarkerWidget extends StatelessWidget {
  final CompanyModel company;
  final String discount;
  final bool isSelected;

  const _CompanyMarkerWidget({
    required this.company,
    required this.discount,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (discount.isNotEmpty)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 118),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                discount,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.visible,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        const SizedBox(height: 2),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: isSelected ? AppTheme.kElectricLime : Colors.white,
              width: isSelected ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppTheme.kElectricLime.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.4),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipOval(
            child: company.logoUrl != null && company.logoUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: company.logoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        const Icon(Icons.store, color: Colors.grey, size: 24),
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.store, color: Colors.grey, size: 24),
                  )
                : const Icon(Icons.store, color: Colors.grey, size: 24),
          ),
        ),
      ],
    );
  }
}

class _CategoryFilterRow extends StatelessWidget {
  final MapViewModel viewModel;
  const _CategoryFilterRow({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppTheme.kLightBackground,
        border: const Border(bottom: BorderSide(color: Colors.white10)),
      ),
      height: 72.h,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _CategoryChip(
              label: 'الكل',
              selected: viewModel.selectedCategoryIds.isEmpty,
              onTap: () async {
                await viewModel.clearFilters();
              },
            ),
            Padding(padding: EdgeInsetsDirectional.only(end: 6.w)),
            ...viewModel.categories.map(
              (c) => Padding(
                padding: EdgeInsetsDirectional.only(end: 6.w),
                child: _CategoryChip(
                  label: c.name,
                  selected: viewModel.selectedCategoryIds.contains(c.id),
                  onTap: () => viewModel.toggleCategory(c.id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(color: selected ? Colors.black : Colors.white),
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.kElectricLime,
      backgroundColor: Colors.white12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    );
  }
}

class _MapIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _MapIconButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(42),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.kElectricLime
                  : Colors.black.withValues(alpha: 0.7),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.black : Colors.white,
              size: 33,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SelectedCompanyCard extends StatefulWidget {
  final MapViewModel viewModel;
  final VoidCallback onClose;

  const _SelectedCompanyCard({
    required this.viewModel,
    required this.onClose,
  });

  @override
  State<_SelectedCompanyCard> createState() => _SelectedCompanyCardState();
}

class _SelectedCompanyCardState extends State<_SelectedCompanyCard> {
  static const double _dismissDragThreshold = 80;
  double _dragOffsetY = 0;
  bool _isDraggingHandle = false;
  bool _isClosingByDrag = false;

  void _handleDragStart(DragStartDetails details) {
    _isDraggingHandle = true;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_isClosingByDrag) return;
    final delta = details.primaryDelta ?? 0;
    if (delta == 0) return;

    setState(() {
      final nextOffset = _dragOffsetY + delta;
      _dragOffsetY = nextOffset.clamp(0.0, 320.0);
    });
  }

  Future<void> _animateDismissDown() async {
    if (_isClosingByDrag) return;
    _isClosingByDrag = true;
    _isDraggingHandle = false;

    setState(() {
      _dragOffsetY = MediaQuery.sizeOf(context).height * 0.82;
    });

    await Future.delayed(const Duration(milliseconds: 260));
    if (mounted) {
      widget.onClose();
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_isClosingByDrag) return;
    _isDraggingHandle = false;

    final shouldDismiss =
        _dragOffsetY >= _dismissDragThreshold ||
        (details.primaryVelocity ?? 0) > 800;

    if (shouldDismiss) {
      _animateDismissDown();
      return;
    }

    setState(() {
      _dragOffsetY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final company = widget.viewModel.selectedCompany;
    if (company == null) {
      return const SizedBox.shrink();
    }

    final distance = widget.viewModel.distanceKmFor(company);
    final companyDeals = widget.viewModel.dealsForCompany(company.id);
    final hasPhone = (company.phone ?? '').isNotEmpty;
    final hasAddress = (company.address ?? '').isNotEmpty;
    final hasWorkingHours = (company.workingHours ?? '').isNotEmpty;

    String? heroImageUrl;
    for (final deal in companyDeals) {
      if (deal.imageUrl.isNotEmpty) {
        heroImageUrl = deal.imageUrl;
        break;
      }
    }

    final panelMaxHeight = MediaQuery.sizeOf(context).height * 0.72;

    return AnimatedContainer(
      duration: _isDraggingHandle
          ? Duration.zero
          : const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(0, _dragOffsetY, 0),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: panelMaxHeight,
          minHeight: 260.h,
        ),
        decoration: BoxDecoration(
          color: AppTheme.kLightBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(26.r),
            topRight: Radius.circular(26.r),
          ),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(26.r),
            topRight: Radius.circular(26.r),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 14.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragStart: _handleDragStart,
                    onVerticalDragUpdate: _handleDragUpdate,
                    onVerticalDragEnd: _handleDragEnd,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Container(
                        width: 42.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        company.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: widget.onClose,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: SizedBox(
                    height: 170.h,
                    width: double.infinity,
                    child: heroImageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: heroImageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: Colors.white10,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.kElectricLime,
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.white10,
                              child: const Center(
                                child: Icon(
                                  Icons.store_mall_directory,
                                  color: Colors.white30,
                                  size: 42,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.white10,
                            child: const Center(
                              child: Icon(
                                Icons.store_mall_directory,
                                color: Colors.white30,
                                size: 42,
                              ),
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white12),
                      ),
                      child: ClipOval(
                        child:
                            company.logoUrl != null &&
                                company.logoUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: company.logoUrl!,
                                fit: BoxFit.cover,
                                placeholder: (_, __) =>
                                    const Icon(Icons.store, color: Colors.grey),
                                errorWidget: (_, __, ___) =>
                                    const Icon(Icons.store, color: Colors.grey),
                              )
                            : const Icon(Icons.store, color: Colors.grey),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            company.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              if (company.categoryName != null)
                                Flexible(
                                  child: Text(
                                    company.categoryName!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ),
                              if (company.categoryName != null &&
                                  distance != null)
                                Text(
                                  '  •  ',
                                  style: TextStyle(
                                    color: Colors.white24,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              if (distance != null)
                                Text(
                                  '${distance.toStringAsFixed(1)} كم',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11.sp,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (hasAddress || hasWorkingHours)
                  Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        if (hasAddress)
                          _InfoPill(
                            icon: Icons.location_on_outlined,
                            text: company.address!,
                          ),
                        if (hasWorkingHours)
                          _InfoPill(
                            icon: Icons.access_time_rounded,
                            text: company.workingHours!,
                          ),
                      ],
                    ),
                  ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'العروض المتاحة',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                    Text(
                      '${companyDeals.length}',
                      style: TextStyle(
                        color: AppTheme.kElectricLime,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                if (companyDeals.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Text(
                      'لا توجد عروض حالياً',
                      style: TextStyle(color: Colors.white38, fontSize: 12.sp),
                    ),
                  )
                else
                  ListView.separated(
                    itemCount: companyDeals.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => SizedBox(height: 8.h),
                    itemBuilder: (context, index) {
                      final deal = companyDeals[index];
                      return _DealListTile(
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
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CompanyProfileView(companyId: company.id),
                            ),
                          );
                        },
                        icon: const Icon(Icons.storefront, size: 18),
                        label: const Text('صفحة الشركة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.kElectricLime,
                          foregroundColor: Colors.black,
                          minimumSize: Size(double.infinity, 44.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                    if (hasPhone) ...[
                      SizedBox(width: 10.w),
                      OutlinedButton.icon(
                        onPressed: () {
                          final uri = Uri(
                            scheme: 'tel',
                            path: company.phone!.trim(),
                          );
                          launchUrl(uri, mode: LaunchMode.externalApplication);
                        },
                        icon: const Icon(Icons.phone, size: 18),
                        label: const Text('اتصال'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: BorderSide(
                            color: Colors.green.withValues(alpha: 0.45),
                          ),
                          minimumSize: Size(118.w, 44.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 0.85.sw),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.kElectricLime, size: 14.w),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white60, fontSize: 11.sp),
            ),
          ),
        ],
      ),
    );
  }
}

class _DealListTile extends StatelessWidget {
  final DealModel deal;
  final VoidCallback onTap;

  const _DealListTile({required this.deal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final discount = deal.discountValue.isNotEmpty
        ? deal.discountValue
        : deal.dealValue;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: SizedBox(
                width: 72.w,
                height: 72.w,
                child: deal.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: deal.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: Colors.white10),
                        errorWidget: (_, __, ___) => Container(
                          color: Colors.white10,
                          child: const Icon(
                            Icons.local_offer,
                            color: Colors.white30,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.white10,
                        child: const Icon(
                          Icons.local_offer,
                          color: Colors.white30,
                        ),
                      ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  if (discount.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        discount,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.orangeAccent.shade100,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 6.w),
            Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14.w),
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String text;
  const _InfoBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
