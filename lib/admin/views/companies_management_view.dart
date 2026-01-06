import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // ✅
import 'package:url_launcher/url_launcher_string.dart'; // Assuming url_launcher is available, otherwise will fallback
import 'package:kodio_app/admin/viewmodels/deals_management_viewmodel.dart';
import 'package:kodio_app/core/theme/app_theme.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/company_model.dart';
import '../viewmodels/companies_management_viewmodel.dart';
import 'widgets/company_editor_form.dart'; // تأكد من المسار الصحيح

class CompaniesManagementView extends StatelessWidget {
  const CompaniesManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isEditorVisible = context
        .watch<CompaniesManagementViewModel>()
        .isEditorVisible;

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: isEditorVisible ? 3 : 5,
            child: const CompaniesTable(),
          ),
          if (isEditorVisible) ...[
            const VerticalDivider(thickness: 1, width: 1, color: Colors.black),
            const Expanded(flex: 2, child: CompanyEditorForm()),
          ],
        ],
      ),
    );
  }
}

class CompaniesTable extends StatelessWidget {
  const CompaniesTable({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CompaniesManagementViewModel>();
    final vmRead = context.read<CompaniesManagementViewModel>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إدارة الشركات',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: AppTheme.kLightText),
              ),
              ElevatedButton.icon(
                onPressed: vmRead.showEditorForNewCompany,
                icon: const Icon(Icons.add),
                label: const Text('إضافة شركة'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              color: AppTheme.kLightBackground,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: buildBody(context, vm, vmRead),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBody(
    BuildContext context,
    CompaniesManagementViewModel vm,
    CompaniesManagementViewModel vmRead,
  ) {
    if (vm.isLoading && vm.companies.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.kElectricLime),
      );
    }

    if (vm.errorMessage != null) {
      return Center(
        child: Text(
          vm.errorMessage!,
          style: const TextStyle(color: Colors.redAccent, fontSize: 16),
        ),
      );
    }

    if (vm.companies.isEmpty) {
      return Center(
        child: Text(
          'لا توجد شركات. أضف شركة جديدة!',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppTheme.kSubtleText),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: buildDataTable(context, vm, vmRead),
      ),
    );
  }

  Widget buildDataTable(
    BuildContext context,
    CompaniesManagementViewModel vm,
    CompaniesManagementViewModel vmRead,
  ) {
    const TextStyle headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: AppTheme.kElectricLime,
      fontSize: 16,
    );

    const TextStyle cellStyle = TextStyle(
      color: AppTheme.kLightText,
      fontSize: 15,
    );

    return DataTable(
      dataRowMinHeight: 60,
      dataRowMaxHeight: 80,
      headingRowHeight: 70,
      columnSpacing: 24,
      horizontalMargin: 24,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      columns: const [
        DataColumn(
          label: Expanded(
            child: Center(child: Text('الشعار', style: headerStyle)),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Center(child: Text('الغلاف', style: headerStyle)),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Center(child: Text('الاسم', style: headerStyle)),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Center(child: Text('الفئة', style: headerStyle)),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Center(child: Text('رقم الهاتف', style: headerStyle)),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Center(child: Text('البريد الإلكتروني', style: headerStyle)),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Center(child: Text('الموقع', style: headerStyle)),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Center(child: Text('الوصف', style: headerStyle)),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Center(child: Text('العنوان', style: headerStyle)),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Center(child: Text('ساعات العمل', style: headerStyle)),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Center(child: Text('عدد العروض', style: headerStyle)),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Center(child: Text('تواصل', style: headerStyle)),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Center(child: Text('إجراءات', style: headerStyle)),
          ),
        ),
      ],
      rows: vm.companies.map((company) {
        return DataRow(
          color: WidgetStateProperty.resolveWith((states) {
            if (vm.companies.indexOf(company) % 2 == 0) {
              return AppTheme.kLightBackground;
            }
            return AppTheme.kDarkBackground.withAlpha(128);
          }),
          cells: [
            // الشعار
            DataCell(Center(child: _buildCompanyLogo(company.logoUrl))),

            // ✅ صورة الغلاف (Cover) معدّلة
            DataCell(
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      company.coverImageUrl != null &&
                          company.coverImageUrl!.isNotEmpty
                      ? Image.network(
                          company.coverImageUrl!,
                          width: 100,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 100,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppTheme.kSubtleText.withAlpha(51),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 30,
                                  color: AppTheme.kSubtleText,
                                ),
                              ),
                        )
                      : Container(
                          width: 100,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.kSubtleText.withAlpha(51),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.panorama,
                            size: 30,
                            color: AppTheme.kSubtleText,
                          ),
                        ),
                ),
              ),
            ),

            // اسم الشركة
            DataCell(
              Center(
                child: _buildCellWithTooltip(
                  company.name,
                  cellStyle.copyWith(fontWeight: FontWeight.bold),
                  maxWidth: 180,
                ),
              ),
            ),

            // الفئة
            DataCell(
              Center(
                child: _buildCellWithTooltip(
                  company.categoryName ?? '(غير محدد)',
                  cellStyle.copyWith(
                    color: company.categoryName != null
                        ? AppTheme.kLightText
                        : AppTheme.kSubtleText,
                  ),
                  maxWidth: 120,
                ),
              ),
            ),

            // رقم الهاتف
            DataCell(
              Center(
                child: _buildCellWithTooltip(
                  company.phone ?? '-',
                  cellStyle,
                  maxWidth: 120,
                ),
              ),
            ),

            // البريد الإلكتروني
            DataCell(
              Center(
                child: _buildCellWithTooltip(
                  company.email ?? '-',
                  cellStyle,
                  maxWidth: 150,
                ),
              ),
            ),

            // الموقع
            DataCell(
              Center(
                child: _buildCellWithTooltip(
                  company.website ?? '-',
                  cellStyle,
                  maxWidth: 150,
                ),
              ),
            ),

            // الوصف
            DataCell(
              Center(
                child: _buildExpandableText(
                  company.description ?? '-',
                  cellStyle,
                  maxWidth: 200,
                ),
              ),
            ),

            // العنوان
            DataCell(
              Center(
                child: _buildCellWithTooltip(
                  company.address ?? '-',
                  cellStyle,
                  maxWidth: 150,
                ),
              ),
            ),

            // ساعات العمل
            DataCell(
              Center(
                child: _buildCellWithTooltip(
                  company.workingHours ?? '-',
                  cellStyle,
                  maxWidth: 120,
                ),
              ),
            ),

            // عدد العروض
            DataCell(
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.kElectricLime.withAlpha(51),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${company.dealCount ?? 0}',
                    style: cellStyle.copyWith(
                      color: AppTheme.kElectricLime,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // تواصل (Social Media)
            DataCell(Center(child: _buildSocialIcons(company.socialLinks))),

            // الإجراءات
            DataCell(
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const FaIcon(
                        FontAwesomeIcons.penToSquare,
                        size: 20,
                        color: Colors.blueAccent,
                      ),
                      tooltip: 'تعديل',
                      onPressed: () {
                        vmRead.selectCompanyForEdit(company);
                      },
                    ),
                    IconButton(
                      icon: const FaIcon(
                        FontAwesomeIcons.trashCan,
                        size: 20,
                        color: Colors.redAccent,
                      ),
                      tooltip: 'حذف',
                      onPressed: () {
                        _showDeleteConfirmDialog(context, vmRead, company);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCellWithTooltip(
    String text,
    TextStyle style, {
    double maxWidth = 150,
  }) {
    if (text == '-' || text.isEmpty) {
      return Text('-', style: style.copyWith(color: AppTheme.kSubtleText));
    }

    return Tooltip(
      message: text,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Text(
          text,
          style: style,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _buildExpandableText(
    String text,
    TextStyle style, {
    double maxWidth = 200,
  }) {
    if (text == '-' || text.isEmpty) {
      return Text('-', style: style.copyWith(color: AppTheme.kSubtleText));
    }

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Tooltip(
        message: text,
        preferBelow: false,
        child: Text(
          text,
          style: style,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );
  }

  Widget _buildCompanyLogo(String? logoUrl) {
    if (logoUrl == null || logoUrl.isEmpty) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppTheme.kSubtleText.withAlpha(51),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const FaIcon(
          FontAwesomeIcons.building,
          size: 25,
          color: AppTheme.kSubtleText,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        logoUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.kSubtleText.withAlpha(51),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const FaIcon(
            FontAwesomeIcons.image,
            size: 25,
            color: AppTheme.kSubtleText,
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    CompaniesManagementViewModel vm,
    CompanyModel company,
  ) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.kLightBackground,
        title: Text(
          'تأكيد الحذف',
          style: TextStyle(color: Colors.red.shade400),
        ),
        content: Text(
          'أنت على وشك حذف شركة "${company.name}" وكل العروض التابعة لها (عددها: ${company.dealCount ?? 0}). هل أنت متأكد؟',
          style: const TextStyle(color: AppTheme.kSubtleText),
        ),
        actions: [
          TextButton(
            child: const Text(
              'إلغاء',
              style: TextStyle(color: AppTheme.kSubtleText),
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('نعم، احذف الكل'),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await vm.deleteCompany(company.id);
              if (context.mounted) {
                context.read<DealsManagementViewModel>().fetchDeals();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcons(Map<String, dynamic>? socialLinks) {
    if (socialLinks == null || socialLinks.isEmpty) {
      return Text('-', style: const TextStyle(color: AppTheme.kSubtleText));
    }

    final List<Widget> icons = [];

    void addIcon(String key, IconData icon, Color color) {
      final url = socialLinks[key] as String?;
      if (url != null && url.isNotEmpty) {
        icons.add(
          InkWell(
            onTap: () async {
              if (await canLaunchUrlString(url)) {
                await launchUrlString(url);
              }
            },
            child: Tooltip(
              message: url,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6.0,
                ), // Increased padding slightly
                child: FaIcon(icon, size: 20, color: color), // ✅ FaIcon
              ),
            ),
          ),
        );
      }
    }

    addIcon('facebook', FontAwesomeIcons.facebook, const Color(0xFF1877F2));
    addIcon('instagram', FontAwesomeIcons.instagram, const Color(0xFFE4405F));
    addIcon('whatsapp', FontAwesomeIcons.whatsapp, const Color(0xFF25D366));
    addIcon('telegram', FontAwesomeIcons.telegram, const Color(0xFF0088cc));
    addIcon('linkedin', FontAwesomeIcons.linkedin, const Color(0xFF0077b5));
    addIcon('tiktok', FontAwesomeIcons.tiktok, Colors.black);

    if (icons.isEmpty) {
      return Text('-', style: const TextStyle(color: AppTheme.kSubtleText));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: icons,
    );
  }
}
