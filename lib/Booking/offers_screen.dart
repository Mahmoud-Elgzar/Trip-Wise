import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:demo1/Booking/companies.dart';

class Offer {
  final int? offerId;
  final String offerName;
  final String description;
  final String created;
  final String activeFrom;
  final String activeTo;
  final dynamic timeAccepted;
  final bool isAccepted;
  final TransportCompany? transportCompany;
  final HotelService? hotelService;
  final PromoOffer? promoOffer;
  final Customer? customer;

  Offer({
    this.offerId,
    required this.offerName,
    required this.description,
    required this.created,
    required this.activeFrom,
    required this.activeTo,
    this.timeAccepted,
    required this.isAccepted,
    this.transportCompany,
    this.hotelService,
    this.promoOffer,
    this.customer,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    print('Raw JSON for Offer: $json');
    return Offer(
      offerId: json['offerId'] as int?,
      offerName: json['offerName'] as String? ?? 'No Name',
      description: json['description'] as String? ?? 'No Description',
      created: json['created'] as String? ?? 'No Date',
      activeFrom: json['activeFrom'] as String? ?? 'No Date',
      activeTo: json['activeTo'] as String? ?? 'No Date',
      timeAccepted: json['timeAccepted'],
      isAccepted: json['isAccepted'] as bool? ?? false,
      transportCompany: json['transportCompany'] != null
          ? TransportCompany.fromJson(json['transportCompany'])
          : null,
      hotelService: json['hotelService'] != null
          ? HotelService.fromJson(json['hotelService'])
          : null,
      promoOffer: json['promoOffer'] != null
          ? PromoOffer.fromJson(json['promoOffer'])
          : null,
      customer:
          json['customer'] != null ? Customer.fromJson(json['customer']) : null,
    );
  }
}

class TransportCompany {
  final int? companyId;
  final String companyName;
  final String hqAddress;
  final String description;
  final double? transportServicePrice;

  TransportCompany({
    this.companyId,
    required this.companyName,
    required this.hqAddress,
    required this.description,
    this.transportServicePrice,
  });

  factory TransportCompany.fromJson(Map<String, dynamic> json) {
    return TransportCompany(
      companyId: json['companyId'] as int?,
      companyName: json['companyName'] as String? ?? 'No Name',
      hqAddress: json['hqAddress'] as String? ?? 'No Address',
      description: json['description'] as String? ?? 'No Description',
      transportServicePrice:
          (json['transportServicePrice'] as num?)?.toDouble(),
    );
  }
}

class HotelService {
  final int? hotelId;
  final Hotel? hotel;
  final double? price;
  final double? finalServicePrice;

  HotelService({
    this.hotelId,
    this.hotel,
    this.price,
    this.finalServicePrice,
  });

  factory HotelService.fromJson(Map<String, dynamic> json) {
    return HotelService(
      hotelId: json['hotelId'] as int?,
      hotel: json['hotel'] != null ? Hotel.fromJson(json['hotel']) : null,
      price: (json['price'] as num?)?.toDouble(),
      finalServicePrice: (json['finalServicePrice'] as num?)?.toDouble(),
    );
  }
}

class Hotel {
  final int? hotelId;
  final String hotelName;
  final City? city;

  Hotel({
    this.hotelId,
    required this.hotelName,
    this.city,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      hotelId: json['hotelId'] as int?,
      hotelName: json['hotelName'] as String? ?? 'No Name',
      city: json['city'] != null ? City.fromJson(json['city']) : null,
    );
  }
}

class City {
  final int? cityId;
  final String cityName;
  final Country? country;

  City({
    this.cityId,
    required this.cityName,
    this.country,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      cityId: json['cityId'] as int?,
      cityName: json['cityName'] as String? ?? 'No Name',
      country:
          json['country'] != null ? Country.fromJson(json['country']) : null,
    );
  }
}

class Country {
  final int? countryId;
  final String countryName;

  Country({
    this.countryId,
    required this.countryName,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      countryId: json['countryId'] as int?,
      countryName: json['countryName'] as String? ?? 'No Name',
    );
  }
}

class PromoOffer {
  final int? promoOfferId;
  final String promoName;
  final int? discountPercent;
  final double? finalServicePrice;

  PromoOffer({
    this.promoOfferId,
    required this.promoName,
    this.discountPercent,
    this.finalServicePrice,
  });

  factory PromoOffer.fromJson(Map<String, dynamic> json) {
    return PromoOffer(
      promoOfferId: json['promoOfferId'] as int?,
      promoName: json['promoName'] as String? ?? 'No Name',
      discountPercent: json['discountPercent'] as int?,
      finalServicePrice: (json['finalServicePrice'] as num?)?.toDouble(),
    );
  }
}

class Customer {
  final int? customerId;
  final String firstName;
  final String lastName;
  final String address;
  final String phone;
  final String email;

  Customer({
    this.customerId,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.phone,
    required this.email,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customerId'] as int?,
      firstName: json['firstName'] as String? ?? 'No Name',
      lastName: json['lastName'] as String? ?? 'No Name',
      address: json['address'] as String? ?? 'No Address',
      phone: json['phone'] as String? ?? 'No Phone',
      email: json['email'] as String? ?? 'No Email',
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offers Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class OffersScreen extends StatelessWidget {
  final String token;
  const OffersScreen({super.key, required this.token});

  Future<List<Offer>> fetchOffers() async {
    final response = await http.get(
      Uri.parse('http://tripwiseeeee.runasp.net/api/offers'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'accept': '*/*',
      },
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Offer.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load offers: ${response.statusCode} - ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height; // Added this line
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offers'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey[100],
          padding: EdgeInsets.all(screenWidth * 0.03),
          child: FutureBuilder<List<Offer>>(
            future: fetchOffers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No offers available.'));
              }

              final offers = snapshot.data!;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet ? 2 : 1,
                  crossAxisSpacing: screenWidth * 0.02,
                  mainAxisSpacing: screenWidth * 0.02,
                  childAspectRatio: isTablet ? 0.75 : 1.0,
                ),
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  final offer = offers[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {},
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: screenHeight * 0.15,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.local_offer,
                                size: isTablet ? 50 : 40,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(screenWidth * 0.03),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    offer.offerName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: screenHeight * 0.01),
                                  Flexible(
                                    child: Text(
                                      offer.description,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(color: Colors.grey[600]),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Hotel: \$${offer.hotelService?.finalServicePrice ?? 0.0}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isTablet ? 15 : 12,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                      Text(
                                        'Transport: \$${offer.transportCompany?.transportServicePrice ?? 0.0}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isTablet ? 15 : 12,
                                          color: const Color(0xff356899),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  ElevatedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Booked Successfully'),
                                          backgroundColor: Color(0xff356899),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xff356899),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.01,
                                        horizontal: screenWidth * 0.03,
                                      ),
                                    ),
                                    child: Text(
                                      'Book Now',
                                      style: TextStyle(
                                        fontSize: isTablet ? 14 : 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
