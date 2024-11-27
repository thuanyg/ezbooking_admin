import 'package:ezbooking_admin/core/configs/app_colors.dart';
import 'package:flutter/material.dart';

class CreateCategoryDialog extends StatelessWidget {
  final Function(String) onCreate;

  const CreateCategoryDialog({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    return AlertDialog(
      title: const Text('Create Category'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Category Name',
          hintText: 'Enter category name',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog without action
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(AppColors.primaryColor)),
          onPressed: () {
            final categoryName = _controller.text.trim();
            if (categoryName.isNotEmpty) {
              onCreate(categoryName); // Trigger the onCreate callback
              Navigator.of(context).pop(); // Close dialog
            } else {
              // Show an error if input is empty
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Category name cannot be empty')),
              );
            }
          },
          child: const Text(
            'Create',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
