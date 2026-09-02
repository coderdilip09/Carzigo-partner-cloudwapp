import 'package:carzigo_partner/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carzigo Partner',
      home: Scaffold(
        body: Center(
          child: Text('Carzigo Partner'),
        ),
      ),
    );
  }
}
