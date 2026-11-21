// Blueprint class to store details of a Loan Transaction (Given or Taken)
class TransactionModel {
  // Properties of a loan transaction
  String id;             // Unique ID of this loan in Firebase
  String contactId;      // Links this loan to a specific Contact's ID
  String contactName;    // Name of the borrower/lender (for easy display in lists)
  double amount;         // Principal loan amount (in Rupees)
  String type;           // "given" (you lent money) or "taken" (you borrowed money)
  double interestRate;   // Interest rate percentage (%)
  String rateType;       // "yearly" or "monthly"
  String startDate;      // Date when the loan started (saved as text e.g. "2026-11-21")
  String dueDate;        // Optional due date (empty "" if no due date)
  String notes;          // Extra description or notes about the loan
  String status;         // "active", "partial" (half paid), or "settled" (fully paid)
  double paidAmount;     // Total amount paid back so far (starts at 0.0)

  // Constructor: Initializes all fields when creating a TransactionModel object
  TransactionModel({
    required this.id,
    required this.contactId,
    required this.contactName,
    required this.amount,
    required this.type,
    required this.interestRate,
    required this.rateType,
    required this.startDate,
    required this.dueDate,
    required this.notes,
    required this.status,
    required this.paidAmount,
  });

  // Converts this TransactionModel object into a Map to save inside Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contactId': contactId,
      'contactName': contactName,
      'amount': amount,
      'type': type,
      'interestRate': interestRate,
      'rateType': rateType,
      'startDate': startDate,
      'dueDate': dueDate,
      'notes': notes,
      'status': status,
      'paidAmount': paidAmount,
    };
  }

  // Converts a Map fetched from Firestore back into a TransactionModel object
  factory TransactionModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TransactionModel(
      id: documentId,
      contactId: map['contactId'] ?? '',
      contactName: map['contactName'] ?? '',
      // .toDouble() ensures numbers like 5000 (int) safely become 5000.0 (double)
      amount: (map['amount'] ?? 0).toDouble(),
      type: map['type'] ?? 'given',
      interestRate: (map['interestRate'] ?? 0).toDouble(),
      rateType: map['rateType'] ?? 'yearly',
      startDate: map['startDate'] ?? '',
      dueDate: map['dueDate'] ?? '',
      notes: map['notes'] ?? '',
      status: map['status'] ?? 'active',
      paidAmount: (map['paidAmount'] ?? 0).toDouble(),
    );
  }
}