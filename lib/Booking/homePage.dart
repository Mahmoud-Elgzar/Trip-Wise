// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:demo1/Booking/hotelPackage.dart';
import 'package:demo1/Booking/modal/hotel.dart' as hotelModal; // أضفنا prefix
import 'package:demo1/Booking/modal/hoteldetails.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'offers_screen.dart' as offers; // أضفنا prefix

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final hotel = hotelModal.Hotel.hotellist(); // استخدمنا hotelModal
  String? token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('auth_token');
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 32.0 : 16.0,
            vertical: 16.0,
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome Back!",
                      style: TextStyle(
                        fontSize: isTablet ? 28 : 22,
                        fontWeight: FontWeight.w300,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Discover Your Perfect Hotel",
                      style: TextStyle(
                        fontSize: isTablet ? 32 : 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
            Text(
              "Most Popular",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 24 : 20,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            SizedBox(
              height: isTablet ? 300 : 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: hotel.length,
                itemBuilder: (context, index) {
                  hotelModal.Hotel hotelscreen =
                      hotel[index]; // استخدمنا hotelModal
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailsScreen(hotel: hotelscreen),
                        ),
                      );
                    },
                    child: Container(
                      width: isTablet ? 220 : 180,
                      margin: EdgeInsets.only(right: 16.0, bottom: 13.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: hotelscreen.imgurl,
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Container(
                                height: isTablet ? 180 : 140,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(hotelscreen.imgurl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hotelscreen.title,
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2),
                                Text(
                                  hotelscreen.location,
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${hotelscreen.price} egp',
                                      style: TextStyle(
                                        fontSize: isTablet ? 16 : 14,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(
                                            0xff356899), // Updated color
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          hotelscreen.rating.toString(),
                                          style: TextStyle(
                                            fontSize: isTablet ? 14 : 12,
                                            color: Colors
                                                .amber, // Gold color for rate
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.star,
                                          color: Colors
                                              .amber, // Gold color for star
                                          size: isTablet ? 16 : 14,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Text(
              "Best Deals",
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            HotelPackage(),
            SizedBox(height: screenHeight * 0.03),
            GestureDetector(
              onTap: () {
                if (token != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          offers.OffersScreen(token: token!), // استخدمنا offers
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please login first!'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Container(
                height: isTablet ? 120 : 100,
                margin: EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xff356899),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Full Packages', // Updated text
                    style: TextStyle(
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 255, 255, 255), // Updated color
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
