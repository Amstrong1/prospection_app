import 'package:flutter/material.dart';
import 'package:prospection_app/screens/home.dart';
import 'package:prospection_app/screens/prospects.dart';
// import 'package:prospection_app/screens/reports.dart';
import 'package:prospection_app/screens/suspects.dart';
// import 'package:location/location.dart';
// import 'package:geocoding/geocoding.dart' as geocoding_platform_interface;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;

class MyBottomNavigationBar extends StatefulWidget {
  const MyBottomNavigationBar({super.key, required this.page});
  final int page;

  @override
  MyBottomNavigationBarState createState() => MyBottomNavigationBarState();
}

class MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _selectedIndex = 0;

  // Location location = Location();
  // late Stream<LocationData> _locationStream;
  // String _address = '';

  // Future<void> _insertLocation(double latitude, double longitude) async {
  // final prefs = await SharedPreferences.getInstance();
  // var userId = prefs.getInt('user_id');
  // var userStructure = prefs.getInt('structure_id');

  //   try {
  //     List<geocoding_platform_interface.Placemark> placemarks =
  //         await geocoding_platform_interface.placemarkFromCoordinates(
  //       latitude,
  //       longitude,
  //     );
  //     geocoding_platform_interface.Placemark placemark = placemarks[0];
  //     setState(() {
  //       _address =
  //           '${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.country}';
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _address = 'Adresse non trouvée';
  //     });
  //   }

  //   await http.post(
  //     Uri.parse('https://prospection.vibecro-corp.tech/api/location'),
  //     body: {
  //       'user_structure': userStructure.toString(),
  //       'user': userId.toString(),
  //       'latitude': latitude.toString(),
  //       'longitude': longitude.toString(),
  //       'address': _address,
  //     },
  //   );
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   setState(() {
  //     location.enableBackgroundMode(enable: true);
  //     _locationStream = location.onLocationChanged;
  //     _locationStream.listen((LocationData userLocation) {
  //       _insertLocation(userLocation.latitude!, userLocation.longitude!);
  //     });
  //   });
  // }

  @override
  void initState() {
    super.initState();
    if (widget.page != 0) {
      _selectedIndex = widget.page;
    }
  }

  static final List<Widget> _widgetOptions = <Widget>[
    const Home(),
    const Suspect(),
    const Prospect(),
    // const Report(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.orange,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_add,
            ),
            label: 'Suspects',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
            ),
            label: 'Prospects',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(
          //     Icons.edit,
          //   ),
          //   label: 'Rapports',
          // ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[350],
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
