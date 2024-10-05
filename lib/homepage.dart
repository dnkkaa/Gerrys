// ignore_for_file: library_private_types_in_public_api, unused_local_variable, unused_import
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gown_rental/card/notification_details_page.dart';
import 'package:gown_rental/controller/aboutPage.dart';
import 'package:gown_rental/controller/faq.dart';
import 'package:gown_rental/controller/location.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gown_rental/pages/login_page.dart';
import 'package:gown_rental/controller/gown_list.dart';
import 'package:gown_rental/controller/manage_users.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:gown_rental/card/gown_detail_page.dart';
import 'package:gown_rental/pages/AddToCartPage.dart'; 
import 'package:gown_rental/controller/changePassword.dart';
import 'package:gown_rental/pages/search.dart';
import 'package:gown_rental/controller/transactions.dart';
//import 'package:gown_rental/card/notification_details_page.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:timezone/standalone.dart' as tz;
import 'theme_provider.dart'; 
import 'dart:io' show Platform;
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomePage extends StatefulWidget {
  final bool isVerified;

  const HomePage({Key? key, this.isVerified = false}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  User? _user;
  int _notificationCount = 0;
  bool isDarkMode = false;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeTab(),
    NotificationsTab(),
  ];

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    _fetchNotificationCount().listen((count) {
      if (mounted) {
        setState(() {
          _notificationCount = count;
        });
      }
    });
  }

  Future<void> _getUserInfo() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }

void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AddToCartPage()),
      );
    } else {
      if (mounted) {
        setState(() {
          if (index == 1) {
            _notificationCount = 0;
          }
          _selectedIndex = index;
        });
      }
    }
  }

Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  void _toggleTheme(bool value) {
    if (mounted) {
      setState(() {
        isDarkMode = value;
      });
    }
  }

Stream<int> _fetchNotificationCount() {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      return Stream.value(0);
    }

    return Supabase.instance.client
        .from('gown_rental')
        .stream(primaryKey: ['id']) 
        .eq('user_id', userId)
        .map((data) {
          final filteredData = data.where((item) {
            return item['status'] != 0;
          }).toList();
          return filteredData.length; 
        });
  }
//temporary:
// Stream<int> _fetchNotificationCount() {
//     final userId = Supabase.instance.client.auth.currentUser?.id;

//     if (userId == null) {
//       return Stream.value(0);
//     }

//     return Supabase.instance.client
//         .from('gown_rental')
//         .select('id')
//         .eq('user_id', userId)
//         .neq('status', 6)
//         .asStream()
//         .map((data) {
//           final filteredData = data.where((item) {
//             return item['status'] != 0;
//           }).toList();
//           return filteredData.length; 
//         });
//   }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(30.0),
          ),
          child: AppBar(
            title: Text(
              'Gerry\'s Rental',
              style: GoogleFonts.cormorantGaramond( 
                textStyle: Theme.of(context).textTheme.headline6?.copyWith(
                      color: Colors.black,
                      fontSize: 40, //50
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            automaticallyImplyLeading: !widget.isVerified,
            centerTitle: true,
            backgroundColor: Colors.blue[300],
            // backgroundColor: const Color.fromARGB(255, 36, 137, 226),
            elevation: 4.0,
          ),
        ),
      ),
      body: _selectedIndex == 3
          ? ProfileTab(
              user: _user,
              onLogout: _logout,
              isDarkMode: isDarkMode,
              onToggleTheme: _toggleTheme,
            )
          : _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: <Widget>[
                  const Icon(Icons.notifications),
                  if (_notificationCount > 0) // Only show dot if count > 0
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Notifications',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color.fromARGB(255, 1, 177, 133),
          unselectedItemColor: Colors.grey[600],
          onTap: _onItemTapped,
        ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchBarOpen = false;
  

  Stream<List<Map<String, dynamic>>> _fetchGownList() {
    return Supabase.instance.client
        .from('gownlist')
        .select('')
        .filter('qty', 'gt', 0)
        .filter('popular', 'gt', 0)
        .asStream()
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SearchResultsPage(query: query),
        ),
      );
      _searchController.clear();
      setState(() {
        _isSearchBarOpen = false; // Close the search bar after search
      });
    }
  }

  void _toggleSearchBar() {
    setState(() {
      _isSearchBarOpen = !_isSearchBarOpen; // Step 2: Toggle method
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _fetchGownList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading data'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No gowns available'));
        }

      final gowns = snapshot.data!;

      return ListView(
      padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        Row(
            mainAxisSize: MainAxisSize.min,                     //center
            mainAxisAlignment: _isSearchBarOpen ? MainAxisAlignment.end : MainAxisAlignment.end,
            children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _isSearchBarOpen ? 250 : 0, 
                    height: 50,
                    child: _isSearchBarOpen
                        ? TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search gowns....',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.search_outlined),
                                onPressed: _onSearch,
                              ),
                            ),        
                          )
                        : null,
                  ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(
                  _isSearchBarOpen ? Icons.close : Icons.search_rounded,
                  size: _isSearchBarOpen ? 26 : 30, 
                ),
                  onPressed: _toggleSearchBar,
                  tooltip: 'Search',
                ),
              ],
            ),
            const SizedBox(height: 30), 
            CarouselSlider(
              options: CarouselOptions(
                height: MediaQuery.of(context).size.width > 800 
                ? screenHeight * 0.6  // Larger height for web or laptop
                : screenHeight * 0.4, // Default height for smaller screens like mobile
                autoPlay: true,
                enlargeCenterPage: true,
                enableInfiniteScroll: true,
              ),
              items: gowns.map((gown) {
                final imageUrl = gown['imageUrl'] as String? ?? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRgZ-HCdoGUy2nI_WfKwckkDEGi7zB_B4G6o-1WIWRcYGureJhmc2LRyo2PtSmJLaUdHtE&usqp=CAU';
                final gownName = gown['gownName'] as String? ?? 'No Name';
                final gownType = gown['type'] as String? ?? 'Unknown Type';
                final gownSize = gown['size'] as String? ?? 'Unknown Size';
                final gownReservationPrice = (gown['reservationPrice'] as int?)?.toString() ?? 'Unknown Reservation Price';
                final gownQty = (gown['qty'] as int?)?.toString() ?? 'Unknown Qty';
                final gownLowRentalRate = (gown['lowrentalRate'] as int?)?.toString() ?? 'Unknown Low Rental Rate';
                final gownHighRentalRate = (gown['highrentalRate'] as int?)?.toString() ?? 'Unknown High Rental Rate';
                final gownColor = gown['color'] as String? ?? 'Unknown Color';
                final gownStyle = gown['style'] as String? ?? 'Unknown Style';
                final gownDescription = gown['description'] as String? ?? 'No description';
                final gownID = gown['gownID'] as int? ?? 0;
                final rentalFee = gown['rentalFee'] as int? ?? 0;

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => GownDetailPage(
                          imageUrl: imageUrl,
                          gownName: gownName,
                          gownType: gownType,
                          gownSize: gownSize,
                          gownReservationPrice: gownReservationPrice,
                          gownQty: gownQty,
                          gownLowRentalRate: int.parse(gownLowRentalRate),
                          gownHighRentalRate: int.parse(gownHighRentalRate),
                          gownColor: gownColor,
                          gownStyle: gownStyle,
                          gownDescription: gownDescription,
                          gownID: gownID,
                          rentalFee: rentalFee,
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: screenWidth,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error, size: 50);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 46),
            GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const GownList(),
                ),
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('See All'),
                SizedBox(width: 5), 
                Icon(Icons.arrow_forward_ios),
              ],
            ),
          ),
            const SizedBox(height: 26),
            const Text(
              'Popular Gowns',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: screenWidth < 600 ? 2 : 4,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: screenWidth < 600 ? 0.75 : 0.6,
              ),
              // itemCount: gowns.where((gown) => gown['popular'] != null && gown['popular'] > 2).length,
              // itemBuilder: (context, index) {
              //   // Filter the gowns based on the 'popular' column value
              //   final popularGowns = gowns.where((gown) => gown['popular'] != null && gown['popular'] > 2).toList();
              itemCount: gowns.length,
              itemBuilder: (context, index) {
                final gown = gowns[index];
                final imageUrl = gown['imageUrl'] as String? ?? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRgZ-HCdoGUy2nI_WfKwckkDEGi7zB_B4G6o-1WIWRcYGureJhmc2LRyo2PtSmJLaUdHtE&usqp=CAU';
                final gownName = gown['gownName'] as String? ?? 'No Name';
                final gownType = gown['type'] as String? ?? 'Unknown Type';
                final gownSize = gown['size'] as String? ?? 'Unknown Size';
                final gownReservationPrice = (gown['reservationPrice'] as int?)?.toString() ?? 'Unknown Reservation Price';
                final gownQty = (gown['qty'] as int?)?.toString() ?? 'Unknown Qty';
                final gownLowRentalRate = (gown['lowrentalRate'] as int?)?.toString() ?? 'Unknown Low Rental Rate';
                final gownHighRentalRate = (gown['highrentalRate'] as int?)?.toString() ?? 'Unknown High Rental Rate';
                final gownColor = gown['color'] as String? ?? 'Unknown Color';
                final gownStyle = gown['style'] as String? ?? 'Unknown Style';
                final gownDescription = gown['description'] as String? ?? 'No Description';
                final gownID = gown['gownID'] as int? ?? 0;
                final rentalFee = gown['rentalFee'] as int? ?? 0;

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => GownDetailPage(
                          imageUrl: imageUrl,
                          gownName: gownName,
                          gownType: gownType,
                          gownSize: gownSize,
                          gownReservationPrice: gownReservationPrice,
                          gownQty: gownQty,
                          gownLowRentalRate: int.parse(gownLowRentalRate),
                          gownHighRentalRate: int.parse(gownHighRentalRate),
                          gownColor: gownColor,
                          gownStyle: gownStyle,
                          gownDescription: gownDescription,
                          gownID: gownID,
                          rentalFee: rentalFee,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.error, size: 50);
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gownName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('$gownType - $gownSize'),
                              Text('₱${NumberFormat('#,##0.00').format(double.parse(gown['lowrentalRate'].toString()))} - ₱${NumberFormat('#,##0.00').format(double.parse(gown['highrentalRate'].toString()))}',
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
                );
              },
            ),
          ],
        );
      },
    );
  }
}


class NotificationsProvider extends ChangeNotifier {
  final Set<int> _clickedNotificationIds = {};
  final Map<int, int> _notificationStatuses = {}; // Track status changes

  Set<int> get clickedNotificationIds => _clickedNotificationIds;

Future<void> markAsClicked(int notificationId, int status) async {
  _clickedNotificationIds.add(notificationId);
  _notificationStatuses[notificationId] = status;

  final currentDate = DateTime.now();
  final formattedDate = DateFormat('hh:mm a').format(currentDate);

  final response = await Supabase.instance.client
      .from('gown_rental')
      .update({
        'status': status.toString(),
        'created_at': currentDate.toUtc().toIso8601String(),
      })
      .eq('id', notificationId);

  if (response == null) {
    print('Null response received from Supabase');
  
  } else if (response.error != null) {
    print('Error updating status: ${response.error?.message ?? 'Unknown error'}');
  
  } else {
    print('Status updated successfully');
  }

  notifyListeners();
}

  bool isClicked(int notificationId) {
    return _clickedNotificationIds.contains(notificationId);
  }

  int? getStatus(int notificationId) {
    return _notificationStatuses[notificationId];
  }
}


class NotificationsTab extends StatefulWidget {
  const NotificationsTab({Key? key}) : super(key: key);

  @override
  _NotificationsTabState createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  late NotificationsProvider _notificationsProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notificationsProvider = Provider.of<NotificationsProvider>(context);
  }

  String _formatDate(String createdAt) {
    try {
      final DateTime parsedDate = DateTime.parse(createdAt).toUtc();
      final localDate = parsedDate.add(const Duration(hours: 8)); // Adjust to local timezone

      final dateFormatter = DateFormat('MMM d, yyyy'); 
      final timeFormatter = DateFormat('hh:mm a');
      
      final formattedDate = dateFormatter.format(localDate);
      final formattedTime = timeFormatter.format(localDate);

      return '$formattedTime  $formattedDate';
    } catch (e) {
      print('Error parsing date: $e'); 
      return createdAt; 
    }
  }

  Stream<List<Map<String, dynamic>>> _fetchNotifications() {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      print('User is not authenticated');
      return Stream.value([]);
    }
    // return Supabase.instance.client
    //     .from('gown_rental')
    //     .select('status, gownName, id, created_at, gownlist(imageUrl)')
    //     .neq('status', 6)
    //     .eq('user_id', userId)
    //     .order('created_at', ascending: false)
    //     .asStream()
    //     .map((data) => List<Map<String, dynamic>>.from(data));
    return Supabase.instance.client
        .from('gown_rental')
        .select('status, gownName, id, created_at, gownlist!gown_rental_gownID_fkey(imageUrl)')
        .neq('status', 6)
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .asStream()
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

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

  Color _getStatusTextColor(int id, int status) {
    final lastStatus = _notificationsProvider.getStatus(id);
    if (lastStatus != null && lastStatus != status) {
      return Colors.green; // Green if the status has changed
    }
    return _notificationsProvider.isClicked(id)
        ? Colors.grey // Grey for clicked notifications
        : Colors.green; // Green for unread notifications
  }


  Color _getDotColor(int notificationId, int status) {
    final lastStatus = _notificationsProvider.getStatus(notificationId);
    if (lastStatus != null && lastStatus != status) {
      return Colors.green; // Green if the status has changed
    }
    return _notificationsProvider.isClicked(notificationId)
        ? Colors.grey // Grey for clicked notifications
        : Colors.green; // Green for unread notifications
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _fetchNotifications(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('Error details: ${snapshot.error}');
          return const Center(child: Text('Error loading notifications'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No notifications'));
        }

        final notifications = snapshot.data!;

        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            final id = notification['id'] as int;
            final status = int.parse(notification['status'] as String);

            final gownName = notification['gownName'] as String;
            final createdAt = notification['created_at'] as String;
            final imageUrl = notification['gownlist']?['imageUrl'] as String? ?? '';

            return ListTile(
              leading: imageUrl.isNotEmpty
                  ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                  : const Icon(Icons.image, size: 50, color: Colors.grey),
              title: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Gown ',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: gownName,  
                      style: TextStyle(
                        color: isDarkMode ? Colors.orange : Colors.black,
                        fontWeight: FontWeight.bold, 
                        fontStyle: FontStyle.italic,  
                      ),
                    ),
                    // TextSpan(
                    //   text: ' has been',
                    //   style: TextStyle(
                    //     color: isDarkMode ? Colors.white : Colors.black,
                    //   ),
                    // ),
                  ],
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: _getStatusText(status),
                          style: TextStyle(
                            color: _getStatusTextColor(id, status),  // Use the color logic here
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _formatDate(createdAt), 
                      style: TextStyle(
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                        fontSize: 9.0,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: Icon(
                Icons.notification_important, 
                color: _getDotColor(id, status),
              ),
              // onTap: () {
              //   _notificationsProvider.markAsClicked(id, status);
              //   Navigator.of(context).push(
              //     MaterialPageRoute(
              //       builder: (context) => NotificationDetailsPage(
              //         notification: notification,
              //         status: status,
              //         notificationId: id,
              //       ),
              //     ),
              //   );
              // },
              onTap: () {
                _notificationsProvider.markAsClicked(id, status);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TransactionPage(
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class ProfileTab extends StatefulWidget {
  final User? user;
  final VoidCallback onLogout;
  final bool isDarkMode;
  final ValueChanged<bool> onToggleTheme;

  const ProfileTab({
    super.key,
    this.user,
    required this.onLogout,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late Stream<List<Map<String, dynamic>>> _userStream;

  @override
  void initState() {
    super.initState();
    _userStream = Supabase.instance.client
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', widget.user!.id)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

@override
Widget build(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  bool isDarkMode = themeProvider.isDarkMode;

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: SingleChildScrollView(  // Wrap the entire content in SingleChildScrollView
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _userStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[200],
                      child: const CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(Icons.error),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(Icons.person, size: 40),
                    );
                  } else {
                    final user = snapshot.data![0];
                    final avatarUrl = user['avatarUrl'] as String?;

                    return CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: avatarUrl != null
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl == null
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    );
                  }
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _userStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Loading user info...');
                    } else if (snapshot.hasError) {
                      return const Text('Error loading user info');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No user info found');
                    } else {
                      final user = snapshot.data![0];
                      final username = user['username'] as String?;
                      final fullname = user['fullname'] as String?;
                      final phone = user['phone_number'] as String?;
                      final address = user['address'] as String?;
                      final age = user['age'] as String?;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${username ?? 'N/A'} (${fullname ?? 'No Name'})',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.user!.email ?? 'N/A',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${address ?? 'N/A'}',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${phone ?? 'N/A'} (${age ?? 'No Age'} yrs.)',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Dark Mode', style: TextStyle(fontSize: 18)),
              Switch(
                value: isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 5,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Profile'),
                  onTap: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ManageUsersPage(user: widget.user),
                      ),
                    );

                    if (result == true) {
                      setState(() {
                        _userStream = Supabase.instance.client
                            .from('users')
                            .stream(primaryKey: ['id'])
                            .eq('id', widget.user!.id)
                            .map((data) => List<Map<String, dynamic>>.from(data));
                      });
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.shopping_cart_checkout_outlined),
                  title: const Text('Transaction'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransactionPage(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Change Password'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordPage(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.messenger_outlined),
                  title: const Text('FAQ'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FAQPage(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('About'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutPage(),
                      ),
                    );
                  },
                ),
                // const Divider(),
                // ListTile(
                //   leading: const Icon(Icons.info),
                //   title: const Text('Location'),
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => const LocationPage(),
                //       ),
                //     );
                //   },
                // ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              onPressed: widget.onLogout,
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Set the corner radius to 0 for a rectangle
                ),
              ),
            ),
          )
        ],
      ),
    ),
  );
 }
}
