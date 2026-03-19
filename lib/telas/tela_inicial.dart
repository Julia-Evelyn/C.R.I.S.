import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/agente_dados.dart';
import '../dados/base.dart';
import '../dados/trilhas.dart';
import 'ficha_agente.dart';

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

  // Função para puxar a cor do Agente já na tela inicial
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            // 1. FOTO DE PERFIL DESTACADA
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: corTema,
                                  width: 2,
                                ), // Borda com a cor da afinidade
                                boxShadow: agente.afinidade != null
                                    ? [
                                        BoxShadow(
                                          color: corTema.withValues(alpha: 0.4),
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
                                  ? Icon(Icons.person, size: 40, color: corTema)
                                  : null,
                            ),
                            const SizedBox(width: 16),

                            // INFORMAÇÕES DO AGENTE
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      String textoClasse = agente.classe != '--'
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
                                            dadosOrigens[agente.origem]?.nome ??
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

                                  // NEX E PP
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

  // Componente visual para as "etiquetas" de NEX e Prestígio
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
