import 'package:flutter/material.dart';
import 'package:ft_engineering_client/Components/reuseable_widgets.dart';
import 'package:ft_engineering_client/Home/product_class.dart';
import 'package:ft_engineering_client/Utils/utilities.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class ProductDetailScreen extends StatelessWidget {
  Product product;

  ProductDetailScreen({required this.product});

  final TextEditingController _quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: Colors.yellow.shade200,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              product.imageUrl != null
                  ? Image.network(
                      product.imageUrl!,
                      height: 400,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : const Icon(
                      Icons.image_not_supported,
                      size: 100,
                      color: Colors.grey,
                    ),
              const SizedBox(height: 16),
              Text(
                product.name,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                product.description,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Quantity: ${product.quantity} ${product.quantityType}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Price: ${product.price.toStringAsFixed(0)}', // Display price properly
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Quantity',
                ),
              ),
              const SizedBox(height: 16),
              ReuseableButton(
                text: 'Add to Cart',
                onPressed: () {
                  int quantity = int.tryParse(_quantityController.text) ?? 0;
                  if (quantity > 0 && quantity <= product.quantity) {
                    // Handle add to cart logic here
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final cartProvider =
                          Provider.of<CartProvider>(context, listen: false);
                      cartProvider.addProduct(CartProduct(
                        name: product.name,
                        imageUrl: product.imageUrl!,
                        quantity: quantity,
                        price: product.price,
                      ));
                    });
                    Utilities().successMsg("Product added to Cart Successfully");
                  } else {
                    Utilities().errorMsg('Invalid quantity!');
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
