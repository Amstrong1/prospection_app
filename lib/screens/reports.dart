import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  ReportState createState() => ReportState();
}

class ReportState extends State<Report> {
  List<dynamic> reports = [];
  String statut = '';

  Future<void> fetchReports() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    var userId = pref.getInt(
      'user_id',
    );

    var url = 'https://prospection.vibecro-corp.tech/api/report/$userId';

    try {
      final response = await http.get(Uri.parse(url));
      setState(() {
        final jsonData = json.decode(response.body);
        reports = jsonData['data'];

        if (reports.isEmpty) {
          statut = 'Aucun rapport ajouté';
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
    fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Rapports'),
      ),
      body: reports.isEmpty
          ? statut == 'Aucun rapport ajouté'
              ? const Center(
                  child: Text(
                    'Aucun rapport ajouté',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(
                    color: Colors.orange,
                  ),
                )
          : Column(
              children: [
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     ElevatedButton(
                //       onPressed: () {
                //         Navigator.pushNamed(context, '/newreport');
                //       },
                //       style: ElevatedButton.styleFrom(
                //         foregroundColor: Colors.white,
                //         backgroundColor: Colors.blue,
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(10.0),
                //         ),
                //       ),
                //       child: const Text('Nouveau'),
                //     ),
                //     const SizedBox(width: 10),
                //   ],
                // ),
                Expanded(
                  child: ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
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
                            '${report['report']}',
                          ),
                          // trailing: Row(
                          //   mainAxisSize: MainAxisSize.min,
                          //   children: [
                          //     IconButton(
                          //       icon: const Icon(
                          //         Icons.edit,
                          //         color: Colors.blue,
                          //         size: 20,
                          //       ),
                          //       onPressed: () {},
                          //     ),
                          //     IconButton(
                          //       icon: const Icon(
                          //         Icons.delete,
                          //         color: Colors.red,
                          //         size: 20,
                          //       ),
                          //       onPressed: () async {
                          //         var url =
                          //             "https://prospection.vibecro-corp.tech/api/report/${report['id']}";
                          //         try {
                          //           final response = await http.delete(
                          //             Uri.parse(url),
                          //           );
                          //           Map<String, dynamic> decodedResponse =
                          //               jsonDecode(response.body);
                          //           if (decodedResponse['success'] == true) {
                          //             setState(() {
                          //               reports.removeAt(index);
                          //             });
                          //             var snackBar = const SnackBar(
                          //               content: Text(
                          //                 "Suppression éffectuée avec succès",
                          //               ),
                          //             );
                          //             ScaffoldMessenger.of(context)
                          //                 .showSnackBar(snackBar);
                          //           } else {
                          //             var snackBar = const SnackBar(
                          //               content: Text(
                          //                 "Erreur",
                          //               ),
                          //             );
                          //             ScaffoldMessenger.of(context)
                          //                 .showSnackBar(snackBar);
                          //           }
                          //         } catch (e) {
                          //           var snackBar = SnackBar(
                          //             content: Text(e.toString()),
                          //           );
                          //           ScaffoldMessenger.of(context)
                          //               .showSnackBar(snackBar);
                          //         }
                          //       },
                          //     ),
                          //   ],
                          // ),

                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) =>
                            //         ReportDetails(report: report),
                            //   ),
                            // );
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

// class ReportDetails extends StatelessWidget {
//   final Map<String, dynamic> report;

//   const ReportDetails({
//     super.key,
//     required this.report,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Détails'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             customText('prospect', report['prospect_name']),
//             const SizedBox(height: 10),
//             customText('Date', report['formatted_created_at']),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
