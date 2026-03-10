import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

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
  final MapController mapController = MapController();
  CompanyModel? selectedCompany;
  Position? userPosition;
  LatLng? _lastCenter;
  double? _lastZoom;

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

  LatLng get initialCenter => _lastCenter ?? _initialTarget;
  double get initialZoom => _lastZoom ?? _defaultZoom;

  bool get hasLocation => userPosition != null;

  Future<void> init({
    bool focusNearby = false,
    bool forceRefresh = false,
  }) async {
    if (isLoading) return;
    if (hasLoaded && !forceRefresh) {
      if (focusNearby) {
        await enableNearbyMode();
      }
      notifyListeners();
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

      if (kDebugMode) {
        print('🗺️ MapVM loaded: ${companies.length} companies, ${deals.length} deals, ${categories.length} categories');
        if (deals.isNotEmpty) {
          print('🗺️ First deal: id=${deals.first.id}, companyId=${deals.first.companyId}, title=${deals.first.title}');
        }
        if (companies.isNotEmpty) {
          print('🗺️ First company: id=${companies.first.id}, name=${companies.first.name}');
        }
      }

      _buildDiscountLookup();
      hasLoaded = true;

      if (focusNearby) {
        await enableNearbyMode();
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
    _animateToUser();
    notifyListeners();
  }

  Future<void> disableNearbyMode() async {
    nearbyOnly = false;
    _animateToInitial();
    notifyListeners();
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
    notifyListeners();
  }

  void onPositionChanged(MapCamera camera, bool hasGesture) {
    _lastCenter = camera.center;
    _lastZoom = camera.zoom;
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
    notifyListeners();
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
    _animateToUser();
  }

  void _animateToUser() {
    if (userPosition == null) return;
    final target = LatLng(userPosition!.latitude, userPosition!.longitude);
    _lastCenter = target;
    _lastZoom = 13.5;
    try {
      mapController.move(target, 13.5);
    } catch (_) {
      // Controller not yet attached
    }
  }

  void _animateToInitial() {
    _lastCenter = _initialTarget;
    _lastZoom = _defaultZoom;
    try {
      mapController.move(_initialTarget, _defaultZoom);
    } catch (_) {
      // Controller not yet attached
    }
  }

  void _buildDiscountLookup() {
    _discountLookup.clear();
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

  List<DealModel> dealsForCompany(int companyId) {
    final result = deals.where((d) => d.companyId == companyId).toList();
    if (kDebugMode) {
      print('🗺️ dealsForCompany($companyId): found ${result.length} out of ${deals.length} total deals');
    }
    return result;
  }

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
}
