//editgown

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart'; // To use kIsWeb

class EditGownForm extends StatefulWidget {
  final Map<String, dynamic> gownData; // Pass the current gown data to be edited
  final Function onUpdate; // Callback function to trigger when the update is successful

  const EditGownForm({
    required this.gownData,
    required this.onUpdate,
    Key? key,
  }) : super(key: key);

  @override
  _EditGownFormState createState() => _EditGownFormState();
}

class _EditGownFormState extends State<EditGownForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _gownNameController;
  late TextEditingController _qtyController;
  late TextEditingController _descriptionController;
  late TextEditingController _gownretailPriceController;
  late TextEditingController _lowrentalRateController;
  late TextEditingController _highrentalRateController;
  late TextEditingController _reservationPriceController;
  late TextEditingController _rentalFeeController;

  String? _selectedColor;
  String? _selectedType;
  String? _selectedSize;
  String? _selectedStyle;
  Uint8List? _selectedImageBytes;
  File? _selectedImageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing gown data
    _gownNameController = TextEditingController(text: widget.gownData['gownName']);
    _qtyController = TextEditingController(text: widget.gownData['qty'].toString());
    _descriptionController = TextEditingController(text: widget.gownData['description']);
    _gownretailPriceController = TextEditingController(text: widget.gownData['gownretailPrice'].toString());
    _lowrentalRateController = TextEditingController(text: widget.gownData['lowrentalRate'].toString());
    _highrentalRateController = TextEditingController(text: widget.gownData['highrentalRate'].toString());
    _reservationPriceController = TextEditingController(text: widget.gownData['reservationPrice'].toString());
    _rentalFeeController = TextEditingController(text: widget.gownData['rentalFee'].toString());
    _selectedType = widget.gownData['type'];
    _selectedSize = widget.gownData['size'];
    _selectedColor = widget.gownData['color'];
    _selectedStyle = widget.gownData['style'];
  }
  Stream<List<Map<String, dynamic>>> _colorStream() {
    return Supabase.instance.client
        .from('colors')
        .stream(primaryKey: ['id'])
        .map((data) => List<Map<String, dynamic>>.from(data));
  }
    Stream<List<Map<String, dynamic>>> _categoryStream() {
    return Supabase.instance.client
        .from('category')
        .stream(primaryKey: ['id'])
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Stream<List<Map<String, dynamic>>> _sizeStream() {
    return Supabase.instance.client
        .from('size')
        .stream(primaryKey: ['id'])
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Stream<List<Map<String, dynamic>>> _styleStream() {
    return Supabase.instance.client
        .from('gown_style')
        .stream(primaryKey: ['id'])
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
        });
      } else {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
      }
    }
  }

  Future<String?> _uploadImage() async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}';

      if (kIsWeb && _selectedImageBytes != null) {
        await Supabase.instance.client.storage
            .from('gown')
            .uploadBinary(fileName, _selectedImageBytes!);
      } else if (_selectedImageFile != null) {
        await Supabase.instance.client.storage
            .from('gown')
            .upload(fileName, _selectedImageFile!);
      }

      final String imageUrl = Supabase.instance.client.storage
          .from('gown')
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
      return null;
    }
  }

  Future<void> _confirmUpdate(BuildContext context) async {
    final shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Update'),
          content: const Text('Are you sure you want to update the gown details?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (shouldUpdate == true) {
      setState(() {
        _isLoading = true;
      });

      final updates = <String, dynamic>{};

      if (_gownNameController.text != widget.gownData['gownName']) {
        updates['gownName'] = _gownNameController.text;
      }
      if (_descriptionController.text != widget.gownData['description']) {
        updates['description'] = _descriptionController.text;
      }
      if (_selectedType != widget.gownData['type']) {
        updates['type'] = _selectedType;
      }
      if (_selectedSize != widget.gownData['size']) {
        updates['size'] = _selectedSize;
      }
      if (_selectedColor != widget.gownData['color']) {
        updates['color'] = _selectedColor;
      }
      if (_selectedStyle != widget.gownData['style']) {
        updates['style'] = _selectedStyle;
      }
      if (_qtyController.text != widget.gownData['qty'].toString()) {
        updates['qty'] = int.parse(_qtyController.text);
      }
      if (_gownretailPriceController.text != widget.gownData['gownretailPrice'].toString()) {
        updates['gownretailPrice'] = int.parse(_gownretailPriceController.text);
      }
      if (_lowrentalRateController.text != widget.gownData['lowrentalRate'].toString()) {
        updates['lowrentalRate'] = int.parse(_lowrentalRateController.text);
      }
      if (_highrentalRateController.text != widget.gownData['highrentalRate'].toString()) {
        updates['highrentalRate'] = int.parse(_highrentalRateController.text);
      }
      if (_reservationPriceController.text != widget.gownData['reservationPrice'].toString()) {
        updates['reservationPrice'] = int.parse(_reservationPriceController.text);
      }
      if (_rentalFeeController.text != widget.gownData['rentalFee'].toString()) {
        updates['rentalFee'] = int.parse(_rentalFeeController.text);
      }
      if (_selectedImageBytes != null || _selectedImageFile != null) {
        final imageUrl = await _uploadImage();
        if (imageUrl != null) {
          updates['imageUrl'] = imageUrl;
        }
      }

      await _updateGown(updates);

      widget.onUpdate(); // Call callback to refresh the gown list
      Navigator.of(context).pop();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateGown(Map<String, dynamic> updates) async {
    if (updates.isNotEmpty) {
      await Supabase.instance.client
          .from('gownlist')
          .update(updates)
          .eq('gownID', widget.gownData['gownID']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Gown'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _gownNameController,
                decoration: const InputDecoration(labelText: 'Gown Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the gown name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the description';
                  }
                  return null;
                },
              ),
               StreamBuilder<List<Map<String, dynamic>>>(
                stream: _categoryStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No categories available');
                  }

                  final types = snapshot.data!
                      .map((category) => category['type'] as String)
                      .toList();

                  _selectedType ??= types.isNotEmpty ? types.first : null;

                  return DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: types.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedType = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a type';
                      }
                      return null;
                    },
                  );
                },
              ),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _sizeStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No sizes available');
                  }

                  final sizes = snapshot.data!
                      .map((size) => size['size'] as String)
                      .toList();

                  _selectedSize ??= sizes.isNotEmpty ? sizes.first : null;

                  return DropdownButtonFormField<String>(
                    value: _selectedSize,
                    decoration: const InputDecoration(labelText: 'Size'),
                    items: sizes.map((size) {
                      return DropdownMenuItem<String>(
                        value: size,
                        child: Text(size),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedSize = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a size';
                      }
                      return null;
                    },
                  );
                },
              ),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _colorStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No colors available');
                  }

                  final colors = snapshot.data!
                      .map((colors) => colors['colors'] as String)
                      .toList();

                  _selectedColor ??= colors.isNotEmpty ? colors.first : null;

                  return DropdownButtonFormField<String>(
                    value: _selectedColor,
                    decoration: const InputDecoration(labelText: 'Color'),
                    items: colors.map((color) {
                      return DropdownMenuItem<String>(
                        value: color,
                        child: Text(color),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedColor = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a color';
                      }
                      return null;
                    },
                  );
                },
              ),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _styleStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No style available');
                  }

                  final style = snapshot.data!
                      .map((gown_style) => gown_style['style'] as String)
                      .toList();

                  _selectedStyle ??= style.isNotEmpty ? style.first : null;

                  return DropdownButtonFormField<String>(
                    value: _selectedStyle,
                    decoration: const InputDecoration(labelText: 'Style'),
                    items: style.map((style) {
                      return DropdownMenuItem<String>(
                        value: style,
                        child: Text(style),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedStyle = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a style';
                      }
                      return null;
                    },
                  );
                },
              ),
              TextFormField(
                controller: _qtyController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the quantity';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _gownretailPriceController,
                decoration: const InputDecoration(labelText: 'Retail Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the retail price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lowrentalRateController,
                decoration: const InputDecoration(labelText: 'Low Rental Rate'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the low rental rate';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _highrentalRateController,
                decoration: const InputDecoration(labelText: 'High Rental Rate'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the high rental rate';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _reservationPriceController,
                decoration: const InputDecoration(labelText: 'Reservation Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the reservation price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _rentalFeeController,
                decoration: const InputDecoration(labelText: 'Rental Fee'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the rental fee';
                  }
                  return null;
                },
              ),
           // Conditionally display the current image if no new image is selected
            if (_selectedImageBytes == null && widget.gownData['imageUrl'] != null) 
              Image.network(widget.gownData['imageUrl'], height: 100, width: 100),
            
            SizedBox(height: 8),

            // Display the new image if selected
            if (_selectedImageBytes != null)
              Image.memory(_selectedImageBytes!, height: 100, width: 100),
            
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Change Image'),
            ),
            
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _confirmUpdate(context);
                      }
                    },
                    child: const Text('Update Gown'),
                  ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without updating
              },
              child: const Text('Cancel'),
                     ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _gownNameController.dispose();
    _qtyController.dispose();
    _descriptionController.dispose();
    _gownretailPriceController.dispose();
    _lowrentalRateController.dispose();
    _highrentalRateController.dispose();
    _reservationPriceController.dispose();
    _rentalFeeController.dispose();
    super.dispose();
  }
}
