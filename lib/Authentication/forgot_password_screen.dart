import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final emailFocusNode = FocusNode();

  bool _isValidEmail(String email) {
    RegExp emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegExp.hasMatch(email);
  }

  bool isLoading = false;

  // Function to send the password reset email
  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
        setState(() {
          isLoading = false;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent.')),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Error occurred')),
        );
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      hintText: "Enter Your Email",
                      focusColor: Colors.black,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter Email";
                      } else if (!_isValidEmail(_emailController.text.toString())) {
                        return "xyz@example.com";
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
                                _resetPassword();
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
                                Text("Reset Password",
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
