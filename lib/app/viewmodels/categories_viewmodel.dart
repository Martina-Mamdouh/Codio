import 'package:flutter/material.dart';
import '../../core/models/category_model.dart';
import '../../core/services/supabase_service.dart';

class CategoriesViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<CategoryModel> categories = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadCategories() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      categories = await _supabaseService.getCategories();
    } catch (e) {
      errorMessage = 'حدث خطأ أثناء تحميل الفئات';
      debugPrint('Error loading categories: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
