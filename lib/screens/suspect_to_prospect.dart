import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prospection_app/widgets/bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SuspectToProspect extends StatefulWidget {
  const SuspectToProspect({super.key});

  @override
  NewProspectState createState() => NewProspectState();
}

class NewProspectState extends State<SuspectToProspect> {
  TextEditingController dateInput = TextEditingController();
  TextEditingController timeInput = TextEditingController();

  List<dynamic> suspects = [];

  final _formKey = GlobalKey<FormState>();
  late String _report;
  String _selectedOption = 'Indécis';
  late String _selectedSuspect;

  bool _sending = false;

  void _reloadApp() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MyBottomNavigationBar()),
        (Route<dynamic> route) => false,
      );
    });
  }

  Future<void> fetchSuspects() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    var userId = pref.getInt(
      'user_id',
    );
    final response = await http.get(
      Uri.parse('https://prospection.vibecro-corp.tech/api/suspect/$userId'),
    );
    try {
      setState(() {
        final jsonData = json.decode(response.body);
        suspects = List<dynamic>.from(jsonData['data']);
        _selectedSuspect = suspects[0]['id'].toString();
      });
    } catch (e) {
      var snackBar = const SnackBar(
        content: Text("Aucun suspect trouvé"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  void initState() {
    super.initState();
    dateInput.text = "";
    timeInput.text = "";
    fetchSuspects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nouveau prospect',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
      body: suspects.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Liste des suspects',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSuspect,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedSuspect = newValue!;
                              });
                            },
                            items: suspects.map<DropdownMenuItem<String>>(
                                (dynamic suspect) {
                              return DropdownMenuItem<String>(
                                value: suspect['id'].toString(),
                                child: Text(
                                  '${suspect['lastname']} ${suspect['firstname']}',
                                ),
                              );
                            }).toList(),
                          ),
                        ),
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
                                data: MediaQuery.of(context)
                                    .copyWith(alwaysUse24HourFormat: true),
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
                        'Décision du client',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedOption,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedOption = newValue!;
                              });
                            },
                            items: <String>['Oui', 'Non', 'Indécis']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                          labelText: 'Rapport',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              10.0,
                            ),
                          ),
                        ),
                        validator: (value) {
                          return null;
                        },
                        onSaved: (value) => _report = value!,
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
                                    var url = Uri.parse(
                                      'http://prospection.vibecro-corp.tech/api/prospect-from-suspect',
                                    );

                                    SharedPreferences pref =
                                        await SharedPreferences.getInstance();
                                    var userId = pref.getInt('user_id');
                                    try {
                                      final response =
                                          await http.post(url, body: {
                                        'user': userId.toString(),
                                        'suspect': _selectedSuspect.toString(),
                                        'app_date': dateInput.text,
                                        'app_time': timeInput.text,
                                        'report': _report,
                                        'status': _selectedOption.toString(),
                                      });
                                      Map<String, dynamic> decodedResponse =
                                          jsonDecode(response.body);
                                      if (decodedResponse['success'] == true) {
                                        var snackBar = const SnackBar(
                                          content: Text(
                                            'Prospect ajouté avec succes',
                                          ),
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
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
