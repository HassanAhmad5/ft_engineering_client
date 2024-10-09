import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ft_engineering_client/Components/reuseable_widgets.dart';

class PendingOrderDetailScreen extends StatelessWidget {
  final String orderId;
  final double totalPrice;
  final List<Map<String, dynamic>> products; // List of products in the order
  final String status;
  final DateTime orderDate;

  const PendingOrderDetailScreen({
    super.key,
    required this.orderId,
    required this.totalPrice,
    required this.products,
    required this.status,
    required this.orderDate,
  });

  // Function to cancel the order by deleting it from Firestore
  Future<void> cancelOrder(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).delete();
      Navigator.of(context).pop(); // Navigate back after deleting
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order canceled successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to cancel order')),
      );
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
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenSize.height * 0.02,
          horizontal: screenSize.width * 0.05,
        ),
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
                color: status == 'completed' ? Colors.green : Colors.orange,
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
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
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
                },
              ),
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
            // Cancel Order Button
            ReuseableButton(text: 'Cancel Order', onPressed: () async {
              // Show confirmation dialog before canceling the order
              bool confirmed = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cancel Order'),
                  content: const Text('Are you sure you want to cancel this order?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('No', style: TextStyle(color: Colors.green),),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Yes', style: TextStyle(color: Colors.deepOrange),),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                // If confirmed, proceed to cancel the order
                await cancelOrder(context);
              }
            },)
          ],
        ),
      ),
    );
  }
}
