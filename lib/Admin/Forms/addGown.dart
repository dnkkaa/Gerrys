// ignore_for_file: unnecessary_null_comparison
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data'; 
import 'package:flutter/foundation.dart';
import 'dart:io';

class AddGownForm extends StatefulWidget {
  @override
  _AddGownFormState createState() => _AddGownFormState();
}

class _AddGownFormState extends State<AddGownForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _gownNameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _gownretailPriceController = TextEditingController();
  final TextEditingController _lowrentalRateController = TextEditingController();
  final TextEditingController _highrentalRateController = TextEditingController();
  final TextEditingController _reservationPriceController = TextEditingController();
  final TextEditingController _rentalFeeController = TextEditingController();


  String? _selectedColor;
  String? _selectedType;
  String? _selectedSize;
  String? _selectedStyle;
  Uint8List? _selectedImageBytes; // Use Uint8List for web
  File? _selectedImageFile; // Use File for mobile

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
        // Web-specific handling
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
        });
      } else {
        // Mobile-specific handling
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
        // Web-specific upload using Uint8List
        await Supabase.instance.client.storage
            .from('gown')
            .uploadBinary(fileName, _selectedImageBytes!);
      } else if (_selectedImageFile != null) {
        // Mobile-specific upload using File
        await Supabase.instance.client.storage
            .from('gown')
            .upload(fileName, _selectedImageFile!);
      }

      // Generate the public URL for the uploaded image
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

  bool _imageSelected = false; // Track if an image is selected

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Gown'),
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
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly, // Allows only digits to be entered
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the quantity';
                    }
                    return null;
                  },
                ),

            
               TextFormField(
                  controller: _gownretailPriceController,
                  decoration: const InputDecoration(labelText: 'Gown Retail Price'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly, // Allows only digits to be entered
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the quantity';
                    }
                    return null;
                  },
                ),

              TextFormField(
                  controller: _lowrentalRateController,
                  decoration: const InputDecoration(labelText: 'Low Rental Rate'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly, // Allows only digits to be entered
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the quantity';
                    }
                    return null;
                  },
                ),
              TextFormField(
                  controller: _highrentalRateController,
                  decoration: const InputDecoration(labelText: 'High Rental Rate'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly, // Allows only digits to be entered
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the quantity';
                    }
                    return null;
                  },
                ),
            TextFormField(
                  controller: _reservationPriceController,
                  decoration: const InputDecoration(labelText: 'Reservation Fee'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly, // Allows only digits to be entered
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the quantity';
                    }
                    return null;
                  },
                ),
            TextFormField(
                  controller: _rentalFeeController,
                  decoration: const InputDecoration(labelText: 'rentalFeee'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly, // Allows only digits to be entered
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the quantity';
                    }
                    return null;
                  },
                ),

// Inside your build method, after the image selection widget
const SizedBox(height: 10),
const SizedBox(height: 10),
SizedBox(
  width: 150,
  height: 150,
  child: _selectedImageBytes != null
      ? Image.memory(
          _selectedImageBytes!,
          width: 150,
          height: 150,
          fit: BoxFit.cover,
        )
      : _selectedImageFile != null
          ? Image.file(
              _selectedImageFile!,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            )
          : TextButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Upload Image'),
              onPressed: () async {
                await _pickImage();
                setState(() {
                  _imageSelected = true; // Set to true when an image is picked
                });
              },
            ),
),
if (!_imageSelected) // Show error message if no image is selected
  Text(
    'Please upload a photo',
    style: TextStyle(color: Colors.red), // Customize the style as needed
  ),

            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
ElevatedButton(
  child: const Text('Add'),
  onPressed: () async {
    if (_formKey.currentState!.validate()) {
      if (!_imageSelected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please upload an image')),
        );
        return; // Stop if no image is selected
      }
              final gownName = _gownNameController.text;
              final description = _descriptionController.text;
              final type = _selectedType!;
              final size = _selectedSize!;
              final color = _selectedColor!;
              final style = _selectedStyle!;
              final qty = int.parse(_qtyController.text);
              final gownretailPrice = int.parse(_gownretailPriceController.text);
              final lowrentalRate = int.parse(_lowrentalRateController.text);
              final highrentalRate = int.parse(_highrentalRateController.text);
              final reservationPrice = int.parse(_reservationPriceController.text);
              final rentalFee = int.parse(_rentalFeeController.text);

             String? imageUrl;
              if (_selectedImageBytes != null || _selectedImageFile != null) {
                imageUrl = await _uploadImage();
              }

              _addGown(gownName, description, type, size, color, style, imageUrl, qty,  gownretailPrice, lowrentalRate, highrentalRate, reservationPrice, rentalFee);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

Future<void> _addGown(
  String gownName, 
  String description,
  String type, 
  String size, 
  String color, 
  String style, 
  String? imageUrl,
  int qty,
  int gownretailPrice, 
  int lowrentalRate, 
  int highrentalRate,
  int reservationPrice,
  int rentalFee,
) async {
  final response = await Supabase.instance.client.from('gownlist').insert([
    {
      'gownName': gownName,
      'type': type,
      'size': size,
      'color': color,
      'style': style,
      'qty': qty,
      'gownretailPrice': gownretailPrice,
      'description': description,
      'lowrentalRate': lowrentalRate,
      'highrentalRate': highrentalRate,
      'reservationPrice': reservationPrice,
      'rentalFee': rentalFee,
      'status': '1', // Automatically setting the status to 1 as 'Available'
      'imageUrl': imageUrl,
    }
  ]);

  if (response.error != null) {
    // Enhanced error handling
    print('Error adding gown: ${response.error!.message}');
    if (response.error!.hint != null) {
      print('Hint: ${response.error!.hint}');
    }
  } else {
    print('Gown added successfully: ${response.data}');
  }
}
}