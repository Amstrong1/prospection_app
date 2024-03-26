import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prospection_app/widgets/bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  late String _email;
  late String _password;
  bool _isAuthenticated = false;
  bool _passwordVisible = false;
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'CONNEXION',
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty ||
                            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                          return 'Entrez une adresse mail valide';
                        }
                        return null;
                      },
                      onSaved: (value) => _email = value!,
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
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
                                  setState(() {
                                    _isAuthenticated = false;
                                    _sending = true;
                                  });
                                  var url = Uri.parse(
                                    'http://prospection.vibecro-corp.tech/api/login',
                                  );

                                  try {
                                    final response =
                                        await http.post(url, body: {
                                      'email': _email,
                                      'password': _password,
                                    });
                                    Map<String, dynamic> decodedResponse =
                                        jsonDecode(response.body);
                                    if (decodedResponse['success'] == true) {
                                      setState(() {
                                        _isAuthenticated = true;
                                      });
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      prefs.setBool(
                                        'isAuthenticated',
                                        _isAuthenticated,
                                      );
                                      prefs.setInt(
                                        'user_id',
                                        decodedResponse['user_id'],
                                      );
                                      prefs.setInt(
                                        'user_structure',
                                        decodedResponse['structure_id'],
                                      );
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const MyBottomNavigationBar(
                                            page: 0,
                                          ),
                                        ),
                                      );
                                    } else {
                                      var snackBar = const SnackBar(
                                        content: Text(
                                          'Email ou mot de passe incorrecte',
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
                                  } catch (e) {
                                    var snackBar = SnackBar(
                                      content: Text(e.toString()),
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
                                'Se connecter',
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
            ),
          ],
        ),
      ),
    );
  }
}
