// ignore_for_file: unused_local_variable, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../card/reservation_info.dart'; 

class AddToCartPage extends StatefulWidget {
  const AddToCartPage({super.key});

  @override
  _AddToCartPageState createState() => _AddToCartPageState();
}

class _AddToCartPageState extends State<AddToCartPage> {
  final Set<int> _selectedItems = Set<int>();

  Stream<List<Map<String, dynamic>>> _fetchCartItems() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return Supabase.instance.client
        .from('AddToCart')
        .stream(primaryKey: ['cartID'])
        .eq('userId', user.id)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  double _calculateTotalPrice(List<Map<String, dynamic>> items) {
    double total = 0;
    for (var item in items) {
      if (_selectedItems.contains(item['cartID'])) {
        final reservationPrice = item['reservationPrice'] is int
            ? item['reservationPrice'] as int
            : int.tryParse(item['reservationPrice'].toString()) ?? 0;
        total += reservationPrice * (item['qty'] as int);
      }
    }
    return total;
  }

  Future<void> _removeFromCart(int itemId, BuildContext context) async {
    try {
      final response = await Supabase.instance.client
          .from('AddToCart')
          .delete()
          .eq('cartID', itemId)
          .eq('userId', Supabase.instance.client.auth.currentUser!.id);

      if (response.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove item from cart: ${response.error!.message}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item removed from cart')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item removed from cart')),
      );
    }
  }

  // Future<int> _fetchAvailableStock(int gownID) async {
  //   try {
  //     final data = await Supabase.instance.client
  //         .from('gownlist')
  //         .select('qty')
  //         .eq('gownID', gownID)
  //         .single();

  //     // ignore: unnecessary_null_comparison
  //     if (data != null && data['qty'] != null) {
  //       return data['qty'] as int;
  //     }
  //     return 0; // Return 0 if no 'qty' is found
  //   } catch (error) {
  //     print('Error fetching stock: $error');
  //     return 0; 
  //   }
  // }

Stream<List<Map<String, dynamic>>> _fetchConfirmedReservations() {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    return Stream.value([]);
  }

  return Supabase.instance.client
      .from('gown_rental')
      .select('id, gownName, cartID')
      .eq('user_id', user.id)
      .or('status.eq.1,status.eq.2,status.eq.3,status.eq.4,status.eq.5,status.eq.6') // Use .or for multiple conditions
      .asStream()
      .map((data) => List<Map<String, dynamic>>.from(data));
}

  // Remove confirmed cart items
  Future<void> _removeConfirmedCartItems() async {
    final confirmedReservations = await _fetchConfirmedReservations().first;

    for (var reservation in confirmedReservations) {
      final cartID = reservation['cartID'] != null ? reservation['cartID'] as int : 0;

      if (cartID != 0) {
        await Supabase.instance.client
        .from('AddToCart')
        .delete()
        .eq('cartID', cartID)
        .eq('userId', Supabase.instance.client.auth.currentUser!.id);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _removeConfirmedCartItems(); 
  }
  // Future<void> _showWarningIfMultipleSelected() async {
  //   if (_selectedItems.length > 1) {
  //     return showDialog<void>(
  //       context: context,
  //       barrierDismissible: false, // User must tap button to close dialog
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: const Text('Warning!'),
  //           content: const Text('You can only reserve one item at a time.'),
  //           actions: <Widget>[
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop(); // Close the dialog
  //               },
  //               child: const Text('OK'),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    bool isWebOrLaptop = MediaQuery.of(context).size.width > 600;
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
              'Cart',
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _fetchCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading cart items'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No items in the cart'));
          } else {
            final items = snapshot.data!;
            final totalFee = _calculateTotalPrice(items);

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final gownName = item['gownName'] as String? ?? 'Unknown Name';
                      final reservationPrice = item['reservationPrice'] is int
                          ? item['reservationPrice'] as int
                          : int.tryParse(item['reservationPrice'].toString()) ?? 0;
                      final gownQty = item['qty'] as int? ?? 0;
                      final imageUrl = item['imageUrl'] as String? ?? '';
                      final gownID = item['gownID'] as int? ?? 0;
                      final type = item['type'] as String? ?? 'Unknown Type';
                      final color = item['color'] as String? ?? 'Unknown Color';
                      final size = item['size'] as String? ?? 'Unknown Size';
                      final style = item['style'] as String? ?? 'Unknown Style';
                      final rentalFee = item['rentalFee'] as int? ?? 0;
                      final cartID = item['cartID'] as int? ?? 0;

                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          leading: imageUrl.isNotEmpty
                          ? LayoutBuilder(
                              builder: (context, constraints) {
                                double screenWidth = MediaQuery.of(context).size.width;
                                double screenHeight = MediaQuery.of(context).size.height;

                                double imageSize;
                                if (screenWidth > 1000) { // For larger screens (web, laptops)
                                  imageSize = 100.0; 
                                } if (screenHeight > 1000) { // For larger screens (web, laptops)
                                  imageSize = 100.0; 
                                } else if (screenWidth > 600) { // For medium screens (tablets)
                                  imageSize = 80.0; 
                                } else { 
                                  imageSize = 60.0;
                                }

                                return Container(
                                  width: imageSize,
                                  height: imageSize,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.blue, 
                                      width: 1.0, 
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8), 
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            )
                          : const Icon(Icons.image_not_supported),
                          title: Text(gownName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Price: ₱${reservationPrice.toString()}'),
                              Text('Qty: ${gownQty.toString()}'),
                              Text('Type: $type'),
                            ],
                          ),
                          trailing: Checkbox(
                            value: _selectedItems.contains(cartID),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedItems.add(cartID);
                                } else {
                                  _selectedItems.remove(cartID);
                                }
                              });
                            },
                          ),
                          onLongPress: () async {
                              await _removeFromCart(item['cartID'], context);

                              if (mounted) {
                                setState(() {
                                  _selectedItems.remove(item['cartID']);
                                });
                              }
                            },
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // Aligns items to the start
                  children: [
                    Expanded( // This allows the text to take the remaining width
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Fee: ₱${totalFee.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '*Note: Long press the selected item you wish to remove from the cart.',
                            style: TextStyle(fontSize: 12, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 36, 137, 226),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    onPressed: _selectedItems.isEmpty
                        ? null
                        : () async {
                            final selectedItem = items.firstWhere((item) => item['cartID'] == _selectedItems.first);
                            final selectedItemsList = items.where((item) => _selectedItems.contains(item['cartID'])).toList();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReservationInfoPage(
                                  selectedItems: selectedItemsList,
                                  totalFee: totalFee,
                                  imageUrl: selectedItem['imageUrl'] as String? ?? '', 
                                  gownName: selectedItem['gownName'] as String? ?? 'Unknown Name', 
                                  gownreservationPrice: selectedItem['reservationPrice'] as int? ?? 0, 
                                  quantity: selectedItem['qty'] as int? ?? 1, 
                                  gownType: selectedItem['gownType'] as String? ?? 'Unknown Type', 
                                  gownColor: selectedItem['gownColor'] as String? ?? 'Unknown Color', 
                                  gownSize: selectedItem['gownSize'] as String? ?? 'Unknown Size', 
                                  gownStyle: selectedItem['gownStyle'] as String? ?? 'Unknown Style', 
                                  rentalFee: selectedItem['rentalFee'] as int? ?? 0,
                                  gownID: selectedItem['gownID'] as int? ?? 0, 
                                  totalPrice: _calculateTotalPrice(selectedItemsList),
                                  cartItems: selectedItemsList, 
                                ),
                              ),
                            );
                          },
                    child: LayoutBuilder( 
                      builder: (context, constraints) {
                        return const Row(
                          mainAxisAlignment: MainAxisAlignment.center, 
                          children: [
                            Flexible( 
                              child: Text(
                                'Check Out',
                                overflow: TextOverflow.ellipsis, 
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white, // Set the text color to white
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  )

                ),
              ],
            );
          }
        },
      ),
    );
  }
}
