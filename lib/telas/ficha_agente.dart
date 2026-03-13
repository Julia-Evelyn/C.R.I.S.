import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../modelos/agente_dados.dart';
import '../dados/base.dart';
import '../dados/itens.dart';
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

  String classeAtual = 'combatente', origemAtual = 'academico';
  String? fotoPath;
  String? afinidadeAtual;
  int nex = 5, prestigio = 0, agi = 1, forc = 1, inte = 1, pre = 1, vig = 1;
  int pvMax = 0, peMax = 0, sanMax = 0, pvAtual = 0, peAtual = 0, sanAtual = 0;
  int defesa = 10, esquiva = 10, bloqueio = 0;
  String habNome = "", habDesc = "";

  int? _indiceAtual;
  bool _modoVisualizacao = false;

  int get espacoMaximo => forc == 0 ? 2 : forc * 5;

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
    Color corDoPopUp = afinidadeAtual == 'Morte'
        ? Colors.white
        : EstiloParanormal.corTema(afinidadeAtual);

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
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
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

  void _abrirCatalogoEquipamento({String filtroInicial = "Todos"}) {
    String filtroAtual = filtroInicial;
    String busca = "";
    Color corTemaLocal = afinidadeAtual == 'Morte'
        ? Colors.white
        : EstiloParanormal.corTema(afinidadeAtual);
    Color corLetra = afinidadeAtual == 'Morte'
        ? Colors.black
        : EstiloParanormal.corTextoTema(afinidadeAtual);

    List<String> categorias = [
      "Todos",
      "Armas",
      "Acessórios",
      "Explosivos",
      "Itens Operacionais",
      "Medicamentos",
      "Munições",
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
                      eq.descricao != "Acessório") {
                    return false;
                  }
                  if (filtroAtual == "Explosivos" &&
                      eq.descricao != "Explosivo") {
                    return false;
                  }
                  if (filtroAtual == "Itens Operacionais" &&
                      eq.descricao != "Item Operacional") {
                    return false;
                  }
                  if (filtroAtual == "Medicamentos" &&
                      eq.descricao != "Medicamento") {
                    return false;
                  }
                  if (filtroAtual == "Munições" && eq.descricao != "Munição") {
                    return false;
                  }
                  if (filtroAtual == "Itens Paranormais" &&
                      eq.descricao != "Item Paranormal") {
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
                side: BorderSide(color: corTemaLocal.withValues(alpha: 0.3)),
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
                        Icon(Icons.inventory_2, color: corTemaLocal, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          "ARSENAL",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: corTemaLocal,
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
                        corTemaLocal,
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
                                        ? corTemaLocal
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
                                      color: corTemaLocal,
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

  void _configurarAdicaoEquipamento(dynamic equipamentoBase) {
    Color corTemaLocal = afinidadeAtual == 'Morte'
        ? Colors.white
        : EstiloParanormal.corTema(afinidadeAtual);
    Color corLetra = afinidadeAtual == 'Morte'
        ? Colors.black
        : EstiloParanormal.corTextoTema(afinidadeAtual);

    bool isArma = equipamentoBase is Arma;
    bool isMunicao =
        !isArma && (equipamentoBase as ItemInventario).descricao == "Munição";

    List<String> modsSelecionados = [];
    String catBase = equipamentoBase.categoria;

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

            List<String> modsDisponiveis = [];
            if (isArma) {
              modsDisponiveis = (equipamentoBase).tipo == "Fogo"
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
            }

            return Dialog(
              backgroundColor: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: corTemaLocal.withValues(alpha: 0.3)),
              ),
              insetPadding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "CONFIGURAR: ${equipamentoBase.nome.toUpperCase()}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: corTemaLocal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isArma
                          ? "Dano: ${equipamentoBase.dano} | Crítico: ${equipamentoBase.margemAmeaca}/x${equipamentoBase.multiplicadorCritico}"
                          : equipamentoBase.descricao,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    if (modsDisponiveis.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "MODIFICAÇÕES",
                            style: TextStyle(
                              color: corTemaLocal,
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
                                    ? Colors.black
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
                                  ? corTemaLocal
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
                    ],

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
                            ),
                            onPressed: () {
                              setState(() {
                                if (isArma) {
                                  Arma a = equipamentoBase;
                                  armas.add(
                                    Arma(
                                      nome: a.nome,
                                      tipo: a.tipo,
                                      dano: a.dano,
                                      margemAmeaca: a.margemAmeaca,
                                      multiplicadorCritico:
                                          a.multiplicadorCritico,
                                      categoria: a.categoria,
                                      espaco: a.espaco,
                                      modificacoes: List.from(modsSelecionados),
                                    ),
                                  );
                                } else {
                                  ItemInventario i =
                                      equipamentoBase as ItemInventario;
                                  inventario.add(
                                    ItemInventario(
                                      nome: i.nome,
                                      categoria: i.categoria,
                                      espaco: i.espaco,
                                      descricao: i.descricao,
                                      modificacoes: List.from(modsSelecionados),
                                    ),
                                  );
                                }
                              });
                              _salvarSilencioso();
                              Navigator.pop(context);
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
      },
    );
  }

  void _mostrarDialogCriacaoManual({required bool isArma}) {
    String nome = "",
        tipo = isArma ? "Corpo a Corpo" : "I",
        dano = "1d4",
        desc = "";
    String categoria = "0";
    int margem = 20, mult = 2;
    double espaco = 1.0;

    Color corTemaLocal = afinidadeAtual == 'Morte'
        ? Colors.white
        : EstiloParanormal.corTema(afinidadeAtual);
    Color corLetra = afinidadeAtual == 'Morte'
        ? Colors.black
        : EstiloParanormal.corTextoTema(afinidadeAtual);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: corTemaLocal.withValues(alpha: 0.3)),
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
                    color: corTemaLocal,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isArma ? "CRIAR ARMA" : "CRIAR ITEM",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: corTemaLocal,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              TextField(
                decoration: EstiloParanormal.customInputDeco(
                  "Nome",
                  corTemaLocal,
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
                          corTemaLocal,
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
                          corTemaLocal,
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
                          corTemaLocal,
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
                          corTemaLocal,
                          Icons.close,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => mult = int.tryParse(val) ?? 2,
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
                        corTemaLocal,
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
                        corTemaLocal,
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
                    corTemaLocal,
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
                      ),
                      onPressed: () {
                        if (nome.isNotEmpty) {
                          setState(() {
                            if (isArma) {
                              armas.add(
                                Arma(
                                  nome: nome,
                                  tipo: tipo,
                                  dano: dano,
                                  margemAmeaca: margem,
                                  multiplicadorCritico: mult,
                                  categoria: categoria,
                                  espaco: espaco,
                                ),
                              );
                            } else {
                              inventario.add(
                                ItemInventario(
                                  nome: nome,
                                  categoria: categoria,
                                  espaco: espaco,
                                  descricao: desc,
                                ),
                              );
                            }
                          });
                          _salvarSilencioso();
                          Navigator.pop(context);
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

  // --- NOVA LÓGICA DE ATUALIZAÇÃO DA FICHA (CÁLCULO DE DEFESA) ---
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
      var stats = dadosClasses[classeAtual];
      if (stats != null) {
        int nivel = (nex / 5).toInt();
        pvMax = stats.pvBase + vig + (stats.pvPorNivel * (nivel - 1));
        peMax = stats.peBase + pre + (stats.pePorNivel * (nivel - 1));
        sanMax = stats.sanBase + (stats.sanPorNivel * (nivel - 1));
      }

      // CÁLCULO DE DEFESA COM PROTEÇÕES EQUIPADAS
      int defItens = 0;
      for (var item in inventario.where((i) => i.equipado)) {
        String nomeLower = item.nome.toLowerCase();
        if (nomeLower.contains("proteção leve")) defItens += 5;
        if (nomeLower.contains("proteção pesada")) defItens += 10;
      }

      int bReflexos = 0, bFortitude = 0;
      for (var p in listaPericias) {
        if (p.id == 'reflexos') bReflexos = p.treino;
        if (p.id == 'fortitude') bFortitude = p.treino;
      }

      defesa = 10 + agi + defItens; // AGI + Bônus do Inventário
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

  // Controle de Trava de Vestimentas e Proteções
  void _toggleEquiparItem(ItemInventario item) {
    if (_modoVisualizacao) return;

    if (!item.equipado) {
      String nomeLower = item.nome.toLowerCase();

      // Limite de Vestimentas = 2
      if (nomeLower.contains("vestimenta")) {
        int equipadas = inventario
            .where(
              (i) => i.equipado && i.nome.toLowerCase().contains("vestimenta"),
            )
            .length;
        if (equipadas >= 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Limite: Você só pode vestir 2 vestimentas ao mesmo tempo!",
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }
      }

      // Limite de Proteção = 1
      if (nomeLower.contains("proteção")) {
        bool temProtecao = inventario.any(
          (i) => i.equipado && i.nome.toLowerCase().contains("proteção"),
        );
        if (temProtecao) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Limite: Você só pode usar 1 proteção por vez!"),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }
      }
    }

    setState(() {
      item.equipado = !item.equipado;
      atualizarFicha();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool block = _modoVisualizacao;
    Color corDoPainel = afinidadeAtual == 'Morte'
        ? Colors.white
        : EstiloParanormal.corTema(afinidadeAtual);

    // Filtramos para os Ataques só as Armas Equipadas
    List<Arma> armasEquipadas = armas.where((a) => a.equipado).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          block ? 'VISUALIZAÇÃO' : 'EDITAR AGENTE',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Form(
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
                      child: BotaoAfinidadeAnimado(
                        onPressed: _mostrarDialogAfinidade,
                      ),
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
                            dadosClasses.keys.toList(),
                            block
                                ? null
                                : (val) {
                                    classeAtual = val!;
                                    atualizarFicha();
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
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildDropdown(
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
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            initialValue: prestigio.toString(),
                            enabled: !block,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Prestígio (PP)",
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Color(0xFF0D0D0D),
                            ),
                            onChanged: (val) {
                              prestigio = int.tryParse(val) ?? 0;
                              atualizarFicha();
                            },
                          ),
                        ),
                      ],
                    ),
                  ]),

                  _buildSecao(
                    "Atributos ${block ? '(Toque para Rolar)' : ''}",
                    [
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
                    ],
                  ),

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

                  // ATAQUES (Mostra APENAS armas equipadas. Sem botão de excluir aqui, o jogador exclui no Inventário)
                  _buildSecao("Armas e Ataques", [
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
                                  "Dano: ${arma.dano} | Crítico: ${arma.margemAmeaca}/x${arma.multiplicadorCritico} \nTipo: ${arma.tipo}",
                                  style: const TextStyle(color: Colors.grey),
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
                                ? () => showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: const Color(0xFF1A1A1A),
                                      title: Text(
                                        "Atacar com ${arma.nome}",
                                        style: TextStyle(color: corDoPainel),
                                      ),
                                      content: Text(
                                        "Role seus dados de ataque e dano (${arma.dano})!",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(
                                            "OK",
                                            style: TextStyle(
                                              color: corDoPainel,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ]),

                  // INVENTÁRIO (Mostra TUDO: Armas e Itens, com Checkbox de Equipar)
                  _buildSecao("Inventário", [
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
                              backgroundColor: corDoPainel,
                              foregroundColor: EstiloParanormal.corTextoTema(
                                afinidadeAtual,
                              ),
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

                    // Renderiza as Armas do Inventário
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
                                "Arma • Cat: ${arma.categoriaEfetiva} | Espaços: ${arma.espacoEfetivo.toString().replaceAll('.0', '')}",
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
                          isThreeLine: arma.modificacoes.isNotEmpty,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Equipar",
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 24,
                                    child: Checkbox(
                                      value: arma.equipado,
                                      activeColor: corDoPainel,
                                      onChanged: block
                                          ? null
                                          : (val) {
                                              setState(() {
                                                arma.equipado = val!;
                                                atualizarFicha();
                                              });
                                            },
                                    ),
                                  ),
                                ],
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

                    // Renderiza os Itens do Inventário
                    ...inventario.map((item) {
                      int index = inventario.indexOf(item);
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
                                "Item • Cat: ${item.categoriaEfetiva} | Espaços: ${item.espacoEfetivo.toString().replaceAll('.0', '')} \n${item.descricao}",
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
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Usar",
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey,
                                    ),
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

                  _buildSecao("Habilidade: $habNome", [
                    Text(
                      habDesc,
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ]),

                  _buildSecao("Perícias", [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: listaPericias.length,
                      itemBuilder: (context, index) {
                        var pericia = listaPericias[index];
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade800),
                            ),
                            color: pericia.treino > 0
                                ? corDoPainel.withValues(alpha: 0.1)
                                : Colors.transparent,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
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
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: pericia.treino,
                                    isExpanded: true,
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      size: 16,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                    items: [
                                      if (!pericia.daOrigem)
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
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 4),
                              SizedBox(
                                width: 40,
                                child: TextFormField(
                                  initialValue: (bonusPericias[pericia.id] ?? 0)
                                      .toString(),
                                  enabled: !block,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (val) {
                                    bonusPericias[pericia.id] =
                                        int.tryParse(val) ?? 0;
                                    _salvarSilencioso();
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
                              "Quando atinge NEX 50% você se conecta com um elemento a sua escolha entre Conhecimento, Energia, Morte e Sangue. Na primeira vez que transcender após isso, irá desenvolver afinidade com o elemento escolhido. Afinidade fornece os seguintes benefícios:\n\n"
                              "• Não precisa de componentes ritualísticos para conjurar rituais do elemento com o qual tem afinidade. Além disso, pode aprender rituais que exijam afinidade com esse elemento.\n\n"
                              "• Recebe +2d20 em testes contra efeitos do seu elemento, mas sofre –2d20 em testes contra efeitos do seu elemento opressor.\n\n"
                              "• Pode escolher poderes paranormais do seu elemento uma segunda vez para receber o benefício listado na linha “Afinidade”.",
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---
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
    Color corDoPopUp = afinidadeAtual == 'Morte'
        ? Colors.white
        : EstiloParanormal.corTema(afinidadeAtual);
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
    Color corDoTema = EstiloParanormal.corTema(afinidadeAtual);
    Color corLetraTema = EstiloParanormal.corTextoTema(afinidadeAtual);

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
