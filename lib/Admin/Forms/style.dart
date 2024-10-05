import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// class AddCategoryForm extends StatefulWidget {
//   const AddCategoryForm({Key? key}) : super(key: key);
class AddStyleForm extends StatefulWidget {
  const AddStyleForm({Key? key}) : super(key: key);

//   @override
//   _AddCategoryFormState createState() => _AddCategoryFormState();
// }
  @override
  _AddStyleFormState createState() => _AddStyleFormState();
}
// class _AddCategoryFormState extends State<AddCategoryForm> {
//   final TextEditingController _categoryController = TextEditingController();
class _AddStyleFormState extends State<AddStyleForm> {
  final TextEditingController _categoryController = TextEditingController();

  // Future<void> _addCategory(String categoryName) async {
  //   final response = await Supabase.instance.client
  //       .from('category')
  //       .insert({'type': categoryName});
  Future<void> _addStyle(String styleName) async {
    final response = await Supabase.instance.client
        .from('gown_style')
        .insert({'style': styleName});

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
      title: const Text('Add Style'),
      content: TextField(
        controller: _categoryController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Style Name',
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
            final styleName = _categoryController.text;
            if (styleName.isNotEmpty) {
              try {
                await _addStyle(styleName);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Style added successfully')),
                );
              } catch (error) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Style added successfully')),
                );
              }
            }
          },
          child: const Text('Add Style'),
        ),
      ],
    );
  }
}
