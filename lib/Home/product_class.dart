import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String name;
  String description;
  int quantity;
  String quantityType;
  String? imageUrl;
  double price;  // Add the price field
  Timestamp? timestamp;

  Product({
    required this.name,
    required this.description,
    required this.quantity,
    required this.quantityType,
    this.imageUrl,
    required this.price,  // Update constructor to require price
    this.timestamp,
  });

  // Factory method to create a Product from Firestore data
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      quantity: data['quantity'] ?? 0,
      quantityType: data['quantityType'] ?? 'KG',
      imageUrl: data['imageUrl'],
      price: (data['price'] ?? 0.0).toDouble(), // Handle price
      timestamp: data['timestamp'], // Handle timestamp
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'quantity': quantity,
      'quantityType': quantityType,
      'imageUrl': imageUrl,
      'price': price,  // Include price in the map
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
    };
  }

  double get totalPrice => price * quantity;
}

class CartProduct {
  final String name;
  final String imageUrl;
  final int quantity;
  final double price;

  CartProduct({
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.price,
  });

  double get totalPrice => price * quantity;
}
