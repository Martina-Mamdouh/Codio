import 'package:flutter/material.dart';
import 'package:kodio_app/core/theme/app_theme.dart';
import 'package:provider/provider.dart';

import '../../core/models/banner_model.dart';
import '../viewmodels/banners_management_viewmodel.dart';
import 'widgets/banner_editor_form.dart';

class BannersManagementView extends StatelessWidget {
  const BannersManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isEditorVisible = context
        .watch<BannersManagementViewModel>()
        .isEditorVisible;

    return Scaffold(
      body: Row(
        children: [
          Expanded(flex: isEditorVisible ? 3 : 5, child: _BannersTable()),
          if (isEditorVisible) ...[
            VerticalDivider(thickness: 1, width: 1, color: Colors.black),
            Expanded(flex: 2, child: BannerEditorForm()),
          ],
        ],
      ),
    );
  }
}

class _BannersTable extends StatelessWidget {
  const _BannersTable();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BannersManagementViewModel>();
    final vmRead = context.read<BannersManagementViewModel>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'جدول البانرات',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: AppTheme.kLightText),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  vmRead.showEditorForNewBanner();
                },
                icon: Icon(Icons.add),
                label: Text('إضافة بانر جديد'),
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: Card(
              color: AppTheme.kLightBackground,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: _buildBody(context, vm, vmRead),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    BannersManagementViewModel vm,
    BannersManagementViewModel vmRead,
  ) {
    if (vm.isLoading && vm.banners.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: AppTheme.kElectricLime),
      );
    }

    if (vm.errorMessage != null) {
      return Center(
        child: Text(
          'خطأ: ${vm.errorMessage}',
          style: TextStyle(color: Colors.redAccent, fontSize: 16),
        ),
      );
    }

    if (vm.banners.isEmpty) {
      return Center(
        child: Text(
          'لا توجد بانرات حالياً.',
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
        child: _buildDataTable(context, vm, vmRead),
      ),
    );
  }

  Widget _buildDataTable(
    BuildContext context,
    BannersManagementViewModel vm,
    BannersManagementViewModel vmRead,
  ) {
    final TextStyle headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: AppTheme.kElectricLime,
      fontSize: 16,
    );
    final TextStyle cellStyle = TextStyle(
      color: AppTheme.kLightText,
      fontSize: 15,
    );

    return DataTable(
      dataRowMinHeight: 80,
      dataRowMaxHeight: 80,
      headingRowHeight: 70,
      columnSpacing: 24,
      horizontalMargin: 24,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      columns: [
        // ✨ عمود ID
        DataColumn(
          label: Expanded(
            child: Center(child: Text('ID', style: headerStyle)),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Center(child: Text('الصورة', style: headerStyle)),
          ),
        ),
        // ✨ عمود Deal ID
        DataColumn(
          label: Expanded(
            child: Center(child: Text('Deal ID', style: headerStyle)),
          ),
        ),
        // ✨ عمود اسم العرض
        DataColumn(
          label: Expanded(
            child: Center(child: Text('العرض المرتبط', style: headerStyle)),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Center(child: Text('إجراءات', style: headerStyle)),
          ),
        ),
      ],
      rows: vm.banners.map((banner) {
        return DataRow(
          color: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            if (vm.banners.indexOf(banner) % 2 == 0) {
              return AppTheme.kLightBackground;
            }
            return AppTheme.kDarkBackground.withAlpha(128);
          }),
          cells: [
            // ✨ عرض ID
            DataCell(
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#${banner.id}',
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
            // الصورة
            DataCell(
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    banner.imageUrl,
                    width: 120,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 120,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.kSubtleText.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.image_not_supported,
                        size: 25,
                        color: AppTheme.kSubtleText,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // ✨ Deal ID
            DataCell(
              Center(
                child: banner.dealId != null
                    ? Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.kElectricLime.withAlpha(51),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#${banner.dealId}',
                          style: TextStyle(
                            color: AppTheme.kElectricLime,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      )
                    : Text(
                        '(غير مرتبط)',
                        style: cellStyle.copyWith(color: AppTheme.kSubtleText),
                      ),
              ),
            ),
            // ✨ اسم العرض المرتبط
            DataCell(
              Center(
                child: banner.dealId != null
                    ? Text(
                        vm.getDealNameById(banner.dealId!) ?? 'عرض محذوف',
                        style: cellStyle.copyWith(
                          color: vm.getDealNameById(banner.dealId!) != null
                              ? AppTheme.kLightText
                              : Colors.redAccent,
                        ),
                      )
                    : Text(
                        '-',
                        style: cellStyle.copyWith(color: AppTheme.kSubtleText),
                      ),
              ),
            ),
            // الإجراءات
            DataCell(
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blueAccent),
                      tooltip: 'تعديل',
                      onPressed: () {
                        vmRead.selectBannerForEdit(banner);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.redAccent),
                      tooltip: 'حذف',
                      onPressed: () {
                        _showDeleteConfirmDialog(context, vmRead, banner);
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

  void _showDeleteConfirmDialog(
    BuildContext context,
    BannersManagementViewModel vm,
    BannerModel banner,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'تأكيد الحذف',
          style: TextStyle(color: AppTheme.kLightText),
        ),
        content: Text(
          'هل أنت متأكد أنك تريد حذف هذا البانر؟',
          style: TextStyle(color: AppTheme.kSubtleText),
        ),
        actions: [
          TextButton(
            child: Text('إلغاء', style: TextStyle(color: AppTheme.kSubtleText)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: Text('حذف'),
            onPressed: () {
              vm.deleteBanner(banner.id);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
