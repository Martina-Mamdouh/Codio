import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show EdgeInsets;
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

    // Allow re-init if data is empty (e.g. previous load returned empty due to transient error)
    final hasData = companies.isNotEmpty || categories.isNotEmpty;
    if (hasLoaded && hasData && !forceRefresh) {
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
        _supabaseService.getCompaniesWithMapDeals(),
        _supabaseService.getDeals(),
        _supabaseService.getCategories(),
      ]);

      companies = results[0] as List<CompanyModel>;
      deals = results[1] as List<DealModel>;
      categories = results[2] as List<CategoryModel>;

      if (kDebugMode) {
        print(
          '🗺️ MapVM loaded: ${companies.length} companies, ${deals.length} deals, ${categories.length} categories',
        );
      }

      _buildDiscountLookup();
      // Only mark as loaded if we actually received data
      hasLoaded = companies.isNotEmpty || categories.isNotEmpty;

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
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high
        ),
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

    // Sort: Featured first, then by date (most recent)
    companyDeals.sort((a, b) {
      if (a.isFeatured != b.isFeatured) {
        return a.isFeatured ? -1 : 1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    String bestLabel = '';
    double bestValue = -1;

    for (final deal in companyDeals) {
      // ✅ Strategy: 
      // 1. Try discountValue (e.g. 50%)
      // 2. If empty, try dealValue (e.g. SR 10)
      // 3. If still empty, use a snippet from Title
      
      String candidate = deal.discountValue.trim();
      if (candidate.isEmpty) {
        candidate = deal.dealValue.trim();
      }
      
      if (candidate.isEmpty) {
        // Fallback to title if no values specified
        candidate = deal.title.length > 8 
            ? '${deal.title.substring(0, 7)}...' 
            : deal.title;
      }

      final parsed = _parseDiscount(candidate);
      
      // If we found a numeric value higher than current best, update
      if (parsed > bestValue) {
        bestValue = parsed;
        bestLabel = candidate;
      } 
      // If no best label yet, set it anyway to ensure we show something
      else if (bestLabel.isEmpty) {
        bestLabel = candidate;
      }
    }

    return bestLabel;
  }

  double _parseDiscount(String value) {
    // Try to find a percentage first
    final percentMatch = RegExp(r"([0-9]+\.?[0-9]*)\s*%").firstMatch(value);
    if (percentMatch != null) {
      return (double.tryParse(percentMatch.group(1) ?? '') ?? 0) + 1000; // Boost percentage
    }

    // Try to find any number
    final numberMatch = RegExp(r"([0-9]+\.?[0-9]*)").firstMatch(value);
    if (numberMatch != null) {
      return double.tryParse(numberMatch.group(1) ?? '') ?? -1;
    }
    
    return -1;
  }

  String discountLabelFor(int companyId) => _discountLookup[companyId] ?? '';

  List<DealModel> dealsForCompany(int companyId) {
    final result = deals.where((d) => d.companyId == companyId).toList();
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

  // Branch markers state
  bool showBranchMarkers = false;
  List<LatLng> branchMarkerPoints = [];
  List<String> branchMarkerNames = [];

  void selectCompany(CompanyModel company) {
    selectedCompany = company;
    showBranchMarkers = false;
    branchMarkerPoints = [];
    branchMarkerNames = [];
    notifyListeners();
  }

  void clearSelection() {
    selectedCompany = null;
    showBranchMarkers = false;
    branchMarkerPoints = [];
    branchMarkerNames = [];
    notifyListeners();
  }

  void showAllBranches(CompanyModel company) {
    final branches = company.branches ?? [];
    final points = <LatLng>[];
    final names = <String>[];

    // Add main company location
    if (company.lat != 0 && company.lng != 0) {
      points.add(LatLng(company.lat, company.lng));
      names.add('${company.name} (الرئيسي)');
    }

    // Add branch locations
    for (final branch in branches) {
      if (branch.lat != 0 && branch.lng != 0) {
        points.add(LatLng(branch.lat, branch.lng));
        names.add(branch.name.isNotEmpty ? branch.name : company.name);
      }
    }

    if (points.isEmpty) return;

    branchMarkerPoints = points;
    branchMarkerNames = names;
    showBranchMarkers = true;
    notifyListeners();

    // Fit map to show all branches
    if (points.length == 1) {
      try {
        mapController.move(points.first, 14.0);
      } catch (_) {}
    } else {
      try {
        final bounds = LatLngBounds.fromPoints(points);
        mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(60),
          ),
        );
      } catch (_) {}
    }
  }

  void clearBranchMarkers() {
    showBranchMarkers = false;
    branchMarkerPoints = [];
    branchMarkerNames = [];
    notifyListeners();
  }
}
