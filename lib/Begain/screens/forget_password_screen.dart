import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isResetStep = false; // Toggle between forget and reset steps

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForgetRequest() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('http://tripwiseeeee.runasp.net/api/Auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailController.text}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Password reset link sent! Proceed to reset.')),
        );
        setState(() {
          _isResetStep = true; // Move to reset step
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to send reset link: ${response.body}')),
        );
      }
    }
  }

  Future<void> _submitResetRequest() async {
    if (_formKey.currentState!.validate()) {
      // Placeholder token for testing (replace with real token from email/deep link in production)
      const String placeholderToken = 'test-token-123';
      final response = await http.post(
        Uri.parse('http://tripwiseeeee.runasp.net/api/Auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'token': placeholderToken, // Temporary placeholder
          'newPassword': _newPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successful!')),
        );
        Navigator.pop(context); // Return to sign-in screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset successful!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.03,
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight * 0.7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isResetStep ? 'Reset Your Password' : 'Reset Your Password',
                  style: TextStyle(
                    fontSize: isTablet ? 28 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  _isResetStep
                      ? 'Enter your new password below.'
                      : 'Enter your email address below to receive a password reset link.',
                  style: TextStyle(fontSize: isTablet ? 18 : 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.04),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (!_isResetStep)
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(isTablet ? 15 : 10),
                            ),
                            prefixIcon: const Icon(Icons.email),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                      if (_isResetStep)
                        TextFormField(
                          controller: _newPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(isTablet ? 15 : 10),
                            ),
                            prefixIcon: const Icon(Icons.lock_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a new password';
                            } else if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                ElevatedButton(
                  onPressed:
                      _isResetStep ? _submitResetRequest : _submitForgetRequest,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.1,
                    ),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isTablet ? 15 : 10),
                    ),
                    backgroundColor: const Color(0xff356899),
                  ),
                  child: Text(
                    _isResetStep ? 'Reset Password' : 'Send Reset Link',
                    style: TextStyle(
                        fontSize: isTablet ? 20 : 18, color: Colors.white),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Back to sign in',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
