import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // ✅
import 'package:kodio_app/admin/viewmodels/companies_management_viewmodel.dart';
import 'package:kodio_app/core/models/company_model.dart';
import 'package:kodio_app/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:kodio_app/core/models/category_model.dart'; // ✅ Added import

class CompanyEditorForm extends StatefulWidget {
  const CompanyEditorForm({super.key});

  @override
  CompanyEditorFormState createState() => CompanyEditorFormState();
}

class CompanyEditorFormState extends State<CompanyEditorForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers أساسية
  final _nameController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  // Controllers للسوشيال ميديا
  final _fbController = TextEditingController();
  final _waController = TextEditingController();
  final _tgController = TextEditingController();
  final _liController = TextEditingController();
  final _ttController = TextEditingController();
  final _igController = TextEditingController(); // ✅ جديد

  // Controllers جديدة للـ Info
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  // ساعات العمل - من والى
  final _workingHoursFromController = TextEditingController();
  final _workingHoursToController = TextEditingController();

  // ✅ Logo
  Uint8List? _selectedLogoBytes;
  String? _existingLogoUrl;

  // ✅ Cover (جديد!)
  Uint8List? _selectedCoverBytes;
  String? _existingCoverUrl;

  // ✅ Category (جديد!)
  Set<int> _selectedCategoryIds = {}; // ✅ Multi-select
  int? _selectedPrimaryCategoryId; // ✅ Primary category

  bool _isEditing = false;
  CompanyModel? _currentCompany;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedCompany = Provider.of<CompaniesManagementViewModel>(
      context,
    ).selectedCompany;
    if (_currentCompany != selectedCompany) {
      _currentCompany = selectedCompany;
      _populateForm(selectedCompany);
    }
  }

  void _populateForm(CompanyModel? company) {
    if (mounted) {
      // ✅ Reset the form logic first to clear previous validation state
      // This is crucial to prevent "stuck" values or errors
      _formKey.currentState?.reset();
    }

    if (company != null) {
      _isEditing = true;
      _nameController.text = company.name;
      _existingLogoUrl = company.logoUrl;
      _existingCoverUrl = company.coverImageUrl; // ✅
      _selectedCategoryIds =
          company.categoryIds?.toSet() ?? {}; // ✅ Multi-select
      _selectedPrimaryCategoryId = company.primaryCategoryId; // ✅ Primary
      _latController.text = company.lat.toString();
      _lngController.text = company.lng.toString();
      _descriptionController.text = company.description ?? '';
      _phoneController.text = company.phone ?? '';
      _websiteController.text = company.website ?? '';
      _emailController.text = company.email ?? '';
      _addressController.text = company.address ?? '';

      // Populate Social Media
      final social = company.socialLinks ?? {};
      _fbController.text = social['facebook'] ?? '';
      _waController.text = social['whatsapp'] ?? '';
      _tgController.text = social['telegram'] ?? '';
      _liController.text = social['linkedin'] ?? '';
      _ttController.text = social['tiktok'] ?? '';
      _igController.text = social['instagram'] ?? ''; // ✅

      // تقسيم ساعات العمل

      // تقسيم ساعات العمل
      if (company.workingHours != null && company.workingHours!.contains('-')) {
        final parts = company.workingHours!.split('-');
        _workingHoursFromController.text = parts[0].trim();
        _workingHoursToController.text = parts.length > 1
            ? parts[1].trim()
            : '';
      } else {
        _workingHoursFromController.clear();
        _workingHoursToController.clear();
      }

      // Reset selection bytes as we are loading existing
      _selectedLogoBytes = null;
      _selectedCoverBytes = null;
    } else {
      _isEditing = false;
      _nameController.clear();
      _existingLogoUrl = null;
      _existingCoverUrl = null; // ✅
      _latController.clear();
      _lngController.clear();
      _descriptionController.clear();
      _phoneController.clear();
      _websiteController.clear();
      _emailController.clear();
      _addressController.clear();
      _workingHoursFromController.clear();
      _workingHoursToController.clear();

      _fbController.clear();
      _waController.clear();
      _tgController.clear();
      _liController.clear();
      _ttController.clear();
      _igController.clear(); // ✅

      _selectedLogoBytes = null;
      _selectedCoverBytes = null; // ✅
      _selectedCategoryIds = {}; // ✅
      _selectedPrimaryCategoryId = null; // ✅
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _workingHoursFromController.dispose();
    _workingHoursToController.dispose();
    _fbController.dispose();
    _waController.dispose();
    _tgController.dispose();
    _liController.dispose();
    _ttController.dispose();
    _igController.dispose(); // ✅
    super.dispose();
  }

  // ✅ اختيار Logo
  Future<void> _pickLogo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.first.bytes != null) {
        setState(() {
          _selectedLogoBytes = result.files.first.bytes;
          _existingLogoUrl = null;
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

  // ✅ اختيار Cover (جديد!)
  Future<void> _pickCover() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.first.bytes != null) {
        setState(() {
          _selectedCoverBytes = result.files.first.bytes;
          _existingCoverUrl = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في اختيار صورة الغلاف: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _submit(CompaniesManagementViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLogoBytes == null && !_isEditing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار صورة الشعار'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // دمج ساعات العمل
    String? workingHours;
    if (_workingHoursFromController.text.trim().isNotEmpty ||
        _workingHoursToController.text.trim().isNotEmpty) {
      final from = _workingHoursFromController.text.trim();
      final to = _workingHoursToController.text.trim();
      if (from.isNotEmpty && to.isNotEmpty) {
        workingHours = '$from - $to';
      } else if (from.isNotEmpty) {
        workingHours = from;
      } else if (to.isNotEmpty) {
        workingHours = to;
      }
    }

    final companyData = {
      'name': _nameController.text.trim(),
      'lat': double.tryParse(_latController.text) ?? 0.0,
      'lng': double.tryParse(_lngController.text) ?? 0.0,
      'logo_url': _existingLogoUrl,
      'cover_image_url': _existingCoverUrl,
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'phone': _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      'website': _websiteController.text.trim().isEmpty
          ? null
          : _websiteController.text.trim(),
      'email': _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      'address': _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      'working_hours': workingHours,
      'category_ids': _selectedCategoryIds.toList(), // ✅
      'primary_category_id': _selectedPrimaryCategoryId, // ✅
      'instagram_url': _igController.text.trim().isEmpty ? null : _igController.text.trim(), // ✅
      'social_links': {
        'facebook': _fbController.text.trim(),
        'whatsapp': _waController.text.trim(),
        'telegram': _tgController.text.trim(),
        'linkedin': _liController.text.trim(),
        'tiktok': _ttController.text.trim(),
        'instagram': _igController.text.trim(), // ✅
      },
    };

    try {
      if (_isEditing) {
        await vm.updateCompany(
          vm.selectedCompany!.id,
          companyData,
          _selectedLogoBytes,
          _selectedCoverBytes, // ✅ أضف الـ cover
        );
      } else {
        await vm.addCompany(
          companyData,
          _selectedLogoBytes,
          _selectedCoverBytes, // ✅ أضف الـ cover
        );
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
    final vm = context.watch<CompaniesManagementViewModel>();
    final vmRead = context.read<CompaniesManagementViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.kLightBackground,
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل الشركة' : 'إضافة شركة جديدة'),
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
              // ✅ صورة الغلاف (جديد!)
              _buildCoverPicker(),
              const SizedBox(height: 24),

              // ✅ شعار الشركة
              _buildLogoPicker(),
              const SizedBox(height: 24),

              // اسم الشركة
              _buildTextField(
                controller: _nameController,
                label: 'اسم الشركة',
                hint: 'أدخل اسم الشركة',
                icon: Icons.business,
                validator: (val) => val!.isEmpty ? 'اسم الشركة مطلوب' : null,
              ),
              const SizedBox(height: 16),

              // الوصف
              _buildTextField(
                controller: _descriptionController,
                label: 'الوصف',
                hint: 'أدخل وصف الشركة',
                icon: Icons.description,
                maxLines: 4,
                required: false,
              ),
              const SizedBox(height: 16),

              // ✅ التصنيف (جديد!)
              // ✅ التصنيف (جديد!)
              _buildMultiSelectCategories(vm.categories),
              const SizedBox(height: 16),
              if (_selectedCategoryIds.isNotEmpty)
                _buildPrimaryCategoryDropdown(vm.categories),
              if (_selectedCategoryIds.isNotEmpty) const SizedBox(height: 16),
              const SizedBox(height: 16),

              // رقم الهاتف
              _buildTextField(
                controller: _phoneController,
                label: 'رقم الهاتف',
                hint: '+20 123 456 7890',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (val) {
                  if (val != null && val.isNotEmpty) {
                    if (!RegExp(r'^[+\d\s\-()]+$').hasMatch(val)) {
                      return 'رقم هاتف غير صالح';
                    }
                  }
                  return null;
                },
                required: false,
              ),
              const SizedBox(height: 16),

              // البريد الإلكتروني
              _buildTextField(
                controller: _emailController,
                label: 'البريد الإلكتروني',
                hint: 'info@company.com',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val != null && val.isNotEmpty) {
                    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(val)) {
                      return 'بريد إلكتروني غير صالح';
                    }
                  }
                  return null;
                },
                required: false,
              ),
              const SizedBox(height: 16),

              // الموقع الإلكتروني
              _buildTextField(
                controller: _websiteController,
                label: 'الموقع الإلكتروني',
                hint: 'https://example.com',
                icon: Icons.language,
                keyboardType: TextInputType.url,
                validator: (val) {
                  if (val != null && val.isNotEmpty) {
                    if (!val.startsWith('http://') &&
                        !val.startsWith('https://')) {
                      return 'يجب أن يبدأ بـ http:// أو https://';
                    }
                  }
                  return null;
                },
                required: false,
              ),
              const SizedBox(height: 16),

              // ✅ قسم السوشيال ميديا
              const Divider(color: AppTheme.kSubtleText),
              Text(
                'روابط التواصل الاجتماعي',
                style: TextStyle(
                  color: AppTheme.kLightText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // فيسبوك
              _buildTextField(
                controller: _fbController,
                label: 'Facebook',
                hint: 'https://facebook.com/page',
                icon: FontAwesomeIcons.facebook,
                required: false,
              ),
              const SizedBox(height: 8),
              // واتساب
              _buildTextField(
                controller: _waController,
                label: 'WhatsApp',
                hint: '+201xxxxxxxxx',
                icon: FontAwesomeIcons.whatsapp,
                required: false,
              ),
              const SizedBox(height: 8),
              // تيليجرام
              _buildTextField(
                controller: _tgController,
                label: 'Telegram',
                hint: 'https://t.me/username',
                icon: FontAwesomeIcons.telegram,
                required: false,
              ),
              const SizedBox(height: 8),
              // لينكدإن
              _buildTextField(
                controller: _liController,
                label: 'LinkedIn',
                hint: 'https://linkedin.com/company/name',
                icon: FontAwesomeIcons.linkedin,
                required: false,
              ),
              const SizedBox(height: 8),
              // تيك توك
              _buildTextField(
                controller: _ttController,
                label: 'TikTok',
                hint: 'https://tiktok.com/@username',
                icon: FontAwesomeIcons.tiktok,
                required: false,
              ),
              const SizedBox(height: 8),
              // إنستجرام
              _buildTextField(
                controller: _igController,
                label: 'Instagram',
                hint: 'https://instagram.com/username',
                icon: FontAwesomeIcons.instagram,
                required: false,
              ),
              const SizedBox(height: 16),
              const Divider(color: AppTheme.kSubtleText),
              const SizedBox(height: 16),

              // العنوان
              _buildTextField(
                controller: _addressController,
                label: 'العنوان',
                hint: 'أدخل عنوان الشركة',
                icon: Icons.location_on,
                maxLines: 2,
                required: false,
              ),
              const SizedBox(height: 16),

              // ساعات العمل
              Text(
                'ساعات العمل',
                style: TextStyle(
                  color: AppTheme.kLightText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _workingHoursFromController,
                      label: 'من',
                      hint: '9 صباحًا',
                      icon: Icons.access_time,
                      required: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward, color: AppTheme.kSubtleText),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _workingHoursToController,
                      label: 'إلى',
                      hint: '10 مساءً',
                      icon: Icons.access_time_filled,
                      required: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // خط العرض
              _buildTextField(
                controller: _latController,
                label: 'خط العرض (Latitude)',
                hint: '30.0444',
                icon: Icons.my_location,
                required: false, // ✅ Optional
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return null; // ✅ Allow empty
                  final lat = double.tryParse(val);
                  if (lat == null) return 'يجب أن يكون رقمًا';
                  if (lat < -90 || lat > 90) return 'يجب أن يكون بين -90 و 90';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // خط الطول
              _buildTextField(
                controller: _lngController,
                label: 'خط الطول (Longitude)',
                hint: '31.2357',
                icon: Icons.place,
                required: false, // ✅ Optional
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return null; // ✅ Allow empty
                  final lng = double.tryParse(val);
                  if (lng == null) return 'يجب أن يكون رقمًا';
                  if (lng < -180 || lng > 180) {
                    return 'يجب أن يكون بين -180 و 180';
                  }
                  return null;
                },
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
                label: Text(_isEditing ? 'حفظ التعديلات' : 'إضافة الشركة'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.kElectricLime,
                  foregroundColor: AppTheme.kDarkBackground,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
        labelText: label + (required ? ' *' : ''),
        hintText: hint,
        prefixIcon:
            (icon.fontPackage == 'font_awesome_flutter' ||
                (icon.fontFamily?.toLowerCase().contains('font') ?? false))
            ? Container(
                width: 40,
                alignment: Alignment.center,
                child: FaIcon(icon, color: AppTheme.kElectricLime, size: 20),
              )
            : Icon(icon, color: AppTheme.kElectricLime, size: 20),
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
        labelStyle: const TextStyle(color: AppTheme.kSubtleText),
        hintStyle: TextStyle(color: AppTheme.kSubtleText.withAlpha(128)),
      ),
      style: const TextStyle(color: AppTheme.kLightText),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator:
          validator ??
          (required ? (val) => val!.isEmpty ? '$label مطلوب' : null : null),
    );
  }

  // ✅ Cover Picker (جديد!)
  Widget _buildCoverPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'صورة الغلاف',
          style: TextStyle(
            color: AppTheme.kLightText,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.kDarkBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.kSubtleText.withAlpha(51)),
          ),
          child: _buildCoverPreview(),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            icon: const Icon(Icons.panorama, color: AppTheme.kElectricLime),
            label: const Text(
              'اختيار صورة الغلاف',
              style: TextStyle(color: AppTheme.kElectricLime),
            ),
            onPressed: _pickCover,
          ),
        ),
      ],
    );
  }

  Widget _buildCoverPreview() {
    if (_selectedCoverBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          _selectedCoverBytes!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 160,
        ),
      );
    }

    if (_existingCoverUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          _existingCoverUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 160,
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.panorama, color: AppTheme.kSubtleText, size: 48),
          const SizedBox(height: 8),
          Text(
            'لم يتم اختيار صورة الغلاف',
            style: TextStyle(color: AppTheme.kSubtleText),
          ),
        ],
      ),
    );
  }

  // ✅ Logo Picker (معدّل)
  Widget _buildLogoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'شعار الشركة *',
          style: TextStyle(
            color: AppTheme.kLightText,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.kDarkBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.kSubtleText.withAlpha(51)),
          ),
          child: _buildLogoPreview(),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            icon: const Icon(Icons.upload_file, color: AppTheme.kElectricLime),
            label: const Text(
              'اختيار شعار الشركة',
              style: TextStyle(color: AppTheme.kElectricLime),
            ),
            onPressed: _pickLogo,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoPreview() {
    if (_selectedLogoBytes != null) {
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            _selectedLogoBytes!,
            fit: BoxFit.contain,
            width: 120,
            height: 120,
          ),
        ),
      );
    }

    if (_existingLogoUrl != null) {
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            _existingLogoUrl!,
            fit: BoxFit.contain,
            width: 120,
            height: 120,
          ),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            color: AppTheme.kSubtleText,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            'لم يتم اختيار شعار',
            style: TextStyle(color: AppTheme.kSubtleText),
          ),
        ],
      ),
    );
  }

  // ✅ Multi-Select Categories
  Widget _buildMultiSelectCategories(List<CategoryModel> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تصنيفات الشركة (اختر واحدًا أو أكثر) *',
          style: TextStyle(
            color: AppTheme.kLightText,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity, // ✅ Full Width
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.kDarkBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.kSubtleText.withAlpha(51)),
          ),
          child: categories.isEmpty
              ? Center(
                  child: Text(
                    'لا توجد تصنيفات متاحة',
                    style: TextStyle(color: AppTheme.kSubtleText),
                  ),
                )
              : Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: categories.map((category) {
                    final isSelected = _selectedCategoryIds.contains(
                      category.id,
                    );
                    return FilterChip(
                      label: Text(category.name),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategoryIds.add(category.id);
                          } else {
                            _selectedCategoryIds.remove(category.id);
                            // If removed category was primary, clear primary
                            if (_selectedPrimaryCategoryId == category.id) {
                              _selectedPrimaryCategoryId = null;
                            }
                          }
                        });
                      },
                      selectedColor: AppTheme.kElectricLime,
                      checkmarkColor: AppTheme.kDarkBackground,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppTheme.kDarkBackground
                            : AppTheme.kLightText,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      backgroundColor: AppTheme.kLightBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.transparent
                              : AppTheme.kSubtleText.withAlpha(51),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
        if (_selectedCategoryIds.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'يجب اختيار تصنيف واحد على الأقل',
              style: TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
      ],
    );
  }

  // ✅ Primary Category Dropdown
  Widget _buildPrimaryCategoryDropdown(List<CategoryModel> categories) {
    // Filter categories to show only selected ones
    final selectedCategories = categories
        .where((c) => _selectedCategoryIds.contains(c.id))
        .toList();

    // Reset primary if it's no longer in selected
    if (_selectedPrimaryCategoryId != null &&
        !_selectedCategoryIds.contains(_selectedPrimaryCategoryId)) {
      _selectedPrimaryCategoryId = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التصنيف الأساسي (يظهر في الكارت) *',
          style: TextStyle(
            color: AppTheme.kLightText,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _selectedPrimaryCategoryId,
          items: selectedCategories.map((category) {
            return DropdownMenuItem<int>(
              value: category.id,
              child: Text(category.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedPrimaryCategoryId = value;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.kDarkBackground,
            // ✅ UX Message
            helperText: 'يرجى اختيار تصنيف واحد على الأقل',
            helperStyle: TextStyle(color: AppTheme.kElectricLime, fontSize: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.kSubtleText.withAlpha(51)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
          ),
          dropdownColor: AppTheme.kLightBackground,
          style: const TextStyle(color: AppTheme.kLightText),
          validator: (value) {
            if (value == null) {
              return 'الرجاء اختيار التصنيف الأساسي';
            }
            if (!_selectedCategoryIds.contains(value)) {
              return 'التصنيف الأساسي يجب أن يكون مختارًا أعلاه';
            }
            return null;
          },
          hint: Text(
            'اختر التصنيف الأساسي',
            style: TextStyle(color: AppTheme.kSubtleText),
          ),
        ),
      ],
    );
  }
}
