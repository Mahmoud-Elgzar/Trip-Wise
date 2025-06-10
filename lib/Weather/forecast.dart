import 'package:flutter/material.dart';
import 'package:demo1/weather/api.dart';
import 'package:demo1/weather/weathermodel.dart';

class Forecast extends StatefulWidget {
  const Forecast({super.key});

  @override
  State<Forecast> createState() => _HomePageState();
}

class _HomePageState extends State<Forecast> {
  ApiResponse? response;
  bool inProgress = false;
  String message = "Search for the location to get weather data";

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFE1D7C6),
                Color(0xFF295F98),
              ], // dark to light blue gradient
              /* begin: Alignment.topCenter,
              end: Alignment.bottomCenter,*/
              begin:
                  Alignment(0.9, -0.5), // Adjusted to approximate -137 degrees
              end: Alignment(-0.9, 0.5),
            ),
          ),
          child: Column(
            children: [
              _buildSearchWidget(screenWidth),
              SizedBox(height: screenHeight * 0.03),
              if (inProgress)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                  strokeWidth: 4,
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildWeatherWidget(screenWidth, screenHeight),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchWidget(double screenWidth) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.07),
      ),
      color: Colors.white,
      child: TextField(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.black54),
          hintText: "Search for location...",
          hintStyle: TextStyle(color: Colors.black38),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
        onSubmitted: (value) {
          _getWeatherData(value);
        },
      ),
    );
  }

  Widget _buildWeatherWidget(double screenWidth, double screenHeight) {
    if (response == null) {
      return Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.black54,
            fontSize: screenWidth * 0.05,
          ),
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildCurrentWeatherSection(screenWidth, screenHeight),
          SizedBox(height: screenHeight * 0.03),
          _buildDetailsCard(screenWidth, screenHeight),
          SizedBox(height: screenHeight * 0.03),
          _buildForecastSection(screenWidth), // Added forecast section here
        ],
      );
    }
  }

  Widget _buildCurrentWeatherSection(double screenWidth, double screenHeight) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on,
              size: screenWidth * 0.08,
              color: Colors.blueGrey,
            ),
            SizedBox(width: screenWidth * 0.03),
            Text(
              response?.location?.name ?? "",
              style: TextStyle(
                fontSize: screenWidth * 0.1,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),
        Center(
          child: Column(
            children: [
              Image.network(
                "https:${response?.current?.condition?.icon}"
                    .replaceAll("64x64", "128x128"),
                scale: 0.7,
              ),
              Text(
                "${response?.current?.tempC.toString() ?? ""}°",
                style: TextStyle(
                  fontSize: screenWidth * 0.25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                response?.current?.condition?.text ?? "",
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForecastSection(double screenWidth) {
    return Column(
      children: [
        Text(
          "3-Day Forecast",
          style: TextStyle(
            fontSize: screenWidth * 0.09,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: response?.forecast?.forecastday?.map((day) {
                  return _buildForecastCard(day, screenWidth);
                }).toList() ??
                [],
          ),
        ),
      ],
    );
  }

  Widget _buildForecastCard(ForecastDay day, double screenWidth) {
    return Card(
      color: Colors.white24,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            Text(
              day.date ?? "",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.05,
              ),
            ),
            const SizedBox(height: 10),
            Image.network(
              "https:${day.day?.condition?.icon}",
              scale: 1.5,
            ),
            const SizedBox(height: 10),
            Text(
              "${day.day?.maxtempC?.toString() ?? ""}° / ${day.day?.mintempC?.toString() ?? ""}°",
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.05,
              ),
            ),
            Text(
              day.day?.condition?.text ?? "",
              style: TextStyle(
                color: Colors.white70,
                fontSize: screenWidth * 0.04,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(double screenWidth, double screenHeight) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 6,
      color: Colors.white24,
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _dataAndTitleWidget(
                    "Humidity",
                    "${response?.current?.humidity?.toString() ?? ""}%",
                    screenWidth),
                _dataAndTitleWidget(
                    "Wind",
                    "${response?.current?.windKph?.toString() ?? ""} km/h",
                    screenWidth),
              ],
            ),
            const Divider(color: Colors.white38),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _dataAndTitleWidget("UV Index",
                    response?.current?.uv?.toString() ?? "", screenWidth),
                _dataAndTitleWidget(
                    "Precipitation",
                    "${response?.current?.precipMm?.toString() ?? ""} mm",
                    screenWidth),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dataAndTitleWidget(String title, String data, double screenWidth) {
    return Column(
      children: [
        Text(
          data,
          style: TextStyle(
            fontSize: screenWidth * 0.06,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: screenWidth * 0.04,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  _getWeatherData(String location) async {
    setState(() {
      inProgress = true;
      message = "Fetching weather data...";
    });

    try {
      // Call the new getForecastWeather method for 5-day data
      response = await WeatherApi().getForecastWeather(location, days: 5);
      if (response == null || response?.current == null) {
        setState(() {
          message = "Weather data not available for this location.";
        });
      } else {
        setState(() {
          message = ""; // Clear the message if data is received
        });
      }
    } catch (e) {
      setState(() {
        message = "Failed to get weather data: $e"; // Log the specific error
        response = null;
      });
    } finally {
      setState(() {
        inProgress = false;
      });
    }
  }
}
