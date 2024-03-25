import 'package:flutter/material.dart';
import 'package:prospection_app/screens/home.dart';
import 'package:prospection_app/screens/prospects.dart';
// import 'package:prospection_app/screens/reports.dart';
import 'package:prospection_app/screens/suspects.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyBottomNavigationBar();
  }
}

class MyBottomNavigationBar extends StatefulWidget {
  const MyBottomNavigationBar({super.key});

  @override
  MyBottomNavigationBarState createState() => MyBottomNavigationBarState();
}

class MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _selectedIndex = 0;

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
