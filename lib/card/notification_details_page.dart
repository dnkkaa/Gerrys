import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationDetailsPage extends StatelessWidget {
  final Map<String, dynamic> notification;
  final int status;
  final int notificationId;

  const NotificationDetailsPage({
    Key? key,
    required this.notification,
    required this.status,
    required this.notificationId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Assuming gownlist contains the gown data with imageUrl
    final String gownName = notification['gownName'] ?? 'Unknown Gown'; 
    final String imageUrl = notification['gownlist']?['imageUrl'] ?? ''; // Fetching imageUrl from gownlist

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
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
              'Notification Details',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display image if available
            imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                )
              : const Text('No Image Available'),

            const SizedBox(height: 16),
             Text('Reservation ID: $notificationId', style: Theme.of(context).textTheme.headline6),
            const SizedBox(height: 8),
            Text('Gown Name: $gownName', style: Theme.of(context).textTheme.bodyText1),
            Text('Status: ${_getStatusText(status)}', style: Theme.of(context).textTheme.subtitle1),
            const SizedBox(height: 16),

          ],
        ),
      ),
    );
  }

  // Status text helper
  String _getStatusText(int status) {
    switch (status) {
      case 1:
        return 'Confirmed';
      case 2:
        return 'Pick Up';
      case 3:
        return 'Rented';
      case 4:
        return 'Returned';
      case 5:
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }
}
