import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prospection_app/screens/login.dart';
import 'package:prospection_app/widgets/bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _sending = false;

  void _reloadApp() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const MyBottomNavigationBar(
            page: 0,
          ),
        ),
        (Route<dynamic> route) => false,
      );
    });
  }

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
        title: const Text(
          'Mon Profil',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
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
                      child: _sending
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.orange,
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  var userId = prefs.getInt('user_id');
                                  setState(() {
                                    _sending = true;
                                  });
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
                                    _reloadApp();
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
                                    setState(() {
                                      _sending = false;
                                    });
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.orange,
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
