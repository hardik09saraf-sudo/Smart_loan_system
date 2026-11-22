import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Service class that handles Sign Up, Login, and Logout with Firebase
class AuthService {
  // Create instances of Firebase Authentication and Cloud Firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the currently logged-in user (returns null if nobody is logged in)
  User? get currentUser => _auth.currentUser;

  // 1. SIGN UP FUNCTION (Creates a new account and saves user profile in Firestore)
  // Returns null if Sign Up succeeds, or returns a clear error message String if it fails
  Future<String?> signUpUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Step A: Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Step B: Save user's Name and Email inside Firestore under 'users/{uid}'
      // Each user gets their own private document ID (uid)
      String uid = userCredential.user!.uid;
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name.trim(),
        'email': email.trim(),
        'createdAt': Timestamp.now(),
      });

      return null; // Returning null means Sign Up was 100% successful!
    } on FirebaseAuthException catch (e) {
      // Handle common Firebase Sign Up errors with clear messages
      if (e.code == 'email-already-in-use') {
        return 'Email Already Registered. Please Login instead.';
      } else if (e.code == 'weak-password') {
        return 'Password is too weak. Use at least 6 characters.';
      } else if (e.code == 'invalid-email') {
        return 'Invalid Email ID format.';
      } else {
        return e.message ?? 'Sign Up failed. Please try again.';
      }
    } catch (e) {
      return 'Something went wrong: $e';
    }
  }

  // 2. LOGIN FUNCTION (Checks Email ID and Password in Firebase)
  // Returns null if Login succeeds, or returns a clear error message String if it fails
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in using Firebase Authentication
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return null; // Returning null means Login was 100% successful!
    } on FirebaseAuthException catch (e) {
      // Handle wrong email or wrong password with clear messages
      if (e.code == 'user-not-found') {
        return 'Wrong Email ID. No account found with this email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong Password. Please enter the correct password.';
      } else if (e.code == 'invalid-credential') {
        return 'Wrong Email ID or Password. Please check and try again.';
      } else if (e.code == 'invalid-email') {
        return 'Invalid Email ID format.';
      } else {
        return e.message ?? 'Login failed. Please try again.';
      }
    } catch (e) {
      return 'Something went wrong: $e';
    }
  }

  // 3. LOGOUT FUNCTION (Signs out the current user)
  Future<void> logoutUser() async {
    await _auth.signOut();
  }
}