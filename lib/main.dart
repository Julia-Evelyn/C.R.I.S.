import 'package:flutter/material.dart';
import 'telas/tela_inicial.dart';

void main() {
  runApp(const OrdoRealitasApp());
}

class OrdoRealitasApp extends StatelessWidget {
  const OrdoRealitasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ordo Realitas - Ficha',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        primaryColor: Colors.white,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.grey,
        ),
      ),
      home: const TelaInicial(),
    );
  }
}