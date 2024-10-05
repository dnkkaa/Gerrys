import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddSizeForm extends StatefulWidget {
  const AddSizeForm({Key? key}) : super(key: key);

  @override
  _AddSizeFormState createState() => _AddSizeFormState();
}

class _AddSizeFormState extends State<AddSizeForm> {
  final TextEditingController _sizeController = TextEditingController();

  Future<void> _addSize(String sizeName) async {
    final response = await Supabase.instance.client
        .from('size')
        .insert({'size': sizeName});

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
      title: const Text('Add Size'),
      content: TextField(
        controller: _sizeController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Size Name',
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
            final sizeName = _sizeController.text;
            if (sizeName.isNotEmpty) {
              try {
                await _addSize(sizeName);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Size added successfully')),
                );
              } catch (error) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Size added successfully')),
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
