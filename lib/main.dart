import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Auto-generated when you ran flutterfire configure
import 'app.dart';              // Imports our root MyApp widget

// Main entry point where the Flutter app starts executing
void main() async {
  // Ensures Flutter engine bindings are ready before calling Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Connects your Flutter app to your Firebase backend project
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Launches the root widget of the app
  runApp(MyApp());
}