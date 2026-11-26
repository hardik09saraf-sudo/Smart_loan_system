import 'package:flutter/material.dart';

// Starter screen for Dashboard (Full summary cards & charts will be built in Week 3)
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          "Dashboard & Analytics (Coming in Week 3)",
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
      ),
    );
  }
}