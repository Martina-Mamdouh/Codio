import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/company_model.dart';
import '../../core/models/deal_model.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/analytics_service.dart';

class DealDetailsViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final AnalyticsService _analyticsService = AnalyticsService();

  CompanyModel? company;
  bool isLoadingCompany = false;

  // Counters for interaction tracking (kept for backward compatibility)
  int copyCodeCount = 0;
  int openLinkCount = 0;
  int imageClickCount = 0;
  int dealViews = 0;
  int companyViews = 0;

  void incrementDealViews(int dealId) {
    dealViews++;
    _analyticsService.trackDealView(dealId);
    notifyListeners();
  }

  void incrementImageClick(int dealId) {
    imageClickCount++;
    _analyticsService.trackDealImageClick(dealId);
    notifyListeners();
  }

  // تحميل بيانات الشركة (خصوصاً اللوجو) والإحصائيات
  Future<void> loadCompanyData(int companyId, int dealId) async {
    isLoadingCompany = true;
    notifyListeners();

    try {
      // Load all data in parallel
      await Future.wait([
        _supabaseService.getCompanyById(companyId).then((res) => company = res),
        loadDealStats(dealId),
        loadEmojiFeedbackStats(dealId),
      ]);

      companyViews++;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading detailed data: $e');
    } finally {
      isLoadingCompany = false;
      notifyListeners();
    }
  }

  // تحميل إحصائيات العرض الحقيقية من قاعدة البيانات
  Future<void> loadDealStats(int dealId) async {
    try {
      final stats = await _analyticsService.getDealAnalytics(dealId);
      if (stats != null) {
        dealViews = stats['view_count'] ?? 0;
        copyCodeCount = stats['code_copy_count'] ?? 0;
        openLinkCount = stats['link_open_count'] ?? 0;
        favorite_count = stats['favorite_count'] ?? 0;
        imageClickCount = stats['image_click_count'] ?? 0;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error loading deal stats: $e');
    }
  }

  int favorite_count = 0;

  // Emoji feedback statistics (from real user data)
  int happyCount = 0;
  int neutralCount = 0;
  int sadCount = 0;
  int totalEmojiCount = 0;
  String? userSelectedEmoji; // Which emoji the current user selected

  // الحسابات الديناميكية للواجهة
  double get calculatedSuccessRate {
    // عرض جديد بدون تقييمات = 5 نجوم (100%)
    if (totalEmojiCount == 0) return 100.0;

    // الأساس: متوسط الإيموجي (😊=5, 😐=3, 😞=1)
    final avg = ((happyCount * 5) + (neutralCount * 3) + (sadCount * 1)) / totalEmojiCount;

    // البونص: نسخ الكود / فتح الرابط يرفع التقييم لو ناقص (بحد أقصى +1 نجمة)
    double bonus = 0.0;
    if (avg < 5.0 && dealViews > 0) {
      bonus = ((copyCodeCount + openLinkCount) / dealViews).clamp(0.0, 1.0);
    }

    final finalRating = (avg + bonus).clamp(0.0, 5.0);
    return (finalRating / 5) * 100;
  }

  // توزيع الإيموجي من البيانات الفعلية
  double get emotionalHappy {
    if (totalEmojiCount == 0) return 0.0;
    return (happyCount / totalEmojiCount) * 100;
  }

  double get emotionalNeutral {
    if (totalEmojiCount == 0) return 0.0;
    return (neutralCount / totalEmojiCount) * 100;
  }

  double get emotionalSad {
    if (totalEmojiCount == 0) return 0.0;
    return (sadCount / totalEmojiCount) * 100;
  }

  /// Submit emoji feedback
  Future<bool> submitEmojiFeedback(int dealId, String emojiType) async {
    final success = await _analyticsService.trackEmojiFeedback(
      dealId,
      emojiType: emojiType,
    );

    if (success) {
      // Reload emoji stats after submission
      await loadEmojiFeedbackStats(dealId);
    }

    return success;
  }

  /// Load emoji feedback statistics
  Future<void> loadEmojiFeedbackStats(int dealId) async {
    try {
      // Load aggregated stats
      final stats = await _analyticsService.getEmojiFeedbackStats(dealId);
      if (stats != null) {
        happyCount = stats['happy_count'] ?? 0;
        neutralCount = stats['neutral_count'] ?? 0;
        sadCount = stats['sad_count'] ?? 0;
        totalEmojiCount = stats['total_count'] ?? 0;
        notifyListeners();
      }

      // Load user's selection
      userSelectedEmoji = await _analyticsService.getUserEmojiFeedback(dealId);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading emoji feedback stats: $e');
    }
  }

  // نسخ الكود
  Future<void> copyCode(BuildContext context, int dealId, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    copyCodeCount++;

    // Track in analytics
    await _analyticsService.trackCodeCopy(dealId, code: code);

    notifyListeners();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم نسخ الكود بنجاح'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // فتح رابط العرض
  Future<void> openDealLink(int dealId, String url) async {
    try {
      // 1) تنظيف أي Markdown أو مسافات
      var cleaned = url.trim();

      // لو جاي بالشكل [https://example.com](...)
      if (cleaned.startsWith('[') && cleaned.contains(']')) {
        final end = cleaned.indexOf(']');
        cleaned = cleaned.substring(1, end);
      }

      // 2) إضافة البروتوكول لو ناقص
      if (!cleaned.startsWith('http://') && !cleaned.startsWith('https://')) {
        cleaned = 'https://$cleaned';
      }

      debugPrint('🌐 Launching URL: $cleaned');
      final uri = Uri.parse(cleaned);

      // Update UI and trigger analytics immediately before app shifts to background
      openLinkCount++;
      notifyListeners();
      _analyticsService.trackLinkOpen(dealId, url: cleaned);

      // 3) محاولة الإطلاق
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint('❌ Cannot launch URL: $cleaned');
      }
    } catch (e) {
      debugPrint('❌ Error opening deal link: $e');
    }
  }

  // مشاركة العرض
  Future<void> shareDeal(DealModel deal) async {
    try {
      await Share.share(
        'تحقق من هذا العرض الرائع: ${deal.title}\n'
        'الخصم: ${deal.discountValue}\n'
        'ينتهي في: ${deal.expiresAt.toString().split(' ')[0]}',
      );
    } catch (e) {
      debugPrint('❌ Error sharing deal: $e');
    }
  }
}
