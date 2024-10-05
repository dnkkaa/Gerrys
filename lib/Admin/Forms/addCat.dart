import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddCategoryForm extends StatefulWidget {
  const AddCategoryForm({Key? key}) : super(key: key);

  @override
  _AddCategoryFormState createState() => _AddCategoryFormState();
}

class _AddCategoryFormState extends State<AddCategoryForm> {
  final TextEditingController _categoryController = TextEditingController();

  Future<void> _addCategory(String categoryName) async {
    final response = await Supabase.instance.client
        .from('category')
        .insert({'type': categoryName});

    if (response.error != null) {
      throw Exception(response.error!.message);
    } else {
      // Close the dialog
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Category'),
      content: TextField(
        controller: _categoryController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Category Name',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog without adding the category
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final categoryName = _categoryController.text;
            if (categoryName.isNotEmpty) {
              try {
                await _addCategory(categoryName);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Category added successfully')),
                );
              } catch (error) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Category added successfully')),
                );
              }
            }
          },
          child: const Text('Add Category'),
        ),
      ],
    );
  }
}
