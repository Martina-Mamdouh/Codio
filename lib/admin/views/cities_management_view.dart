import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/city_model.dart';
import '../../core/theme/app_theme.dart';
import '../viewmodels/cities_management_viewmodel.dart';

class CitiesManagementView extends StatelessWidget {
  const CitiesManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kDarkBackground,
      appBar: AppBar(
        title: const Text('إدارة المدن'),
        backgroundColor: AppTheme.kDarkBackground,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCityDialog(context),
        backgroundColor: AppTheme.kElectricLime,
        child: const Icon(Icons.add, color: AppTheme.kDarkBackground),
      ),
      body: Consumer<CitiesManagementViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.kElectricLime),
            );
          }

          if (vm.cities.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد مدن. أضف مدينة جديدة.',
                style: TextStyle(color: AppTheme.kSubtleText),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vm.cities.length,
            itemBuilder: (context, index) {
              final city = vm.cities[index];
              return Card(
                color: AppTheme.kLightBackground,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppTheme.kSubtleText.withAlpha(50)),
                ),
                child: ListTile(
                  title: Text(
                    city.nameAr,
                    style: const TextStyle(
                        color: AppTheme.kLightText,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    city.nameEn,
                    style: const TextStyle(color: AppTheme.kSubtleText),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => _showCityDialog(context, city: city),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _confirmDelete(context, vm, city),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCityDialog(BuildContext context, {CityModel? city}) {
    final nameEnController = TextEditingController(text: city?.nameEn ?? '');
    final nameArController = TextEditingController(text: city?.nameAr ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.kDarkBackground,
        title: Text(
          city == null ? 'إضافة مدينة جديدة' : 'تعديل المدينة',
          style: const TextStyle(color: AppTheme.kLightText),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameEnController,
                style: const TextStyle(color: AppTheme.kLightText),
                decoration: const InputDecoration(
                  labelText: 'الاسم باللغة الإنجليزية',
                  labelStyle: TextStyle(color: AppTheme.kSubtleText),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.kSubtleText),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.kElectricLime),
                  ),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'مطلوب إدخال الاسم' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameArController,
                style: const TextStyle(color: AppTheme.kLightText),
                decoration: const InputDecoration(
                  labelText: 'الاسم باللغة العربية',
                  labelStyle: TextStyle(color: AppTheme.kSubtleText),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.kSubtleText),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.kElectricLime),
                  ),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'مطلوب إدخال الاسم' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: AppTheme.kSubtleText),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.kElectricLime,
              foregroundColor: AppTheme.kDarkBackground,
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final vm =
                    Provider.of<CitiesManagementViewModel>(context, listen: false);
                final data = {
                  'name_en': nameEnController.text.trim(),
                  'name_ar': nameArController.text.trim(),
                };

                try {
                  if (city == null) {
                    await vm.addCity(data);
                  } else {
                    await vm.updateCity(city.id, data);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              }
            },
            child: Text(city == null ? 'إضافة' : 'تحديث'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, CitiesManagementViewModel vm, CityModel city) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.kDarkBackground,
        title: const Text('تأكيد الحذف',
            style: TextStyle(color: AppTheme.kLightText)),
        content: Text('هل أنت متأكد من حذف المدينة "${city.nameAr}"؟',
            style: const TextStyle(color: AppTheme.kSubtleText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء',
                style: TextStyle(color: AppTheme.kSubtleText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                await vm.deleteCity(city.id);
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.redAccent),
                  );
                }
              }
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

