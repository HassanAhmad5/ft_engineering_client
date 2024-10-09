import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Pending Orders/pending_order_detail_screen.dart';
import 'Progress Orders/progress_order_detail_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  _OrderTrackingScreenState createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int pendingOrdersCount = 0;
  int inProgressOrdersCount = 0;
  int completeOrdersCount = 0;


  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchOrderCounts();
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  // Function to fetch orders with specific status
  Stream<QuerySnapshot> getOrdersByStatus(String status) {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('clientId', isEqualTo: _auth.currentUser!.uid)
        .where('status', isEqualTo: status)
        .snapshots();
  }

  void _fetchOrderCounts() {
    getOrdersByStatus('pending').listen((snapshot) {
      setState(() {
        pendingOrdersCount = snapshot.docs.length;
      });
    });

    getOrdersByStatus('in progress').listen((snapshot) {
      setState(() {
        inProgressOrdersCount = snapshot.docs.length;
      });
    });

    getOrdersByStatus('completed').listen((snapshot) {
      setState(() {
        completeOrdersCount = snapshot.docs.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // StreamBuilders to fetch and display active orders
          SizedBox(
            height: 120,
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.only(
                  left: 0.10 * MediaQuery.of(context).size.width),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Orders",
                    style: TextStyle(fontSize: 23),
                  ),
                  Text(
                    "${pendingOrdersCount + inProgressOrdersCount + completeOrdersCount}",
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.blueAccent,
                    ),
                  )
                ],
              ),
            ),
          ),
          TabBar(
            indicatorColor: Colors.yellow.shade600,
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black,
            tabs: [
              Tab(text: 'Pending ($pendingOrdersCount)'),
              Tab(text: 'In Progress ($inProgressOrdersCount)'),
              Tab(text: 'Completed ($completeOrdersCount)'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildPendingOrderList(),    // Pending orders tab
                buildProgressOrderList(),  // In progress orders tab
                buildCompletedOrderList(),   // Completed orders tab
              ],
            ),
          ),
        ],
      ),
    );
  }
  // Widget to build the order list based on the status
  Widget buildPendingOrderList() {
    return StreamBuilder<QuerySnapshot>(
      stream: getOrdersByStatus('pending'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var orders = snapshot.data!.docs;

        if (orders.isEmpty) {
          return const Center(
            child: Text('No orders available'),
          );
        }

        return ListView.builder(
          itemCount: orders.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            var orderData = orders[index].data() as Map<String, dynamic>;
            String orderId = orders[index].id;
            double totalPrice = orderData['totalPrice'];
            List<Map<String, dynamic>> products = List<Map<String, dynamic>>.from(orderData['products']);
            String status = orderData['status'];
            DateTime orderDate = (orderData['orderDate'] as Timestamp).toDate();

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: ListTile(
                title: Text('Order ID: $orderId'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Products: ${products.length}'),
                    Text('Total Price: ${totalPrice.toStringAsFixed(0)}'),
                  ],
                ),
                onTap: () {
                  // Navigate to OrderDetailScreen when an order is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PendingOrderDetailScreen(
                        orderId: orderId,
                        totalPrice: totalPrice,
                        products: products,
                        status: status,
                        orderDate: orderDate,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget buildProgressOrderList() {
    return StreamBuilder<QuerySnapshot>(
      stream: getOrdersByStatus('in progress'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var orders = snapshot.data!.docs;

        if (orders.isEmpty) {
          return const Center(
            child: Text('No orders available'),
          );
        }

        return ListView.builder(
          itemCount: orders.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            var orderData = orders[index].data() as Map<String, dynamic>;
            String orderId = orders[index].id;
            double totalPrice = orderData['totalPrice'];
            List<Map<String, dynamic>> products = List<Map<String, dynamic>>.from(orderData['products']);
            String status = orderData['status'];
            DateTime orderDate = (orderData['orderDate'] as Timestamp).toDate();
            String? assignedStaffId = orderData['assigned_staffId'];

            // If there's no assigned staff, show a default message
            if (assignedStaffId == null) {
              return _buildOrderCard(orderId, totalPrice, products, status, orderDate, 'Not Assigned', 'N/A', assignedStaffId!);
            }

            // Fetch staff details using the assigned staff ID
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('staff').doc(assignedStaffId).get(),
              builder: (context, staffSnapshot) {
                if (!staffSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var staffData = staffSnapshot.data!.data() as Map<String, dynamic>;
                String staffName = staffData['name'];
                String staffPhone = staffData['phone'];

                return _buildOrderCard(orderId, totalPrice, products, status, orderDate, staffName, staffPhone, assignedStaffId);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildOrderCard(String orderId, double totalPrice, List<Map<String, dynamic>> products,
      String status, DateTime orderDate, String staffName, String staffPhone, String assignedStaffId) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: ListTile(
        title: Text('Order ID: $orderId'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Products: ${products.length}'),
            Text('Total Price: ${totalPrice.toStringAsFixed(0)}'),
            Text('Staff Name: $staffName'),
            Text('Staff Phone: $staffPhone'),
          ],
        ),
        onTap: () {
          // Navigate to OrderDetailScreen when an order is tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProgressOrderDetailScreen(
                orderId: orderId,
                totalPrice: totalPrice,
                products: products,
                status: status,
                orderDate: orderDate,
                staffId: assignedStaffId,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildCompletedOrderList() {
    return StreamBuilder<QuerySnapshot>(
      stream: getOrdersByStatus('completed'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var orders = snapshot.data!.docs;

        if (orders.isEmpty) {
          return const Center(
            child: Text('No orders available'),
          );
        }

        return ListView.builder(
          itemCount: orders.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            var orderData = orders[index].data() as Map<String, dynamic>;
            String orderId = orders[index].id;
            double totalPrice = orderData['totalPrice'];
            List<Map<String, dynamic>> products = List<Map<String, dynamic>>.from(orderData['products']);
            String status = orderData['status'];
            DateTime orderDate = (orderData['orderDate'] as Timestamp).toDate();

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: ListTile(
                title: Text('Order ID: $orderId'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Products: ${products.length}'),
                    Text('Total Price: ${totalPrice.toStringAsFixed(0)}'),
                  ],
                ),
                onTap: () {
                  // Navigate to OrderDetailScreen when an order is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PendingOrderDetailScreen(
                        orderId: orderId,
                        totalPrice: totalPrice,
                        products: products,
                        status: status,
                        orderDate: orderDate,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
