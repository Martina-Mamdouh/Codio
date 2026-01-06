import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';

class ReviewsManagementView extends StatefulWidget {
  const ReviewsManagementView({super.key});

  @override
  State<ReviewsManagementView> createState() => _ReviewsManagementViewState();
}

class _ReviewsManagementViewState extends State<ReviewsManagementView> {
  final supabaseService = SupabaseService();
  List<Map<String, dynamic>> reviews = [];
  bool isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => isLoading = true);
    try {
      reviews = await supabaseService.getAllReviewsForAdmin();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل التقييمات: $e')));
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  // فلترة التقييمات حسب البحث
  List<Map<String, dynamic>> get filteredReviews {
    if (_searchQuery.trim().isEmpty) return reviews;

    final query = _searchQuery.toLowerCase();
    return reviews.where((review) {
      final companyName = (review['companies']?['name'] ?? '')
          .toString()
          .toLowerCase();
      final userName = (review['users']?['full_name'] ?? '')
          .toString()
          .toLowerCase();
      final comment = (review['comment'] ?? '').toString().toLowerCase();

      return companyName.contains(query) ||
          userName.contains(query) ||
          comment.contains(query);
    }).toList();
  }

  Future<void> _deleteReview(int reviewId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.kLightBackground,
        title: const Text(
          'تأكيد الحذف',
          style: TextStyle(color: Colors.redAccent),
        ),
        content: const Text(
          'هل تريد حذف هذا التقييم نهائيًا؟',
          style: TextStyle(color: AppTheme.kLightText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await supabaseService.deleteReviewById(reviewId);
        await _loadReviews();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف التقييم بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في الحذف: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editReview(Map<String, dynamic> review) async {
    final ratingController = TextEditingController(
      text: review['rating'].toString(),
    );
    final commentController = TextEditingController(
      text: review['comment'] ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.kLightBackground,
        title: const Text(
          'تعديل التقييم',
          style: TextStyle(color: AppTheme.kElectricLime),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ratingController,
                decoration: const InputDecoration(
                  labelText: 'التقييم (1-5)',
                  labelStyle: TextStyle(color: AppTheme.kSubtleText),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.kLightText),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'التعليق',
                  labelStyle: TextStyle(color: AppTheme.kSubtleText),
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                style: const TextStyle(color: AppTheme.kLightText),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.kElectricLime,
              foregroundColor: AppTheme.kDarkBackground,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final newRating = int.tryParse(ratingController.text);
        if (newRating == null || newRating < 1 || newRating > 5) {
          throw Exception('التقييم يجب أن يكون بين 1 و 5');
        }

        await supabaseService.updateReviewById(
          review['id'],
          rating: newRating,
          comment: commentController.text.trim().isEmpty
              ? null
              : commentController.text.trim(),
        );

        await _loadReviews();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تعديل التقييم بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في التعديل: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    ratingController.dispose();
    commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kDarkBackground,
      // appBar: AppBar(
      //   title: const Text('جدول التقييمات'),
      //   backgroundColor: AppTheme.kDarkBackground,
      //   elevation: 0,
      // ),
      body: Column(
        children: [
          // شريط البحث
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: AppTheme.kLightText),
              decoration: InputDecoration(
                hintText: 'ابحث عن شركة، مستخدم، أو تعليق...',
                hintStyle: const TextStyle(color: AppTheme.kSubtleText),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.kElectricLime,
                ),
                filled: true,
                fillColor: AppTheme.kLightBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // عدد النتائج
          if (!isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    'عدد التقييمات: ${filteredReviews.length}',
                    style: const TextStyle(
                      color: AppTheme.kSubtleText,
                      fontSize: 14,
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    Text(
                      ' (من أصل ${reviews.length})',
                      style: const TextStyle(
                        color: AppTheme.kSubtleText,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // قائمة التقييمات
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.kElectricLime,
                    ),
                  )
                : filteredReviews.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isEmpty
                              ? Icons.rate_review_outlined
                              : Icons.search_off,
                          size: 64,
                          color: AppTheme.kSubtleText,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'لا توجد تقييمات'
                              : 'لا توجد نتائج للبحث',
                          style: const TextStyle(
                            color: AppTheme.kSubtleText,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredReviews.length,
                    itemBuilder: (context, index) {
                      final review = filteredReviews[index];
                      final user = review['users'] ?? {};
                      final company = review['companies'] ?? {};

                      return Card(
                        color: AppTheme.kLightBackground,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // اسم الشركة
                              Row(
                                children: [
                                  const Icon(
                                    Icons.business,
                                    color: AppTheme.kElectricLime,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      company['name'] ?? 'شركة غير معروفة',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.kElectricLime,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // اسم المستخدم
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    color: AppTheme.kSubtleText,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    user['full_name'] ?? 'غير معروف',
                                    style: const TextStyle(
                                      color: AppTheme.kLightText,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // النجوم والأزرار
                              Row(
                                children: [
                                  ...List.generate(
                                    5,
                                    (i) => Icon(
                                      i < (review['rating'] ?? 0)
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${review['rating']})',
                                    style: const TextStyle(
                                      color: AppTheme.kSubtleText,
                                    ),
                                  ),
                                  const Spacer(),

                                  // زر التعديل
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blueAccent,
                                      size: 20,
                                    ),
                                    tooltip: 'تعديل',
                                    onPressed: () => _editReview(review),
                                  ),

                                  // زر الحذف
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                    tooltip: 'حذف',
                                    onPressed: () =>
                                        _deleteReview(review['id']),
                                  ),
                                ],
                              ),

                              // التعليق
                              if (review['comment'] != null &&
                                  review['comment'].toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.kDarkBackground,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      review['comment'],
                                      style: const TextStyle(
                                        color: AppTheme.kLightText,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),

                              // تاريخ التقييم
                              if (review['created_at'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'تاريخ التقييم: ${_formatDate(review['created_at'])}',
                                    style: const TextStyle(
                                      color: AppTheme.kSubtleText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    try {
      final dateTime = DateTime.parse(date.toString());
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'تاريخ غير معروف';
    }
  }
}
