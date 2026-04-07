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

    return Container(
      padding: const EdgeInsets.all(24),
      color: AppTheme.kLightBackground,
      child: Form(
        key: _formKey,
        child: Column(
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
            const SizedBox(height: 24),

            // Image Picker
            InkWell(
              onTap: _pickImage,
              child: Container(
                height: 180,
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
            ),
            const SizedBox(height: 24),

            // Deal Selection
            const Text('العرض المرتبط:',
                style: TextStyle(color: AppTheme.kLightText, fontSize: 14)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _selectedDealId,
              dropdownColor: AppTheme.kLightBackground,
              decoration: AppTheme.searchInputDecoration(hintText: 'اختر العرض'),
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
            const SizedBox(height: 24),

            // Is Active Switch
            SwitchListTile(
              title: const Text('نشط',
                  style: TextStyle(color: AppTheme.kLightText, fontSize: 16)),
              value: _isActive,
              activeColor: AppTheme.kElectricLime,
              onChanged: (val) => setState(() => _isActive = val),
            ),
            const Spacer(),

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
        ),
      ),
    );
  }
}
