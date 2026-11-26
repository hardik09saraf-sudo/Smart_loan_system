import 'package:flutter/material.dart';

// Starter screen for Contacts List (Full directory & Add Contact will be built tomorrow - Day 6)
class ContactListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          "Contacts Directory (Coming Tomorrow - Day 6)",
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
      ),
    );
  }
}
