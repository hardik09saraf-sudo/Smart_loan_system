import 'package:flutter/material.dart';

// Starter screen for Loans List (Full loans list will be built in Week 2)
class TransactionListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Loans & Transactions"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          "Loans List (Coming in Week 2)",
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
      ),
    );
  }
}