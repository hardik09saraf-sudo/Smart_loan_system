import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/contact_model.dart';
import '../models/transaction_model.dart';
import '../models/payment_model.dart';

// FirestoreService handles all database Save, Read, Update, and Delete operations
// Every user's data is stored privately under: users/{uid}/...
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper getter for the currently logged-in user's unique ID
  String get _uid => _auth.currentUser!.uid;

  // Helper reference to the current user's private Firestore folder
  DocumentReference get _userDoc => _firestore.collection('users').doc(_uid);

  // ==========================================
  // 1. CONTACTS (BORROWERS & LENDERS)
  // ==========================================

  // Add a new contact to users/{uid}/contacts
  Future<void> addContact(ContactModel contact) async {
    await _userDoc.collection('contacts').doc(contact.id).set(contact.toMap());
  }

  // Real-time stream of all contacts for the current user
  Stream<List<ContactModel>> getContactsStream() {
    return _userDoc
        .collection('contacts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ContactModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Delete a contact
  Future<void> deleteContact(String contactId) async {
    await _userDoc.collection('contacts').doc(contactId).delete();
  }

  // ==========================================
  // 2. LOANS / TRANSACTIONS
  // ==========================================

  // Add a new loan transaction to users/{uid}/transactions
  Future<void> addTransaction(TransactionModel transaction) async {
    await _userDoc
        .collection('transactions')
        .doc(transaction.id)
        .set(transaction.toMap());
  }

  // Real-time stream of all loans for the current user
  Stream<List<TransactionModel>> getTransactionsStream() {
    return _userDoc
        .collection('transactions')
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Delete a loan transaction
  Future<void> deleteTransaction(String transactionId) async {
    await _userDoc.collection('transactions').doc(transactionId).delete();
  }

  // ==========================================
  // 3. INSTALLMENT PAYMENTS
  // ==========================================

  // Record a payment installment and update the parent loan's paidAmount & status
  Future<void> recordPayment({
    required PaymentModel payment,
    required double newPaidAmount,
    required String newStatus,
  }) async {
    // 1. Save payment receipt inside users/{uid}/transactions/{txId}/payments
    await _userDoc
        .collection('transactions')
        .doc(payment.transactionId)
        .collection('payments')
        .doc(payment.id)
        .set(payment.toMap());

    // 2. Update parent loan's total paidAmount and status ('partial' or 'settled')
    await _userDoc
        .collection('transactions')
        .doc(payment.transactionId)
        .update({
      'paidAmount': newPaidAmount,
      'status': newStatus,
    });
  }

  // Real-time stream of payment receipts for a specific loan
  Stream<List<PaymentModel>> getPaymentsStream(String transactionId) {
    return _userDoc
        .collection('transactions')
        .doc(transactionId)
        .collection('payments')
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PaymentModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}