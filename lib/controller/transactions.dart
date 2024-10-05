// ignore_for_file: use_build_context_synchronously, avoid_print, unused_element

import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';


class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90.0), 
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
              'Transactions',
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
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.white,
              tabs: const [
                Tab(text: 'Track'),
                Tab(text: 'Cancel'),
                Tab(text: 'Review'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TrackTab(),
          CancelTab(),
          ReviewTab(),
        ],
      ),
    );
  }
}

class TrackTab extends StatefulWidget {
  const TrackTab({super.key});

  @override
  _TrackTabState createState() => _TrackTabState();
}


class _TrackTabState extends State<TrackTab> {
  String? selectedGownName;

  Stream<List<Map<String, dynamic>>> _reservationStream() {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      return Stream.value([]);
    }

    return Supabase.instance.client
        .from('gown_rental')
        .select('id, gownName, status, dateReturn, qty, gownID, totalFee, imageUrl') 
        .neq('status', 6)
        .neq('status', 5)
       // .neq('status', 4)
        .eq('user_id', userId)
        .asStream(); 
  }

  String _formatDates(String dateReturn) {
    try {
      final DateTime parsedDate = DateTime.parse(dateReturn).toUtc();
      final localDate = parsedDate.add(const Duration(hours: 8)); 

      final dateFormatter = DateFormat('MMM d, yyyy'); 
      final timeFormatter = DateFormat('hh:mm a');
      
      final formattedDate = dateFormatter.format(localDate);
      final formattedTime = timeFormatter.format(localDate);

      return '                                                        $formattedDate at $formattedTime';
    } catch (e) {
      print('Error parsing date: $e'); 
      return dateReturn; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>( 
      stream: _reservationStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return const Center(child: Text('Error fetching reservation data'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No gowns reserved'));
        }

        final reservations = snapshot.data!;
        final gownNames = reservations
            .map((item) => item['gownName'] as String?)
            .where((name) => name != null)
            .toSet() 
            .cast<String>() 
            .toList();

        // Updated gownBuildSteps to hold complete information
        final gownBuildSteps = {
          for (var item in reservations)
            if (item['gownName'] != null)
              item['gownName'] as String: {
                'status': int.tryParse(item['status'].toString()) ?? 0,
                'dateReturn': item['dateReturn'] as String?,
                'id': item['id'] as int, 
                'gownID': item['gownID'] as int, 
                'qty': item['qty'] as int, 
                'totalFee': item['totalFee'] as int, 
                'imageUrl': item['imageUrl'] as String,
              },
        };

        if (!gownNames.contains(selectedGownName)) {
          selectedGownName = null;
        }

        return SingleChildScrollView( 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              hint: Text(
                "Track gown",
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white 
                      : Colors.black, 
                ),
              ),
              value: selectedGownName,
              onChanged: (String? newValue) {
                setState(() {
                  selectedGownName = newValue;
                });
              },
              items: gownNames.map((String gownName) {
                return DropdownMenuItem<String>(
                  value: gownName,
                  child: Text(
                    gownName,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white 
                          : Colors.black, 
                    ),
                  ),
                );
              }).toList(),
            ),
            if (selectedGownName != null)
              _buildStepsForSelectedGown(gownBuildSteps),
            ],
          )
        );
      },
    );
  }

Widget _buildStepsForSelectedGown(Map<String, dynamic> gownBuildSteps) {
  final gownData = gownBuildSteps[selectedGownName!]!;
  final reservationStatus = gownData['status'] ?? 0;
  final dateReturn = gownData['dateReturn'] as String?;
  final reservationId = gownData['id']; 
 // final gownID = gownData['gownID'];
  final qty = gownData['qty']?.toString() ?? 'N/A';
  final totalFee = gownData['totalFee'] != null 
  ? NumberFormat("#,##0.00").format(gownData['totalFee']) 
  : 'N/A';
  final imageUrl = gownData['imageUrl'];

  if (reservationStatus == 3) {
    Future.delayed(Duration.zero, () {
      _showPenaltyDialog(context, dateReturn);
    });
  }
  if (reservationStatus == 4) {
    Future.delayed(Duration.zero, () {
      _showReturnedDialog(context);
    });
  }

  return Column(
    children: [
      buildStep(context, 'Pending', 'Your reservation is pending.', reservationStatus >= 0),
      buildStep(context, 'Confirmation', 'Your reservation has been confirmed.', reservationStatus >= 1),
      buildStep(context, 'Pick Up', 'Your gown is ready for pick up.', reservationStatus >= 2),
      buildStep(context, 'Rented', 'The gown has been successfully rented', reservationStatus >= 3),
      buildStep(context, 'Returned', 'The gown has been returned.', reservationStatus >= 4, isLast: true),

      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (imageUrl != null && imageUrl.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2), 
                borderRadius: BorderRadius.circular(8), 
              ),
              margin: const EdgeInsets.only(left: 30), 
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8), 
                child: Image.network(
                  imageUrl,
                  width: 140, 
                  height: 130, 
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(width: 20), 
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reservation ID: $reservationId', style: const TextStyle(fontWeight: FontWeight.bold)),
               // Text('Gown ID: $gownID', style: const TextStyle(fontSize: 14.0)),
               // Text('Gown Name: $selectedGownName', style: const TextStyle(fontSize: 14.0)),
                Text('Qty: $qty', style: const TextStyle(fontSize: 14.0)),
                Text('Total Fee: ₱$totalFee', style: const TextStyle(fontSize: 14.0)),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 50),
      if (reservationStatus == 0 || reservationStatus == 1) 
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text('Reservation ID: $reservationId', style: const TextStyle(fontWeight: FontWeight.bold)),
              // Text('Gown Name: $selectedGownName', style: const TextStyle(fontSize: 16.0)),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () async {
                  if (reservationStatus == 0) {
                    _showCancelPendingDialog(context, reservationId);
                  } else if (reservationStatus == 1) {
                  _showCancelDialog(context, reservationId);
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue, shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30), 
                ),
                child: const Text('Cancel Reservation'),
              ),
            ],
          ),
        ),
    ],
  );
}

void _showPenaltyDialog(BuildContext context, String? dateReturn) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Adjust the border radius as needed
            side: const BorderSide(color: Colors.grey, width: 1), // Set the border color and width
          ),
        title: const Text('Penalty Information'),
        content: Text(
          'You will receive a penalty worth ₱100.00 for late return and it will x2 until you return it completely.\n\nReturn the gown on the said date: ${dateReturn != null ? _formatDates(dateReturn) : 'N/A'}',
          style: const TextStyle(
            fontSize: 16.0,    
            fontWeight: FontWeight.w400, 
            color: Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); 
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

void refreshData() async {
  setState(() {});
}
void _showCancelPendingDialog(BuildContext context, reservationId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Adjust the border radius as needed
            side: const BorderSide(color: Colors.grey, width: 1), // Set the border color and width
          ),
        title: const Text('Cancel Reservation?'),
        content: const Text(
          'Do you want to cancel your reservation?',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
          textAlign: TextAlign.justify,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); 
            },
            style: TextButton.styleFrom(
                backgroundColor: Colors.red, // Set button background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5), // Rectangle button with rounded corners
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0), // Adjust padding
              ),
              child: const Text(
                'No',
                style: TextStyle(color: Colors.white), // Set text color
              ),
          ),
          TextButton(
            onPressed: () async {
              await _cancelReservation(reservationId);
               if (mounted) {
                Navigator.of(context).pop();
                refreshData();
              }
            },
            style: TextButton.styleFrom(
                backgroundColor: Colors.blue, // Set button background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5), // Rectangle button with rounded corners
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0), // Adjust padding
              ),
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.white), // Set text color
              ),
          ),
        ],
      );
    },
  );
}

void _showCancelDialog(BuildContext context, reservationId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Adjust the border radius as needed
            side: const BorderSide(color: Colors.grey, width: 1), // Set the border color and width
        ),
        title: const Text('Cancel Confirmation'),
        content: const Text(
          'Do you want to cancel your reservation?\n\nIf yes, you will get a penalty of ₱100.00.',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
          textAlign: TextAlign.justify, 
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); 
            },
            style: TextButton.styleFrom(
                backgroundColor: Colors.red, // Set button background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5), // Rectangle button with rounded corners
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0), // Adjust padding
              ),
              child: const Text(
                'No',
                style: TextStyle(color: Colors.white), // Set text color
              ),
          ),
          TextButton(
            onPressed: () async {
              await _cancelReservation(reservationId);
               if (mounted) {
                Navigator.of(context).pop();
                refreshData();
              }
            },
            style: TextButton.styleFrom(
                backgroundColor: Colors.blue, // Set button background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5), // Rectangle button with rounded corners
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0), // Adjust padding
              ),
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.white), // Set text color
              ),
          ),
        ],
      );
    },
  );
}

void _showReturnedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Adjust the border radius as needed
            side: const BorderSide(color: Colors.grey, width: 1), // Set the border color and width
        ),
        title: const Text('Rented Information'),
        content: const Text(
          'Make a review to the gown you\'ve rented by visiting the Review tab. \n\n\nThank you.',
          style: TextStyle(
            fontSize: 16.0,    
            fontWeight: FontWeight.w400,  
            color: Colors.black87, 
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); 
              // Navigator.of(context).pushReplacement(
              //   MaterialPageRoute(builder: (context) => const ReviewTab()),
              // );
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

Future<void> _cancelReservation(int reservationId) async {
  int penaltyAmount = 100;

  final response = await Supabase.instance.client
      .from('gown_rental')
      .update({
        'status': 5,               
        'cancelledPenalty': penaltyAmount,  
      })
      .eq('id', reservationId);

  if (response == null) {
    print('Error: Response is null');
  } else if (response.error != null) {
    print('Error updating reservation status: ${response.error!.message}');
  } else {
    print('Reservation status and penalty updated successfully');
    if (mounted) {
      Navigator.of(context).pop(); // Navigate back after success
    }
  }
}

Widget buildStep(BuildContext context, String title, String subtitle, bool isActive, {bool isLast = false,  String? note}) {
    return Column(
      children: [
        Row(
          children: [
            Column(
              children: [
                Icon(
                  isActive ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isActive ? Colors.green : Colors.grey,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 50,
                    color: Colors.grey,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(subtitle),
                  if (note != null) 
                    Text(
                      note,
                      style: const TextStyle(color: Colors.red), 
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}


class CancelTab extends StatelessWidget {
  const CancelTab({super.key});

  String _formatDate(String createdAt) {
    try {
      final DateTime parsedDate = DateTime.parse(createdAt).toUtc();
      final localDate = parsedDate.add(const Duration(hours: 8)); 

      final dateFormatter = DateFormat('MMM d, yyyy'); 
      final timeFormatter = DateFormat('hh:mm a');
      
      final formattedDate = dateFormatter.format(localDate);
      final formattedTime = timeFormatter.format(localDate);

      return '                                                      $formattedTime  $formattedDate';
    } catch (e) {
      print('Error parsing date: $e'); 
      return createdAt; 
    }
  }

  Stream<List<Map<String, dynamic>>> _fetchCancelledGownsStream() {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      return Stream.value([]);
    }

    return Supabase.instance.client
        .from('gown_rental')
        .select('*')
        .eq('status', 5) 
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .asStream();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _fetchCancelledGownsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No cancelled transactions found.'));
        }

        final cancelledGowns = snapshot.data!;

        return ListView.builder(
          itemCount: cancelledGowns.length,
          itemBuilder: (context, index) {
            final gown = cancelledGowns[index];
            final gownId = gown['id']; // Assuming 'id' is the primary key in gown_rental table
            final gownName = gown['gownName'] ?? 'Unnamed Gown'; // Handle null gownName safely
            final createdAt = gown['created_at'] ?? ''; // Assuming created_at stores the cancellation time
            
            final formattedDate = _formatDate(createdAt);

            return ListTile(
              contentPadding: const EdgeInsets.all(8.0),
              title: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Reservation ',
                      style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black),
                    ),
                    TextSpan(
                      text: '$gownId',
                      style: TextStyle(
                        color: isDarkMode ? Colors.lightBlueAccent : Colors.blue, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    TextSpan(
                      text: ' ($gownName)',
                      style: TextStyle(
                        color: isDarkMode ? Colors.orangeAccent : Colors.red, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    TextSpan(
                      text: ' has been cancelled.',
                      style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black),
                    ),
                  ],
                ),
              ),
              subtitle: Text(
                formattedDate,
                style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54),
              ),
            );
          },
        );
      },
    );
  }
}

//REVIEW
class ReviewTab extends StatefulWidget {
  const ReviewTab({super.key});

  @override
  _ReviewTabState createState() => _ReviewTabState();
}

class _ReviewTabState extends State<ReviewTab> {
  Uint8List? _selectedImageBytes;
  File? _selectedImageFile;
  Uint8List? _selectedVideoBytes;
  File? _selectedVideoFile;
  final TextEditingController _reviewsController = TextEditingController();

  @override
  void dispose() {
    _reviewsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
        });
      } else {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedVideoBytes = bytes;
        });
      } else {
        setState(() {
          _selectedVideoFile = File(pickedFile.path);
        });
      }
    }
  }

  Future<String?> _uploadImage(BuildContext context) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}';

      if (kIsWeb && _selectedImageBytes != null) {
        await Supabase.instance.client.storage
            .from('gown')
            .uploadBinary(fileName, _selectedImageBytes!);
      } else if (_selectedImageFile != null) {
        await Supabase.instance.client.storage
            .from('gown')
            .upload(fileName, _selectedImageFile!);
      }

      final String imageUrl = Supabase.instance.client.storage
          .from('gown')
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) 
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
      return null;
    }
  }

  Future<String?> _uploadVideo(BuildContext context) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.mp4';

      if (kIsWeb && _selectedVideoBytes != null) {
        await Supabase.instance.client.storage
            .from('gown')
            .uploadBinary(fileName, _selectedVideoBytes!);
      } else if (_selectedVideoFile != null) {
        await Supabase.instance.client.storage
            .from('gown')
            .upload(fileName, _selectedVideoFile!);
      }

      final String videoUrl = Supabase.instance.client.storage
          .from('gown')
          .getPublicUrl(fileName);

      return videoUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload video: $e')),
      );
      return null;
    }
  }

  Stream<List<Map<String, dynamic>>> _reservationDataStream() {
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) {
    return Stream.value([]);
  }

  return Supabase.instance.client
      .from('gown_rental')
      .select('*') 
      .eq('status', 4) 
      .eq('user_id', userId)
      .asStream();
}

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _reservationDataStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching reservation data'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No items available for review'));
        }

        final reservations = snapshot.data!;

        return ListView.builder(
          itemCount: reservations.length,
          itemBuilder: (context, index) {
            final reservation = reservations[index];
            final gownName = reservation['gownName'] as String;
            final reviews = reservation['reviews'] as String?;
            final imageUrl = reservation['imageUrl'] as String?;
            final videoUrl = reservation['videoUrl'] as String?;
            final gownID = reservation['gownID'] as int;

            return ReviewItem(
              gownID: gownID,
              gownName: gownName,
              initialReviews: reviews,
              initialImageUrl: imageUrl,
              initialVideoUrl: videoUrl,
            );
          },
        );
      },
    );
  }
}

class ReviewItem extends StatefulWidget {
  final int gownID;
  final String gownName;
  final String? initialReviews;
  final String? initialImageUrl;
  final String? initialVideoUrl;

  const ReviewItem({
    required this.gownID,
    required this.gownName,
    this.initialReviews,
    this.initialImageUrl,
    this.initialVideoUrl,
    Key? key,
  }) : super(key: key);

  @override
  _ReviewItemState createState() => _ReviewItemState();
}

class _ReviewItemState extends State<ReviewItem> {
  Uint8List? _selectedImageBytes;
  File? _selectedImageFile;
  Uint8List? _selectedVideoBytes;
  File? _selectedVideoFile;
  late TextEditingController _reviewsController;
  bool _isExpanded = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _reviewsController = TextEditingController(text: widget.initialReviews);
    _reviewsController.addListener(_onReviewTextChanged);
  }

  @override
  void dispose() {
    _reviewsController.removeListener(_onReviewTextChanged);
    _reviewsController.dispose();
    super.dispose();
  }

   void _onReviewTextChanged() {
  }

  bool _canSubmitReview() {
    return _reviewsController.text.isNotEmpty || _selectedImageBytes != null || _selectedImageFile != null;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
        });
      } else {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedVideoBytes = bytes;
        });
      } else {
        setState(() {
          _selectedVideoFile = File(pickedFile.path);
        });
      }
    }
  }

  Future<String?> _uploadImage(BuildContext context) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}';

      if (kIsWeb && _selectedImageBytes != null) {
        await Supabase.instance.client.storage
            .from('gown')
            .uploadBinary(fileName, _selectedImageBytes!);
      } else if (_selectedImageFile != null) {
        await Supabase.instance.client.storage
            .from('gown')
            .upload(fileName, _selectedImageFile!);
      }

      final String imageUrl = Supabase.instance.client.storage
          .from('gown')
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
      return null;
    }
  }

  Future<String?> _uploadVideo(BuildContext context) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.mp4';

      if (kIsWeb && _selectedVideoBytes != null) {
        await Supabase.instance.client.storage
            .from('gown')
            .uploadBinary(fileName, _selectedVideoBytes!);
      } else if (_selectedVideoFile != null) {
        await Supabase.instance.client.storage
            .from('gown')
            .upload(fileName, _selectedVideoFile!);
      }

      final String videoUrl = Supabase.instance.client.storage
          .from('gown')
          .getPublicUrl(fileName);

      return videoUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload video: $e')),
      );
      return null;
    }
  }

Stream<Map<String, String?>?> _userDetailsStream() {
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId != null) {
    return Supabase.instance.client
        .from('users')
        .stream(primaryKey: ['username', 'avatarUrl']) 
        .eq('id', userId)
        .limit(1)  
        .execute()
        .map((data) {
          if (data.isNotEmpty) {
            return {
              'username': data.first['username'] as String?,
              'avatarUrl': data.first['avatarUrl'] as String?
            };
          }
          return null;
        });
  } else {
    return Stream.value(null);
  }
}

Future<void> _submitReview() async {
  if (_isSubmitting || !_canSubmitReview()) return;

  setState(() {
    _isSubmitting = true;
  });

  try {
    String? imageUrl;
    String? videoUrl;

    if (_selectedImageBytes != null || _selectedImageFile != null) {
      imageUrl = await _uploadImage(context);
    }

    if (_selectedVideoBytes != null || _selectedVideoFile != null) {
      videoUrl = await _uploadVideo(context);
    }

    final currentUser = Supabase.instance.client.auth.currentUser;

    if (currentUser == null) {
      throw Exception('User is not authenticated. Please log in.');
    }

    final userDetails = await _userDetailsStream().first;
    final username = userDetails?['username'];
    final avatarUrl = userDetails?['avatarUrl'];

    await Supabase.instance.client.from('reviews').insert({
      'reviews': _reviewsController.text,
      'username': username,
      'avatarUrl': avatarUrl,
      'imageUrl': imageUrl,
      'gownID': widget.gownID,
      'gownName': widget.gownName,
      'videoUrl': videoUrl,
    });

    // Update reservation status
    final updateResponse = await Supabase.instance.client
      .from('gown_rental')
      .update({'status': 6})
      .eq('gownID', widget.gownID)
      .eq('user_id', currentUser.id);

    if (updateResponse.error != null) {
      throw updateResponse.error!;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review submitted successfully!')),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TransactionPage()), 
      );
    });

    setState(() {
      _reviewsController.clear();
      _selectedImageBytes = null;
      _selectedImageFile = null;
      _selectedVideoBytes = null;
      _selectedVideoFile = null;
      _isSubmitting = false;
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review submitted successfully!')),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TransactionPage()), 
      );
    });
    setState(() {
      _isSubmitting = false;
    });
  }
}

@override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;

  return StreamBuilder<Map<String, String?>?>(
    stream: _userDetailsStream(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else {
        final userDetails = snapshot.data;
        final username = userDetails?['username'];
        final avatarUrl = userDetails?['avatarUrl'];

        return Card(
          margin: const EdgeInsets.all(10.0),
          child: ExpansionTile(
            title: Text(widget.gownName, style: const TextStyle(fontSize: 18)),
            initiallyExpanded: _isExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                _isExpanded = expanded;
              });
            },
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (avatarUrl != null) 
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(avatarUrl),
                          radius: 25,
                        ),
                        const SizedBox(width: 10), 
                        Text(
                          username ?? 'Unknown User', 
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (widget.initialImageUrl != null)
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 2, 
                          ),
                          borderRadius: BorderRadius.circular(8), 
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8), 
                          child: Image.network(
                            widget.initialImageUrl!,
                            width: screenWidth * 0.6,
                            height: screenWidth * 0.5,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    if (widget.initialVideoUrl != null)
                      VideoPlayerWidget(videoUrl: widget.initialVideoUrl!),
                    const SizedBox(height: 10),
                    const Text('Review:'),
                    TextField(
                      controller: _reviewsController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Type your review',
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_selectedImageBytes != null)
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image.memory(
                            _selectedImageBytes!,
                            width: screenWidth * 0.3,
                            height: screenWidth * 0.3,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _selectedImageBytes = null; // Reset the image bytes
                              });
                            },
                          ),
                        ],
                      ),
                    if (_selectedImageFile != null)
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image.file(
                            _selectedImageFile!,
                            width: screenWidth * 0.3,
                            height: screenWidth * 0.3,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _selectedImageFile = null; 
                              });
                            },
                          ),
                        ],
                      ),
                    if (_selectedVideoFile != null || _selectedVideoBytes != null)
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        if (_selectedVideoBytes != null)
                          Container(
                            width: screenWidth * 0.3,
                            height: screenWidth * 0.3,
                            child: const Center(child: Text('Video selected (web).')),
                            color: Colors.grey[300],  // Placeholder for web video
                          ),
                        if (_selectedVideoFile != null)
                          Container(
                            width: screenWidth * 0.3,
                            height: screenWidth * 0.3,
                            child: const Center(child: Text('Video selected (file).')),
                            color: Colors.grey[300],  // Placeholder for local video
                          ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _selectedVideoFile = null;
                              _selectedVideoBytes = null;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.image, size: 30),
                          onPressed: _pickImage,
                          tooltip: 'Upload Image',
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.videocam_sharp, size: 30),
                          onPressed: _pickVideo,
                          tooltip: 'Upload Video',
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _canSubmitReview() && !_isSubmitting ? _submitReview : null,
                          icon: const Icon(Icons.send),
                          label: const Text('Send'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                      ],
                     ),const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({required this.videoUrl, Key? key}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Column(
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  setState(() {
                    if (_isPlaying) {
                      _controller.pause();
                    } else {
                      _controller.play();
                    }
                    _isPlaying = !_isPlaying;
                  });
                },
              ),
            ],
          )
        : const CircularProgressIndicator();
  }
}