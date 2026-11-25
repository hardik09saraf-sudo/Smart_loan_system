import 'package:flutter/material.dart';
import '../dashboard/dashboard_screen.dart';
import '../transactions/transaction_list_screen.dart';
import '../contacts/contact_list_screen.dart';
import '../settings/settings_screen.dart';

// HomeScreen is the main app shell holding the 4 bottom navigation tabs
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Keeps track of which tab is currently selected (0 = Dashboard, 1 = Loans, etc.)
  int selectedIndex = 0;

  // List of the 4 screens matching the 4 bottom navigation buttons
  final List<Widget> screens = [
    DashboardScreen(),
    TransactionListScreen(),
    ContactListScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Displays whichever screen corresponds to the currently selectedIndex
      body: screens[selectedIndex],

      // Bottom Navigation Bar with 4 tabs
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Loans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}