import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prospection_app/screens/login.dart';
import 'package:prospection_app/widgets/indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fl_chart/fl_chart.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<Home> {
  late Map<String, dynamic> decodedResponse = {};

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
  }

  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(150.0),
        child: RoundedBottomAppBar(
          appBarColor: Colors.orange,
          appBarHeight: 150.0,
        ),
      ),
      body: decodedResponse.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            )
          : Column(
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
      var prospectYespercent = (prospectYes.toDouble() * 100) / prospects;
      var prospectNopercent = (prospectNo.toDouble() * 100) / prospects;
      var prospectIndecispercent =
          (prospectIndecis.toDouble() * 100) / prospects;
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

  const RoundedBottomAppBar({
    super.key,
    required this.appBarHeight,
    required this.appBarColor,
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
          const Text(
            'Accueil',
            style: TextStyle(
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

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  ProfilPageState createState() => ProfilPageState();
}

class ProfilPageState extends State<Profil> {
  String userName = "";
  String userEmail = "";

  final _formKey = GlobalKey<FormState>();
  late String _oldPassword;
  late String _password;
  late String _password_confirmation;
  bool _passwordVisible = false;

  Future<void> _fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('user_id');
    final response = await http.get(
      Uri.parse('https://prospection.vibecro-corp.tech/api/profile/$userId'),
    );
    var decodedResponse = jsonDecode(response.body);
    setState(() {
      userName = decodedResponse['name'].toString();
      userEmail = decodedResponse['email'].toString();
    });
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(
      'isAuthenticated',
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Login(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_circle),
                  const SizedBox(width: 10),
                  Text(
                    userName,
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.email),
                  const SizedBox(width: 10),
                  Text(
                    userEmail,
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'Modifier mot de passe',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Ancien mot de passe',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                          child: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      obscureText: !_passwordVisible,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Entrez votre ancien mot de passe';
                        }
                        return null;
                      },
                      onSaved: (value) => _oldPassword = value!,
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Nouveau mot de passe',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                          child: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      obscureText: !_passwordVisible,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Entrez un mot de passe';
                        }
                        return null;
                      },
                      onSaved: (value) => _password = value!,
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Confirmer mot de passe',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                          child: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      obscureText: !_passwordVisible,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Confirmer le mot de passe';
                        }
                        return null;
                      },
                      onSaved: (value) => _password_confirmation = value!,
                    ),
                    const SizedBox(height: 30.0),
                    SizedBox(
                      width: double.infinity,
                      height: 50.0,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final prefs = await SharedPreferences.getInstance();
                            var userId = prefs.getInt('user_id');
                            final response = await http.post(
                                Uri.parse(
                                  'https://prospection.vibecro-corp.tech/api/set-password',
                                ),
                                body: {
                                  'user': userId.toString(),
                                  'old_password': _oldPassword,
                                  'password': _password,
                                  'password_confirmation':
                                      _password_confirmation,
                                });
                            Map<String, dynamic> decodedResponse =
                                jsonDecode(response.body);
                            if (decodedResponse['success'] == true) {
                              const snackBar = SnackBar(
                                content: Text(
                                  'Mot de passe mis à jour',
                                ),
                              );
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                snackBar,
                              );
                            } else {
                              const snackBar = SnackBar(
                                content: Text(
                                  'Vérifier les informations entrées et réssayer',
                                ),
                              );
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                snackBar,
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text(
                          'Modifier le mot de passe',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _logout(context);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text('Déconnexion'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
