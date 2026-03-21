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
import 'widgets/deal_card.dart';

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
                                        color: Colors.blue.withOpacity(0.4),
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
                  ],
                ),
              ),
              SafeArea(
                bottom: true,
                maintainBottomViewPadding: true,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final offset =
                        Tween<Offset>(
                          begin: const Offset(0, 0.08),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        );
                    return SlideTransition(
                      position: offset,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    child: _SelectedCompanyCard(
                      key: ValueKey(vm.selectedCompany?.id ?? -1),
                      viewModel: vm,
                    ),
                  ),
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
        width: 56,
        height: discount.isNotEmpty ? 72 : 56,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              discount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
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
                    ? AppTheme.kElectricLime.withOpacity(0.5)
                    : Colors.black.withOpacity(0.4),
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
                  : Colors.black.withOpacity(0.7),
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

class _SelectedCompanyCard extends StatelessWidget {
  final MapViewModel viewModel;
  const _SelectedCompanyCard({Key? key, required this.viewModel})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final company = viewModel.selectedCompany;
    if (company == null) {
      return SizedBox(height: 10.h);
    }

    final distance = viewModel.distanceKmFor(company);
    final companyDeals = viewModel.dealsForCompany(company.id);
    final hasPhone = (company.phone ?? '').isNotEmpty;
    final hasAddress = (company.address ?? '').isNotEmpty;
    final hasWorkingHours = (company.workingHours ?? '').isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppTheme.kLightBackground,
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Company header
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: company.logoUrl != null && company.logoUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: CachedNetworkImage(
                            imageUrl: company.logoUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                const Icon(Icons.store, color: Colors.grey),
                            errorWidget: (_, __, ___) =>
                                const Icon(Icons.store, color: Colors.grey),
                          ),
                        )
                      : const Icon(Icons.store, color: Colors.grey),
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
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                      ),
                      Row(
                        children: [
                          if (company.categoryName != null)
                            Text(
                              company.categoryName!,
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 11.sp,
                              ),
                            ),
                          if (company.categoryName != null && distance != null)
                            Text(
                              ' · ',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 11.sp,
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
                // Call button
                if (hasPhone)
                  Padding(
                    padding: EdgeInsetsDirectional.only(end: 4.w),
                    child: InkWell(
                      onTap: () {
                        final uri = Uri(
                          scheme: 'tel',
                          path: company.phone!.trim(),
                        );
                        launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.green.withOpacity(0.4),
                          ),
                        ),
                        child: Icon(
                          Icons.phone,
                          color: Colors.green,
                          size: 20.w,
                        ),
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CompanyProfileView(companyId: company.id),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.kElectricLime,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                  ),
                  child: Text('صفحة الشركة', style: TextStyle(fontSize: 12.sp)),
                ),
              ],
            ),
          ),
          // Quick info row (address, working hours)
          if (hasAddress || hasWorkingHours)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
              child: Row(
                children: [
                  if (hasAddress) ...[
                    Icon(
                      Icons.location_on_outlined,
                      color: AppTheme.kElectricLime,
                      size: 14.w,
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        company.address!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                  ],
                  if (hasAddress && hasWorkingHours)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Text(
                        '·',
                        style: TextStyle(
                          color: Colors.white24,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                  if (hasWorkingHours) ...[
                    Icon(
                      Icons.access_time_rounded,
                      color: AppTheme.kElectricLime,
                      size: 14.w,
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        company.workingHours!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          // Deals list
          if (companyDeals.isEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Text(
                'لا توجد عروض حالياً',
                style: TextStyle(color: Colors.white38, fontSize: 12.sp),
              ),
            )
          else
            SizedBox(
              height: 230.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                itemCount: companyDeals.length,
                separatorBuilder: (_, __) => SizedBox(width: 10.w),
                itemBuilder: (context, index) {
                  final deal = companyDeals[index];
                  return SizedBox(
                    width: 220.w,
                    child: DealCard(
                      deal: deal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DealDetailsView(deal: deal),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _DealMiniCard extends StatelessWidget {
  final DealModel deal;
  const _DealMiniCard({required this.deal});

  @override
  Widget build(BuildContext context) {
    final discount = deal.discountValue.isNotEmpty
        ? deal.discountValue
        : deal.dealValue;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DealDetailsView(deal: deal)),
        );
      },
      child: Container(
        width: 180.w,
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: AppTheme.kDarkBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deal image + discount badge
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: deal.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: deal.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: Colors.white10,
                              child: const Center(
                                child: Icon(
                                  Icons.local_offer,
                                  color: Colors.white24,
                                  size: 24,
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.white10,
                              child: const Center(
                                child: Icon(
                                  Icons.local_offer,
                                  color: Colors.white24,
                                  size: 24,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.white10,
                            child: const Center(
                              child: Icon(
                                Icons.local_offer,
                                color: Colors.white24,
                                size: 24,
                              ),
                            ),
                          ),
                  ),
                  if (discount.isNotEmpty)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          discount,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 6.h),
            // Deal title
            Text(
              deal.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
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
        color: Colors.black.withOpacity(0.75),
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
