import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gown_rental/card/reservation_info.dart';
import 'package:intl/intl.dart';

class ReservePage extends StatefulWidget {
  final String imageUrl;
  final String gownName;
  final int gownreservationPrice;
  final int gownQty;
  final String gownType;
  final String gownColor;
  final String gownSize;
  final String gownStyle;
  final int gownID;
  final int rentalFee;

  const ReservePage({
    super.key,
    required this.imageUrl,
    required this.gownName,
    required this.gownreservationPrice,
    required this.gownQty,
    required this.gownType,
    required this.gownColor,
    required this.gownSize,
    required this.gownStyle,
    required this.gownID,
    required this.rentalFee,
  });

  @override
  _ReservePageState createState() => _ReservePageState();
}

class _ReservePageState extends State<ReservePage> {
  late int quantity;
  late double totalPrice;

  @override
  void initState() {
    super.initState();
    quantity = widget.gownQty;
    totalPrice = widget.gownreservationPrice.toDouble() * quantity;
  }

  void updateTotalPrice() {
    setState(() {
      totalPrice = widget.gownreservationPrice.toDouble() * quantity;
    });
  }

  Color _getBorderColor() {
    switch (widget.gownColor.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      default:
        return Colors.grey; // Default color if not matched
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
              'Reserve',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _getBorderColor(),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: SizedBox(
                  width: 800,
                  height: 450,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.gownName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            _buildDetailText(
              'Reservation Price: ', 
              '₱${NumberFormat('#,##0.00').format(widget.gownreservationPrice)}', // Format the reservation price
              context,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Qty reserve: $quantity',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Total: ₱${NumberFormat('#,##0.00').format(totalPrice)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReservationInfoPage(
                      gownID: widget.gownID,
                      imageUrl: widget.imageUrl,
                      gownName: widget.gownName,
                      gownreservationPrice: widget.gownreservationPrice, 
                      gownType: widget.gownType,
                      gownColor: widget.gownColor,
                      gownSize: widget.gownSize,
                      gownStyle: widget.gownStyle,
                      quantity: quantity,
                      totalFee: totalPrice, 
                      rentalFee: widget.rentalFee,
                      selectedItems: [
                        {
                        'gownID': widget.gownID,
                        'imageUrl': widget.imageUrl,
                        'gownName': widget.gownName,
                        'reservationPrice': widget.gownreservationPrice,
                        'qty': quantity,
                        'type': widget.gownType,
                        'color': widget.gownColor,
                        'size': widget.gownSize,
                        'style': widget.gownStyle,
                        'rentalFee': widget.rentalFee,
                      }
                      ], totalPrice: totalPrice, cartItems: [],
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(MediaQuery.of(context).size.width * 1.0, 50),  // 80% of screen width
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text('Proceed'),
           )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailText(String title, String value, BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        TextSpan(
          text: value,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    ),
  );
 }
}
