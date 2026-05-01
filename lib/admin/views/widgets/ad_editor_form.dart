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
  final _dealIdController = TextEditingController();
  final _linkUrlController = TextEditingController();
  bool _isActive = true;
  Uint8List? _selectedImageBytes;
  String? _existingImageUrl;
  String _placement = 'home'; // 'home' or 'category'
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final ad = context.read<AdsManagementViewModel>().selectedAd;
    if (ad != null) {
      _isActive = ad.isActive;
      _dealIdController.text = ad.dealId?.toString() ?? '';
      _linkUrlController.text = ad.linkUrl ?? '';
      _existingImageUrl = ad.imageLink;
      _placement = ad.placement;
      _selectedCategoryId = ad.categoryId;
    }
  }

  @override
  void dispose() {
    _dealIdController.dispose();
    _linkUrlController.dispose();
    super.dispose();
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

      if (_placement == 'category' && _selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء اختيار التصنيف')),
        );
        return;
      }

      final vm = context.read<AdsManagementViewModel>();

      // Check max 5 ads per placement
      final excludeId = vm.selectedAd?.id;
      if (vm.isPlacementFull(_placement,
          categoryId: _selectedCategoryId, excludeAdId: excludeId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم بلوغ الحد الأقصى (${AdsManagementViewModel.maxAdsPerPlacement} إعلانات) لهذا المكان.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      final adData = {
        'is_active': _isActive,
        'deal_id': _dealIdController.text.trim().isEmpty
            ? null
            : int.tryParse(_dealIdController.text.trim()),
        'link_url': _linkUrlController.text.trim().isEmpty
            ? null
            : _linkUrlController.text.trim(),
        'placement': _placement,
        'category_id': _placement == 'category' ? _selectedCategoryId : null,
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

              // ── Placement Selector ─────────────────────────────
              const Text(
                'مكان النشر *',
                style: TextStyle(color: AppTheme.kSubtleText, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildPlacementChip(
                      label: 'الصفحة الرئيسية',
                      icon: Icons.home_rounded,
                      value: 'home',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPlacementChip(
                      label: 'داخل تصنيف',
                      icon: Icons.category_rounded,
                      value: 'category',
                    ),
                  ),
                ],
              ),

              // Show remaining slots info
              Builder(builder: (_) {
                final currentCount = vm.countAdsForPlacement(
                  _placement,
                  categoryId: _selectedCategoryId,
                );
                final editing = vm.selectedAd != null;
                // If editing the same placement, don't double count
                final adjustedCount = (editing &&
                        vm.selectedAd!.placement == _placement &&
                        (_placement == 'home' ||
                            vm.selectedAd!.categoryId == _selectedCategoryId))
                    ? currentCount - 1
                    : currentCount;
                final remaining =
                    AdsManagementViewModel.maxAdsPerPlacement - adjustedCount;

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'المتاح: $remaining من ${AdsManagementViewModel.maxAdsPerPlacement} إعلانات',
                    style: TextStyle(
                      color: remaining > 0 ? Colors.grey[400] : Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),

              // ── Category Dropdown (only if placement == category) ───
              if (_placement == 'category') ...[
                _buildCategoryDropdown(vm),
                const SizedBox(height: 16),
              ],

              // Deal ID
              _buildTextField(
                controller: _dealIdController,
                label: 'رقم العرض (Deal ID)',
                hint: 'أدخل رقم العرض المرتبط (اختياري)',
                icon: Icons.link,
                keyboardType: TextInputType.number,
                required: false,
                validator: (val) {
                  if (val != null && val.isNotEmpty) {
                    final dealId = int.tryParse(val);
                    if (dealId == null) {
                      return 'يجب أن يكون رقمًا صحيحًا';
                    }
                    if (dealId <= 0) {
                      return 'يجب أن يكون رقمًا موجبًا';
                    }
                  }
                  return null;
                },
              ),

              if (_dealIdController.text.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDealPreview(vm),
              ],
              const SizedBox(height: 16),

              // Link URL
              _buildTextField(
                controller: _linkUrlController,
                label: 'رابط خارجي (Link URL)',
                hint: 'مثال: https://google.com (اختياري)',
                icon: Icons.language,
                required: false,
                keyboardType: TextInputType.url,
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

  // ── Placement Chip ────────────────────────────────────────────────────────
  Widget _buildPlacementChip({
    required String label,
    required IconData icon,
    required String value,
  }) {
    final isSelected = _placement == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _placement = value;
          if (value == 'home') _selectedCategoryId = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.kElectricLime.withAlpha(30)
              : AppTheme.kDarkBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.kElectricLime : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 20,
                color:
                    isSelected ? AppTheme.kElectricLime : AppTheme.kSubtleText),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.kElectricLime : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Category Dropdown ─────────────────────────────────────────────────────
  Widget _buildCategoryDropdown(AdsManagementViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'اختر التصنيف *',
          style: TextStyle(color: AppTheme.kSubtleText, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.kDarkBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.kSubtleText.withAlpha(51)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedCategoryId,
              hint: const Text(
                'اختر التصنيف',
                style: TextStyle(color: AppTheme.kSubtleText),
              ),
              dropdownColor: AppTheme.kDarkBackground,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down,
                  color: AppTheme.kElectricLime),
              items: vm.categories.map((cat) {
                return DropdownMenuItem<int>(
                  value: cat.id,
                  child: Text(
                    cat.name,
                    style: const TextStyle(color: AppTheme.kLightText),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedCategoryId = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label + (required ? ' *' : ' (اختياري)'),
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.kElectricLime),
        filled: true,
        fillColor: AppTheme.kDarkBackground,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        labelStyle: const TextStyle(color: AppTheme.kSubtleText),
        hintStyle: TextStyle(color: AppTheme.kSubtleText.withAlpha(128)),
      ),
      style: const TextStyle(color: AppTheme.kLightText),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: (val) {
        if (controller == _dealIdController) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildDealPreview(AdsManagementViewModel vm) {
    final dealId = int.tryParse(_dealIdController.text.trim());
    if (dealId == null) return const SizedBox.shrink();

    final dealName = vm.getDealNameById(dealId);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.kDarkBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: dealName != null ? AppTheme.kElectricLime : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            dealName != null ? Icons.check_circle : Icons.warning,
            color: dealName != null ? AppTheme.kElectricLime : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              dealName != null
                  ? 'مرتبط بالعرض: $dealName'
                  : 'تحذير: العرض غير موجود',
              style: TextStyle(
                color: dealName != null ? AppTheme.kLightText : Colors.orange,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
