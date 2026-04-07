import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../viewmodels/ads_management_viewmodel.dart';

class AdEditorForm extends StatefulWidget {
  const AdEditorForm({super.key});

  @override
  State<AdEditorForm> createState() => _AdEditorFormState();
}

class _AdEditorFormState extends State<AdEditorForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isActive = true;
  int? _selectedDealId;
  Uint8List? _selectedImageBytes;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    final ad = context.read<AdsManagementViewModel>().selectedAd;
    if (ad != null) {
      _isActive = ad.isActive;
      _selectedDealId = ad.dealId;
      _existingImageUrl = ad.imageLink;
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedImageBytes = result.files.single.bytes;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedImageBytes == null && _existingImageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء اختيار صورة')),
        );
        return;
      }

      if (_selectedDealId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء اختيار عرض')),
        );
        return;
      }

      final vm = context.read<AdsManagementViewModel>();
      final adData = {
        'is_active': _isActive,
        'deal_id': _selectedDealId,
      };

      if (vm.selectedAd == null) {
        vm.addAd(adData, _selectedImageBytes);
      } else {
        vm.updateAd(vm.selectedAd!.id, adData, _selectedImageBytes);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdsManagementViewModel>();

    // Make the form scrollable and responsive for wide (web) layouts
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppTheme.kLightBackground,
      child: Form(
        key: _formKey,
        child: LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;

          Widget imagePicker = InkWell(
            onTap: _pickImage,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.kDarkBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.kSubtleText.withAlpha(51),
                  width: 2,
                ),
              ),
              child: _selectedImageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
                    )
                  : (_existingImageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(_existingImageUrl!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined,
                                size: 40, color: AppTheme.kSubtleText),
                            SizedBox(height: 8),
                            Text('اختر صورة الإعلان',
                                style: TextStyle(color: AppTheme.kSubtleText)),
                          ],
                        )),
            ),
          );

          Widget fields = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    vm.selectedAd == null ? 'إضافة إعلان جديد' : 'تعديل الإعلان',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.kElectricLime,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    onPressed: () => vm.hideEditor(),
                    icon: const Icon(Icons.close, color: AppTheme.kSubtleText),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Deal Selection
              const Text('العرض المرتبط:',
                  style: TextStyle(color: AppTheme.kLightText, fontSize: 14)),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _selectedDealId,
                isExpanded: true,
                dropdownColor: AppTheme.kLightBackground,
                decoration: InputDecoration(
                  hintText: 'اختر العرض',
                  filled: true,
                  fillColor: AppTheme.kDarkBackground,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.kSubtleText.withAlpha(51)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.kElectricLime, width: 2),
                  ),
                  hintStyle: const TextStyle(color: AppTheme.kSubtleText, fontSize: 14),
                ),
                items: vm.deals.map((deal) {
                  return DropdownMenuItem<int>(
                    value: deal.id,
                    child: Text(deal.title,
                        style: const TextStyle(color: AppTheme.kLightText, fontSize: 14)),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedDealId = val),
                validator: (val) => val == null ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),

              // Is Active Switch
              SwitchListTile(
                title: const Text('نشط',
                    style: TextStyle(color: AppTheme.kLightText, fontSize: 16)),
                value: _isActive,
                activeThumbColor: AppTheme.kElectricLime,
                onChanged: (val) => setState(() => _isActive = val),
              ),

              const SizedBox(height: 16),
              // Submit Button
              if (vm.isLoading)
                const Center(child: CircularProgressIndicator(color: AppTheme.kElectricLime))
              else
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(vm.selectedAd == null ? 'إضافة' : 'حفظ التغييرات'),
                ),
            ],
          );

          if (isWide) {
            return SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: image
                  Flexible(flex: 1, child: imagePicker),
                  const SizedBox(width: 24),
                  // Right: fields with constrained max width for readability
                  Flexible(
                    flex: 2,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: fields,
                    ),
                  ),
                ],
              ),
            );
          }

          // Mobile / narrow layout: vertical
          return SingleChildScrollView(padding: const EdgeInsets.only(bottom: 8), child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    vm.selectedAd == null ? 'إضافة إعلان جديد' : 'تعديل الإعلان',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.kElectricLime,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    onPressed: () => vm.hideEditor(),
                    icon: const Icon(Icons.close, color: AppTheme.kSubtleText),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              imagePicker,
              const SizedBox(height: 16),
              fields,
            ],
          ));
        }),
      ),
    );
  }
}
