import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utility/router.dart' as route;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  bool _isObscure = true;
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repassController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  int counterValue = 0;
  final _formKey = GlobalKey<FormState>();

  void _incrementCounterValue() {
    setState(() {
      counterValue++;
    });
  }

  Future<void> _updatePoints(int newPoints) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDocRef =
          FirebaseFirestore.instance.collection('Users').doc(user.uid);
      await userDocRef.set({'points': newPoints}, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/abstract_background.jpg'),
                    fit: BoxFit.cover),
              ),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(12),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Register',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        _buildFormField(
                          controller: firstnameController,
                          hintText: 'First Name',
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your first name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        _buildFormField(
                          controller: lastnameController,
                          hintText: 'Last Name',
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your last name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        _buildFormField(
                          controller: emailController,
                          hintText: 'E-mail',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your E-Mail';
                            }
                            if (!value.contains('@')) {
                              return 'Invalid email format';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        _buildFormField(
                          controller: numberController,
                          hintText: 'Phone number',
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        _buildPasswordField(
                          controller: passwordController,
                          hintText: 'Password',
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a new password';
                            }
                            if (value.length < 6) {
                              return 'Password should be at least 6 characters long';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        _buildPasswordField(
                          controller: repassController,
                          hintText: 'Re-Enter Password',
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please re-enter your password';
                            }
                            if (value != passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        _buildFormField(
                          controller: usernameController,
                          hintText: 'Username',
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a username';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        _buildSubmitButton(),
                        const SizedBox(
                          height: 20,
                        ),
                        _buildBackButton(),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  TextFormField _buildFormField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      style: const TextStyle(color: Colors.black),
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding:
            const EdgeInsets.only(left: 14, bottom: 8, top: 8, right: 14),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  TextFormField _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      style: const TextStyle(color: Colors.black),
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding:
            const EdgeInsets.only(left: 14, bottom: 8, top: 15, right: 14),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isObscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.black,
          ),
          onPressed: () {
            setState(() {
              _isObscure = !_isObscure;
            });
          },
        ),
      ),
      validator: validator,
      obscureText: _isObscure,
    );
  }

  Widget _buildSubmitButton() {
    return MaterialButton(
      onPressed: () {
        _register(
          emailController.text,
          passwordController.text,
        );
      },
      color: Colors.orangeAccent[700],
      minWidth: 200,
      height: 50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: const Text(
        'Register',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return MaterialButton(
      onPressed: () {
        Navigator.pushReplacementNamed(context, route.loginPage);
      },
      color: Colors.orangeAccent[700],
      minWidth: 200,
      height: 50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: const Text(
        'Go back',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _register(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      try {
        final authResult = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        final user = authResult.user;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .set({
            'fname': firstnameController.text,
            'lname': lastnameController.text,
            'email': emailController.text,
            'phone': numberController.text,
            'username': usernameController.text,
            'points': 0, // Set the 'points' field to 0 for new users
          });
          // Increment the counter when a new user is registered and update points
          _incrementCounterValue();
          await _updatePoints(counterValue);
          _navigateToLoginPage();
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          _showErrorDialog('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          _showErrorDialog(
              'The email address is already in use by another account.');
        } else {
          _showErrorDialog(
              'An error occurred while registering. Please try again later.');
        }
      } catch (e) {
        _showErrorDialog(
            'An error occurred while registering. Please try again later.');
      }
    }
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(errorMessage),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToLoginPage() {
    Navigator.pushReplacementNamed(context, route.loginPage);
  }
}
