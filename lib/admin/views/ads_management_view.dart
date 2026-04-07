import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../viewmodels/ads_management_viewmodel.dart';
import 'widgets/ad_editor_form.dart';

class AdsManagementView extends StatelessWidget {
  const AdsManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isEditorVisible = context.watch<AdsManagementViewModel>().isEditorVisible;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;

          if (isMobile) {
            if (isEditorVisible) {
              return const AdEditorForm();
            } else {
              return const _AdsTable();
            }
          }

          return Row(
            children: [
              Expanded(flex: isEditorVisible ? 3 : 5, child: const _AdsTable()),
              if (isEditorVisible) ...[
                const VerticalDivider(thickness: 1, width: 1, color: Colors.black),
                const Expanded(flex: 2, child: AdEditorForm()),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _AdsTable extends StatefulWidget {
  const _AdsTable();

  @override
  State<_AdsTable> createState() => _AdsTableState();
}

class _AdsTableState extends State<_AdsTable> {
  late final ScrollController _verticalController;
  late final ScrollController _horizontalController;

  @override
  void initState() {
    super.initState();
    _verticalController = ScrollController();
    _horizontalController = ScrollController();
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdsManagementViewModel>();
    final vmRead = context.read<AdsManagementViewModel>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'جدول الإعلانات',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.kLightText),
              ),
              ElevatedButton.icon(
                onPressed: () => vmRead.showEditorForNewAd(),
                icon: const Icon(Icons.add),
                label: const Text('إضافة إعلان جديد'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              color: AppTheme.kLightBackground,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: _buildBody(context, vm, vmRead),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, AdsManagementViewModel vm, AdsManagementViewModel vmRead) {
    if (vm.isLoading && vm.ads.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.kElectricLime));
    }

    if (vm.errorMessage != null) {
      return Center(
        child: Text('خطأ: ${vm.errorMessage}', style: const TextStyle(color: Colors.redAccent, fontSize: 16)),
      );
    }

    if (vm.ads.isEmpty) {
      return Center(
        child: Text('لا توجد إعلانات حالياً.',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.kSubtleText)),
      );
    }

    return Scrollbar(
      controller: _verticalController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _verticalController,
        child: Scrollbar(
          controller: _horizontalController,
          thumbVisibility: true,
          notificationPredicate: (notif) => notif.metrics.axis == Axis.horizontal,
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            child: _buildDataTable(context, vm, vmRead),
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable(BuildContext context, AdsManagementViewModel vm, AdsManagementViewModel vmRead) {
    const TextStyle headerStyle = TextStyle(fontWeight: FontWeight.bold, color: AppTheme.kElectricLime, fontSize: 16);
    const TextStyle cellStyle = TextStyle(color: AppTheme.kLightText, fontSize: 15);

    return DataTable(
      dataRowMinHeight: 80,
      dataRowMaxHeight: 80,
      headingRowHeight: 70,
      columnSpacing: 24,
      horizontalMargin: 24,
      columns: const [
        DataColumn(label: Center(child: Text('ID', style: headerStyle))),
        DataColumn(label: Center(child: Text('الصورة', style: headerStyle))),
        DataColumn(label: Center(child: Text('العرض المرتبط', style: headerStyle))),
        DataColumn(label: Center(child: Text('الحالة', style: headerStyle))),
        DataColumn(label: Center(child: Text('إجراءات', style: headerStyle))),
      ],
      rows: vm.ads.map((ad) {
        return DataRow(
          cells: [
            DataCell(Center(child: Text('#${ad.id}', style: cellStyle))),
            DataCell(
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    ad.imageLink,
                    width: 100,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
            DataCell(Center(child: Text(ad.dealTitle ?? 'غير معروف', style: cellStyle))),
            DataCell(
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ad.isActive ? Colors.green.withAlpha(51) : Colors.red.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ad.isActive ? 'نشط' : 'غير نشط',
                    style: TextStyle(color: ad.isActive ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            DataCell(
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      onPressed: () => vmRead.selectAdForEdit(ad),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _showDeleteConfirmDialog(context, vmRead, ad),
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

  void _showDeleteConfirmDialog(BuildContext context, AdsManagementViewModel vm, dynamic ad) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف', style: TextStyle(color: AppTheme.kLightText)),
        content: const Text('هل أنت متأكد أنك تريد حذف هذا الإعلان؟', style: TextStyle(color: AppTheme.kSubtleText)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              vm.deleteAd(ad.id);
              Navigator.pop(ctx);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
