import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../modelos/agente_dados.dart';
import '../dados/base.dart';
import '../dados/trilhas.dart';
import 'ficha_agente.dart';
import 'tela_lore_agente.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});
  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  List<AgenteDados> meusAgentes = [];

  @override
  void initState() {
    super.initState();
    _carregarAgentes();
  }

  Future<void> _carregarAgentes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? agentesJson = prefs.getString('agentes_salvos');
    if (agentesJson != null) {
      setState(
        () => meusAgentes = (jsonDecode(agentesJson) as List)
            .map((item) => AgenteDados.fromJson(item))
            .toList(),
      );
    }
  }

  Future<void> _excluirAgente(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => meusAgentes.removeAt(index));
    await prefs.setString(
      'agentes_salvos',
      jsonEncode(meusAgentes.map((e) => e.toJson()).toList()),
    );
  }

  Color _obterCorAfinidade(String? afinidade) {
    if (afinidade == null) return Colors.white;
    switch (afinidade) {
      case 'Sangue':
        return const Color(0xFF990000);
      case 'Energia':
        return const Color(0xFF9900FF);
      case 'Morte':
        return Colors.white54;
      case 'Conhecimento':
        return const Color(0xFFFFB300);
      default:
        return Colors.white;
    }
  }

  Future<void> _salvarMeusAgentes() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(
      meusAgentes.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('agentes_salvos', jsonString);
  }

  void _duplicarAgente(int index) async {
    Map<String, dynamic> jsonAgente = meusAgentes[index].toJson();
    AgenteDados copia = AgenteDados.fromJson(jsonAgente);

    copia.nome = "${copia.nome} (Cópia)";

    setState(() {
      meusAgentes.insert(index + 1, copia);
    });

    await _salvarMeusAgentes();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Agente duplicado com sucesso!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'MEUS AGENTES',
          style: TextStyle(
            fontFamily: 'Courier',
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: Colors.white, height: 2.0),
        ),
      ),
      body: meusAgentes.isEmpty
          ? const Center(
              child: Text(
                "Nenhum agente recrutado.\nClique no '+' para criar.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: meusAgentes.length,
              itemBuilder: (context, index) {
                final agente = meusAgentes[index];
                Color corTema = _obterCorAfinidade(agente.afinidade);

                // Envolvemos o card com um Padding que cuida da margem inferior
                return Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Slidable(
                    key: Key('agente_${agente.nome}_$index'),
                    // O ActionPane é o que aparece quando você arrasta
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      extentRatio: 0.45, // Espaço ocupado pelos botões
                      children: [
                        // Botão "Info" (Com a cor da afinidade do Agente)
                        CustomSlidableAction(
                          onPressed: (context) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TelaLoreAgente(
                                  agente: agente,
                                  corTema: corTema,
                                  onSalvar: _salvarMeusAgentes,
                                ),
                              ),
                            ).then((_) => setState(() {}));
                          },
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.only(
                            left: 8,
                          ), 
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF111111,
                              ), 
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: corTema.withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.folder_shared,
                                  color: corTema,
                                  size: 24,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "INFO",
                                  style: TextStyle(
                                    color: corTema,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Courier',
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Botão Duplicar
                        CustomSlidableAction(
                          onPressed: (context) => _duplicarAgente(index),
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.only(left: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF111111),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey.shade800,
                                width: 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.control_point_duplicate,
                                  color: Colors.grey.shade400,
                                  size: 24,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "COPIAR",
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Courier',
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Card principal do agente
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: corTema.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 5,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            final att = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FichaAgente(
                                  agenteParaEditar: agente,
                                  indexEdicao: index,
                                  isVisualizacao: true,
                                ),
                              ),
                            );
                            if (att == true) _carregarAgentes();
                          },
                          onLongPress: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color(0xFF1A1A1A),
                              title: const Text(
                                "Excluir Agente",
                                style: TextStyle(color: Colors.white),
                              ),
                              content: Text(
                                "Deseja apagar a ficha de ${agente.nome}?",
                                style: const TextStyle(color: Colors.white),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    "Cancelar",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                  ),
                                  onPressed: () {
                                    _excluirAgente(index);
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    "Excluir",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: corTema,
                                      width: 2,
                                    ),
                                    boxShadow: agente.afinidade != null
                                        ? [
                                            BoxShadow(
                                              color: corTema.withValues(
                                                alpha: 0.4,
                                              ),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ]
                                        : [],
                                    image: agente.fotoPath != null
                                        ? DecorationImage(
                                            image: FileImage(
                                              File(agente.fotoPath!),
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: agente.fotoPath == null
                                      ? Icon(
                                          Icons.person,
                                          size: 40,
                                          color: corTema,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        agente.nome.toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.white,
                                          letterSpacing: 1,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        () {
                                          String textoClasse =
                                              agente.classe != '--'
                                              ? agente.classe.toUpperCase()
                                              : "SEM CLASSE";
                                          String textoTrilha = "";
                                          if (agente.trilha != '--' &&
                                              trilhasOrdem.containsKey(
                                                agente.trilha,
                                              )) {
                                            textoTrilha =
                                                " • ${trilhasOrdem[agente.trilha]!.nome.toUpperCase()}";
                                          }
                                          String textoOrigem = "";
                                          if (agente.origem != '--') {
                                            String nomeOrigem =
                                                dadosOrigens[agente.origem]
                                                    ?.nome ??
                                                agente.origem;
                                            textoOrigem =
                                                " • ${nomeOrigem.toUpperCase()}";
                                          }
                                          return "$textoClasse$textoTrilha$textoOrigem";
                                        }(),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          _buildBadge(
                                            "NEX ${agente.nex}%",
                                            corTema,
                                          ),
                                          const SizedBox(width: 8),
                                          _buildBadge(
                                            "PP ${agente.prestigio}",
                                            Colors.grey.shade400,
                                            isOutline: true,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          final att = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FichaAgente()),
          );
          if (att == true) _carregarAgentes();
        },
      ),
    );
  }

  Widget _buildBadge(String text, Color color, {bool isOutline = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOutline ? Colors.transparent : color.withValues(alpha: 0.2),
        border: Border.all(
          color: isOutline ? color.withValues(alpha: 0.5) : color,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
