import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ft_engineering_client/Authentication/login_screen.dart';
import 'package:ft_engineering_client/Authentication/signup_details_screen.dart';
import 'package:ft_engineering_client/Utils/utilities.dart';
import '../Components/reuseable_widgets.dart';

class SignupEmailScreen extends StatefulWidget {
  const SignupEmailScreen({super.key});

  @override
  State<SignupEmailScreen> createState() => _SignupEmailScreenState();
}

class _SignupEmailScreenState extends State<SignupEmailScreen> {
  final _form = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  bool _obscuredPassword = true;
  bool _obscuredConfirmPassword = true;
  bool isEmailValid = false;

  FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;

  void _toggleObscuredPassword() {
    setState(() {
      _obscuredPassword = !_obscuredPassword;
    });
  }

  void _toggleObscuredConfirmPassword() {
    setState(() {
      _obscuredConfirmPassword = !_obscuredConfirmPassword;
    });
  }

  bool _isValidEmail(String email) {
    RegExp emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegExp.hasMatch(email);
  }

  Future<void> _signupWithEmailPassword() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        Utilities().successMsg('Registration Successful');
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupDetailsScreen()));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for this email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email format.';
      } else {
        errorMessage = e.message ?? 'Registration failed.';
      }
      Utilities().errorMsg(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            child: SingleChildScrollView(
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                        hintText: "Email",
                        focusColor: Colors.black,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Email";
                        } else if (!_isValidEmail(value)) {
                          return "xyz@example.com";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                      obscureText: _obscuredPassword,
                      focusNode: passwordFocusNode,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock,
                          size: 22,
                        ),
                        prefixIconColor: Colors.black,
                        hintText: "Password",
                        focusColor: Colors.black,
                        suffixIcon: GestureDetector(
                          onTap: _toggleObscuredPassword,
                          child: Icon(
                            _obscuredPassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            size: 18,
                          ),
                        ),
                        suffixIconColor: Colors.black,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Password";
                        } else if (value.length < 6) {
                          return "Password must be at least 6 characters.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                      obscureText: _obscuredConfirmPassword,
                      focusNode: confirmPasswordFocusNode,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock,
                          size: 22,
                        ),
                        prefixIconColor: Colors.black,
                        hintText: "Confirm Password",
                        focusColor: Colors.black,
                        suffixIcon: GestureDetector(
                          onTap: _toggleObscuredConfirmPassword,
                          child: Icon(
                            _obscuredConfirmPassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            size: 18,
                          ),
                        ),
                        suffixIconColor: Colors.black,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Confirm Password";
                        } else if (value != _passwordController.text) {
                          return "Passwords do not match.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        if (emailFocusNode.hasFocus) {
                          emailFocusNode.unfocus();
                        }
                        if (passwordFocusNode.hasFocus) {
                          passwordFocusNode.unfocus();
                        }
                        if (confirmPasswordFocusNode.hasFocus) {
                          confirmPasswordFocusNode.unfocus();
                        }
                      },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0.1 * MediaQuery.of(context).size.width),
                          child: ElevatedButton(
                              onPressed: (){
                                if(_form.currentState!.validate()) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  _signupWithEmailPassword();
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
                                  : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Login",
                                      style: const TextStyle(
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
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Already have an account?",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to Sign Up Screen
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                },
                child: const Text(
                  ' Login',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
