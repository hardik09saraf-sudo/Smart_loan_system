// Blueprint class to store a single payment made towards a loan
class PaymentModel {
  // Properties of a payment record
  String id;              // Unique ID of this payment in Firebase
  String transactionId;   // Links this payment to the parent Loan's ID
  double amount;          // How much money was paid in this installment
  String paymentDate;     // Date when the payment was made
  String mode;            // Payment mode: "UPI", "Bank Transfer", "Cash", or "Other"
  String proofUrl;        // Download link of the uploaded receipt image (from Firebase Storage)

  // Constructor: Initializes all payment fields
  PaymentModel({
    required this.id,
    required this.transactionId,
    required this.amount,
    required this.paymentDate,
    required this.mode,
    required this.proofUrl,
  });

  // Converts this PaymentModel object into a Map to save inside Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionId': transactionId,
      'amount': amount,
      'paymentDate': paymentDate,
      'mode': mode,
      'proofUrl': proofUrl,
    };
  }

  // Converts a Map fetched from Firestore back into a PaymentModel object
  factory PaymentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PaymentModel(
      id: documentId,
      transactionId: map['transactionId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      paymentDate: map['paymentDate'] ?? '',
      mode: map['mode'] ?? 'UPI',
      proofUrl: map['proofUrl'] ?? '',
    );
  }
}