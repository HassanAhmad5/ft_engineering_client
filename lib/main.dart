import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Authentication/login_screen.dart';
import 'Firebase/firebase_options.dart';

import 'Home/product_class.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          // Outline border settings
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.black),
          ),
          // Focused border settings
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.black, width: 2.0), // Color and width for focused border
          ),
          // Label style when unfocused
          labelStyle: const TextStyle(color: Colors.grey),
          // Label style when focused
          floatingLabelStyle: const TextStyle(color: Colors.black),
          // Hint text style
          hintStyle: const TextStyle(color: Colors.grey),
          // Prefix and suffix text style
          prefixStyle: const TextStyle(color: Colors.black),
          suffixStyle: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}

class CartProvider extends ChangeNotifier {
  List<CartProduct> _products = [];

  List<CartProduct> get products => _products;

  void addProduct(CartProduct product) {
    _products.add(product);
    notifyListeners();
  }

  void removeProduct(CartProduct product) {
    _products.remove(product);
    notifyListeners();
  }

  void clearCart() {
    products.clear();
    notifyListeners();
  }

  double get totalPrice =>
      _products.fold(0, (sum, product) => sum + product.totalPrice);
}