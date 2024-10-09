import 'dart:convert';

import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ft_engineering_client/Components/reuseable_widgets.dart';
import 'package:ft_engineering_client/Home/AppBar%20NavBar/appbar_navbar.dart';
import 'package:ft_engineering_client/Home/home_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ft_engineering_client/Utils/utilities.dart';
import 'package:http/http.dart' as http;

import '../Model/postal_area_model.dart';

class SignupDetailsScreen extends StatefulWidget {
  const SignupDetailsScreen({super.key});

  @override
  State<SignupDetailsScreen> createState() => _SignupDetailsScreenState();
}

class _SignupDetailsScreenState extends State<SignupDetailsScreen> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _shopAddressController = TextEditingController();
  LatLng? _shopLocation;

  final TextEditingController _dropdownSearchFieldController = TextEditingController();

  bool isAreasAvailable = true;
  bool isLoading = false;

  SuggestionsBoxController suggestionBoxController = SuggestionsBoxController();

  String? _selectedFruit;

  List<PostalAreaModel> areas = [];

  Future<List<PostalAreaModel>> getAreas() async {
    final response = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/HassanAhmad5/Islamabad_Rawalpindi_Postal_Areas_API/main/Islamabad_Rawalpindi_Postal_Areas.json'));
    var data = jsonDecode(response.body.toString());

    if (response.statusCode == 200) {
      areas.clear(); // Clear previous data if any
      for (var item in data) {
        areas.add(PostalAreaModel.fromJson(item));
      }
      setState(() {
        isAreasAvailable = false;
      });
      return areas;
    } else {
      print("Error in API");
      return areas;
    }
  }

  // Suggestions based on user query
  List<String> getSuggestions(String query) {
    List<String> matches = [];

    // Ensure data is not empty
    if (areas.isEmpty) {
      print("No areas available to search");
      return matches;
    }

    // Filter areas based on query
    for (var area in areas) {
      if (area.areaName != null &&
          area.areaName!.toLowerCase().contains(query.toLowerCase())) {
        matches.add(area.areaName!);
      }
    }
    return matches;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      Utilities().errorMsg('Location permission denied');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _shopLocation = LatLng(position.latitude, position.longitude);
    });

    print('Location Set: ${_shopLocation!.latitude}, ${_shopLocation!.longitude}');
  }

  Future<void> _saveUserDataToFirestore() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        await _firestore.collection('users').doc(currentUser.uid).set({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'shop_name': _shopNameController.text.trim(),
          'shop_address': _shopAddressController.text.trim(),
          'area_name': _dropdownSearchFieldController.text.trim(),
          'shop_location': {
            'latitude': _shopLocation?.latitude,
            'longitude': _shopLocation?.longitude,
          },
          'email': currentUser.email, // If email was used for signup
          'uid': currentUser.uid,
        });

        Utilities().successMsg('Profile Created Successfully');
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AppbarNavbar()));
      } catch (e) {
        Utilities().errorMsg('Failed to create profile: $e');
      }
    } else {
      Utilities().errorMsg('No user found');
    }
  }

  @override
  void initState() {
    getAreas();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isAreasAvailable
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.jpeg',
            width: 150,
            height: 150,
            fit: BoxFit.fill,
          ),
          const SizedBox(height: 20,),
          const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              )
          ),
        ],
      )
          : Center(
            child: SingleChildScrollView(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.jpeg',
                width: 150,
                height: 150,
                fit: BoxFit.fill,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Enter Name'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Enter Name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Phone Number'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Enter Phone Number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _shopNameController,
                        decoration: const InputDecoration(labelText: 'Shop Name'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Enter Shop Name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropDownSearchFormField(
                        textFieldConfiguration: TextFieldConfiguration(
                          decoration: const InputDecoration(labelText: 'Area Name'),
                          controller: _dropdownSearchFieldController,
                        ),
                        suggestionsCallback: (pattern) {
                          return getSuggestions(pattern);
                        },
                        itemBuilder: (context, String suggestion) {
                          return ListTile(
                            tileColor: Colors.white,
                            title: Text(suggestion),
                          );
                        },
                        transitionBuilder: (context, suggestionsBox, controller) {
                          return suggestionsBox;
                        },
                        onSuggestionSelected: (String suggestion) {
                          _dropdownSearchFieldController.text = suggestion;
                        },
                        suggestionsBoxController: suggestionBoxController,
                        validator: (value) => value!.isEmpty ? 'Please select an area' : null,
                        onSaved: (value) => _selectedFruit = value,
                        displayAllSuggestionWhenTap: true,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _shopAddressController,
                        decoration: const InputDecoration(labelText: 'Shop Address'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Enter Shop Address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 0.1 * MediaQuery.of(context).size.width),
                        child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });
                                await _getCurrentLocation();
                                if (_shopLocation != null) {
                                  await _saveUserDataToFirestore();
                                } else {
                                  Utilities().errorMsg('Location is required');
                                }
                              }
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
                                Text("Create Profile",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'roboto',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ],
                            )
                        ),
                      ),
                      const SizedBox(height: 20), // Extra padding at the bottom
                    ],
                  ),
                ),
              ),
            ],
          ),
            ),
          )
    );
  }
}
