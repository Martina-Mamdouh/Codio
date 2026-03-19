import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';

class SocialLinksManagementView extends StatefulWidget {
  const SocialLinksManagementView({super.key});

  @override
  State<SocialLinksManagementView> createState() =>
      _SocialLinksManagementViewState();
}

class _SocialLinksManagementViewState extends State<SocialLinksManagementView> {
  final _service = SupabaseService();
  bool _isLoading = true;
  bool _isSaving = false;

  // Controllers for each platform
  final _controllers = <String, TextEditingController>{
    'whatsapp_url': TextEditingController(),
    'instagram_url': TextEditingController(),
    'telegram_url': TextEditingController(),
    'facebook_url': TextEditingController(),
    'tiktok_url': TextEditingController(),
    'linkedin_url': TextEditingController(),
  };

  // Meta per platform
  static const _platforms = [
    _PlatformMeta(
      key: 'whatsapp_url',
      label: 'واتساب',
      hint: 'https://wa.me/201XXXXXXXXX',
      icon: FontAwesomeIcons.whatsapp,
      color: Color(0xFF25D366),
    ),
    _PlatformMeta(
      key: 'instagram_url',
      label: 'إنستقرام',
      hint: 'https://instagram.com/yourpage',
      icon: FontAwesomeIcons.instagram,
      color: Color(0xFFE1306C),
    ),
    _PlatformMeta(
      key: 'telegram_url',
      label: 'تيليجرام',
      hint: 'https://t.me/yourchannel',
      icon: FontAwesomeIcons.telegram,
      color: Color(0xFF0088CC),
    ),
    _PlatformMeta(
      key: 'facebook_url',
      label: 'فيسبوك',
      hint: 'https://facebook.com/yourpage',
      icon: FontAwesomeIcons.facebook,
      color: Color(0xFF1877F2),
    ),
    _PlatformMeta(
      key: 'tiktok_url',
      label: 'تيك توك',
      hint: 'https://tiktok.com/@yourpage',
      icon: FontAwesomeIcons.tiktok,
      color: Colors.white,
    ),
    _PlatformMeta(
      key: 'linkedin_url',
      label: 'لينكد إن',
      hint: 'https://linkedin.com/company/yourpage',
      icon: FontAwesomeIcons.linkedin,
      color: Color(0xFF0A66C2),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final data = await _service.getAppSettings();
    for (final entry in data.entries) {
      _controllers[entry.key]?.text = entry.value;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      for (final p in _platforms) {
        await _service.updateAppSetting(
          p.key,
          _controllers[p.key]!.text.trim(),
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم حفظ الروابط بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ فشل الحفظ: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.kElectricLime),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'روابط التواصل الاجتماعي',
            style: TextStyle(
              color: AppTheme.kLightText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'الروابط الفارغة لن تظهر للمستخدمين في التطبيق',
            style: TextStyle(color: AppTheme.kSubtleText, fontSize: 14),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: _platforms.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                final p = _platforms[i];
                return _buildField(p);
              },
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(
                _isSaving ? 'جاري الحفظ...' : 'حفظ جميع الروابط',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.kElectricLime,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(_PlatformMeta p) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.kLightBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: p.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: FaIcon(p.icon, color: p.color, size: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.label,
                  style: const TextStyle(
                    color: AppTheme.kLightText,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controllers[p.key],
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: p.hint,
                    hintStyle: const TextStyle(
                      color: Colors.white30,
                      fontSize: 12,
                    ),
                    filled: true,
                    fillColor: AppTheme.kDarkBackground,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppTheme.kElectricLime,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatformMeta {
  final String key;
  final String label;
  final String hint;
  final IconData icon;
  final Color color;

  const _PlatformMeta({
    required this.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.color,
  });
}
