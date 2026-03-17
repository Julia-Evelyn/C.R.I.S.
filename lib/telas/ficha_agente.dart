import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../modelos/agente_dados.dart';
import '../dados/base.dart';
import '../dados/itens.dart';
import '../dados/poderes.dart';
import '../componentes/estilizacao.dart';

class FichaAgente extends StatefulWidget {
  final AgenteDados? agenteParaEditar;
  final int? indexEdicao;
  final bool isVisualizacao;

  const FichaAgente({
    super.key,
    this.agenteParaEditar,
    this.indexEdicao,
    this.isVisualizacao = false,
  });
  @override
  State<FichaAgente> createState() => _FichaAgenteState();
}

class _FichaAgenteState extends State<FichaAgente> {
  final TextEditingController _nomeController = TextEditingController();

  late List<Pericia> listaPericias;
  Map<String, int> bonusPericias = {};
  List<ItemInventario> inventario = [];
  List<Arma> armas = [];

  List<String> poderesEscolhidos = [];
  List<String> periciasClasse = [];

  String classeAtual = '--', origemAtual = 'academico';
  String? fotoPath;
  String? afinidadeAtual;
  int nex = 5, prestigio = 0, agi = 1, forc = 1, inte = 1, pre = 1, vig = 1;
  int pvMax = 0, peMax = 0, sanMax = 0, pvAtual = 0, peAtual = 0, sanAtual = 0;
  int defesa = 10, esquiva = 10, bloqueio = 0;
  String habNome = "", habDesc = "";

  int? _indiceAtual;
  bool _modoVisualizacao = false;

  int _abaAtual = 0;

  // --- CORREÇÃO: Usando a função oficial de Estilo para evitar letras invisíveis! ---
  Color get corDestaque => afinidadeAtual == 'Morte'
      ? Colors.white
      : EstiloParanormal.corTema(afinidadeAtual);
  Color get corFundoAfinidade => afinidadeAtual == 'Morte'
      ? Colors.black
      : EstiloParanormal.corTema(afinidadeAtual);
  Color get corTextoAfinidade => afinidadeAtual == 'Morte'
      ? Colors.white
      : EstiloParanormal.corTextoTema(afinidadeAtual);

  int get espacoMaximo {
    int base = forc == 0 ? 2 : forc * 5;
    if (poderesEscolhidos.contains("Mochileiro")) {
      base += 5;
    }
    return base;
  }

  double get espacoOcupado {
    double espItens = inventario.fold(
      0.0,
      (soma, item) => soma + item.espacoEfetivo,
    );
    double espArmas = armas.fold(
      0.0,
      (soma, arma) => soma + arma.espacoEfetivo,
    );
    return espItens + espArmas;
  }

  int get maosOcupadas {
    int m = 0;
    for (var a in armas.where((a) => a.equipado)) {
      if (a.empunhadura == 'Duas Mãos') {
        m += 2;
      } else {
        m += 1;
      }
    }
    m += inventario
        .where(
          (item) => item.equipado && item.nome.toLowerCase().contains("escudo"),
        )
        .length;
    return m;
  }

  String get patenteAtual {
    if (prestigio >= 200) return "Agente de Elite";
    if (prestigio >= 100) return "Oficial de Operações";
    if (prestigio >= 50) return "Agente Especial";
    if (prestigio >= 20) return "Operador";
    return "Recruta";
  }

  String get limiteCredito {
    if (prestigio >= 200) return "Ilimitado";
    if (prestigio >= 100) return "Alto";
    if (prestigio >= 20) return "Médio";
    return "Baixo";
  }

  Map<String, int> get limitesCategoria {
    if (prestigio >= 200) return {"I": 3, "II": 3, "III": 3, "IV": 2};
    if (prestigio >= 100) return {"I": 3, "II": 3, "III": 2, "IV": 1};
    if (prestigio >= 50) return {"I": 3, "II": 2, "III": 1, "IV": 0};
    if (prestigio >= 20) return {"I": 3, "II": 1, "III": 0, "IV": 0};
    return {"I": 2, "II": 0, "III": 0, "IV": 0};
  }

  Map<String, int> get usoCategoriaAtual {
    var uso = {"I": 0, "II": 0, "III": 0, "IV": 0};
    for (var item in inventario) {
      if (uso.containsKey(item.categoriaEfetiva)) {
        uso[item.categoriaEfetiva] = uso[item.categoriaEfetiva]! + 1;
      }
    }
    for (var arma in armas) {
      if (uso.containsKey(arma.categoriaEfetiva)) {
        uso[arma.categoriaEfetiva] = uso[arma.categoriaEfetiva]! + 1;
      }
    }
    return uso;
  }

  String _obterOpressor(String elemento) {
    switch (elemento) {
      case 'Sangue':
        return 'Morte';
      case 'Morte':
        return 'Energia';
      case 'Energia':
        return 'Conhecimento';
      case 'Conhecimento':
        return 'Sangue';
      default:
        return 'Desconhecido';
    }
  }

  @override
  void initState() {
    super.initState();
    _indiceAtual = widget.indexEdicao;
    _modoVisualizacao = widget.agenteParaEditar != null
        ? widget.isVisualizacao
        : false;
    _inicializarPericias();
    bonusPericias.clear();
    _nomeController.addListener(_salvarSilencioso);

    if (widget.agenteParaEditar != null) {
      final ag = widget.agenteParaEditar!;
      _nomeController.text = ag.nome;
      classeAtual = ag.classe;
      origemAtual = ag.origem;
      fotoPath = ag.fotoPath;
      afinidadeAtual = ag.afinidade;
      nex = ag.nex;
      prestigio = ag.prestigio;
      agi = ag.agi;
      forc = ag.forc;
      inte = ag.inte;
      pre = ag.pre;
      vig = ag.vig;
      pvAtual = ag.pvAtual ?? 0;
      peAtual = ag.peAtual ?? 0;
      sanAtual = ag.sanAtual ?? 0;
      inventario = List.from(ag.inventario);
      armas = List.from(ag.armas);

      poderesEscolhidos = List.from(ag.poderes);
      periciasClasse = List.from(ag.periciasClasse);

      for (var p in listaPericias) {
        if (ag.pericias.containsKey(p.id)) p.treino = ag.pericias[p.id]!;
        if (ag.pericias.containsKey("${p.id}_bonus")) {
          bonusPericias[p.id] = ag.pericias["${p.id}_bonus"]!;
        }
      }
    }
    atualizarFicha(isInitialLoad: true);
  }

  @override
  void dispose() {
    _nomeController.removeListener(_salvarSilencioso);
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _salvarSilencioso() async {
    if (_modoVisualizacao) return;
    final prefs = await SharedPreferences.getInstance();

    Map<String, int> periciasTreinadas = {};
    for (var p in listaPericias) {
      if (p.treino > 0) periciasTreinadas[p.id] = p.treino;
      if (bonusPericias.containsKey(p.id) && bonusPericias[p.id]! > 0) {
        periciasTreinadas["${p.id}_bonus"] = bonusPericias[p.id]!;
      }
    }

    final novoAgente = AgenteDados(
      nome: _nomeController.text.isEmpty
          ? "Agente Desconhecido"
          : _nomeController.text,
      classe: classeAtual,
      origem: origemAtual,
      fotoPath: fotoPath,
      afinidade: afinidadeAtual,
      nex: nex,
      prestigio: prestigio,
      agi: agi,
      forc: forc,
      inte: inte,
      pre: pre,
      vig: vig,
      pvAtual: pvAtual,
      peAtual: peAtual,
      sanAtual: sanAtual,
      pericias: periciasTreinadas,
      inventario: inventario,
      armas: armas,
      poderes: poderesEscolhidos,
      periciasClasse: periciasClasse,
    );

    List<AgenteDados> lista = [];
    final String? agentesJson = prefs.getString('agentes_salvos');
    if (agentesJson != null) {
      lista = (jsonDecode(agentesJson) as List)
          .map((i) => AgenteDados.fromJson(i))
          .toList();
    }
    if (_indiceAtual != null) {
      lista[_indiceAtual!] = novoAgente;
    } else {
      lista.add(novoAgente);
      _indiceAtual = lista.length - 1;
    }
    await prefs.setString(
      'agentes_salvos',
      jsonEncode(lista.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _escolherFoto() async {
    if (_modoVisualizacao) return;
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cortar',
            toolbarColor: const Color(0xFF0D0D0D),
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
            hideBottomControls: true,
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() => fotoPath = croppedFile.path);
        _salvarSilencioso();
      }
    }
  }

  void _rolarDado(String nomeAtrib, int valorAtrib) {
    if (!_modoVisualizacao) return;
    int qtdDados = valorAtrib == 0 ? 2 : valorAtrib;
    List<int> resultados = List.generate(
      qtdDados,
      (_) => Random().nextInt(20) + 1,
    );
    int resultadoFinal = valorAtrib == 0
        ? resultados.reduce(min)
        : resultados.reduce(max);
    Color corDoPopUp = corDestaque;

    String mensagemCritico = "";
    Color corNumero = Colors.white;

    if (resultadoFinal == 20) {
      mensagemCritico = "SUCESSO CRÍTICO!";
      corNumero = Colors.amberAccent;
    } else if (resultadoFinal == 1) {
      mensagemCritico = "FALHA CRÍTICA!";
      corNumero = Colors.redAccent;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          "Teste de $nomeAtrib",
          textAlign: TextAlign.center,
          style: TextStyle(color: corDoPopUp),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Rolou: ${resultados.join(', ')}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              resultadoFinal.toString(),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: corNumero,
              ),
            ),
            if (mensagemCritico.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                mensagemCritico,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: corNumero,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: TextStyle(color: corDoPopUp)),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogAfinidade() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          "O Outro Lado Chama",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Escolha seu elemento de afinidade. Esta escolha moldará seu personagem e NÃO PODERÁ SER DESFEITA.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _btnElemento("Sangue", const Color(0xFF990000)),
              _btnElemento("Energia", const Color(0xFF9900FF)),
              _btnElemento("Morte", Colors.black),
              _btnElemento("Conhecimento", const Color(0xFFFFB300)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _btnElemento(String elemento, Color cor) {
    Color corDoTexto = (elemento == 'Conhecimento')
        ? Colors.black
        : Colors.white;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: cor,
          foregroundColor: corDoTexto,
          side: elemento == 'Morte'
              ? const BorderSide(color: Colors.white54, width: 1)
              : null,
        ),
        onPressed: () {
          setState(() => afinidadeAtual = elemento);
          _salvarSilencioso();
          Navigator.pop(context);
        },
        child: Text(
          elemento.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
    );
  }

  void _mostrarDialogPericiasClasse(String novaClasse) {
    Color corTemaLocal = corFundoAfinidade;
    Color corLetra = corTextoAfinidade;
    Color corDestaqueLocal = corDestaque;

    int maxLivres = 1;
    if (novaClasse == 'combatente') maxLivres = max(1, 1 + inte);
    if (novaClasse == 'especialista') maxLivres = max(1, 7 + inte);
    if (novaClasse == 'ocultista') maxLivres = max(1, 3 + inte);

    String combOp1 = 'luta';
    String combOp2 = 'fortitude';
    List<String> selecionadasLivres = [];
    List<String> selecionadasPerito = [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            List<Pericia> periciasDisponiveisParaLivres = listaPericias.where((
              p,
            ) {
              if (novaClasse == 'combatente' &&
                  (p.id == combOp1 || p.id == combOp2)) {
                return false;
              }
              if (novaClasse == 'ocultista' &&
                  (p.id == 'ocultismo' || p.id == 'vontade')) {
                return false;
              }
              return true;
            }).toList();

            List<Pericia> periciasDisponiveisParaPerito = listaPericias
                .where((p) => p.id != 'luta' && p.id != 'pontaria')
                .toList();

            bool podeConfirmar = selecionadasLivres.length == maxLivres;
            if (novaClasse == 'especialista' && selecionadasPerito.length != 2) {
              podeConfirmar = false;
            }

            return Dialog(
              backgroundColor: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: corDestaqueLocal.withValues(alpha: 0.3),
                ),
              ),
              insetPadding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "NOVA CLASSE: ${novaClasse.toUpperCase()}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: corDestaqueLocal,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Defina as habilidades básicas que você adquiriu com o treinamento da sua nova classe.",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 24),

                    if (novaClasse == 'combatente') ...[
                      const Text(
                        "PERÍCIAS DE COMBATE (Escolha 1 de cada)",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              "Armas",
                              combOp1,
                              ["luta", "pontaria"],
                              (val) {
                                setDialogState(() {
                                  combOp1 = val!;
                                  selecionadasLivres.remove(val);
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown(
                              "Defesa",
                              combOp2,
                              ["fortitude", "reflexos"],
                              (val) {
                                setDialogState(() {
                                  combOp2 = val!;
                                  selecionadasLivres.remove(val);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    if (novaClasse == 'ocultista') ...[
                      const Text(
                        "TREINAMENTO PARANORMAL",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Você recebe treinamento automático em Ocultismo e Vontade.",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 24),
                    ],

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "PERÍCIAS LIVRES",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${selecionadasLivres.length} / $maxLivres",
                          style: TextStyle(
                            color: selecionadasLivres.length == maxLivres
                                ? Colors.green
                                : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: periciasDisponiveisParaLivres.map((p) {
                        bool isSelected = selecionadasLivres.contains(p.id);
                        return FilterChip(
                          label: Text(
                            p.nome,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? corLetra
                                  : Colors.grey.shade400,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: corTemaLocal,
                          backgroundColor: const Color(0xFF1A1A1A),
                          side: BorderSide(
                            color: isSelected
                                ? corDestaqueLocal
                                : Colors.grey.shade800,
                          ),
                          onSelected: (selected) {
                            setDialogState(() {
                              if (selected) {
                                if (selecionadasLivres.length < maxLivres) {
                                  selecionadasLivres.add(p.id);
                                }
                              } else {
                                selecionadasLivres.remove(p.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    if (novaClasse == 'especialista') ...[
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "PODER: PERITO",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${selecionadasPerito.length} / 2",
                            style: TextStyle(
                              color: selecionadasPerito.length == 2
                                  ? Colors.green
                                  : Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Escolha 2 perícias treinadas para ganhar o bônus de Perito (+1d6).",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: periciasDisponiveisParaPerito.map((p) {
                          bool isSelected = selecionadasPerito.contains(p.id);
                          return FilterChip(
                            label: Text(
                              p.nome,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? Colors.black
                                    : Colors.grey.shade400,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: Colors.deepPurpleAccent,
                            backgroundColor: const Color(0xFF1A1A1A),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.deepPurpleAccent
                                  : Colors.grey.shade800,
                            ),
                            onSelected: (selected) {
                              setDialogState(() {
                                if (selected) {
                                  if (selecionadasPerito.length < 2) {
                                    selecionadasPerito.add(p.id);
                                  }
                                } else {
                                  selecionadasPerito.remove(p.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {});
                            },
                            child: const Text(
                              "CANCELAR",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: corTemaLocal,
                              foregroundColor: corLetra,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: afinidadeAtual == 'Morte'
                                  ? const BorderSide(color: Colors.white54)
                                  : null,
                            ),
                            onPressed: podeConfirmar
                                ? () {
                                    setState(() {
                                      classeAtual = novaClasse;

                                      poderesEscolhidos.removeWhere(
                                        (p) =>
                                            p.startsWith("Ataque Especial") ||
                                            p.startsWith("Eclético") ||
                                            p.startsWith("Perito") ||
                                            p.startsWith(
                                              "Escolhido pelo Outro Lado",
                                            ),
                                      );

                                      if (novaClasse == 'combatente') {
                                        poderesEscolhidos.add(
                                          "Ataque Especial",
                                        );
                                      } else if (novaClasse == 'especialista') {
                                        poderesEscolhidos.add("Eclético");
                                        List<String> nomesPerito =
                                            selecionadasPerito
                                                .map(
                                                  (id) => listaPericias
                                                      .firstWhere(
                                                        (p) => p.id == id,
                                                      )
                                                      .nome,
                                                )
                                                .toList();
                                        poderesEscolhidos.add(
                                          "Perito (${nomesPerito.join(', ')})",
                                        );
                                      } else if (novaClasse == 'ocultista') {
                                        poderesEscolhidos.add(
                                          "Escolhido pelo Outro Lado",
                                        );
                                      }

                                      periciasClasse.clear();
                                      if (novaClasse == 'combatente') {
                                        periciasClasse.addAll([
                                          combOp1,
                                          combOp2,
                                        ]);
                                      } else if (novaClasse == 'ocultista') {
                                        periciasClasse.addAll([
                                          'ocultismo',
                                          'vontade',
                                        ]);
                                      }
                                      periciasClasse.addAll(selecionadasLivres);

                                      for (String id in periciasClasse) {
                                        var pericia = listaPericias.firstWhere(
                                          (p) => p.id == id,
                                        );
                                        if (pericia.treino < 5) {
                                          pericia.treino = 5;
                                        }
                                      }

                                      atualizarFicha();
                                    });
                                    _salvarSilencioso();
                                    Navigator.pop(context);
                                  }
                                : null,
                            child: const Text(
                              "CONFIRMAR",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // =========================================================================
  // SISTEMA DE CATÁLOGO DE PODERES
  // =========================================================================

  void _abrirCatalogoPoderes() {
    String busca = "";
    String filtroPrincipal = "Gerais";
    String filtroParanormal = "Conhecimento";

    Color corTemaLocal = corFundoAfinidade;
    Color corLetra = corTextoAfinidade;
    Color corDestaqueLocal = corDestaque;

    List<String> categoriasPrincipais = [
      "Gerais",
      "Combatente",
      "Especialista",
      "Ocultista",
      "Poderes Paranormais",
    ];
    List<String> categoriasParanormais = [
      "Conhecimento",
      "Energia",
      "Morte",
      "Sangue",
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            String filtroEfetivo = filtroPrincipal == "Poderes Paranormais"
                ? filtroParanormal
                : filtroPrincipal;

            List<Poder> listaAtiva = [];
            bool isParanormal = false;

            if (filtroEfetivo == "Gerais") {
              listaAtiva = catalogoPoderesGerais;
            } else if (filtroEfetivo == "Combatente") {
              listaAtiva = catalogoPoderesCombatente;
            } else if (filtroEfetivo == "Especialista") {
              listaAtiva = catalogoPoderesEspecialista;
            } else if (filtroEfetivo == "Ocultista") {
              listaAtiva = catalogoPoderesOcultista;
            } else if (filtroEfetivo == "Conhecimento") {
              listaAtiva = catalogoPoderesConhecimento;
              isParanormal = true;
            } else if (filtroEfetivo == "Energia") {
              listaAtiva = catalogoPoderesEnergia;
              isParanormal = true;
            } else if (filtroEfetivo == "Morte") {
              listaAtiva = catalogoPoderesMorte;
              isParanormal = true;
            } else if (filtroEfetivo == "Sangue") {
              listaAtiva = catalogoPoderesSangue;
              isParanormal = true;
            }

            List<Poder> filtrados = listaAtiva.where((p) {
              if (busca.isNotEmpty &&
                  !p.nome.toLowerCase().contains(busca.toLowerCase())) {
                return false;
              }

              if (isParanormal) {
                bool temAfinidade = poderesEscolhidos.contains(
                  "${p.nome} (Afinidade)",
                );
                if (temAfinidade) return false;
              } else {
                if (poderesEscolhidos.contains(p.nome)) return false;
              }

              return true;
            }).toList();

            return Dialog(
              backgroundColor: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: corDestaqueLocal.withValues(alpha: 0.3),
                ),
              ),
              insetPadding: const EdgeInsets.all(16),
              child: Container(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.85,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bolt, color: corDestaqueLocal, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          "PODERES",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: corDestaqueLocal,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: EstiloParanormal.customInputDeco(
                        "Pesquisar poder...",
                        corDestaqueLocal,
                        Icons.search,
                      ),
                      onChanged: (val) => setDialogState(() => busca = val),
                    ),
                    const SizedBox(height: 12),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categoriasPrincipais
                            .map(
                              (cat) => Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(
                                    cat,
                                    style: TextStyle(
                                      color: filtroPrincipal == cat
                                          ? corLetra
                                          : Colors.grey.shade400,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  selected: filtroPrincipal == cat,
                                  onSelected: (val) => setDialogState(
                                    () => filtroPrincipal = cat,
                                  ),
                                  selectedColor: corTemaLocal,
                                  backgroundColor: const Color(0xFF0D0D0D),
                                  side: BorderSide(
                                    color: filtroPrincipal == cat
                                        ? corDestaqueLocal
                                        : Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    if (filtroPrincipal == "Poderes Paranormais") ...[
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: categoriasParanormais.map((cat) {
                            Color corElemento;
                            switch (cat) {
                              case 'Sangue':
                                corElemento = const Color(0xFF990000);
                                break;
                              case 'Energia':
                                corElemento = const Color(0xFF9900FF);
                                break;
                              case 'Conhecimento':
                                corElemento = const Color(0xFFFFB300);
                                break;
                              case 'Morte':
                              default:
                                corElemento = Colors.black;
                                break;
                            }

                            Color corTxtSelecionado =
                                (cat == 'Conhecimento' || cat == 'Morte')
                                ? Colors.black
                                : Colors.white;
                            if (cat == 'Morte') {
                              corTxtSelecionado =
                                  Colors.white; // Fundo preto = texto branco
                            }

                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(
                                  cat,
                                  style: TextStyle(
                                    color: filtroParanormal == cat
                                        ? corTxtSelecionado
                                        : corElemento,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                selected: filtroParanormal == cat,
                                onSelected: (val) => setDialogState(
                                  () => filtroParanormal = cat,
                                ),
                                selectedColor: corElemento,
                                backgroundColor: const Color(0xFF0D0D0D),
                                side: BorderSide(
                                  color: filtroParanormal == cat
                                      ? (cat == 'Morte'
                                            ? Colors.white54
                                            : corElemento)
                                      : Colors.grey.shade900,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade800),
                        ),
                        child: filtrados.isEmpty
                            ? const Center(
                                child: Text(
                                  "Nenhum poder encontrado na categoria atual.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filtrados.length,
                                itemBuilder: (context, index) {
                                  var p = filtrados[index];
                                  bool upandoAfinidade =
                                      isParanormal &&
                                      poderesEscolhidos.contains(p.nome);

                                  Color corTitulo = Colors.white;
                                  if (isParanormal) {
                                    if (filtroParanormal == 'Sangue') {
                                      corTitulo = const Color(0xFF990000);
                                    } else if (filtroParanormal == 'Energia') {
                                      corTitulo = const Color(0xFF9900FF);
                                    } else if (filtroParanormal ==
                                        'Conhecimento') {
                                      corTitulo = const Color(0xFFFFB300);
                                    } else {
                                      corTitulo = Colors.white;
                                    }
                                  }

                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade900,
                                        ),
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                      title: Text(
                                        upandoAfinidade
                                            ? "${p.nome} (Afinidade)"
                                            : p.nome,
                                        style: TextStyle(
                                          color: corTitulo,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            p.descricao,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                          if (p.preRequisitos != "Nenhum") ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              "Pré-req: ${p.preRequisitos}",
                                              style: TextStyle(
                                                color: corDestaqueLocal,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      trailing: Icon(
                                        upandoAfinidade
                                            ? Icons.upgrade
                                            : Icons.add_circle,
                                        color: corDestaqueLocal,
                                      ),
                                      onTap: () {
                                        setState(() {
                                          if (upandoAfinidade) {
                                            poderesEscolhidos.remove(p.nome);
                                            poderesEscolhidos.add(
                                              "${p.nome} (Afinidade)",
                                            );
                                          } else {
                                            poderesEscolhidos.add(p.nome);
                                          }
                                        });
                                        atualizarFicha();
                                        Navigator.pop(context);
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // =========================================================================
  // SISTEMA DE CATÁLOGO DE EQUIPAMENTOS
  // =========================================================================

  void _abrirCatalogoEquipamento({String filtroInicial = "Todos"}) {
    String filtroAtual = filtroInicial;
    String busca = "";
    Color corTemaLocal = corFundoAfinidade;
    Color corLetra = corTextoAfinidade;
    Color corDestaqueLocal = corDestaque;

    List<String> categorias = [
      "Todos",
      "Armas",
      "Acessórios",
      "Explosivos",
      "Itens Operacionais",
      "Medicamentos",
      "Munições",
      "Proteções",
      "Itens Paranormais",
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            List<dynamic> todosEquipamentos = [
              ...catalogoArmasOrdem,
              ...catalogoItensOrdem,
            ];
            List<dynamic> filtrados = todosEquipamentos.where((eq) {
              if (busca.isNotEmpty &&
                  !eq.nome.toLowerCase().contains(busca.toLowerCase())) {
                return false;
              }
              if (filtroAtual != "Todos") {
                if (filtroAtual == "Armas" && eq is! Arma) return false;
                if (filtroAtual != "Armas" && eq is Arma) return false;
                if (eq is ItemInventario) {
                  if (filtroAtual == "Acessórios" &&
                      (!eq.descricao.contains("Acessório") &&
                          !eq.nome.contains("Vestimenta"))) {
                    return false;
                  }
                  if (filtroAtual == "Explosivos" &&
                      !eq.descricao.contains("Explosivo")) {
                    return false;
                  }
                  if (filtroAtual == "Itens Operacionais" &&
                      !eq.descricao.contains("Item Operacional")) {
                    return false;
                  }
                  if (filtroAtual == "Medicamentos" &&
                      !eq.descricao.contains("Medicamento")) {
                    return false;
                  }
                  if (filtroAtual == "Munições" &&
                      !eq.descricao.contains("Munição")) {
                    return false;
                  }
                  if (filtroAtual == "Proteções" &&
                      !eq.descricao.contains("Proteção")) {
                    return false;
                  }
                  if (filtroAtual == "Itens Paranormais" &&
                      !eq.descricao.contains("Item Paranormal")) {
                    return false;
                  }
                }
              }
              return true;
            }).toList();

            return Dialog(
              backgroundColor: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: corDestaqueLocal.withValues(alpha: 0.3),
                ),
              ),
              insetPadding: const EdgeInsets.all(16),
              child: Container(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.85,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2,
                          color: corDestaqueLocal,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "ARSENAL",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: corDestaqueLocal,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: EstiloParanormal.customInputDeco(
                        "Pesquisar equipamento...",
                        corDestaqueLocal,
                        Icons.search,
                      ),
                      onChanged: (val) => setDialogState(() => busca = val),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categorias
                            .map(
                              (cat) => Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(
                                    cat,
                                    style: TextStyle(
                                      color: filtroAtual == cat
                                          ? corLetra
                                          : Colors.grey.shade400,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  selected: filtroAtual == cat,
                                  onSelected: (val) =>
                                      setDialogState(() => filtroAtual = cat),
                                  selectedColor: corTemaLocal,
                                  backgroundColor: const Color(0xFF0D0D0D),
                                  side: BorderSide(
                                    color: filtroAtual == cat
                                        ? corDestaqueLocal
                                        : Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade800),
                        ),
                        child: filtrados.isEmpty
                            ? const Center(
                                child: Text(
                                  "Equipamento não encontrado",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filtrados.length,
                                itemBuilder: (context, index) {
                                  var eq = filtrados[index];
                                  bool isArma = eq is Arma;
                                  return ListTile(
                                    title: Text(
                                      eq.nome,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      isArma
                                          ? "Cat: ${eq.categoria} | Espaço: ${eq.espaco.toString().replaceAll('.0', '')} | Dano: ${eq.dano}"
                                          : "Cat: ${eq.categoria} | Espaço: ${eq.espaco.toString().replaceAll('.0', '')} | ${eq.descricao}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.add_circle,
                                      color: corDestaqueLocal,
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _configurarAdicaoEquipamento(eq);
                                    },
                                  );
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.handyman, size: 18),
                            label: const Text(
                              "CRIAR ITEM",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.grey.shade800),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _mostrarDialogCriacaoManual(isArma: false);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.colorize, size: 18),
                            label: const Text(
                              "CRIAR ARMA",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.grey.shade800),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _mostrarDialogCriacaoManual(isArma: true);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _processarNovoItem(ItemInventario novoItem) {
    if (novoItem.nome.toLowerCase().contains("vestimenta")) {
      _mostrarDialogEscolherPericiaParaNovoItem(novoItem);
    } else {
      setState(() => inventario.add(novoItem));
      _salvarSilencioso();
    }
  }

  void _mostrarDialogEscolherPericiaParaNovoItem(ItemInventario itemBase) {
    String periciaSelecionada = listaPericias.first.id;
    String nomePericia = listaPericias.first.nome;
    Color corTemaLocal = corFundoAfinidade;
    Color corDestaqueLocal = corDestaque;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: corDestaqueLocal.withValues(alpha: 0.3)),
          ),
          title: Row(
            children: [
              Icon(Icons.checkroom, color: corDestaqueLocal),
              const SizedBox(width: 8),
              Text(
                "Costurar Vestimenta",
                style: TextStyle(
                  color: corDestaqueLocal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Escolha qual perícia esta vestimenta vai aprimorar:",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: periciaSelecionada,
                dropdownColor: const Color(0xFF1A1A1A),
                style: const TextStyle(color: Colors.white),
                decoration: EstiloParanormal.customInputDeco(
                  "Perícia",
                  corDestaqueLocal,
                  Icons.star,
                ),
                items: listaPericias
                    .map(
                      (p) => DropdownMenuItem(value: p.id, child: Text(p.nome)),
                    )
                    .toList(),
                onChanged: (val) {
                  periciaSelecionada = val!;
                  nomePericia = listaPericias
                      .firstWhere((p) => p.id == val)
                      .nome;
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: corTemaLocal,
                foregroundColor: corTextoAfinidade,
                side: afinidadeAtual == 'Morte'
                    ? const BorderSide(color: Colors.white54)
                    : null,
              ),
              onPressed: () {
                setState(() {
                  itemBase.periciaVinculada = periciaSelecionada;
                  itemBase.nome = "Vestimenta de $nomePericia";
                  inventario.add(itemBase);
                  atualizarFicha();
                });
                _salvarSilencioso();
                Navigator.pop(context);
              },
              child: const Text(
                "Confirmar",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _configurarAdicaoEquipamento(dynamic equipamentoBase) {
    Color corTemaLocal = corFundoAfinidade;
    Color corLetra = corTextoAfinidade;
    Color corDestaqueLocal = corDestaque;

    bool isArma = equipamentoBase is Arma;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: corDestaqueLocal.withValues(alpha: 0.3)),
          ),
          insetPadding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "ADICIONAR: ${equipamentoBase.nome.toUpperCase()}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: corDestaqueLocal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isArma
                      ? "Dano: ${equipamentoBase.dano} | Crítico: ${equipamentoBase.margemAmeaca}/x${equipamentoBase.multiplicadorCritico}"
                      : equipamentoBase.descricao,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _abrirCatalogoEquipamento();
                        },
                        child: const Text(
                          "VOLTAR",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: corTemaLocal,
                          foregroundColor: corLetra,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: afinidadeAtual == 'Morte'
                              ? const BorderSide(color: Colors.white54)
                              : null,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          if (isArma) {
                            Arma a = equipamentoBase;
                            setState(() {
                              armas.add(
                                Arma(
                                  nome: a.nome,
                                  tipo: a.tipo,
                                  dano: a.dano,
                                  margemAmeaca: a.margemAmeaca,
                                  multiplicadorCritico: a.multiplicadorCritico,
                                  categoria: a.categoria,
                                  espaco: a.espaco,
                                  proficiencia: a.proficiencia,
                                  empunhadura: a.empunhadura,
                                ),
                              );
                            });
                            _salvarSilencioso();
                          } else {
                            ItemInventario i =
                                equipamentoBase as ItemInventario;
                            _processarNovoItem(
                              ItemInventario(
                                nome: i.nome,
                                categoria: i.categoria,
                                espaco: i.espaco,
                                descricao: i.descricao,
                              ),
                            );
                          }
                        },
                        child: const Text(
                          "ADICIONAR",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarDialogModificarEquipamento(
    dynamic equipamento,
    int indexNaLista,
  ) {
    Color corTemaLocal = corFundoAfinidade;
    Color corLetra = corTextoAfinidade;
    Color corDestaqueLocal = corDestaque;

    bool isArma = equipamento is Arma;
    bool isMunicao =
        !isArma &&
        (equipamento as ItemInventario).descricao.contains("Munição");
    bool isProtecao =
        !isArma &&
        (equipamento as ItemInventario).descricao.contains("Proteção");
    bool isVestimenta =
        !isArma &&
        (equipamento as ItemInventario).nome.toLowerCase().contains(
          "vestimenta",
        );

    List<String> modsDisponiveis = [];
    if (isArma) {
      modsDisponiveis = (equipamento).tipo == "Fogo"
          ? [
              "Alongada",
              "Calibre Grosso",
              "Compensador",
              "Discreta",
              "Ferrolho Automático",
              "Mira Laser",
              "Mira Telescópica",
              "Silenciador",
              "Tática",
              "Visão de Calor",
            ]
          : ["Certeira", "Cruel", "Discreta", "Perigosa", "Tática"];
    } else if (isMunicao) {
      modsDisponiveis = ["Dum dum", "Explosiva"];
    } else if (isProtecao) {
      modsDisponiveis = ["Antibombas", "Blindada", "Discreta", "Reforçada"];
    } else if (isVestimenta) {
      modsDisponiveis = ["Aprimorada"];
    }

    if (modsDisponiveis.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Este equipamento não suporta modificações."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    List<String> modsSelecionados = List.from(equipamento.modificacoes);
    String catBase = equipamento.categoria;

    int getCatInt(String c) {
      if (c == 'I') return 1;
      if (c == 'II') return 2;
      if (c == 'III') return 3;
      if (c == 'IV') return 4;
      return 0;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool podeAdicionarMaisMods =
                (getCatInt(catBase) + modsSelecionados.length) < 4;

            return Dialog(
              backgroundColor: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: corDestaqueLocal.withValues(alpha: 0.3),
                ),
              ),
              insetPadding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.build, color: corDestaqueLocal, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "BANCADA DE MELHORIAS",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: corDestaqueLocal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      equipamento.nome,
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "MODIFICAÇÕES",
                          style: TextStyle(
                            color: corDestaqueLocal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!podeAdicionarMaisMods)
                          const Text(
                            "LIMITE ATINGIDO",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: modsDisponiveis.map((mod) {
                        bool isSelected = modsSelecionados.contains(mod);
                        return FilterChip(
                          label: Text(
                            mod,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? corLetra
                                  : Colors.grey.shade400,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: corTemaLocal,
                          backgroundColor: const Color(0xFF1A1A1A),
                          side: BorderSide(
                            color: isSelected
                                ? corDestaqueLocal
                                : Colors.grey.shade800,
                          ),
                          onSelected: (selected) {
                            setDialogState(() {
                              if (selected) {
                                if (podeAdicionarMaisMods) {
                                  modsSelecionados.add(mod);
                                }
                              } else {
                                modsSelecionados.remove(mod);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "CANCELAR",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: corTemaLocal,
                              foregroundColor: corLetra,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: afinidadeAtual == 'Morte'
                                  ? const BorderSide(color: Colors.white54)
                                  : null,
                            ),
                            onPressed: () {
                              setState(() {
                                if (isArma) {
                                  armas[indexNaLista].modificacoes = List.from(
                                    modsSelecionados,
                                  );
                                } else {
                                  inventario[indexNaLista].modificacoes =
                                      List.from(modsSelecionados);
                                }
                                atualizarFicha();
                              });
                              _salvarSilencioso();
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "APLICAR",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarDialogCriacaoManual({required bool isArma}) {
    String nome = "",
        tipo = isArma ? "Corpo a Corpo" : "I",
        dano = "1d4",
        desc = "";
    String categoria = "0", proficiencia = "Simples", empunhadura = "Uma Mão";
    int margem = 20, mult = 2;
    double espaco = 1.0;

    Color corTemaLocal = corFundoAfinidade;
    Color corLetra = corTextoAfinidade;
    Color corDestaqueLocal = corDestaque;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: corDestaqueLocal.withValues(alpha: 0.3)),
        ),
        insetPadding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    isArma ? Icons.colorize : Icons.backpack,
                    color: corDestaqueLocal,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isArma ? "CRIAR ARMA" : "CRIAR ITEM",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: corDestaqueLocal,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                decoration: EstiloParanormal.customInputDeco(
                  "Nome",
                  corDestaqueLocal,
                  Icons.edit,
                ),
                onChanged: (val) => nome = val,
              ),
              const SizedBox(height: 16),
              if (isArma) ...[
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: tipo,
                        decoration: EstiloParanormal.customInputDeco(
                          "Tipo",
                          corDestaqueLocal,
                          Icons.category,
                        ),
                        items: ["Corpo a Corpo", "Fogo", "Arremesso", "Disparo"]
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                        onChanged: (val) => tipo = val!,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        decoration: EstiloParanormal.customInputDeco(
                          "Dano",
                          corDestaqueLocal,
                          Icons.casino,
                        ),
                        onChanged: (val) => dano = val,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: EstiloParanormal.customInputDeco(
                          "Margem",
                          corDestaqueLocal,
                          Icons.warning_amber,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => margem = int.tryParse(val) ?? 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        decoration: EstiloParanormal.customInputDeco(
                          "Crítico (x)",
                          corDestaqueLocal,
                          Icons.close,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => mult = int.tryParse(val) ?? 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: proficiencia,
                        decoration: EstiloParanormal.customInputDeco(
                          "Proficiência",
                          corDestaqueLocal,
                          Icons.military_tech,
                        ),
                        items: ["Simples", "Táticas", "Pesadas"]
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                        onChanged: (val) => proficiencia = val!,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: empunhadura,
                        decoration: EstiloParanormal.customInputDeco(
                          "Empunhadura",
                          corDestaqueLocal,
                          Icons.front_hand,
                        ),
                        items: ["Leve", "Uma Mão", "Duas Mãos"]
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                        onChanged: (val) => empunhadura = val!,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: categoria,
                      decoration: EstiloParanormal.customInputDeco(
                        "Categoria",
                        corDestaqueLocal,
                        Icons.format_list_bulleted,
                      ),
                      items: ["0", "I", "II", "III", "IV"]
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (val) => categoria = val!,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: EstiloParanormal.customInputDeco(
                        "Espaço",
                        corDestaqueLocal,
                        Icons.scale,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (val) => espaco =
                          double.tryParse(val.replaceAll(',', '.')) ?? 1.0,
                    ),
                  ),
                ],
              ),
              if (!isArma) ...[
                const SizedBox(height: 16),
                TextField(
                  decoration: EstiloParanormal.customInputDeco(
                    "Detalhes / Efeitos",
                    corDestaqueLocal,
                    Icons.info_outline,
                  ),
                  maxLines: 3,
                  minLines: 1,
                  onChanged: (val) => desc = val,
                ),
              ],
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _abrirCatalogoEquipamento();
                      },
                      child: const Text(
                        "CANCELAR",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: corTemaLocal,
                        foregroundColor: corLetra,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: afinidadeAtual == 'Morte'
                            ? const BorderSide(color: Colors.white54)
                            : null,
                      ),
                      onPressed: () {
                        if (nome.isNotEmpty) {
                          Navigator.pop(context);
                          if (isArma) {
                            setState(
                              () => armas.add(
                                Arma(
                                  nome: nome,
                                  tipo: tipo,
                                  dano: dano,
                                  margemAmeaca: margem,
                                  multiplicadorCritico: mult,
                                  categoria: categoria,
                                  espaco: espaco,
                                  proficiencia: proficiencia,
                                  empunhadura: empunhadura,
                                ),
                              ),
                            );
                            _salvarSilencioso();
                          } else {
                            _processarNovoItem(
                              ItemInventario(
                                nome: nome,
                                categoria: categoria,
                                espaco: espaco,
                                descricao: desc,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(
                        "CRIAR",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void atualizarFicha({bool isInitialLoad = false}) {
    setState(() {
      if (nex < 50 && afinidadeAtual != null) {
        afinidadeAtual = null;
      }
      var origemData = dadosOrigens[origemAtual];
      if (origemData != null) {
        habNome = origemData.nomeHabilidade;
        habDesc = origemData.descHabilidade;
        for (var p in listaPericias) {
          if (p.daOrigem) {
            if (p.treino <= 5) p.treino = 0;
            p.daOrigem = false;
          }
        }
        for (var p in listaPericias) {
          if (origemData.pericias.contains(p.id)) {
            if (p.treino < 5) p.treino = 5;
            p.daOrigem = true;
          }
        }
      }

      for (var p in listaPericias) {
        if (periciasClasse.contains(p.id)) {
          if (p.treino < 5) p.treino = 5;
        }
      }

      var stats = dadosClasses[classeAtual];
      if (stats != null) {
        int nivel = (nex / 5).toInt();
        pvMax = stats.pvBase + (vig * nivel) + (stats.pvPorNivel * (nivel - 1));
        peMax = stats.peBase + (pre * nivel) + (stats.pePorNivel * (nivel - 1));

        int sanidadePerdidaPorTranscender = 0;
        int quantidadePoderesParanormais = 0;

        List<Poder> todosParanormais = [
          ...catalogoPoderesConhecimento,
          ...catalogoPoderesEnergia,
          ...catalogoPoderesMorte,
          ...catalogoPoderesSangue,
        ];

        for (String nomePoderEscolhido in poderesEscolhidos) {
          String nomeBase = nomePoderEscolhido.replaceAll(" (Afinidade)", "");
          if (todosParanormais.any((p) => p.nome == nomeBase)) {
            quantidadePoderesParanormais++;
          }
        }

        sanidadePerdidaPorTranscender =
            quantidadePoderesParanormais * stats.sanPorNivel;
        sanMax =
            stats.sanBase +
            (stats.sanPorNivel * (nivel - 1)) -
            sanidadePerdidaPorTranscender;
        if (sanMax < 0) sanMax = 0;
      } else {
        if (isInitialLoad && widget.agenteParaEditar == null) {
          pvMax = 0;
          peMax = 0;
          sanMax = 0;
        }
      }

      int defItens = 0;
      for (var item in inventario.where((i) => i.equipado)) {
        String nomeLower = item.nome.toLowerCase();
        String descLower = item.descricao.toLowerCase();

        if (descLower.contains("proteção") || nomeLower.contains("escudo")) {
          if (nomeLower.contains("leve")) defItens += 5;
          if (nomeLower.contains("pesada")) defItens += 10;
          if (nomeLower.contains("escudo")) defItens += 2;
          if (item.modificacoes.contains("Reforçada")) defItens += 2;
        }
      }

      int bReflexos = 0, bFortitude = 0;
      for (var p in listaPericias) {
        if (p.id == 'reflexos') bReflexos = p.treino;
        if (p.id == 'fortitude') bFortitude = p.treino;
      }

      defesa = 10 + agi + defItens;
      esquiva = defesa + bReflexos;
      bloqueio = bFortitude;

      if (isInitialLoad && widget.agenteParaEditar == null) {
        pvAtual = pvMax;
        peAtual = peMax;
        sanAtual = sanMax;
      }
    });
    if (!isInitialLoad) _salvarSilencioso();
  }

  void _mostrarDialogEscolherPericia(ItemInventario item) {
    String periciaSelecionada = listaPericias.first.id;
    Color corDestaqueLocal = corDestaque;
    Color corTemaLocal = corFundoAfinidade;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: corDestaqueLocal.withValues(alpha: 0.3)),
          ),
          title: Row(
            children: [
              Icon(Icons.checkroom, color: corDestaqueLocal),
              const SizedBox(width: 8),
              Text(
                "Vestimenta",
                style: TextStyle(
                  color: corDestaqueLocal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Escolha a perícia que receberá o bônus desta vestimenta:",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: periciaSelecionada,
                dropdownColor: const Color(0xFF1A1A1A),
                style: const TextStyle(color: Colors.white),
                decoration: EstiloParanormal.customInputDeco(
                  "Perícia",
                  corDestaqueLocal,
                  Icons.star,
                ),
                items: listaPericias
                    .map(
                      (p) => DropdownMenuItem(value: p.id, child: Text(p.nome)),
                    )
                    .toList(),
                onChanged: (val) => periciaSelecionada = val!,
              ),
            ],
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
                backgroundColor: corTemaLocal,
                foregroundColor: corTextoAfinidade,
                side: afinidadeAtual == 'Morte'
                    ? const BorderSide(color: Colors.white54)
                    : null,
              ),
              onPressed: () {
                setState(() {
                  item.equipado = true;
                  item.periciaVinculada = periciaSelecionada;
                  atualizarFicha();
                });
                Navigator.pop(context);
              },
              child: const Text(
                "Equipar",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleEquiparItem(ItemInventario item) {
    if (_modoVisualizacao) return;

    bool isVestimenta = item.nome.toLowerCase().contains("vestimenta");
    bool isProtecao = item.descricao.toLowerCase().contains("proteção");
    bool isEscudo = item.nome.toLowerCase().contains("escudo");

    if (!item.equipado) {
      if (isVestimenta) {
        int equipadas = inventario
            .where(
              (i) => i.equipado && i.nome.toLowerCase().contains("vestimenta"),
            )
            .length;
        int limiteVestimentas = poderesEscolhidos.contains("Mochileiro")
            ? 3
            : 2;

        if (equipadas >= limiteVestimentas) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Limite: Você só pode vestir $limiteVestimentas vestimentas ao mesmo tempo!",
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }
        _mostrarDialogEscolherPericia(item);
        return;
      }

      if (isProtecao) {
        if (isEscudo) {
          if (maosOcupadas + 1 > 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Limite: Você não tem mãos livres suficientes para equipar o Escudo!",
                ),
                backgroundColor: Colors.redAccent,
              ),
            );
            return;
          }
          if (inventario.any(
            (i) => i.equipado && i.nome.toLowerCase().contains("escudo"),
          )) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Limite: Você já tem um escudo equipado!"),
                backgroundColor: Colors.redAccent,
              ),
            );
            return;
          }
        } else {
          if (inventario.any(
            (i) =>
                i.equipado &&
                i.descricao.toLowerCase().contains("proteção") &&
                !i.nome.toLowerCase().contains("escudo"),
          )) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Limite: Você só pode usar 1 proteção por vez! (Mas pode usar 1 Escudo junto)",
                ),
                backgroundColor: Colors.redAccent,
              ),
            );
            return;
          }
        }
      }
    }

    setState(() {
      item.equipado = !item.equipado;
      atualizarFicha();
    });
  }

  void _toggleEquiparArma(Arma arma) {
    if (_modoVisualizacao) return;

    if (!arma.equipado) {
      int custoMaos = arma.empunhadura == 'Duas Mãos' ? 2 : 1;
      if (maosOcupadas + custoMaos > 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Limite: Você não tem mãos livres suficientes para empunhar essa arma!",
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    setState(() {
      arma.equipado = !arma.equipado;
      atualizarFicha();
    });
  }

  // =========================================================================
  // SISTEMA DE ABAS (FUNÇÕES DE CONSTRUÇÃO)
  // =========================================================================

  Widget _buildAbaAtributos(bool block, Color corDoPainel) {
    List<Arma> armasEquipadas = armas.where((a) => a.equipado).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: AvatarPulsante(
              afinidade: afinidadeAtual,
              corTema: corDoPainel,
              fotoPath: fotoPath,
              isVisualizacao: block,
              onTap: _escolherFoto,
            ),
          ),
          const SizedBox(height: 16),
          if (nex >= 50 && afinidadeAtual == null && !block)
            Center(
              child: BotaoAfinidadeAnimado(onPressed: _mostrarDialogAfinidade),
            ),

          _buildSecao("Detalhes", [
            TextFormField(
              controller: _nomeController,
              enabled: !block,
              decoration: const InputDecoration(
                labelText: "Nome",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color(0xFF0D0D0D),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    "Classe",
                    classeAtual,
                    ['--', ...dadosClasses.keys],
                    block
                        ? null
                        : (val) {
                            if (val != classeAtual) {
                              if (val == '--') {
                                setState(() {
                                  classeAtual = val!;
                                });
                                atualizarFicha();
                              } else {
                                _mostrarDialogPericiasClasse(val!);
                              }
                            }
                          },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(
                    "Origem",
                    origemAtual,
                    dadosOrigens.keys.toList(),
                    block
                        ? null
                        : (val) {
                            origemAtual = val!;
                            atualizarFicha();
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              "NEX (%)",
              nex.toString(),
              List.generate(20, (i) => ((i + 1) * 5).toString()),
              block
                  ? null
                  : (val) {
                      nex = int.parse(val!);
                      atualizarFicha();
                    },
            ),
          ]),

          _buildSecao("Atributos ${block ? '(Toque para Rolar)' : ''}", [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAtributoInput("AGI", agi, block, (val) {
                  agi = int.tryParse(val) ?? 0;
                  atualizarFicha();
                }),
                _buildAtributoInput("FOR", forc, block, (val) {
                  forc = int.tryParse(val) ?? 0;
                  atualizarFicha();
                }),
                _buildAtributoInput("INT", inte, block, (val) {
                  inte = int.tryParse(val) ?? 0;
                  atualizarFicha();
                }),
                _buildAtributoInput("PRE", pre, block, (val) {
                  pre = int.tryParse(val) ?? 0;
                  atualizarFicha();
                }),
                _buildAtributoInput("VIG", vig, block, (val) {
                  vig = int.tryParse(val) ?? 0;
                  atualizarFicha();
                }),
              ],
            ),
          ]),

          _buildSecao("Status", [
            _buildBarraStatus(
              "PONTOS DE VIDA (PV)",
              pvAtual,
              pvMax,
              Colors.red,
              (val) {
                setState(() => pvAtual = val.clamp(0, pvMax));
                _salvarSilencioso();
              },
            ),
            const SizedBox(height: 16),
            _buildBarraStatus(
              "PONTOS DE ESFORÇO (PE)",
              peAtual,
              peMax,
              Colors.blue,
              (val) {
                setState(() => peAtual = val.clamp(0, peMax));
                _salvarSilencioso();
              },
            ),
            const SizedBox(height: 16),
            _buildBarraStatus(
              "SANIDADE (SAN)",
              sanAtual,
              sanMax,
              Colors.blueGrey,
              (val) {
                setState(() => sanAtual = val.clamp(0, sanMax));
                _salvarSilencioso();
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(color: Colors.grey),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusFixo("Defesa", defesa),
                _buildStatusFixo("Esquiva", esquiva),
                _buildStatusFixo("Bloqueio", bloqueio),
              ],
            ),
          ]),

          _buildSecao("Ataques (Armas Equipadas)", [
            if (armasEquipadas.isEmpty)
              const Text(
                "Nenhuma arma empunhada. Vá ao inventário para equipar uma arma.",
                style: TextStyle(color: Colors.grey),
              ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: armasEquipadas.length,
              itemBuilder: (context, index) {
                final arma = armasEquipadas[index];
                bool isProficiente =
                    arma.proficiencia == 'Simples' ||
                    (arma.proficiencia == 'Táticas' &&
                        classeAtual == 'combatente');
                String alertaProf = isProficiente
                    ? ""
                    : "\n⚠️ Não proficiente: -2d20 no Ataque";
                String modDano = "";
                if (arma.tipo == 'Corpo a Corpo' || arma.tipo == 'Arremesso') {
                  if (forc > 0) {
                    modDano = "+$forc";
                  } else if (forc < 0) {
                    modDano = "$forc";
                  }
                }
                return Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0D0D),
                    border: Border.all(color: Colors.grey.shade800),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ListTile(
                    title: Text(
                      arma.nome,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Dano: ${arma.dano}$modDano | Crítico: ${arma.margemAmeaca}/x${arma.multiplicadorCritico} \nTipo: ${arma.tipo}$alertaProf",
                          style: TextStyle(
                            color: isProficiente
                                ? Colors.grey
                                : Colors.redAccent,
                          ),
                        ),
                        if (arma.modificacoes.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              "Mods: ${arma.modificacoes.join(', ')}",
                              style: TextStyle(
                                color: corDoPainel,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: block
                        ? () {
                            int d20 = Random().nextInt(20) + 1;
                            Color corD20 = Colors.white;
                            String msgCrit = "";
                            if (d20 == 20) {
                              corD20 = Colors.amberAccent;
                              msgCrit = "SUCESSO CRÍTICO!";
                            } else if (d20 == 1) {
                              corD20 = Colors.redAccent;
                              msgCrit = "FALHA CRÍTICA!";
                            }

                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: const Color(0xFF1A1A1A),
                                title: Text(
                                  "Ataque: ${arma.nome}",
                                  style: TextStyle(color: corDoPainel),
                                ),
                                content: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      fontFamily: 'sans-serif',
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: "Teste de Ataque (d20):\n",
                                      ),
                                      TextSpan(
                                        text: "$d20",
                                        style: TextStyle(
                                          color: corD20,
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (msgCrit.isNotEmpty)
                                        TextSpan(
                                          text: "\n$msgCrit\n",
                                          style: TextStyle(
                                            color: corD20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      const TextSpan(text: "\n\n"),
                                      TextSpan(
                                        text:
                                            "Dano: ${arma.dano}$modDano\n$alertaProf",
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      "OK",
                                      style: TextStyle(color: corDoPainel),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        : null,
                  ),
                );
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildAbaPericias(bool block, Color corDoPainel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: _buildSecao("Perícias", [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: listaPericias.length,
          itemBuilder: (context, index) {
            var pericia = listaPericias[index];

            int bonusExtra = 0;
            var vestimentas = inventario.where(
              (i) => i.equipado && i.periciaVinculada == pericia.id,
            );
            for (var v in vestimentas) {
              int b = v.modificacoes.contains("Aprimorada") ? 5 : 2;
              if (b > bonusExtra) bonusExtra = b;
            }

            int totalBonus = pericia.treino + bonusExtra;
            bool isLocked =
                pericia.daOrigem || periciasClasse.contains(pericia.id);

            return Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade800)),
                color: pericia.treino > 0
                    ? corDoPainel.withValues(alpha: 0.1)
                    : Colors.transparent,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${pericia.nome} (${pericia.atributo})",
                            style: TextStyle(
                              color: pericia.treino > 0
                                  ? Colors.white
                                  : Colors.grey,
                              fontWeight: pericia.treino > 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (bonusExtra > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 4, right: 4),
                            child: Icon(
                              Icons.checkroom,
                              color: corDoPainel,
                              size: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: pericia.treino,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down, size: 16),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                        items: [
                          if (!isLocked)
                            const DropdownMenuItem(
                              value: 0,
                              child: Text("Destreinado (+0)"),
                            ),
                          const DropdownMenuItem(
                            value: 5,
                            child: Text("Treinado (+5)"),
                          ),
                          const DropdownMenuItem(
                            value: 10,
                            child: Text("Veterano (+10)"),
                          ),
                          const DropdownMenuItem(
                            value: 15,
                            child: Text("Expert (+15)"),
                          ),
                        ],
                        onChanged: block
                            ? null
                            : (val) {
                                setState(() {
                                  pericia.treino = val!;
                                  atualizarFicha();
                                });
                              },
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "+",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 35,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade800),
                    ),
                    child: Text(
                      "+$bonusExtra",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "=",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 35,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: corDoPainel.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: corDoPainel.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      "+$totalBonus",
                      style: TextStyle(
                        color: corDoPainel,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ]),
    );
  }

  Widget _buildAbaHabilidades(bool block, Color corDoPainel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSecao("Habilidade de Origem: $habNome", [
            Text(
              habDesc,
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
          ]),

          if (afinidadeAtual != null)
            _buildSecao("Afinidade Elemental", [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D0D),
                  border: Border.all(color: corDoPainel, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Afinidade: ${afinidadeAtual!.toUpperCase()} | Opressor: ${_obterOpressor(afinidadeAtual!).toUpperCase()}",
                      style: TextStyle(
                        color: corDoPainel,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "• Não precisa de componentes ritualísticos para conjurar rituais do elemento com o qual tem afinidade. Além disso, pode aprender rituais que exijam afinidade com esse elemento.\n\n• Recebe +2d20 em testes contra efeitos do seu elemento, mas sofre –2d20 em testes contra efeitos do seu elemento opressor.\n\n• Pode escolher poderes paranormais do seu elemento uma segunda vez para receber o benefício listado na linha “Afinidade”.",
                      style: TextStyle(
                        color: Colors.grey,
                        height: 1.4,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ]),

          _buildSecao("Poderes", [
            if (!block)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _abrirCatalogoPoderes,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Poder"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corFundoAfinidade,
                    foregroundColor: corTextoAfinidade,
                    side: afinidadeAtual == 'Morte'
                        ? const BorderSide(color: Colors.white54)
                        : null,
                  ),
                ),
              ),
            if (poderesEscolhidos.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  "Nenhum poder escolhido.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: poderesEscolhidos.length,
              itemBuilder: (context, index) {
                String nomePoder = poderesEscolhidos[index];
                String nomeBase = nomePoder;
                if (nomePoder.startsWith("Perito (")) nomeBase = "Perito";
                if (nomePoder.endsWith(" (Afinidade)")) {
                  nomeBase = nomePoder.replaceAll(" (Afinidade)", "");
                }

                List<Poder> todosPoderes = [
                  ...catalogoPoderesGerais,
                  ...catalogoPoderesCombatente,
                  ...catalogoPoderesEspecialista,
                  ...catalogoPoderesOcultista,
                  ...catalogoPoderesConhecimento,
                  ...catalogoPoderesEnergia,
                  ...catalogoPoderesMorte,
                  ...catalogoPoderesSangue,
                ];

                Poder p = todosPoderes.firstWhere(
                  (pod) => pod.nome == nomeBase,
                  orElse: () => Poder(
                    nome: nomePoder,
                    tipo: "Desconhecido",
                    descricao: "Poder desconhecido.",
                  ),
                );
                bool isParanormal = [
                  "Conhecimento",
                  "Energia",
                  "Morte",
                  "Sangue",
                ].contains(p.tipo);

                return Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0D0D),
                    border: Border.all(color: Colors.grey.shade800),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      nomePoder,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isParanormal ? corDoPainel : Colors.white,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          p.descricao,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        if (p.preRequisitos != "Nenhum") ...[
                          const SizedBox(height: 4),
                          Text(
                            "Pré-req: ${p.preRequisitos}",
                            style: TextStyle(
                              color: corDoPainel,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: (() {
                      bool isPoderDeClasse =
                          nomeBase == "Ataque Especial" ||
                          nomeBase == "Eclético" ||
                          nomeBase == "Perito" ||
                          nomeBase == "Escolhido pelo Outro Lado";
                      if (block) return null;
                      if (isPoderDeClasse) {
                        return const Icon(
                          Icons.lock,
                          color: Colors.grey,
                          size: 20,
                        );
                      } else {
                        return IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            setState(() => poderesEscolhidos.removeAt(index));
                            atualizarFicha();
                          },
                        );
                      }
                    })(),
                  ),
                );
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildAbaRituais(bool block, Color corDoPainel) {
    return const Center(
      child: Text(
        "Grimório e Rituais serão implementados em breve...",
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _buildAbaInventario(bool block, Color corDoPainel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSecao("Painel de Controle", [
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: corDoPainel, width: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Patente: ${patenteAtual.toUpperCase()}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: corDoPainel,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Crédito: $limiteCredito",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 75,
                        child: TextFormField(
                          initialValue: prestigio.toString(),
                          enabled: !block,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          decoration: const InputDecoration(
                            labelText: "PP",
                            labelStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 8,
                            ),
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color(0xFF1A1A1A),
                          ),
                          onChanged: (val) {
                            prestigio = int.tryParse(val) ?? 0;
                            atualizarFicha();
                          },
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.grey),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ["I", "II", "III", "IV"].map((cat) {
                      int atual = usoCategoriaAtual[cat]!;
                      int max = limitesCategoria[cat]!;
                      bool excedeu = atual > max;
                      return Column(
                        children: [
                          Text(
                            "Cat $cat",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "$atual / $max",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: excedeu ? Colors.redAccent : Colors.white,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Espaço: ${espacoOcupado.toString().replaceAll('.0', '')} / $espacoMaximo",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: espacoOcupado > espacoMaximo
                        ? Colors.redAccent
                        : Colors.white,
                  ),
                ),
                if (!block)
                  ElevatedButton.icon(
                    onPressed: () => _abrirCatalogoEquipamento(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Equipamento"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: corFundoAfinidade,
                      foregroundColor: corTextoAfinidade,
                      side: afinidadeAtual == 'Morte'
                          ? const BorderSide(color: Colors.white54)
                          : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (inventario.isEmpty && armas.isEmpty)
              const Text(
                "Inventário vazio.",
                style: TextStyle(color: Colors.grey),
              ),

            ...armas.map((arma) {
              int index = armas.indexOf(arma);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D0D),
                  border: Border.all(color: Colors.grey.shade800),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  title: Text(
                    arma.nome,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Arma • Cat: ${arma.categoriaEfetiva} | Espaço: ${arma.espacoEfetivo.toString().replaceAll('.0', '')} \nProf: ${arma.proficiencia} | Emp: ${arma.empunhadura}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      if (arma.modificacoes.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "Mods: ${arma.modificacoes.join(', ')}",
                            style: TextStyle(
                              color: corDoPainel,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Equipar",
                            style: TextStyle(fontSize: 9, color: Colors.grey),
                          ),
                          SizedBox(
                            height: 24,
                            child: Checkbox(
                              value: arma.equipado,
                              activeColor: corDoPainel,
                              onChanged: block
                                  ? null
                                  : (val) => _toggleEquiparArma(arma),
                            ),
                          ),
                        ],
                      ),
                      if (!block)
                        IconButton(
                          icon: const Icon(Icons.build, color: Colors.blueGrey),
                          onPressed: () {
                            _mostrarDialogModificarEquipamento(arma, index);
                          },
                        ),
                      if (!block)
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            setState(() => armas.removeAt(index));
                            _salvarSilencioso();
                          },
                        ),
                    ],
                  ),
                ),
              );
            }),

            ...inventario.map((item) {
              int index = inventario.indexOf(item);
              bool isEquipavel =
                  item.descricao.toLowerCase().contains("proteção") ||
                  item.nome.toLowerCase().contains("vestimenta") ||
                  item.nome.toLowerCase().contains("escudo");

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D0D),
                  border: Border.all(color: Colors.grey.shade800),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  title: Text(
                    item.nome,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Item • Cat: ${item.categoriaEfetiva} | Espaço: ${item.espacoEfetivo.toString().replaceAll('.0', '')} \n${item.descricao}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      if (item.modificacoes.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "Mods: ${item.modificacoes.join(', ')}",
                            style: TextStyle(
                              color: corDoPainel,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isEquipavel)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Usar",
                              style: TextStyle(fontSize: 9, color: Colors.grey),
                            ),
                            SizedBox(
                              height: 24,
                              child: Checkbox(
                                value: item.equipado,
                                activeColor: corDoPainel,
                                onChanged: block
                                    ? null
                                    : (val) => _toggleEquiparItem(item),
                              ),
                            ),
                          ],
                        ),
                      if (!block)
                        IconButton(
                          icon: const Icon(Icons.build, color: Colors.blueGrey),
                          onPressed: () {
                            _mostrarDialogModificarEquipamento(item, index);
                          },
                        ),
                      if (!block)
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            setState(() => inventario.removeAt(index));
                            _salvarSilencioso();
                          },
                        ),
                    ],
                  ),
                ),
              );
            }),
          ]),
        ],
      ),
    );
  }

  // =========================================================================
  // WIDGETS AUXILIARES E FUNÇÕES DE BARRA FLUTUANTE
  // =========================================================================

  Widget _buildFloatingNavBar(bool block, Color corDoPainel) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: corDoPainel.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavBarItem(0, Icons.person, "Atributos", block, corDoPainel),
          _buildNavBarItem(1, Icons.star, "Perícias", block, corDoPainel),
          _buildNavBarItem(2, Icons.bolt, "Poderes", block, corDoPainel),
          _buildNavBarItem(
            3,
            Icons.auto_awesome,
            "Rituais",
            block,
            corDoPainel,
          ),
          _buildNavBarItem(4, Icons.backpack, "Inventário", block, corDoPainel),
        ],
      ),
    );
  }

  Widget _buildNavBarItem(
    int index,
    IconData icon,
    String label,
    bool block,
    Color corDoPainel,
  ) {
    bool isSelected = _abaAtual == index;
    Color itemColor = isSelected ? corDoPainel : Colors.grey.shade600;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _abaAtual = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? corDoPainel.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: itemColor, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: itemColor,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool block = _modoVisualizacao;
    Color corDoPainel = corDestaque;

    Widget conteudoDaAba;
    switch (_abaAtual) {
      case 0:
        conteudoDaAba = _buildAbaAtributos(block, corDoPainel);
        break;
      case 1:
        conteudoDaAba = _buildAbaPericias(block, corDoPainel);
        break;
      case 2:
        conteudoDaAba = _buildAbaHabilidades(block, corDoPainel);
        break;
      case 3:
        conteudoDaAba = _buildAbaRituais(block, corDoPainel);
        break;
      case 4:
        conteudoDaAba = _buildAbaInventario(block, corDoPainel);
        break;
      default:
        conteudoDaAba = _buildAbaAtributos(block, corDoPainel);
    }

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(
          block ? 'AGENTE' : 'EDITAR AGENTE',
          style: const TextStyle(fontFamily: 'Courier', letterSpacing: 2),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: corDoPainel, height: 2.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _salvarSilencioso();
            Navigator.pop(context, true);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(block ? Icons.edit : Icons.check, color: Colors.white),
            onPressed: () {
              setState(() => _modoVisualizacao = !_modoVisualizacao);
              if (_modoVisualizacao) _salvarSilencioso();
            },
          ),
        ],
      ),
      body: conteudoDaAba,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: _buildFloatingNavBar(block, corDoPainel),
        ),
      ),
    );
  }

  Widget _buildBarraStatus(
    String titulo,
    int atual,
    int maximo,
    Color cor,
    Function(int) onChanged,
  ) {
    double progresso = maximo == 0 ? 0 : atual / maximo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Text(
              "$atual / $maximo",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: () => onChanged(atual - 5),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.keyboard_double_arrow_left,
                  color: Colors.white54,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => onChanged(atual - 1),
              onLongPress: () => onChanged(0),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.remove_circle_outline,
                  color: Colors.white54,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onPanUpdate: (details) {
                      double percent =
                          details.localPosition.dx / constraints.maxWidth;
                      onChanged((percent * maximo).round());
                    },
                    onTapDown: (details) {
                      double percent =
                          details.localPosition.dx / constraints.maxWidth;
                      onChanged((percent * maximo).round());
                    },
                    child: Container(
                      height: 24,
                      alignment: Alignment.center,
                      color: Colors.transparent,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progresso,
                          minHeight: 12,
                          backgroundColor: Colors.grey.shade800,
                          color: cor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onChanged(atual + 1),
              onLongPress: () => onChanged(maximo),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.add_circle_outline,
                  color: Colors.white54,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => onChanged(atual + 5),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.keyboard_double_arrow_right,
                  color: Colors.white54,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAtributoInput(
    String label,
    int value,
    bool isVisu,
    Function(String) onChanged,
  ) {
    Color corDoPopUp = corDestaque;
    return GestureDetector(
      onTap: isVisu ? () => _rolarDado(label, value) : null,
      child: SizedBox(
        width: 65,
        child: TextFormField(
          initialValue: value.toString(),
          enabled: !isVisu,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isVisu ? corDoPopUp : Colors.white,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: const Color(0xFF0D0D0D),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSecao(String titulo, List<Widget> filhos) {
    Color corDoTema = corFundoAfinidade;
    Color corLetraTema = corTextoAfinidade;

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFF333333)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: corDoTema,
                border: afinidadeAtual == 'Morte'
                    ? Border.all(color: Colors.white54, width: 1)
                    : null,
                borderRadius: afinidadeAtual == 'Morte'
                    ? BorderRadius.circular(2)
                    : null,
              ),
              child: Text(
                titulo.toUpperCase(),
                style: TextStyle(
                  color: corLetraTema,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...filhos,
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> options,
    Function(String?)? onChanged,
  ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: const Color(0xFF0D0D0D),
      ),
      initialValue: value,
      isExpanded: true,
      items: options
          .map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase())))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildStatusFixo(String label, int value) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  void _inicializarPericias() {
    listaPericias = periciasBase
        .map(
          (p) =>
              Pericia(nome: p["nome"]!, atributo: p["atributo"]!, id: p["id"]!),
        )
        .toList();
  }
}
