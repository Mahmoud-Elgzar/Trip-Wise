// ignore_for_file: use_key_in_widget_constructors

import 'package:demo1/Booking/payment.dart';
import 'package:flutter/material.dart';
import 'package:demo1/Booking/modal/hotel.dart';

class DetailsScreen extends StatefulWidget {
  final Hotel hotel;

  const DetailsScreen({required this.hotel});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // ignore: unused_local_variable
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: screenWidth * (isTablet ? 0.6 : 0.8),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: Offset(0.0, 2.0),
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      child: Hero(
                        tag: widget.hotel.imgurl,
                        child: Image(
                          image: AssetImage(widget.hotel.imgurl),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    Positioned(
                      top: isTablet ? 60 : 50,
                      left: isTablet ? 40 : 30,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: isTablet ? 40 : 30,
                          width: isTablet ? 40 : 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: isTablet ? 20 : 15,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 20 : 10),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32 : 20,
                    vertical: 10,
                  ),
                  child: Text(
                    widget.hotel.title,
                    style: TextStyle(
                      fontSize: isTablet ? 28 : 25,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 20),
                  child: Text(
                    widget.hotel.location,
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                SizedBox(height: isTablet ? 24 : 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 20),
                  child: Text(
                    widget.hotel.description,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: isTablet ? 24 : 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: isTablet ? 16 : 14,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '${widget.hotel.price} Egp',
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reviews',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: isTablet ? 16 : 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  widget.hotel.rating.toString(),
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                    color: const Color(0xff356899),
                                  ),
                                ),
                                Icon(Icons.star,
                                    size: isTablet ? 16 : 12,
                                    color: Colors.amber),
                                Icon(Icons.star,
                                    size: isTablet ? 16 : 12,
                                    color: Colors.amber),
                                Icon(Icons.star,
                                    size: isTablet ? 16 : 12,
                                    color: Colors.amber),
                                Icon(Icons.star_half,
                                    size: isTablet ? 16 : 12,
                                    color: Colors.amber),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recently booked',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: isTablet ? 16 : 14,
                              ),
                            ),
                            SizedBox(height: 10),
                            Stack(
                              children: [
                                SizedBox(
                                  height: isTablet ? 30 : 20,
                                  width: isTablet ? 90 : 70,
                                ),
                                Positioned(
                                  left: isTablet ? 30 : 20,
                                  child: Container(
                                    height: isTablet ? 30 : 20,
                                    width: isTablet ? 30 : 20,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: const Color(0xff356899),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: isTablet ? 45 : 30,
                                  child: Container(
                                    height: isTablet ? 30 : 20,
                                    width: isTablet ? 30 : 20,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: const Color(0xff356899),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: isTablet ? 60 : 40,
                                  child: Container(
                                    height: isTablet ? 30 : 20,
                                    width: isTablet ? 30 : 20,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.yellow,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: isTablet ? 75 : 50,
                                  child: Container(
                                    height: isTablet ? 30 : 20,
                                    width: isTablet ? 30 : 20,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.green,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '+3',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isTablet ? 14 : 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isTablet ? 24 : 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 20),
                  child: Text(
                    'Amenities',
                    style: TextStyle(
                      fontSize: isTablet ? 22 : 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(height: isTablet ? 16 : 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 20),
                  child: GridView.count(
                    crossAxisCount: isTablet ? 6 : 5,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisSpacing: isTablet ? 16 : 8,
                    mainAxisSpacing: isTablet ? 16 : 8,
                    childAspectRatio: 1,
                    children: [
                      _buildAmenityItem(
                        icon: Icons.directions_car,
                        label: 'Parking',
                        isTablet: isTablet,
                      ),
                      _buildAmenityItem(
                        icon: Icons.hot_tub,
                        label: 'Bath',
                        isTablet: isTablet,
                      ),
                      _buildAmenityItem(
                        icon: Icons.pool,
                        label: 'Pool',
                        isTablet: isTablet,
                      ),
                      _buildAmenityItem(
                        icon: Icons.wifi,
                        label: 'WiFi',
                        isTablet: isTablet,
                      ),
                      _buildAmenityItem(
                        icon: Icons.park,
                        label: 'Park',
                        isTablet: isTablet,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isTablet ? 32 : 24),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32 : 20,
                    vertical: 10,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PaymentScreen(),
                          ),
                        );
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 32 : 24,
                          vertical: isTablet ? 14 : 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xff356899), Color(0xff356899)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xff356899),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'Book Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isTablet ? 32 : 24),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenityItem({
    required IconData icon,
    required String label,
    required bool isTablet,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: isTablet ? 50 : 40,
          width: isTablet ? 50 : 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(0.0, 2.0),
                blurRadius: 10.0,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              color: const Color(0xff356899),
              size: isTablet ? 28 : 24,
            ),
          ),
        ),
        SizedBox(height: isTablet ? 8 : 5),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xff356899),
            fontSize: isTablet ? 14 : 12,
          ),
        ),
      ],
    );
  }
}