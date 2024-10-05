import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gown_rental/pages/login_page.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isLargeScreen = constraints.maxWidth > 800;

          return Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: isLargeScreen
                      ? Row(
                        children: [
                          Expanded(
                            flex: 3,  
                            child: Image.asset(
                              'assets/background1.gif',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const Spacer(flex: 1),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.blue[100],
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginPage()), 
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min, 
                              children: [
                                const Icon(
                                  Icons.arrow_forward, 
                                  color: Colors.black,
                                ),
                                const SizedBox(width: 10), 
                                Text(
                                  'Get Started',
                                  style: GoogleFonts.raleway(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(flex: 1), //space to the right of the button
                        ],
                      )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Full-screen layout for small screens
                            Expanded(
                              child: Center(
                                child: Image.asset(
                                  'assets/background1.gif',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Colors.blue[100], // Light blue background
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginPage()), 
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min, 
                                children: [
                                  const Icon(
                                    Icons.arrow_forward, 
                                    color: Colors.black,
                                  ),
                                  const SizedBox(width: 10), 
                                  Text(
                                    'Get Started',
                                    style: GoogleFonts.raleway(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// class AnimatedText extends StatefulWidget {
//   final String text;
//   final TextStyle style;

//   const AnimatedText({Key? key, required this.text, required this.style}) : super(key: key);

//   @override
//   _AnimatedTextState createState() => _AnimatedTextState();
// }

// class _AnimatedTextState extends State<AnimatedText> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<Offset> _offsetAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     )..repeat(reverse: true);

//     _offsetAnimation = Tween<Offset>(
//       begin: Offset.zero,
//       end: const Offset(0.0, -0.2),
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOut,
//     ));
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SlideTransition(
//       position: _offsetAnimation,
//       child: Text(widget.text, style: widget.style, textAlign: TextAlign.center),
//     );
//   }
// }
