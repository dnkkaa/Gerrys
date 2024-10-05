import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
//import 'package:gown_rental/pages/phoneOtp.dart';
import 'package:gown_rental/homepage.dart';
import 'dart:async';

class OTPVerificationPage extends StatefulWidget {
  final String email;

  const OTPVerificationPage({Key? key, required this.email}) : super(key: key);

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  Timer? _timer;
  int _start = 0;
  int _attempts = 0;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    setState(() {
      _canResend = false;
      _start = 0 + (_attempts * 5);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_start == 0) {
          setState(() {
            _canResend = true;
          });
          timer.cancel();
        } else {
          setState(() {
            _start--;
          });
        }
      });
    });
  }

  Future<void> _verifyOTP() async {
    try {
      final otp = _otpController.text;

      final response = await Supabase.instance.client.auth.verifyOTP(
        email: widget.email,
        token: otp,
        type: OtpType.signup,
      );

      if (!mounted) return;

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account successfully verified!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const HomePage(isVerified: true)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP! Please try again.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP! Please try again.')),
        );
      }
    }
  }

  Future<void> _resendOTP() async {
    setState(() {
      _attempts++;
      _canResend = false;
    });

    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: widget.email,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent!')),
      );

      startTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resend OTP: $e')),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Center the text
          children: [
            const SizedBox(height: 30),
            Text(
              'Verify with Email Verification Code',
              textAlign: TextAlign.center, // Center the text
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Enter the OTP sent to ${widget.email}',
              textAlign: TextAlign.center, // Center the text
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 30),
            Text(
              'Please enter the authentication code',
              textAlign: TextAlign.center, // Center the text
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            PinCodeTextField(
              controller: _otpController,
              appContext: context,
              length: 6,
              onChanged: (value) {
                if (value.length == 6) {
                  _verifyOTP();
                }
              },
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(10),
                fieldHeight: 50,
                fieldWidth: 40,
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: "Didn't get the code? ",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black, // Set the color of the non-clickable text
                ),
                children: [
                  TextSpan(
                    text: _canResend
                        ? 'Resend Code'
                        : 'Resend in $_start seconds',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _canResend ? Colors.blue : Colors.grey,
                    ),
                    recognizer: _canResend
                        ? (TapGestureRecognizer()..onTap = _resendOTP)
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
