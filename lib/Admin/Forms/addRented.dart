import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';


class AddRentedForm extends StatefulWidget {
  @override
  _AddRentedFormState createState() => _AddRentedFormState();
}

class _AddRentedFormState extends State<AddRentedForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _rentedfullNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _paymentMethodController = TextEditingController();
  final TextEditingController _referenceCodeController = TextEditingController();

  List<Map<String, dynamic>> _selectedGowns = [];
  bool _showReferenceCodeField = false;
  String? _selectedRentOption = 'Rent Now';  // Default to 'Rent Now'
// To store the date when rented
DateTime? _pickupDate; 
DateTime? _dateRented; 



// To store the selected pickup date
  Future<void> _selectPickupDate(BuildContext context) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2101),
  );

  if (pickedDate != null) {
    setState(() {
      _pickupDate = pickedDate;
    });
  }
}
void _submitForm() {
  if (_formKey.currentState!.validate()) {
    if (_selectedRentOption == 'Rent Now') {
// Set the rented date to now
    }
    // Handle pickup date if 'Pick Up Later' is selected
    // Submit the form with selectedGowns and other fields
    // You can add logic here to save the data
  }
}


  @override
  void dispose() {
    _rentedfullNameController.dispose();
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

void _addGownToRented(String gownName) async {
  final gownDetails = await _fetchGownDetails(gownName);

  if (gownDetails != null && !_selectedGowns.any((gown) => gown['gownName'] == gownName)) {
    setState(() {
      _selectedGowns.add({
        'gownName': gownName,
        'imageUrl': gownDetails['imageUrl'] ?? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRgZ-HCdoGUy2nI_WfKwckkDEGi7zB_B4G6o-1WIWRcYGureJhmc2LRyo2PtSmJLaUdHtE&usqp=CAU', // Ensure imageUrl is included
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


  void _removeGownFromRented(String gownName) {
    setState(() {
      _selectedGowns.removeWhere((gown) => gown['gownName'] == gownName);
    });
  }

  @override
Widget build(BuildContext context) {
  return AlertDialog(
    title: const Text('Add New Rent'),
    content: Container(
      width: 400, // Adjust this value for the desired width
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _rentedfullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the rent name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
// Inside your build method or wherever you're defining your form field
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
                        _addGownToRented(newValue);
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
                              onPressed: () => _removeGownFromRented(gown['gownName']),
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
                              return 'Quantity cannot exceed available quantity';
                            }
                            return null;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Reservation Price: ₱${gown['reservationPrice']}'),    
                              Text('Rental Fee: ₱${gown['rentalFee']}'),
                              Text('Total Reservation Price: ₱${gown['reservationPrice'] * gown['qty']}'),
                              Text('Total Rental Fee: ₱${gown['rentalFee'] * gown['qty']}'),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),

              // New section to display total rented fee
              if (_selectedGowns.isNotEmpty)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 16.0),
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 8.0),
                      Text('Total Reservation Fee: ₱${_calculateTotalReservationFee()}'),
                      Text('Total Rental Fee: ₱${_calculateTotalRentalFee()}'),
                    ],
                  ),
                ),

  


              DropdownButtonFormField<String>(
                value: _paymentMethodController.text.isNotEmpty ? _paymentMethodController.text : null,
                decoration: const InputDecoration(labelText: 'Payment Method'),
                items: ['GCash', 'Cash'].map((method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _paymentMethodController.text = newValue!;
                    _showReferenceCodeField = newValue == 'GCash';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a payment method';
                  }
                  return null;
                },
              ),
              if (_showReferenceCodeField)
                TextFormField(
                  controller: _referenceCodeController,
                  decoration: const InputDecoration(labelText: 'Reference Code'),
                ),


DropdownButtonFormField<String>(
  value: _selectedRentOption,
  decoration: const InputDecoration(labelText: 'Rent Option'),
  items: const [
    DropdownMenuItem(
      value: 'Rent Now',
      child: Text('Rent Now'),
    ),
    DropdownMenuItem(
      value: 'Pick Up Later',
      child: Text('Pick Up Later'),
    ),
  ],
  onChanged: (String? newValue) {
    setState(() {
      _selectedRentOption = newValue;
      if (newValue == 'Rent Now') {
        // Set dateRented to now and clear pickupDate
        _pickupDate = null;
      } else if (newValue == 'Pick Up Later') {
        // Clear dateRented and allow user to select a pickup date
        _pickupDate = null;
      }
    });
  },
),
if (_selectedRentOption == 'Pick Up Later')
  TextButton(
    onPressed: () => _selectPickupDate(context),
    child: Text(
      _pickupDate == null
          ? 'Select Pickup Date'
          : 'Pickup Date: ${DateFormat('yyyy-MM-dd').format(_pickupDate!)}',
    ),
  ),



            ],

          ),
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
              // Prepare data for review
              String rentedFullName = _rentedfullNameController.text;
              String address = _addressController.text;
              String phoneNumber = _phoneNumberController.text;
              String paymentMethod = _paymentMethodController.text;
              String referenceCode = _referenceCodeController.text;

            // Show review dialog
showDialog(
  context: context,
  builder: (context) {
    return AlertDialog(
      title: const Text('Review Rented'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text('Full Name: $rentedFullName'),
            Text('Address: $address'),
            Text('Phone Number: $phoneNumber'),
            Text('Payment Method: $paymentMethod'),
            if (paymentMethod == 'GCash')
              Text('Reference Code: $referenceCode'),
            ..._selectedGowns.map((gown) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gown Name: ${gown['gownName']}'),
                   Image.network(
                     gown['imageUrl'] ?? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRgZ-HCdoGUy2nI_WfKwckkDEGi7zB_B4G6o-1WIWRcYGureJhmc2LRyo2PtSmJLaUdHtE&usqp=CAU', 
                     width: 100,
                     height: 100,
                     fit: BoxFit.cover,
                     ),
                  Text('Type: ${gown['type']}'),
                  Text('Style: ${gown['style']}'),
                  Text('Color: ${gown['color']}'),
                  Text('Size: ${gown['size']}'),
                  Text('Quantity: ${gown['qty']}'),
                  Text('Total Reservation Price: ₱${gown['reservationPrice'] * gown['qty']}'),
                  Text('Total Rental Fee: ₱${gown['rentalFee'] * gown['qty']}'),
                  SizedBox(height: 8),
                ],
              );
            }).toList(),
            Divider(),
            Text('Total Reservation Fees: ₱${_calculateTotalReservationFee()}'),
            Text('Total Rental Fees: ₱${_calculateTotalRentalFee()}'),
          ],
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
  child: const Text('Confirm Add'),
  onPressed: () async {
    for (var gown in _selectedGowns) {
      try {
        final gownName = gown['gownName'];
        final imageUrl = gown['imageUrl'];
        final type = gown['type'];
        final style = gown['style'];
        final color = gown['color'];
        final size = gown['size'];
        final qty = gown['qty'];
        final rentalFee = gown['rentalFee'];
        final reservationPrice = gown['reservationPrice'];

        final dateRented = DateTime.now();
        final dateReturn = dateRented.add(Duration(days: 3));
        final pickupDate = DateTime.now();

        // Proceed with adding the rented gown
await _addRented(
  rentedFullName,
  gownName,
  imageUrl,
  type,
  style,
  color,
  size,
  address,
  phoneNumber,
  paymentMethod,
  referenceCode,
  rentalFee,
  reservationPrice,
  qty,
  _dateRented ?? DateTime.now(), // If Rent Now, pass dateRented
  dateReturn,
  _pickupDate ?? DateTime.now(),  // If Pick Up Later, pass pickupDate
);

      } catch (e) {
        print('Error adding rental: $e');
      }
    }

    // Close the dialogs after the operation is successful
    Navigator.of(context).pop(); // Close the confirmation dialog
    Navigator.of(context).pop(); // Close the add dialog
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
    );
  }

// New method to calculate the total reservation fee
double _calculateTotalReservationFee() {
  double total = 0;
  for (var gown in _selectedGowns) {
    total += gown['reservationPrice'] * gown['qty'];
  }
  return total;
}

// New method to calculate the total rental fee
double _calculateTotalRentalFee() {
  double total = 0;
  for (var gown in _selectedGowns) {
    total += gown['rentalFee'] * gown['qty'];
  }
  return total;
}

Future<void> _addRented(
  String fullname,
  String gownName,
  String? imageUrl,
  String type,
  String style,
  String color,
  String size,
  String address,
  String phoneNumber,
  String paymentMethod,
  String referenceCode,
  int rentalFee,
  int reservationPrice,
  int qty,
  DateTime dateRented, // Add this
  DateTime dateReturn,
  DateTime pickupDate, // And this
) async {
  try {
    // Fetch current gown details to get the existing quantity
    final gownDetails = await _fetchGownDetails(gownName);
    if (gownDetails == null) {
      throw Exception('Gown details not found');
    }

    final currentQty = gownDetails['qty'] as int;

    // Check if the quantity is sufficient
    if (currentQty < qty) {
      throw Exception('Insufficient quantity available');
    }

    // Insert the reservation into the gown_rental table
   final response = await Supabase.instance.client
    .from('gown_rental')
    .insert({
      'fullname': fullname,
      'gownName': gownName,
      'imageUrl': imageUrl,
      'type': type,
      'style': style,
      'color': color,
      'size': size,
      'address': address,
      'phone_number': phoneNumber,
      'paymentMethod': paymentMethod,
      'referenceCode': referenceCode.isEmpty ? null : referenceCode,
      'rentalFee': rentalFee * qty,
      'reservationPrice': reservationPrice * qty,
      'qty': qty,
      'status': 3,
      'dateRented': dateRented != null ? dateRented.toIso8601String() : null,  // Only store if not null
      'dateReturn': dateReturn.toIso8601String(),
      'pickupDate': pickupDate != null ? pickupDate.toIso8601String() : null,  // Only store if not null
    });


    if (response.error != null) {
      throw Exception('Error adding rent: ${response.error!.message}');
    }

    // Update the gownlist to decrease the available quantity
    final updatedQty = currentQty - qty;

    final updateResponse = await Supabase.instance.client
        .from('gownlist')
        .update({'qty': updatedQty})
        .eq('gownName', gownName);

    if (updateResponse.error != null) {
      throw Exception('Error updating gown quantity: ${updateResponse.error!.message}');
    }

    print('Rented added and gown quantity updated successfully');
  } catch (error) {
    print('Error adding rented: $error');
    // Handle error (e.g., show a message to the user)
  }
}


}