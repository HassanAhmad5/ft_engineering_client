import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher package

class ProgressOrderDetailScreen extends StatelessWidget {
  final String orderId;
  final double totalPrice;
  final List<Map<String, dynamic>> products; // List of products in the order
  final String status;
  final DateTime orderDate;
  final String staffId;

  ProgressOrderDetailScreen({
    super.key,
    required this.orderId,
    required this.totalPrice,
    required this.products,
    required this.status,
    required this.orderDate,
    required this.staffId,
  });

  // Function to launch phone dialer
  void _launchCaller(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade200,
        title: const Text(
          "Ft Engineering",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: screenSize.height * 0.02,
            horizontal: screenSize.width * 0.05,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Details:',
                style: TextStyle(
                  fontSize: screenSize.width * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ID: $orderId',
                        style: TextStyle(
                          fontSize: screenSize.width * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Order Date: ${orderDate.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(fontSize: screenSize.width * 0.045),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Status: $status',
                        style: TextStyle(
                          fontSize: screenSize.width * 0.045,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Products:',
                        style: TextStyle(
                          fontSize: screenSize.width * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Column(
                        children: products.map((product) {
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: screenSize.height * 0.1,
                                    width: screenSize.width * 0.2,
                                    child: Image.network(
                                      product['imageUrl'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['name'],
                                          style: TextStyle(
                                            fontSize: screenSize.width * 0.045,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Quantity: ${product['quantity']}',
                                          style: TextStyle(
                                            fontSize: screenSize.width * 0.04,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Price: ${product['price'].toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: screenSize.width * 0.04,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Total Price: ${totalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: screenSize.width * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Assigned Staff:',
                style: TextStyle(
                  fontSize: screenSize.width * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('staff').doc(staffId).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var staffData = snapshot.data!.data() as Map<String, dynamic>?;
                  if (staffData == null) {
                    return const Text('Staff information not found');
                  }

                  String staffName = staffData['name'];
                  String staffPhone = staffData['phone'];

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: Text(
                        'Name: $staffName',
                        style: TextStyle(
                          fontSize: screenSize.width * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Phone: $staffPhone',
                        style: TextStyle(fontSize: screenSize.width * 0.04),
                      ),
                      leading: const Icon(Icons.person, color: Colors.blueAccent),
                      trailing: IconButton(
                        icon: const Icon(Icons.phone, color: Colors.green),
                        onPressed: () => _launchCaller(staffPhone),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
