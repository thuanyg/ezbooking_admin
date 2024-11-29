import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezbooking_admin/core/utils/dialogs.dart';
import 'package:ezbooking_admin/datasource/categories/category_datasource_impl.dart';
import 'package:ezbooking_admin/models/category.dart';
import 'package:ezbooking_admin/providers/categories/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoriesManagement extends StatefulWidget {
  const CategoriesManagement({super.key});

  @override
  State<CategoriesManagement> createState() => _CategoriesManagementState();
}

class _CategoriesManagementState extends State<CategoriesManagement> {
  @override
  void initState() {
    super.initState();
  }

  Color _generateRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256), // Red
      random.nextInt(256), // Green
      random.nextInt(256), // Blue
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoryProvider(CategoryDatasourceImpl()),
      child: Builder(
        builder: (context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Categories",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('categories')
                        .snapshots(),
                    builder: (_, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final categories = snapshot.data?.docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return Category.fromJson(data);
                          }).toList() ??
                          [];

                      if (categories.isEmpty) {
                        return const Center(
                          child: Text(
                            "No categories available.",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      return Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: categories.map((category) {
                          return Chip(
                            deleteIcon: const Icon(
                              Icons.clear,
                              color: Colors.white,
                            ),
                            onDeleted: () {
                              DialogUtils.showConfirmationDialog(
                                context: context,
                                size: MediaQuery.of(context).size,
                                title:
                                    "Are you sure you want to delete this category? (${category.categoryName})",
                                textCancelButton: "Cancel",
                                textAcceptButton: "Delete",
                                acceptPressed: () {
                                  final categoryProvider =
                                  Provider.of<CategoryProvider>(context,
                                      listen: false);
                                  categoryProvider.deleteCategory(
                                      context, category.id);
                                  Navigator.pop(context);

                                },
                              );

                            },
                            label: Text(
                              category.categoryName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: _generateRandomColor(),
                            elevation: 1,
                            shadowColor: Colors.grey[50],
                            avatar: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Text(
                                category.categoryName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
