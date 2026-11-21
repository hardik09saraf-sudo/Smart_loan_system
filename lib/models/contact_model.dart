// Blueprint class to store details of a Borrower or Lender
class ContactModel {
  // Variables (properties) that every contact will have
  String id;          // Unique ID of the contact in Firebase
  String name;        // Full name of the person
  String mobile;      // Mobile phone number
  String email;       // Email address (can be empty "")
  String type;        // Either "borrower" (takes money) or "lender" (gives money)
  String createdAt;   // Date & time when this contact was created

  // Constructor: Runs when we create a new ContactModel object
  ContactModel({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.type,
    required this.createdAt,
  });

  // 1. toMap(): Converts this Dart object into a Map (Key-Value pairs)
  // Firebase Firestore only understands Maps, so we use this before saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
      'type': type,
      'createdAt': createdAt,
    };
  }

  // 2. fromMap(): Converts a Map coming from Firestore back into a ContactModel object
  // 'factory' means a special constructor that builds and returns an object from raw data
  factory ContactModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ContactModel(
      id: documentId,                     // Gets the document ID from Firestore
      name: map['name'] ?? '',            // '??' means if null, use empty text ''
      mobile: map['mobile'] ?? '',
      email: map['email'] ?? '',
      type: map['type'] ?? 'borrower',
      createdAt: map['createdAt'] ?? '',
    );
  }
}