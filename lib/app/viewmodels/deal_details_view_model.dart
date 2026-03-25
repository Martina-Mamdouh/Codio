import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/company_model.dart';
import '../../core/models/deal_model.dart';
import '../../core/services/supabase_service.dart';

class DealDetailsViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  CompanyModel? company;
  bool isLoadingCompany = false;

  // Counters for interaction tracking
  int copyCodeCount = 0;
  int openLinkCount = 0;
  int imageClickCount = 0;
  int dealViews = 0;
  int companyViews = 0;

  void incrementDealViews() {
    dealViews++;
    notifyListeners();
  }

  void incrementImageClick() {
    imageClickCount++;
    notifyListeners();
  }

  // تحميل بيانات الشركة (خصوصاً اللوجو)
  Future<void> loadCompanyData(int companyId) async {
    isLoadingCompany = true;
    notifyListeners();

    try {
      company = await _supabaseService.getCompanyById(companyId);
      companyViews++;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading company: $e');
    } finally {
      isLoadingCompany = false;
      notifyListeners();
    }
  }

  // نسخ الكود
  Future<void> copyCode(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    copyCodeCount++;
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
  Future<void> openDealLink(String url) async {
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

      // 3) محاولة الإطلاق
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint('❌ Cannot launch URL: $cleaned');
      } else {
        openLinkCount++;
        notifyListeners();
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
