import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'homePage.dart';

class TransportCompany {
  final int id;
  final String companyName;
  final String location;
  final bool isActive;

  TransportCompany({
    required this.id,
    required this.companyName,
    required this.location,
    required this.isActive,
  });

  factory TransportCompany.fromJson(Map<String, dynamic> json) {
    return TransportCompany(
      id: json['companyId'],
      companyName: json['companyName'] ?? 'No Name',
      location: json['hqAddress'] ?? 'No Location',
      isActive: json['active'] ?? false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;
  bool rememberMe = false;

  Future<void> login() async {
    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://tripwiseeeee.runasp.net/api/Auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        if (rememberMe) {
          await prefs.setString('remembered_email', emailController.text);
          await prefs.setString('remembered_password', passwordController.text);
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TransportCompaniesScreen(token: token),
          ),
        );
      } else {
        setState(() {
          errorMessage = 'Login failed: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(height: 0),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  Future<void> _loadRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('remembered_email');
    final password = prefs.getString('remembered_password');
    if (email != null && password != null) {
      setState(() {
        rememberMe = true;
        emailController.text = email;
        passwordController.text = password;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                side: BorderSide(
                  color: Colors.blue.shade100,
                  width: 1,
                ),
              ),
              elevation: 8,
              shadowColor: Colors.blueAccent.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.directions_car,
                        size: 80, color: Color(0xff356899)),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome Back',
                      style: theme.textTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff356899),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please login to your account',
                      style: theme.textTheme.titleMedium!
                          .copyWith(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: inputDecoration('Email Address'),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: inputDecoration('Password'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  rememberMe = value ?? false;
                                });
                              },
                              activeColor: const Color(0xff356899),
                            ),
                            const Text(
                              'Remember Me',
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 14),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            // Add Forgot Password navigation
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                                color: Color(0xff356899), fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : login,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 5,
                          backgroundColor: const Color(0xff356899),
                          foregroundColor: Colors.white,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 3),
                              )
                            : const Text('Login',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TransportCompaniesScreen extends StatelessWidget {
  final String token;
  const TransportCompaniesScreen({Key? key, required this.token})
      : super(key: key);

  Future<List<TransportCompany>> fetchTransportCompanies() async {
    final response = await http.get(
      Uri.parse('http://tripwiseeeee.runasp.net/api/TransportCompanies'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'accept': '*/*',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => TransportCompany.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load companies: ${response.statusCode}');
    }
  }

  IconData _getCompanyIcon(int id) {
    // Simple mapping of companyId to unique icons
    switch (id % 5) {
      // Use modulo to cycle through a set of icons
      case 0:
        return Icons.local_taxi;
      case 1:
        return Icons.directions_bus;
      case 2:
        return Icons.airplanemode_active;
      case 3:
        return Icons.directions_railway;
      case 4:
        return Icons.directions_boat;
      default:
        return Icons.store; // Default icon
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Transport Companies'),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: FutureBuilder<List<TransportCompany>>(
        future: fetchTransportCompanies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 40),
                  const SizedBox(height: 10),
                  Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red)),
                  TextButton(
                    onPressed: () {}, // Requires StatefulWidget
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 40),
                  SizedBox(height: 10),
                  Text('No transport companies available.'),
                ],
              ),
            );
          }

          final companies = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            itemCount: companies.length,
            separatorBuilder: (_, __) =>
                const Divider(indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final company = companies[index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: company.isActive
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Icon(
                    _getCompanyIcon(
                        company.id), // Unique icon based on companyId
                    size: 40,
                    color: company.isActive
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                  title: Text(
                    company.companyName,
                    style: theme.textTheme.titleMedium!
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    company.location,
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: Colors.grey.shade700),
                  ),
                  trailing: Text(
                    company.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: company.isActive
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
