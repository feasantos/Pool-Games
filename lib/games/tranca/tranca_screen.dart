import 'package:flutter/material.dart';

class TrancaScreen extends StatelessWidget {
  const TrancaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tranca')),
      body: const Center(child: Text('Em breve...', style: TextStyle(fontSize: 24))),
    );
  }
}
