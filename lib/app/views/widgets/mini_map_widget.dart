import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
          if (vm.isLoading && vm.markers.isEmpty) {
            return Container(
              height: 220.h,
              decoration: BoxDecoration(
                color: AppTheme.kLightBackground,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.kElectricLime),
              ),
            );
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: vm.initialCameraPosition,
                  markers: vm.markers.values.toSet(),
                  zoomControlsEnabled: false,
                  myLocationEnabled: vm.hasLocation,
                  myLocationButtonEnabled: false,
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                  liteModeEnabled: false,
                  gestureRecognizers: {
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                  onMapCreated: (controller) => vm.setMapController(controller),
                  onTap: (_) {
                    // Handle map tap if needed
                  },
                ),
                
                // Button to open full map
                Positioned(
                  top: 12,
                  right: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'open_full_map',
                    backgroundColor: AppTheme.kElectricLime,
                    child: const Icon(Icons.fullscreen, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MapView(startNearby: widget.focusNearby),
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
