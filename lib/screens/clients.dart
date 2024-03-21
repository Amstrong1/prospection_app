import 'package:flutter/material.dart';

class Client extends StatelessWidget {
  const Client({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client'),
      ),
      body: const Center(
        child: Text('Client'),
      ),
    );
  }
}