import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/models/notification_model.dart';
import '../../core/services/supabase_service.dart';

class NotificationsViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<NotificationModel> newNotifications = [];
  List<NotificationModel> oldNotifications = [];

  bool isLoading = false;
  String? errorMessage;

  StreamSubscription<List<NotificationModel>>? _subscription;

  Future<void> loadNotifications() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // 1. جلب البيانات فوراً لضمان ظهورها (حتى لو الـ Stream فيه مشكلة)
      final all = await _supabaseService.getNotifications();
      _updateLists(all);
      
      // 2. بدء الاستماع للتحديثات
      startListening();
    } catch (e) {
      errorMessage = 'حدث خطأ أثناء تحميل الإشعارات';
      debugPrint('Error loading notifications: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void startListening() {
    if (_subscription != null) return;

    _subscription = _supabaseService.getNotificationsStream().listen(
      (data) {
        _updateLists(data);
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error listening to notifications: $error');
      },
    );
  }

  void _updateLists(List<NotificationModel> all) {
    // فرز الإشعارات حسب التاريخ (الأحدث أولاً)
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    newNotifications = all.where((n) => !n.isRead).toList();
    oldNotifications = all.where((n) => n.isRead).toList();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
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
