import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kodio_app/admin/viewmodels/deals_management_viewmodel.dart';
import 'package:kodio_app/admin/viewmodels/companies_management_viewmodel.dart';
import 'package:kodio_app/core/models/deal_model.dart';
import 'package:kodio_app/core/models/company_model.dart';
import 'package:kodio_app/core/theme/app_theme.dart';
import 'package:provider/provider.dart';

class DealEditorForm extends StatefulWidget {
  const DealEditorForm({super.key});

  @override
  DealEditorFormState createState() => DealEditorFormState();
}

class DealEditorFormState extends State<DealEditorForm> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _dealTypeController = TextEditingController();
  final _dealValueController = TextEditingController();
  final _startsAtController = TextEditingController();
  final _expiresAtController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _termsController = TextEditingController();
  final _discountValueController = TextEditingController();

  Uint8List? _selectedImageBytes;
  String? _existingImageUrl;
  bool _isEditing = false;
  bool _isFeatured = false;
  bool _isForStudents = false;
  int? _selectedCategoryId;
  int? _selectedCompanyId;
  DealModel? _currentDeal;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedDeal = Provider.of<DealsManagementViewModel>(context).selectedDeal;

    if (_currentDeal != selectedDeal) {
      _currentDeal = selectedDeal;
      _updateFormFields(selectedDeal);
    }
  }

  void _updateFormFields(DealModel? deal) {
    if (mounted) {
      _formKey.currentState?.reset();
    }
    if (deal != null) {
      _isEditing = true;
      _titleController.text = deal.title;
      _descController.text = deal.description;
      _existingImageUrl = deal.imageUrl;
      _dealTypeController.text = deal.dealType;
      _dealValueController.text = deal.dealValue;
      _startsAtController.text = deal.startsAt.toIso8601String().split('T').first;
      _expiresAtController.text = deal.expiresAt.toIso8601String().split('T').first;
      _companyNameController.text = deal.companyName ?? '';
      _selectedCompanyId = deal.companyId;
      _termsController.text = deal.termsConditions;
      _discountValueController.text = deal.discountValue;
      _isFeatured = deal.isFeatured;
      _isForStudents = deal.isForStudents;
      _selectedCategoryId = deal.categoryId;
    } else {
      _isEditing = false;
      _titleController.clear();
      _descController.clear();
      _existingImageUrl = null;
      _dealTypeController.clear();
      _dealValueController.clear();
      _startsAtController.clear();
      _expiresAtController.clear();
      _companyNameController.clear();
      _selectedCompanyId = null;
      _termsController.clear();
      _discountValueController.clear();
      _isFeatured = false;
      _isForStudents = false;
      _selectedCategoryId = null;
      _selectedImageBytes = null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _dealTypeController.dispose();
    _dealValueController.dispose();
    _startsAtController.dispose();
    _expiresAtController.dispose();
    _companyNameController.dispose();
    _termsController.dispose();
    _discountValueController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);

      if (result != null && result.files.first.bytes != null) {
        setState(() {
          _selectedImageBytes = result.files.first.bytes;
          _existingImageUrl = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في اختيار الصورة: $e'), backgroundColor: Colors.redAccent));
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.kElectricLime,
              onPrimary: AppTheme.kDarkBackground,
              surface: AppTheme.kLightBackground,
              onSurface: AppTheme.kLightText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _submit(DealsManagementViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCompanyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء اختيار الشركة'), backgroundColor: Colors.redAccent));
      return;
    }

    if (_selectedImageBytes == null && !_isEditing) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء اختيار صورة العرض'), backgroundColor: Colors.redAccent));
      return;
    }

    final dealData = {
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'image_url': _existingImageUrl,
      'deal_type': _dealTypeController.text.trim(),
      'deal_value': _dealValueController.text.trim(),
      'starts_at': _startsAtController.text,
      'expires_at': _expiresAtController.text,
      'company_id': _selectedCompanyId,
      'terms_conditions': _termsController.text.trim(),
      'publish_location': 'home', // Default value since input was removed
      'discount_value': _discountValueController.text.trim(),
      'is_featured': _isFeatured,
      'is_for_students': _isForStudents,
      'category_id': _selectedCategoryId,
    };

    try {
      if (_isEditing) {
        await vm.updateDeal(vm.selectedDeal!.id, dealData, _selectedImageBytes);
      } else {
        await vm.addDeal(dealData, _selectedImageBytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DealsManagementViewModel>();
    final vmRead = context.read<DealsManagementViewModel>();
    final companiesVM = context.watch<CompaniesManagementViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.kLightBackground,
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل العرض' : 'إضافة عرض جديد'),

        backgroundColor: AppTheme.kDarkBackground,
        actions: [IconButton(icon: const Icon(Icons.close), tooltip: 'إغلاق', onPressed: vmRead.hideEditor)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // صورة العرض
              _buildImagePicker(),
              const SizedBox(height: 24),

              // عنوان العرض
              _buildTextField(
                controller: _titleController,
                label: 'عنوان العرض',
                hint: 'أدخل عنوان جذاب للعرض',
                icon: Icons.title,
                validator: (val) => val!.isEmpty ? 'عنوان العرض مطلوب' : null,
              ),
              const SizedBox(height: 16),

              // الوصف
              _buildTextField(
                controller: _descController,
                label: 'الوصف',
                hint: 'اكتب تفاصيل العرض',
                icon: Icons.description,
                maxLines: 4,
                validator: (val) => val!.isEmpty ? 'الوصف مطلوب' : null,
              ),
              const SizedBox(height: 16),

              // الشركة (Autocomplete)
              _buildCompanyAutocomplete(companiesVM),
              const SizedBox(height: 16),

              // الفئة
              _buildCategoryDropdown(vm),
              const SizedBox(height: 16),

              // قيمة الخصم
              _buildTextField(
                controller: _discountValueController,
                label: 'قيمة الخصم',
                hint: 'مثال: 50% أو 100 جنيه',
                icon: Icons.local_offer,
                validator: (val) => val!.isEmpty ? 'قيمة الخصم مطلوبة' : null,
              ),
              const SizedBox(height: 16),

              // الشروط والأحكام
              _buildTextField(
                controller: _termsController,
                label: 'الشروط والأحكام',
                hint: 'اكتب شروط استخدام العرض',
                icon: Icons.rule,
                maxLines: 3,
                validator: (val) => val!.isEmpty ? 'الشروط والأحكام مطلوبة' : null,
              ),
              const SizedBox(height: 16),

              // نوع العرض
              _buildTextField(
                controller: _dealTypeController,
                label: 'نوع العرض',
                hint: 'code أو link',
                icon: Icons.category,
                validator: (val) {
                  if (val!.isEmpty) return 'نوع العرض مطلوب';
                  if (val != 'code' && val != 'link') {
                    return 'يجب أن يكون code أو link';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // قيمة العرض (كود أو رابط)
              _buildTextField(
                controller: _dealValueController,
                label: 'قيمة العرض',
                hint: 'الكود أو الرابط',
                icon: Icons.vpn_key,
                validator: (val) => val!.isEmpty ? 'قيمة العرض مطلوبة' : null,
              ),
              const SizedBox(height: 16),

              // تاريخ البداية والنهاية
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(controller: _startsAtController, label: 'تاريخ البدء', hint: 'YYYY-MM-DD'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateField(controller: _expiresAtController, label: 'تاريخ الانتهاء', hint: 'YYYY-MM-DD'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // مكان النشر (Hidden - Default to 'home')
              // _locationController removed to rely on is_featured switch

              // Switches
              _buildSwitchTile(
                title: 'عرض للطلاب',
                value: _isForStudents,
                onChanged: (val) => setState(() => _isForStudents = val),
                icon: Icons.school,
              ),
              const SizedBox(height: 12),

              _buildSwitchTile(
                title: 'عرض مميز',
                value: _isFeatured,
                onChanged: (val) => setState(() => _isFeatured = val),
                icon: Icons.star,
                activeColor: Colors.orangeAccent,
              ),
              const SizedBox(height: 24),

              // زر الحفظ
              ElevatedButton.icon(
                onPressed: vm.isLoading ? null : () => _submit(vmRead),
                icon: vm.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Icon(_isEditing ? Icons.save : Icons.add),
                label: Text(_isEditing ? 'حفظ التعديلات' : 'إضافة العرض'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.kElectricLime,
                  foregroundColor: AppTheme.kDarkBackground,
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: '$label *',
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.kElectricLime),
        filled: true,
        fillColor: AppTheme.kDarkBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
        labelStyle: const TextStyle(color: AppTheme.kSubtleText),
        hintStyle: TextStyle(color: AppTheme.kSubtleText.withAlpha(128)),
      ),
      style: const TextStyle(color: AppTheme.kLightText),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDateField({required TextEditingController controller, required String label, required String hint}) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: '$label *',
        hintText: hint,
        prefixIcon: const Icon(Icons.calendar_today, color: AppTheme.kElectricLime),
        filled: true,
        fillColor: AppTheme.kDarkBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.kSubtleText.withAlpha(51)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.kElectricLime, width: 2),
        ),
        labelStyle: const TextStyle(color: AppTheme.kSubtleText),
      ),
      style: const TextStyle(color: AppTheme.kLightText),
      onTap: () => _selectDate(controller),
      validator: (val) => val!.isEmpty ? '$label مطلوب' : null,
    );
  }

  Widget _buildCompanyAutocomplete(CompaniesManagementViewModel companiesVM) {
    return Autocomplete<CompanyModel>(
      displayStringForOption: (CompanyModel company) => company.name,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<CompanyModel>.empty();
        }
        return companiesVM.companies.where((CompanyModel company) {
          return company.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (CompanyModel company) {
        setState(() {
          _selectedCompanyId = company.id;
          _companyNameController.text = company.name;
        });
      },
      fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
        if (_companyNameController.text.isNotEmpty && textEditingController.text.isEmpty) {
          textEditingController.text = _companyNameController.text;
        }

        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'الشركة *',
            hintText: 'ابحث عن الشركة...',
            prefixIcon: const Icon(Icons.business, color: AppTheme.kElectricLime),
            suffixIcon: const Icon(Icons.search, color: AppTheme.kSubtleText),
            filled: true,
            fillColor: AppTheme.kDarkBackground,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.kSubtleText.withAlpha(51)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.kElectricLime, width: 2),
            ),
            labelStyle: const TextStyle(color: AppTheme.kSubtleText),
            hintStyle: TextStyle(color: AppTheme.kSubtleText.withAlpha(128)),
          ),
          style: const TextStyle(color: AppTheme.kLightText),
          validator: (val) {
            if (val == null || val.isEmpty) return 'اسم الشركة مطلوب';
            if (_selectedCompanyId == null) return 'اختر شركة من القائمة';
            return null;
          },
          onChanged: (value) {
            _companyNameController.text = value;
            if (value != _companyNameController.text) {
              setState(() => _selectedCompanyId = null);
            }
          },
        );
      },
      optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<CompanyModel> onSelected, Iterable<CompanyModel> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 300,
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(color: AppTheme.kDarkBackground, borderRadius: BorderRadius.circular(8)),
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: options.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  final CompanyModel option = options.elementAt(index);
                  return ListTile(
                    title: Text(option.name, style: const TextStyle(color: AppTheme.kLightText)),
                    subtitle: Text('ID: ${option.id}', style: const TextStyle(color: AppTheme.kSubtleText, fontSize: 12)),
                    leading: const Icon(Icons.business, color: AppTheme.kElectricLime),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryDropdown(DealsManagementViewModel vm) {
    return DropdownButtonFormField<int>(
      value: _selectedCategoryId,
      decoration: InputDecoration(
        labelText: 'الفئة',
        prefixIcon: const Icon(Icons.category, color: AppTheme.kElectricLime),
        filled: true,
        fillColor: AppTheme.kDarkBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.kSubtleText.withAlpha(51)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.kElectricLime, width: 2),
        ),
        labelStyle: const TextStyle(color: AppTheme.kSubtleText),
      ),
      dropdownColor: AppTheme.kDarkBackground,
      style: const TextStyle(color: AppTheme.kLightText),
      hint: const Text('اختر الفئة (اختياري)', style: TextStyle(color: AppTheme.kSubtleText)),
      items: vm.categories.map((category) {
        return DropdownMenuItem<int>(value: category.id, child: Text(category.name));
      }).toList(),
      onChanged: (value) => setState(() => _selectedCategoryId = value),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    Color? activeColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.kDarkBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.kSubtleText.withAlpha(51)),
      ),
      child: SwitchListTile(
        title: Row(
          children: [
            Icon(icon, color: activeColor ?? AppTheme.kElectricLime, size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: AppTheme.kLightText)),
          ],
        ),
        value: value,
        activeColor: activeColor ?? AppTheme.kElectricLime,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'صورة العرض *',
          style: TextStyle(color: AppTheme.kLightText, fontSize: 16, fontWeight: FontWeight.bold),
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
            label: const Text('اختيار صورة', style: TextStyle(color: AppTheme.kElectricLime)),
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
        child: Image.memory(_selectedImageBytes!, fit: BoxFit.cover, width: double.infinity, height: 200),
      );
    }

    if (_existingImageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(_existingImageUrl!, fit: BoxFit.cover, width: double.infinity, height: 200),
      );
    }

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, color: AppTheme.kSubtleText, size: 48),
          SizedBox(height: 8),
          Text('لم يتم اختيار صورة', style: TextStyle(color: AppTheme.kSubtleText)),
        ],
      ),
    );
  }
}
