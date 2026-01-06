import 'package:flutter/material.dart';
import '../../core/models/notification_model.dart';
import '../../core/services/supabase_service.dart';

class NotificationsViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<NotificationModel> newNotifications = [];
  List<NotificationModel> oldNotifications = [];

  bool isLoading = false;
  String? errorMessage;

  Future<void> loadNotifications() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final all = await _supabaseService.getNotifications();

      newNotifications = all.where((n) => !n.isRead).toList(growable: false);
      oldNotifications = all.where((n) => n.isRead).toList(growable: false);
    } catch (e) {
      errorMessage = 'حدث خطأ أثناء تحميل الإشعارات';
      debugPrint('Error loading notifications: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    if (newNotifications.isEmpty) return;

    // تحديث متفائل
    oldNotifications = [
      ...newNotifications.map((n) => n.copyWith(isRead: true)),
      ...oldNotifications,
    ];
    newNotifications = [];
    notifyListeners();

    try {
      await _supabaseService.markAllNotificationsAsRead();
    } catch (e) {
      // لو حصل خطأ نرجع نحمّل من السيرفر
      await loadNotifications();
    }
  }

  Future<void> markOneAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    newNotifications = newNotifications
        .where((n) => n.id != notification.id)
        .toList();
    oldNotifications = [
      notification.copyWith(isRead: true),
      ...oldNotifications,
    ];
    notifyListeners();

    await _supabaseService.markNotificationAsRead(notification.id);
  }
}
