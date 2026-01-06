import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for tracking user interactions and analytics
class AnalyticsService {
  final _supabase = Supabase.instance.client;
  
  // Queue for offline events
  final List<Map<String, dynamic>> _eventQueue = [];
  bool _isProcessing = false;

  /// Track a generic analytics event
  Future<void> trackEvent({
    required String eventType,
    required String entityType,
    required int entityId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      
      final event = {
        'event_type': eventType,
        'entity_type': entityType,
        'entity_id': entityId,
        'user_id': userId,
        'metadata': metadata ?? {},
        'created_at': DateTime.now().toIso8601String(),
      };

      // Try to insert immediately
      await _supabase.from('analytics_events').insert(event);
      
      if (kDebugMode) {
        print('📊 Analytics: $eventType for $entityType #$entityId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Analytics error: $e');
      }
      // Queue for retry if offline
      _eventQueue.add({
        'event_type': eventType,
        'entity_type': entityType,
        'entity_id': entityId,
        'user_id': _supabase.auth.currentUser?.id,
        'metadata': metadata ?? {},
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
  Future<void> trackDealFavorite(int dealId, {required bool isFavorited}) async {
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
  Future<void> trackCompanyFollow(int companyId, {required bool isFollowed}) async {
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
  Future<void> trackBannerClick(int bannerId, {int? position, String? targetUrl}) async {
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
  Future<List<Map<String, dynamic>>> getTopDealsByViews({int limit = 10}) async {
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
  Future<List<Map<String, dynamic>>> getCompanyPerformance({int? companyId}) async {
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
      final response = await _supabase
          .from('banner_analytics')
          .select();
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching banner analytics: $e');
      }
      return [];
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
}
