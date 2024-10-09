import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ft_engineering_client/Home/cart_screen.dart';
import 'package:ft_engineering_client/Home/Order%20Tracking/order_tracking_screen.dart';
import 'package:ft_engineering_client/Home/Profile/profile_screen.dart';

import '../home_screen.dart';

class AppbarNavbar extends StatefulWidget {
  const AppbarNavbar({super.key});

  @override
  State<AppbarNavbar> createState() => _AppbarNavbarState();
}

class _AppbarNavbarState extends State<AppbarNavbar> {

  late List<Widget> _pages;

  void _initializePages() {
    _pages = [
      const HomeScreenController(),
      const CartScreenController(),
      const OrderTrackingScreenController(),
      const ProfileScreenController(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  int _currentIndex = 0;

  @override
  void initState() {
    _initializePages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade200,
        title: const Text("Ft Engineering", style: TextStyle(
            fontWeight: FontWeight.bold
        ),),
        leading: const SizedBox(),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert), // Three vertical dots icon
            onSelected: (value) {
              if (value == 0) {
                FirebaseAuth.instance.signOut().then((value) {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<int>(
                value: 0,
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: SizedBox(
        height: 60,
        child: Container(
          color: Colors.yellow.shade200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildNavItem(Icons.home, 'Home', 0),
              buildNavItem(Icons.shopping_cart, 'Cart', 1),
              buildNavItem(Icons.check_box, 'Order Tracking', 2),
              buildNavItem(Icons.person, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }
  Widget buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: _currentIndex == index ? Colors.blue : Colors.black, size: 25),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _currentIndex == index ? Colors.blue : Colors.black,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreenController extends StatelessWidget {
  const HomeScreenController({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeScreen();
  }
}

class CartScreenController extends StatelessWidget {
  const CartScreenController({super.key});

  @override
  Widget build(BuildContext context) {
    return CartScreen();
  }
}

class OrderTrackingScreenController extends StatelessWidget {
  const OrderTrackingScreenController({super.key});

  @override
  Widget build(BuildContext context) {
    return const OrderTrackingScreen();
  }
}

class ProfileScreenController extends StatelessWidget {
  const ProfileScreenController({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}






