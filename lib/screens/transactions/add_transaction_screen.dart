import 'package:flutter/material.dart';
import '../../models/contact_model.dart';
import '../../models/transaction_model.dart';
import '../../services/firestore_service.dart';

// AddTransactionScreen allows users to record a new Given or Taken loan
// with a real-time Simple Interest preview card
class AddTransactionScreen extends StatefulWidget {
  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  final FirestoreService _firestoreService = FirestoreService();

  // Controllers for numeric & text inputs
  final TextEditingController amountController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // Selected contact details
  String? selectedContactId;
  String? selectedContactName;

  // Loan configuration state
  String transactionType = 'given'; // 'given' (I Lent) or 'taken' (I Borrowed)
  String rateType = 'yearly';       // 'yearly' or 'monthly'
  DateTime startDate = DateTime.now();
  DateTime? dueDate;

  bool isSaving = false;

  // Helper to format DateTime as YYYY-MM-DD
  String formatDate(DateTime date) {
    String y = date.year.toString();
    String m = date.month.toString().padLeft(2, '0');
    String d = date.day.toString().padLeft(2, '0');
    return "$y-$m-$d";
  }

  // Self-contained Simple Interest calculator (Yearly: 365 days, Monthly: 30 days)
  double computeSimpleInterest(double principal, double rate, String period, DateTime start, DateTime end) {
    if (principal <= 0 || rate <= 0) return 0.0;
    int days = end.difference(start).inDays;
    if (days <= 0) return 0.0;

    if (period == 'monthly') {
      return (principal * rate * (days / 30.0)) / 100.0;
    } else {
      return (principal * rate * (days / 365.0)) / 100.0;
    }
  }

  // Opens Flutter DatePicker for Start Date
  Future<void> pickStartDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
      });
    }
  }

  // Opens Flutter DatePicker for optional Due Date
  Future<void> pickDueDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dueDate ?? startDate.add(Duration(days: 30)),
      firstDate: startDate,
      lastDate: DateTime(2040),
    );
    if (picked != null) {
      setState(() {
        dueDate = picked;
      });
    }
  }

  // Saves the new loan transaction into Cloud Firestore
  void handleSaveLoan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedContactId == null || selectedContactName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a Borrower or Lender first!")),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    String newId = DateTime.now().millisecondsSinceEpoch.toString();

    TransactionModel newLoan = TransactionModel(
      id: newId,
      contactId: selectedContactId!,
      contactName: selectedContactName!,
      amount: double.parse(amountController.text.trim()),
      type: transactionType,
      interestRate: double.parse(rateController.text.trim()),
      rateType: rateType,
      startDate: formatDate(startDate),
      dueDate: dueDate != null ? formatDate(dueDate!) : '',
      notes: notesController.text.trim(),
      status: 'active',
      paidAmount: 0.0,
    );

    try {
      await _firestoreService.addTransaction(newLoan);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Loan saved successfully!")),
      );

      Navigator.pop(context); // Return to Loans List
    } catch (e) {
      setState(() {
        isSaving = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving loan: $e")),
      );
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    rateController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Parse live numbers for the Live Interest Preview Card
    double previewPrincipal = double.tryParse(amountController.text.trim()) ?? 0.0;
    double previewRate = double.tryParse(rateController.text.trim()) ?? 0.0;

    double interestTillToday = computeSimpleInterest(
      previewPrincipal,
      previewRate,
      rateType,
      startDate,
      DateTime.now(),
    );

    double interestTillDue = dueDate != null
        ? computeSimpleInterest(
            previewPrincipal,
            previewRate,
            rateType,
            startDate,
            dueDate!,
          )
        : interestTillToday;

    double totalPayable = previewPrincipal + interestTillDue;

    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Loan"),
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
              // 1. Contact Dropdown loaded live from Firestore
              Text(
                "Select Borrower / Lender *",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              StreamBuilder<List<ContactModel>>(
                stream: _firestoreService.getContactsStream(),
                builder: (context, snapshot) {
                  List<ContactModel> contacts = snapshot.data ?? [];

                  if (contacts.isEmpty) {
                    return Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: Text(
                        "No contacts found! Go to the Contacts tab first and add a Borrower or Lender.",
                        style: TextStyle(color: Colors.amber[900], fontSize: 13),
                      ),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    initialValue: selectedContactId,
                    hint: Text("Choose a contact"),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person_search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: contacts.map((c) {
                      return DropdownMenuItem<String>(
                        value: c.id,
                        child: Text("${c.name} (${c.type.toUpperCase()})"),
                      );
                    }).toList(),
                    onChanged: (value) {
                      ContactModel chosen =
                          contacts.firstWhere((c) => c.id == value);
                      setState(() {
                        selectedContactId = chosen.id;
                        selectedContactName = chosen.name;
                      });
                    },
                  );
                },
              ),

              SizedBox(height: 18),

              // 2. Transaction Type Toggle (Given vs Taken)
              Text(
                "Transaction Type *",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Center(child: Text("Given (I Lent)")),
                      selected: transactionType == 'given',
                      selectedColor: Colors.green[100],
                      onSelected: (_) {
                        setState(() => transactionType = 'given');
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      label: Center(child: Text("Taken (I Borrowed)")),
                      selected: transactionType == 'taken',
                      selectedColor: Colors.amber[100],
                      onSelected: (_) {
                        setState(() => transactionType = 'taken');
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 18),

              // 3. Principal Amount Field
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: "Principal Amount (₹) *",
                  prefixIcon: Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  double? amt = double.tryParse(value ?? '');
                  if (amt == null || amt <= 0) {
                    return "Enter a valid amount greater than 0";
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              // 4. Interest Rate & Rate Period Row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: rateController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: "Interest Rate (%) *",
                        prefixIcon: Icon(Icons.percent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        double? r = double.tryParse(value ?? '');
                        if (r == null || r < 0) {
                          return "Enter valid rate";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: rateType,
                      decoration: InputDecoration(
                        labelText: "Period",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(value: 'yearly', child: Text("Yearly")),
                        DropdownMenuItem(value: 'monthly', child: Text("Monthly")),
                      ],
                      onChanged: (val) {
                        setState(() {
                          rateType = val!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // 5. Start Date & Optional Due Date Pickers
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: pickStartDate,
                      icon: Icon(Icons.calendar_today, size: 16),
                      label: Text("Start: ${formatDate(startDate)}"),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: pickDueDate,
                      icon: Icon(Icons.event_available, size: 16),
                      label: Text(
                        dueDate == null
                            ? "Due Date (Opt)"
                            : "Due: ${formatDate(dueDate!)}",
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // 6. Optional Notes Field
              TextFormField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: "Notes / Purpose (Optional)",
                  prefixIcon: Icon(Icons.note_alt_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // 7. LIVE INTEREST PREVIEW CARD
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calculate, color: Colors.blue[700], size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Live Simple Interest Preview",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Interest Till Today:"),
                        Text(
                          "₹${interestTillToday.toStringAsFixed(2)}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Interest Till Due Date:"),
                        Text(
                          "₹${interestTillDue.toStringAsFixed(2)}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Divider(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Payable / Receivable:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                        Text(
                          "₹${totalPayable.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // 8. Save Loan Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSaving ? null : handleSaveLoan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSaving
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Save Loan",
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