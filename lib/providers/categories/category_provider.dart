import 'package:ezbooking_admin/core/utils/dialogs.dart';
import 'package:ezbooking_admin/datasource/categories/category_datasource.dart';
import 'package:ezbooking_admin/datasource/categories/category_datasource_impl.dart';
import 'package:ezbooking_admin/models/category.dart';
import 'package:flutter/material.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryDatasourceImpl _dataSource;

  CategoryProvider(this._dataSource);

  List<Category> _categories = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;

  bool get isLoading => _isLoading;

  // Fetch all categories and update state
  Future<void> fetchCategories() async {
    _setLoading(true);
    try {
      _categories = await _dataSource.getAllCategories();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add a new category and update state
  Future<void> addCategory(BuildContext context, Category category) async {
    await Future.delayed(const Duration(microseconds: 800));
    _setLoading(true);
    try {
      bool isExisted = await _dataSource.isCategoryExisted(category.categoryName);
      if (isExisted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This category already has created.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      await _dataSource.addCategory(category);
      _categories.add(category);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error adding category: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing category and update state
  Future<void> updateCategory(Category category) async {
    _setLoading(true);
    try {
      await _dataSource.updateCategory(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      }
    } catch (e) {
      debugPrint('Error updating category: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Delete a category and update state
  Future<void> deleteCategory(BuildContext context, String id) async {
    _setLoading(true);
    try {
      bool isAssign = await _dataSource.isCategoryAssigned(id);
      if (isAssign) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This category has been assigned for another events.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await _dataSource.deleteCategory(id);

      _categories.removeWhere((category) => category.id == id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This category has been deleted'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      debugPrint('Error deleting category: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Set loading state and notify listeners
  void _setLoading(bool value) {
    _isLoading = value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
