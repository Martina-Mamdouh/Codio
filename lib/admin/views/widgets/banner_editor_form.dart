import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kodio_app/admin/viewmodels/banners_management_viewmodel.dart';
import 'package:kodio_app/core/models/banner_model.dart';
import 'package:kodio_app/core/theme/app_theme.dart';
import 'package:provider/provider.dart';

class BannerEditorForm extends StatefulWidget {
  const BannerEditorForm({super.key});

  @override
  BannerEditorFormState createState() => BannerEditorFormState();
}

class BannerEditorFormState extends State<BannerEditorForm> {
  final _formKey = GlobalKey<FormState>();
  final _dealIdController = TextEditingController();

  Uint8List? _selectedImageBytes;
  String? _existingImageUrl;
  bool _isEditing = false;
  BannerModel? _currentBanner;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedBanner = Provider.of<BannersManagementViewModel>(
      context,
    ).selectedBanner;

    if (_currentBanner != selectedBanner) {
      _currentBanner = selectedBanner;
      _updateFormFields(selectedBanner);
    }
  }

  void _updateFormFields(BannerModel? banner) {
    if (mounted) {
      _formKey.currentState?.reset();
    }
    if (banner != null) {
      _isEditing = true;
      _existingImageUrl = banner.imageUrl;
      _dealIdController.text = banner.dealId?.toString() ?? '';
      _selectedImageBytes = null;
    } else {
      _isEditing = false;
      _existingImageUrl = null;
      _dealIdController.clear();
      _selectedImageBytes = null;
    }
  }

  @override
  void dispose() {
    _dealIdController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.first.bytes != null) {
        setState(() {
          _selectedImageBytes = result.files.first.bytes;
          _existingImageUrl = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في اختيار الصورة: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _submit(BannersManagementViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImageBytes == null && !_isEditing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار صورة البانر'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final bannerData = {
      'image_url': _existingImageUrl,
      'deal_id': _dealIdController.text.trim().isEmpty
          ? null
          : int.tryParse(_dealIdController.text.trim()),
    };

    try {
      if (_isEditing) {
        await vm.updateBanner(
          vm.selectedBanner!.id,
          bannerData,
          _selectedImageBytes,
        );
      } else {
        await vm.addBanner(bannerData, _selectedImageBytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BannersManagementViewModel>();
    final vmRead = context.read<BannersManagementViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.kLightBackground,
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل البانر' : 'إضافة بانر جديد'),
        centerTitle: true,
        backgroundColor: AppTheme.kDarkBackground,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'إغلاق',
            onPressed: vmRead.hideEditor,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // صورة البانر
              _buildImagePicker(),
              const SizedBox(height: 24),

              // رقم العرض المرتبط (اختياري)
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

              // عرض معاينة العرض المرتبط
              if (_dealIdController.text.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDealPreview(vm),
              ],

              const SizedBox(height: 24),

              // معلومة إضافية
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.kDarkBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.kElectricLime.withAlpha(51),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppTheme.kElectricLime,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ملاحظات',
                          style: TextStyle(
                            color: AppTheme.kElectricLime,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• البانرات تظهر في الصفحة الرئيسية للتطبيق\n'
                      '• يمكن ربط البانر بعرض معين أو تركه بدون ربط\n'
                      '• يُفضل استخدام صور بنسبة عرض 16:9',
                      style: TextStyle(
                        color: AppTheme.kSubtleText,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // زر الحفظ
              ElevatedButton.icon(
                onPressed: vm.isLoading ? null : () => _submit(vmRead),
                icon: vm.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(_isEditing ? Icons.save : Icons.add),
                label: Text(_isEditing ? 'حفظ التعديلات' : 'إضافة البانر'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.kElectricLime,
                  foregroundColor: AppTheme.kDarkBackground,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
    );
  }

  Widget _buildDealPreview(BannersManagementViewModel vm) {
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

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'صورة البانر *',
          style: TextStyle(
            color: AppTheme.kLightText,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.kDarkBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.kSubtleText.withAlpha(51)),
          ),
          child: _buildImagePreview(),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            icon: const Icon(Icons.upload_file, color: AppTheme.kElectricLime),
            label: const Text(
              'اضغط لاختيار صورة',
              style: TextStyle(color: AppTheme.kElectricLime),
            ),
            onPressed: _pickImage,
          ),
        ),
        Center(
          child: Text(
            'يُفضل استخدام صور بنسبة عرض 16:9 (مثال: 1920×1080)',
            style: TextStyle(color: AppTheme.kSubtleText, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          _selectedImageBytes!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
        ),
      );
    }

    if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          _existingImageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        ),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            color: AppTheme.kSubtleText,
            size: 48,
          ),
          SizedBox(height: 8),
          Text(
            'لم يتم اختيار صورة',
            style: TextStyle(color: AppTheme.kSubtleText),
          ),
        ],
      ),
    );
  }
}
