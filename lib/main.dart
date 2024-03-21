import 'package:flutter/material.dart';
import 'package:prospection_app/screens/clients.dart';
import 'package:prospection_app/screens/home.dart';
import 'package:prospection_app/screens/login.dart';
import 'package:prospection_app/screens/new_prospect.dart';
import 'package:prospection_app/screens/new_suspect.dart';
import 'package:prospection_app/screens/prospect_choice.dart';
import 'package:prospection_app/screens/prospects.dart';
import 'package:prospection_app/screens/reports.dart';
import 'package:prospection_app/screens/solutions.dart';
import 'package:prospection_app/screens/suspect_to_prospect.dart';
import 'package:prospection_app/screens/suspects.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isAuthenticated = prefs.getBool('isAuthenticated') ?? false;

  runApp(MyApp(isAuthenticated: isAuthenticated));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isAuthenticated});

  final bool isAuthenticated;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: isAuthenticated == true ? const Home() : const Login(),
      routes: {
        '/profile': (context) => const Profil(),
        '/reports': (context) => const Report(),
        '/clients': (context) => const Client(),
        '/solutions': (context) => const Solution(),
        '/suspects': (context) => const Suspect(),
        '/newsuspect': (context) => const NewSuspect(),
        '/prospects': (context) => const Prospect(),
        '/new_prospect': (context) => const NewProspect(),
        '/suspect_to_prospects': (context) => const SuspectToProspect(),
        '/prospect_choice': (context) => const ChoicePage(),
      },
    );
  }
}