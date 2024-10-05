import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gown_rental/card/gown_detail_page.dart';

class SearchResultsPage extends StatelessWidget {
  final String query;

  const SearchResultsPage({super.key, required this.query});

  Stream<List<Map<String, dynamic>>> _searchGowns(String query) {
    return Supabase.instance.client
        .from('gownlist')
        .select('*')
        .or('gownName.ilike.%$query%,type.ilike.%$query%')
        .gt('qty', 0)
        .asStream()
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  @override
  Widget build(BuildContext context) {
    // Get the current brightness (dark or light mode)
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(30.0),
          ),
          child: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_outlined, color: isDarkMode ? Colors.white : Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              'Search Results',
              style: GoogleFonts.poppins(
                textStyle: Theme.of(context).textTheme.headline6?.copyWith(
                      color: isDarkMode ? Colors.white : Colors.black,
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
        stream: _searchGowns(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No results found'));
          }

          final gowns = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two columns
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.7, // Adjust the aspect ratio to control height
            ),
            itemCount: gowns.length,
            itemBuilder: (context, index) {
              final gown = gowns[index];
              final imageUrl = gown['imageUrl'] as String? ?? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRgZ-HCdoGUy2nI_WfKwckkDEGi7zB_B4G6o-1WIWRcYGureJhmc2LRyo2PtSmJLaUdHtE&usqp=CAU';

              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => GownDetailPage(
                        imageUrl: imageUrl.isNotEmpty ? imageUrl : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRgZ-HCdoGUy2nI_WfKwckkDEGi7zB_B4G6o-1WIWRcYGureJhmc2LRyo2PtSmJLaUdHtE&usqp=CAU', // Handle empty URLs
                        gownName: gown['gownName'] ?? 'Unknown Name',
                        gownType: gown['type'] ?? 'Unknown Type',
                        gownSize: gown['size'] ?? 'Unknown Size',
                        gownReservationPrice: gown['reservationPrice'].toString(),
                        gownQty: gown['qty'].toString(),
                        gownLowRentalRate: int.parse(gown['lowrentalRate'].toString()),
                        gownHighRentalRate: int.parse(gown['highrentalRate'].toString()),
                        gownColor: gown['color'] ?? 'Unknown Color',
                        gownStyle: gown['style'] ?? 'Unknown Style',
                        gownDescription: gown['description'] ?? 'No Description Available',
                        gownID: gown['gownID'] ?? 0,
                        rentalFee: gown['rentalFee'] ?? 0,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: isDarkMode ? Colors.grey[800] : Colors.white,
                    border: isDarkMode 
                        ? null  // No border in dark mode
                        : Border.all(  // Add a border in light mode
                            color: Colors.grey,  // You can change the color as needed
                            width: 1.0,
                          ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                width: double.infinity,
                                height: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.broken_image, size: 100);
                                },
                              )
                            : const Icon(Icons.image_not_supported, size: 100),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              gown['gownName'] ?? 'Unknown Name',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                             // maxLines: 1,
                             // overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              '${gown['type']} - ${gown['size']}',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            Text(
                              '₱${gown['lowrentalRate'].toStringAsFixed(2)} - ₱${gown['highrentalRate'].toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: isDarkMode ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
