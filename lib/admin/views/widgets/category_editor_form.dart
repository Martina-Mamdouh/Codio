import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kodio_app/admin/viewmodels/categories_management_viewmodel.dart';
import 'package:kodio_app/core/models/category_model.dart';
import 'package:kodio_app/core/theme/app_theme.dart';
import 'package:provider/provider.dart';

class CategoryEditorForm extends StatefulWidget {
  const CategoryEditorForm({super.key});

  @override
  CategoryEditorFormState createState() => CategoryEditorFormState();
}

class CategoryEditorFormState extends State<CategoryEditorForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _iconNameController = TextEditingController();

  Uint8List? _selectedImageBytes;
  String? _existingImageUrl;
  bool _isEditing = false;
  CategoryModel? _currentCategory;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedCategory = Provider.of<CategoriesManagementViewModel>(
      context,
    ).selectedCategory;

    if (_currentCategory != selectedCategory) {
      _currentCategory = selectedCategory;
      _updateFormFields(selectedCategory);
    }
  }

  void _updateFormFields(CategoryModel? category) {
    if (mounted) {
      _formKey.currentState?.reset();
    }
    if (category != null) {
      _isEditing = true;
      _nameController.text = category.name;
      _iconNameController.text = category.iconName ?? '';
      _existingImageUrl = category.imageUrl;
      _selectedImageBytes = null;
    } else {
      _isEditing = false;
      _nameController.clear();
      _iconNameController.clear();
      _existingImageUrl = null;
      _selectedImageBytes = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconNameController.dispose();
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

  Future<void> _submit(CategoriesManagementViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;

    final categoryData = {
      'name': _nameController.text.trim(),
      'icon_name': _iconNameController.text.trim().isEmpty
          ? null
          : _iconNameController.text.trim(),
      'image_url': _existingImageUrl,
    };

    try {
      if (_isEditing) {
        await vm.updateCategory(
          vm.selectedCategory!.id,
          categoryData,
          _selectedImageBytes,
        );
      } else {
        await vm.addCategory(categoryData, _selectedImageBytes);
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
    final vm = context.watch<CategoriesManagementViewModel>();
    final vmRead = context.read<CategoriesManagementViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.kLightBackground,
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل الفئة' : 'إضافة فئة جديدة'),
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
              // صورة الفئة
              _buildImagePicker(),
              const SizedBox(height: 24),

              // اسم الفئة
              _buildTextField(
                controller: _nameController,
                label: 'اسم الفئة',
                hint: 'مثال: مطاعم، إلكترونيات، أزياء',
                icon: Icons.category,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'اسم الفئة مطلوب';
                  }
                  if (val.length < 2) {
                    return 'اسم الفئة يجب أن يكون حرفين على الأقل';
                  }
                  if (val.length > 50) {
                    return 'اسم الفئة يجب ألا يتجاوز 50 حرف';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // اسم الأيقونة
              _buildTextField(
                controller: _iconNameController,
                label: 'اسم الأيقونة',
                hint: 'مثال: restaurant, shopping_bag',
                icon: Icons.emoji_symbols,
                required: false,
                helperText: 'اسم الأيقونة من Material Icons (اختياري)',
              ),
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
                      '• الصورة اختيارية - يمكن إضافة الفئة بدون صورة\n'
                      '• اسم الأيقونة يُستخدم في التطبيق للعرض البديل\n'
                      '• يمكنك تعديل الفئة لاحقاً في أي وقت',
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
                label: Text(_isEditing ? 'حفظ التعديلات' : 'إضافة الفئة'),
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
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label + (required ? ' *' : ' (اختياري)'),
        hintText: hint,
        helperText: helperText,
        helperStyle: const TextStyle(color: AppTheme.kSubtleText, fontSize: 12),
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

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'صورة الفئة (اختياري)',
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
          Icon(Icons.category_outlined, color: AppTheme.kSubtleText, size: 50),
          SizedBox(height: 12),
          Text(
            'لم يتم اختيار صورة',
            style: TextStyle(color: AppTheme.kSubtleText, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            '(اختياري)',
            style: TextStyle(color: AppTheme.kSubtleText, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
