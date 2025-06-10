// ignore_for_file: camel_case_types

import 'package:demo1/Begain/screens/forget_password_screen.dart';
import 'package:demo1/HomePage/homepage.dart';
import 'package:flutter/material.dart';
//import 'package:demo1/Begain/screens/forget_password_screen.dart';
import 'package:demo1/Begain/screens/signup_screen.dart';
import 'package:demo1/Begain/theme/theme.dart';
import 'package:demo1/Begain/widgets/custom_scaffold.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  bool rememberPassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_formSignInKey.currentState!.validate() && rememberPassword) {
      final response = await http.post(
        Uri.parse('http://tripwiseeeee.runasp.net/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
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
            const SnackBar(content: Text('Login failed: No token received')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${response.body}')),
        );
      }
    } else if (!rememberPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the terms')),
      );
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    try {
      String? token;
      if (provider == 'google') {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) return; // User canceled the sign-in
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        token = googleAuth.idToken;
      } else if (provider == 'facebook') {
        final LoginResult result = await FacebookAuth.instance.login();
        if (result.status == LoginStatus.success &&
            result.accessToken != null) {
          token = result.accessToken!.tokenString; // Updated to tokenString
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Facebook login failed')),
          );
          return;
        }
      }

      if (token != null) {
        final response = await http.post(
          Uri.parse('http://tripwiseeeee.runasp.net/api/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'provider': provider,
            'token': token,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final authToken = data['token'] as String?;
          if (authToken != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('auth_token', authToken);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Social login failed: No token received')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Social login failed: ${response.body}')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during social login: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formSignInKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        const Text(
                          'Hi,\nPlease log in',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            label: const Text('Email'),
                            hintText: 'Enter your email',
                            prefixIcon:
                                const Icon(Icons.email, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            label: const Text('Password'),
                            hintText: 'Enter your password',
                            prefixIcon:
                                const Icon(Icons.lock, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: rememberPassword,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      rememberPassword = value!;
                                    });
                                  },
                                  activeColor: lightColorScheme.primary,
                                ),
                                const Text(
                                  'Remember me',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (e) =>
                                        const ForgetPasswordScreen(),
                                  ),
                                );
                              },
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (e) =>
                                          const ForgetPasswordScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff356899),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Log In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 0.7,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "log in with",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 0.7,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        /*  Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Logo(logos.facebook,
                                onTap: () => _handleSocialLogin('facebook')),
                            Logo(logos.google,
                                onTap: () => _handleSocialLogin('google')),
                          ],
                        ),*/
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (e) => const SignupScreen(),
                                  ),
                                );
                              },
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (e) => const SignupScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  ' Sign up',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.blue,
                                  ),
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
          ),
        ],
      ),
    );
  }
}

enum logos { facebook, google }

class Logo extends StatelessWidget {
  final logos logoType;
  final VoidCallback? onTap;

  const Logo(this.logoType, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    switch (logoType) {
      case logos.facebook:
        iconData = Icons.facebook;
        break;
      case logos.google:
        iconData = Icons.g_mobiledata;
        break;
    }

    return IconButton(
      icon: Icon(iconData, size: 30),
      onPressed: onTap,
    );
  }
}
