import 'package:flutter/material.dart';
import 'package:kodio_app/core/theme/app_theme.dart';
import 'package:provider/provider.dart';

import '../../core/models/category_model.dart';
import '../viewmodels/categories_management_viewmodel.dart';
import 'widgets/category_editor_form.dart';

class CategoriesManagementView extends StatelessWidget {
  const CategoriesManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isEditorVisible = context
        .watch<CategoriesManagementViewModel>()
        .isEditorVisible;

    return Scaffold(
      body: Row(
        children: [
          Expanded(flex: isEditorVisible ? 3 : 5, child: _CategoriesTable()),
          if (isEditorVisible) ...[
            VerticalDivider(thickness: 1, width: 1, color: Colors.black),
            Expanded(flex: 2, child: CategoryEditorForm()),
          ],
        ],
      ),
    );
  }
}

class _CategoriesTable extends StatelessWidget {
  const _CategoriesTable();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CategoriesManagementViewModel>();
    final vmRead = context.read<CategoriesManagementViewModel>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'جدول الفئات',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: AppTheme.kLightText),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  vmRead.showEditorForNewCategory();
                },
                icon: Icon(Icons.add),
                label: Text('إضافة فئة جديدة'),
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
    CategoriesManagementViewModel vm,
    CategoriesManagementViewModel vmRead,
  ) {
    if (vm.isLoading && vm.categories.isEmpty) {
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

    if (vm.categories.isEmpty) {
      return Center(
        child: Text(
          'لا توجد فئات حالياً.',
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
    CategoriesManagementViewModel vm,
    CategoriesManagementViewModel vmRead,
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
      dataRowMinHeight: 70,
      dataRowMaxHeight: 70,
      headingRowHeight: 70,
      columnSpacing: 24,
      horizontalMargin: 24,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      columns: [
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
        DataColumn(
          label: Expanded(
            child: Center(child: Text('اسم الفئة', style: headerStyle)),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Center(child: Text('الأيقونة', style: headerStyle)),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Center(child: Text('إجراءات', style: headerStyle)),
          ),
        ),
      ],
      rows: vm.categories.map((category) {
        return DataRow(
          color: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            if (vm.categories.indexOf(category) % 2 == 0) {
              return AppTheme.kLightBackground;
            }
            return AppTheme.kDarkBackground.withAlpha(128);
          }),
          cells: [
            // ✨ عرض ID
            DataCell(
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.kElectricLime.withAlpha(51),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#${category.id}',
                    style: TextStyle(
                      color: AppTheme.kElectricLime,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // الصورة
            DataCell(Center(child: _buildCategoryImage(category.imageUrl))),
            // اسم الفئة
            DataCell(
              Center(
                child: Text(
                  category.name,
                  style: cellStyle.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            // اسم الأيقونة
            DataCell(
              Center(
                child: Text(
                  category.iconName ?? '(لا يوجد)',
                  style: cellStyle.copyWith(
                    color: category.iconName != null
                        ? AppTheme.kLightText
                        : AppTheme.kSubtleText,
                  ),
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
                        vmRead.selectCategoryForEdit(category);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.redAccent),
                      tooltip: 'حذف',
                      onPressed: () {
                        _showDeleteConfirmDialog(context, vmRead, category);
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

  Widget _buildCategoryImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppTheme.kSubtleText.withAlpha(51),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.category, size: 30, color: AppTheme.kSubtleText),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppTheme.kSubtleText.withAlpha(51),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.image_not_supported,
            size: 30,
            color: AppTheme.kSubtleText,
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    CategoriesManagementViewModel vm,
    CategoryModel category,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'تأكيد الحذف',
          style: TextStyle(color: AppTheme.kLightText),
        ),
        content: Text(
          'هل أنت متأكد أنك تريد حذف فئة "${category.name}"؟\n\nملاحظة: قد تؤثر على العروض والشركات المرتبطة بها.',
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
              vm.deleteCategory(category.id);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
