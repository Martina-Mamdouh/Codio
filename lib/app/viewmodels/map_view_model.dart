import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../../core/models/category_model.dart';
import '../../core/models/company_model.dart';
import '../../core/models/deal_model.dart';
import '../../core/services/supabase_service.dart';

class MapViewModel extends ChangeNotifier {
  MapViewModel();

  final SupabaseService _supabaseService = SupabaseService();

  // Data
  List<CompanyModel> companies = [];
  List<CategoryModel> categories = [];
  List<DealModel> deals = [];
  final Map<int, String> _discountLookup = {};

  // UI state
  bool isLoading = false;
  bool isLocationLoading = false;
  bool hasLoaded = false;
  bool nearbyOnly = false;
  String? errorMessage;
  String? locationError;
  Set<int> selectedCategoryIds = {};

  // Map state
  GoogleMapController? _mapController;
  Map<MarkerId, Marker> markers = {};
  CompanyModel? selectedCompany;
  Position? userPosition;
  CameraPosition? _lastCameraPosition;

  // Marker cache
  final Map<int, BitmapDescriptor> _markerCache = {};

  // Constants
  static const LatLng _fallbackCenter = LatLng(24.7136, 46.6753); // Riyadh
  static const double _defaultZoom = 11.8;
  static const double nearbyRadiusMeters = 10000; // 10 km

  LatLng get _initialTarget {
    if (selectedCompany != null) {
      return LatLng(selectedCompany!.lat, selectedCompany!.lng);
    }

    final withLocation = companies.firstWhere(
      (c) => c.lat != 0 && c.lng != 0,
      orElse: () => companies.isNotEmpty
          ? companies.first
          : CompanyModel(
              id: -1,
              name: 'fallback',
              lat: _fallbackCenter.latitude,
              lng: _fallbackCenter.longitude,
            ),
    );

    return LatLng(withLocation.lat, withLocation.lng);
  }

  CameraPosition get initialCameraPosition =>
      CameraPosition(target: _initialTarget, zoom: _defaultZoom);

  bool get hasLocation => userPosition != null;

  Future<void> init({
    bool focusNearby = false,
    bool forceRefresh = false,
  }) async {
    if (isLoading) return;
    if (hasLoaded && !forceRefresh) {
      if (focusNearby) {
        await enableNearbyMode();
      } else {
        await _rebuildMarkers();
      }
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _supabaseService.getCompanies(),
        _supabaseService.getDeals(),
        _supabaseService.getCategories(),
      ]);

      companies = results[0] as List<CompanyModel>;
      deals = results[1] as List<DealModel>;
      categories = results[2] as List<CategoryModel>;

      _buildDiscountLookup();
      hasLoaded = true;

      if (focusNearby) {
        await enableNearbyMode();
      } else {
        await _rebuildMarkers();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing map view: $e');
      }
      errorMessage = 'حدث خطأ أثناء تحميل بيانات الخريطة، حاول لاحقاً';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await init(forceRefresh: true, focusNearby: nearbyOnly);
  }

  Future<void> enableNearbyMode() async {
    nearbyOnly = true;
    await _ensureLocation();
    if (userPosition == null) {
      nearbyOnly = false;
      notifyListeners();
      return;
    }
    await _rebuildMarkers();
    await _animateToUser();
  }

  Future<void> disableNearbyMode() async {
    nearbyOnly = false;
    await _rebuildMarkers();
    await _animateToInitial();
  }

  Future<void> toggleNearby() async {
    if (nearbyOnly) {
      await disableNearbyMode();
    } else {
      await enableNearbyMode();
    }
  }

  Future<void> clearFilters() async {
    selectedCategoryIds.clear();
    nearbyOnly = false;
    await _rebuildMarkers();
  }

  Future<void> setMapController(GoogleMapController controller) async {
    _mapController = controller;
    if (_lastCameraPosition != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(_lastCameraPosition!),
      );
    } else {
      await _animateToInitial();
    }
  }

  void onCameraMove(CameraPosition position) {
    _lastCameraPosition = position;
  }

  List<CompanyModel> get filteredCompanies {
    Iterable<CompanyModel> filtered = companies;

    if (selectedCategoryIds.isNotEmpty) {
      filtered = filtered.where((c) {
        final ids = c.categoryIds ?? <int>[];
        return ids.any(selectedCategoryIds.contains);
      });
    }

    if (nearbyOnly && userPosition != null) {
      filtered = filtered.where((c) {
        final distance = Geolocator.distanceBetween(
          userPosition!.latitude,
          userPosition!.longitude,
          c.lat,
          c.lng,
        );
        return distance <= nearbyRadiusMeters;
      });
    }

    return filtered.toList();
  }

  Future<void> toggleCategory(int categoryId) async {
    if (selectedCategoryIds.contains(categoryId)) {
      selectedCategoryIds.remove(categoryId);
    } else {
      selectedCategoryIds.add(categoryId);
    }
    await _rebuildMarkers();
  }

  Future<void> _ensureLocation({bool force = false}) async {
    if (userPosition != null && !force) return;

    isLocationLoading = true;
    locationError = null;
    notifyListeners();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        locationError = 'خدمة تحديد الموقع غير مفعّلة';
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        locationError = 'يجب السماح بالوصول للموقع لاستخدام العروض القريبة';
        return;
      }

      userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      locationError = null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Location error: $e');
      }
      locationError = 'تعذر تحديد موقعك حالياً';
    } finally {
      isLocationLoading = false;
      notifyListeners();
    }
  }

  Future<void> centerOnUser() async {
    await _ensureLocation();
    await _animateToUser();
  }

  Future<void> _animateToUser() async {
    if (_mapController == null || userPosition == null) return;
    final target = LatLng(userPosition!.latitude, userPosition!.longitude);
    final camera = CameraPosition(target: target, zoom: 13.5);
    _lastCameraPosition = camera;
    await _mapController!.animateCamera(CameraUpdate.newCameraPosition(camera));
  }

  Future<void> _animateToInitial() async {
    if (_mapController == null) return;
    final camera = CameraPosition(target: _initialTarget, zoom: _defaultZoom);
    _lastCameraPosition = camera;
    await _mapController!.animateCamera(CameraUpdate.newCameraPosition(camera));
  }

  Future<void> _rebuildMarkers() async {
    final companiesToShow = filteredCompanies
        .where((c) => c.lat != 0 || c.lng != 0)
        .toList();
    if (companiesToShow.isEmpty) {
      markers = {};
      notifyListeners();
      return;
    }

    final futures = companiesToShow.map(_buildMarkerForCompany).toList();
    final built = await Future.wait(futures);
    markers = {for (final m in built) m.markerId: m};
    notifyListeners();
  }

  Future<Marker> _buildMarkerForCompany(CompanyModel company) async {
    final discount = _discountLookup[company.id] ?? '';
    final markerId = MarkerId('company_${company.id}');
    final icon = await _resolveMarkerIcon(company, discount);

    return Marker(
      markerId: markerId,
      position: LatLng(company.lat, company.lng),
      icon: icon,
      infoWindow: InfoWindow(
        title: company.name,
        snippet: discount.isNotEmpty ? 'خصم $discount' : 'اضغط للتفاصيل',
        onTap: () {
          selectedCompany = company;
          notifyListeners();
        },
      ),
      onTap: () {
        selectedCompany = company;
        notifyListeners();
      },
    );
  }

  Future<BitmapDescriptor> _resolveMarkerIcon(
    CompanyModel company,
    String discount,
  ) async {
    if (_markerCache.containsKey(company.id)) {
      return _markerCache[company.id]!;
    }

    try {
      final bytes = await _composeMarkerBytes(
        logoUrl: company.logoUrl,
        discount: discount,
      );
      final descriptor = BitmapDescriptor.fromBytes(bytes);
      _markerCache[company.id] = descriptor;
      return descriptor;
    } catch (_) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
    }
  }

  Future<Uint8List> _composeMarkerBytes({
    required String? logoUrl,
    required String discount,
  }) async {
    const double size = 168;
    const double borderWidth = 6;
    const double shadowBlur = 9;
    const double badgeSize = 54;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(size / 2, size / 2);
    final radius = size / 2.25;

    // Soft shadow to lift the marker from the map.
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, shadowBlur);
    canvas.drawCircle(center, radius, shadowPaint);

    // Outer ring for contrast on all map themes.
    final ringPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius - 2, ringPaint);

    // Base fill.
    final basePaint = Paint()..color = const Color(0xFF1B1B1B);
    canvas.drawCircle(center, radius - borderWidth, basePaint);

    // Clip the logo into a perfect circle.
    final clipRadius = radius - (borderWidth * 1.4);
    final clipPath = Path()..addOval(Rect.fromCircle(center: center, radius: clipRadius));
    canvas.save();
    canvas.clipPath(clipPath);

    if (logoUrl != null && logoUrl.isNotEmpty) {
      try {
        final image = await _loadNetworkImage(logoUrl, targetSize: (clipRadius * 2).toInt());
        paintImage(
          canvas: canvas,
          rect: Rect.fromCircle(center: center, radius: clipRadius),
          image: image,
          fit: BoxFit.cover,
        );
      } catch (_) {
        _drawFallbackStoreIcon(canvas, center, clipRadius * 2);
      }
    } else {
      _drawFallbackStoreIcon(canvas, center, clipRadius * 2);
    }

    canvas.restore();

    // Discount badge as circular pill that sits at top.
    if (discount.isNotEmpty) {
      final badgeCenter = Offset(size / 2, badgeSize / 2 + 4);
      final badgePaint = Paint()..color = Colors.redAccent;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: badgeCenter,
            width: badgeSize * 1.6,
            height: badgeSize * 0.7,
          ),
          const Radius.circular(18),
        ),
        badgePaint,
      );

      final paragraphStyle = ui.ParagraphStyle(
        textAlign: TextAlign.center,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      );
      final textStyle = ui.TextStyle(color: Colors.white);
      final builder = ui.ParagraphBuilder(paragraphStyle)
        ..pushStyle(textStyle)
        ..addText(discount);
      final paragraph = builder.build()
        ..layout(ui.ParagraphConstraints(width: badgeSize * 1.5));
      canvas.drawParagraph(paragraph, Offset(badgeCenter.dx - (badgeSize * 0.75), badgeCenter.dy - 16));
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<ui.Image> _loadNetworkImage(String url, {int targetSize = 120}) async {
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: targetSize,
    );
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  void _drawFallbackStoreIcon(Canvas canvas, Offset center, double size) {
    final paint = Paint()..color = Colors.white;
    canvas.drawCircle(center, size / 4, paint);
    final icon = Icons.store;
    final builder =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(textAlign: TextAlign.center, fontSize: 48),
          )
          ..pushStyle(
            ui.TextStyle(
              color: const Color(0xFF1A1A1A),
              fontFamily: 'MaterialIcons',
            ),
          )
          ..addText(String.fromCharCode(icon.codePoint));
    final paragraph = builder.build()
      ..layout(ui.ParagraphConstraints(width: size / 2));
    canvas.drawParagraph(
      paragraph,
      Offset(center.dx - (size / 4), center.dy - 32),
    );
  }

  void _buildDiscountLookup() {
    _discountLookup.clear();
    _markerCache.clear();
    final grouped = <int, List<DealModel>>{};
    for (final deal in deals) {
      grouped.putIfAbsent(deal.companyId, () => []).add(deal);
    }

    grouped.forEach((companyId, companyDeals) {
      final best = _pickBestDiscount(companyDeals);
      if (best.isNotEmpty) {
        _discountLookup[companyId] = best;
      }
    });
  }

  String _pickBestDiscount(List<DealModel> companyDeals) {
    if (companyDeals.isEmpty) return '';

    companyDeals.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    String bestLabel = '';
    double bestValue = -1;

    for (final deal in companyDeals) {
      final candidate =
          (deal.discountValue.isNotEmpty ? deal.discountValue : deal.dealValue)
              .trim();
      if (candidate.isEmpty) continue;

      final parsed = _parseDiscount(candidate);
      if (parsed > bestValue) {
        bestValue = parsed;
        bestLabel = candidate;
      }
    }

    return bestLabel;
  }

  double _parseDiscount(String value) {
    final match = RegExp(r"([0-9]+\.?[0-9]*)").firstMatch(value);
    if (match != null) {
      return double.tryParse(match.group(1) ?? '') ?? -1;
    }
    return -1;
  }

  String discountLabelFor(int companyId) => _discountLookup[companyId] ?? '';

  double? distanceKmFor(CompanyModel company) {
    if (userPosition == null) return null;
    final distance = Geolocator.distanceBetween(
      userPosition!.latitude,
      userPosition!.longitude,
      company.lat,
      company.lng,
    );
    return distance / 1000;
  }

  void selectCompany(CompanyModel company) {
    selectedCompany = company;
    notifyListeners();
  }

  void clearSelection() {
    selectedCompany = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
