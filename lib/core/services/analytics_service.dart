import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

/// Service for tracking user interactions and analytics
class AnalyticsService {
  final _supabase = Supabase.instance.client;

  // Queue for offline events
  final List<Map<String, dynamic>> _eventQueue = [];
  bool _isProcessing = false;
  static String? _deviceId;

  Future<String> _getOrCreateDeviceId() async {
    if (_deviceId != null) return _deviceId!;

    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString('analytics_device_id');

    if (_deviceId == null) {
      _deviceId =
          'dev_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(99999)}';
      await prefs.setString('analytics_device_id', _deviceId!);
    }

    return _deviceId!;
  }

  /// Track a generic analytics event
  Future<void> trackEvent({
    required String eventType,
    required String entityType,
    required int entityId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      final deviceId = await _getOrCreateDeviceId();

      final Map<String, dynamic> finalMetadata = Map.from(metadata ?? {});
      finalMetadata['device_id'] = deviceId;

      final event = {
        'event_type': eventType,
        'entity_type': entityType,
        'entity_id': entityId,
        'user_id': userId,
        'metadata': finalMetadata,
        'created_at': DateTime.now().toIso8601String(),
      };

      // Try to insert immediately
      await _supabase.from('analytics_events').insert(event);

      if (kDebugMode) {
        print(
          '📊 Analytics: $eventType for $entityType #$entityId (Device: $deviceId)',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Analytics error: $e');
      }

      final deviceId = _deviceId ?? '';
      final Map<String, dynamic> finalMetadata = Map.from(metadata ?? {});
      finalMetadata['device_id'] = deviceId;

      // Queue for retry if offline
      _eventQueue.add({
        'event_type': eventType,
        'entity_type': entityType,
        'entity_id': entityId,
        'user_id': _supabase.auth.currentUser?.id,
        'metadata': finalMetadata,
      });
      _processQueue();
    }
  }

  /// Process queued events
  Future<void> _processQueue() async {
    if (_isProcessing || _eventQueue.isEmpty) return;

    _isProcessing = true;

    try {
      if (_eventQueue.isNotEmpty) {
        await _supabase.from('analytics_events').insert(_eventQueue);
        _eventQueue.clear();
        if (kDebugMode) {
          print('✅ Processed ${_eventQueue.length} queued analytics events');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to process analytics queue: $e');
      }
    } finally {
      _isProcessing = false;
    }
  }

  // ==================== DEAL TRACKING ====================

  /// Track deal page view
  Future<void> trackDealView(int dealId) async {
    await trackEvent(
      eventType: 'deal_view',
      entityType: 'deal',
      entityId: dealId,
    );
  }

  /// Track deal card click
  Future<void> trackDealCardClick(int dealId) async {
    await trackEvent(
      eventType: 'deal_card_click',
      entityType: 'deal',
      entityId: dealId,
    );
  }

  /// Track code copy
  Future<void> trackCodeCopy(int dealId, {String? code}) async {
    await trackEvent(
      eventType: 'code_copy',
      entityType: 'deal',
      entityId: dealId,
      metadata: code != null ? {'code': code} : null,
    );
  }

  /// Track deal link open
  Future<void> trackLinkOpen(int dealId, {String? url}) async {
    await trackEvent(
      eventType: 'link_open',
      entityType: 'deal',
      entityId: dealId,
      metadata: url != null ? {'url': url} : null,
    );
  }

  /// Track deal favorite
  Future<void> trackDealFavorite(
    int dealId, {
    required bool isFavorited,
  }) async {
    await trackEvent(
      eventType: 'deal_favorite',
      entityType: 'deal',
      entityId: dealId,
      metadata: {'action': isFavorited ? 'add' : 'remove'},
    );
  }

  /// Track deal image click
  Future<void> trackDealImageClick(int dealId) async {
    await trackEvent(
      eventType: 'deal_image_click',
      entityType: 'deal',
      entityId: dealId,
    );
  }

  /// Track emoji feedback (user satisfaction rating)
  Future<bool> trackEmojiFeedback(
    int dealId, {
    required String emojiType,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        if (kDebugMode) {
          print('❌ Cannot track emoji feedback: User not logged in');
        }
        return false;
      }

      // Validate emoji type
      if (!['happy', 'neutral', 'sad'].contains(emojiType)) {
        if (kDebugMode) {
          print('❌ Invalid emoji type: $emojiType');
        }
        return false;
      }

      // Upsert to ensure one feedback per user per deal
      await _supabase.from('deal_emoji_feedback').upsert({
        'deal_id': dealId,
        'user_id': userId,
        'emoji_type': emojiType,
        'created_at': DateTime.now().toIso8601String(),
      }, onConflict: 'deal_id,user_id');

      if (kDebugMode) {
        print('😊 Emoji feedback tracked: $emojiType for deal #$dealId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error tracking emoji feedback: $e');
      }
      return false;
    }
  }

  /// Get emoji feedback statistics for a specific deal
  Future<Map<String, dynamic>?> getEmojiFeedbackStats(int dealId) async {
    try {
      final response = await _supabase.rpc(
        'get_deal_emoji_stats',
        params: {'p_deal_id': dealId},
      );

      if (response != null && response is Map) {
        return Map<String, dynamic>.from(response);
      }

      // Fallback: manual aggregation if RPC doesn't exist
      final feedbacks = await _supabase
          .from('deal_emoji_feedback')
          .select('emoji_type')
          .eq('deal_id', dealId);

      if (feedbacks.isEmpty) {
        return {
          'happy_count': 0,
          'neutral_count': 0,
          'sad_count': 0,
          'total_count': 0,
          'happy_percentage': 0.0,
          'neutral_percentage': 0.0,
          'sad_percentage': 0.0,
        };
      }

      final happyCount = feedbacks
          .where((f) => f['emoji_type'] == 'happy')
          .length;
      final neutralCount = feedbacks
          .where((f) => f['emoji_type'] == 'neutral')
          .length;
      final sadCount = feedbacks.where((f) => f['emoji_type'] == 'sad').length;
      final total = feedbacks.length;

      return {
        'happy_count': happyCount,
        'neutral_count': neutralCount,
        'sad_count': sadCount,
        'total_count': total,
        'happy_percentage': total > 0 ? (happyCount / total * 100) : 0.0,
        'neutral_percentage': total > 0 ? (neutralCount / total * 100) : 0.0,
        'sad_percentage': total > 0 ? (sadCount / total * 100) : 0.0,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching emoji feedback stats: $e');
      }
      return null;
    }
  }

  /// Get user's emoji feedback for a specific deal (to show which one they selected)
  Future<String?> getUserEmojiFeedback(int dealId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) return null;

      final response = await _supabase
          .from('deal_emoji_feedback')
          .select('emoji_type')
          .eq('deal_id', dealId)
          .eq('user_id', userId)
          .maybeSingle();

      return response?['emoji_type'] as String?;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching user emoji feedback: $e');
      }
      return null;
    }
  }

  // ==================== COMPANY TRACKING ====================

  /// Track company page view
  Future<void> trackCompanyView(int companyId) async {
    await trackEvent(
      eventType: 'company_view',
      entityType: 'company',
      entityId: companyId,
    );
  }

  /// Track company follow
  Future<void> trackCompanyFollow(
    int companyId, {
    required bool isFollowed,
  }) async {
    await trackEvent(
      eventType: 'company_follow',
      entityType: 'company',
      entityId: companyId,
      metadata: {'action': isFollowed ? 'follow' : 'unfollow'},
    );
  }

  /// Track social media button click
  Future<void> trackSocialClick(int companyId, {String? platform}) async {
    await trackEvent(
      eventType: 'social_click',
      entityType: 'company',
      entityId: companyId,
      metadata: {'platform': platform ?? 'unknown'},
    );
  }

  /// Track website button click
  Future<void> trackWebsiteClick(int companyId, {String? url}) async {
    await trackEvent(
      eventType: 'website_click',
      entityType: 'company',
      entityId: companyId,
      metadata: url != null ? {'url': url} : null,
    );
  }

  /// Track map/location click
  Future<void> trackMapClick(int companyId) async {
    await trackEvent(
      eventType: 'map_click',
      entityType: 'company',
      entityId: companyId,
    );
  }

  /// Track phone click
  Future<void> trackPhoneClick(int companyId, {String? phone}) async {
    await trackEvent(
      eventType: 'phone_click',
      entityType: 'company',
      entityId: companyId,
      metadata: phone != null ? {'phone': phone} : null,
    );
  }

  /// Track email click
  Future<void> trackEmailClick(int companyId, {String? email}) async {
    await trackEvent(
      eventType: 'email_click',
      entityType: 'company',
      entityId: companyId,
      metadata: email != null ? {'email': email} : null,
    );
  }

  // ==================== BANNER TRACKING ====================

  /// Track banner impression
  Future<void> trackBannerImpression(int bannerId, {int? position}) async {
    await trackEvent(
      eventType: 'banner_impression',
      entityType: 'banner',
      entityId: bannerId,
      metadata: position != null ? {'position': position} : null,
    );
  }

  /// Track banner click
  Future<void> trackBannerClick(
    int bannerId, {
    int? position,
    String? targetUrl,
  }) async {
    await trackEvent(
      eventType: 'banner_click',
      entityType: 'banner',
      entityId: bannerId,
      metadata: {
        if (position != null) 'position': position,
        if (targetUrl != null) 'target_url': targetUrl,
      },
    );
  }

  // ==================== DASHBOARD QUERIES ====================

  /// Get unique analytics from the isolated view
  Future<List<Map<String, dynamic>>> getUniqueAnalytics() async {
    try {
      final response = await _supabase.from('unique_analytics_view').select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching unique analytics: $e');
      }
      return [];
    }
  }

  /// Get deal analytics (for dashboard)
  Future<Map<String, dynamic>?> getDealAnalytics(int dealId) async {
    try {
      final response = await _supabase
          .from('deal_analytics')
          .select()
          .eq('deal_id', dealId)
          .maybeSingle();

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching deal analytics: $e');
      }
      return null;
    }
  }

  /// Get company analytics (for dashboard)
  Future<Map<String, dynamic>?> getCompanyAnalytics(int companyId) async {
    try {
      final response = await _supabase
          .from('company_analytics')
          .select()
          .eq('company_id', companyId)
          .maybeSingle();

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching company analytics: $e');
      }
      return null;
    }
  }

  /// Get top deals by views (for dashboard)
  Future<List<Map<String, dynamic>>> getTopDealsByViews({
    int limit = 10,
  }) async {
    try {
      final response = await _supabase
          .from('top_deals_by_views')
          .select()
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching top deals: $e');
      }
      return [];
    }
  }

  /// Get company performance summary (for dashboard)
  Future<List<Map<String, dynamic>>> getCompanyPerformance({
    int? companyId,
  }) async {
    try {
      var query = _supabase.from('company_performance').select();

      if (companyId != null) {
        query = query.eq('id', companyId);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching company performance: $e');
      }
      return [];
    }
  }

  /// Get banner performance stats (for dashboard)
  Future<List<Map<String, dynamic>>> getBannerPerformance() async {
    try {
      final response = await _supabase.from('banner_analytics').select();

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching banner analytics: $e');
      }
      return [];
    }
  }

  // ==================== AD TRACKING & ANALYTICS ====================

  /// Track ad impression
  Future<void> trackAdImpression(int adId, {int? position}) async {
    await trackEvent(
      eventType: 'ad_impression',
      entityType: 'ad',
      entityId: adId,
      metadata: position != null ? {'position': position} : null,
    );
  }

  /// Track ad click
  Future<void> trackAdClick(
    int adId, {
    int? position,
    String? targetUrl,
  }) async {
    await trackEvent(
      eventType: 'ad_click',
      entityType: 'ad',
      entityId: adId,
      metadata: {
        if (position != null) 'position': position,
        if (targetUrl != null) 'target_url': targetUrl,
      },
    );
  }

  /// Get ad performance stats (for dashboard)
  Future<List<Map<String, dynamic>>> getAdPerformance() async {
    try {
      final response = await _supabase.from('ad_analytics').select();

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching ad analytics: $e');
      }
      return [];
    }
  }

  /// Get filtered stats for a specific ad from raw analytics_events via RPC.
  /// Returns totals + unique user counts for impressions and clicks
  /// filtered by [from] date.
  Future<Map<String, dynamic>> getAdFilteredStats(
    int adId, {
    DateTime? from,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_ad_filtered_stats',
        params: {
          'p_ad_id': adId,
          'p_from_date': from?.toUtc().toIso8601String(),
        },
      );

      final data = Map<String, dynamic>.from(response as Map);

      return {
        'impressions': data['impressions'] ?? 0,
        'unique_impressions': data['unique_impressions'] ?? 0,
        'clicks': data['clicks'] ?? 0,
        'unique_clicks': data['unique_clicks'] ?? 0,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching ad filtered stats: $e');
      }
      return {
        'impressions': 0,
        'unique_impressions': 0,
        'clicks': 0,
        'unique_clicks': 0,
      };
    }
  }

  /// Get social platform click breakdown (for dashboard)
  Future<List<Map<String, dynamic>>> getSocialPlatformBreakdown() async {
    try {
      final response = await _supabase
          .from('social_platform_breakdown')
          .select();

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching social breakdown: $e');
      }
      return [];
    }
  }

  /// Refresh materialized views (call periodically or on-demand)
  Future<void> refreshAnalyticsViews() async {
    try {
      await _supabase.rpc('refresh_analytics_views');
      if (kDebugMode) {
        print('✅ Analytics views refreshed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error refreshing analytics views: $e');
      }
    }
  }

  /// Get filtered stats for a specific company from raw analytics_events.
  /// Returns totals + unique user counts for page views, map clicks, phone clicks,
  /// social clicks, and website clicks — all filtered by [from] date.
  /// Uses device_id as fallback for unique tracking when user_id is null (guest).
  Future<Map<String, dynamic>> getCompanyFilteredStats(
    int companyId, {
    DateTime? from,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_company_filtered_stats',
        params: {
          'p_company_id': companyId,
          'p_from_date': from?.toUtc().toIso8601String(),
        },
      ).timeout(const Duration(seconds: 10));

      final data = Map<String, dynamic>.from(response as Map);

      return {
        'page_views': data['page_views'] ?? 0,
        'unique_viewers': data['unique_viewers'] ?? 0,
        'map_clicks': data['map_clicks'] ?? 0,
        'unique_map_clickers': data['unique_map_clickers'] ?? 0,
        'phone_clicks': data['phone_clicks'] ?? 0,
        'unique_phone_clickers': data['unique_phone_clickers'] ?? 0,
        'social_clicks': data['social_clicks'] ?? 0,
        'unique_social_clickers': data['unique_social_clickers'] ?? 0,
        'website_clicks': data['website_clicks'] ?? 0,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching company filtered stats: $e');
      }
      return {
        'page_views': 0,
        'unique_viewers': 0,
        'map_clicks': 0,
        'unique_map_clickers': 0,
        'phone_clicks': 0,
        'unique_phone_clickers': 0,
        'social_clicks': 0,
        'unique_social_clickers': 0,
        'website_clicks': 0,
      };
    }
  }

  /// Get filtered stats for all deals of a specific company via RPC.
  /// Returns a list of maps containing views, copies, links, and emoji counts
  /// for each deal, filtered by [from] date.
  Future<List<Map<String, dynamic>>> getCompanyDealsFilteredStats(
    int companyId, {
    DateTime? from,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_company_deals_filtered_stats',
        params: {
          'p_company_id': companyId,
          'p_from_date': from?.toUtc().toIso8601String(),
        },
      ).timeout(const Duration(seconds: 10));

      if (response == null) return [];

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching company deals filtered stats: $e');
      }
      return [];
    }
  }
}
