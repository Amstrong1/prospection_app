import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:prospection_app/screens/edit_prospect.dart';
import 'package:prospection_app/widgets/animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prospect extends StatefulWidget {
  const Prospect({super.key});

  @override
  ProspectState createState() => ProspectState();
}

class ProspectState extends State<Prospect> {
  List<dynamic> prospects = [];
  String statut = '';

  Future<void> fetchProspects() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    var userId = pref.getInt(
      'user_id',
    );

    var url = 'https://prospection.vibecro-corp.tech/api/prospects/$userId';

    try {
      final response = await http.get(Uri.parse(url));
      setState(() {
        final jsonData = json.decode(response.body);
        prospects = jsonData['data'];

        if (prospects.isEmpty) {
          statut = 'Aucun prospect ajouté';
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
    fetchProspects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes Prospects',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
      body: prospects.isEmpty
          ? statut == 'Aucun prospect ajouté'
              ? Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/prospect_choice');
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
                      'Aucun prospect ajouté',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: AnimatedImage(),
                )
          : Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/prospect_choice');
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
                    itemCount: prospects.length,
                    itemBuilder: (context, index) {
                      final prospect = prospects[index];
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
                            '${prospect['company']}',
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
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute<dynamic>(
                                      builder: (_) =>
                                          EditProspect(prospect: prospect),
                                    ),
                                  );
                                },
                              ),
                              // IconButton(
                              //   icon: const Icon(
                              //     Icons.delete,
                              //     color: Colors.red,
                              //     size: 20,
                              //   ),
                              //   onPressed: () async {
                              //     var url =
                              //         "https://prospection.vibecro-corp.tech/api/prospect/${prospect['id']}";
                              //     try {
                              //       final response = await http.delete(
                              //         Uri.parse(url),
                              //       );
                              //       Map<String, dynamic> decodedResponse =
                              //           jsonDecode(response.body);
                              //       if (decodedResponse['success'] == true) {
                              //         setState(() {
                              //           prospects.removeAt(index);
                              //         });
                              //         var snackBar = const SnackBar(
                              //           content: Text(
                              //             "Suppression éffectuée avec succès",
                              //           ),
                              //         );
                              //         ScaffoldMessenger.of(context)
                              //             .showSnackBar(snackBar);
                              //       } else {
                              //         var snackBar = const SnackBar(
                              //           content: Text(
                              //             "Erreur",
                              //           ),
                              //         );
                              //         ScaffoldMessenger.of(context)
                              //             .showSnackBar(snackBar);
                              //       }
                              //     } catch (e) {
                              //       var snackBar = SnackBar(
                              //         content: Text(e.toString()),
                              //       );
                              //       ScaffoldMessenger.of(context)
                              //           .showSnackBar(snackBar);
                              //     }
                              //   },
                              // ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProspectDetails(prospect: prospect),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}

class ProspectDetails extends StatelessWidget {
  final Map<String, dynamic> prospect;

  const ProspectDetails({
    super.key,
    required this.prospect,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${prospect['company']}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            customText('Nom', prospect['lastname']),
            customText('Prénom', prospect['email']),
            customText('Email', prospect['email']),
            customText('Telephone', prospect['tel']),
            customText('Entreprise', prospect['company']),
            customText('Date', prospect['created_at']),
            customText('Réponse', prospect['status']),
            prospect['reports'].length > 0
                ? customText(
                    'Rapport',
                    prospect['reports'][0]['report'] ?? "Aucun rapport",
                  )
                : customText('Rapport', 'Aucun rapport'),
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
                itemCount: prospect['solutions'].length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(
                      prospect['solutions'][index]['title'],
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

Widget customText(String label, String? value) {
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
        value ?? '...',
        style: const TextStyle(
          fontSize: 18.0,
        ),
      ),
      const SizedBox(height: 50),
    ],
  );
}
