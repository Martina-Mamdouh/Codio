// lib/app/viewmodels/reviews_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/models/review_model.dart';
import '../../core/services/supabase_service.dart';

class ReviewsViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final int companyId;

  List<ReviewModel> reviews = [];
  ReviewModel? userReview; // مراجعة المستخدم الحالي

  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;

  // قناة Realtime
  RealtimeChannel? _reviewsChannel;

  ReviewsViewModel(this.companyId) {
    loadReviews();
  }

  // جلب كل المراجعات
  Future<void> loadReviews() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // جلب كل المراجعات
      reviews = await _supabaseService.getCompanyReviews(companyId);

      // جلب مراجعة المستخدم الحالي
      userReview = await _supabaseService.getUserReview(companyId);

      // اشترك في Realtime
      _subscribeToReviews();
    } catch (e) {
      errorMessage = 'حدث خطأ أثناء تحميل التقييمات';
      debugPrint('❌ Error loading reviews: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // اشتراك Realtime
  void _subscribeToReviews() {
    if (_reviewsChannel != null) {
      Supabase.instance.client.removeChannel(_reviewsChannel!);
    }

    _reviewsChannel = Supabase.instance.client
        .channel('reviews_$companyId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'reviews',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'company_id',
            value: companyId,
          ),
          callback: (payload) {
            debugPrint('🔄 Realtime review update: ${payload.eventType}');

            if (payload.eventType == PostgresChangeEvent.insert) {
              _handleReviewInsert(payload.newRecord);
            } else if (payload.eventType == PostgresChangeEvent.update) {
              _handleReviewUpdate(payload.newRecord);
            } else if (payload.eventType == PostgresChangeEvent.delete) {
              _handleReviewDelete(payload.oldRecord);
            }
          },
        )
        .subscribe();
  }

  bool isUserReview(ReviewModel review) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    return review.userId == currentUserId;
  }

  void _handleReviewInsert(Map<String, dynamic> data) async {
    // اجلب الـ review كامل مع بيانات المستخدم
    try {
      final reviewId = data['id'] as int;
      final fullReview = await Supabase.instance.client
          .from('reviews')
          .select('''
          *,
          user:users!reviews_user_id_fkey(full_name, avatar_url)
        ''')
          .eq('id', reviewId)
          .single();

      final newReview = ReviewModel.fromJson(fullReview);

      // تحقق إذا كانت المراجعة موجودة (تجنب التكرار)
      final exists = reviews.any((r) => r.id == newReview.id);
      if (!exists) {
        reviews.insert(0, newReview);

        // تحديث مراجعة المستخدم إذا كانت له
        final currentUserId = Supabase.instance.client.auth.currentUser?.id;
        if (newReview.userId == currentUserId) {
          userReview = newReview;
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error fetching full review: $e');
    }
  }

  void _handleReviewUpdate(Map<String, dynamic> data) async {
    try {
      final reviewId = data['id'] as int;
      final fullReview = await Supabase.instance.client
          .from('reviews')
          .select('''
          *,
          user:users!reviews_user_id_fkey(full_name, avatar_url)
        ''')
          .eq('id', reviewId)
          .single();

      final updatedReview = ReviewModel.fromJson(fullReview);
      final index = reviews.indexWhere((r) => r.id == updatedReview.id);

      if (index != -1) {
        reviews[index] = updatedReview;

        // تحديث مراجعة المستخدم إذا كانت له
        final currentUserId = Supabase.instance.client.auth.currentUser?.id;
        if (updatedReview.userId == currentUserId) {
          userReview = updatedReview;
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error fetching updated review: $e');
    }
  }

  void _handleReviewDelete(Map<String, dynamic> data) {
    final deletedId = data['id'] as int;
    reviews.removeWhere((r) => r.id == deletedId);

    // حذف مراجعة المستخدم إذا كانت له
    if (userReview?.id == deletedId) {
      userReview = null;
    }

    notifyListeners();
  }

  // إضافة/تعديل مراجعة
  Future<bool> submitReview({required int rating, String? comment}) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final review = await _supabaseService.upsertReview(
        companyId: companyId,
        rating: rating,
        comment: comment,
      );

      // تحديث محلي فوري
      userReview = review;

      // تحديث أو إضافة في القائمة
      final index = reviews.indexWhere((r) => r.id == review.id);
      if (index != -1) {
        reviews[index] = review;
      } else {
        reviews.insert(0, review);
      }

      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'حدث خطأ أثناء إرسال التقييم';
      debugPrint('❌ Error submitting review: $e');
      notifyListeners();
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  // حذف مراجعة
  Future<bool> deleteReview() async {
    if (userReview == null) return false;

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _supabaseService.deleteReview(companyId);

      // حذف محلي فوري
      reviews.removeWhere((r) => r.id == userReview!.id);
      userReview = null;

      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'حدث خطأ أثناء حذف التقييم';
      debugPrint('❌ Error deleting review: $e');
      notifyListeners();
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  // إحصائيات التقييمات
  double get averageRating {
    if (reviews.isEmpty) return 0.0;
    final sum = reviews.fold<int>(0, (sum, review) => sum + review.rating);
    return sum / reviews.length;
  }

  int get totalReviews => reviews.length;

  // توزيع النجوم
  Map<int, int> get ratingDistribution {
    final distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var review in reviews) {
      distribution[review.rating] = (distribution[review.rating] ?? 0) + 1;
    }
    return distribution;
  }

  // النسبة المئوية لكل نجمة
  double getRatingPercentage(int stars) {
    if (reviews.isEmpty) return 0.0;
    final count = ratingDistribution[stars] ?? 0;
    return (count / reviews.length) * 100;
  }

  // هل المستخدم قيّم الشركة؟
  bool get hasUserReviewed => userReview != null;

  @override
  void dispose() {
    if (_reviewsChannel != null) {
      Supabase.instance.client.removeChannel(_reviewsChannel!);
      _reviewsChannel = null;
    }
    super.dispose();
  }
}
