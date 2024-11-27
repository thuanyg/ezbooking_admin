import 'package:ezbooking_admin/models/category.dart';

abstract class CategoryDatasource {
  Future<void> addCategory(Category category);
  Future<Category?> getCategoryById(String id);
  Future<List<Category>> getAllCategories();
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
  Future<bool> isCategoryExisted(String categoryName);
  Future<bool> isCategoryAssigned(String id);
}