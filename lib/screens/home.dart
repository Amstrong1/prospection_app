import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prospection_app/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: decodedResponse.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GridView.count(
              crossAxisCount: 2,
              children: [
                customContainer(
                  context: context,
                  title: 'Suspects',
                  number: decodedResponse['suspects'].toString(),
                  color: Colors.blue,
                  routeCreate: '/newsuspect',
                  routeIndex: '/suspects',
                ),
                customContainer(
                  context: context,
                  title: 'Rapports',
                  number: decodedResponse['reports'].toString(),
                  color: Colors.green,
                  routeCreate: '',
                  routeIndex: '/reports',
                ),
                customContainer(
                  context: context,
                  title: 'Propsects',
                  number: decodedResponse['prospects'].toString(),
                  color: Colors.red,
                  routeCreate: '/prospect_choice',
                  routeIndex: '/prospects',
                ),
                customContainer(
                  context: context,
                  title: 'Solutions',
                  number: decodedResponse['solutions'].toString(),
                  color: Colors.orange,
                  routeCreate: '',
                  routeIndex: '/solutions',
                ),
              ],
            ),
    );
  }
}

Widget customContainer({
  required BuildContext context,
  required String title,
  required Color color,
  required String number,
  required String routeCreate,
  required String routeIndex,
}) {
  return Container(
    margin: const EdgeInsets.all(8.0),
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, routeCreate);
              },
              icon: const Icon(Icons.add_circle),
              color: Colors.white,
            ),
          ],
        ),
        const SizedBox(height: 4.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25.0,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, routeIndex);
              },
              icon: const Icon(Icons.arrow_forward),
              color: Colors.white,
            ),
          ],
        ),
      ],
    ),
  );
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
