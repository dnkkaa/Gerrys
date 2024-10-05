import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gown_rental/card/confirmed.dart';

class ReservationInfoPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems;
  final double totalFee;

  const ReservationInfoPage({
    super.key,
    required this.selectedItems,
    required this.totalFee,
    required int rentalFee,
    required int gownID,
    required String imageUrl,
    required int gownreservationPrice,
    required String gownName,
    required String gownSize,
    required String gownStyle,
    required int quantity,
    required double totalPrice,
    required List cartItems,
    required String gownColor,
    required String gownType,
  });

  @override
  _ReservationInfoPageState createState() => _ReservationInfoPageState();
}

class _ReservationInfoPageState extends State<ReservationInfoPage> {
  final PageController _pageController = PageController();
  String? _paymentMethod;
  bool _isGcashSelected = false;
  // ignore: unused_field
  bool _isCashOnSiteSelected = false;

  final TextEditingController _referenceCodeController = TextEditingController();

  // Calculate the full payment based on the selected items
  int get fullPaymentAmount {
    return widget.selectedItems.fold(0, (total, item) {
      final price = item['reservationPrice'] is int
          ? item['reservationPrice'] as int
          : int.tryParse(item['reservationPrice'].toString()) ?? 0;
      final quantity = item['qty'] as int? ?? 0;
      return total + (price * quantity);
    });
  }

  void _updateFullPayment() {
    setState(() {
      _referenceCodeController.text = '₱${fullPaymentAmount.toString()}';
    });
  }

  Stream<Map<String, dynamic>?> _getUserStream() {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      return supabase
          .from('users')
          .stream(primaryKey: ['id'])
          .eq('id', user.id)
          .map((event) => event.isNotEmpty ? event.first : null);
    } else {
      return Stream.value(null);
    }
  }

void _showGcashDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: SizedBox(
          width: 250,
          height: 350,
          child: SingleChildScrollView( // Added to avoid overflow
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/gcash.jpg',
                  width: 250, // Set the width
                  height: 320, // Set the height
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10),
                const Text(
                  '+63-965-089-3717',
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'Please scan the QR code to pay via GCash',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

Future<void> _saveReservation(Map<String, dynamic>? userData) async {
  if (_paymentMethod == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a payment method')),
    );
    return;
  }

  if (_isGcashSelected && _referenceCodeController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter the GCash reference code')),
    );
    return;
  }

  try {
    final supabase = Supabase.instance.client;
    final List<Map<String, dynamic>> reservationDataList = widget.selectedItems.map((item) {
      final reservationData = {
        'gownID': item['gownID'] as int? ?? 0,
        'gownName': item['gownName'] as String? ?? '',
        'imageUrl': item['imageUrl'] as String? ?? '',
        'type': item['type'] as String? ?? 'Unknown Type',
        'size': item['size'] as String? ?? 'Unknown Size',
        'color': item['color'] as String? ?? 'Unknown Color',
        'style': item['style'] as String? ?? 'Unknown Style',
        'reservationPrice': item['reservationPrice'] as int? ?? 0,
        'qty': item['qty'] as int? ?? 0,
       //'totalFee': widget.totalFee.toInt(),
        'rentalFee': item['rentalFee'] as int? ?? 0,
        //'rentalFee': item['rentalFee'] is int ? item['rentalFee'] as int : int.tryParse(item['rentalFee'].toString()) ?? 0,
        'totalFee': (item['reservationPrice'] as int? ?? 0) * (item['qty'] as int? ?? 1),
        'paymentMethod': _paymentMethod,
        'fullname': userData?['fullname'] ?? '',
        'address': userData?['address'] ?? '',
        'phone_number': userData?['phone_number'] ?? '',
        'status': 0, 
        'cartID': item['cartID'] as int? ?? 0,
      };

      if (_isGcashSelected) {
        reservationData['referenceCode'] = _referenceCodeController.text;
      }

      return reservationData;
    }).toList();

    // Batch insert
    final response = await supabase.from('gown_rental').upsert(reservationDataList);

    if (response.error != null) {
      print('Insert error: ${response.error?.message}'); // Debug print
      throw Exception(response.error?.message ?? 'Unknown error');
    } else if (response.data == null) {
      throw Exception('No data returned from the insert operation.');
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Confirmed(),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reservation on process.....')),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Confirmed(),
      ),
    );
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
              'Process Reservation',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<Map<String, dynamic>?>(
          stream: _getUserStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading user data'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No user data available'));
            }

            final userData = snapshot.data;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 450,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.selectedItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.selectedItems[index];
                      return Center(
                        child: Container(
                          width: 800,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _getColorFromString(item['color'] as String? ?? 'unknown'),
                              width: 1,
                            ),
                          ),
                          child: Image.network(
                            item['imageUrl'] as String? ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(child: Text('Image could not be loaded'));
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                if (userData != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 6.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ExpansionTile(
                      title: const Text(
                        'User Information',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                     // initiallyExpanded: true,
                      children: [
                        ListTile(
                          title: TextFormField(
                            initialValue: userData['fullname'],
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              labelStyle: TextStyle(fontWeight: FontWeight.bold),
                              border: InputBorder.none,
                            ),
                            readOnly: true,
                          ),
                        ),
                        ListTile(
                          title: TextFormField(
                            initialValue: userData['email'],
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(fontWeight: FontWeight.bold),
                              border: InputBorder.none,
                            ),
                            readOnly: true,
                          ),
                        ),
                        ListTile(
                          title: TextFormField(
                            initialValue: userData['phone_number'],
                            decoration: const InputDecoration(
                              labelText: 'Mobile Number',
                              labelStyle: TextStyle(fontWeight: FontWeight.bold),
                              border: InputBorder.none,
                            ),
                            readOnly: true,
                          ),
                        ),
                        ListTile(
                          title: TextFormField(
                            initialValue: userData['address'],
                            decoration: const InputDecoration(
                              labelText: 'Address',
                              labelStyle: TextStyle(fontWeight: FontWeight.bold),
                              border: InputBorder.none,
                            ),
                            readOnly: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 6.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ExpansionTile(
                    title: const Text(
                      'Gown Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    initiallyExpanded: true,
                    children: [
                      for (var item in widget.selectedItems)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                title: TextFormField(
                                  initialValue: item['gownName'],
                                  decoration: const InputDecoration(
                                    labelText: 'Gown Name',
                                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                                    border: InputBorder.none,
                                  ),
                                  readOnly: true,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              ListTile(
                                title: TextFormField(
                                  initialValue: item['type'],
                                  decoration: const InputDecoration(
                                    labelText: 'Type',
                                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                                    border: InputBorder.none,
                                  ),
                                  readOnly: true,
                                ),
                              ),
                              ListTile(
                                title: TextFormField(
                                  initialValue: item['color'],
                                  decoration: const InputDecoration(
                                    labelText: 'Color',
                                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                                    border: InputBorder.none,
                                  ),
                                  readOnly: true,
                                ),
                              ),
                              ListTile(
                                title: TextFormField(
                                  initialValue: item['size'],
                                  decoration: const InputDecoration(
                                    labelText: 'Size',
                                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                                    border: InputBorder.none,
                                  ),
                                  readOnly: true,
                                ),
                              ),
                              ListTile(
                                title: TextFormField(
                                  initialValue: item['style'],
                                  decoration: const InputDecoration(
                                    labelText: 'Style',
                                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                                    border: InputBorder.none,
                                  ),
                                  readOnly: true,
                                ),
                              ),
                              ListTile(
                                title: TextFormField(
                                  initialValue: '₱${NumberFormat('#,##0.00').format(item['reservationPrice'])}', //initialValue: '₱${item['reservationPrice'].toStringAsFixed(2)}',
                                  decoration: const InputDecoration(
                                    labelText: 'Price',
                                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                                    border: InputBorder.none,
                                  ),
                                  readOnly: true,
                                ),
                              ),
                              ListTile(
                                title: TextFormField(
                                  initialValue: item['qty'].toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'Quantity',
                                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                                    border: InputBorder.none,
                                  ),
                                  readOnly: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'Payment Method',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      DropdownButtonFormField<String>(
                        value: _paymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _paymentMethod = value;
                            _isGcashSelected = value == 'GCash';
                          });
                          if (_isGcashSelected) {
                            _showGcashDialog();
                          }
                        },
                        items: const [
                          DropdownMenuItem(value: 'GCash', child: Text('GCash')),
                        ],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                      if (_isGcashSelected) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'GCash Reference Code',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextFormField(
                          controller: _referenceCodeController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                      const Text(
                        'Total Fee',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextFormField(
                        initialValue: '₱${NumberFormat('#,##0.00').format(widget.totalFee)}',
                        // initialValue: '₱${widget.totalFee.toStringAsFixed(2)}',
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _saveReservation(userData),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 36, 131, 226), 
                      minimumSize: const Size(400, 50),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, 
                      ),
                      foregroundColor: Colors.white, 
                    ),
                    child: const Text('Confirm Reservation'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Color _getColorFromString(String colorString) {
    switch (colorString.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
