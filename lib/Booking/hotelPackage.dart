// ignore_for_file: file_names, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:demo1/Booking/modal/hotel.dart';
import 'package:demo1/Booking/modal/hoteldetails.dart';

class HotelPackage extends StatelessWidget {
  final hotel = Hotel.PeoplechoiceList();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return SizedBox(
      height: isTablet ? 350 : 300,
      width: double.infinity,
      child: ListView.separated(
        separatorBuilder: (_, index) => SizedBox(height: isTablet ? 16 : 10),
        itemCount: hotel.length,
        itemBuilder: (context, index) {
          Hotel hotelscreen = hotel[index];
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16.0 : 10.0,
              vertical: 5.0,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailsScreen(hotel: hotelscreen),
                  ),
                );
              },
              child: Container(
                height: isTablet ? 180 : 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      offset: Offset(0.0, 4.0),
                      blurRadius: 8.0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      child: Hero(
                        tag: hotelscreen.imgurl,
                        child: ClipRRect(
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(16),
                          ),
                          child: Container(
                            height: isTablet ? 180 : 150,
                            width: isTablet ? 150 : 120,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(hotelscreen.imgurl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: isTablet ? 20 : 15,
                      left: isTablet ? 160 : 130,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hotelscreen.title,
                            style: TextStyle(
                              fontSize: isTablet ? 20 : 18,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            hotelscreen.location,
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${hotelscreen.price} Egp per night',
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff356899),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: isTablet ? 12 : 10),
                            child: Row(
                              children: [
                                Icon(Icons.directions_car,
                                    color: const Color(0xff356899),
                                    size: isTablet ? 24 : 20),
                                SizedBox(width: 8),
                                Icon(Icons.hot_tub,
                                    color: const Color(0xff356899),
                                    size: isTablet ? 24 : 20),
                                SizedBox(width: 8),
                                Icon(Icons.local_bar,
                                    color: const Color(0xff356899),
                                    size: isTablet ? 24 : 20),
                                SizedBox(width: 8),
                                Icon(Icons.wifi,
                                    color: const Color(0xff356899),
                                    size: isTablet ? 24 : 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: isTablet ? 20 : 15,
                      right: isTablet ? 20 : 15,
                      child: GestureDetector(
                        onTap: () {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: Text(
                                "Confirmation",
                                style: TextStyle(
                                  fontSize: isTablet ? 20 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Text(
                                "Hotel booked at ${hotelscreen.title}",
                                style: TextStyle(
                                  fontSize: isTablet ? 16 : 14,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, 'ok'),
                                  child: Text(
                                    'OK',
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                      color: const Color(0xff356899),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 20 : 16,
                            vertical: isTablet ? 10 : 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xff356899), Color(0xff356899)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color:  Color(0xff356899),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            'Book Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 16 : 14,
                              fontWeight: FontWeight.w600,
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
        },
      ),
    );
  }
}
