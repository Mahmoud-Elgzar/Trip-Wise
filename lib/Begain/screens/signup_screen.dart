import 'package:demo1/HomePage/homepage.dart';
import 'package:flutter/material.dart';
import 'package:demo1/Begain/screens/signin_screen.dart';
import 'package:demo1/Begain/widgets/custom_scaffold.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _detailsController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('http://tripwiseeeee.runasp.net/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'phone': _phoneController.text,
          'mobile': _mobileController.text,
          'address': _addressController.text,
          'details': _detailsController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] as String?;

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Registration failed: No token received')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${response.body}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return CustomScaffold(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(
            screenWidth * 0.05,
            screenHeight * 0.08,
            screenWidth * 0.05,
            screenHeight * 0.03,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  Text(
                    'Sign Up',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                          fontSize: isTablet ? 32 : 24,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // First Name Field
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isTablet ? 15 : 10),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Last Name Field
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isTablet ? 15 : 10),
                      ),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isTablet ? 15 : 10),
                      ),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isTablet ? 15 : 10),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      } else if (value.length < 6) {
                        return 'Password should be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isTablet ? 15 : 10),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      } else if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Phone Field
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isTablet ? 15 : 10),
                      ),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(value)) {
                          return 'Please enter a valid phone number';
                        }
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Mobile Field
                  TextFormField(
                    controller: _mobileController,
                    decoration: InputDecoration(
                      labelText: 'Mobile',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isTablet ? 15 : 10),
                      ),
                      prefixIcon: const Icon(Icons.phone_android),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(value)) {
                          return 'Please enter a valid mobile number';
                        }
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Address Field
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isTablet ? 15 : 10),
                      ),
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (value.length < 5) {
                          return 'Address should be at least 5 characters';
                        }
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Details Field
                  TextFormField(
                    controller: _detailsController,
                    decoration: InputDecoration(
                      labelText: 'Details',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isTablet ? 15 : 10),
                      ),
                      prefixIcon: const Icon(Icons.notes),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (value.length < 5) {
                          return 'Details should be at least 5 characters';
                        }
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * 0.04),

                  // Sign Up Button
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff356899),
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                        horizontal: screenWidth * 0.1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isTablet ? 15 : 10),
                      ),
                    ),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                          fontSize: isTablet ? 20 : 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(fontSize: isTablet ? 16 : 14),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (e) => const SigninScreen()));
                        },
                        child: Text(
                          "sign in here",
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
