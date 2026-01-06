import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app/views/deal_details_view.dart';
import '../../app/views/notifications_view.dart';
import '../../core/services/supabase_service.dart';

class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  // Global navigator key for deep-linking
  GlobalKey<NavigatorState>? _navigatorKey;

  // Lightweight duplicate prevention (in-memory cache)
  // Prevents same notification from being saved twice (foreground + click)
  final Map<String, DateTime> _recentNotifications = {};
  static const _duplicateWindowSeconds = 5;

  Future<void> initialize(
    String appId, {
    GlobalKey<NavigatorState>? navigatorKey, // For deep-linking
  }) async {
    _navigatorKey = navigatorKey; // Store for later use
    try {
      OneSignal.initialize(appId);

      final accepted = await OneSignal.Notifications.requestPermission(true);
      if (kDebugMode) {
        print("OneSignal: Notification permission accepted: $accepted");
      }

      OneSignal.Notifications.addForegroundWillDisplayListener((event) async {
        if (kDebugMode) {
          print('OneSignal: Notification received in foreground');
          print('Title: ${event.notification.title}');
          print('Body: ${event.notification.body}');
        }

        // Guard: Only save if user is authenticated (prevent crash on logout/before login)
        if (Supabase.instance.client.auth.currentUser == null) {
          if (kDebugMode) {
            print('OneSignal: Skipping save - no authenticated user');
          }
          event.notification.display();
          return;
        }

        final title = event.notification.title ?? '';
        final body = event.notification.body ?? '';

        // Extract deal_id if present (for deep-linking)
        int? dealId = _extractDealId(event.notification.additionalData);

        if (title.isNotEmpty || body.isNotEmpty) {
          // Guard: Prevent duplicate saves (foreground + click both fire)
          if (!_isDuplicate(title, body)) {
            await SupabaseService().logNotificationForCurrentUser(
              title,
              body,
              dealId: dealId, // Pass optional deal_id
            );
          } else if (kDebugMode) {
            print('OneSignal: Skipping duplicate notification');
          }
        }

        // نعرض الإشعار في الـ status bar
        event.notification.display();
      });

      // Handler عند الضغط على الإشعار
      OneSignal.Notifications.addClickListener((event) async {
        if (kDebugMode) {
          print('OneSignal: Notification clicked');
        }

        // Guard: Only save if user is authenticated (prevent crash after logout)
        if (Supabase.instance.client.auth.currentUser == null) {
          if (kDebugMode) {
            print('OneSignal: Skipping save - no authenticated user');
          }
          return;
        }

        final title = event.notification.title ?? '';
        final body = event.notification.body ?? '';

        // Extract deal_id if present (for deep-linking)
        int? dealId = _extractDealId(event.notification.additionalData);

        if (title.isNotEmpty || body.isNotEmpty) {
          // Guard: Prevent duplicate saves (foreground + click both fire)
          if (!_isDuplicate(title, body)) {
            await SupabaseService().logNotificationForCurrentUser(
              title,
              body,
              dealId: dealId, // Pass optional deal_id
            );
          } else if (kDebugMode) {
            print('OneSignal: Skipping duplicate notification');
          }
        }

        // Deep-link to deal if dealId provided
        if (dealId != null) {
          await _navigateToDeal(dealId);
          return; // Early exit - navigation handled
        }

        final data = event.notification.additionalData;
        if (data != null) {
          if (kDebugMode) {
            print('Additional Data: $data');
          }

          if (data.containsKey('dealId')) {
            final dealId = data['dealId'];
            if (kDebugMode) {
              print('Opening deal: $dealId');
            }
            // TODO: Navigate to deal details حسب الـ dealId
          }

          if (data.containsKey('companyId')) {
            final companyId = data['companyId'];
            if (kDebugMode) {
              print('Opening company: $companyId');
            }
            // TODO: Navigate to company profile حسب الـ companyId
          }
        }
      });

      if (kDebugMode) {
        print('OneSignal initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing OneSignal: $e');
      }
    }
  }

  // جلب الـ Subscription ID
  String? getSubscriptionId() {
    try {
      return OneSignal.User.pushSubscription.id;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting Subscription ID: $e');
      }
      return null;
    }
  }

  // تعيين External User ID (login)
  void setExternalUserId(String userId) {
    try {
      OneSignal.login(userId);
      if (kDebugMode) {
        print('External User ID set: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting External User ID: $e');
      }
    }
  }

  // إزالة External User ID (logout)
  void removeExternalUserId() {
    try {
      OneSignal.logout();
      if (kDebugMode) {
        print('External User ID removed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error removing External User ID: $e');
      }
    }
  }

  // إرسال Tag واحد
  void sendTag(String key, String value) {
    try {
      OneSignal.User.addTags({key: value});
      if (kDebugMode) {
        print('Tag sent: $key = $value');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending tag: $e');
      }
    }
  }

  // إرسال عدة Tags
  void sendTags(Map<String, String> tags) {
    try {
      OneSignal.User.addTags(tags);
      if (kDebugMode) {
        print('Tags sent: $tags');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending tags: $e');
      }
    }
  }

  // حذف Tag واحد
  void deleteTag(String key) {
    try {
      OneSignal.User.removeTags([key]);
      if (kDebugMode) {
        print('Tag deleted: $key');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting tag: $e');
      }
    }
  }

  // حذف عدة Tags
  void deleteTags(List<String> keys) {
    try {
      OneSignal.User.removeTags(keys);
      if (kDebugMode) {
        print('Tags deleted: $keys');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting tags: $e');
      }
    }
  }

  /// Check if notification was recently processed (prevents duplicates)
  /// Returns true if same notification seen within last 5 seconds
  bool _isDuplicate(String title, String body) {
    final key = '$title|$body';
    final now = DateTime.now();

    if (_recentNotifications.containsKey(key)) {
      final lastSeen = _recentNotifications[key]!;
      if (now.difference(lastSeen).inSeconds < _duplicateWindowSeconds) {
        return true; // Duplicate within window
      }
    }

    // Mark as seen
    _recentNotifications[key] = now;

    // Cleanup old entries to prevent memory growth
    _recentNotifications.removeWhere(
      (k, v) => now.difference(v).inSeconds > _duplicateWindowSeconds,
    );

    return false;
  }

  /// Extract deal_id from OneSignal additionalData (safe parsing)
  /// Returns null if not present or invalid format
  int? _extractDealId(Map<String, dynamic>? additionalData) {
    if (additionalData == null) return null;

    try {
      // Check if deal_id exists in payload
      if (!additionalData.containsKey('deal_id')) return null;

      final dealIdValue = additionalData['deal_id'];

      // Handle both int and string formats
      if (dealIdValue is int) {
        return dealIdValue;
      } else if (dealIdValue is String) {
        return int.tryParse(dealIdValue); // Safe parsing
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error extracting deal_id: $e');
      }
      return null;
    }
  }

  /// Navigate to deal details screen (with graceful error handling)
  Future<void> _navigateToDeal(int dealId) async {
    if (_navigatorKey?.currentState == null) {
      if (kDebugMode) {
        print('Cannot navigate: Navigator key not available');
      }
      return;
    }

    try {
      // Fetch the deal from database
      final deal = await SupabaseService().getDealById(dealId);

      if (deal != null) {
        // Navigate to deal details
        _navigatorKey!.currentState!.push(
          MaterialPageRoute(builder: (_) => DealDetailsView(deal: deal)),
        );
        if (kDebugMode) {
          print('✅ Navigated to deal $dealId');
        }
      } else {
        // Deal not found - navigate to notifications screen (fallback)
        if (kDebugMode) {
          print('⚠️ Deal $dealId not found - navigating to notifications');
        }
        _navigatorKey!.currentState!.push(
          MaterialPageRoute(builder: (_) => const NotificationsView()),
        );
      }
    } catch (e) {
      // Error fetching deal - navigate to notifications screen (fallback)
      if (kDebugMode) {
        print('❌ Error navigating to deal $dealId: $e');
      }
      _navigatorKey!.currentState!.push(
        MaterialPageRoute(builder: (_) => const NotificationsView()),
      );
    }
  }
}
