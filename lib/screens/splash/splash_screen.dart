import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';

// SplashScreen is the very first screen shown when the app opens
class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // initState() runs automatically ONCE as soon as this screen appears
  @override
  void initState() {
    super.initState();
    checkUserAndNavigate();
  }

  // Waits 2 seconds, then checks if a user is already logged in
  void checkUserAndNavigate() async {
    // Pause for 2 seconds so the user sees the brand logo
    await Future.delayed(Duration(seconds: 2));

    // Safety check: make sure this screen is still open before navigating
    if (!mounted) return;

    // Check FirebaseAuth to see if someone is already logged in on this phone
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // User is already logged in -> go straight to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      // Nobody is logged in -> go to LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dark fintech background color
      backgroundColor: Color(0xFF0D1117),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Rounded blue box holding the Rupee icon
            Container(
              padding: EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.currency_rupee,
                size: 56,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 20),

            // Main App Title
            Text(
              "SmartInterestX",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 8),

            // Subtitle
            Text(
              "Loan & Interest Manager",
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[300],
              ),
            ),

            SizedBox(height: 35),

            // Small loading spinner
            CircularProgressIndicator(color: Colors.blue),
          ],
        ),
      ),
    );
  }
}