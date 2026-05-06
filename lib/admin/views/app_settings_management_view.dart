import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';

class AppSettingsManagementView extends StatefulWidget {
  const AppSettingsManagementView({super.key});

  @override
  State<AppSettingsManagementView> createState() => _AppSettingsManagementViewState();
}

class _AppSettingsManagementViewState extends State<AppSettingsManagementView> {
  final SupabaseService _supabaseService = SupabaseService();
  final TextEditingController _popularSearchesController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _popularSearchesController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final settings = await _supabaseService.getAppSettings();
      if (mounted) {
        setState(() {
          _popularSearchesController.text = settings['popular_searches'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل الإعدادات: $e')),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      await _supabaseService.updateAppSetting(
        'popular_searches',
        _popularSearchesController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم الحفظ بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ أثناء الحفظ: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kDarkBackground,
      appBar: AppBar(
        title: const Text(
          'إعدادات التطبيق',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.kLightBackground,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.kElectricLime),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: AppTheme.kLightBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.search, color: AppTheme.kElectricLime),
                              const SizedBox(width: 8),
                              const Text(
                                'مقترحات البحث الشائعة',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'اكتب الكلمات المقترحة للبحث مفصولة بفاصلة (,)\nمثال: سينما,فانتوم,طلباتي,مطاعم',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _popularSearchesController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'أدخل كلمات البحث...',
                              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                              filled: true,
                              fillColor: AppTheme.kDarkBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveSettings,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.kElectricLime,
                                foregroundColor: AppTheme.kDarkBackground,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isSaving
                                  ? const CircularProgressIndicator(color: AppTheme.kDarkBackground)
                                  : const Text(
                                      'حفظ التعديلات',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
