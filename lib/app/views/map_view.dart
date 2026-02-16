import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../viewmodels/map_view_model.dart';
import 'company_profile_view.dart';

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
          if (vm.isLoading && vm.markers.isEmpty) {
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
                    GoogleMap(
                      initialCameraPosition: vm.initialCameraPosition,
                      markers: vm.markers.values.toSet(),
                      zoomControlsEnabled: false,
                      myLocationEnabled: vm.hasLocation,
                      myLocationButtonEnabled: false,
                      compassEnabled: true,
                      onTap: (_) => vm.clearSelection(),
                      onCameraMove: vm.onCameraMove,
                      onMapCreated: (controller) =>
                          vm.setMapController(controller),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Column(
                        children: [
                          _MapIconButton(
                            icon: Icons.my_location,
                            label: 'موقعي',
                            isActive: vm.hasLocation,
                            onTap: () {
                              vm.centerOnUser();
                            },
                          ),
                          const SizedBox(height: 8),
                          _MapIconButton(
                            icon: Icons.local_fire_department,
                            label: 'العروض القريبة',
                            isActive: vm.nearbyOnly,
                            onTap: () {
                              vm.toggleNearby();
                            },
                          ),
                          const SizedBox(height: 8),
                          _MapIconButton(
                            icon: Icons.refresh,
                            label: 'إعادة التمركز',
                            onTap: () {
                              vm.disableNearbyMode();
                            },
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
                  ],
                ),
              ),
              _SelectedCompanyCard(viewModel: vm),
            ],
          );
        },
      ),
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
            ...viewModel.categories.map(
              (c) => Padding(
                padding: EdgeInsets.only(right: 6.w),
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
          borderRadius: BorderRadius.circular(28),
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
              size: 22,
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
  const _SelectedCompanyCard({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final company = viewModel.selectedCompany;
    if (company == null) {
      return SizedBox(height: 10.h);
    }

    final discount = viewModel.discountLabelFor(company.id);
    final distance = viewModel.distanceKmFor(company);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: const BoxDecoration(
        color: AppTheme.kLightBackground,
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: company.logoUrl != null && company.logoUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.network(company.logoUrl!, fit: BoxFit.cover),
                  )
                : const Icon(Icons.store, color: Colors.grey),
          ),
          SizedBox(width: 12.w),
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
                if (company.categoryName != null)
                  Text(
                    company.categoryName!,
                    style: TextStyle(color: Colors.white60, fontSize: 12.sp),
                  ),
                if (distance != null)
                  Text(
                    '${distance.toStringAsFixed(1)} كم من موقعك',
                    style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                  ),
                if (discount.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 4.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      discount,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CompanyProfileView(companyId: company.id),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              backgroundColor: AppTheme.kElectricLime,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text('عرض العروض', style: TextStyle(fontSize: 13.sp)),
          ),
        ],
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
