import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gown_rental/card/gown_detail_page.dart'; 

class GownList extends StatelessWidget {
  const GownList({super.key});

  Stream<List<Map<String, dynamic>>> _streamGowns() {
    return Supabase.instance.client
        .from('gownlist')
        .stream(primaryKey: ['gownID'])
        .gt('qty', 0) 
        .order('gownID', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = screenWidth / 3; 

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
              'Available Gowns',
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
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _streamGowns(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No gowns available.'));
            }

            final gowns = snapshot.data!;

            return ListView.builder(
              itemCount: (gowns.length / 2).ceil(),
              itemBuilder: (context, index) {
                final firstGown = gowns[index * 2];
                final secondGown = index * 2 + 1 < gowns.length
                    ? gowns[index * 2 + 1]
                    : null;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0), // Space between rows
                  child: Row(
                    children: [
                      Flexible(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => GownDetailPage(
                                  imageUrl: firstGown['imageUrl'] ?? '',
                                  gownName: firstGown['gownName'] ?? 'No Name',
                                  gownType: firstGown['type'] ?? 'Unknown Type',
                                  gownSize: firstGown['size'] ?? 'Unknown Size',
                                  gownReservationPrice: (firstGown['reservationPrice'] as int?)?.toString() ?? 'Unknown Reservation Price',
                                  gownQty: (firstGown['qty'] as int?)?.toString() ?? 'Unknown Qty',
                                  gownLowRentalRate: (firstGown['lowrentalRate'] as int?) ?? 0,
                                  gownHighRentalRate: (firstGown['highrentalRate'] as int?) ?? 0,
                                  gownColor: firstGown['color'] ?? 'Unknown Color',
                                  gownStyle: firstGown['style'] ?? 'Unknown Style',
                                  gownDescription: firstGown['description'] ?? 'No Description',
                                  gownID: firstGown['gownID'] ?? '',
                                  rentalFee: firstGown['rentalFee'] ?? 'Unknown Rental Fee',
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 5,
                            child: Column(
                              children: [
                                Image.network(
                                  firstGown['imageUrl'] ?? 'https://st4.depositphotos.com/14953852/24787/v/1600/depositphotos_247872612-stock-illustration-no-image-available-icon-vector.jpg',
                                  fit: BoxFit.cover,
                                  height: imageHeight,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    print('Error loading image: ${firstGown['imageUrl']}');
                                    return const Icon(Icons.error);
                                  },
                                ),
                                const SizedBox(height: 10),
                                ListTile(
                                  title: Text(firstGown['gownName'] ?? 'No Name'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('₱${NumberFormat('#,##0.00').format(double.parse(firstGown['lowrentalRate'].toString()))} - ₱${NumberFormat('#,##0.00').format(double.parse(firstGown['highrentalRate'].toString()))}',
                                      style: const TextStyle(
                                          fontSize: 12.0, 
                                        ),
                                      ),
                                      Text('${firstGown['type'] ?? 'N/A'} - ${firstGown['size'] ?? 'N/A'}',
                                      style: const TextStyle(
                                          fontSize: 12.0, 
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (secondGown != null)
                        const SizedBox(width: 16), 
                      if (secondGown != null)
                        Flexible(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => GownDetailPage(
                                    imageUrl: secondGown['imageUrl'] ?? '',
                                    gownName: secondGown['gownName'] ?? 'No Name',
                                    gownType: secondGown['type'] ?? 'Unknown Type',
                                    gownSize: secondGown['size'] ?? 'Unknown Size',
                                    gownReservationPrice: (secondGown['reservationPrice'] as int?)?.toString() ?? 'Unknown Reservation Price',
                                    gownQty: (secondGown['qty'] as int?)?.toString() ?? 'Unknown Qty',
                                    gownLowRentalRate: (secondGown['lowrentalRate'] as int?) ?? 0,
                                    gownHighRentalRate: (secondGown['highrentalRate'] as int?) ?? 0,
                                    gownColor: secondGown['color'] ?? 'Unknown Color',
                                    gownStyle: secondGown['style'] ?? 'Unknown Style',
                                    gownDescription: secondGown['description'] ?? 'No Description',
                                    gownID: firstGown['gownID'] ?? '',
                                    rentalFee: firstGown['rentalFee'] ?? 'Unknown Rental Fee',
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 5,
                              child: Column(
                                children: [
                                  Image.network(
                                    secondGown['imageUrl'] ?? 'https://st4.depositphotos.com/14953852/24787/v/1600/depositphotos_247872612-stock-illustration-no-image-available-icon-vector.jpg',
                                    fit: BoxFit.cover,
                                    height: imageHeight,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      print('Error loading image: ${secondGown['imageUrl']}');
                                      return const Icon(Icons.error);
                                    },
                                  ),
                                  const SizedBox(height: 10), 
                                  ListTile(
                                    title: Text(secondGown['gownName'] ?? 'No Name'),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                       Text('₱${NumberFormat('#,##0.00').format(double.parse(secondGown['lowrentalRate'].toString()))} - ₱${NumberFormat('#,##0.00').format(double.parse(secondGown['highrentalRate'].toString()))}',
                                      style: const TextStyle(
                                          fontSize: 12.0, 
                                        ),
                                      ),
                                      Text('${secondGown['type'] ?? 'N/A'} - ${secondGown['size'] ?? 'N/A'}',
                                      style: const TextStyle(
                                          fontSize: 12.0, 
                                        ),
                                      ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
