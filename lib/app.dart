import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart';

// Root widget of SmartInterestX that sets up app-wide Theme and first screen
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Hides the red "DEBUG" banner in the top-right corner
      debugShowCheckedModeBanner: false,

      // App title shown in phone task switcher
      title: 'SmartInterestX',

      // Clean fintech blue color theme for the entire app
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
      ),

      // The very first screen shown when the app opens
      home: SplashScreen(),
    );
  }
}