// lib/app/views/widgets/company_info_tab.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kodio_app/app/viewmodels/company_profile_view_model.dart';
import '../../../core/theme/app_theme.dart';

class CompanyInfoTab extends StatelessWidget {
  final CompanyProfileViewModel viewModel;
  const CompanyInfoTab({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final c = viewModel.company!;
    final dealsCount = c.dealCount ?? viewModel.deals.length;
    final rating = c.rating ?? 0.0;
    final followers = c.followersCount ?? 0;
    final reviews = c.reviewsCount ?? 0;

    return RefreshIndicator(
      onRefresh: viewModel.loadCompanyData,
      color: AppTheme.kElectricLime,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // كروت الإحصائيات
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.local_offer_outlined,
                    label: 'العروض',
                    value: dealsCount.toString(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    icon: Icons.group_outlined,
                    label: 'المتابعون',
                    value: followers.toString(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    icon: Icons.star_rate_rounded,
                    label: 'التقييم',
                    value: rating.toStringAsFixed(1),
                    subtitle: '$reviews تقييم',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ✅ مجالات الشركة (جديد)
            if (viewModel.getCompanyCategoryNames().isNotEmpty) ...[
              const Text(
                'مجالات الشركة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  //  // Inherited
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: viewModel.getCompanyCategoryNames().map((name) {
                  return Chip(
                    label: Text(
                      name,
                      style: const TextStyle(
                        color: AppTheme.kDarkBackground,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: AppTheme.kElectricLime,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 0,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide.none,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Divider(color: Colors.white12),
            ],

            // حول
            const Text(
              'حول',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                //  // Inherited
              ),
            ),
            const SizedBox(height: 8),
            _CompactTextBox(
              text: (c.description ?? '').isNotEmpty
                  ? c.description!
                  : 'لا يوجد وصف حالياً',
            ),

            const SizedBox(height: 20),

            // معلومات الاتصال
            const Text(
              'معلومات الاتصال',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                //  // Inherited
              ),
            ),
            const SizedBox(height: 12),

            if ((c.address ?? '').isNotEmpty) ...[
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: AppTheme.kElectricLime,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      c.address!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        //  // Inherited
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],

            if ((c.phone ?? '').isNotEmpty) ...[
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    color: AppTheme.kElectricLime,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      c.phone!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        //  // Inherited
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],

            if ((c.website ?? '').isNotEmpty) ...[
              Row(
                children: [
                  const Icon(
                    Icons.language,
                    color: AppTheme.kElectricLime,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      c.website!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        //  // Inherited
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],

            if ((c.email ?? '').isNotEmpty) ...[
              Row(
                children: [
                  const Icon(
                    Icons.email_outlined,
                    color: AppTheme.kElectricLime,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      c.email!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        //  // Inherited
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],

            if ((c.address ?? '').isEmpty &&
                (c.phone ?? '').isEmpty &&
                (c.website ?? '').isEmpty &&
                (c.email ?? '').isEmpty)
              const Text(
                'لا توجد بيانات تواصل متاحة',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  //  // Inherited
                ),
              ),

            const SizedBox(height: 20),

            // ساعات العمل
            const Text(
              'ساعات العمل',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                //  // Inherited
              ),
            ),
            const SizedBox(height: 8),
            _CompactTextBox(
              text: (c.workingHours ?? '').isNotEmpty
                  ? c.workingHours!
                  : 'لا توجد ساعات عمل متاحة',
            ),

            const SizedBox(height: 20),

            // الموقع
            const Text(
              'الموقع',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                //  // Inherited
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.map_outlined,
                  color: AppTheme.kElectricLime,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    (c.address ?? '').isNotEmpty ? c.address! : 'لا يوجد عنوان',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      //  // Inherited
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    viewModel.incrementMapClicks();
                    final uri = Uri.parse(
                      'https://www.google.com/maps/search/?api=1&query=${c.lat},${c.lng}',
                    );
                    launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                  child: const Text(
                    'فتح الخريطة',
                    style: TextStyle(
                      color: AppTheme.kElectricLime,
                      fontSize: 13,
                      //  // Inherited
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // التواصل الاجتماعي (Social Media)
            if (c.socialLinks != null && c.socialLinks!.isNotEmpty) ...[
              const Text(
                'تواصل معنا',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  //  // Inherited
                ),
              ),
              const SizedBox(height: 12),
              _SocialLinks(socialLinks: c.socialLinks!, viewModel: viewModel),
            ],

            // ✅ الفروع
            if ((c.branches ?? []).isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'الفروع',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...c.branches!.map(
                (branch) => Card(
                  color: AppTheme.kLightBackground,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // اسم الفرع
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: AppTheme.kElectricLime,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                branch.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if ((branch.address ?? '').isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.map_outlined,
                                color: AppTheme.kSubtleText,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  branch.address!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if ((branch.phone ?? '').isNotEmpty) ...[
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () =>
                                launchUrl(Uri.parse('tel:${branch.phone}')),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.phone_outlined,
                                  color: AppTheme.kSubtleText,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  branch.phone!,
                                  style: const TextStyle(
                                    color: AppTheme.kElectricLime,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if ((branch.workingHours ?? '').isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: AppTheme.kSubtleText,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                branch.workingHours!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                        // مواقع التواصل الاجتماعي للفرع
                        if (branch.socialLinks != null &&
                            branch.socialLinks!.values.any(
                              (v) => (v as String? ?? '').isNotEmpty,
                            )) ...[
                          const SizedBox(height: 10),
                          const Divider(color: Colors.white10),
                          const SizedBox(height: 6),
                          _BranchSocialLinks(socialLinks: branch.socialLinks!),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ✅ Branch Social Links Widget
class _BranchSocialLinks extends StatelessWidget {
  final Map<String, dynamic> socialLinks;
  const _BranchSocialLinks({required this.socialLinks});

  @override
  Widget build(BuildContext context) {
    final items = <({IconData icon, Color color, String url})>[];

    void add(String key, IconData icon, Color color) {
      final v = socialLinks[key] as String? ?? '';
      if (v.isNotEmpty) items.add((icon: icon, color: color, url: v));
    }

    add('facebook', FontAwesomeIcons.facebook, const Color(0xFF1877F2));
    add('whatsapp', FontAwesomeIcons.whatsapp, const Color(0xFF25D366));
    add('telegram', FontAwesomeIcons.telegram, const Color(0xFF0088CC));
    add('linkedin', FontAwesomeIcons.linkedin, const Color(0xFF0A66C2));
    add('tiktok', FontAwesomeIcons.tiktok, Colors.white);
    add('instagram', FontAwesomeIcons.instagram, const Color(0xFFE4405F));

    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return InkWell(
          onTap: () async {
            try {
              final uri = Uri.parse(item.url.trim());
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (_) {}
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.kDarkBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Center(
              child: FaIcon(item.icon, color: item.color, size: 18),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.kLightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.kElectricLime, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle ?? label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialLinks extends StatelessWidget {
  final Map<String, dynamic> socialLinks;
  final CompanyProfileViewModel viewModel;

  const _SocialLinks({required this.socialLinks, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final c = viewModel.company!;
    final List<Widget> icons = [];

    // Helper to add social icons with tracking
    void addIcon(String platform, IconData icon, Color color, String? url) {
      if (url != null && url.trim().isNotEmpty) {
        icons.add(
          InkWell(
            onTap: () async {
              viewModel.incrementSocialClicks(platform);
              final uri = Uri.parse(url.trim());
              try {
                if (!await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                )) {
                  debugPrint('Could not launch $uri');
                }
              } catch (e) {
                debugPrint('Error launching social: $e');
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: AppTheme.kLightBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Center(child: FaIcon(icon, color: color, size: 22)),
            ),
          ),
        );
      }
    }

    // 1. Instagram (From new field)
    addIcon(
      'instagram',
      FontAwesomeIcons.instagram,
      const Color(0xFFE4405F),
      c.instagramUrl,
    );

    // 2. Facebook (From socialLinks map)
    addIcon(
      'facebook',
      FontAwesomeIcons.facebook,
      const Color(0xFF1877F2),
      socialLinks['facebook'] as String?,
    );

    // 3. WhatsApp (From socialLinks map)
    addIcon(
      'whatsapp',
      FontAwesomeIcons.whatsapp,
      const Color(0xFF25D366),
      socialLinks['whatsapp'] as String?,
    );

    if (icons.isEmpty) return const SizedBox();

    return Wrap(spacing: 12, runSpacing: 12, children: icons);
  }
}

class _CompactTextBox extends StatelessWidget {
  final String text;
  const _CompactTextBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.kLightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          height: 1.5, // Compact line height
        ),
      ),
    );
  }
}
