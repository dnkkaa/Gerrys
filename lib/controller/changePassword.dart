import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  bool obscureCurrentPassword = true;
  bool obscureNewPassword = true;
  bool obscureConfirmNewPassword = true;

  void toggleCurrentPasswordVisibility() {
    setState(() {
      obscureCurrentPassword = !obscureCurrentPassword;
    });
  }

  void toggleNewPasswordVisibility() {
    setState(() {
      obscureNewPassword = !obscureNewPassword;
    });
  }

  void toggleConfirmNewPasswordVisibility() {
    setState(() {
      obscureConfirmNewPassword = !obscureConfirmNewPassword;
    });
  }

  bool _isPasswordValid(String password) {
    // Check password length
    if (password.length < 6) return false;

    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;

    // Check for at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) return false;

    return true;
  }

  Future<void> _changePassword() async {
    try {
      // Validate new password requirements
      if (_newPasswordController.text != _confirmNewPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New passwords do not match!')),
        );
        return;
      }

      if (!_isPasswordValid(_newPasswordController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New password must be at least 6 characters long, contain at least one uppercase letter, and one special character.')),
        );
        return;
      }

      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user is logged in.')),
        );
        return;
      }

      try {
        // Attempt to re-authenticate the user with the current password
        await supabase.auth.signInWithPassword(
          email: currentUser.email!,
          password: _currentPasswordController.text,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Current password is incorrect.')),
        );
        return;
      }

      // If re-authentication is successful, update the password
      await supabase.auth.updateUser(
        UserAttributes(
          password: _newPasswordController.text,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully.')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

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
              'Change Password',
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
          children: [
            const SizedBox(height: 16),
            _buildPasswordField(
              _currentPasswordController,
              'Current Password',
              obscureCurrentPassword,
              toggleCurrentPasswordVisibility,
            ),
            const SizedBox(height: 25),
            _buildPasswordField(
              _newPasswordController,
              'New Password',
              obscureNewPassword,
              toggleNewPasswordVisibility,
            ),
            const SizedBox(height: 25),
            _buildPasswordField(
              _confirmNewPasswordController,
              'Confirm New Password',
              obscureConfirmNewPassword,
              toggleConfirmNewPasswordVisibility,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: width > 500
                    ? EdgeInsets.symmetric(vertical: 10.0, horizontal: width * 0.010) // Larger padding for web
                    : EdgeInsets.symmetric(vertical: 15.0, horizontal: width * 0.040), // Smaller padding for mobile/tablet
              ),
              child: Text(
                'Change Password',
                style: GoogleFonts.poppins(
                  fontSize: width > 500 ? width * 0.020 : width * 0.030, // Adjust font size based on screen width
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String labelText,
    bool obscureText,
    VoidCallback toggleVisibility,
  ) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: IconButton(
          onPressed: toggleVisibility,
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
          ),
        ),
        border: OutlineInputBorder(  
          borderRadius: BorderRadius.circular(8),  
          borderSide: const BorderSide(
            color: Colors.grey,  
            width: 1.5,          
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.grey,  
            width: 1.5,          
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.blue,  
            width: 2.0,          
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), 
      ),
    );
  }
}
