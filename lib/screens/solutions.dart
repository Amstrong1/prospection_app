import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Solution extends StatefulWidget {
  const Solution({super.key});
  @override
  SolutionState createState() => SolutionState();
}

class SolutionState extends State<Solution> {
  List<dynamic> solutions = [];

  Future<void> fetchSolutions() async {
    var url = 'https://prospection.vibecro-corp.tech/api/solution';

    try {
      final response = await http.get(Uri.parse(url));
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
    fetchSolutions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Les Solutions'),
      ),
      body: solutions.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: solutions.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(
                    solutions[index]['title'],
                    style: const TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
