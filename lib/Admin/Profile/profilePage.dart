import 'package:flutter/material.dart';
import 'package:gown_rental/Admin/Profile/EditProfilePage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<Map<String, dynamic>?> _fetchUserDetails() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) return null;

    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('username, email, avatarUrl') // Adjust fields as necessary
          .eq('id', userId)
          .single();

      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error fetching user details.'));
          }

          final user = snapshot.data!;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: user['avatarUrl'] != null 
                        ? NetworkImage(user['avatarUrl']) 
                        : const AssetImage('assets/default_avatar.png') as ImageProvider, // Replace with your default avatar
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user['username'] ?? 'No User Name',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user['email'] ?? 'user@gmail.com',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
  onPressed: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(user: user),
      ),
    );
    if (result == true) {
      // Optionally, refetch user details after edit
     _fetchUserDetails();
    }
                 }, child: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
