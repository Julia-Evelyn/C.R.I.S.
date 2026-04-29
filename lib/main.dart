import 'package:flutter/material.dart';
import 'telas/tela_inicial.dart';

import 'dados/itens.dart';
import 'dados/poderes.dart';

// Função para colocar tudo em ordem alfabética
void ordenarCatalogos() {
  catalogoItensOrdem.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),);
  catalogoArmasOrdem.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),);
  catalogoPoderesGerais.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),);
  catalogoPoderesCombatente.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),);
  catalogoPoderesEspecialista.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),);
  catalogoPoderesOcultista.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),);
  catalogoPoderesSangue.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),);
  catalogoPoderesMorte.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),);
  catalogoPoderesEnergia.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),);
  catalogoPoderesConhecimento.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  ordenarCatalogos();

  runApp(const OrdoRealitasApp());
}

class OrdoRealitasApp extends StatelessWidget {
  const OrdoRealitasApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Terminal Ordo Realitas',
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
