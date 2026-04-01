import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/models/banner_model.dart';
import '../../core/models/deal_model.dart';
import '../../core/services/supabase_service.dart';

class HomeViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<BannerModel> banners = [];
  List<DealModel> newDeals = [];
  List<DealModel> allNewDeals = [];

  List<DealModel> featuredDeals = [];
  List<DealModel> allFeaturedDeals = [];

  List<DealModel> expiringDeals = [];
  List<DealModel> allExpiringDeals = [];

  List<DealModel> studentDeals = [];
  List<DealModel> allStudentDeals = [];

  List<DealModel> entertainmentDeals = [];
  List<DealModel> allEntertainmentDeals = [];

  List<DealModel> nearbyDeals = []; // ✅ New List
  List<DealModel> allNearbyDeals = []; // ✅ New List

  bool isLoading = false;
  bool isLocationLoading = false;
  String? errorMessage;
  Position? userPosition;

  HomeViewModel() {
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    isLoading = true;
    errorMessage = null;
    if (hasListeners) {
      notifyListeners();
    }

    try {
      // 1. Fetch Banners and All Deals concurrently
      final results = await Future.wait([
        _supabaseService.getBanners(),
        _supabaseService.getDeals(),
        _determinePosition(), // ✅ Get location for nearby deals
      ]);

      banners = results[0] as List<BannerModel>;
      final allDeals = results[1] as List<DealModel>;
      userPosition = results[2] as Position?;

      // 2. Clear lists
      allStudentDeals = [];
      allExpiringDeals = [];
      allFeaturedDeals = [];
      allNewDeals = [];
      allEntertainmentDeals = [];
      allNearbyDeals = [];

      // 3. Define Logic Helpers
      final now = DateTime.now();
      final sevenDaysLater = now.add(const Duration(days: 7));

      bool isEndingSoon(DealModel d) {
        return d.expiresAt.isAfter(now) && d.expiresAt.isBefore(sevenDaysLater);
      }

      final Set<int> usedDealIds = {};

      // 4. Apply Display Priority (Highest -> Lowest)

      // Priority 0: Nearby Deals (New)
      if (userPosition != null) {
        final List<DealModel> dealsWithLocation = allDeals.where((d) {
          return d.companyLat != null && d.companyLng != null && d.companyLat != 0;
        }).toList();

        // Sort by distance
        dealsWithLocation.sort((a, b) {
          final distA = Geolocator.distanceBetween(
            userPosition!.latitude,
            userPosition!.longitude,
            a.companyLat!,
            a.companyLng!,
          );
          final distB = Geolocator.distanceBetween(
            userPosition!.latitude,
            userPosition!.longitude,
            b.companyLat!,
            b.companyLng!,
          );
          return distA.compareTo(distB);
        });
        
        // Filter to reasonable range (e.g. 30km)
        allNearbyDeals = dealsWithLocation.where((d) {
           final dist = Geolocator.distanceBetween(
            userPosition!.latitude,
            userPosition!.longitude,
            d.companyLat!,
            d.companyLng!,
          );
           return dist <= 30000; // 30 km
        }).toList();
        
        // usedDealIds.addAll(allNearbyDeals.map((d) => d.id)); // Optional: decide if nearby removes from other sections
      }

      // Priority 1: Student Deals
      allStudentDeals = allDeals.where((d) => d.isForStudents).toList();
      allStudentDeals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      usedDealIds.addAll(allStudentDeals.map((d) => d.id));

      // Priority 1.5: Entertainment Deals
      allEntertainmentDeals = allDeals.where((d) {
        if (usedDealIds.contains(d.id)) return false;
        final cat = d.categoryName?.toLowerCase() ?? '';
        return cat.contains('ترفيه') || cat.contains('أنشطة');
      }).toList();
      allEntertainmentDeals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      usedDealIds.addAll(allEntertainmentDeals.map((d) => d.id));

      // Priority 2: Ending Soon Deals
      allExpiringDeals = allDeals.where((d) {
        if (usedDealIds.contains(d.id)) return false;
        return isEndingSoon(d);
      }).toList();
      allExpiringDeals.sort((a, b) => a.expiresAt.compareTo(b.expiresAt));
      usedDealIds.addAll(allExpiringDeals.map((d) => d.id));

      // Priority 3: Featured Deals
      allFeaturedDeals = allDeals.where((d) {
        if (usedDealIds.contains(d.id)) return false;
        if (d.isForStudents) return false;
        return d.isFeatured;
      }).toList();
      allFeaturedDeals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      usedDealIds.addAll(allFeaturedDeals.map((d) => d.id));

      // Priority 4: New Deals
      allNewDeals = allDeals.where((d) {
        if (usedDealIds.contains(d.id)) return false;
        if (d.isForStudents) return false;
        return true;
      }).toList();
      allNewDeals.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // 5. Limited Display
      studentDeals = allStudentDeals.take(5).toList();
      entertainmentDeals = allEntertainmentDeals.take(5).toList();
      expiringDeals = allExpiringDeals.take(5).toList();
      featuredDeals = allFeaturedDeals.take(5).toList();
      newDeals = allNewDeals.take(5).toList();
      nearbyDeals = allNearbyDeals.take(5).toList();
    } catch (e) {
      errorMessage = 'حدث خطأ أثناء تحميل البيانات، تأكد من اتصالك بالإنترنت';
      debugPrint('Error in HomeViewModel: $e');
    } finally {
      isLoading = false;
      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  double calculateDistance(DealModel deal) {
    if (userPosition == null || deal.companyLat == null || deal.companyLng == null) {
      return 0.0;
    }
    return Geolocator.distanceBetween(
      userPosition!.latitude,
      userPosition!.longitude,
      deal.companyLat!,
      deal.companyLng!,
    ) / 1000; // Convert to KM
  }

  Future<Position?> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low, // Lower accuracy for faster fetch on home
          timeLimit: Duration(seconds: 5),
        )
      );
    } catch (_) {
      return null;
    }
  }
}
