// ignore_for_file: sized_box_for_whitespace, unnecessary_const, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gown_rental/pages/login_page.dart';
import 'package:gown_rental/pages/otp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


Future<List<Map<String, dynamic>>> fetchAddressSuggestions(String query) async {
  final url = 'https://nominatim.openstreetmap.org/search?format=json&q=$query';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => {
        'display_name': item['display_name'],
        'lat': item['lat'],
        'lon': item['lon']
      }).toList();
    } else {
      throw Exception('Failed to load suggestions');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}


class _RegisterPageState extends State<RegisterPage> {

bool _isFormValid() {
  return _usernameController.text.isNotEmpty &&
      _fullnameController.text.isNotEmpty &&
      _emailController.text.isNotEmpty &&
      _addressController.text.isNotEmpty &&
      _ageController.text.isNotEmpty &&
      _phoneNumberController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _rePasswordController.text.isNotEmpty;
}

@override
void initState() {
  super.initState();

  _usernameController.addListener(_onFormFieldChanged);
  _fullnameController.addListener(_onFormFieldChanged);
  _emailController.addListener(_onFormFieldChanged);
  _addressController.addListener(_onFormFieldChanged);
  _ageController.addListener(_onFormFieldChanged);
  _phoneNumberController.addListener(_onFormFieldChanged);
  _passwordController.addListener(_onFormFieldChanged);
  _rePasswordController.addListener(_onFormFieldChanged);
}

void _onFormFieldChanged() {
  setState(() {}); // Update the button's enabled/disabled state
}


  late double height;
  late double width;

  bool obscurePassword = true;
  bool obscureRePassword = true;
  bool agreedToTerms = false;
  bool canCheckTerms = false;

  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();

  void passwordVisibleToggle() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }

  void rePasswordVisibleToggle() {
    setState(() {
      obscureRePassword = !obscureRePassword;
    });
  }

bool isValidPassword(String password) {
  // Regular expression for password validation
  final passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*[!@#\$&*~])(?=.{6,})');
  return passwordRegExp.hasMatch(password);
}

void _showTermsDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), 
      ),
      title: const Text("Terms and Conditions",
      style: TextStyle(fontWeight: FontWeight.bold)
      ),
      content: const SingleChildScrollView(
        child: Text(
          """
Terms and Conditions

1. Introduction
By using this application, you agree to these terms and conditions in full. If you disagree with these terms and conditions or any part of these terms and conditions, you must not use this application.

2. Privacy Policy
We are committed to safeguarding the privacy of our users. This section explains how we collect, use, and protect your personal data:
   - Information Collection: We collect personal data such as your name, email, and contact details when you register or make transactions on the app.
   - Use of Data: Your personal data is used to provide services, improve user experience, and for necessary communication purposes. We will not share your information with third parties without your consent.
   - Data Security: We take appropriate security measures to protect your personal information from unauthorized access, disclosure, alteration, or destruction.
   - Data Retention: Your data will be stored for as long as necessary to provide the services or as required by law.

3. User Responsibilities
You are responsible for keeping your account secure. Do not share your password or any sensitive information with anyone. You must notify us immediately of any breach of security or unauthorized use of your account.

4. Service Usage
The app is provided 'as is' without any warranties or guarantees. We may modify or discontinue the app at any time without notice.

5. Updates to the Terms
We may update these terms from time to time by posting an updated version in the application. Continued use of the application after changes indicates your agreement to the new terms.

6. Contact Information
For any questions or concerns regarding these terms or your privacy, please contact us at support@example.com.

By proceeding, you acknowledge that you have read and agreed to these Terms and Conditions.
          """,
          textAlign: TextAlign.justify,
          style: TextStyle(fontSize: 14),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              canCheckTerms = true;
            });
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5), 
            ),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            backgroundColor: Colors.blueAccent,
          ),
          child: const Text("Agree", style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5), 
            ),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            backgroundColor: Colors.grey,
          ),
          child: const Text("Cancel", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}


// Regular expression for validating email format
bool isValidEmail(String email) {
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email);
}

Future<void> _signUp() async {
  // Check if user agreed to terms
  if (!agreedToTerms) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You must agree to the terms and conditions.')),
    );
    return;
  }

  // Validate email format
  if (!isValidEmail(_emailController.text)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a valid email address.')),
    );
    return;
  }

  // Password validation
  if (!isValidPassword(_passwordController.text)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password must be at least 6 characters long, contain an uppercase letter, and a special character.')),
    );
    return;
  }

  try {
    // Check if username exists
    final existingUsernameResponse = await Supabase.instance.client
        .from('users')
        .select('id')
        .eq('username', _usernameController.text)
        .maybeSingle(); 

    if (existingUsernameResponse != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username is already taken! Please choose a different username.')),
      );
      return; 
    }

    // Check if email already exists
    final existingUserResponse = await Supabase.instance.client
        .from('users')
        .select('id')
        .eq('email', _emailController.text)
        .maybeSingle(); 

    if (existingUserResponse != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email is already registered! Please use a different email.')),
      );
      return;
    }

    // Check if passwords match
    if (_passwordController.text != _rePasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }

    // Sign up the user with email and password
    final AuthResponse response = await Supabase.instance.client.auth.signUp(
      email: _emailController.text,
      password: _passwordController.text,
    );

    // Handle sign-up result
    if (response.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign-up failed! Please try again.')),
      );
    } else {
      // Save user data to database
      await Supabase.instance.client.from('users').insert({
        'id': response.user!.id,
        'username': _usernameController.text,
        'fullname': _fullnameController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'age': _ageController.text,
        'phone_number': '+63${_phoneNumberController.text}',
        'role': 3,
      });

      // Prompt user to check email for verification
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please check your email for verification.')),
      );

      // Navigate to OTP verification page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationPage(email: _emailController.text),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $e')),
    );
    print('Exception: $e');
  }
}


  void _onAddressChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final suggestions = await fetchAddressSuggestions(query);
      setState(() {
        _suggestions = suggestions;
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

@override
Widget build(BuildContext context) {
  height = MediaQuery.of(context).size.height;
  width = MediaQuery.of(context).size.width;

  bool isWebOrLaptop = width >= 1024;

  return Scaffold(
    resizeToAvoidBottomInset: true,
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 36, 137, 226), Colors.white],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: isWebOrLaptop
                ? Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                     Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/logo.png',
                              width: 150.0,
                              height: 150.0,
                            ),
                      const SizedBox(height: 10),
                      // Gerry\'s Rental Text on the left
                      const SizedBox(height: 10),
                            Text(
                              'Gerry\'s Rental',
                              style: GoogleFonts.greatVibes(
                                fontSize: 80,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                wordSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Form container on the right
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: width * 0.45, // Adjust width for web or laptop
                          height: 550, // Adjust height if necessary
                          margin: EdgeInsets.only(right: width * 0.05),
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 141, 202, 238),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurStyle: BlurStyle.inner,
                                blurRadius: 10,
                                color: Color.fromARGB(255, 164, 179, 172),
                                offset: Offset(0, 5),
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(width * 0.05),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  SizedBox(height: height * 0.015),
                                  _buildTextField(
                                    _usernameController,
                                    'Username',
                                    prefixIcon: const Icon(Icons.favorite_outline_outlined),
                                  ),
                                  SizedBox(height: height * 0.015),
                                  _buildTextField(
                                    _fullnameController,
                                    'Full Name',
                                    prefixIcon: const Icon(Icons.person),
                                  ),
                                  SizedBox(height: height * 0.015),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: _buildTextField(
                                          _emailController,
                                          'Email',
                                          prefixIcon: const Icon(Icons.email),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.info_outline, color: Colors.black54),
                                        onPressed: _showInfoDialog,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: height * 0.015),
                                  _buildAddressField(),
                                  SizedBox(height: height * 0.015),
                                  _buildTextField(
                                    _ageController,
                                    'Age',
                                    prefixIcon: const Icon(Icons.cake),
                                  ),
                                  SizedBox(height: height * 0.015),
                                  _buildPhoneNumberField(),
                                  SizedBox(height: height * 0.020),
                                  _buildPasswordField(
                                    _passwordController,
                                    'Password',
                                    obscurePassword,
                                    passwordVisibleToggle,
                                    prefixIcon: const Icon(Icons.lock),
                                  ),
                                  SizedBox(height: height * 0.015),
                                  _buildPasswordField(
                                    _rePasswordController,
                                    'Re-enter Password',
                                    obscureRePassword,
                                    rePasswordVisibleToggle,
                                    prefixIcon: const Icon(Icons.lock),
                                  ),
                                  SizedBox(height: height * 0.025),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: agreedToTerms,
                                        onChanged: canCheckTerms
                                            ? (bool? value) {
                                                setState(() {
                                                  agreedToTerms = value ?? false;
                                                });
                                              }
                                            : null,
                                      ),
                                      const Text("I agree to the "),
                                      GestureDetector(
                                        onTap: _showTermsDialog, // Show the terms dialog
                                        child: const Text(
                                          "Terms and Conditions",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: height * 0.02),
                                  ElevatedButton(
                                    onPressed: _isFormValid() && agreedToTerms ? _signUp : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isFormValid()
                                          ? Colors.grey[800]
                                          : Colors.grey, // Change color when disabled
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                        horizontal: 40,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      textStyle: GoogleFonts.poppins(
                                        fontSize: 15,
                                      ),
                                    ),
                                    child: const Text(
                                      'Register Account',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(height: height * 0.02),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: Colors.grey[600],
                                          thickness: 0.25,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: width * 0.025),
                                        child: Text(
                                          'OR',
                                          style: GoogleFonts.poppins(
                                            fontSize: width * 0.010,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: Colors.grey[800],
                                          thickness: 0.25,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: height * 0.02),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Already have an account? ",
                                        style: GoogleFonts.poppins(
                                          color: const Color.fromARGB(255, 0, 0, 0),
                                          fontSize: width * 0.0125,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (BuildContext context) {
                                              return const LoginPage();
                                            }),
                                          );
                                        },
                                        child: Text(
                                          ' Login here!',
                                          style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: width * 0.0125,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logo.png', // Replace with your image path
                        width: 100.0, // Adjust logo size for mobile
                        height: 100.0,
                      ),
                      const SizedBox(height: 10),
                      // Gerry\'s Rental Text centered for mobile
                      Text(
                        'Gerry\'s Rental',
                        style: GoogleFonts.greatVibes(
                          fontSize: 70, // Smaller text size for mobile
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          wordSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Form container centered for mobile
                      Container(
                        width: width * 0.9,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 141, 202, 238),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurStyle: BlurStyle.inner,
                              blurRadius: 10,
                              color: Color.fromARGB(255, 164, 179, 172),
                              offset: Offset(0, 5),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(width * 0.05),
                            child: Column(
                                children: [
                                  SizedBox(height: height * 0.015),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: _buildTextField(
                                          _usernameController, 
                                          'Username', 
                                          prefixIcon: const Icon(Icons.favorite_outline_outlined),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: height * 0.015),
                                  _buildTextField(
                                    _fullnameController, 
                                    'Full Name', 
                                    prefixIcon: const Icon(Icons.person),
                                  ),
                                  SizedBox(height: height * 0.015),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: _buildTextField(
                                          _emailController, 
                                          'Email', 
                                          prefixIcon: const Icon(Icons.email),
                                        ),
                                      ),
                                  IconButton(
                                        icon: const Icon(Icons.info_outline, color: Colors.black54),
                                        onPressed: _showInfoDialog, // This function shows the dialog
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: height * 0.015),
                                  _buildAddressField(),
                                  SizedBox(height: height * 0.015),
                                  _buildTextField(
                                    _ageController, 
                                    'Age', 
                                    prefixIcon: const Icon(Icons.cake),
                                  ),
                                  SizedBox(height: height * 0.015),
                                  _buildPhoneNumberField(), 
                                  SizedBox(height: height * 0.020),
                                  _buildPasswordField(
                                    _passwordController, 
                                    'Password', 
                                    obscurePassword, 
                                    passwordVisibleToggle, 
                                    prefixIcon: const Icon(Icons.lock),
                                  ),
                                  SizedBox(height: height * 0.015),
                                  _buildPasswordField(
                                    _rePasswordController, 
                                    'Re-enter Password', 
                                    obscureRePassword, 
                                    rePasswordVisibleToggle, 
                                    prefixIcon: const Icon(Icons.lock),
                                  ),

                                  SizedBox(height: height * 0.025),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: agreedToTerms,
                                        onChanged: canCheckTerms
                                            ? (bool? value) {
                                                setState(() {
                                                  agreedToTerms = value ?? false;
                                                });
                                              }
                                            : null, 
                                      ),
                                      const Text("I agree to the "),
                                      GestureDetector(
                                        onTap: _showTermsDialog, 
                                        child: const Text(
                                          "Terms and Conditions",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                      width: isWebOrLaptop ? 1300 : double.infinity, 
                                      child: ElevatedButton(
                                        onPressed: _isFormValid() && agreedToTerms ? _signUp : null,
                                        //onPressed: _isFormValid() ? _signUp : null, // Disable the button if form is not valid
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _isFormValid() ? Colors.grey[800] : Colors.grey, 
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 18,
                                            horizontal: 40,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          textStyle: GoogleFonts.poppins(
                                            fontSize: 15,
                                          ),
                                        ),
                                        child: const Text(
                                          'Register Account',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: height * 0.02),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Divider(
                                            color: Colors.grey[600],
                                            thickness: 0.25,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: width * 0.025),
                                          child: Text(
                                            'OR',
                                            style: GoogleFonts.poppins(
                                              fontSize: width * 0.025,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Divider(
                                            color: Colors.grey[800],
                                            thickness: 0.25,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: height * 0.02),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Already have an account! ",
                                          style: GoogleFonts.poppins(
                                            color: const Color.fromARGB(255, 0, 0, 0),
                                            fontSize: width * 0.0285,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(builder: (BuildContext context) {
                                                return const LoginPage();
                                              }),
                                            );
                                          },
                                          child: Text(
                                            ' Login here!',
                                            style: GoogleFonts.poppins(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: width * 0.0285,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                              ),
                           ),
                        ),
                      ],
                   )
               ),
            ),
         ),
       ),
    );
  }

void _showInfoDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: const Text("Email Information",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text(
        "Please double-check your email for confirmation before clicking the Register Account button.\n\n"
        "If you accidentally click the back button right after without confirming, it will be saved automatically in our database and cannot be used again until the admin deletes it.",
        style: TextStyle(fontSize: 14),
        textAlign: TextAlign.justify,
      ),
      actions: [
        Container(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5), 
              ),
              padding: const EdgeInsets.symmetric(vertical: 15), 
              backgroundColor: Colors.blueAccent,
            ),
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildTextField(TextEditingController controller, String labelText, {Icon? prefixIcon}) {
  double heightFactor = MediaQuery.of(context).size.width >= 1024 ? 1.2 : 1.0; // Adjust height for web/laptop
                                                            //mobile  //web
  double fontSize = MediaQuery.of(context).size.width < 600 ? 12.0 : 14.0;

  return Container(
    height: 50 * heightFactor, 
    child: TextField(
      controller: controller,
      style: GoogleFonts.poppins(
        fontSize: fontSize,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: fontSize, 
          color: Colors.black54,
        ),
        floatingLabelStyle: GoogleFonts.poppins(
          fontSize: fontSize, 
          color: Colors.black54,
        ),
        fillColor: Colors.grey[50],
        filled: true,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.blueAccent,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.blueAccent,
          ),
        ),
      ),
    ),
  );
}


Widget _buildPasswordField(
  TextEditingController controller,
  String labelText,
  bool obscureText,
  VoidCallback toggleVisibility,
  {Icon? prefixIcon}
) {
  double heightFactor = MediaQuery.of(context).size.width >= 1024 ? 1.2 : 1.0; 
  double fontSize = MediaQuery.of(context).size.width < 600 ? 12.0 : 14.0; 
  double iconSize;

  if (MediaQuery.of(context).size.width < 600) {
    iconSize = 24.0; 
  } else {
    iconSize = MediaQuery.of(context).size.width * 0.02; 
  }

  return Container(
    height: 50 * heightFactor, 
    child: TextField(
      controller: controller,
      obscureText: obscureText,
      style: GoogleFonts.poppins(
        fontSize: fontSize,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon != null ? IconTheme(
          data: IconThemeData(size: iconSize),
          child: prefixIcon,
        ) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: fontSize,
          color: Colors.black54,
        ),
        floatingLabelStyle: GoogleFonts.poppins(
          fontSize: fontSize, 
          color: Colors.black54,
        ),
        fillColor: Colors.grey[50],
        filled: true,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.blueAccent,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.blueAccent,
          ),
        ),
        suffixIcon: IconButton(
          onPressed: toggleVisibility,
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey[800],
          ),
        ),
      ),
    ),
  );
}

Widget _buildPhoneNumberField() {
  double heightFactor = MediaQuery.of(context).size.width >= 1024 ? 1.2 : 1.0; 
  double fontSize = MediaQuery.of(context).size.width < 600 ? 12.0 : 14.0;

  return Container(
    height: 50 * heightFactor, 
    child: TextField(
      controller: _phoneNumberController,
      keyboardType: TextInputType.phone,
      maxLength: 10, 
      style: GoogleFonts.poppins(
        fontSize: fontSize, 
      ),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            '+63',
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              color: const Color.fromARGB(255, 106, 106, 106),
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        hintText: '9xxxxxxxxx', 
        counterText: '', 
        labelText: 'Phone Number',
        labelStyle: GoogleFonts.poppins(
          fontSize: fontSize, 
          color: Colors.black54,
        ),
        floatingLabelStyle: GoogleFonts.poppins(
          fontSize: fontSize, 
          color: Colors.black54,
        ),
        fillColor: Colors.grey[50],
        filled: true,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.blueAccent,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.blueAccent,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      ),
    ),
  );
}

bool _validatePhoneNumber(String phoneNumber) {
  final String fullPhoneNumber = '+63' + phoneNumber;
  final RegExp regex = RegExp(r'^\+639\d{9}$');
  return regex.hasMatch(fullPhoneNumber);
}


  Widget _buildAddressField() {
  double heightFactor = MediaQuery.of(context).size.width >= 1024 ? 1.2 : 1.0; 
  double mobileHeight = MediaQuery.of(context).size.width < 600 ? 60.0 : 50.0; 
  double fontSize = MediaQuery.of(context).size.width < 600 ? 12.0 : 14.0; 

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        height: mobileHeight * heightFactor, 
        child: TextField(
          controller: _addressController,
          onChanged: _onAddressChanged,
          style: GoogleFonts.poppins(
            fontSize: fontSize, 
          ),
          decoration: InputDecoration(
            labelText: 'Address',
            labelStyle: GoogleFonts.poppins(
              fontSize: fontSize,
              color: Colors.black54,
            ),
            floatingLabelStyle: GoogleFonts.poppins(
              fontSize: fontSize, 
              color: Colors.black54,
            ),
            prefixIcon: const Icon(
              Icons.location_city, // Add a location icon
              color: Colors.black54, // Set the color of the icon
            ),
            fillColor: Colors.grey[50],
            filled: true,
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.blueAccent,
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.blueAccent,
              ),
            ),
          ),
        ),
      ),
      if (_isLoading) const Center(child: CircularProgressIndicator()),
      if (_suggestions.isNotEmpty) ...[
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: Column(
            children: _suggestions.map((suggestion) {
              return ListTile(
                title: Text(suggestion['display_name']),
                onTap: () {
                  setState(() {
                    _addressController.text = suggestion['display_name'];
                    _suggestions = [];
                  });
                },
              );
            }).toList(),
          ),
        ),
      ],
    ],
  );
}
}
