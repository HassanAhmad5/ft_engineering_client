import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailEditScreen extends StatefulWidget {
  @override
  _EmailEditScreenState createState() => _EmailEditScreenState();
}

class _EmailEditScreenState extends State<EmailEditScreen> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool isLoading = false;

  final emailFocusNode = FocusNode();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _updateEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // Get the current user
        User? currentUser = _auth.currentUser;

        if (currentUser != null) {
          // Send the verification email before updating the email
          await currentUser.verifyBeforeUpdateEmail(_emailController.text);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Verification email sent! Please verify your new email to complete the update.',
                style: TextStyle(color: Colors.green),
              ),
            ),
          );

          // Continuously check if the email is verified
          bool emailVerified = false;
          while (!emailVerified) {
            await Future.delayed(const Duration(seconds: 3)); // Poll every 3 seconds

            // Reload user to get updated information
            await currentUser?.reload();
            currentUser = _auth.currentUser; // Refresh the user object

            if (currentUser != null && currentUser.emailVerified) {
              emailVerified = true;

              // Once verified, update email in Firestore
              await _firestore.collection('users').doc(currentUser.uid).update({
                'email': _emailController.text,
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Email verified and updated successfully!',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              );

              // Break the loop once email is verified and Firestore is updated
              break;
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No user is currently logged in!',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        // Handle specific FirebaseAuth errors
        String errorMessage = '';

        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'The email address is already in use by another account.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          case 'requires-recent-login':
            errorMessage =
            'You need to re-authenticate before updating the email. Please log in again.';
            break;
          default:
            errorMessage = 'An error occurred: ${e.message}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );
      } catch (e) {
        // Catch any other exceptions
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Something went wrong: ${e.toString()}',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  bool _isValidEmail(String email) {
    RegExp emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegExp.hasMatch(email);
  }

  bool isEmailValid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade200,
        title: const Text("Ft Engineering", style: TextStyle(
            fontWeight: FontWeight.bold
        ),),
        centerTitle: true,
      ),
      body: Column(
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _emailController,
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                    focusNode: emailFocusNode,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.email,
                        size: 22,
                      ),
                      prefixIconColor: Colors.black,
                      hintText: "New Email",
                      focusColor: Colors.black,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter Email";
                      } else if (!_isValidEmail(_emailController.text.toString())) {
                        return "xyz@example.com";
                      }
                      if (_isValidEmail(_emailController.text.toString())) {
                        setState(() {
                          isEmailValid = true;
                        });
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                      onTap: () {
                        if (emailFocusNode.hasFocus) {
                          emailFocusNode.unfocus();
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 0.1 * MediaQuery.of(context).size.width),
                        child: ElevatedButton(
                            onPressed: (){
                              if(_formKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });
                                _updateEmail();
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
                                Text("Update Email",
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
