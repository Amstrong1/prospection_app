import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prospection_app/widgets/bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewSuspect extends StatefulWidget {
  const NewSuspect({super.key});

  @override
  NewSuspectState createState() => NewSuspectState();
}

class NewSuspectState extends State<NewSuspect> {
  List<dynamic> solutions = [];
  List<dynamic> selectedSolutions = [];

  TextEditingController dateInput = TextEditingController();
  TextEditingController timeInput = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  late String _tel;
  late String _email;
  late String _company;
  late String _address;
  late String _lastname;
  late String _firstname;

  bool _sending = false;

  void _reloadApp() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MyBottomNavigationBar()),
        (Route<dynamic> route) => false,
      );
    });
  }

  Future<void> fetchSolutions() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var userStructure = pref.getInt('user_structure');

    final response = await http.get(
      Uri.parse(
          'https://prospection.vibecro-corp.tech/api/solution/$userStructure'),
    );
    try {
      setState(() {
        final jsonData = json.decode(response.body);
        solutions = List<dynamic>.from(jsonData['data']);
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
    dateInput.text = "";
    timeInput.text = "";
    fetchSolutions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nouveau suspect',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Entrez le nom du suspect';
                    }
                    return null;
                  },
                  onSaved: (value) => _lastname = value!,
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Prénom(s)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Entrez le(s) prénom(s) du suspect';
                    }
                    return null;
                  },
                  onSaved: (value) => _firstname = value!,
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Entreprise',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ),
                    ),
                    suffixIcon: const Icon(Icons.business),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Entrez le numero du suspect';
                    }
                    return null;
                  },
                  onSaved: (value) => _company = value!,
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ),
                    ),
                    suffixIcon: const Icon(Icons.email),
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
                    labelText: 'Contact',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ),
                    ),
                    suffixIcon: const Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Entrez le numero du suspect';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                  onSaved: (value) => _tel = value!,
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Adresse',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ),
                    ),
                    suffixIcon: const Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Entrez l\'adresse du suspect';
                    }
                    return null;
                  },
                  onSaved: (value) => _address = value!,
                ),
                const SizedBox(height: 20.0),
                // datepicker
                TextField(
                  controller: dateInput,
                  decoration: InputDecoration(
                    labelText: "Date de rdv",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ),
                    ),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1950),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDate != null) {
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                      setState(() {
                        dateInput.text = formattedDate;
                      });
                    }
                  },
                ),
                // timepicker
                const SizedBox(height: 20.0),
                TextField(
                  controller: timeInput,
                  decoration: InputDecoration(
                    labelText: "Heure de rdv",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ),
                    ),
                    suffixIcon: const Icon(Icons.access_time),
                  ),
                  readOnly: true,
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (BuildContext context, Widget? child) {
                        return MediaQuery(
                          data: MediaQuery.of(
                            context,
                          ).copyWith(
                            alwaysUse24HourFormat: true,
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedTime != null) {
                      setState(() {
                        timeInput.text =
                            "${pickedTime.hour}:${pickedTime.minute}";
                      });
                    }
                  },
                ),
                const SizedBox(height: 20.0),
                const Text(
                  'Solutions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 10,
                  children: List.generate(
                    solutions.length,
                    (index) => ChoiceChip(
                      label: Text(solutions[index]['title']),
                      selected:
                          selectedSolutions.contains(solutions[index]['id']),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedSolutions.add(solutions[index]['id']);
                          } else {
                            selectedSolutions.remove(solutions[index]['id']);
                          }
                        });
                      },
                    ),
                  ),
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
                                _sending = true;
                              });
                              var url = Uri.parse(
                                'http://prospection.vibecro-corp.tech/api/suspect',
                              );
                              final prefs =
                                  await SharedPreferences.getInstance();
                              var userId = prefs.getInt('user_id');
                              var userStructure =
                                  prefs.getInt('user_structure');
                              try {
                                final response = await http.post(url, body: {
                                  'user_structure': userStructure.toString(),
                                  'user': userId.toString(),
                                  'lastname': _lastname,
                                  'firstname': _firstname,
                                  'company': _company,
                                  'address': _address,
                                  'tel': _tel,
                                  'email': _email,
                                  'app_date': dateInput.text,
                                  'app_time': timeInput.text,
                                  'solutions': jsonEncode(selectedSolutions)
                                });
                                Map<String, dynamic> decodedResponse =
                                    jsonDecode(response.body);
                                if (decodedResponse['success'] == true) {
                                  var snackBar = const SnackBar(
                                    content: Text('Suspect ajouté avec succes'),
                                  );
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    snackBar,
                                  );
                                  _reloadApp();
                                } else {
                                  var snackBar = const SnackBar(
                                    content: Text(
                                      'Une erreur est survenue lors de l\'ajout du suspect',
                                    ),
                                  );
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    snackBar,
                                  );
                                }
                              } catch (e) {
                                var snackBar = SnackBar(
                                  content: Text(e.toString()),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
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
                            'Enregistrer',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 50.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
