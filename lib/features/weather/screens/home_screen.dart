import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Météo Now"),
      ),
      body: const Center(
        child: Text(
          "home page",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
