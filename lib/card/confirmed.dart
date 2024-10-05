import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:gown_rental/homepage.dart';

class Confirmed extends StatefulWidget {
  const Confirmed({super.key});

  @override
  _ConfirmedState createState() => _ConfirmedState();
}

class _ConfirmedState extends State<Confirmed> {
  @override
  void initState() {
    super.initState();
    // Automatically show the dialog when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTransactionDialog();
    });
  }

  // Function to show the dialog message
  void _showTransactionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Adjust the border radius as needed
            side: const BorderSide(color: Colors.grey, width: 1), // Set the border color and width
          ),
          title: const Text('Transaction Information'),
          content: const Text.rich(
            TextSpan(
              text: 'To check or track your transaction, visit your ',
              children: <TextSpan>[
                TextSpan(
                  text: '\'Profile\'',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' and click the ',
                ),
                TextSpan(
                  text: 'Transaction',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: ' option.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Navigate to homepage after closing dialog
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue, // Set button background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5), // Rectangle button with rounded corners
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0), // Adjust padding
              ),
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white), // Set text color
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/logo.png',
              height: 500, // Set desired height for the image
              width: 500,  // Set desired width for the image
            ),
          ),
        ],
      ),
    );
  }
}
