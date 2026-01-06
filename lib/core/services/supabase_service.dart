import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/company_model.dart';
import '../models/deal_model.dart';
import '../models/notification_model.dart';
import '../models/review_model.dart';

// Top-level function for compute
List<DealModel> parseDeals(List<dynamic> data) {
  return data.map((item) => DealModel.fromJson(item)).toList();
}

class SupabaseService {
  final _client = Supabase.instance.client;

  Future<List<DealModel>> getDeals() async {
    try {
      final data = await _client
          .from('deals')
          .select(
            '*, companies(name, logo_url, cover_image_url), categories(name)',
          )
          .order('created_at', ascending: false);
      // Use compute to parse JSON in background isolate
      final deals = await compute(parseDeals, data);
      return deals;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting deals: $e');
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
      // 1. Fetch companies (without joining categories to avoid FK issues)
      final companiesData = await _client
          .from('companies')
          .select('*, deals(count)')
          .order('created_at', ascending: false);

      // 2. Fetch all categories to map names manually (Safest approach)
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

        // Map Supabase count response to flat deal_count
        if (json['deals'] != null && json['deals'] is List) {
          final dealsList = json['deals'] as List;
          if (dealsList.isNotEmpty && dealsList.first is Map) {
            json['deal_count'] = dealsList.first['count'];
          } else {
            json['deal_count'] = 0;
          }
        }

        // 3. Resolve Primary Category Name
        final primaryId = json['primary_category_id'] as int?;
        if (primaryId != null && categoryMap.containsKey(primaryId)) {
          json['category_name'] = categoryMap[primaryId];
        } else {
          // Optional: fallback logic or leave null
          json['category_name'] = null;
        }

        return CompanyModel.fromJson(json);
      }).toList();

      return companies;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting companies: $e');
      }
      return [];
    }
  }

  Future<void> addCompany(Map<String, dynamic> companyData) async {
    try {
      await _client.from('companies').insert(companyData);
    } catch (e) {
      if (kDebugMode) {
        print('Error adding company: $e');
      }
      throw Exception('Failed to add company. Please try again.');
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

  // Top-level function for compute
  List<BannerModel> parseBanners(List<dynamic> data) {
    return data.map((item) => BannerModel.fromJson(item)).toList();
  }

  Future<List<BannerModel>> getBanners() async {
    try {
      final data = await _client
          .from('banners')
          .select()
          .order('created_at', ascending: false);
      // Parse directly without compute - data is already List<dynamic>
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

  // notifications functions

  // 1) جلب كل إشعارات المستخدم الحالي (Inbox)
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final data = await _client
          .from('notifications')
          .select('*')
          .order('created_at', ascending: false);

      return (data as List)
          .map(
            (json) => NotificationModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting notifications: $e');
      }
      return [];
    }
  }

  // 2) جعل كل إشعارات المستخدم الحالي كمقروءة
  Future<void> markAllNotificationsAsRead() async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('is_read', false);
    } catch (e) {
      if (kDebugMode) {
        print('Error markAllNotificationsAsRead: $e');
      }
      throw Exception('Failed to mark notifications as read.');
    }
  }

  // 3) جعل إشعار واحد كمقروء
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

  // مفيدة لو في إشعارات inside-app غير OneSignal
  Future<void> logNotificationForCurrentUser(
    String title,
    String body, {
    int? dealId, // Optional: link notification to a specific deal
  }) async {
    // Guard: Silently fail if no authenticated user (defensive - prevents crashes)
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      if (kDebugMode) {
        print('⚠️ Cannot save notification: No authenticated user');
      }
      return; // Exit early without throwing
    }

    try {
      await _client.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'body': body,
        if (dealId != null) 'deal_id': dealId, // Optional deep-link to deal
        // is_read = false, created_at = now() من الـ default
      });

      if (kDebugMode) {
        print(
          '✅ Notification saved successfully${dealId != null ? ' (linked to deal $dealId)' : ''}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving notification: $e');
      }
      // Don't throw - fail silently to avoid crashing OneSignal listeners
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
            '*, companies(name, logo_url, cover_image_url), categories(name)',
          )
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
            '*, companies(name, logo_url, cover_image_url), categories(name)',
          )
          .eq('is_featured', true)
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
            '*, companies(name, logo_url, cover_image_url), categories(name)',
          )
          .gte('expires_at', now.toIso8601String())
          .lte('expires_at', sevenDaysLater.toIso8601String())
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
            '*, companies(name, logo_url, cover_image_url), categories(name)',
          ) // ✨
          .eq('company_id', companyId)
          .order('created_at', ascending: false);

      if (kDebugMode) {
        print('getCompanyDeals for companyId $companyId: ${data.length} deals');
      }

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
            '*, companies(name, logo_url, cover_image_url), categories(name)',
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
          .select('*')
          .eq('id', companyId)
          .maybeSingle();

      if (data == null) {
        if (kDebugMode) {
          print('Company with id $companyId not found');
        }
        return null;
      }

      final json = Map<String, dynamic>.from(data);
      if (json['categories'] != null && json['categories'] is Map) {
        json['category_name'] = json['categories']['name'];
      }

      final dealsData = await _client
          .from('deals')
          .select('id')
          .eq('company_id', companyId);
      json['deal_count'] = (dealsData as List).length;

      return CompanyModel.fromJson(json);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting company by id: $e');
      }
      return null;
    }
  }

  // ================== Categories =========================

  // جلب كل الفئات
  Future<List<CategoryModel>> getCategories() async {
    try {
      final data = await _client
          .from('categories')
          .select()
          .order('name', ascending: true);

      final categories = data
          .map((item) => CategoryModel.fromJson(item))
          .toList();
      return categories;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting categories: $e');
      }
      return [];
    }
  }

  // ==================== Admin Categories CRUD ====================

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

  // ==================== End Admin Categories CRUD ================

  // جلب عروض فئة معينة
  Future<List<DealModel>> getDealsByCategory(int categoryId) async {
    try {
      final data = await _client
          .from('deals')
          .select(
            '*, companies(name, logo_url, cover_image_url), categories(name)',
          ) // ✨
          .eq('category_id', categoryId)
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

  // ================== End Categories ======================

  // ==================== Favorite Deals ====================
  // ==================== Favorite Deals ====================
  Future<List<DealModel>> getFavoriteDeals() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      // Use deep select to fetch deals directly through the foreign key
      // 'deals!inner' ensures we only get rows where the deal still exists
      final data = await _client
          .from('favorites_deals') // assuming FK name is 'deal_id' -> relation 'deals'
          .select('deals!inner(*, companies(*), categories(name))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List).map((row) {
        final dealData = row['deals'] as Map<String, dynamic>;
        return DealModel.fromJson(dealData);
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting favorite deals: $e');
      rethrow;
    }
  }

  /// هل العرض ده في المفضّلة للمستخدم الحالي؟
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

  /// إضافة عرض للمفضّلة
  Future<bool> addDealToFavorites(int dealId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      await _client.from('favorites_deals').insert({
        'user_id': userId,
        'deal_id': dealId,
      });

      debugPrint('✅ Deal $dealId added to favorites');
      return true;
    } catch (e) {
      debugPrint('❌ Error adding deal to favorites: $e');
      return false;
    }
  }

  /// حذف عرض من المفضّلة
  Future<bool> removeDealFromFavorites(int dealId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      await _client
          .from('favorites_deals')
          .delete()
          .eq('user_id', userId)
          .eq('deal_id', dealId);

      debugPrint('✅ Deal $dealId removed from favorites');
      return true;
    } catch (e) {
      debugPrint('❌ Error removing deal from favorites: $e');
      return false;
    }
  }

  /// Toggle (لو مضاف يشيله، لو مش مضاف يضيفه)
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

  /// جلب كل مفضّلات المستخدم (اختياري لشاشة المفضّلات)
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

  // ==================== Following Companies ====================
  // هل المستخدم الحالي متابع الشركة؟
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
      if (kDebugMode) {
        print('Error isCompanyFollowed: $e');
      }
      return false;
    }
  }

  // تبديل حالة المتابعة
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
      if (kDebugMode) {
        print('Error toggleCompanyFollow: $e');
      }
      return await isCompanyFollowed(companyId);
    }
  }

  Future<List<CompanyModel>> getFollowedCompanies() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      // Deep select: Fetch companies via 'following' table
      // relationships: following -> companies (FK: company_id)
      // companies -> deals (for count)
      // companies -> categories (for category name) - assuming FK exists
      
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
        
        // Handle Deal Count
        // Supabase returns {count: X} or [{count: X}]
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
        
        // Handle Category Name
        // Supabase returns {name: "Foo"} or null
        if (companyJson['categories'] != null) {
           final catData = companyJson['categories'];
           if (catData is Map) {
             companyJson['category_name'] = catData['name'];
           }
        }

        return CompanyModel.fromJson(companyJson);
      }).toList();

    } catch (e) {
      if (kDebugMode) {
        print('Error getFollowedCompanies: $e');
      }
      rethrow;
    }
  }

  // IDs الشركات اللي المستخدم متابعها (لو حبيت تستخدمها في لستة)
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
      if (kDebugMode) {
        print('Error getFollowedCompanyIds: $e');
      }
      return <int>{};
    }
  }

  // ==================== End Following Companies ====================

  // ==================== Reviews ====================

  // جلب مراجعات شركة
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

  // إضافة/تعديل مراجعة
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

  // حذف مراجعة
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

  // التحقق من وجود مراجعة للمستخدم
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
  // ==================== Admin: Manage Reviews ====================

  /// للإدمن فقط: حذف أي تقييم بالـ ID
  Future<void> deleteReviewById(int reviewId) async {
    try {
      await _client.from('reviews').delete().eq('id', reviewId);
      debugPrint('✅ Review $reviewId deleted by admin');
    } catch (e) {
      debugPrint('❌ Error admin deleting review: $e');
      rethrow;
    }
  }

  /// للإدمن فقط: تعديل تقييم معين
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

      debugPrint('✅ Review $reviewId updated by admin');
    } catch (e) {
      debugPrint('❌ Error admin updating review: $e');
      rethrow;
    }
  }

  /// للإدمن فقط: جلب كل التقييمات مع تفاصيل المستخدم والشركة
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

  // ==================== End Admin Reviews ====================

  // ==================== End Reviews ====================

  // ==================== Search ======================
  Future<List<DealModel>> searchDeals(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final data = await _client
          .from('deals')
          .select(
            '*, companies(name, logo_url, cover_image_url), categories(name)',
          ) // ✨
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false)
          .limit(50);

      final deals = data.map((item) => DealModel.fromJson(item)).toList();
      return deals;
    } catch (e) {
      if (kDebugMode) {
        print('Error searching deals: $e');
      }
      return [];
    }
  }

  // ==================== End Search ==================
  // ==================== Diagnostics ====================
  Future<String> runDiagnostics() async {
    final StringBuffer report = StringBuffer();
    report.writeln('--- Diagnostics Report ---');
    report.writeln('Timestamp: ${DateTime.now().toIso8601String()}');

    final user = _client.auth.currentUser;
    if (user == null) {
      report.writeln('❌ Auth Status: Not Authenticated');
      return report.toString();
    }
    report.writeln('✅ Auth Status: Authenticated (${user.id})');
    report.writeln('Email: ${user.email}');

    try {
      // Check Favorites Count (Raw)
      final favRows = await _client
          .from('favorites_deals')
          .select('deal_id')
          .eq('user_id', user.id);
      
      final count = (favRows as List).length;
      report.writeln('✅ Favorites Table Row Count: $count');
      
      if (count > 0) {
        // Check visibility of first deal
        final firstDealId = favRows.first['deal_id'];
        report.writeln('🔍 Checking visibility for Deal ID: $firstDealId');
        
        final dealCheck = await _client
            .from('deals')
            .select('id')
            .eq('id', firstDealId)
            .maybeSingle();
            
        if (dealCheck != null) {
          report.writeln('✅ Deal $firstDealId is VISIBLE via standard select.');
        } else {
          report.writeln('❌ Deal $firstDealId is NOT VISIBLE (RLS or Deleted).');
        }
      }

      // Check Following Count
      final followRows = await _client
          .from('following')
          .select('id')
          .eq('user_id', user.id);
      
      report.writeln('✅ Following Table Row Count: ${(followRows as List).length}');

      // ---------------------------------------------------------
      // TEST MAIN QUERY
      report.writeln('🔍 Testing getFavoriteDeals() query...');
      try {
        final deals = await getFavoriteDeals();
        report.writeln('✅ getFavoriteDeals returned: ${deals.length} items');
        if (deals.isNotEmpty) {
           report.writeln('   First Item: ${deals.first.title}');
        }
      } catch (e) {
        report.writeln('❌ getFavoriteDeals FAILED:');
        report.writeln('   $e');
      }
      // ---------------------------------------------------------

    } catch (e) {
      report.writeln('❌ Error running diagnostics: $e');
    }

    report.writeln('--------------------------');
    return report.toString();
  }
}
