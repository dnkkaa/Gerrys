import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen width
    double screenWidth = MediaQuery.of(context).size.width;

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
              'Frequently Asked Question',
              style: GoogleFonts.poppins(
                textStyle: Theme.of(context).textTheme.headline6?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  //fontSize: screenWidth > 800 ? screenWidth * 0.03 : screenWidth * 0.05, // Larger text size for web/laptop
                ),
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.blue[300],
            elevation: 4.0,
          ),
        ),
      ),
      body: ListView(
        children: const [
          FAQItem(question: 'What is the return policy?', answer: 'You can return items within 3 days starting the day it was rented. If happens that your not able to returned the item within the date returned that was given to you, a given penalty will be given worth ₱100.00 per day.'),
          FAQItem(question: 'How can I track my order?', answer: 'You can track your order by visiting the Profile Tab > Choose \'Transaction\' or simply you will received a notif coming from the notification tab.'),
          FAQItem(question: 'What payment methods are accepted?', answer: 'We simply accept Cash-on-site and GCash.'),
        ],
      ),
    );
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const FAQItem({
    Key? key,
    required this.question,
    required this.answer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text(
          question,
          style: GoogleFonts.poppins(
            fontSize: screenWidth > 500 ? screenWidth * 0.020 : screenWidth * 0.020, // Larger text size for web/laptop
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: GoogleFonts.poppins(
                fontSize: screenWidth > 800 ? screenWidth * 0.030 : screenWidth * 0.025, // Adjust answer text size based on screen width
              ),
            ),
          ),
        ],
      ),
    );
  }
}
