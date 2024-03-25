import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Suspect extends StatefulWidget {
  const Suspect({super.key});

  @override
  SuspectState createState() => SuspectState();
}

class SuspectState extends State<Suspect> {
  List<dynamic> suspects = [];
  String statut = '';

  Future<void> fetchSuspects() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    var userId = pref.getInt(
      'user_id',
    );

    var url = 'https://prospection.vibecro-corp.tech/api/suspect/$userId';

    try {
      final response = await http.get(Uri.parse(url));
      setState(() {
        final jsonData = json.decode(response.body);
        suspects = jsonData['data'];

        if (suspects.isEmpty) {
          statut = 'Aucun suspect ajouté';
        }
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
    fetchSuspects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes Suspects',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
      body: suspects.isEmpty
          ? statut == 'Aucun suspect ajouté'
              ? Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/newsuspect');
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Text('Nouveau'),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Aucun suspect ajouté',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(
                    color: Colors.orange,
                  ),
                )
          : Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/newsuspect');
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text('Nouveau'),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: suspects.length,
                    itemBuilder: (context, index) {
                      final suspect = suspects[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 5.0,
                          horizontal: 10.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          title: Text(
                            '${suspect['lastname']} ${suspect['firstname']}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  var url =
                                      "https://prospection.vibecro-corp.tech/api/suspect/${suspect['id']}";
                                  try {
                                    final response = await http.delete(
                                      Uri.parse(url),
                                    );
                                    Map<String, dynamic> decodedResponse =
                                        jsonDecode(response.body);
                                    if (decodedResponse['success'] == true) {
                                      setState(() {
                                        suspects.removeAt(index);
                                      });
                                      var snackBar = const SnackBar(
                                        content: Text(
                                          "Suppression éffectuée avec succès",
                                        ),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    } else {
                                      var snackBar = const SnackBar(
                                        content: Text(
                                          "Erreur",
                                        ),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    }
                                  } catch (e) {
                                    var snackBar = SnackBar(
                                      content: Text(e.toString()),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  }
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SuspectDetails(suspect: suspect),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class SuspectDetails extends StatelessWidget {
  final Map<String, dynamic> suspect;

  const SuspectDetails({
    super.key,
    required this.suspect,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${suspect['lastname']} ${suspect['firstname']}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            customText('Nom', suspect['lastname']),
            customText('Prénom', suspect['email']),
            customText('Email', suspect['email']),
            customText('Telephone', suspect['tel']),
            customText('Entreprise', suspect['company']),
            customText('Date de rencontre prévue', suspect['app_date']),
            customText('Heure de rencontre prévue', suspect['app_time']),
            const SizedBox(height: 20),
            const Text(
              "Solutions : ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: suspect['solutions'].length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(
                      suspect['solutions'][index]['title'],
                      style: const TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget customText(String label, String value) {
  return Row(
    children: [
      Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
      ),
      const Text(
        " : ",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
      ),
      Text(
        value,
        style: const TextStyle(
          fontSize: 18.0,
        ),
      ),
      const SizedBox(height: 50),
    ],
  );
}
