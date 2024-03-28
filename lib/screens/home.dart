import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prospection_app/widgets/animate.dart';
import 'package:prospection_app/widgets/indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<Home> {
  late Map<String, dynamic> decodedResponse = {};
  late Position currentPosition;
  String _address = '';

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _insertLocation() async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('user_id');
    var userStructure = prefs.getInt('user_structure');
    currentPosition = await _getCurrentPosition();

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        currentPosition.latitude,
        currentPosition.longitude,
      );
      Placemark placemark = placemarks[0];
      setState(() {
        _address =
            '${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.country}';
      });
      await http.post(
        Uri.parse('https://prospection.vibecro-corp.tech/api/location'),
        body: {
          'user_structure': userStructure.toString(),
          'user': userId.toString(),
          'latitude': currentPosition.latitude.toString(),
          'longitude': currentPosition.longitude.toString(),
          'address': _address,
        },
      );
      print(userStructure.toString());
    } catch (e) {
      setState(() {
        _address = 'Adresse non trouvée';
        print(e);
      });
    }
  }

  Future<void> fetchDataCount() async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('user_id');
    final response = await http.get(
      Uri.parse('https://prospection.vibecro-corp.tech/api/home/$userId'),
    );
    try {
      setState(() {
        decodedResponse = jsonDecode(response.body);
      });
    } catch (e) {
      var snackBar = SnackBar(
        content: Text(e.toString()),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDataCount();
    _insertLocation();
  }

  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return decodedResponse.isEmpty
        ? const Center(
            child: AnimatedImage(),
          )
        : Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(150.0),
              child: RoundedBottomAppBar(
                appBarColor: Colors.orange,
                appBarHeight: 150.0,
                structure: decodedResponse['structure'],
              ),
            ),
            body: Column(
              children: [
                const SizedBox(height: 20.0),
                const Text(
                  'Statistiques des prospects',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        sectionsSpace: 0,
                        centerSpaceRadius: 40,
                        sections: showingSections(
                          touchedIndex,
                          decodedResponse['prospects'],
                          decodedResponse['prospectsYes'],
                          decodedResponse['prospectsNo'],
                          decodedResponse['prospectsInd'],
                        ),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Indicator(
                        color: Colors.green,
                        text: 'Oui',
                        isSquare: true,
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Indicator(
                        color: Colors.red,
                        text: 'Non',
                        isSquare: true,
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Indicator(
                        color: Colors.grey,
                        text: 'Indécis',
                        isSquare: true,
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      SizedBox(
                        height: 18,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(20.0),
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Column(
                      children: <Widget>[
                        Text(
                          'Informations',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          "Aucune information à afficher",
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}

List<PieChartSectionData> showingSections(
  touchedIndex,
  prospects,
  prospectYes,
  prospectNo,
  prospectIndecis,
) {
  return List.generate(3, (i) {
    final isTouched = i == touchedIndex;
    final fontSize = isTouched ? 25.0 : 16.0;
    final radius = isTouched ? 60.0 : 50.0;
    const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
    if (prospectYes == 0 && prospectNo == 0 && prospectIndecis == 0) {
      return PieChartSectionData(
        color: Colors.grey,
        value: 100,
        title: '0%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    } else {
      var prospectYespercent = double.parse(
        ((prospectYes.toDouble() * 100) / prospects).toStringAsFixed(1),
      );
      var prospectNopercent = double.parse(
        ((prospectNo.toDouble() * 100) / prospects).toStringAsFixed(1),
      );
      var prospectIndecispercent = double.parse(
        ((prospectIndecis.toDouble() * 100) / prospects).toStringAsFixed(1),
      );
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.green,
            value: prospectYespercent,
            title: '$prospectYespercent%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.red,
            value: prospectNopercent,
            title: '$prospectNopercent%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: Colors.grey,
            value: prospectIndecispercent,
            title: '$prospectIndecispercent%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        default:
          throw Error();
      }
    }
  });
}

class RoundedBottomAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final double appBarHeight;
  final Color appBarColor;
  final String structure;

  const RoundedBottomAppBar({
    super.key,
    required this.appBarHeight,
    required this.appBarColor,
    required this.structure,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: appBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: appBarColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40.0),
          bottomRight: Radius.circular(40.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            structure,
            style: const TextStyle(
              fontSize: 20.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.account_circle,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);
}
