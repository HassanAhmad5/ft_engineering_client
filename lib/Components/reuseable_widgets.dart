import 'package:flutter/material.dart';

import '../Home/product_class.dart';

class ReuseableButton extends StatelessWidget {
  String text;
  final Function() onPressed;
  ReuseableButton({super.key, required this.text, required this.onPressed});


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.1 * MediaQuery.of(context).size.width),
      child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow.shade200,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(text,
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          )
      ),
    );
  }
}

class ReuseableCard extends StatelessWidget {
  final Product product;

  ReuseableCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.network(product.imageUrl!, height: 120, fit: BoxFit.fill),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Rs.${product.price.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green)),
                Text('Quantity: ${product.quantity}', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}