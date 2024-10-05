import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ManageUsersPage extends StatefulWidget {
  final User? user;

  const ManageUsersPage({Key? key, this.user}) : super(key: key);

  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final _formKey = GlobalKey<FormState>();
  String? _fullname;
  String? _phone;
  String? _username;
  String? _age;
  Uint8List? _selectedImageBytes;
  File? _selectedImageFile;
  String? _avatarUrl;

  bool _updateUsername = false;
  bool _updateFullname = false;
  bool _updatePhone = false;
  bool _updateAddress = false;
  bool _updateAge = false;
  bool _updateAvatar = false;

  final TextEditingController _addressController = TextEditingController();
  
  // ignore: unused_field
  List<Map<String, dynamic>> _suggestions = [];
  // ignore: unused_field
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fullname = widget.user?.userMetadata?['fullname'];
    _phone = widget.user?.userMetadata?['phone_number'];
    _addressController.text = widget.user?.userMetadata?['address'] ?? '';
    _username = widget.user?.userMetadata?['username'];
    _age = widget.user?.userMetadata?['age'];
    _avatarUrl = widget.user?.userMetadata?['avatarUrl'];
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageFile = null; // Clear the file if bytes are available
          _updateAvatar = true;
        });
      } else {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
          _selectedImageBytes = null; // Clear the bytes if a file is available
          _updateAvatar = true;
        });
      }
    }
  }

  Future<String?> _uploadImage() async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}';

      if (kIsWeb && _selectedImageBytes != null) {
        await Supabase.instance.client.storage
            .from('avatar')
            .uploadBinary(fileName, _selectedImageBytes!);
      } else if (_selectedImageFile != null) {
        await Supabase.instance.client.storage
            .from('avatar')
            .upload(fileName, _selectedImageFile!);
      }

      final String avatarUrl = Supabase.instance.client.storage
          .from('avatar')
          .getPublicUrl(fileName);

      return avatarUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
      return null;
    }
  }

  Future<void> _updateUserDetails() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final userId = widget.user?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID is null. Cannot update profile.')),
        );
        return;
      }

      String? avatarUrl;
      if (_updateAvatar) {
        avatarUrl = await _uploadImage();
      }

      final updateData = <String, dynamic>{};
      if (_updateUsername) updateData['username'] = _username;
      if (_updateFullname) updateData['fullname'] = _fullname;
      if (_updatePhone) updateData['phone_number'] = _phone;
      if (_updateAddress) updateData['address'] = _addressController.text;
      if (_updateAge) updateData['age'] = _age;
      if (avatarUrl != null) updateData['avatarUrl'] = avatarUrl;

      try {
        final response = await Supabase.instance.client
            .from('users')
            .update(updateData)
            .eq('id', userId);

        if (response.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: ${response.error!.message}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.of(context).pop(true);
      }
    }
  }

  void _onAddressChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final suggestions = await fetchAddressSuggestions(query);
      setState(() {
        _suggestions = suggestions;
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(30.0),
          ),
          child: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              'Edit Profile',
              style: GoogleFonts.poppins(
                textStyle: Theme.of(context).textTheme.headline6?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.blue[300],
            elevation: 4.0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // Image picker button
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  child: ClipOval(
                    child: _selectedImageFile != null
                        ? Image.file(
                            _selectedImageFile!,
                            fit: BoxFit.cover, 
                            width: 100,
                            height: 100,
                          )
                        : (_selectedImageBytes != null
                            ? Image.memory(
                                _selectedImageBytes!,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              )
                            : (_avatarUrl != null
                                ? Image.network(
                                    _avatarUrl!,
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                  )
                                : Icon(Icons.camera_alt, size: 50, color: Colors.grey[600]))),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Choose which field need to update:",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              CheckboxListTile(
                title: const Text('Username'),
                value: _updateUsername,
                onChanged: (value) {
                  setState(() {
                    _updateUsername = value ?? false;
                  });
                },
              ),
              if (_updateUsername)
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Username'),
                  initialValue: _username,
                  onSaved: (value) => _username = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your new username';
                    }
                    return null;
                  },
                ),
              CheckboxListTile(
                title: const Text('Full Name'),
                value: _updateFullname,
                onChanged: (value) {
                  setState(() {
                    _updateFullname = value ?? false;
                  });
                },
              ),
              if (_updateFullname)
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  initialValue: _fullname,
                  onSaved: (value) => _fullname = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
              CheckboxListTile(
              title: const Text('Mobile Number'),
              value: _updatePhone,
              onChanged: (value) {
                setState(() {
                  _updatePhone = value ?? false;
                });
              },
            ),
            if (_updatePhone)
              TextFormField(
                decoration: const InputDecoration(labelText: 'Mobile Number'),
                initialValue: _phone != null && _phone!.startsWith('+63') ? _phone : '+63${_phone ?? ''}', // Ensure +63 prefix
                onSaved: (value) {
                  if (value != null) {
                    // Remove any spaces or non-numeric characters (except the +63) and save the phone number
                    _phone = '+63' + value.replaceAll(RegExp(r'\D'), '').substring(2);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 11 || !value.startsWith('+63')) {
                    return 'Please enter a valid mobile number with +63';
                  }
                  return null;
                },
                keyboardType: TextInputType.phone,
              ),
              CheckboxListTile(
                title: const Text('Address'),
                value: _updateAddress,
                onChanged: (value) {
                  setState(() {
                    _updateAddress = value ?? false;
                  });
                },
              ),
              if (_updateAddress)
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  onSaved: (value) => _addressController.text = value ?? '',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                  onChanged: _onAddressChanged,
                ),
              if (_updateAddress && _suggestions.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    return ListTile(
                      title: Text(suggestion['description']),
                      onTap: () {
                        setState(() {
                          _addressController.text = suggestion['description'];
                          _suggestions = [];
                        });
                      },
                    );
                  },
                ),
              CheckboxListTile(
                title: const Text('Age'),
                value: _updateAge,
                onChanged: (value) {
                  setState(() {
                    _updateAge = value ?? false;
                  });
                },
              ),
              if (_updateAge)
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Age'),
                  initialValue: _age,
                  onSaved: (value) => _age = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: (_updateUsername || _updateFullname || _updatePhone || _updateAddress || _updateAge || _updateAvatar) 
                    ? _updateUserDetails 
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.blue, // Set background color
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // make button rectangle
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(color: Colors.white), // Set text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<List<Map<String, dynamic>>> fetchAddressSuggestions(String query) async {
    final apiKey = '';
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final predictions = data['predictions'] as List<dynamic>;

      return predictions
          .map((p) => {'description': p['description'] as String})
          .toList();
    } else {
      throw Exception('Failed to load address suggestions');
    }
  }
}
