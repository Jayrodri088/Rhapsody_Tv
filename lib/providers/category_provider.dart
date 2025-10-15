import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.getCategories();

      if (response['success'] == true) {
        final categoriesData = response['data']['categories'] as List;
        _categories = categoriesData.map((json) => Category.fromJson(json)).toList();

        // Sort by order
        _categories.sort((a, b) => a.order.compareTo(b.order));

        _errorMessage = null;
      } else {
        _errorMessage = response['message'] ?? 'Failed to load categories';
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Category? getCategoryBySlug(String slug) {
    try {
      return _categories.firstWhere((category) => category.slug == slug);
    } catch (e) {
      return null;
    }
  }

  void clearCategories() {
    _categories = [];
    _errorMessage = null;
    notifyListeners();
  }
}
