import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ft_engineering_client/Components/reuseable_widgets.dart';
import 'package:ft_engineering_client/Utils/utilities.dart';
import 'package:provider/provider.dart';

import '../main.dart';

// Product model


// Cart provider for managing cart state


// Main CartPage Widget
class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> storeOrderInFirestore(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    try {
      // Create a document in the 'orders' collection
      await FirebaseFirestore.instance.collection('orders').add({
        'orderDate': Timestamp.now(),
        'totalPrice': cartProvider.totalPrice,
        'clientId': _auth.currentUser!.uid,
        'status': 'pending',
        'products': cartProvider.products.map((product) => {
          'name': product.name,
          'quantity': product.quantity,
          'price': product.totalPrice,
          'imageUrl': product.imageUrl,
        }).toList(),
      });

      // After storing, clear the cart
      cartProvider.clearCart();

      setState(() {
        isLoading = false;
      });
      // Show success message
      Utilities().successMsg("Order Placed Successfully");
    } catch (e) {
      // Handle any errors that might occur during Firestore operation
      Utilities().errorMsg("Something went wrong");
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartProvider.products.length,
              itemBuilder: (context, index) {
                final product = cartProvider.products[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(
                    vertical: screenSize.height * 0.01,
                    horizontal: screenSize.width * 0.04,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(screenSize.height * 0.015),
                    child: Row(
                      children: [
                        SizedBox(
                          height: screenSize.height * 0.1,
                          width: screenSize.width * 0.2,
                          child: Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: screenSize.width * 0.04),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: TextStyle(
                                  fontSize: screenSize.width * 0.045,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: screenSize.height * 0.01),
                              Text('Quantity: ${product.quantity}'),
                              SizedBox(height: screenSize.height * 0.005),
                              Text(
                                'Total: ${product.totalPrice.toStringAsFixed(0)}',
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            cartProvider.removeProduct(product);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(screenSize.height * 0.02),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total Price: ${cartProvider.totalPrice.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: screenSize.width * 0.05),
                ),
                const SizedBox(height: 5,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.1 * MediaQuery.of(context).size.width),
                  child: ElevatedButton(
                      onPressed: (){
                        setState(() {
                          isLoading = true;
                        });
                        storeOrderInFirestore(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow.shade200,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      child: isLoading
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              color: Colors.yellow.shade200,
                              height: 20,
                              width: 20,
                              child: const CircularProgressIndicator(color: Colors.black,)),
                          const SizedBox(width: 5,),
                          const Text('Loading',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'roboto',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      )
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Place Order",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'roboto',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      )
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

