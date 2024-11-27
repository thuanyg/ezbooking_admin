import 'dart:math';

import 'package:ezbooking_admin/providers/categories/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoriesManagement extends StatefulWidget {
  const CategoriesManagement({super.key});

  @override
  State<CategoriesManagement> createState() => _CategoriesManagementState();
}

class _CategoriesManagementState extends State<CategoriesManagement> {
  late CategoryProvider categoryProvider;

  @override
  void initState() {
    super.initState();
    categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    categoryProvider.fetchCategories();
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
            child: Container(
              margin: EdgeInsets.only(bottom: 100),
              child: Consumer<CategoryProvider>(
                builder: (context, value, child) {
                  if (value.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (value.categories.isEmpty) {
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
                    children: value.categories.map((category) {
                      return Chip(
                        deleteIcon: const Icon(
                          Icons.clear,
                          color: Colors.white,
                        ),
                        onDeleted: () {
                          categoryProvider.deleteCategory(context, category.id);
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
          ),
        )
      ],
    );
  }
}
