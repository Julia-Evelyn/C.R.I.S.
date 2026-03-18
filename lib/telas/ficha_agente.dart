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
import '../componentes/widgets_ficha.dart';
import '../componentes/dialogs_ficha.dart';

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

  // === NOVAS VARIÁVEIS DE ESTADO ===
  Map<String, int> resistencias = {};
  Map<String, int> bonusOrigem = {};
  // =================================

  String classeAtual = '--', origemAtual = '--';
  String? fotoPath;
  String? afinidadeAtual;
  int nex = 5, prestigio = 0, agi = 1, forc = 1, inte = 1, pre = 1, vig = 1;
  int pvMax = 0, peMax = 0, sanMax = 0, pvAtual = 0, peAtual = 0, sanAtual = 0;
  int defesa = 10, esquiva = 10, bloqueio = 0;
  String habNome = "", habDesc = "";

  int? _indiceAtual;
  bool _modoVisualizacao = false;
  int _abaAtual = 0;
  bool sofrePenalidadeProtecao = false;

  Color get corDestaque {
    if (afinidadeAtual == 'Morte' ||
        afinidadeAtual == null ||
        afinidadeAtual!.isEmpty) {
      return Colors.white;
    }
    return EstiloParanormal.corTema(afinidadeAtual);
  }

  Color get corFundoAfinidade {
    if (afinidadeAtual == 'Morte') return Colors.black;
    if (afinidadeAtual == null || afinidadeAtual!.isEmpty) return Colors.white;
    return EstiloParanormal.corTema(afinidadeAtual);
  }

  Color get corTextoAfinidade {
    if (afinidadeAtual == 'Morte' ||
        afinidadeAtual == 'Sangue' ||
        afinidadeAtual == 'Energia') {
      return Colors.white;
    }
    return Colors.black;
  }

  int get limitePePorTurno {
    int baseLimite = (nex / 5).ceil();
    if (origemAtual == 'universitario') baseLimite += 1;

    // Revoltado Sozinho
    if (origemAtual == 'revoltado' &&
        poderesEscolhidos.contains("Revoltado_Sozinho")) {
      baseLimite += 1;
    }

    return baseLimite;
  }

  int get deslocamento {
    int baseDesl = 9;
    // Ginasta
    if (origemAtual == 'ginasta') baseDesl += 3;
    return baseDesl;
  }

  int get espacoMaximo {
    int base = forc == 0 ? 2 : forc * 5;
    if (poderesEscolhidos.contains("Mochileiro")) base += 5;
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

  // --- LÓGICA: Limite de Crédito do Magnata ---
  String get limiteCredito {
    if (origemAtual == 'magnata') {
      if (prestigio >= 100) return "Ilimitado";
      if (prestigio >= 20) return "Alto";
      return "Médio"; // Um nível acima do recruta sempre!
    } else {
      if (prestigio >= 200) return "Ilimitado";
      if (prestigio >= 100) return "Alto";
      if (prestigio >= 20) return "Médio";
      return "Baixo";
    }
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

  void _mostrarNotificacao(String mensagem) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade700,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 1500), () {
      entry.remove();
    });
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
      corNumero = const Color.fromARGB(255, 63, 152, 63);
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

            List<Pericia> periciasDisponiveisParaPerito = listaPericias.where((
              p,
            ) {
              if (p.id == 'luta' || p.id == 'pontaria') return false;
              return p.treino > 0 ||
                  p.daOrigem ||
                  selecionadasLivres.contains(p.id);
            }).toList();

            selecionadasPerito.removeWhere(
              (id) => !periciasDisponiveisParaPerito.any(
                (pericia) => pericia.id == id,
              ),
            );

            bool podeConfirmar = selecionadasLivres.length == maxLivres;
            if (novaClasse == 'especialista' &&
                selecionadasPerito.length != 2) {
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
                            child: DropdownFicha(
                              label: "Armas",
                              value: combOp1,
                              options: const ["luta", "pontaria"],
                              onChanged: (val) {
                                setDialogState(() {
                                  combOp1 = val!;
                                  selecionadasLivres.remove(val);
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownFicha(
                              label: "Defesa",
                              value: combOp2,
                              options: const ["fortitude", "reflexos"],
                              onChanged: (val) {
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
                        "Escolha 2 perícias treinadas para ganhar o bônus de Perito (+1d6). Dica: Escolha suas perícias livres acima primeiro!",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      if (periciasDisponiveisParaPerito.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "Selecione suas perícias livres acima para habilitá-las aqui.",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      else
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

  void _mostrarDialogOrigens() {
    String busca = "";
    String? origemExpandida;

    Color corTemaLocal = corFundoAfinidade;
    Color corLetra = corTextoAfinidade;
    Color corDestaqueLocal = corDestaque;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            List<MapEntry<String, DadosOrigem>> filtrados = dadosOrigens.entries
                .where((entry) {
                  if (busca.isNotEmpty &&
                      !entry.value.nome.toLowerCase().contains(
                        busca.toLowerCase(),
                      )) {
                    return false;
                  }
                  return true;
                })
                .toList();
            filtrados.sort((a, b) => a.value.nome.compareTo(b.value.nome));

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
                          Icons.history_edu,
                          color: corDestaqueLocal,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "ORIGENS",
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
                        "Pesquisar origem...",
                        corDestaqueLocal,
                        Icons.search,
                      ),
                      onChanged: (val) => setDialogState(() => busca = val),
                    ),
                    const SizedBox(height: 16),

                    if (busca.isEmpty) ...[
                      ListTile(
                        leading: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.redAccent,
                        ),
                        title: const Text(
                          "Nenhuma Origem (--)",
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          setState(() {
                            origemAtual = '--';
                            atualizarFicha();
                          });
                          _salvarSilencioso();
                          Navigator.pop(context);
                        },
                      ),
                      const Divider(color: Colors.grey),
                    ],

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
                                  "Nenhuma origem encontrada.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filtrados.length,
                                itemBuilder: (context, index) {
                                  var entry = filtrados[index];
                                  DadosOrigem org = entry.value;
                                  String keyOrigem = entry.key;
                                  bool isExpanded =
                                      origemExpandida == keyOrigem;
                                  List<String> nomesPericias = org.pericias.map(
                                    (id) {
                                      try {
                                        return listaPericias
                                            .firstWhere((p) => p.id == id)
                                            .nome;
                                      } catch (e) {
                                        return id;
                                      }
                                    },
                                  ).toList();

                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade900,
                                        ),
                                      ),
                                      color: isExpanded
                                          ? Colors.grey.shade900.withValues(
                                              alpha: 0.5,
                                            )
                                          : Colors.transparent,
                                    ),
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        dividerColor: Colors.transparent,
                                      ),
                                      child: ExpansionTile(
                                        title: Text(
                                          org.nome,
                                          style: TextStyle(
                                            color: isExpanded
                                                ? corDestaqueLocal
                                                : Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          isExpanded
                                              ? "Perícias: ${nomesPericias.join(', ')}"
                                              : org.nomeHabilidade,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        iconColor: corDestaqueLocal,
                                        collapsedIconColor: Colors.grey,
                                        onExpansionChanged: (expanded) {
                                          setDialogState(() {
                                            origemExpandida = expanded
                                                ? keyOrigem
                                                : null;
                                          });
                                        },
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              16,
                                              0,
                                              16,
                                              16,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                const Divider(
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  "Poder: ${org.nomeHabilidade}",
                                                  style: TextStyle(
                                                    color: corDestaqueLocal,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  org.descHabilidade,
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 13,
                                                    height: 1.4,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                    backgroundColor:
                                                        corTemaLocal,
                                                    foregroundColor: corLetra,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    side:
                                                        afinidadeAtual ==
                                                            'Morte'
                                                        ? const BorderSide(
                                                            color:
                                                                Colors.white54,
                                                          )
                                                        : null,
                                                  ),
                                                  onPressed: () {
                                                    // LIMPA TRIGGERS ANTIGOS DE ORIGEM AO TROCAR
                                                    poderesEscolhidos
                                                        .removeWhere(
                                                          (p) =>
                                                              p.startsWith(
                                                                "Experimento_",
                                                              ) ||
                                                              p.startsWith(
                                                                "Profetizado_",
                                                              ) ||
                                                              p.startsWith(
                                                                "Colegial_",
                                                              ),
                                                        );

                                                    // == INTERCEPTADORES DE ORIGEM ==
                                                    if (keyOrigem ==
                                                        'cultista_arrependido') {
                                                      Navigator.pop(context);
                                                      _mostrarDialogPoderCultista();
                                                    } else if (keyOrigem ==
                                                        'operario') {
                                                      Navigator.pop(context);
                                                      _mostrarDialogOperario();
                                                    } else if (keyOrigem ==
                                                        'experimento') {
                                                      Navigator.pop(context);
                                                      _mostrarDialogExperimento();
                                                    } else if (keyOrigem ==
                                                        'profetizado') {
                                                      Navigator.pop(context);
                                                      _mostrarDialogProfetizado();
                                                    } else if (keyOrigem ==
                                                        'engenheiro') {
                                                      Navigator.pop(context);
                                                      _mostrarDialogEngenheiro();
                                                    } else {
                                                      setState(() {
                                                        origemAtual = keyOrigem;
                                                        atualizarFicha();
                                                      });
                                                      _salvarSilencioso();
                                                      Navigator.pop(context);
                                                    }
                                                  },
                                                  child: const Text(
                                                    "ESCOLHER ORIGEM",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
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
                              corTxtSelecionado = Colors.white;
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

  void _abrirCatalogoEquipamento({String filtroInicial = "Todos"}) {
    String filtroAtual = filtroInicial;
    List<String> subFiltrosAtivos = [];
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
      "Munições",
      "Proteções",
      "Itens Paranormais",
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Widget buildFiltroArma(String label, List<String> opcoes) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Text(
                      label.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: opcoes.map((sub) {
                      bool isSelected = subFiltrosAtivos.contains(sub);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(
                            sub,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey.shade400,
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: Colors.grey.shade300,
                          backgroundColor: const Color(0xFF151515),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.grey.shade300
                                : Colors.grey.shade800,
                          ),
                          onSelected: (val) {
                            setDialogState(() {
                              if (isSelected) {
                                subFiltrosAtivos.remove(sub);
                              } else {
                                subFiltrosAtivos.removeWhere(
                                  (e) => opcoes.contains(e),
                                );
                                subFiltrosAtivos.add(sub);
                              }
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            }

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
                if (filtroAtual == "Armas") {
                  if (eq is! Arma) return false;
                  for (String sub in subFiltrosAtivos) {
                    if (["Simples", "Táticas", "Pesadas"].contains(sub) &&
                        eq.proficiencia != sub) {
                      return false;
                    }
                    if (["Corpo a Corpo", "Fogo", "Disparo"].contains(sub) &&
                        eq.tipo != sub) {
                      return false;
                    }
                    if (["Leve", "Uma Mão", "Duas Mãos"].contains(sub) &&
                        eq.empunhadura != sub) {
                      return false;
                    }
                  }
                } else {
                  if (eq is Arma) return false;
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
                                  onSelected: (val) => setDialogState(() {
                                    filtroAtual = cat;
                                    subFiltrosAtivos.clear();
                                  }),
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

                    if (filtroAtual == "Armas") ...[
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildFiltroArma("Proficiência", [
                              "Simples",
                              "Táticas",
                              "Pesadas",
                            ]),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.grey.shade800,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            buildFiltroArma("Tipo", [
                              "Corpo a Corpo",
                              "Fogo",
                              "Disparo",
                            ]),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.grey.shade800,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            buildFiltroArma("Empunhadura", [
                              "Leve",
                              "Uma Mão",
                              "Duas Mãos",
                            ]),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    const SizedBox(height: 8),
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
                                  String tipoItem = "";
                                  String descLimpa = "";
                                  if (!isArma) {
                                    tipoItem = eq.descricao.split('.').first;
                                    descLimpa = eq.descricao
                                        .replaceFirst("$tipoItem.", "")
                                        .trim();
                                    if (descLimpa.isEmpty) descLimpa = tipoItem;
                                  }

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF151515),
                                      border: Border.all(
                                        color: Colors.grey.shade900,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        dividerColor: Colors.transparent,
                                      ),
                                      child: ExpansionTile(
                                        iconColor: corDestaqueLocal,
                                        collapsedIconColor: Colors.grey,
                                        tilePadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 4,
                                        ),
                                        title: isArma
                                            ? RichText(
                                                text: TextSpan(
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: "${eq.nome}  ",
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          "${eq.proficiencia} - ${eq.tipo} - ${eq.empunhadura}",
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Text(
                                                eq.nome,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                        subtitle: RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              color: corDestaqueLocal,
                                              fontSize: 13,
                                            ),
                                            children: isArma
                                                ? [
                                                    const TextSpan(
                                                      text: "Categoria: ",
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          "${eq.categoria}   ",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const TextSpan(
                                                      text: "Dano: ",
                                                    ),
                                                    TextSpan(
                                                      text: "${eq.dano}   ",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const TextSpan(
                                                      text: "Crítico: ",
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          "x${eq.multiplicadorCritico}   ",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const TextSpan(
                                                      text: "Espaços: ",
                                                    ),
                                                    TextSpan(
                                                      text: eq.espaco
                                                          .toString()
                                                          .replaceAll('.0', ''),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ]
                                                : [
                                                    const TextSpan(
                                                      text: "Categoria: ",
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          "${eq.categoria}   ",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const TextSpan(
                                                      text: "Espaços: ",
                                                    ),
                                                    TextSpan(
                                                      text: eq.espaco
                                                          .toString()
                                                          .replaceAll('.0', ''),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                          ),
                                        ),
                                        trailing: SizedBox(
                                          width: 90,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.add_circle,
                                                  color: corDestaqueLocal,
                                                  size: 28,
                                                ),
                                                onPressed: () {
                                                  if (eq is ItemInventario &&
                                                      (eq.nome ==
                                                              "Catalisador ritualístico" ||
                                                          eq.nome.contains(
                                                            "(elemento)",
                                                          ))) {
                                                    if (eq.nome ==
                                                        "Catalisador ritualístico") {
                                                      mostrarDialogCatalisador(
                                                        context: context,
                                                        corDestaque:
                                                            corDestaqueLocal,
                                                        corTema: corTemaLocal,
                                                        corTexto: corLetra,
                                                        afinidadeAtual:
                                                            afinidadeAtual,
                                                        onConfirmar: (item) {
                                                          _aplicarTagsOrigemItem(
                                                            item,
                                                          );
                                                          setState(
                                                            () => inventario
                                                                .add(item),
                                                          );
                                                          atualizarFicha();
                                                          _salvarSilencioso();
                                                          _mostrarNotificacao(
                                                            "Catalisador adicionado!",
                                                          );
                                                        },
                                                      );
                                                    } else {
                                                      mostrarDialogElementoItem(
                                                        context: context,
                                                        itemBase: eq,
                                                        corDestaque:
                                                            corDestaqueLocal,
                                                        corTema: corTemaLocal,
                                                        corTexto: corLetra,
                                                        afinidadeAtual:
                                                            afinidadeAtual,
                                                        onConfirmar: (item) {
                                                          _aplicarTagsOrigemItem(
                                                            item,
                                                          );
                                                          setState(
                                                            () => inventario
                                                                .add(item),
                                                          );
                                                          atualizarFicha();
                                                          _salvarSilencioso();
                                                          _mostrarNotificacao(
                                                            "${item.nome} adicionado!",
                                                          );
                                                        },
                                                      );
                                                    }
                                                  } else {
                                                    if (eq is Arma) {
                                                      setState(
                                                        () => armas.add(
                                                          Arma(
                                                            nome: eq.nome,
                                                            tipo: eq.tipo,
                                                            dano: eq.dano,
                                                            margemAmeaca:
                                                                eq.margemAmeaca,
                                                            multiplicadorCritico:
                                                                eq.multiplicadorCritico,
                                                            categoria:
                                                                eq.categoria,
                                                            espaco: eq.espaco,
                                                            proficiencia:
                                                                eq.proficiencia,
                                                            empunhadura:
                                                                eq.empunhadura,
                                                            descricao:
                                                                eq.descricao,
                                                          ),
                                                        ),
                                                      );
                                                      _salvarSilencioso();
                                                      _mostrarNotificacao(
                                                        "Arma adicionada!",
                                                      );
                                                    } else {
                                                      _processarNovoItem(
                                                        ItemInventario(
                                                          nome: eq.nome,
                                                          categoria:
                                                              eq.categoria,
                                                          espaco: eq.espaco,
                                                          descricao:
                                                              eq.descricao,
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                              ),
                                              Icon(
                                                Icons.expand_more,
                                                color: corDestaqueLocal
                                                    .withValues(alpha: 0.5),
                                              ),
                                            ],
                                          ),
                                        ),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              16,
                                              0,
                                              16,
                                              16,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Divider(
                                                  color: corDestaqueLocal
                                                      .withValues(alpha: 0.3),
                                                  thickness: 1,
                                                ),
                                                const SizedBox(height: 8),
                                                if (isArma) ...[
                                                  Text(
                                                    eq.descricao.isNotEmpty
                                                        ? eq.descricao
                                                        : "Nenhuma descrição fornecida.",
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ] else ...[
                                                  Text(
                                                    tipoItem,
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    descLimpa,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
                              mostrarDialogCriacaoManual(
                                context: context,
                                isArma: false,
                                corDestaque: corDestaqueLocal,
                                corTema: corTemaLocal,
                                corTexto: corLetra,
                                afinidadeAtual: afinidadeAtual,
                                onVoltar: () => _abrirCatalogoEquipamento(
                                  filtroInicial: filtroAtual,
                                ),
                                onConfirmar: (novoItem) {
                                  _processarNovoItem(novoItem);
                                },
                              );
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
                              mostrarDialogCriacaoManual(
                                context: context,
                                isArma: true,
                                corDestaque: corDestaqueLocal,
                                corTema: corTemaLocal,
                                corTexto: corLetra,
                                afinidadeAtual: afinidadeAtual,
                                onVoltar: () => _abrirCatalogoEquipamento(
                                  filtroInicial: filtroAtual,
                                ),
                                onConfirmar: (novaArma) {
                                  setState(() => armas.add(novaArma));
                                  _salvarSilencioso();
                                  _mostrarNotificacao(
                                    "Arma criada e adicionada!",
                                  );
                                },
                              );
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

  void _aplicarTagsOrigemItem(ItemInventario item) {
    // RESOLVE O CRASH: Destranca a lista imutável transformando-a numa lista normal!
    item.modificacoes = List.from(item.modificacoes);

    // Engenheiro: Verifica se é o item escolhido na Origem
    if (origemAtual == 'engenheiro' && poderesEscolhidos.contains("Engenheiro_${item.nome}")) {
      if (!item.modificacoes.contains("Ferramenta Favorita")) item.modificacoes.add("Ferramenta Favorita");
    }
    // Blaster: Verifica se é um Explosivo de Dano
    if (origemAtual == 'blaster' && item.descricao.toLowerCase().contains("explosivo")) {
      if (item.descricao.toLowerCase().contains("dano") || item.descricao.toLowerCase().contains("d6") || item.descricao.toLowerCase().contains("d8")) {
        if (!item.modificacoes.contains("Explosão Solidária")) item.modificacoes.add("Explosão Solidária");
      }
    }
  }
  
  void _processarNovoItem(ItemInventario novoItem) {
    _aplicarTagsOrigemItem(novoItem);
    String nomeLower = novoItem.nome.toLowerCase();
    if (nomeLower.contains("vestimenta") || nomeLower.contains("utensílio")) {
      bool isVestimenta = nomeLower.contains("vestimenta");
      mostrarDialogEscolherPericiaAprimoramento(
        context: context,
        itemBase: novoItem,
        listaPericias: listaPericias,
        corDestaque: corDestaque,
        corTema: corFundoAfinidade,
        corTexto: corTextoAfinidade,
        afinidadeAtual: afinidadeAtual,
        isVestimenta: isVestimenta,
        onConfirmar: (itemConfigurado) {
          setState(() {
            inventario.add(itemConfigurado);
            atualizarFicha();
          });
          _salvarSilencioso();
          _mostrarNotificacao(
            "${isVestimenta ? 'Vestimenta' : 'Utensílio'} adicionado(a)!",
          );
        },
      );
    } else {
      setState(() => inventario.add(novoItem));
      _salvarSilencioso();
      _mostrarNotificacao("Item adicionado!");
    }
  }

  // ================== DIALOGS ESPECÍFICOS DE ORIGENS ==================

  void _mostrarDialogPoderCultista() {
    String busca = "";
    String filtroParanormal = "Conhecimento";

    Color corTemaLocal = corFundoAfinidade;
    Color corLetra = corTextoAfinidade;
    Color corDestaqueLocal = corDestaque;

    List<String> categoriasParanormais = [
      "Conhecimento",
      "Energia",
      "Morte",
      "Sangue",
    ];

    showDialog(
      context: context,
      barrierDismissible:
          false, // Obriga a escolher um poder ou cancelar a origem
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            List<Poder> listaAtiva = [];
            if (filtroParanormal == "Conhecimento") {
              listaAtiva = catalogoPoderesConhecimento;
            } else if (filtroParanormal == "Energia") {
              listaAtiva = catalogoPoderesEnergia;
            } else if (filtroParanormal == "Morte") {
              listaAtiva = catalogoPoderesMorte;
            } else if (filtroParanormal == "Sangue") {
              listaAtiva = catalogoPoderesSangue;
            }

            List<Poder> filtrados = listaAtiva.where((p) {
              if (busca.isNotEmpty &&
                  !p.nome.toLowerCase().contains(busca.toLowerCase())) {
                return false;
              }
              // Oculta poderes que o jogador já tem
              if (poderesEscolhidos.contains(p.nome)) return false;
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
                        Expanded(
                          child: Text(
                            "PODER DO CULTISTA",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: corDestaqueLocal,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "A origem Cultista Arrependido fornece um poder paranormal grátis. Escolha o seu abaixo:",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
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
                            corTxtSelecionado = Colors.white;
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
                              onSelected: (val) =>
                                  setDialogState(() => filtroParanormal = cat),
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
                                  "Nenhum poder encontrado.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filtrados.length,
                                itemBuilder: (context, index) {
                                  var p = filtrados[index];

                                  Color corTitulo = Colors.white;
                                  if (filtroParanormal == 'Sangue') {
                                    corTitulo = const Color(0xFF990000);
                                  } else if (filtroParanormal == 'Energia') {
                                    corTitulo = const Color(0xFF9900FF);
                                  } else if (filtroParanormal ==
                                      'Conhecimento') {
                                    corTitulo = const Color(0xFFFFB300);
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
                                        p.nome,
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
                                      trailing: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: corTemaLocal,
                                          foregroundColor: corLetra,
                                          side: afinidadeAtual == 'Morte'
                                              ? const BorderSide(
                                                  color: Colors.white54,
                                                )
                                              : null,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            origemAtual =
                                                'cultista_arrependido';
                                            poderesEscolhidos.add(p.nome);
                                            atualizarFicha();
                                          });
                                          _salvarSilencioso();
                                          Navigator.pop(context);
                                          _mostrarNotificacao(
                                            "Origem e Poder aplicados!",
                                          );
                                        },
                                        child: const Text(
                                          "ESCOLHER",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarDialogOperario() {
    List<Arma> armasValidas = catalogoArmasOrdem
        .where(
          (a) => a.proficiencia == 'Simples' || a.proficiencia == 'Táticas',
        )
        .toList();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text(
            "Ferramenta de Trabalho",
            style: TextStyle(color: corDestaque),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: armasValidas.length,
              itemBuilder: (ctx, i) {
                var arma = armasValidas[i];
                return ListTile(
                  title: Text(
                    arma.nome,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    // CORREÇÃO: A arma já nasce com uma lista mutável contendo a modificação
                    Arma novaArma = Arma(
                      nome: arma.nome,
                      tipo: arma.tipo,
                      dano: arma.dano,
                      margemAmeaca: arma.margemAmeaca,
                      multiplicadorCritico: arma.multiplicadorCritico,
                      categoria: arma.categoria,
                      espaco: arma.espaco,
                      proficiencia: arma.proficiencia,
                      empunhadura: arma.empunhadura,
                      descricao: arma.descricao,
                      modificacoes: ["Ferramenta de Trabalho"],
                    );

                    setState(() {
                      origemAtual = 'operario';
                      armas.add(novaArma);
                      atualizarFicha();
                    });

                    _salvarSilencioso();
                    Navigator.pop(context);
                    _mostrarNotificacao(
                      "Origem aplicada e Ferramenta adicionada!",
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogExperimento() {
    List<String> idsFisicos = [
      'acrobacia',
      'atletismo',
      'crime',
      'fortitude',
      'furtividade',
      'iniciativa',
      'luta',
      'pilotagem',
      'pontaria',
      'reflexos',
    ];
    List<Pericia> periciasValidas = listaPericias
        .where((p) => idsFisicos.contains(p.id))
        .toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text(
            "Mutação (Experimento)",
            style: TextStyle(color: corDestaque),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: periciasValidas.length,
              itemBuilder: (ctx, i) {
                var p = periciasValidas[i];
                return ListTile(
                  title: Text(
                    p.nome,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    setState(() {
                      origemAtual = 'experimento';
                      poderesEscolhidos.add("Experimento_${p.id}");
                      atualizarFicha();
                    });
                    _salvarSilencioso();
                    Navigator.pop(context);
                    _mostrarNotificacao("Origem Experimento aplicada!");
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogProfetizado() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text(
            "Premonição (Profetizado)",
            style: TextStyle(color: corDestaque),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: listaPericias.length,
              itemBuilder: (ctx, i) {
                var p = listaPericias[i];
                return ListTile(
                  title: Text(
                    p.nome,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    setState(() {
                      origemAtual = 'profetizado';
                      poderesEscolhidos.add("Profetizado_${p.id}");
                      var pericia = listaPericias.firstWhere(
                        (per) => per.id == p.id,
                      );
                      if (pericia.treino < 5) pericia.treino = 5;
                      pericia.daOrigem = true;

                      var vontade = listaPericias.firstWhere(
                        (v) => v.id == 'vontade',
                      );
                      if (vontade.treino < 5) vontade.treino = 5;
                      vontade.daOrigem = true;
                      atualizarFicha();
                    });
                    _salvarSilencioso();
                    Navigator.pop(context);
                    _mostrarNotificacao("Origem Profetizado aplicada!");
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogEngenheiro() {
    // Filtra itens normais que tenham categoria maior que zero (I, II, III, etc)
    List<dynamic> itensValidos = catalogoItensOrdem
        .where((item) => item.categoria != '0')
        .toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text(
            "Ferramenta Favorita (Engenheiro)",
            style: TextStyle(color: corDestaque),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: itensValidos.length,
              itemBuilder: (ctx, i) {
                var item = itensValidos[i] as ItemInventario;
                return ListTile(
                  title: Text(
                    item.nome,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "Categoria: ${item.categoria}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    setState(() {
                      origemAtual = 'engenheiro';
                      poderesEscolhidos.add("Engenheiro_${item.nome}");
                      atualizarFicha();
                    });
                    _salvarSilencioso();
                    Navigator.pop(context);
                    _mostrarNotificacao("Origem Engenheiro aplicada!");
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  void atualizarFicha({bool isInitialLoad = false}) {
    setState(() {
      if (nex < 50 && afinidadeAtual != null) {
        afinidadeAtual = null;
      }

      // Limpa bônus de origem e resistências
      bonusOrigem.clear();
      resistencias.clear();

      if (origemAtual == 'diplomata') bonusOrigem['diplomacia'] = 2;
      if (origemAtual == 'profetizado') bonusOrigem['vontade'] = 2;
      if (origemAtual == 'colegial' &&
          poderesEscolhidos.contains("Colegial_Perto") &&
          !poderesEscolhidos.contains("Colegial_Morto")) {
        for (var p in listaPericias) {
          bonusOrigem[p.id] = 2;
        }
      }
      // Revoltado Sozinho (+1 em todas as perícias)
      if (origemAtual == 'revoltado' &&
          poderesEscolhidos.contains("Revoltado_Sozinho")) {
        for (var p in listaPericias) {
          bonusOrigem[p.id] = (bonusOrigem[p.id] ?? 0) + 1;
        }
      }

      if (origemAtual == 'experimento') resistencias['Geral'] = 2;
      if (origemAtual == 'teorico_da_conspiracao') {
        resistencias['Mental'] = inte;
      }

      for (String pod in poderesEscolhidos) {
        if (pod.startsWith("Experimento_")) {
          bonusOrigem[pod.replaceAll("Experimento_", "")] = 2;
        }
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
      } else {
        habNome = "";
        habDesc = "";
        for (var p in listaPericias) {
          if (p.daOrigem) {
            if (p.treino <= 5) p.treino = 0;
            p.daOrigem = false;
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

        if (origemAtual == 'colegial' &&
            poderesEscolhidos.contains("Colegial_Morto")) {
          peMax -= nivel; // Perde -1 PE por NEX se o amigo morrer
        }

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

        int sanidadeBase = stats.sanBase;
        if (origemAtual == 'cultista_arrependido') {
          sanidadeBase = (sanidadeBase / 2).floor();
          if (quantidadePoderesParanormais > 0) quantidadePoderesParanormais--;
        }

        int sanidadePerdidaPorTranscender =
            quantidadePoderesParanormais * stats.sanPorNivel;
        sanMax =
            sanidadeBase +
            (stats.sanPorNivel * (nivel - 1)) -
            sanidadePerdidaPorTranscender;

        if (origemAtual == 'desgarrado') pvMax += nivel;
        if (origemAtual == 'vitima') sanMax += nivel;
        if (origemAtual == 'mergulhador') pvMax += 5;
        if (origemAtual == 'universitario') {
          peMax += 1;
          int nexImpares = (nivel / 2).floor();
          if (nivel >= 3) peMax += nexImpares;
        }

        if (sanMax < 0) sanMax = 0;
      } else {
        if (isInitialLoad && widget.agenteParaEditar == null) {
          pvMax = 0;
          peMax = 0;
          sanMax = 0;
        }
      }

      int defItens = 0;
      int bonusBloqueioBracadeira = 0;
      bool usaProtecaoLeve = false;
      bool usaProtecaoPesadaOuEscudo = false;

      for (var item in inventario.where((i) => i.equipado)) {
        String nomeLower = item.nome.toLowerCase();
        String descLower = item.descricao.toLowerCase();

        if (descLower.contains("proteção pesada")) {
          resistencias['Balístico'] = (resistencias['Balístico'] ?? 0) + 2;
          resistencias['Corte'] = (resistencias['Corte'] ?? 0) + 2;
          resistencias['Impacto'] = (resistencias['Impacto'] ?? 0) + 2;
          resistencias['Perfuração'] = (resistencias['Perfuração'] ?? 0) + 2;
        }
        if (nomeLower.contains("traje hazmat")) {
          resistencias['Químico'] = (resistencias['Químico'] ?? 0) + 10;
        }
        if (nomeLower.contains("traje espacial")) {
          resistencias['Químico'] = (resistencias['Químico'] ?? 0) + 20;
        }

        if (descLower.contains("proteção") || nomeLower.contains("escudo")) {
          if (nomeLower.contains("leve")) {
            defItens += 5;
            usaProtecaoLeve = true;
          }
          if (nomeLower.contains("pesada")) {
            defItens += 10;
            usaProtecaoPesadaOuEscudo = true;
          }
          if (nomeLower.contains("escudo")) {
            defItens += 2;
            usaProtecaoPesadaOuEscudo = true;
          }
          if (item.modificacoes.contains("Reforçada")) defItens += 2;
        }

        if (nomeLower.contains("braçadeira reforçada")) {
          bonusBloqueioBracadeira += 2;
        }
      }

      sofrePenalidadeProtecao = false;
      if (usaProtecaoPesadaOuEscudo) {
        sofrePenalidadeProtecao = true;
      } else if (usaProtecaoLeve && classeAtual == 'ocultista') {
        sofrePenalidadeProtecao = true;
      }

      int bReflexos = 0, bFortitude = 0;
      for (var p in listaPericias) {
        if (p.id == 'reflexos') bReflexos = p.treino;
        if (p.id == 'fortitude') bFortitude = p.treino;
      }

      // LÓGICA: Bônus de Defesa das Origens
      int bonusDefesaOrigem = 0;
      if (origemAtual == 'policial') bonusDefesaOrigem += 2;
      if (origemAtual == 'ginasta') bonusDefesaOrigem += 2;
      if (origemAtual == 'revoltado' &&
          poderesEscolhidos.contains("Revoltado_Sozinho")) {
        bonusDefesaOrigem += 1;
      }

      defesa = 10 + agi + defItens + bonusDefesaOrigem;
      esquiva = defesa + bReflexos;
      bloqueio = bFortitude + bonusBloqueioBracadeira;

      if (isInitialLoad && widget.agenteParaEditar == null) {
        pvAtual = pvMax;
        peAtual = peMax;
        sanAtual = sanMax;
      }
    });
    if (!isInitialLoad) _salvarSilencioso();
  }

  void _toggleEquiparItem(ItemInventario item) {
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

          SecaoFicha(
            titulo: "Detalhes",
            corTema: corFundoAfinidade,
            corTexto: corTextoAfinidade,
            isMorte: afinidadeAtual == 'Morte',
            filhos: [
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
                    child: DropdownFicha(
                      label: "Classe",
                      value: classeAtual,
                      options: ['--', ...dadosClasses.keys],
                      onChanged: block
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
                    child: GestureDetector(
                      onTap: block ? null : () => _mostrarDialogOrigens(),
                      child: Container(
                        height: 58,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D0D0D),
                          border: Border.all(color: Colors.grey.shade600),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Origem",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    origemAtual == '--'
                                        ? '--'
                                        : (dadosOrigens[origemAtual]?.nome ??
                                                  origemAtual)
                                              .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownFicha(
                      label: "NEX (%)",
                      value: nex.toString(),
                      options: List.generate(
                        20,
                        (i) => i == 19 ? "99" : ((i + 1) * 5).toString(),
                      ),
                      onChanged: block
                          ? null
                          : (val) {
                              nex = int.parse(val!);
                              atualizarFicha();
                            },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D0D0D),
                        border: Border.all(color: Colors.grey.shade600),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "PE / Turno",
                            style: TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            limitePePorTurno.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D0D0D),
                        border: Border.all(color: Colors.grey.shade600),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Desl.",
                            style: TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${deslocamento}m",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "PROFICIÊNCIAS DA CLASSE:",
                    style: TextStyle(
                      color: corDestaque,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    classeAtual == 'combatente'
                        ? "Armas simples, armas táticas e proteções leves."
                        : classeAtual == 'especialista'
                        ? "Armas simples e proteções leves."
                        : classeAtual == 'ocultista'
                        ? "Armas simples."
                        : "Nenhuma.",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  if (sofrePenalidadeProtecao)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        "⚠️ PENALIDADE: Usando proteção sem proficiência. Você sofre –2d20 em testes de Força e Agilidade.",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          SecaoFicha(
            titulo: "Atributos ${block ? '(Toque para Rolar)' : ''}",
            corTema: corFundoAfinidade,
            corTexto: corTextoAfinidade,
            isMorte: afinidadeAtual == 'Morte',
            filhos: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AtributoInputFicha(
                    label: "AGI",
                    value: agi,
                    isVisu: block,
                    corPopUp: corDestaque,
                    onChanged: (val) {
                      agi = int.tryParse(val) ?? 0;
                      atualizarFicha();
                    },
                    onRolarDado: _rolarDado,
                  ),
                  AtributoInputFicha(
                    label: "FOR",
                    value: forc,
                    isVisu: block,
                    corPopUp: corDestaque,
                    onChanged: (val) {
                      forc = int.tryParse(val) ?? 0;
                      atualizarFicha();
                    },
                    onRolarDado: _rolarDado,
                  ),
                  AtributoInputFicha(
                    label: "INT",
                    value: inte,
                    isVisu: block,
                    corPopUp: corDestaque,
                    onChanged: (val) {
                      inte = int.tryParse(val) ?? 0;
                      atualizarFicha();
                    },
                    onRolarDado: _rolarDado,
                  ),
                  AtributoInputFicha(
                    label: "PRE",
                    value: pre,
                    isVisu: block,
                    corPopUp: corDestaque,
                    onChanged: (val) {
                      pre = int.tryParse(val) ?? 0;
                      atualizarFicha();
                    },
                    onRolarDado: _rolarDado,
                  ),
                  AtributoInputFicha(
                    label: "VIG",
                    value: vig,
                    isVisu: block,
                    corPopUp: corDestaque,
                    onChanged: (val) {
                      vig = int.tryParse(val) ?? 0;
                      atualizarFicha();
                    },
                    onRolarDado: _rolarDado,
                  ),
                ],
              ),
            ],
          ),

          SecaoFicha(
            titulo: "Status",
            corTema: corFundoAfinidade,
            corTexto: corTextoAfinidade,
            isMorte: afinidadeAtual == 'Morte',
            filhos: [
              BarraStatusFicha(
                titulo: "PONTOS DE VIDA (PV)",
                atual: pvAtual,
                maximo: pvMax,
                cor: Colors.red,
                onChanged: (val) {
                  setState(() => pvAtual = val.clamp(0, pvMax));
                  _salvarSilencioso();
                },
              ),
              const SizedBox(height: 16),
              BarraStatusFicha(
                titulo: "PONTOS DE ESFORÇO (PE)",
                atual: peAtual,
                maximo: peMax,
                cor: Colors.blue,
                onChanged: (val) {
                  setState(() => peAtual = val.clamp(0, peMax));
                  _salvarSilencioso();
                },
              ),
              const SizedBox(height: 16),
              BarraStatusFicha(
                titulo: "SANIDADE (SAN)",
                atual: sanAtual,
                maximo: sanMax,
                cor: Colors.blueGrey,
                onChanged: (val) {
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
                  StatusFixoFicha(label: "Defesa", value: defesa),
                  StatusFixoFicha(label: "Esquiva", value: esquiva),
                  StatusFixoFicha(label: "Bloqueio", value: bloqueio),
                ],
              ),
            ],
          ),

          if (resistencias.isNotEmpty)
            SecaoFicha(
              titulo: "Resistências",
              corTema: corFundoAfinidade,
              corTexto: corTextoAfinidade,
              isMorte: afinidadeAtual == 'Morte',
              filhos: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: resistencias.entries.map((e) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF151515),
                        border: Border.all(
                          color: corDestaque.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "${e.key}: ${e.value}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

          SecaoFicha(
            titulo: "Ataques (Armas Equipadas)",
            corTema: corFundoAfinidade,
            corTexto: corTextoAfinidade,
            isMorte: afinidadeAtual == 'Morte',
            filhos: [
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

                  int bonusDano = 0;
                  if (arma.tipo == 'Corpo a Corpo' ||
                      arma.tipo == 'Arremesso') {
                    bonusDano += forc;
                    if (origemAtual == 'lutador') {
                      bonusDano += 2; // LÓGICA: Lutador
                    }
                  } else if (arma.tipo == 'Fogo' || arma.tipo == 'Disparo') {
                    if (origemAtual == 'militar') {
                      bonusDano += 2; // LÓGICA: Militar
                    }
                  }
                  if (bonusDano > 0) {
                    modDano = "+$bonusDano";
                  } else if (bonusDano < 0) {
                    modDano = "$bonusDano";
                  }
                  if (arma.modificacoes.contains("Ferramenta de Trabalho")) {
                    alertaProf += " | +1 no Ataque";
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
                            "Dano: ${arma.danoEfetivo}$modDano | Crítico: ${arma.margemAmeacaEfetiva}/x${arma.multiplicadorCritico} \nTipo: ${arma.tipo}$alertaProf",
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
                                  color: corDestaque,
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
                                    style: TextStyle(color: corDestaque),
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
                                              "Dano: ${arma.danoEfetivo}$modDano\n$alertaProf",
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        "OK",
                                        style: TextStyle(color: corDestaque),
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAbaPericias(bool block, Color corDoPainel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: SecaoFicha(
        titulo: "Perícias",
        corTema: corFundoAfinidade,
        corTexto: corTextoAfinidade,
        isMorte: afinidadeAtual == 'Morte',
        filhos: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: listaPericias.length,
            itemBuilder: (context, index) {
              var pericia = listaPericias[index];

              int bonusExtra = 0;
              var aprimoramentos = inventario.where((i) {
                bool isUtensilio = i.nome.toLowerCase().contains("utensílio");
                return i.periciaVinculada == pericia.id &&
                    (i.equipado || isUtensilio);
              });

              for (var v in aprimoramentos) {
                bool temModAprimorado =
                    v.modificacoes.contains("Aprimorado") ||
                    v.modificacoes.contains("Aprimorada");
                int b = temModAprimorado ? 5 : 2;
                if (b > bonusExtra) bonusExtra = b;
              }

              // --- LÓGICA: Adiciona o Bônus de Origens! ---
              int bonusDaOrigemAplicado = bonusOrigem[pericia.id] ?? 0;
              int bonusTotalExtras = bonusExtra + bonusDaOrigemAplicado;
              int totalBonus = pericia.treino + bonusTotalExtras;

              bool isLocked =
                  pericia.daOrigem || periciasClasse.contains(pericia.id);

              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade800),
                  ),
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
                          if (bonusTotalExtras > 0)
                            Padding(
                              padding: const EdgeInsets.only(left: 4, right: 4),
                              child: Icon(
                                Icons.add_circle,
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
                        "+$bonusTotalExtras",
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
        ],
      ),
    );
  }

  Widget _buildAbaHabilidades(bool block, Color corDoPainel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (origemAtual != '--')
            SecaoFicha(
              titulo: "Habilidade de Origem: $habNome",
              corTema: corFundoAfinidade,
              corTexto: corTextoAfinidade,
              isMorte: afinidadeAtual == 'Morte',
              filhos: [
                Text(
                  habDesc,
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),

                // LÓGICA: Switches Exclusivos do Colegial!
                if (origemAtual == 'colegial') ...[
                  const SizedBox(height: 16),
                  const Divider(color: Colors.grey),
                  SwitchListTile(
                    title: const Text(
                      "Amigo Próximo (+2 Perícias)",
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    value: poderesEscolhidos.contains("Colegial_Perto"),
                    activeThumbColor: corDestaque,
                    contentPadding: EdgeInsets.zero,
                    onChanged:
                        block || poderesEscolhidos.contains("Colegial_Morto")
                        ? null
                        : (val) {
                            setState(() {
                              if (val) {
                                poderesEscolhidos.add("Colegial_Perto");
                              } else {
                                poderesEscolhidos.remove("Colegial_Perto");
                              }
                              atualizarFicha();
                            });
                            _salvarSilencioso();
                          },
                  ),
                  SwitchListTile(
                    title: const Text(
                      "Amigo Morreu (-PE Max)",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: poderesEscolhidos.contains("Colegial_Morto"),
                    activeThumbColor: Colors.redAccent,
                    contentPadding: EdgeInsets.zero,
                    onChanged: block
                        ? null
                        : (val) {
                            setState(() {
                              if (val) {
                                poderesEscolhidos.add("Colegial_Morto");
                                poderesEscolhidos.remove("Colegial_Perto");
                              } else {
                                poderesEscolhidos.remove("Colegial_Morto");
                              }
                              atualizarFicha();
                            });
                            _salvarSilencioso();
                          },
                  ),
                ],
                // LÓGICA: Switches Exclusivos do Revoltado!
                if (origemAtual == 'revoltado') ...[
                  const SizedBox(height: 16),
                  const Divider(color: Colors.grey),
                  SwitchListTile(
                    title: const Text(
                      "Sem Aliados Próximos (+1 Def, +1 Perícias, +1 PE)",
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    value: poderesEscolhidos.contains("Revoltado_Sozinho"),
                    activeThumbColor: corDestaque,
                    contentPadding: EdgeInsets.zero,
                    onChanged: block
                        ? null
                        : (val) {
                            setState(() {
                              if (val) {
                                poderesEscolhidos.add("Revoltado_Sozinho");
                              } else {
                                poderesEscolhidos.remove("Revoltado_Sozinho");
                              }
                              atualizarFicha();
                            });
                            _salvarSilencioso();
                          },
                  ),
                ],
              ],
            ),

          if (afinidadeAtual != null)
            SecaoFicha(
              titulo: "Afinidade Elemental",
              corTema: corFundoAfinidade,
              corTexto: corTextoAfinidade,
              isMorte: afinidadeAtual == 'Morte',
              filhos: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0D0D),
                    border: Border.all(color: corDestaque, width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Afinidade: ${afinidadeAtual!.toUpperCase()} | Opressor: ${_obterOpressor(afinidadeAtual!).toUpperCase()}",
                        style: TextStyle(
                          color: corDestaque,
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
              ],
            ),

          SecaoFicha(
            titulo: "Poderes",
            corTema: corFundoAfinidade,
            corTexto: corTextoAfinidade,
            isMorte: afinidadeAtual == 'Morte',
            filhos: [
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
                  // Oculta as tags matemáticas de Origem da tela de poderes visuais
                  if (nomePoder.startsWith("Experimento_") ||
                      nomePoder.startsWith("Profetizado_") ||
                      nomePoder.startsWith("Colegial_")) {
                    return const SizedBox.shrink();
                  }

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
                          color: isParanormal ? corDestaque : Colors.white,
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
                                color: corDestaque,
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
            ],
          ),
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
          SecaoFicha(
            titulo: "Painel de Controle",
            corTema: corFundoAfinidade,
            corTexto: corTextoAfinidade,
            isMorte: afinidadeAtual == 'Morte',
            filhos: [
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: corDestaque, width: 0.5),
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
                                color: corDestaque,
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
                                color: excedeu
                                    ? Colors.redAccent
                                    : Colors.white,
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

              // ================= ARMAS EXPANSÍVEIS =================
              ...armas.map((arma) {
                int index = armas.indexOf(arma);
                bool isProficiente =
                    arma.proficiencia == 'Simples' ||
                    (arma.proficiencia == 'Táticas' &&
                        classeAtual == 'combatente');
                String alertaProf = isProficiente
                    ? ""
                    : "\n⚠️ Não proficiente: -2d20 no Ataque";
                String modDano = "";

                int bonusDano = 0;
                if (arma.tipo == 'Corpo a Corpo' || arma.tipo == 'Arremesso') {
                  bonusDano += forc;
                  if (origemAtual == 'lutador') bonusDano += 2;
                } else if (arma.tipo == 'Fogo' || arma.tipo == 'Disparo') {
                  if (origemAtual == 'militar') bonusDano += 2;
                }
                if (bonusDano > 0) {
                  modDano = "+$bonusDano";
                } else if (bonusDano < 0) {
                  modDano = "$bonusDano";
                }
                if (arma.modificacoes.contains("Ferramenta de Trabalho")) {
                  alertaProf += " | +1 no Ataque";
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151515),
                    border: Border.all(color: Colors.grey.shade900),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      iconColor: corDestaque,
                      collapsedIconColor: Colors.grey,
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      title: Text(
                        arma.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: RichText(
                        text: TextSpan(
                          style: TextStyle(color: corDestaque, fontSize: 13),
                          children: [
                            const TextSpan(text: "Categoria: "),
                            TextSpan(
                              text: "${arma.categoriaEfetiva}   ",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: "Espaços: "),
                            TextSpan(
                              text: arma.espacoEfetivo.toString().replaceAll(
                                '.0',
                                '',
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Checkbox(
                              value: arma.equipado,
                              activeColor: corDestaque,
                              onChanged: (val) => _toggleEquiparArma(arma),
                            ),
                            Icon(
                              Icons.expand_more,
                              color: corDestaque.withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Divider(
                                color: corDestaque.withValues(alpha: 0.3),
                                thickness: 1,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Arma ${arma.tipo} • ${arma.proficiencia} • ${arma.empunhadura}",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Dano: ${arma.danoEfetivo}$modDano | Crítico: ${arma.margemAmeacaEfetiva}/x${arma.multiplicadorCritico}$alertaProf",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              if (arma.modificacoes.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    "Mods: ${arma.modificacoes.join(', ')}",
                                    style: TextStyle(
                                      color: corDestaque,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (!block)
                                    TextButton(
                                      onPressed: () {
                                        setState(() => armas.removeAt(index));
                                        _salvarSilencioso();
                                      },
                                      child: const Text(
                                        "Remover",
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    )
                                  else
                                    const SizedBox.shrink(),
                                  Row(
                                    children: [
                                      if (!block)
                                        TextButton(
                                          onPressed: () =>
                                              mostrarDialogModificarEquipamento(
                                                context: context,
                                                equipamento: arma,
                                                corDestaque: corDestaque,
                                                corTema: corFundoAfinidade,
                                                corTexto: corTextoAfinidade,
                                                afinidadeAtual: afinidadeAtual,
                                                onAplicar: (mods) {
                                                  setState(() {
                                                    armas[index].modificacoes =
                                                        List.from(mods);
                                                    atualizarFicha();
                                                  });
                                                  _salvarSilencioso();
                                                },
                                              ),
                                          child: const Text(
                                            "Editar",
                                            style: TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // ================= ITENS EXPANSÍVEIS =================
              ...inventario.map((item) {
                int index = inventario.indexOf(item);
                bool isEquipavel =
                    item.descricao.toLowerCase().contains("proteção") ||
                    item.nome.toLowerCase().contains("vestimenta") ||
                    item.nome.toLowerCase().contains("escudo");

                String tipoItem = item.descricao.split('.').first;
                String descLimpa = item.descricao
                    .replaceFirst("$tipoItem.", "")
                    .trim();
                if (descLimpa.isEmpty) descLimpa = tipoItem;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151515),
                    border: Border.all(color: Colors.grey.shade900),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      iconColor: corDestaque,
                      collapsedIconColor: Colors.grey,
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      title: Text(
                        item.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: RichText(
                        text: TextSpan(
                          style: TextStyle(color: corDestaque, fontSize: 13),
                          children: [
                            const TextSpan(text: "Categoria: "),
                            TextSpan(
                              text: "${item.categoriaEfetiva}   ",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: "Espaços: "),
                            TextSpan(
                              text: item.espacoEfetivo.toString().replaceAll(
                                '.0',
                                '',
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: isEquipavel
                          ? SizedBox(
                              width: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Checkbox(
                                    value: item.equipado,
                                    activeColor: corDestaque,
                                    onChanged: (val) =>
                                        _toggleEquiparItem(item),
                                  ),
                                  Icon(
                                    Icons.expand_more,
                                    color: corDestaque.withValues(alpha: 0.5),
                                  ),
                                ],
                              ),
                            )
                          : Icon(
                              Icons.expand_more,
                              color: corDestaque.withValues(alpha: 0.5),
                            ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Divider(
                                color: corDestaque.withValues(alpha: 0.3),
                                thickness: 1,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                tipoItem,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                descLimpa,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),

                              if (item.modificacoes.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    "Mods: ${item.modificacoes.join(', ')}",
                                    style: TextStyle(
                                      color: corDestaque,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (!block)
                                    TextButton(
                                      onPressed: () {
                                        setState(
                                          () => inventario.removeAt(index),
                                        );
                                        _salvarSilencioso();
                                      },
                                      child: const Text(
                                        "Remover",
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    )
                                  else
                                    const SizedBox.shrink(),
                                  Row(
                                    children: [
                                      if (!block)
                                        TextButton(
                                          onPressed: () =>
                                              mostrarDialogModificarEquipamento(
                                                context: context,
                                                equipamento: item,
                                                corDestaque: corDestaque,
                                                corTema: corFundoAfinidade,
                                                corTexto: corTextoAfinidade,
                                                afinidadeAtual: afinidadeAtual,
                                                onAplicar: (mods) {
                                                  setState(() {
                                                    inventario[index]
                                                            .modificacoes =
                                                        List.from(mods);
                                                    atualizarFicha();
                                                  });
                                                  _salvarSilencioso();
                                                },
                                              ),
                                          child: const Text(
                                            "Editar",
                                            style: TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
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
        border: Border.all(color: corDestaque.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavBarItem(0, Icons.person, "Atributos", block, corDestaque),
          _buildNavBarItem(1, Icons.star, "Perícias", block, corDestaque),
          _buildNavBarItem(2, Icons.bolt, "Poderes", block, corDestaque),
          _buildNavBarItem(
            3,
            Icons.auto_awesome,
            "Rituais",
            block,
            corDestaque,
          ),
          _buildNavBarItem(4, Icons.backpack, "Inventário", block, corDestaque),
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

  void _inicializarPericias() {
    listaPericias = periciasBase
        .map(
          (p) =>
              Pericia(nome: p["nome"]!, atributo: p["atributo"]!, id: p["id"]!),
        )
        .toList();
  }

  // ================== DIALOGS ESPECÍFICOS DE ORIGENS ==================
}
