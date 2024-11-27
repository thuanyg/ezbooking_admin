import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezbooking_admin/datasource/categories/category_datasource.dart';
import 'package:ezbooking_admin/models/category.dart';

class CategoryDatasourceImpl extends CategoryDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'categories';

  // CREATE: Add a new category to Firestore
  @override
  Future<void> addCategory(Category category) async {
    try {
      await _firestore.collection(_collectionName).add(category.toJson());
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  // READ: Fetch a category by its ID
  @override
  Future<Category?> getCategoryById(String id) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_collectionName).doc(id).get();

      if (doc.exists) {
        return Category.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch category: $e');
    }
  }

  // READ: Fetch all categories
  Future<List<Category>> getAllCategories() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection(_collectionName).get();

      return querySnapshot.docs
          .map((doc) => Category.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  // UPDATE: Update a category in Firestore
  @override
  Future<void> updateCategory(Category category) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(category.id)
          .update(category.toJson());
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  // DELETE: Remove a category by its ID
  @override
  Future<void> deleteCategory(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  @override
  Future<bool> isCategoryAssigned(String id) async {
    try {
      final docs = await _firestore
          .collection("events")
          .where('category', isEqualTo: id)
          .get();
      return docs.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to fetch: $e');
    }
  }

  @override
  Future<bool> isCategoryExisted(String categoryName) async {
    try {
      final docs = await _firestore
          .collection(_collectionName)
          .where('categoryName', isEqualTo: categoryName)
          .limit(1)
          .get();
      return docs.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to fetch: $e');
    }
  }
}
