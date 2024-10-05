// ignore_for_file: unnecessary_null_comparison, unused_field
import 'package:flutter/material.dart';
import 'package:gown_rental/Admin/Forms/editReservation.dart';
import 'package:gown_rental/Admin/Profile/profilePage.dart';
import 'package:gown_rental/Admin/Setting/settingsPage.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:gown_rental/Admin/Forms/addGown.dart';
import 'package:gown_rental/Admin/Forms/addReservation.dart';
import 'package:gown_rental/Admin/Forms/addRented.dart';
import 'package:gown_rental/Admin/Forms/editGown.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gown_rental/pages/login_page.dart';
import 'package:gown_rental/Admin/Forms/categories.dart';


class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Close the drawer after selection
  }

  Stream<List<Map<String, dynamic>>> _userStream() {
    return Supabase.instance.client
        .from('users')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Future<void> _deleteUser(String userId) async {
    final response = await Supabase.instance.client
        .from('users')
        .delete()
        .eq('id', userId);

    if (response.error != null) {
      throw Exception(response.error!.message);
    }
  }

Future<String?> _fetchAvatarUrl() async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return null;

  try {
    final response = await Supabase.instance.client
        .from('users')
        .select('avatarUrl')
        .eq('id', userId)
        .single();

    // Check if the response contains data
    if (response != null && response['avatarUrl'] != null) {
      return response['avatarUrl'] as String?;
    } else {
      return null; // Return null if there's no data
    }
  } catch (e) {
    // Handle any errors that occur during the query
    print('Error fetching avatar URL: $e');
    return null; // Return null if there's an error
  }
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Admin'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0), 
          child: FutureBuilder<String?>(
            future: _fetchAvatarUrl(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircleAvatar(
                  backgroundColor: Colors.grey,
                );
              }

              if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                return const CircleAvatar(
                  backgroundColor: Colors.grey, // Default avatar if there's no avatar_url
                  child: Icon(Icons.person, color: Colors.white),
                );
              }

              return PopupMenuButton<int>(
                icon: CircleAvatar(
                  backgroundImage: NetworkImage(snapshot.data!),
                ),
                onSelected: (value) {
                  if (value == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfilePage()),
                    );
                  } else if (value == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsPage()),
                    );
                  } else if (value == 2) {
                    _logout(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 0,
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.black), // Icon for Profile
                        SizedBox(width: 10), // Space between icon and text
                        Text("Profile"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: Colors.black), // Icon for Settings
                        SizedBox(width: 10), // Space between icon and text
                        Text("Settings"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 2,
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.black), // Icon for Logout
                        SizedBox(width: 10), // Space between icon and text
                        Text("Logout"),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
      // Add a Drawer here if needed
    ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Admin Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Categories'),
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Gown Inventory'),
              onTap: () => _onItemTapped(2),
            ),
            ListTile(
              leading: const Icon(Icons.assignment_return),
              title: const Text('Manage Rental Request'),
              onTap: () => _onItemTapped(3),
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Manage Reservation'),
              onTap: () => _onItemTapped(4),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Manage Gown Rentals'),
              onTap: () => _onItemTapped(5),
            ),
            ListTile(
              leading: const Icon(Icons.assignment_turned_in),
              title: const Text('Cancelled'),
              onTap: () => _onItemTapped(6),
            ),
            ListTile(
              leading: const Icon(Icons.assignment_turned_in),
              title: const Text('Report'),
              onTap: () => _onItemTapped(7),
            ),
            ListTile(
              leading: const Icon(Icons.assignment_turned_in),
              title: const Text('History'),
              onTap: () => _onItemTapped(8),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Manage Users'),
              onTap: () => _onItemTapped(9),
            ),
          ],
        ),
      ),
      body: _getSelectedPage(),
    );
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return const Center(child: Text('Dashboard', style: TextStyle(fontSize: 24.0)));
      case 1:
        return _buildCategoryAndColorsPage();
      case 2:
        return _buildAddGownPage();
      case 3:
        return _buildRequestPage();
      case 4:
        return _buildReservationPage();
      case 5:
        return _buildRentedPage();
      case 6:
        return _buildCancelPage();
      case 7:
        return _buildReportPage();
      case 8:
        return _buildHistoryPage();
      case 9:
        return const Center(child: Text('User', style: TextStyle(fontSize: 24.0)));
      default:
        return const Center(child: Text('Welcome, Admin!', style: TextStyle(fontSize: 24.0)));
    }
  }

  Widget _buildCategoryAndColorsPage() {
    return const CategoryAndColorsPage();
  }

  Widget _buildAddGownPage() {
    return _AddGownPage(); // Fixed this to return the correct widget
  }

  Widget _buildRequestPage() {
    return _RequestPage(); 
  }

  Widget _buildReservationPage() {
    return _ReservationPage(); 
  }

  Widget _buildRentedPage() {
    return _RentedPage();
  }
  Widget _buildCancelPage() {
    return _CancelPage();
  }
  Widget _buildReportPage() {
    return _CancelPage();
  }
  Widget _buildHistoryPage() {
    return _CancelPage();
  }

}

//GOWNLIST
class _AddGownPage extends StatefulWidget {
  @override
  _AddGownPageState createState() => _AddGownPageState();
}

class _AddGownPageState extends State<_AddGownPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gown Lists',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddGownForm()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Gowns',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _gownStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No gowns found'));
                }

                final gowns = snapshot.data!.where((gown) {
                  final gownName = gown['gownName']?.toLowerCase() ?? '';
                  final color = gown['color']?.toLowerCase() ?? '';
                  final size = gown['size']?.toLowerCase() ?? '';
                  final reservationPrice = gown['reservationPrice']?.toString() ?? '';
                  final rentalFee = gown['rentalFee']?.toString() ?? '';
                  final type = gown['type']?.toLowerCase() ?? '';

                  return gownName.contains(_searchQuery) ||
                      color.contains(_searchQuery) ||
                      size.contains(_searchQuery) ||
                      reservationPrice.contains(_searchQuery) ||
                      rentalFee.contains(_searchQuery) ||
                      type.contains(_searchQuery);
                }).toList();

                if (gowns.isEmpty) {
                  return const Center(child: Text('No matching gowns found'));
                }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Actions')),  // Actions column moved to the first position
                        DataColumn(label: Text('Gown Image')),  // Gown Image moved after Actions
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Gown Name')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Size')),
                        DataColumn(label: Text('Color')),
                        DataColumn(label: Text('Qty')),
                        DataColumn(label: Text('Reservation Fee')),
                        DataColumn(label: Text('Rental Fee')),
                      ],
                      rows: gowns.map((gown) {
                        return DataRow(
                          cells: [
                            DataCell(Row(  // Actions DataCell moved to the first position
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility, color: Colors.green),
                                  onPressed: () {
                                    _showGownDetails(context, gown);
                                  },
                                ),
                               IconButton(
                                icon: const Icon(Icons.edit, color: Color.fromARGB(255, 8, 118, 208)),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditGownForm(
                                        gownData: gown, // Passing gown data
                                        onUpdate: () {
                                          // Implement logic here to refresh the gown list or other operations
                                          setState(() {
                                            // Rebuild the widget after editing
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _confirmDelete(context, gown['gownID']);
                                  },
                                ),
                              ],
                            )),
                            DataCell(Image.network(
                              gown['imageUrl'] ?? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRgZ-HCdoGUy2nI_WfKwckkDEGi7zB_B4G6o-1WIWRcYGureJhmc2LRyo2PtSmJLaUdHtE&usqp=CAU',
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            )),
DataCell(
  Container(
    padding: const EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      color: gown['status'] == '1' ? Colors.red[100] : null, // RColor.fromARGB(255, 214, 55, 71)or Available status
      border: gown['status'] == '1'
          ? Border.all(color: Colors.red, width: 2.0)
          : null, // Red border for Available status
      borderRadius: BorderRadius.circular(4.0),
    ),
    child: Text(
      gown['status'] == '1' ? 'Available' : gown['status'] ?? 'N/A', // Display 'Available' when status is 1
    ),
  ),
),

                            DataCell(Text(gown['gownName'] ?? 'N/A')),
                            DataCell(Text(gown['type'] ?? 'N/A')),
                            DataCell(Text(gown['size'] ?? 'N/A')),
                            DataCell(Text(gown['color'] ?? 'N/A')),
                            DataCell(Text(gown['qty']?.toString() ?? 'N/A')),
                            DataCell(Text(gown['reservationPrice']?.toString() ?? 'N/A')),
                            DataCell(Text(gown['rentalFee']?.toString() ?? 'N/A')),
                          ],
                        );
                      }).toList(),
                    ),
                  );
              },
            ),
          ),
        ],
      ),
    );
  }

void _showGownDetails(BuildContext context, Map<String, dynamic> gown) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('${gown['gownName']} Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the gown image if an image URL is available
              if (gown['imageUrl'] != null && gown['imageUrl'].isNotEmpty)
                Image.network(
                  gown['imageUrl'],
                  height: 50, // Set a height for the image
                  width: 50, // Make the image fill the width
                  fit: BoxFit.cover, // Make the image cover the space
                ),
              const SizedBox(height: 16), // Add some spacing between the image and details

              Text('Type: ${gown['type']}'),
              Text('Size: ${gown['size']}'),
              Text('Color: ${gown['color']}'),
              Text('Style: ${gown['style']}'),
              Text('Quantity: ${gown['qty']}'),
              Text('Description: ${gown['description']}'),
              Text('Gown Retail Price: ${gown['gownretailPrice']}'),
              Text('Low Rental Rate: ${gown['lowrentalRate']}'),
              Text('High Rental Rate: ${gown['highrentalRate']}'),
              Text('Reservation Fee: ${gown['reservationPrice']}'),
              Text('Rental Fee: ${gown['rentalFees']}'),
            ],
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

void _confirmDelete(BuildContext context, int gownID) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Gown'),
        content: const Text('Are you sure you want to delete this gown?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteGown(gownID);
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

   Future<void> _deleteGown(int gownID) async {
    try {
      await Supabase.instance.client
          .from('gownlist')
          .delete()
          .eq('gownID', gownID);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservation deleted successfully')),
      );
      setState(() {}); // Update the UI after deletion
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete reservation: $error')),
      );
    }
  }


  Stream<List<Map<String, dynamic>>> _gownStream() {
    return Supabase.instance.client
        .from('gownlist')
        .stream(primaryKey: ['gownID'])
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }
}



//REQUEST

class _RequestPage extends StatefulWidget {
  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<_RequestPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gown Rental Request Lists',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _requestStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No request found'));
                }

                final requests = snapshot.data!
                    .where((request) => _matchesSearchQuery(request))
                    .toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Action')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Full Name')),
                      DataColumn(label: Text('Address')),
                      DataColumn(label: Text('Phone Number')),
                      DataColumn(label: Text('Gown Name')),
                      DataColumn(label: Text('Gown Type')),
                      DataColumn(label: Text('Gown Size')),
                      DataColumn(label: Text('Gown Color')),
                      DataColumn(label: Text('Gown Style')),
                      DataColumn(label: Text('Payment Method')),
                      DataColumn(label: Text('Rental Fee')),
                      DataColumn(label: Text('Reservation Price')),
                      DataColumn(label: Text('Quantity')),
                    ],
                    rows: requests.map((request) {
                      return DataRow(
                        cells: [
                          DataCell(Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _updateStatus(request['id'], 1);
                                },
                                child: const Text('Confirm'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  _updateStatus(request['id'], 5);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Cancel'),
                              ),
                            ],
                          )),
                          DataCell(Text(request['status'] ?? 'N/A')),
                          DataCell(Text(request['fullname'] ?? 'N/A')),
                          DataCell(Text(request['address'] ?? 'N/A')),
                          DataCell(Text(request['phone_number']?.toString() ?? 'N/A')),
                          DataCell(Text(request['gownName'] ?? 'N/A')),
                          DataCell(Text(request['type'] ?? 'N/A')),
                          DataCell(Text(request['size'] ?? 'N/A')),
                          DataCell(Text(request['color'] ?? 'N/A')),
                          DataCell(Text(request['style'] ?? 'N/A')),
                          DataCell(Text(request['paymentMethod'] ?? 'N/A')),
                          DataCell(Text(request['rentalFee']?.toString() ?? 'N/A')),
                          DataCell(Text(request['reservationPrice']?.toString() ?? 'N/A')),
                          DataCell(Text(request['qty']?.toString() ?? 'N/A')),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _matchesSearchQuery(Map<String, dynamic> request) {
    final searchFields = [
      request['fullname'],
      request['address'],
      request['phone_number']?.toString(),
      request['gownName'],
      request['type'],
      request['size'],
      request['color'],
      request['style'],
      request['paymentMethod'],
      request['referenceCode']?.toString(),
      request['rentalFee']?.toString(),
      request['reservationPrice']?.toString(),
      request['fullPayment']?.toString(),
      request['qty']?.toString(),
      request['totalFee']?.toString(),
    ];
    return searchFields.any((field) => field != null && field.toLowerCase().contains(_searchQuery));
  }

  Stream<List<Map<String, dynamic>>> _requestStream() {
    return Supabase.instance.client
        .from('gown_rental')
        .stream(primaryKey: ['id'])
        .eq('status', 0)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

Future<void> _updateStatus(int id, int newStatus) async {
  try {
    await Supabase.instance.client
        .from('gown_rental')
        .update({'status': newStatus})
        .eq('id', id);
    
    if (newStatus >= 1) { 
      final requestData = await Supabase.instance.client
          .from('gown_rental')
          .select('gownName, qty')
          .eq('id', id)
          .single();
      
      if (requestData != null) {
        final gownName = requestData['gownName'];
        final qtyToDeduct = requestData['qty'];

        final gownData = await Supabase.instance.client
            .from('gownlist')
            .select('qty')
            .eq('gownName', gownName)
            .single();

        if (gownData != null) {
          final currentQuantity = gownData['qty'];

          final newQuantity = currentQuantity - qtyToDeduct;

          await Supabase.instance.client
              .from('gownlist')
              .update({'qty': newQuantity})
              .eq('gownName', gownName);
        }
      }
    }
  } catch (error) {
    print('Error updating status: $error');
  }
}
}


//RESERVATIONgown---------------------------------------------------------

class _ReservationPage extends StatefulWidget {
  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<_ReservationPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';


  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

String _formatDate(String dateString) {
  DateTime date = DateTime.parse(dateString);
  return '${_monthName(date.month)}/${date.day}/${date.year}';
}

String _monthName(int monthNumber) {
  const months = [
    '01', '02', '03', '04', '05', '06',
    '07', '08', '09', '10', '11', '12'
  ];
  return months[monthNumber - 1];
}

@override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reservation Lists',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddReservationForm()),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16.0),
TextField(
  controller: _searchController,
  decoration: InputDecoration(
    labelText: 'Search Reservations',
    prefixIcon: Icon(Icons.search),
    suffixIcon: _searchController.text.isNotEmpty
        ? IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
            },
          )
        : null,
    border: OutlineInputBorder(),
  ),
  onChanged: (value) {
    // Trigger a rebuild to show or hide the 'x' icon when typing
    // You may need to use setState in a stateful widget
  },
),

const SizedBox(height: 16.0),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _reservationStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No reservation found'));
                }

                final reservations = snapshot.data!.where((reservation) {
                  final gownName = reservation['gownName']?.toLowerCase() ?? '';
                  final color = reservation['color']?.toLowerCase() ?? '';
                  final size = reservation['size']?.toLowerCase() ?? '';
                  final reservationPrice = reservation['reservationPrice']?.toString() ?? '';
                  final rentalFee = reservation['rentalFee']?.toString() ?? '';
                  final type = reservation['type']?.toLowerCase() ?? '';

                  return gownName.contains(_searchQuery) ||
                      color.contains(_searchQuery) ||
                      size.contains(_searchQuery) ||
                      reservationPrice.contains(_searchQuery) ||
                      rentalFee.contains(_searchQuery) ||
                      type.contains(_searchQuery);
                }).toList();

                if (reservations.isEmpty) {
                  return const Center(child: Text('No matching gowns found'));
                }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Action')),
                    DataColumn(label: Text('Status')),
                     DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Image')), // New Image column
                    DataColumn(label: Text('Full Name')),
                    DataColumn(label: Text('Gown Name')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('Reservation Payment')),
                    DataColumn(label: Text('Rental Fee')),
                    DataColumn(label: Text('Balance')),
                  ],
                  rows: reservations.map((reservation) {
                    return DataRow(
                      cells: [
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility, color: Colors.blue),
                              onPressed: () {
                                _viewReservationDetails(reservation);
                              },
                            ),
                             IconButton(
                                  icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => EditReservationForm()),
                                    );
                                  },
                                ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                try {
                                  await _deleteReservation(reservation['id']);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Reservation deleted successfully')),
                                  );
                                  setState(() {}); // Ensure the UI is updated after deletion
                                } catch (error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to delete reservation: $error')),
                                  );
                                }
                              },
                            ),
PopupMenuButton<String>(
  onSelected: (value) async {
    if (value == 'Rent Now') {
      // Call the function without selectedDate, since it's immediate
      await _updateReservationStatus(context, reservation['id'], 3);
    } else if (value == 'Pick Up Later') {  // Ensure this matches the itemBuilder value
      // Show DatePicker for the user to choose a future date
      DateTime? selectedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101),
      );

      if (selectedDate != null) {
        // Pass the selectedDate when renting later
        await _updateReservationStatus(context, reservation['id'], 2, selectedDate);
      }
    } else if (value == 'Cancel') {
      await _updateReservationStatus(context, reservation['id'], 5);
    }
  },
  itemBuilder: (BuildContext context) {
    return {'Rent Now', 'Pick Up Later', 'Cancel'}.map((String choice) {
      return PopupMenuItem<String>(
        value: choice,
        child: Text(choice),
      );
    }).toList();
  },
),

                          ],
                        )),
                        
DataCell(
  Column(
    crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start
    children: [
      Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: reservation['status'] == '1' ? Colors.green[100] : null, // Red background for 'Reserve' status
          border: reservation['status'] == '1'
              ? Border.all(color: Colors.green, width: 2.0) // Red border for 'Reserve' status
              : null,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Text(
          reservation['status'] == '1' ? 'Reserve' : reservation['status'] ?? 'N/A', // Display 'Reserve' when status is 1
        ),
      ),
      const SizedBox(height: 4.0), // Add some spacing
    ],
  ),
),
DataCell(Text(reservation['created_at'] != null? _formatDate(reservation['created_at'].toString()) : 'N/A',),
    ), 
                       
                        DataCell(
                          Image.network(
                            reservation['imageUrl'] ?? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRgZ-HCdoGUy2nI_WfKwckkDEGi7zB_B4G6o-1WIWRcYGureJhmc2LRyo2PtSmJLaUdHtE&usqp=CAU',
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                        ), // Image cell
                        DataCell(Text(reservation['fullname'] ?? 'N/A')),
                        DataCell(Text(reservation['gownName'] ?? 'N/A')),
                        DataCell(Text(reservation['qty']?.toString() ?? 'N/A')),
                        DataCell(Text(reservation['reservationPrice'] != null ? '₱${reservation['reservationPrice'].toStringAsFixed(2)}' : 'N/A')),
                        DataCell(Text(reservation['rentalFee'] != null ? '₱${reservation['rentalFee'].toStringAsFixed(2)}' : 'N/A')),
DataCell( Container(
    padding: const EdgeInsets.all(8.0), // Optional padding
    decoration: BoxDecoration(
      border: Border.all(
        color: Colors.red, // Always use a red border
        width: 2.0, // Width of the border
      ),
      borderRadius: BorderRadius.circular(4.0), // Optional: rounded corners
    ),
    child: Text(
      ((reservation['rentalFee'] ?? 0.0) - (reservation['reservationPrice'] ?? 0.0)).toStringAsFixed(2),
      style: const TextStyle(
        color: Colors.black,  // Default text color (you can customize)
      ),
    ),
  ),
),


                      ],
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}


  Future<void> _viewReservationDetails(Map<String, dynamic> reservation) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reservation Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Full Name: ${reservation['fullname'] ?? 'N/A'}'),
                Text('Gown Name: ${reservation['gownName'] ?? 'N/A'}'),
                Text('Gown Type: ${reservation['type'] ?? 'N/A'}'),
                Text('Gown Size: ${reservation['size'] ?? 'N/A'}'),
                Text('Gown Color: ${reservation['color'] ?? 'N/A'}'),
                Text('Gown Style: ${reservation['style'] ?? 'N/A'}'),
                Text('Balance: ₱${(reservation['rentalFee'] != null && reservation['reservationPrice'] != null) ? (reservation['rentalFee'] - reservation['reservationPrice']).toStringAsFixed(2) : 'N/A'}'),
                Text('Payment Method: ${reservation['paymentMethod'] ?? 'N/A'}'),
                Text('Reservation Fee: ₱${reservation['reservationPrice']?.toStringAsFixed(2) ?? 'N/A'}'),
                Text('Rental Fee: ₱${reservation['rentalFee']?.toStringAsFixed(2) ?? 'N/A'}'),
                Text('Quantity: ${reservation['qty']?.toString() ?? 'N/A'}'),
              ],
            ),
          ),
          actions: <Widget>[
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

// Update your _updateReservationStatus function to handle the selected date
Future<void> _updateReservationStatus(BuildContext context, int id, int status, [DateTime? selectedDate]) async {
  final dateRented = status == 3 ? DateTime.now() : null;
  final dateReturn = dateRented != null ? dateRented.add(Duration(days: 3)) : null;

  try {
    await Supabase.instance.client
        .from('gown_rental')
        .update({
          'status': status,
          'dateRented': dateRented?.toIso8601String(),
          'dateReturn': dateReturn?.toIso8601String(),
          'pickupDate': selectedDate?.toIso8601String(), // Store selected pickup date if applicable
        })
        .eq('id', id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status updated to $status')),
    );
    setState(() {}); // Update the UI
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Failed to update status: $error')),
    );
  }
}
   Future<void> _deleteReservation(int id) async {
    try {
      await Supabase.instance.client
          .from('gown_rental')
          .delete()
          .eq('id', id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservation deleted successfully')),
      );
      setState(() {}); // Update the UI after deletion
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete reservation: $error')),
      );
    }
  }

  Stream<List<Map<String, dynamic>>> _reservationStream() {
    return Supabase.instance.client
        .from('gown_rental')
        .stream(primaryKey: ['id'])
        .eq('status', 1)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }
}



//RENTED---------------------------------------------------------------------------------------------------------------------------------------------

class _RentedPage extends StatefulWidget {
  @override
  _RentedPageState createState() => _RentedPageState();
}

class _RentedPageState extends State<_RentedPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';


  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

String _formatDate(String dateString) {
  DateTime date = DateTime.parse(dateString);
  return '${_monthName(date.month)}/${date.day}/${date.year}';
}

String _monthName(int monthNumber) {
  const months = [
    '01', '02', '03', '04', '05', '06',
    '07', '08', '09', '10', '11', '12'
  ];
  return months[monthNumber - 1];
}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rented Lists',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddRentedForm()),
                  );
                },
              ),
            ],
          ),
        const SizedBox(height: 16.0),
TextField(
  controller: _searchController,
  decoration: InputDecoration(
    labelText: 'Search Gown Rentals',
    prefixIcon: Icon(Icons.search),
    suffixIcon: _searchController.text.isNotEmpty
        ? IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
            },
          )
        : null,
    border: OutlineInputBorder(),
  ),
  onChanged: (value) {
    // Trigger a rebuild to show or hide the 'x' icon when typing
    // You may need to use setState in a stateful widget
  },
),

const SizedBox(height: 16.0),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _rentedStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No gwon rentals found'));
                }

                final renteds = snapshot.data!.where((rented) {
                  
                  final gownName = rented['gownName']?.toLowerCase() ?? '';
                  final color = rented['color']?.toLowerCase() ?? '';
                  final size = rented['size']?.toLowerCase() ?? '';
                  final reservationPrice = rented['reservationPrice']?.toString() ?? '';
                  final rentalFee = rented['rentalFee']?.toString() ?? '';
                  final type = rented['type']?.toLowerCase() ?? '';

                  return gownName.contains(_searchQuery) ||
                      color.contains(_searchQuery) ||
                      size.contains(_searchQuery) ||
                      reservationPrice.contains(_searchQuery) ||
                      rentalFee.contains(_searchQuery) ||
                      type.contains(_searchQuery);
                }).toList();

                if (renteds.isEmpty) {
                  return const Center(child: Text('No matching gowns found'));
                }

  return SingleChildScrollView(
  scrollDirection: Axis.vertical, // Enable vertical scrolling
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal, // Enable horizontal scrolling
    child: DataTable(
      columns: const [
        DataColumn(label: Text('Action')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Full Name')),
        DataColumn(label: Text('Phone Number')),
        DataColumn(label: Text('Gown Name')),
        DataColumn(label: Text('Date Pick Up')),
        DataColumn(label: Text('Date Rented')),
        DataColumn(label: Text('Date Returned')),
        DataColumn(label: Text('Quantity')),
      ],
      rows: renteds.map((rented) {
        return DataRow(
          cells: [
            DataCell(
              Row(
                children: [
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'Rented') {
                        await _updateRentedStatus(rented['id'], 3);  // Change status to 3 (Rented)
                      } else if (value == 'Cancelled') {
                        await _updateRentedStatus(rented['id'], 5);  // Change status to 5 (Cancelled)
                      } else if (value == 'Return') {
                        await _updateRentedStatus(rented['id'], 4);  // Change status to 4 (Return)
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      if (rented['status'] == '2') {
                        // Pick-up status actions
                        return {'Rented', 'Cancelled'}.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      } else if (rented['status'] == '3') {
                        // Rented status actions
                        return {'Return'}.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      } else {
                        // Other statuses, default to Cancelled
                        return {'Cancelled'}.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      }
                    },
                  ),
                ],
              ),
            ),
            DataCell(
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: rented['status'] == '2'
                      ? Colors.yellow  // Yellow for Pick-up
                      : rented['status'] == '3'
                          ? Colors.blue  // Blue for Rented
                          : Colors.transparent,
                  border: Border.all(
                    color: rented['status'] == '2'
                        ? Colors.yellow
                        : rented['status'] == '3'
                            ? Colors.blue
                            : Colors.black,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  rented['status'] == '2'
                      ? 'Pick-up'
                      : rented['status'] == '3'
                          ? 'Rented'
                          : rented['status'] ?? 'N/A',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
            DataCell(Text(rented['fullname'] ?? 'N/A')),
            DataCell(Text(rented['phone_number']?.toString() ?? 'N/A')),
            DataCell(Text(rented['gownName'] ?? 'N/A')),
            DataCell(Text(rented['pickupDate'] != null
                ? _formatDate(rented['pickupDate'].toString())
                : '')),
            DataCell(Text(rented['dateRented'] != null
                ? _formatDate(rented['dateRented'].toString())
                : '')),
            DataCell(Text(rented['dateReturn'] != null
                ? _formatDate(rented['dateReturn'].toString())
                : '')),
            DataCell(Text(rented['qty']?.toString() ?? 'N/A')),
          ],
        );
      }).toList(),
    ),
  ),
);
              },
            ),
          ),
        ],
      ),
    );
  }
// Function to calculate penalty
String calculatePenalty(String status, String? dateReturn) {
  if (status == '3' && dateReturn != null) {
    DateTime returnDate = DateTime.parse(dateReturn);
    DateTime currentDate = DateTime.now();

    if (currentDate.isAfter(returnDate)) {
      // Calculate the number of days after the dateReturn
      int daysLate = currentDate.difference(returnDate).inDays;
      int penalty = daysLate * 100;
      return penalty.toString(); // Display penalty amount
    }
  }
  return '0'; // No penalty if status is not 3 or dateReturn hasn't passed
}
Future<void> _updateRentedStatus(int id, int status) async {
  // When the status is 3 (Rented), set the current date as dateRented
  final dateRented = status == 3 ? DateTime.now() : null;
  
  // Calculate dateReturn 3 days after dateRented
  final dateReturn = dateRented != null ? dateRented.add(Duration(days: 3)) : null;

  try {
    // Update the gown_rental table with both dateRented and dateReturn
    await Supabase.instance.client
        .from('gown_rental')
        .update({
          'status': status,
          'dateRented': dateRented?.toIso8601String(),
          'dateReturn': dateReturn?.toIso8601String(),
        })
        .eq('id', id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status updated to $status')),
    );
    setState(() {}); // Update the UI
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update status: $error')),
    );
  }
}


  Stream<List<Map<String, dynamic>>> _rentedStream() {
    return Supabase.instance.client
        .from('gown_rental')
        .select('*')
        .or('status.eq.2,status.eq.3')
        .limit(1000)
        .asStream()
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Future<void> _deleteReservation(int id) async {
    try {
      await Supabase.instance.client.from('gown_rental').delete().eq('id', id);
    } catch (error) {
      throw Exception('Failed to delete reservation: $error');
    }
  }

  Future<void> _printReceipt(Map<String, dynamic> rented) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Rented Gown Receipt', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text('Full Name: ${rented['fullname'] ?? 'N/A'}'),
                pw.Text('Address: ${rented['address'] ?? 'N/A'}'),
                pw.Text('Phone Number: ${rented['phone_number']?.toString() ?? 'N/A'}'),
                pw.Text('Gown Name: ${rented['gownName'] ?? 'N/A'}'),
                pw.Text('Date Pick Up: ${rented['pickupDate'] ?? 'N/A'}'),
                pw.Text('Date Rented: ${rented['dateRented'] ?? 'N/A'}'),
                pw.Text('Date Returned: ${rented['dateReturn'] ?? 'N/A'}'),
                pw.Text('Quantity: ${rented['qty']?.toString() ?? 'N/A'}'),
                pw.Text('Total Fee: ${rented['totalFee']?.toString() ?? 'N/A'}'),
                pw.SizedBox(height: 20),
                pw.Text('Thank you for renting with us!'),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}


//CANCELLED---------------------------------------------------------------------

class _CancelPage extends StatefulWidget {
  @override
  _CancelPageState createState() => _CancelPageState();
}

class _CancelPageState extends State<_CancelPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gown Rental Cancel Lists',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _cancelStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No Cancel found'));
                }

                final cancelList = snapshot.data!
                    .where((cancel) => _matchesSearchQuery(cancel))
                    .toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Action')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Full Name')),
                      DataColumn(label: Text('Address')),
                      DataColumn(label: Text('Phone Number')),
                      DataColumn(label: Text('Gown Name')),
                      DataColumn(label: Text('Gown Type')),
                      DataColumn(label: Text('Gown Size')),
                      DataColumn(label: Text('Gown Color')),
                      DataColumn(label: Text('Gown Style')),
                      DataColumn(label: Text('Balance')),
                      DataColumn(label: Text('Payment Method')),
                      DataColumn(label: Text('Reference Code')),
                      DataColumn(label: Text('Rental Fee')),
                      DataColumn(label: Text('Reservation Price')),
                      DataColumn(label: Text('Quantity')),
                      DataColumn(label: Text('Total Fee')),
                    ],
                    rows: cancelList.map((cancel) {
                      return DataRow(
                        cells: [
                          DataCell(Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _updateStatus(cancel['id'], 1);
                                },
                                child: const Text('Confirm'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  _updateStatus(cancel['id'], 5);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Cancel'),
                              ),
                            ],
                          )),
                          DataCell(Text(cancel['status'] ?? 'N/A')),
                          DataCell(Text(cancel['fullname'] ?? 'N/A')),
                          DataCell(Text(cancel['address'] ?? 'N/A')),
                          DataCell(Text(cancel['phone_number']?.toString() ?? 'N/A')),
                          DataCell(Text(cancel['gownName'] ?? 'N/A')),
                          DataCell(Text(cancel['type'] ?? 'N/A')),
                          DataCell(Text(cancel['size'] ?? 'N/A')),
                          DataCell(Text(cancel['color'] ?? 'N/A')),
                          DataCell(Text(cancel['style'] ?? 'N/A')),
                          DataCell(Text(cancel['balance']?.toString() ?? 'N/A')),
                          DataCell(Text(cancel['paymentMethod'] ?? 'N/A')),
                          DataCell(Text(cancel['referenceCode']?.toString() ?? 'N/A')),
                          DataCell(Text(cancel['rentalFee']?.toString() ?? 'N/A')),
                          DataCell(Text(cancel['reservationPrice']?.toString() ?? 'N/A')),
                          DataCell(Text(cancel['fullPayment']?.toString() ?? 'N/A')),
                          DataCell(Text(cancel['qty']?.toString() ?? 'N/A')),
                          DataCell(Text(cancel['totalFee']?.toString() ?? 'N/A')),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _matchesSearchQuery(Map<String, dynamic> cancel) {
    final searchFields = [
      cancel['fullname'],
      cancel['address'],
      cancel['phone_number']?.toString(),
      cancel['gownName'],
      cancel['type'],
      cancel['size'],
      cancel['color'],
      cancel['style'],
      cancel['balance']?.toString(),
      cancel['paymentMethod'],
      cancel['referenceCode']?.toString(),
      cancel['rentalFee']?.toString(),
      cancel['reservationPrice']?.toString(),
      cancel['fullPayment']?.toString(),
      cancel['qty']?.toString(),
      cancel['totalFee']?.toString(),
    ];
    return searchFields.any((field) => field != null && field.toLowerCase().contains(_searchQuery));
  }

  Stream<List<Map<String, dynamic>>> _cancelStream() {
    return Supabase.instance.client
        .from('gown_rental')
        .stream(primaryKey: ['id'])
        .eq('status', 5)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Future<void> _updateStatus(int id, int newStatus) async {
    try {
      await Supabase.instance.client
          .from('gown_rental')
          .update({'status': newStatus})
          .eq('id', id);
      
      if (newStatus >= 1) { 
        final cancelData = await Supabase.instance.client
            .from('gown_rental')
            .select('gownName, qty')
            .eq('id', id)
            .single();

        if (cancelData != null) {
          final gownName = cancelData['gownName'];
          final qtyToDeduct = cancelData['qty'];

          final gownData = await Supabase.instance.client
              .from('gownlist')
              .select('qty')
              .eq('gownName', gownName)
              .single();

          if (gownData != null) {
            final currentQuantity = gownData['qty'];
            final newQuantity = currentQuantity - qtyToDeduct;

            await Supabase.instance.client
                .from('gownlist')
                .update({'qty': newQuantity})
                .eq('gownName', gownName);
          }
        }
      }
    } catch (error) {
      print('Error updating status: $error');
    }
  }
}

//REPORTS---------------------------------------------------------------------------------------------

class _ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<_ReportPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _salesReport = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchSalesReport();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  Future<void> _fetchSalesReport() async {
    try {
      // Query the database
      final response = await Supabase.instance.client
          .from('gown_rental')
          .select();

      if (response == null) {
        throw Exception('Error fetching data: response is null');
      }

      // Process the data
      List<Map<String, dynamic>> salesData = List<Map<String, dynamic>>.from(response);

      // Calculate total sales
      var dailySales = _calculateTotalSales(salesData, 'daily');
      var weeklySales = _calculateTotalSales(salesData, 'weekly');
      var monthlySales = _calculateTotalSales(salesData, 'monthly');
      var yearlySales = _calculateTotalSales(salesData, 'yearly');

      setState(() {
        _salesReport = [
          {'type': 'Daily', 'sales': dailySales},
          {'type': 'Weekly', 'sales': weeklySales},
          {'type': 'Monthly', 'sales': monthlySales},
          {'type': 'Yearly', 'sales': yearlySales},
        ];
      });
    } catch (error) {
      print('Error fetching sales report: $error');
    }
  }

  double _calculateTotalSales(List<Map<String, dynamic>> data, String period) {
    double totalSales = 0;
    DateTime now = DateTime.now();

    for (var record in data) {
      DateTime rentedDate = DateTime.parse(record['dateRented']);
      bool withinPeriod = false;

      if (period == 'daily') {
        withinPeriod = rentedDate.isAfter(now.subtract(Duration(days: 1)));
      } else if (period == 'weekly') {
        withinPeriod = rentedDate.isAfter(now.subtract(Duration(days: 7)));
      } else if (period == 'monthly') {
        withinPeriod = rentedDate.isAfter(DateTime(now.year, now.month).subtract(Duration(days: 30)));
      } else if (period == 'yearly') {
        withinPeriod = rentedDate.isAfter(DateTime(now.year - 1, now.month, now.day));
      }

      if (withinPeriod) {
        totalSales += record['rentalFee'] ?? 0;  // Handle potential null values
      }
    }

    return totalSales;
  }

  void _printReport() {
    // Implement printing functionality here
    print('Printing report...');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sales Report',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.print, color: Colors.blue),
                onPressed: _printReport,
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Report',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          _buildReportTable(),
        ],
      ),
    );
  }

  Widget _buildReportTable() {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Report Type')),
        DataColumn(label: Text('Total Sales')),
      ],
      rows: _salesReport.map((report) {
        return DataRow(
          cells: [
            DataCell(Text(report['type'])),
            DataCell(Text(report['sales'].toString())),
          ],
        );
      }).toList(),
    );
  }
}



//History------------------------------------------------------

class _HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<_HistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _gownRentalData = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchGownRentalData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  Future<void> _fetchGownRentalData() async {
    try {
    // Query the database to fetch all data from the gown_rental table
    final response = await Supabase.instance.client
        .from('gown_rental')
        .select();

    if (response == null) {
      throw Exception('Error fetching data: response is null');
    }

    // Process the data
    List<Map<String, dynamic>> gownRentalData = List<Map<String, dynamic>>.from(response);

    // Sort the data by created_at in descending order
    gownRentalData.sort((a, b) {
      DateTime dateA = DateTime.parse(a['created_at']);
      DateTime dateB = DateTime.parse(b['created_at']);
      return dateB.compareTo(dateA); // Descending order
    });

    setState(() {
      _gownRentalData = gownRentalData;
    });
    } catch (error) {
      print('Error fetching gown rental data: $error');
    }
  }

  void _printReport() {
    // Implement printing functionality here
    print('Printing report...');
  }  

  void _viewRentalDetails(Map<String, dynamic> rental) {
    // Show a dialog with all rental details
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rental Details for ID: ${rental['id']}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Created At: ${rental['created_at']?.toString() ?? ''}'),
                Text('Full Name: ${rental['fullname'] ?? ''}'),
                Text('Address: ${rental['address'] ?? ''}'),
                Text('Phone Number: ${rental['phone_number'] ?? ''}'),
                Text('Gown Name: ${rental['gownName'] ?? ''}'),
                Text('Type: ${rental['type'] ?? ''}'),
                Text('Size: ${rental['size'] ?? ''}'),
                Text('Color: ${rental['color'] ?? ''}'),
                Text('Style: ${rental['style'] ?? ''}'),
                Text('Quantity: ${rental['qty']?.toString() ?? ''}'),
                Text('Rental Fee: ${rental['rentalFee']?.toString() ?? ''}'),
                Text('Reservation Price: ${rental['reservationPrice']?.toString() ?? ''}'),
                Text('Payment Method: ${rental['paymentMethod'] ?? ''}'),
                Text('Reference Code: ${rental['referenceCode']?.toString() ?? ''}'),
                Text('Balance: ${rental['balance']?.toString() ?? ''}'),
                Text('Total Fee: ${rental['totalFee']?.toString() ?? ''}'),
                Text('Date Rented: ${rental['dateRented']?.toString() ?? ''}'),
                Text('Date Return: ${rental['dateReturn']?.toString() ?? ''}'),
                Text('Penalty: ${rental['penalty'] ?? ''}'),
                Text('Status: ${rental['status'] ?? ''}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
String _formatDate(String dateString) {
  DateTime date = DateTime.parse(dateString);
  return '${_monthName(date.month)}/${date.day}/${date.year}';
}

String _monthName(int monthNumber) {
  const months = [
    '01', '02', '03', '04', '05', '06',
    '07', '08', '09', '10', '11', '12'
  ];
  return months[monthNumber - 1];
}

  @override
  Widget build(BuildContext context) {
    // Filter the data to include only those with status '4'
    final filteredData = _gownRentalData.where((rental) => rental['status'] == '4').toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Returned Gown Rental Data',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.print, color: Colors.blue),
                onPressed: _printReport,
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Rental Data',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildDataTable(filteredData),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<Map<String, dynamic>> filteredData) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('View')),
        DataColumn(label: Text('No.')),
         DataColumn(label: Text('Status')),
        DataColumn(label: Text('Full Name')),
 DataColumn(label: Text('Image')), 
        DataColumn(label: Text('Gown Name')),
        DataColumn(label: Text('Quantity')),
        DataColumn(label: Text('Rental Fee')),

        DataColumn(label: Text('Date Return')),
       
      ],
      rows: filteredData.map((rental) {
        return DataRow(
          cells: [
            DataCell(
              IconButton(
                icon: Icon(Icons.visibility),
                onPressed: () => _viewRentalDetails(rental),
              ),
            ),
            DataCell(Text(rental['id'].toString())),
            DataCell(Text(
                rental['status'] == '4' ? 'Returned' : rental['status'] ?? '',
                style: TextStyle(
                  color: Colors.black, // Set the text color to black
                  fontWeight: FontWeight.bold, // Make the text bold
                ),
              ),
            ),

            DataCell(Text(rental['fullname'] ?? '')),
            DataCell(
                          Image.network(
                            rental['imageUrl'] ?? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRgZ-HCdoGUy2nI_WfKwckkDEGi7zB_B4G6o-1WIWRcYGureJhmc2LRyo2PtSmJLaUdHtE&usqp=CAU',
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                        ), // Image cell
            DataCell(Text(rental['gownName'] ?? '')),
            DataCell(Text(rental['qty']?.toString() ?? '')),
            DataCell(Text(rental['rentalFee']?.toString() ?? '')),
            DataCell(Text(rental['dateReturn'] != null
                ? _formatDate(rental['dateReturn'].toString())
                : '')),
             
          ],
        );
      }).toList(),
    );
  }
}
