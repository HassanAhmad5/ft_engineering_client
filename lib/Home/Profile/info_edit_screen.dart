import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../../Model/postal_area_model.dart';
import '../../Utils/utilities.dart';

class InfoEditScreen extends StatefulWidget {
  const InfoEditScreen({super.key});

  @override
  State<InfoEditScreen> createState() => _InfoEditScreenState();
}

class _InfoEditScreenState extends State<InfoEditScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _shopAddressController = TextEditingController();
  final TextEditingController _dropdownSearchFieldController = TextEditingController();

  LatLng? _shopLocation;

  bool isAreasAvailable = true;
  bool isLoading = false;

  SuggestionsBoxController suggestionBoxController = SuggestionsBoxController();

  List<PostalAreaModel> areas = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getAreas();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        _nameController.text = userData['name'] ?? '';
        _phoneController.text = userData['phone'] ?? '';
        _shopNameController.text = userData['shop_name'] ?? '';
        _shopAddressController.text = userData['shop_address'] ?? '';
        _dropdownSearchFieldController.text = userData['area_name'] ?? '';

        if (userData['shop_location'] != null) {
          _shopLocation = LatLng(userData['shop_location']['latitude'], userData['shop_location']['longitude']);
        }

        setState(() {});
      }
    }
  }

  Future<List<PostalAreaModel>> getAreas() async {
    final response = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/HassanAhmad5/Islamabad_Rawalpindi_Postal_Areas_API/main/Islamabad_Rawalpindi_Postal_Areas.json'));
    var data = jsonDecode(response.body.toString());

    if (response.statusCode == 200) {
      areas.clear();
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

  List<String> getSuggestions(String query) {
    List<String> matches = [];

    if (areas.isEmpty) {
      print("No areas available to search");
      return matches;
    }

    for (var area in areas) {
      if (area.areaName != null && area.areaName!.toLowerCase().contains(query.toLowerCase())) {
        matches.add(area.areaName!);
      }
    }
    return matches;
  }

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
  }

  Future<void> _saveUserDataToFirestore() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'shop_name': _shopNameController.text.trim(),
          'shop_address': _shopAddressController.text.trim(),
          'area_name': _dropdownSearchFieldController.text.trim(),
          'shop_location': {
            'latitude': _shopLocation?.latitude,
            'longitude': _shopLocation?.longitude,
          },
        });

        Utilities().successMsg('Profile Updated Successfully');
        Navigator.pop(context);
      } catch (e) {
        Utilities().errorMsg('Failed to update profile: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.yellow.shade200,
          title: const Text(
            "Ft Engineering",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
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
            const SizedBox(height: 20),
            const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                )),
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
                                      child: const CircularProgressIndicator(color: Colors.black)),
                                  const SizedBox(width: 5),
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
                                  Text("Update Profile",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'roboto',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ],
                              )),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
