import 'package:flutter/material.dart';
import '../../models/contact_model.dart';
import '../../services/firestore_service.dart';

// AddContactScreen lets the user add a new Borrower or Lender to Firestore
class AddContactScreen extends StatefulWidget {
  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the input fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Default role is 'borrower' (user can toggle between 'borrower' and 'lender')
  String selectedType = 'borrower';
  bool isSaving = false;

  final FirestoreService _firestoreService = FirestoreService();

  // Validates form and saves the new ContactModel into Firestore
  void handleSaveContact() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    // Generate a unique ID using current timestamp
    String newId = DateTime.now().millisecondsSinceEpoch.toString();

    ContactModel newContact = ContactModel(
      id: newId,
      name: nameController.text.trim(),
      mobile: mobileController.text.trim(),
      email: emailController.text.trim(),
      type: selectedType,
      createdAt: DateTime.now().toIso8601String(),
    );

    try {
      await _firestoreService.addContact(newContact);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${newContact.name} saved to Contacts!")),
      );

      // Go back to ContactListScreen
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving contact: $e")),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Contact"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Full Name Field
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Full Name *",
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter contact's name";
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              // 2. Mobile Number Field
              TextFormField(
                controller: mobileController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Mobile Number *",
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter mobile number";
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              // 3. Optional Email Field
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email Address (Optional)",
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // 4. Role Selector (Borrower vs Lender)
              Text(
                "Tag Contact As:",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Center(child: Text("Borrower (Takes Money)")),
                      selected: selectedType == 'borrower',
                      selectedColor: Colors.amber[100],
                      onSelected: (val) {
                        setState(() {
                          selectedType = 'borrower';
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      label: Center(child: Text("Lender (Gives Money)")),
                      selected: selectedType == 'lender',
                      selectedColor: Colors.green[100],
                      onSelected: (val) {
                        setState(() {
                          selectedType = 'lender';
                        });
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),

              // 5. Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSaving ? null : handleSaveContact,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSaving
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Save Contact",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}