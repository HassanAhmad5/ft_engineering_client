import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ft_engineering_client/Home/Profile/email_edit_screen.dart';
import 'package:ft_engineering_client/Home/Profile/info_edit_screen.dart';
import 'package:ft_engineering_client/Home/Profile/password_edit_screen.dart';
import 'package:ft_engineering_client/Utils/utilities.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  Map<String, dynamic>? userDetails;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = true;

  Future<Map<String, dynamic>?> fetchUserDetails(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        // Return the user data
        return userSnapshot.data();
      } else {
        print("User not found.");
        return null;
      }
    } catch (e) {
      print("Error fetching user details: $e");
      return null;
    }
  }

  void getUserDetails(String userId) async {
    userDetails = await fetchUserDetails(userId);

    if (userDetails != null) {
      setState(() {
        isLoading = false;
      });
    } else {
      Utilities().errorMsg("Connection Error");
    }
  }

  @override
  void initState() {
    getUserDetails(_auth.currentUser!.uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? const Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildCard(
              title: 'Email',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmailEditScreen(),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Email text display
                  _buildTextDisplay('Email', userDetails!['email']),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildCard(
              title: 'Password',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PasswordEditScreen(),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Email text display
                  _buildTextDisplay('Password', '********'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildCard(
              title: 'Personal Info',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InfoEditScreen(),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Name text display
                  _buildTextDisplay('Name', userDetails!['name']),
                  const SizedBox(height: 16),
                  // Phone number text display
                  _buildTextDisplay('Phone Number', userDetails!['phone']),
                  const SizedBox(height: 16),
                  // Shop Name text display
                  _buildTextDisplay('Shop Name', userDetails!['shop_name']),
                  const SizedBox(height: 16),
                  // Shop Address text display
                  _buildTextDisplay('Shop Address', userDetails!['shop_address']),
                  const SizedBox(height: 16),
                  // Area dropdown display
                  _buildTextDisplay('Area', userDetails!['area_name']),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }

  // Helper method to build a Text display widget
  Widget _buildTextDisplay(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  // Helper method to build a Card
  Widget _buildCard(
      {required String title, required Function onPressed, Widget? child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    onPressed();
                  },
                ),
              ],
            ),
            if (child != null) child,
          ],
        ),
      ),
    );
  }


}