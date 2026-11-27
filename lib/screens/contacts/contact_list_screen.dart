import 'package:flutter/material.dart';
import '../../models/contact_model.dart';
import '../../services/firestore_service.dart';
import 'add_contact_screen.dart';

// ContactListScreen displays all Borrowers & Lenders in real time from Firestore
class ContactListScreen extends StatefulWidget {
  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  // Search text and selected role filter ('ALL', 'borrower', or 'lender')
  String searchQuery = "";
  String selectedFilter = "ALL";

  // Shows a confirmation dialog before deleting a contact
  void confirmDeleteContact(ContactModel contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Contact"),
        content: Text("Are you sure you want to delete ${contact.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _firestoreService.deleteContact(contact.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${contact.name} deleted")),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts Directory"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),

      // Floating Action Button to open AddContactScreen
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddContactScreen()),
          );
        },
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        icon: Icon(Icons.person_add),
        label: Text("Add Contact"),
      ),

      body: Column(
        children: [
          // 1. Search Input Box
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by name or mobile...",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),

          // 2. Role Filter Chips (All / Borrowers / Lenders)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                FilterChip(
                  label: Text("All"),
                  selected: selectedFilter == "ALL",
                  onSelected: (_) => setState(() => selectedFilter = "ALL"),
                ),
                SizedBox(width: 8),
                FilterChip(
                  label: Text("Borrowers"),
                  selected: selectedFilter == "borrower",
                  onSelected: (_) => setState(() => selectedFilter = "borrower"),
                ),
                SizedBox(width: 8),
                FilterChip(
                  label: Text("Lenders"),
                  selected: selectedFilter == "lender",
                  onSelected: (_) => setState(() => selectedFilter = "lender"),
                ),
              ],
            ),
          ),

          // 3. Live Firestore Stream of Contacts
          Expanded(
            child: StreamBuilder<List<ContactModel>>(
              stream: _firestoreService.getContactsStream(),
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                // Error state
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                List<ContactModel> allContacts = snapshot.data ?? [];

                // Apply Search and Filter
                List<ContactModel> filteredContacts = allContacts.where((c) {
                  bool matchesFilter =
                      selectedFilter == "ALL" || c.type == selectedFilter;
                  bool matchesSearch =
                      c.name.toLowerCase().contains(searchQuery) ||
                      c.mobile.contains(searchQuery);
                  return matchesFilter && matchesSearch;
                }).toList();

                // Empty state
                if (filteredContacts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          "No contacts found",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Tap + Add Contact below to add a Borrower or Lender",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                // Contact Cards List
                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    ContactModel contact = filteredContacts[index];
                    bool isBorrower = contact.type == 'borrower';

                    return Card(
                      margin: EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              isBorrower ? Colors.amber[100] : Colors.green[100],
                          child: Text(
                            contact.name[0].toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isBorrower ? Colors.amber[900] : Colors.green[900],
                            ),
                          ),
                        ),
                        title: Text(
                          contact.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(contact.mobile),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isBorrower ? Colors.amber[50] : Colors.green[50],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isBorrower ? Colors.amber : Colors.green,
                                ),
                              ),
                              child: Text(
                                contact.type.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isBorrower ? Colors.amber[900] : Colors.green[900],
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => confirmDeleteContact(contact),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}