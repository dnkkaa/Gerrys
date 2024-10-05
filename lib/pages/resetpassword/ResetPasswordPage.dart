// ignore_for_file: unused_field, unnecessary_import

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gown_rental/homepage.dart';
//import 'package:gown_rental/pages/login_page.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailResetController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isOtpSent = false;
  bool _isOtpValidated = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  bool _isLoading = false;

  final SupabaseClient _supabaseClient = Supabase.instance.client;

  @override
  void dispose() {
    // if (mounted){
    // // Dispose controllers
    // _emailResetController.dispose();
    // _otpController.dispose();
    // _newPasswordController.dispose();
    // _confirmPasswordController.dispose();
    // }
    super.dispose();
  }

  // Validate password
  bool _isValidPassword(String password) {
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*[!@#$%^&*(),.?":{}|<>]).{6,}$');
    return regex.hasMatch(password);
  }

  Future<void> _resetPassword() async {
    final email = _emailResetController.text.trim().toLowerCase();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = "Please enter your email.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _supabaseClient
          .from('users')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      if (response == null) {
        setState(() {
          _errorMessage = "Email is not registered. Please try a different email.";
          _isLoading = false;
        });
        return;
      }

      await _supabaseClient.auth.resetPasswordForEmail(email);

      setState(() {
        _errorMessage = null;
        _isOtpSent = true;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    final email = _emailResetController.text.trim().toLowerCase();

    if (otp.isEmpty || email.isEmpty) {
      setState(() {
        _errorMessage = "Please enter your OTP that was sent to $email.";
      });
      return;
    }

    try {
      final response = await _supabaseClient.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.recovery,
      );

      if (response.user != null) {
        setState(() {
          _isOtpValidated = true;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = "Invalid OTP. Please try again.";
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = "Invalid OTP. Please try again.";
        _otpController.clear();
      });
    }
  }

  Future<void> _updatePassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = "Please fill both password fields.";
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = "Passwords do not match.";
      });
      return;
    }

    if (!_isValidPassword(newPassword)) {
      setState(() {
        _errorMessage = "Password must be at least 6 characters long, contain 1 uppercase letter, and 1 special character.";
      });
      return;
    }

    try {
      await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      setState(() {
        _errorMessage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully!')),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage(isVerified: true)),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update password. Please try again.')),
      );
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: const Text('Resetting Password', 
      style: TextStyle(
        fontWeight: FontWeight.w500)
      ),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_errorMessage != null) ...[
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 10),
          ],
          if (!_isOtpSent) ...[
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Enter the user\'s email you want to reset.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailResetController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: Colors.blueAccent,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: Colors.red,
                    width: 2,
                  ),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              maxLines: 1,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text('Back'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _resetPassword,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text('Send OTP'),
                ),
              ],
            ),
          ],
          if (_isOtpSent && !_isOtpValidated) ...[
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Verify with Email Verification Code',
              textAlign: TextAlign.center, 
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: Text(
              'Please enter the authentication code',
              textAlign: TextAlign.center, 
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 20),
          PinCodeTextField(
            appContext: context,
            length: 6,
            obscureText: false,
            animationType: AnimationType.fade,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(5),
              fieldHeight: 50,
              fieldWidth: 40,
              activeFillColor: Colors.white,
            ),
            animationDuration: const Duration(milliseconds: 300),
            controller: _otpController,
            keyboardType: TextInputType.number,
            onCompleted: (v) {},
            onChanged: (value) {},
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _verifyOtp,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Text('Verify'),
            ),
          )
        ],
        if (_isOtpValidated) ...[
          const Text('Create your new password'),
          const SizedBox(height: 12),
          TextField(
            controller: _newPasswordController,
            decoration: InputDecoration(
              labelText: 'New Password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
              ),
              border: const OutlineInputBorder(), 
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0), 
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2.0), 
              ),
            ),
            obscureText: _obscureNewPassword,
          ),
          const SizedBox(height: 20),
          const Text('Re-type your new password'),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              border: const OutlineInputBorder(), 
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0), 
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2.0), 
              ),
            ),
            obscureText: _obscureConfirmPassword,
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight, 
              child: ElevatedButton(
                onPressed: _updatePassword,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text('Update Password'),
              ),
            ),
          ],
        ],
      ),
    ),
  );
 }
}
