import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ad_model.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/company_model.dart';
import '../models/city_model.dart'; // ✅ Added
import '../models/deal_model.dart';
import '../models/notification_model.dart';
import '../models/review_model.dart';

// Top-level function for compute
List<DealModel> parseDeals(List<dynamic> data) {
  return data.map((item) => DealModel.fromJson(item)).toList();
}

class SupabaseService {
  final _client = Supabase.instance.client;

  /// Fetch deals.
  ///
  /// By default this returns only deals that should be visible inside the app
  /// (rows where `show_in_app = true`). Pass [onlyVisible] = false to return
  /// all deals (useful for admin panels or the map view which should show all)
  Future<List<DealModel>> getDeals({bool onlyVisible = true}) async {
    try {
      final query = _client
          .from('deals')
          .select(
            '*, companies(name, logo_url, cover_image_url, is_partner, lat, lng), categories(name)',
          );

      // Apply visibility filter only when requested
      final filtered = onlyVisible ? query.eq('show_in_app', true) : query;

      final data = await filtered.order('created_at', ascending: false);

      if (kDebugMode) {
        print('📊 getDeals: ${data.length} raw rows');
      }

      final deals = data.map((item) => DealModel.fromJson(item)).toList();
      return deals;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting deals: $e');
      }
      return [];
    }
  }

  Future<void> addDeal(Map<String, dynamic> dealData) async {
    try {
      await _client.from('deals').insert(dealData);
    } catch (e) {
      if (kDebugMode) {
        print('Error adding deal: $e');
      }
      throw Exception('Failed to add deal. Please try again.');
    }
  }

  Future<void> updateDeal(int id, Map<String, dynamic> dealData) async {
    try {
      await _client.from('deals').update(dealData).eq('id', id);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating deal: $e');
      }
      throw Exception('Failed to update deal. Please try again.');
    }
  }

  Future<void> deleteDeal(int id) async {
    try {
      try {
        await _client.from('favorites_deals').delete().eq('deal_id', id);
        await _client.from('notifications').delete().eq('deal_id', id);
      } catch (e) {
        if (kDebugMode) {
          print('Error deleting related records for deal $id: $e');
        }
      }
      await _client.from('deals').delete().eq('id', id);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting deal: $e');
      }
      throw Exception('Failed to delete deal. Please try again.');
    }
  }

  Future<List<CompanyModel>> getCompanies() async {
    try {
      final companiesData = await _client
          .from('companies')
          .select('*, deals(count), company_branches(*)')
          .order('created_at', ascending: false);

      final categoriesData = await _client
          .from('categories')
          .select('id, name');

      final categoryMap = {
        for (var item in categoriesData as List)
          item['id'] as int: item['name'] as String,
      };

      final List<dynamic> rawList = companiesData as List<dynamic>;

      final companies = rawList.map((item) {
        final Map<String, dynamic> json = Map<String, dynamic>.from(item);

        if (json['deals'] != null && json['deals'] is List) {
          final dealsList = json['deals'] as List;
          json['deal_count'] = dealsList.isNotEmpty
              ? dealsList.first['count']
              : 0;
        }

        final primaryId = json['primary_category_id'] as int?;
        if (primaryId != null && categoryMap.containsKey(primaryId)) {
          json['category_name'] = categoryMap[primaryId];
        }

        return CompanyModel.fromJson(json);
      }).toList();

      return companies;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting companies: $e');
      }
      return [];
    }
  }

  Future<List<CompanyModel>> getCompaniesWithMapDeals() async {
    try {
      final data = await _client
          .from('companies')
          // Return companies that have at least one deal (no longer filter by show_in_map)
          .select('*, deals!inner(*), company_branches(*)');

      return (data as List).map((item) => CompanyModel.fromJson(item)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getCompaniesWithMapDeals: $e');
      }
      return [];
    }
  }

  Future<List<DealModel>> getNearbyDeals(double lat, double lng) async {
    try {
      final data = await _client
          .from('deals')
          .select('*, companies!inner(*), categories(name)')
          .not('companies.lat', 'is', null)
          .not('companies.lng', 'is', null);

      List<DealModel> deals = (data as List).map((item) => DealModel.fromJson(item)).toList();
      return deals;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getNearbyDeals: $e');
      }
      return [];
    }
  }

  Future<int> addCompany(Map<String, dynamic> companyData) async {
    try {
      final response = await _client
          .from('companies')
          .insert(companyData)
          .select('id')
          .single();
      return response['id'] as int;
    } catch (e) {
      if (kDebugMode) {
        print('Error adding company: $e');
      }
      throw Exception('Failed to add company. Please try again.');
    }
  }

  Future<void> saveCompanyBranches(
    int companyId,
    List<Map<String, dynamic>> branches,
  ) async {
    if (branches.isEmpty) return;
    try {
      final branchesWithId = branches.map((b) {
        final copy = Map<String, dynamic>.from(b);
        copy.remove('id');
        copy['company_id'] = companyId;
        return copy;
      }).toList();
      await _client.from('company_branches').insert(branchesWithId);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving company branches: $e');
      }
      throw Exception('Failed to save company branches.');
    }
  }

  Future<void> replaceCompanyBranches(
    int companyId,
    List<Map<String, dynamic>> branches,
  ) async {
    try {
      await _client
          .from('company_branches')
          .delete()
          .eq('company_id', companyId);
      if (branches.isNotEmpty) {
        await saveCompanyBranches(companyId, branches);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error replacing company branches: $e');
      }
      throw Exception('Failed to replace company branches.');
    }
  }

  Future<void> updateCompany(int id, Map<String, dynamic> companyData) async {
    try {
      await _client.from('companies').update(companyData).eq('id', id);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating company: $e');
      }
      throw Exception('Failed to update company. Please try again.');
    }
  }

  Future<void> deleteCompany(int id) async {
    try {
      await _client.from('companies').delete().eq('id', id);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting company: $e');
      }
      throw Exception('Failed to delete company. Please try again.');
    }
  }

  List<BannerModel> parseBanners(List<dynamic> data) {
    return data.map((item) => BannerModel.fromJson(item)).toList();
  }

  Future<List<BannerModel>> getBanners() async {
    try {
      final data = await _client
          .from('banners')
          .select()
          .order('created_at', ascending: false);
      return (data as List)
          .map((item) => BannerModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting banners: $e');
      }
      return [];
    }
  }

  Future<void> addBanner(Map<String, dynamic> bannerData) async {
    try {
      await _client.from('banners').insert(bannerData);
    } catch (e) {
      if (kDebugMode) {
        print('Error adding banner: $e');
      }
      throw Exception('Failed to add banner. Please try again.');
    }
  }

  Future<void> updateBanner(int id, Map<String, dynamic> bannerData) async {
    try {
      await _client.from('banners').update(bannerData).eq('id', id);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating banner: $e');
      }
      throw Exception('Failed to update banner. Please try again.');
    }
  }

  Future<void> deleteBanner(int id) async {
    try {
      await _client.from('banners').delete().eq('id', id);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting banner: $e');
      }
      throw Exception('Failed to delete banner. Please try again.');
    }
  }

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final data = await _client
          .from('notifications')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List)
          .map(
            (json) => NotificationModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting notifications: $e');
      }
      return [];
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      if (kDebugMode) {
        print('Error markAllNotificationsAsRead: $e');
      }
      throw Exception('Failed to mark notifications as read.');
    }
  }

  Future<void> markNotificationAsRead(int id) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', id);
    } catch (e) {
      if (kDebugMode) {
        print('Error markNotificationAsRead: $e');
      }
    }
  }

  Stream<List<NotificationModel>> getNotificationsStream() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return const Stream.empty();
    }

    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map(
          (data) =>
              data.map((json) => NotificationModel.fromJson(json)).toList(),
        );
  }

  Future<void> logNotificationForCurrentUser(
    String title,
    String body, {
    int? dealId,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _client.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'body': body,
        if (dealId != null) 'deal_id': dealId,
      });
    } catch (e) {
      if (dealId != null && e.toString().contains('23503')) {
        try {
          await _client.from('notifications').insert({
            'user_id': userId,
            'title': title,
            'body': body,
          });
        } catch (retryError) {
          if (kDebugMode) print('❌ Retry failed: $retryError');
        }
      }
    }
  }

  Future<String> uploadImageBytes(Uint8List bytes, String path) async {
    try {
      await _client.storage
          .from('images')
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final String publicUrl = _client.storage
          .from('images')
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
      throw Exception('Failed to upload image. Please check connection.');
    }
  }

  Future<List<DealModel>> getNewDeals() async {
    try {
      final data = await _client
          .from('deals')
          .select(
            '*, companies(name, logo_url, cover_image_url, is_partner, lat, lng), categories(name)',
          )
          // Only new deals that should be visible inside the app
          .eq('show_in_app', true)
          .order('created_at', ascending: false)
          .limit(5);
      return data.map((item) => DealModel.fromJson(item)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting new deals: $e');
      }
      return [];
    }
  }

  Future<List<DealModel>> getFeaturedDeals() async {
    try {
      final data = await _client
          .from('deals')
          .select(
            '*, companies(name, logo_url, cover_image_url, is_partner, lat, lng), categories(name)',
          )
          .eq('is_featured', true)
          // Only featured deals visible inside the app
          .eq('show_in_app', true)
          .order('created_at', ascending: false);
      return data.map((item) => DealModel.fromJson(item)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting featured deals: $e');
      }
      return [];
    }
  }

  Future<List<DealModel>> getExpiringDeals() async {
    try {
      final now = DateTime.now();
      final sevenDaysLater = now.add(const Duration(days: 7));

      final data = await _client
          .from('deals')
          .select(
            '*, companies(name, logo_url, cover_image_url, is_partner, lat, lng), categories(name)',
          )
          .gte('expires_at', now.toIso8601String())
          .lte('expires_at', sevenDaysLater.toIso8601String())
          // Only expiring deals visible inside the app
          .eq('show_in_app', true)
          .order('expires_at', ascending: true);
      return data.map((item) => DealModel.fromJson(item)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting expiring deals: $e');
      }
      return [];
    }
  }

  Future<List<DealModel>> getCompanyDeals(int companyId) async {
    try {
      final data = await _client
          .from('deals')
          .select(
            '*, companies(name, logo_url, cover_image_url, is_partner, lat, lng), categories(name)',
          )
          .eq('company_id', companyId)
          // Only company deals that are supposed to be shown inside the app
          .eq('show_in_app', true)
          .order('created_at', ascending: false);

      return data.map((item) => DealModel.fromJson(item)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting company deals: $e');
      }
      return [];
    }
  }

  Future<DealModel?> getDealById(int dealId) async {
    try {
      final data = await _client
          .from('deals')
          .select(
            '*, companies(name, logo_url, cover_image_url, is_partner, lat, lng), categories(name)',
          )
          .eq('id', dealId)
          .single();
      return DealModel.fromJson(data);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting deal by id: $e');
      }
      return null;
    }
  }

  Future<CompanyModel?> getCompanyById(int companyId) async {
    try {
      final data = await _client
          .from('companies')
          .select('*, deals(count), categories(name), company_branches(*)')
          .eq('id', companyId)
          .maybeSingle();

      if (data == null) return null;

      final json = Map<String, dynamic>.from(data);

      if (json['deals'] != null && json['deals'] is List) {
        final dealsList = json['deals'] as List;
        json['deal_count'] = dealsList.isNotEmpty
            ? dealsList.first['count']
            : 0;
      }

      if (json['categories'] != null) {
        if (json['categories'] is List &&
            (json['categories'] as List).isNotEmpty) {
          json['category_name'] = (json['categories'] as List).first['name'];
        } else if (json['categories'] is Map) {
          json['category_name'] = json['categories']['name'];
        }
      }

      return CompanyModel.fromJson(json);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting company by id: $e');
      }
      return null;
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final data = await _client
          .from('categories')
          .select()
          .order('name', ascending: true);
      return data
          .map((item) => CategoryModel.fromJson(item))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting categories: $e');
      }
      return [];
    }
  }

  Future<void> addCategory(Map<String, dynamic> categoryData) async {
    try {
      await _client.from('categories').insert(categoryData);
    } catch (e) {
      if (kDebugMode) {
        print('Error adding category: $e');
      }
      throw Exception('Failed to add category. Please try again.');
    }
  }

  Future<void> updateCategory(int id, Map<String, dynamic> categoryData) async {
    try {
      await _client.from('categories').update(categoryData).eq('id', id);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating category: $e');
      }
      throw Exception('Failed to update category. Please try again.');
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _client.from('categories').delete().eq('id', id);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting category: $e');
      }
      throw Exception('Failed to delete category. Please try again.');
    }
  }

  // ✅ CITIES CRUD

  Future<List<CityModel>> getCities() async {
    try {
      final data = await _client
          .from('cities')
          .select()
          .order('name_en', ascending: true);
      return data.map((item) => CityModel.fromJson(item)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting cities: $e');
      }
      return [];
    }
  }

  Future<void> addCity(Map<String, dynamic> cityData) async {
    try {
      await _client.from('cities').insert(cityData);
    } catch (e) {
      if (kDebugMode) {
        print('Error adding city: $e');
      }
      throw Exception('Failed to add city. Please try again.');
    }
  }

  Future<void> updateCity(int id, Map<String, dynamic> cityData) async {
    try {
      await _client.from('cities').update(cityData).eq('id', id);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating city: $e');
      }
      throw Exception('Failed to update city. Please try again.');
    }
  }

  Future<void> deleteCity(int id) async {
    try {
      await _client.from('cities').delete().eq('id', id);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting city: $e');
      }
      throw Exception('Failed to delete city. Please try again.');
    }
  }

  // ✅ ADS CRUD

  Future<List<AdModel>> getAds() async {
    try {
      final data = await _client
          .from('advertisements')
          .select('*, deals(title)')
          .order('id', ascending: false);
      return (data as List).map((item) => AdModel.fromJson(item)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting ads: $e');
      }
      return [];
    }
  }

  Future<void> addAd(Map<String, dynamic> adData) async {
    try {
      await _client.from('advertisements').insert(adData);
    } catch (e) {
      if (kDebugMode) {
        print('Error adding ad: $e');
      }
      throw Exception('Failed to add ad. Please try again.');
    }
  }

  Future<void> updateAd(int id, Map<String, dynamic> adData) async {
    try {
      await _client.from('advertisements').update(adData).eq('id', id);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating ad: $e');
      }
      throw Exception('Failed to update ad. Please try again.');
    }
  }

  Future<void> deleteAd(int id) async {
    try {
      await _client.from('advertisements').delete().eq('id', id);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting ad: $e');
      }
      throw Exception('Failed to delete ad. Please try again.');
    }
  }

  Future<List<DealModel>> getDealsByCategory(int categoryId) async {
    try {
      final data = await _client
          .from('deals')
          .select(
            '*, companies(name, logo_url, cover_image_url, is_partner, lat, lng), categories(name)',
          )
          .eq('category_id', categoryId)
          // Respect show_in_app flag for category listing
          .eq('show_in_app', true)
          .order('created_at', ascending: false);

      final deals = data.map((item) => DealModel.fromJson(item)).toList();
      return deals;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting deals by category: $e');
      }
      return [];
    }
  }

  Future<List<DealModel>> getFavoriteDeals() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final data = await _client
          .from('favorites_deals')
          .select('deals!inner(*, companies(*), categories(name))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      // Map rows -> deal and filter out deals that are hidden in the app
      return (data as List)
          .map((row) => row['deals'] as Map<String, dynamic>)
          .map((dealData) => DealModel.fromJson(dealData))
          .where((deal) => deal.showInApp)
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting favorite deals: $e');
      rethrow;
    }
  }

  Future<bool> isDealFavorite(int dealId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      final data = await _client
          .from('favorites_deals')
          .select('id')
          .eq('user_id', userId)
          .eq('deal_id', dealId)
          .maybeSingle();

      return data != null;
    } catch (e) {
      debugPrint('❌ Error checking deal favorite: $e');
      return false;
    }
  }

  Future<bool> addDealToFavorites(int dealId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      await _client.from('favorites_deals').insert({
        'user_id': userId,
        'deal_id': dealId,
      });
      return true;
    } catch (e) {
      debugPrint('❌ Error adding deal to favorites: $e');
      return false;
    }
  }

  Future<bool> removeDealFromFavorites(int dealId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      await _client
          .from('favorites_deals')
          .delete()
          .eq('user_id', userId)
          .eq('deal_id', dealId);
      return true;
    } catch (e) {
      debugPrint('❌ Error removing deal from favorites: $e');
      return false;
    }
  }

  Future<bool> toggleDealFavorite(int dealId) async {
    try {
      final isFav = await isDealFavorite(dealId);
      if (isFav) {
        return await removeDealFromFavorites(dealId);
      } else {
        return await addDealToFavorites(dealId);
      }
    } catch (e) {
      debugPrint('❌ Error toggling deal favorite: $e');
      return false;
    }
  }

  Future<List<int>> getFavoriteDealIds() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final data = await _client
          .from('favorites_deals')
          .select('deal_id')
          .eq('user_id', userId);

      return (data as List).map((row) => row['deal_id'] as int).toList();
    } catch (e) {
      debugPrint('❌ Error getting favorite deal ids: $e');
      return [];
    }
  }

  Future<bool> isCompanyFollowed(int companyId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      final data = await _client
          .from('following')
          .select('id')
          .eq('user_id', userId)
          .eq('company_id', companyId)
          .maybeSingle();

      return data != null;
    } catch (e) {
      if (kDebugMode) print('Error isCompanyFollowed: $e');
      return false;
    }
  }

  Future<bool> toggleCompanyFollow(int companyId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      final existing = await _client
          .from('following')
          .select('id')
          .eq('user_id', userId)
          .eq('company_id', companyId)
          .maybeSingle();

      if (existing != null) {
        await _client.from('following').delete().eq('id', existing['id']);
        return false;
      } else {
        await _client.from('following').insert({
          'user_id': userId,
          'company_id': companyId,
        });
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('Error toggleCompanyFollow: $e');
      return await isCompanyFollowed(companyId);
    }
  }

  Future<List<CompanyModel>> getFollowedCompanies() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final data = await _client
          .from('following')
          .select('''
            companies!inner(
              *,
              deals(count),
              categories(name)
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List).map((row) {
        final companyJson = row['companies'] as Map<String, dynamic>;

        if (companyJson['deals'] != null) {
          final dealsData = companyJson['deals'];
          if (dealsData is List && dealsData.isNotEmpty) {
            companyJson['deal_count'] = dealsData.first['count'];
          } else if (dealsData is Map) {
            companyJson['deal_count'] = dealsData['count'];
          } else {
            companyJson['deal_count'] = 0;
          }
        }

        if (companyJson['categories'] != null) {
          final catData = companyJson['categories'];
          if (catData is Map) {
            companyJson['category_name'] = catData['name'];
          }
        }

        return CompanyModel.fromJson(companyJson);
      }).toList();
    } catch (e) {
      if (kDebugMode) print('Error getFollowedCompanies: $e');
      rethrow;
    }
  }

  Future<Set<int>> getFollowedCompanyIds() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return <int>{};

    try {
      final data = await _client
          .from('following')
          .select('company_id')
          .eq('user_id', userId);

      return (data as List).map((row) => row['company_id'] as int).toSet();
    } catch (e) {
      if (kDebugMode) print('Error getFollowedCompanyIds: $e');
      return <int>{};
    }
  }

  Future<List<ReviewModel>> getCompanyReviews(int companyId) async {
    try {
      final data = await _client
          .from('reviews')
          .select('''
        *,
        user:users!reviews_user_id_fkey(full_name, avatar_url)
      ''')
          .eq('company_id', companyId)
          .order('created_at', ascending: false);

      return data.map((json) => ReviewModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching company reviews: $e');
      rethrow;
    }
  }

  Future<ReviewModel> upsertReview({
    required int companyId,
    required int rating,
    String? comment,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('غير مسجل دخول');

      final data = await _client
          .from('reviews')
          .upsert({
            'user_id': userId,
            'company_id': companyId,
            'rating': rating,
            'comment': comment,
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'user_id,company_id')
          .select('''
        *,
        user:users!reviews_user_id_fkey(full_name, avatar_url)
      ''')
          .single();

      return ReviewModel.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error upserting review: $e');
      rethrow;
    }
  }

  Future<void> deleteReview(int companyId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('غير مسجل دخول');

      await _client
          .from('reviews')
          .delete()
          .eq('user_id', userId)
          .eq('company_id', companyId);
    } catch (e) {
      debugPrint('❌ Error deleting review: $e');
      rethrow;
    }
  }

  Future<ReviewModel?> getUserReview(int companyId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      final data = await _client
          .from('reviews')
          .select('''
        *,
        user:users!reviews_user_id_fkey(full_name, avatar_url)
      ''')
          .eq('user_id', userId)
          .eq('company_id', companyId)
          .maybeSingle();

      return data != null ? ReviewModel.fromJson(data) : null;
    } catch (e) {
      debugPrint('❌ Error fetching user review: $e');
      return null;
    }
  }

  Future<void> deleteReviewById(int reviewId) async {
    try {
      await _client.from('reviews').delete().eq('id', reviewId);
    } catch (e) {
      debugPrint('❌ Error admin deleting review: $e');
      rethrow;
    }
  }

  Future<void> updateReviewById(
    int reviewId, {
    int? rating,
    String? comment,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (rating != null) data['rating'] = rating;
      if (comment != null) data['comment'] = comment;
      data['updated_at'] = DateTime.now().toIso8601String();

      await _client.from('reviews').update(data).eq('id', reviewId);
    } catch (e) {
      debugPrint('❌ Error admin updating review: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllReviewsForAdmin() async {
    try {
      final response = await _client
          .from('reviews')
          .select('''
          *,
          users:user_id (id, full_name, email, avatar_url),
          companies:company_id (id, name, logo_url)
        ''')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Error getting all reviews for admin: $e');
      return [];
    }
  }

  Future<List<DealModel>> searchDeals(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final data = await _client
          .from('deals')
          .select(
            '*, companies(name, logo_url, cover_image_url, lat, lng), categories(name)',
          )
          .or('title.ilike.%$query%,description.ilike.%$query%')
          // Only allow searching visible deals
          .eq('show_in_app', true)
          .order('created_at', ascending: false)
          .limit(50);

      final deals = data.map((item) => DealModel.fromJson(item)).toList();
      return deals;
    } catch (e) {
      if (kDebugMode) print('Error searching deals: $e');
      return [];
    }
  }

  Future<String> runDiagnostics() async {
    final StringBuffer report = StringBuffer();
    report.writeln('--- Diagnostics Report ---');
    final user = _client.auth.currentUser;
    if (user == null) return '❌ Not Authenticated';

    try {
      final favRows = await _client
          .from('favorites_deals')
          .select('deal_id')
          .eq('user_id', user.id);
      report.writeln('✅ Favorites count: ${(favRows as List).length}');
    } catch (e) {
      report.writeln('❌ Error: $e');
    }
    return report.toString();
  }

  Future<Map<String, String>> getAppSettings() async {
    try {
      final data = await _client.from('app_settings').select('key, value');
      return {
        for (final row in data as List)
          row['key'] as String: (row['value'] as String?) ?? '',
      };
    } catch (e) {
      debugPrint('❌ Error getting app settings: $e');
      return {};
    }
  }

  Future<void> updateAppSetting(String key, String value) async {
    try {
      await _client.from('app_settings').upsert({
        'key': key,
        'value': value,
      }, onConflict: 'key');
    } catch (e) {
      debugPrint('❌ Error updating app setting $key: $e');
      rethrow;
    }
  }
}
