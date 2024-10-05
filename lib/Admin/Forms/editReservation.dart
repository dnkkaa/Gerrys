import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';

class EditReservationForm extends StatefulWidget {
  @override
  _EditReservationFormState createState() => _EditReservationFormState();
}

class _EditReservationFormState extends State<EditReservationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reservationfullNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _paymentMethodController = TextEditingController();
  final TextEditingController _referenceCodeController = TextEditingController();

  List<Map<String, dynamic>> _selectedGowns = [];
  bool _showReferenceCodeField = false;

  @override
  void dispose() {
    _reservationfullNameController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    _paymentMethodController.dispose();
    _referenceCodeController.dispose();
    super.dispose();
  }

  Stream<List<Map<String, dynamic>>> _gownNameStream() {
    return Supabase.instance.client
        .from('gownlist')
        .stream(primaryKey: ['gownID'])
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Future<Map<String, dynamic>?> _fetchGownDetails(String gownName) async {
    try {
      final response = await Supabase.instance.client
          .from('gownlist')
          .select()
          .eq('gownName', gownName)
          .single();

      return response;
    } catch (error) {
      print('Error fetching gown details: $error');
      return null;
    }
  }

  void _addGownToReservation(String gownName) async {
    final gownDetails = await _fetchGownDetails(gownName);

    if (gownDetails != null && !_selectedGowns.any((gown) => gown['gownName'] == gownName)) {
      setState(() {
        _selectedGowns.add({
          'gownName': gownName,
          'imageUrl': gownDetails['imageUrl'] ?? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRgZ-HCdoGUy2nI_WfKwckkDEGi7zB_B4G6o-1WIWRcYGureJhmc2LRyo2PtSmJLaUdHtE&usqp=CAU',
          'reservationPrice': gownDetails['reservationPrice'],
          'type': gownDetails['type'],
          'style': gownDetails['style'],
          'color': gownDetails['color'],
          'size': gownDetails['size'],
          'qty': 1,
          'rentalFee': gownDetails['rentalFee'],
          'availableQty': gownDetails['qty'],
        });
      });
    }
  }

  void _removeGownFromReservation(String gownName) {
    setState(() {
      _selectedGowns.removeWhere((gown) => gown['gownName'] == gownName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Reservation'),
      content: Container(
        width: 400, // Adjust this value for the desired width
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _reservationfullNameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the reservation name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Allow only digits
                    LengthLimitingTextInputFormatter(11), // Limit input to 11 digits
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    } else if (value.length != 11) {
                      return 'Phone number must be 11 digits';
                    }
                    return null; // Return null if the input is valid
                  },
                ),

                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _gownNameStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No gowns available');
                    }

                    final gownNames = snapshot.data!
                        .map((gown) => gown['gownName'] as String)
                        .toList();

                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Select Gown'),
                      items: gownNames.map((gownName) {
                        return DropdownMenuItem<String>(
                          value: gownName,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(gownName),
                              IconButton(
                                icon: Icon(Icons.info_outline),
                                onPressed: () async {
                                  final gownDetails = await _fetchGownDetails(gownName);
                                  if (gownDetails != null) {
                                    // Display gown details in a dialog
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Gown Details'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Name: ${gownDetails['gownName']}'),
                                              Image.network(
                                                gownDetails['imageUrl'] ?? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRgZ-HCdoGUy2nI_WfKwckkDEGi7zB_B4G6o-1WIWRcYGureJhmc2LRyo2PtSmJLaUdHtE&usqp=CAU',
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                              ),
                                              Text('Type: ${gownDetails['type']}'),
                                              Text('Style: ${gownDetails['style']}'),
                                              Text('Color: ${gownDetails['color']}'),
                                              Text('Size: ${gownDetails['size']}'),
                                              Text('Reservation Price: \$${gownDetails['reservationPrice']}'),
                                              Text('Rental Fee: \$${gownDetails['rentalFee']}'),
                                              Text('Available Quantity: ${gownDetails['qty']}'),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              child: const Text('Close'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          _addGownToReservation(newValue);
                        }
                      },
                      validator: (value) {
                        if (_selectedGowns.isEmpty) {
                          return 'Please select at least one gown';
                        }
                        return null;
                      },
                    );
                  },
                ),
                if (_selectedGowns.isNotEmpty)
                  Column(
                    children: _selectedGowns.map((gown) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            gown['imageUrl'] ?? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRgZ-HCdoGUy2nI_WfKwckkDEGi7zB_B4G6o-1WIWRcYGureJhmc2LRyo2PtSmJLaUdHtE&usqp=CAU',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(gown['gownName']),
                              IconButton(
                                icon: Icon(Icons.remove_circle),
                                onPressed: () => _removeGownFromReservation(gown['gownName']),
                              ),
                            ],
                          ),
                          // Quantity input
                          TextFormField(
                            initialValue: gown['qty'].toString(),
                            decoration: InputDecoration(
                                labelText: 'Quantity (Max ${gown['availableQty']})'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final enteredQty = int.tryParse(value) ?? 0;
                              if (enteredQty > 0 && enteredQty <= gown['availableQty']) {
                                setState(() {
                                  gown['qty'] = enteredQty;
                                });
                              }
                            },
                            validator: (value) {
                              final int? enteredQty = int.tryParse(value ?? '');
                              if (enteredQty == null || enteredQty <= 0) {
                                return 'Please enter a valid quantity';
                              } else if (enteredQty > gown['availableQty']) {
                                return 'Quantity exceeds available stock';
                              }
                              return null;
                            },
                          ),
                          Divider(),
                        ],
                      );
                    }).toList(),
                  ),
                TextFormField(
                  controller: _paymentMethodController,
                  decoration: const InputDecoration(labelText: 'Payment Method'),
                ),
                CheckboxListTile(
                  title: const Text('Reference Code'),
                  value: _showReferenceCodeField,
                  onChanged: (value) {
                    setState(() {
                      _showReferenceCodeField = value ?? false;
                    });
                  },
                ),
                if (_showReferenceCodeField)
                  TextFormField(
                    controller: _referenceCodeController,
                    decoration: const InputDecoration(labelText: 'Reference Code'),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              // Process the reservation submission
              final reservationData = {
                'fullName': _reservationfullNameController.text,
                'address': _addressController.text,
                'phoneNumber': _phoneNumberController.text,
                'paymentMethod': _paymentMethodController.text,
                'referenceCode': _showReferenceCodeField ? _referenceCodeController.text : null,
                'gowns': _selectedGowns,
              };
              // Handle your reservation data
              Navigator.of(context).pop(reservationData);
            }
          },
          child: const Text('Save Changes'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
