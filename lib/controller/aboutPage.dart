import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: PreferredSize(
      //   preferredSize: const Size.fromHeight(40.0),
      //   child: ClipRRect(
      //     borderRadius: const BorderRadius.vertical(
      //       bottom: Radius.circular(30.0),
      //     ),
      //     child: AppBar(
      //       leading: IconButton(
      //         icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black),
      //         onPressed: () {
      //           Navigator.pop(context);
      //         },
      //       ),
      //       title: Text(
      //         'About Us',
      //         style: GoogleFonts.poppins(
      //           textStyle: Theme.of(context).textTheme.headline6?.copyWith(
      //             color: Colors.black,
      //             fontWeight: FontWeight.bold,
      //           ),
      //         ),
      //       ),
      //       centerTitle: true,
      //       backgroundColor: Colors.blue[300],
      //       elevation: 4.0,
      //     ),
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Our Project',
                style: GoogleFonts.dancingScript(fontSize: 30, fontWeight: FontWeight.bold),
               // textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'We are a leading business in the fashion industry, dedicated to providing our customers with the highest quality gowns and exceptional service. Our mission is to make every occasion special with our exquisite designs and personalized approach.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.justify, // Justified text
              ),
              const SizedBox(height: 16),
              Text(
                'Our Vision',
                style: GoogleFonts.dancingScript(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'To be the top choice for gowns and fashion in this area, known for our creativity, quality, and customer satisfaction.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.justify, // Justified text
              ),
              const SizedBox(height: 16),
              Text(
                'Contact Us',
                style: GoogleFonts.dancingScript(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'gownrental3@gmail.com\nor \n +63 907 057 8697',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center, // Justified text
              ),
              const SizedBox(height: 20),
              Text(
                'Developers',
                style: GoogleFonts.dancingScript(fontSize: 30, fontWeight: FontWeight.bold),
               // textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Danica's contact with local asset image
              Row(
                children: [
                  // Image container
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle, // Circular image
                      image: DecorationImage(
                        image: AssetImage('assets/danica.jpg'), // Use local asset
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Danica C. Alambag\n+63 963 530 8735\ndanica.alambag@evsu.edu.ph',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.justify, // Justified text
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Mary's contact with local asset image
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/divine.png'), // Use local asset
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Mary Divine C. Cerilo\n+63 963 530 8735\nmarydivine.cerilo@evsu.edu.ph',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.justify, // Justified text
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Joan's contact with local asset image
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/joan.jpg'), // Use local asset
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Joan R. Tigbawan\n+63 963 530 8735\njoan.tigbawan@evsu.edu.ph',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.justify, // Justified text
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
