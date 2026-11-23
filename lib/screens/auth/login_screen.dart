import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';
import 'signup_screen.dart';

// LoginScreen allows existing users to sign in with Email & Password
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Key used to validate all TextFormFields inside our Form
  final _formKey = GlobalKey<FormState>();

  // Controllers to read text typed by the user
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Instance of our AuthService to talk to Firebase
  final AuthService _authService = AuthService();

  // State variables for UI interactivity
  bool isLoading = false;        // Shows spinner while logging in
  bool hidePassword = true;      // Toggles password visibility (eye icon)
  String? errorMessage;          // Stores "Wrong Email ID" or "Wrong Password" message

  // Runs when the user taps the "Login" button
  void handleLogin() async {
    // 1. Validate empty fields or bad email format first
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Start loading spinner and clear any previous error message
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // 3. Call loginUser() from AuthService
    String? result = await _authService.loginUser(
      email: emailController.text,
      password: passwordController.text,
    );

    // 4. Stop loading spinner
    setState(() {
      isLoading = false;
    });

    if (result == null) {
      // Login succeeded! Show welcome SnackBar and move to HomeScreen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Successful! Welcome back.")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      // Login failed (Wrong Email ID or Wrong Password) -> show red error box
      setState(() {
        errorMessage = result;
      });
    }
  }

  // Clean up controllers when this screen is closed
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30),

                // App Icon Badge
                Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.currency_rupee, color: Colors.white, size: 32),
                ),

                SizedBox(height: 20),

                // Heading
                Text(
                  "Welcome Back",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  "Sign in to manage your loans and interest",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),

                SizedBox(height: 24),

                // RED ERROR BANNER (Only appears if Wrong Email ID or Wrong Password)
                if (errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: TextStyle(
                              color: Colors.red[900],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Email Input Field
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter your Email ID";
                    }
                    if (!value.contains("@")) {
                      return "Please enter a valid Email ID";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16),

                // Password Input Field with Show/Hide Eye Button
                TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your password";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 24),

                // Login Button (Shows spinner while loading)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 20),

                // Switch to Sign Up Screen for New Users
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("New user? "),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignupScreen()),
                        );
                      },
                      child: Text(
                        "Create an Account (Sign Up)",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}