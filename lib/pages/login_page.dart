// ignore_for_file: unused_field, prefer_final_fields, sized_box_for_whitespace, unnecessary_null_comparison, unnecessary_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gown_rental/homepage.dart';
import 'package:gown_rental/pages/resetpassword/ResetPasswordPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gown_rental/pages/register_page.dart';
import 'package:gown_rental/Admin/dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late double height;
  late double width;

  bool obscurePassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  void passwordVisibleToggle() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }

@override
void dispose() {
  _emailController.dispose();
  _passwordController.dispose();
  super.dispose();
}


Future<void> _signIn() async {
  try {
    final input = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    String? email;

    final isEmail = RegExp(r"^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$").hasMatch(input);

    if (isEmail) {
      email = input; 
    } else {
      final userResponse = await Supabase.instance.client
          .from('users')
          .select('email')
          .eq('username', input)
          .single();

      if (userResponse == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid username! Please try again.')),
        );
        return;
      }

      email = userResponse['email']; 
    }

    final AuthResponse response = await Supabase.instance.client.auth.signInWithPassword(
      email: email!,
      password: password,
    );

    if (response.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credential error! Please try again.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );

      final user = response.user!;
      final userId = user.id;

      final userData = await Supabase.instance.client
          .from('users')
          .select('role')
          .eq('id', userId)
          .single();

      final role = userData['role'];

      if (role == 1 || role == 2) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPage()),
        );
      } else if (role == 3) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unknown role. Please contact support.')),
        );
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid credential! Please try again.')),
    );
  }
}

@override
Widget build(BuildContext context) {
  height = MediaQuery.of(context).size.height;
  width = MediaQuery.of(context).size.width;

  bool isWebOrLaptop = width >= 1024;

  return Scaffold(
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Left Side: Logo and Gerry's Rental Text
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
                      // Right Side: Container with form
                      Expanded(
                        child: Container(
                          width: isWebOrLaptop ? width * 0.4 : width * 0.85,
                          height: 540,
                          margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 141, 202, 238),
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            boxShadow: [
                              BoxShadow(
                                blurStyle: BlurStyle.inner,
                                blurRadius: 5,
                                color: Color.fromARGB(255, 109, 179, 150),
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.015,
                              vertical: height * 0.0100,
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 55),
                                Container(
                                  width: isWebOrLaptop ? width * 0.3 : width * 0.8,
                                  child: TextField(
                                    controller: _emailController,
                                    style: const TextStyle(
                                      fontSize: 16, 
                                    ),
                                    decoration: InputDecoration(
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.grey[800],
                                          size: 35,
                                        ),
                                      ),
                                      labelText: 'Email/Username',
                                      labelStyle: const TextStyle(
                                        fontSize: 14, 
                                        color: Colors.black54,
                                      ),
                                      floatingLabelStyle: const TextStyle(
                                        fontSize: 16, 
                                        color: Colors.black54,
                                      ),
                                      fillColor: Colors.grey[50],
                                      filled: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: height * 0.01,
                                        horizontal: width * 0.015,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 35),
                                Container(
                                  width: isWebOrLaptop ? width * 0.3 : width * 0.8,
                                  child: TextField(
                                    controller: _passwordController,
                                    style: const TextStyle(
                                      fontSize: 16, 
                                    ),
                                    obscureText: obscurePassword,
                                    decoration: InputDecoration(
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: Icon(
                                          Icons.lock,
                                          color: Colors.grey[800],
                                          size: 35,
                                        ),
                                      ),
                                      suffixIcon: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: SizedBox(
                                          width: 50,
                                          height: width * 0.03,
                                          child: Center(
                                            child: IconButton(
                                              onPressed: passwordVisibleToggle,
                                              icon: obscurePassword
                                                  ? Icon(
                                                      Icons.visibility_off,
                                                      color: Colors.grey[800],
                                                      size: width * 0.02,
                                                    )
                                                  : Icon(
                                                      Icons.visibility,
                                                      color: Colors.grey[800],
                                                      size: width * 0.02,
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      labelText: 'Password',
                                      labelStyle: const TextStyle(
                                        fontSize: 14, 
                                        color: Colors.black54,
                                      ),
                                      floatingLabelStyle: const TextStyle(
                                        fontSize: 16, 
                                        color: Colors.black54,
                                      ),
                                      fillColor: Colors.grey[50],
                                      filled: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: height * 0.015,
                                        horizontal: width * 0.015,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 25),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const SizedBox(height: 25),
                                    Padding(
                                      padding: EdgeInsets.only(right: width * 0.035),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const ResetPasswordPage(), 
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Forget Password?',
                                          style: GoogleFonts.poppins(
                                            fontSize: width * 0.010,
                                            color: Colors.black,
                                            //color: const Color.fromARGB(255, 255, 255, 255),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: height * 0.025),
                                Container(
                                  width: isWebOrLaptop ? 380 : 200,
                                  child: ElevatedButton(
                                    onPressed: _signIn,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[800],
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 20,
                                        horizontal: 60,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      textStyle: GoogleFonts.poppins(
                                        fontSize: isWebOrLaptop ? 20 : 16,
                                      ),
                                    ),
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                SizedBox(height: height * 0.03),
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Divider(
                                        color: Color.fromARGB(255, 128, 123, 123),
                                        thickness: 0.25,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: width * 0.025,
                                      ),
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
                                SizedBox(height: height * 0.04),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: width * 0.0115,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const RegisterPage(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Register',
                                        style: GoogleFonts.poppins(
                                          color: Colors.black,
                                          fontSize: width * 0.0125,
                                          fontWeight: FontWeight.bold,
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
                      Text(
                        'Gerry\'s Rental',
                        style: GoogleFonts.greatVibes(
                          fontSize: 70, // Adjust text size for mobile
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          wordSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: width * 0.8,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 141, 202, 238),
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          boxShadow: [
                            BoxShadow(
                              blurStyle: BlurStyle.inner,
                              blurRadius: 10,
                              color: Color.fromARGB(255, 109, 179, 150),
                              offset: Offset(0, 5),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.0750,
                            vertical: height * 0.050,
                          ),
                          child: Column(
                            children: [
                          TextField(
                            controller: _emailController,
                            style: GoogleFonts.poppins(
                              fontSize: width * 0.0375,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Icon(
                                  Icons.email, // Change to your desired icon
                                  color: Colors.grey[800],
                                  size: width * 0.05, // Dynamic icon size based on screen width
                                ),
                              ),
                              labelText: 'Email/Username',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: width * 0.0265,
                                color: Colors.black54,
                              ),
                              floatingLabelStyle: GoogleFonts.poppins(
                                fontSize: width * 0.0265,
                                color: Colors.black54,
                              ),
                              fillColor: Colors.grey[50],
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: height * 0.0425),
                          TextField(
                            controller: _passwordController,
                            style: GoogleFonts.poppins(
                              fontSize: width * 0.0375,
                            ),
                            obscureText: obscurePassword,
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Icon(
                                  Icons.lock, // Change to your desired icon for password
                                  color: Colors.grey[800],
                                  size: width * 0.05, // Dynamic icon size based on screen width
                                ),
                              ),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(5),
                                child: SizedBox(
                                  width: width * 0.1,  // Adjust based on screen width
                                  height: width * 0.1, // Adjust based on screen width
                                  child: Center(
                                    child: IconButton(
                                      onPressed: passwordVisibleToggle,
                                      icon: obscurePassword
                                          ? Icon(
                                              Icons.visibility_off,
                                              color: Colors.grey[800],
                                              size: width * 0.05,  // Dynamic icon size based on screen width
                                            )
                                          : Icon(
                                              Icons.visibility,
                                              color: Colors.grey[800],
                                              size: width * 0.05,  // Dynamic icon size based on screen width
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              labelText: 'Password',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: width * 0.0265,
                                color: Colors.black54,
                              ),
                              floatingLabelStyle: GoogleFonts.poppins(
                                fontSize: width * 0.0265,
                                color: Colors.black54,
                              ),
                              fillColor: Colors.grey[50],
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: height * 0.015),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ResetPasswordPage(), 
                                    ),
                                  );
                                },
                                child: Text(
                                  'Forget Password?',
                                  style: GoogleFonts.poppins(
                                    fontSize: width * 0.0225,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height * 0.025),
                          Container(
                            width: isWebOrLaptop ? 900 : double.infinity,
                            child: ElevatedButton(
                              onPressed: _signIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                                padding: EdgeInsets.symmetric(
                                  vertical: isWebOrLaptop ? 28 : 20, 
                                  horizontal: isWebOrLaptop ? 80 : 50,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                textStyle: GoogleFonts.poppins(
                                  fontSize: isWebOrLaptop ? 35 : 16, 
                                ),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(color: Colors.white), 
                              ),
                            ),
                          ),
                          SizedBox(height: height * 0.02),
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  color: Color.fromARGB(255, 128, 123, 123),
                                  thickness: 0.25,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.025,
                                ),
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
                                "Don't have an account? ",
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: width * 0.0285,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const RegisterPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Register',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: width * 0.0285,
                                    fontWeight: FontWeight.bold,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
