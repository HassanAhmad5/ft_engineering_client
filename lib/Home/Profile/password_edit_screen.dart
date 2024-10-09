import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PasswordEditScreen extends StatefulWidget {
  const PasswordEditScreen({super.key});

  @override
  _PasswordEditScreenState createState() => _PasswordEditScreenState();
}

class _PasswordEditScreenState extends State<PasswordEditScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _newConfirmPasswordController = TextEditingController();

  final oldPasswordFocusNode = FocusNode();
  final newPasswordFocusNode = FocusNode();
  final newConfirmPasswordFocusNode = FocusNode();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  bool _obscuredOldPassword = true;
  bool _obscuredNewPassword = true;
  bool _obscuredNewConfirmPassword = true;

  void _toggleObscuredOldPassword() {
    setState(() {
      _obscuredOldPassword = !_obscuredOldPassword;
    });
  }

  void _toggleObscuredNewPassword() {
    setState(() {
      _obscuredNewPassword = !_obscuredNewPassword;
    });
  }

  void _toggleObscuredNewConfirmPassword() {
    setState(() {
      _obscuredNewConfirmPassword = !_obscuredNewConfirmPassword;
    });
  }

  // Function to re-authenticate the user
  Future<void> _reauthenticateUser(String currentPassword) async {
    User? user = _auth.currentUser;

    if (user != null && user.email != null) {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
    }
  }

  // Function to change the user's password
  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // Re-authenticate the user before changing the password
        await _reauthenticateUser(_oldPasswordController.text);

        // If successful, change the password
        await _auth.currentUser!.updatePassword(_newPasswordController.text);

        setState(() {
          isLoading = false;
        });

        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password successfully updated!')),
        );
        Navigator.of(context).pop();
      } on FirebaseAuthException catch (e) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

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
      body: Center(
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
                        controller: _oldPasswordController,
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                        obscureText: _obscuredOldPassword,
                        focusNode: oldPasswordFocusNode,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.lock,
                            size: 22,
                          ),
                          prefixIconColor: Colors.black,
                          hintText: "Old Password",
                          focusColor: Colors.black,
                          suffixIcon: GestureDetector(
                            onTap: _toggleObscuredOldPassword,
                            child: Icon(
                              _obscuredOldPassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              size: 18,
                            ),
                          ),
                          suffixIconColor: Colors.black,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter Old Password";
                          } else if (value.length < 6) {
                            return "Password must be at least 6 characters.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _newPasswordController,
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                        obscureText: _obscuredNewPassword,
                        focusNode: newPasswordFocusNode,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.lock,
                            size: 22,
                          ),
                          prefixIconColor: Colors.black,
                          hintText: "New Password",
                          focusColor: Colors.black,
                          suffixIcon: GestureDetector(
                            onTap: _toggleObscuredNewPassword,
                            child: Icon(
                              _obscuredNewPassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              size: 18,
                            ),
                          ),
                          suffixIconColor: Colors.black,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter New Password";
                          } else if (value.length < 6) {
                            return "Password must be at least 6 characters.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _newConfirmPasswordController,
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                        obscureText: _obscuredNewConfirmPassword,
                        focusNode: newConfirmPasswordFocusNode,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.lock,
                            size: 22,
                          ),
                          prefixIconColor: Colors.black,
                          hintText: "Confirm New Password",
                          focusColor: Colors.black,
                          suffixIcon: GestureDetector(
                            onTap: _toggleObscuredNewConfirmPassword,
                            child: Icon(
                              _obscuredNewConfirmPassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              size: 18,
                            ),
                          ),
                          suffixIconColor: Colors.black,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter Confirm New Password";
                          } else if (value != _newPasswordController.text) {
                            return "Passwords do not match.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      GestureDetector(
                          onTap: () {
                            if (oldPasswordFocusNode.hasFocus) {
                              oldPasswordFocusNode.unfocus();
                            }
                            if (newPasswordFocusNode.hasFocus) {
                              newPasswordFocusNode.unfocus();
                            }
                            if (newConfirmPasswordFocusNode.hasFocus) {
                              newConfirmPasswordFocusNode.unfocus();
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
                                    _changePassword();
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
                                    Text("Change Password",
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
        ),
      ),
    );
  }
}
