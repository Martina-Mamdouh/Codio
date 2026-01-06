import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kodio_app/core/theme/app_theme.dart';
import 'package:provider/provider.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/models/deal_model.dart';
import '../viewmodels/deals_management_viewmodel.dart';
import 'widgets/deal_editor_form.dart';

class DealsManagementView extends StatelessWidget {
  const DealsManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isEditorVisible = context
        .watch<DealsManagementViewModel>()
        .isEditorVisible;

    return Scaffold(
      body: Row(
        children: [
          Expanded(flex: isEditorVisible ? 3 : 5, child: _DealsTable()),
          if (isEditorVisible) ...[
            VerticalDivider(thickness: 1, width: 1, color: Colors.black),
            Expanded(flex: 2, child: DealEditorForm()),
          ],
        ],
      ),
    );
  }
}

class _DealsTable extends StatelessWidget {
  const _DealsTable();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DealsManagementViewModel>();
    final vmRead = context.read<DealsManagementViewModel>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'جدول العروض',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: AppTheme.kLightText),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  vmRead.showEditorForNewDeal();
                },
                icon: const FaIcon(FontAwesomeIcons.plus, size: 18),
                label: Text('إضافة عرض جديد'),
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
    DealsManagementViewModel vm,
    DealsManagementViewModel vmRead,
  ) {
    if (vm.isLoading && vm.deals.isEmpty) {
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

    if (vm.deals.isEmpty) {
      return Center(
        child: Text(
          'لا توجد عروض حالياً.',
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
    DealsManagementViewModel vm,
    DealsManagementViewModel vmRead,
  ) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
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
        DataColumn(
          label: Expanded(
            child: Center(child: Text('العنوان', style: headerStyle)),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Center(child: Text('الشركة', style: headerStyle)),
          ),
        ),
        // ✨ عمود الفئة
        DataColumn(
          label: Expanded(
            child: Center(child: Text('الفئة', style: headerStyle)),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Center(child: Text('نوع العرض', style: headerStyle)),
          ),
        ),
        // ✨ عمود الخصم
        DataColumn(
          label: Expanded(
            child: Center(child: Text('الخصم', style: headerStyle)),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Center(child: Text('الكود/الرابط', style: headerStyle)),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Center(child: Text('تاريخ البدء', style: headerStyle)),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Center(child: Text('تاريخ الانتهاء', style: headerStyle)),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Center(child: Text('إجراءات', style: headerStyle)),
          ),
        ),
      ],
      rows: vm.deals.map((deal) {
        return DataRow(
          color: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            if (vm.deals.indexOf(deal) % 2 == 0) {
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
                    color: AppTheme.kElectricLime.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#${deal.id}',
                    style: TextStyle(
                      color: AppTheme.kElectricLime,
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
                    deal.imageUrl,
                    width: 80,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.kSubtleText.withAlpha(51),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.image,
                        size: 20,
                        color: AppTheme.kSubtleText,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // العنوان
            DataCell(Center(child: Text(deal.title, style: cellStyle))),
            // الشركة
            DataCell(
              Center(
                child: Text(deal.companyName ?? 'غير معروف', style: cellStyle),
              ),
            ),
            // ✨ الفئة
            DataCell(
              Center(
                child: Text(
                  deal.categoryName ?? '(غير محدد)',
                  style: cellStyle.copyWith(
                    color: deal.categoryName != null
                        ? AppTheme.kLightText
                        : AppTheme.kSubtleText,
                  ),
                ),
              ),
            ),
            // نوع العرض
            DataCell(
              Center(
                child: Chip(
                  label: Text(
                    deal.dealType,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: AppTheme.kElectricLime,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            // ✨ الخصم
            DataCell(
              Center(
                child: Text(
                  deal.discountValue.isNotEmpty ? deal.discountValue : '-',
                  style: cellStyle.copyWith(
                    color: deal.discountValue.isNotEmpty
                        ? Colors.orangeAccent
                        : AppTheme.kSubtleText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // الكود/الرابط
            DataCell(Center(child: Text(deal.dealValue, style: cellStyle))),
            // تاريخ البدء
            DataCell(
              Center(
                child: Text(formatter.format(deal.startsAt), style: cellStyle),
              ),
            ),
            // تاريخ الانتهاء
            DataCell(
              Center(
                child: Text(formatter.format(deal.expiresAt), style: cellStyle),
              ),
            ),
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
                        vmRead.selectDealForEdit(deal);
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
                        _showDeleteConfirmDialog(context, vmRead, deal);
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
    DealsManagementViewModel vm,
    DealModel deal,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'تأكيد الحذف',
          style: TextStyle(color: AppTheme.kLightText),
        ),
        content: Text(
          'هل أنت متأكد أنك تريد حذف عرض "${deal.title}"؟',
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
              vm.deleteDeal(deal.id);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
