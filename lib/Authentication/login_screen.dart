import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ft_engineering_client/Authentication/forgot_password_screen.dart';
import 'package:ft_engineering_client/Authentication/signup_email_screen.dart';
import 'package:ft_engineering_client/Components/reuseable_widgets.dart';
import 'package:ft_engineering_client/Home/AppBar%20NavBar/appbar_navbar.dart';
import 'package:ft_engineering_client/Home/home_screen.dart';
import '../Utils/utilities.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  bool isLoading = false;

  final _form = GlobalKey<FormState>();

  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  bool _obscured = true;

  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
      if (emailFocusNode.hasPrimaryFocus) {
        return;
      }
      emailFocusNode.canRequestFocus = false;
    });
  }

  bool _isValidEmail(String email) {
    RegExp emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegExp.hasMatch(email);
  }

  bool isEmailValid = false;

  void loginUserEmail(){
    _auth.signInWithEmailAndPassword(email: _emailController.text.toString(), password: _passwordController.text.toString()).then((value) => {
      print("Hello"),
      Utilities().successMsg("Authentication Successful"),
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AppbarNavbar())),
      setState(() {
        isLoading = false;
      })
    }).onError((error, stackTrace) => {
      print(error.toString()),
      setState(() {
        isLoading = false;
      }),
      Utilities().errorMsg('Wrong Credentials')
    });
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
            child: Form(
              key: _form,
              child: Column(
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
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                    obscureText: _obscured,
                    focusNode: passwordFocusNode,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.lock,
                        size: 22,
                      ),
                      prefixIconColor: Colors.black,
                      hintText: "Password",
                      focusColor: Colors.black,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: GestureDetector(
                          onTap: _toggleObscured,
                          child: Icon(
                            _obscured
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            size: 18,
                          ),
                        ),
                      ),
                      suffixIconColor: Colors.black,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter Password";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                    },
                    child: const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (emailFocusNode.hasFocus) {
                        emailFocusNode.unfocus();
                      }
                      if (passwordFocusNode.hasFocus) {
                        passwordFocusNode.unfocus();
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
                                loginUserEmail();
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account?",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to Sign Up Screen
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupEmailScreen()));
                },
                child: const Text(
                  ' Sign Up',
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