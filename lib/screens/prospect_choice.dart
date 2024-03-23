import 'package:flutter/material.dart';

class ChoicePage extends StatelessWidget {
  const ChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/suspect_to_prospects');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text('Confirmer un rendez avec un suspect'),
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/newprospect');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text('Créer un prospect'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
