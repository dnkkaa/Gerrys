import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddColorForm extends StatefulWidget {
  const AddColorForm({Key? key}) : super(key: key);

  @override
  _AddColorFormState createState() => _AddColorFormState();
}

class _AddColorFormState extends State<AddColorForm> {
  final TextEditingController _colorsController = TextEditingController();

  Future<void> _addColors(String colorName) async {
    final response = await Supabase.instance.client
        .from('colors')
        .insert({'colors': colorName});

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
      title: const Text('Add Color'),
      content: TextField(
        controller: _colorsController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Color Name',
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
            final categoryName = _colorsController.text;
            if (categoryName.isNotEmpty) {
              try {
                await _addColors(categoryName);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Color added successfully')),
                );
              } catch (error) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Color added successfully')),
                );
              }
            }
          },
          child: const Text('Add Color'),
        ),
      ],
    );
  }
}
