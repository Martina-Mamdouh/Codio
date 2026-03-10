import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../viewmodels/map_view_model.dart';
import '../map_view.dart';

class MiniMapWidget extends StatefulWidget {
  final bool focusNearby;
  const MiniMapWidget({super.key, this.focusNearby = true});

  @override
  State<MiniMapWidget> createState() => _MiniMapWidgetState();
}

class _MiniMapWidgetState extends State<MiniMapWidget> {
  final MapController _miniMapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapViewModel>().init(focusNearby: widget.focusNearby);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220.h,
      child: Consumer<MapViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && !vm.hasLoaded) {
            return Container(
              height: 220.h,
              decoration: BoxDecoration(
                color: AppTheme.kLightBackground,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: const Center(
                child:
                    CircularProgressIndicator(color: AppTheme.kElectricLime),
              ),
            );
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _miniMapController,
                  options: MapOptions(
                    initialCenter: vm.initialCenter,
                    initialZoom: vm.initialZoom,
                    onPositionChanged: vm.onPositionChanged,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
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
                            width: 18,
                            height: 18,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    // Company markers
                    MarkerLayer(
                      markers: vm.filteredCompanies
                          .where((c) => c.lat != 0 && c.lng != 0)
                          .map((company) {
                        return Marker(
                          point: LatLng(company.lat, company.lng),
                          width: 36,
                          height: 36,
                          child: GestureDetector(
                            onTap: () => vm.selectCompany(company),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: company.logoUrl != null &&
                                        company.logoUrl!.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: company.logoUrl!,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) => const Icon(
                                          Icons.store,
                                          color: Colors.grey,
                                          size: 16,
                                        ),
                                        errorWidget: (_, __, ___) =>
                                            const Icon(
                                          Icons.store,
                                          color: Colors.grey,
                                          size: 16,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.store,
                                        color: Colors.grey,
                                        size: 16,
                                      ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                // Button to open full map
                Positioned(
                  top: 12,
                  right: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'open_full_map',
                    backgroundColor: AppTheme.kElectricLime,
                    child:
                        const Icon(Icons.fullscreen, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              MapView(startNearby: widget.focusNearby),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
