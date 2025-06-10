// ignore_for_file: library_private_types_in_public_api, unnecessary_to_list_in_spreads, deprecated_member_use

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedPaymentMethod = 1;

  final List<Map<String, dynamic>> paymentMethods = [
    {
      'name': 'Vodafone Cash',
      'value': 1,
      'imagePath': 'assets/images/vodafone cash.png',
    },
    {
      'name': 'InstaPay',
      'value': 2,
      'imagePath': 'assets/images/insta.png',
    },
    {
      'name': 'Cash',
      'value': 3,
      'imagePath': 'assets/images/COD.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 251, 251, 251), // White background
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.08),
          child: Column(
            children: [
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: Text(
                  'Choose Payment Method',
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF333333), // Dark gray for consistency
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              SizedBox(height: screenHeight * 0.02),
              ...paymentMethods.asMap().entries.map((entry) {
                int index = entry.key;
                final method = entry.value;
                return ListTile(
                  leading: Radio<int>(
                    value: method['value'],
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value!;
                      });
                    },
                  ),
                  title: Row(
                    children: [
                      Image.asset(
                        method['imagePath'],
                        width: screenWidth * 0.12,
                        height: screenWidth * 0.12,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.broken_image,
                            size: screenWidth * 0.12,
                            color: const Color(0xFF888888),
                          );
                        },
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Expanded(
                        child: Text(
                          method['name'],
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: const Color(
                                0xFF333333), // Dark gray for consistency
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                ).animate().slideY(
                      begin: 0.5,
                      end: 0.0,
                      delay: Duration(milliseconds: 200 * (index + 1)),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeInOutCubic,
                    );
              }).toList(),
              SizedBox(height: screenHeight * 0.02),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 800),
                child: GestureDetector(
                  onTap: () {
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text(
                          'Confirm reservation',
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        content: Text(
                          'Your reservation has been confirmed successfully.',
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.04,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'ok'),
                            child: Text(
                              'Ok',
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.04,
                                color: const Color(0xFF356899),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    width: screenWidth * 0.9,
                    padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                        horizontal: screenWidth * 0.04),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff356899), Color(0xff356899)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'تأكيد الدفع',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
