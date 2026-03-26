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
import '../dados/rituais.dart';
import '../dados/trilhas.dart';
import '../componentes/estilizacao.dart';
import '../componentes/dialogs_ficha.dart';
import '../componentes/widgets_ficha.dart';

part 'origens.dart';
part 'pericias.dart';
part 'equipamentos.dart';
part 'guia_combate.dart';
part 'rituais_aba.dart';

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

  List<Poder> poderesEscolhidos = [];
  List<Ritual> rituaisConhecidos = [];
  List<String> periciasClasse = [];

  Map<String, int> resistencias = {};
  Map<String, int> bonusOrigem = {};

  String classeAtual = '--', origemAtual = '--', trilhaAtual = '--';
  String? fotoPath;
  String? afinidadeAtual;
  int nex = 5, prestigio = 0, agi = 1, forc = 1, inte = 1, pre = 1, vig = 1;

  // ATRIBUTOS EFETIVOS E PENALIDADES (MONSTRUOSO)
  int efAgi = 1, efFor = 1, efInt = 1, efPre = 1, efVig = 1;
  Map<String, int> dadosExtrasPericias = {};

  // RASTREADORES DE MALDIÇÃO (Afetam Sanidade)
  int maldicoesConhecimento = 0,
      maldicoesEnergia = 0,
      maldicoesMorte = 0,
      maldicoesSangue = 0;

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
    if (origemAtual == 'revoltado' &&
        poderesEscolhidos.any((p) => p.nome == "Revoltado_Sozinho")) {
      baseLimite += 1;
    }
    return baseLimite;
  }

  int get deslocamento {
    int baseDesl = 9;
    if (origemAtual == 'ginasta') baseDesl += 3;
    if (estaSobrecarregado) baseDesl -= 3;
    return baseDesl;
  }

  int get totalAtributosPermitidos {
    int max = 9;
    if (nex >= 20) max += 1;
    if (nex >= 50) max += 1;
    if (nex >= 80) max += 1;
    if (nex >= 95) max += 1;
    return max;
  }

  int get totalAtributosAtuais {
    return agi + forc + inte + pre + vig;
  }

  int get espacoMaximo {
    int base = forc == 0 ? 2 : forc * 5;
    if (poderesEscolhidos.any((p) => p.nome == "Mochileiro")) base += 5;
    if (trilhaAtual == 'tecnico' && nex >= 10) base += (inte * 5);
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

  bool get estaSobrecarregado => espacoOcupado > espacoMaximo;

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
    if (origemAtual == 'magnata') {
      if (prestigio >= 100) return "Ilimitado";
      if (prestigio >= 20) return "Alto";
      return "Médio";
    } else {
      if (prestigio >= 200) return "Ilimitado";
      if (prestigio >= 100) return "Alto";
      if (prestigio >= 20) return "Médio";
      return "Baixo";
    }
  }

  Map<String, int> get limitesCategoria {
    Map<String, int> limites;
    if (prestigio >= 200) {
      limites = {"I": 3, "II": 3, "III": 3, "IV": 2};
    } else if (prestigio >= 100) {
      limites = {"I": 3, "II": 3, "III": 2, "IV": 1};
    } else if (prestigio >= 50) {
      limites = {"I": 3, "II": 2, "III": 1, "IV": 0};
    } else if (prestigio >= 20) {
      limites = {"I": 3, "II": 1, "III": 0, "IV": 0};
    } else {
      limites = {"I": 2, "II": 0, "III": 0, "IV": 0};
    }

    int profTreino = listaPericias
        .firstWhere(
          (p) => p.id == 'profissao',
          orElse: () => Pericia(id: '', nome: '', atributo: ''),
        )
        .treino;
    if (profTreino >= 15) {
      limites['III'] = limites['III']! + 1;
    } else if (profTreino >= 10) {
      limites['II'] = limites['II']! + 1;
    } else if (profTreino >= 5) {
      limites['I'] = limites['I']! + 1;
    }
    return limites;
  }

  // ========================================================
  // LÓGICA DE CATEGORIAS (COM MALDIÇÕES E MODS NORMAIS)
  // ========================================================
  // ========================================================
  // LÓGICA DE CATEGORIAS (COM MALDIÇÕES E MODS NORMAIS)
  // ========================================================
  int _calcularAumentoCategoriaGeral(List<String> mods) {
    int qtdMaldicoes = 0;
    int qtdNormais = 0;
    List<String> maldicoes = [
      "Lancinante",
      "Predadora",
      "Sanguinária",
      "Consumidora",
      "Erosiva",
      "Repulsora",
      "Empuxo",
      "Energética",
      "Vibrante",
      "Antielemento",
      "Ritualística",
      "Senciente",
      "Regenerativa",
      "Sádica",
      "Letárgica",
      "Repulsiva",
      "Cinética",
      "Lépida",
      "Voltaica",
      "Abascanta",
      "Profética",
      "Sombria",
      "Carisma",
      "Conjuração",
      "Escudo Mental",
      "Reflexão",
      "Sagacidade",
      "Defesa",
      "Destreza",
      "Potência",
      "Esforço Adicional",
      "Disposição",
      "Pujança",
      "Vitalidade",
      "Proteção Elemental (Sangue)",
      "Proteção Elemental (Morte)",
      "Proteção Elemental (Energia)",
      "Proteção Elemental (Conhecimento)",
    ];

    for (String mod in mods) {
      if ([
        "Ferramenta Favorita",
        "Ferramenta de Trabalho",
        "Arma Favorita",
      ].contains(mod)) {
        continue;
      }
      if (maldicoes.contains(mod)) {
        qtdMaldicoes++;
      } else {
        qtdNormais++;
      }
    }
    // A 1ª maldição sobe +2, as demais +1.
    return qtdNormais + (qtdMaldicoes > 0 ? (1 + qtdMaldicoes) : 0);
  }

  String _obterCategoriaCalculada(dynamic eq) {
    String cat = eq.categoria;
    if (cat == "--") return cat;

    List<String> ordemCompleta = [
      "0",
      "I",
      "II",
      "III",
      "IV",
      "V",
      "VI",
      "VII",
      "VIII",
      "IX",
      "X",
    ];
    int idxBase = ordemCompleta.indexOf(cat.trim());
    if (idxBase == -1) return cat;

    int aumento = _calcularAumentoCategoriaGeral(
      List<String>.from(eq.modificacoes),
    );
    int idxAumentado = idxBase + aumento;

    int reducao = 0;
    // O Aniquilador reduz a categoria final APÓS todos os aumentos
    if (eq is Arma &&
        trilhaAtual == 'aniquilador' &&
        eq.modificacoes.contains("Arma Favorita")) {
      reducao = nex >= 99 ? 3 : (nex >= 40 ? 2 : 1);
    }

    int idxFinal = max(0, idxAumentado - reducao);
    idxFinal = min(
      4,
      idxFinal,
    ); // TRAVA ABSOLUTA: O limite máximo da categoria é IV (índice 4)

    return ordemCompleta[idxFinal];
  }

  Map<String, int> get usoCategoriaAtual {
    var uso = {"I": 0, "II": 0, "III": 0, "IV": 0};
    for (var item in inventario) {
      String cat = _obterCategoriaCalculada(item);
      if (uso.containsKey(cat)) uso[cat] = uso[cat]! + 1;
    }
    for (var arma in armas) {
      String cat = _obterCategoriaCalculada(arma);
      if (uso.containsKey(cat)) uso[cat] = uso[cat]! + 1;
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
      trilhaAtual = ag.trilha;
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
      rituaisConhecidos = List.from(ag.rituais);
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
      trilha: trilhaAtual,
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
      rituais: rituaisConhecidos,
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

    int penCon = maldicoesConhecimento * 2;
    int penEne = maldicoesEnergia * 2;
    int penMor = maldicoesMorte * 2;
    int penSan = maldicoesSangue * 2;

    String avisoMaldicao = "";
    if (nomeAtrib == "INT" && penCon > 0) {
      avisoMaldicao =
          "⚠️ FALHAR CUSTARÁ $penCon SAN (Maldições do Conhecimento)";
    }
    if (nomeAtrib == "AGI" && penEne > 0) {
      avisoMaldicao = "⚠️ FALHAR CUSTARÁ $penEne SAN (Maldições de Energia)";
    }
    if (nomeAtrib == "PRE" && penMor > 0) {
      avisoMaldicao = "⚠️ FALHAR CUSTARÁ $penMor SAN (Maldições da Morte)";
    }
    if ((nomeAtrib == "FOR" || nomeAtrib == "VIG") && penSan > 0) {
      avisoMaldicao = "⚠️ FALHAR CUSTARÁ $penSan SAN (Maldições de Sangue)";
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
            if (avisoMaldicao.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                avisoMaldicao,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
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

  void _usarPoder(Poder poder) {
    if (!_modoVisualizacao) return;
    if (poder.custoPE <= 0) return;

    if (peAtual >= poder.custoPE) {
      setState(() => peAtual -= poder.custoPE);
      _salvarSilencioso();
      _mostrarNotificacao("Usou ${poder.nome}: -${poder.custoPE} PE");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pontos de Esforço insuficientes!"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _rolarAtaque(Arma arma, int bonusDanoFixo, bool isProficiente) {
    if (!_modoVisualizacao) return;

    String atributoUsado = arma.atributoPersonalizado.isNotEmpty
        ? arma.atributoPersonalizado
        : (arma.tipo == 'Corpo a Corpo' ? 'FOR' : 'AGI');
    String periciaUsada = arma.periciaPersonalizada.isNotEmpty
        ? arma.periciaPersonalizada
        : (arma.tipo == 'Corpo a Corpo' ? 'luta' : 'pontaria');

    int valorAtrib = 1;
    switch (atributoUsado) {
      case 'AGI':
        valorAtrib = agi;
        break;
      case 'FOR':
        valorAtrib = forc;
        break;
      case 'INT':
        valorAtrib = inte;
        break;
      case 'PRE':
        valorAtrib = pre;
        break;
      case 'VIG':
        valorAtrib = vig;
        break;
    }

    int modAtaque = 0;
    int modMultExtra = 0;
    List<String> dadosDanoExtra = [];

    for (String mod in arma.modificacoes) {
      String mLower = mod.toLowerCase();
      if (mLower.contains("certeira") || mLower.contains("alongada")) {
        modAtaque += 2;
      }
      if (mLower.contains("ferramenta de trabalho")) modAtaque += 1;
      if (mLower.contains("letal") || mLower.contains("dum dum")) {
        modMultExtra += 1;
      }

      if (mLower.contains("sanguinária") ||
          mLower.contains("flamejante") ||
          mLower.contains("vibrante") ||
          mLower.contains("energética") ||
          mLower.contains("erosiva")) {
        dadosDanoExtra.add("1d6");
      }
      if (mLower.contains("lancinante") || mLower.contains("erosiva")) {
        dadosDanoExtra.add("1d8");
      }
      if (mLower.contains("antielemento")) dadosDanoExtra.add("4d8");
      if (mLower.contains("predadora")) {
        arma.margemAmeaca = 20 - ((20 - arma.margemAmeaca) * 2);
      }
    }

    int modMargemTrilha = 0;
    bool aniquilador99 = false;

    if (trilhaAtual == 'guerreiro' &&
        nex >= 10 &&
        arma.tipo == 'Corpo a Corpo') {
      modMargemTrilha += 2;
    }
    if (trilhaAtual == 'aniquilador' &&
        nex >= 99 &&
        arma.modificacoes.contains("Arma Favorita")) {
      modMargemTrilha += 2;
      aniquilador99 = true;
    }

    Pericia perObj = listaPericias.firstWhere(
      (p) => p.id == periciaUsada,
      orElse: () => Pericia(id: '', nome: '', atributo: ''),
    );
    int bonusPericia = perObj.treino;
    int bonusExtraItem = 0;
    for (var v in inventario.where(
      (i) => i.periciaVinculada == periciaUsada && i.equipado,
    )) {
      int b =
          (v.modificacoes.contains("Aprimorado") ||
              v.modificacoes.contains("Aprimorada"))
          ? 5
          : 2;
      if (b > bonusExtraItem) bonusExtraItem = b;
    }
    int totalBonus =
        bonusPericia +
        (bonusOrigem[periciaUsada] ?? 0) +
        bonusExtraItem +
        modAtaque;

    int dadosExtras = isProficiente ? 0 : -2;
    int qtdDados = valorAtrib + dadosExtras;
    bool rolarPior = false;

    if (qtdDados <= 0) {
      qtdDados = 2 + qtdDados.abs();
      rolarPior = true;
    }

    List<int> d20s = List.generate(qtdDados, (_) => Random().nextInt(20) + 1);
    int d20Escolhido = rolarPior ? d20s.reduce(min) : d20s.reduce(max);
    int resultadoAtaque = d20Escolhido + totalBonus;

    int margemFinal = arma.margemAmeacaEfetiva - modMargemTrilha;
    int multFinal = arma.multiplicadorCritico + modMultExtra;

    bool isCrit = d20Escolhido >= margemFinal;
    bool isFalhaCritica = d20Escolhido == 1;

    int totalDano = 0;
    List<int> rolagensDano = [];
    int flatTotal = bonusDanoFixo;

    String stringDanoLimpo = arma.danoEfetivo
        .replaceAll(' ', '')
        .replaceAll('-', '+-');
    var partes = stringDanoLimpo.split('+');

    if (aniquilador99 && partes.isNotEmpty && partes[0].contains('d')) {
      var dp = partes[0].split('d');
      if (dp.length == 2) {
        int q = (int.tryParse(dp[0]) ?? 1) + 1;
        partes[0] = "${q}d${dp[1]}";
      }
    }

    partes.addAll(dadosDanoExtra);

    for (var parte in partes) {
      parte = parte.trim();
      if (parte.isEmpty) continue;

      if (parte.contains('d')) {
        var dp = parte.split('d');
        if (dp.length == 2) {
          int qtd = int.tryParse(dp[0]) ?? 1;
          int faces = int.tryParse(dp[1]) ?? 0;

          if (isCrit && !isFalhaCritica) qtd *= multFinal;

          for (int i = 0; i < qtd; i++) {
            int r = Random().nextInt(faces) + 1;
            rolagensDano.add(r);
            totalDano += r;
          }
        }
      } else {
        flatTotal += int.tryParse(parte) ?? 0;
      }
    }
    totalDano += flatTotal;
    if (isFalhaCritica) totalDano = 0;

    Color corD20 = Colors.white;
    String tituloCrit = "";
    if (isCrit && !isFalhaCritica) {
      corD20 = Colors.amberAccent;
      tituloCrit = "\nSUCESSO CRÍTICO!\n";
    }
    if (isFalhaCritica) {
      corD20 = Colors.redAccent;
      tituloCrit = "\nFALHA CRÍTICA!\n";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          "Ataque: ${arma.nome}",
          textAlign: TextAlign.center,
          style: TextStyle(color: corDestaque, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Teste de ${perObj.nome.isEmpty ? periciaUsada.toUpperCase() : perObj.nome} ($atributoUsado)",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Text(
              "Ataque: $resultadoAtaque",
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: corD20,
              ),
            ),
            Text(
              "Dados (${rolarPior ? 'Pior de $qtdDados' : '${qtdDados}d20'}): [${d20s.join(', ')}]\nCálculo: $d20Escolhido (Dado) + $totalBonus (Bônus)",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            Text(
              tituloCrit,
              style: TextStyle(
                color: corD20,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Divider(color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              "Dano: $totalDano",
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            Text(
              "Dados: [${rolagensDano.join(', ')}]${flatTotal != 0 ? ' + $flatTotal' : ''}",
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            if (modAtaque > 0 ||
                modMultExtra > 0 ||
                dadosDanoExtra.isNotEmpty ||
                modMargemTrilha > 0 ||
                aniquilador99)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Bônus de Trilhas e Efeitos Ativos.",
                  style: TextStyle(
                    color: corDestaque,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("FECHAR", style: TextStyle(color: corDestaque)),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogEditarAtaque(Arma arma) {
    String attrAtual = arma.atributoPersonalizado.isEmpty
        ? "Padrão"
        : arma.atributoPersonalizado;
    String periciaAtual = arma.periciaPersonalizada.isEmpty
        ? "Padrão"
        : arma.periciaPersonalizada;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: Text(
                "Editar Teste: ${arma.nome}",
                style: TextStyle(color: corDestaque),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownFicha(
                    label: "Atributo Base",
                    value: attrAtual,
                    options: const [
                      "Padrão",
                      "FOR",
                      "AGI",
                      "INT",
                      "PRE",
                      "VIG",
                    ],
                    onChanged: (val) => setDialogState(() => attrAtual = val!),
                  ),
                  const SizedBox(height: 16),
                  DropdownFicha(
                    label: "Perícia do Teste",
                    value: periciaAtual,
                    options: const [
                      "Padrão",
                      "luta",
                      "pontaria",
                      "ocultismo",
                      "tecnologia",
                      "crime",
                      "sobrevivencia",
                    ],
                    onChanged: (val) =>
                        setDialogState(() => periciaAtual = val!),
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
                    backgroundColor: corDestaque,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      arma.atributoPersonalizado = attrAtual == "Padrão"
                          ? ""
                          : attrAtual;
                      arma.periciaPersonalizada = periciaAtual == "Padrão"
                          ? ""
                          : periciaAtual;
                      atualizarFicha();
                    });
                    _salvarSilencioso();
                    Navigator.pop(context);
                  },
                  child: const Text("SALVAR"),
                ),
              ],
            );
          },
        );
      },
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
              if (p.daOrigem) return false;
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
                                      trilhaAtual = '--';
                                      poderesEscolhidos.removeWhere(
                                        (p) =>
                                            p.tipo == "Combatente" ||
                                            p.tipo == "Especialista" ||
                                            p.tipo == "Ocultista" ||
                                            p.tipo == "Sistema",
                                      );

                                      if (novaClasse == 'combatente') {
                                        poderesEscolhidos.add(
                                          Poder(
                                            nome: "Ataque Especial",
                                            tipo: "Combatente",
                                            descricao:
                                                "Quando faz um ataque, você pode gastar 2 PE para receber +5...",
                                            custoPE: 2,
                                          ),
                                        );
                                      } else if (novaClasse == 'especialista') {
                                        poderesEscolhidos.add(
                                          Poder(
                                            nome: "Eclético",
                                            tipo: "Especialista",
                                            descricao:
                                                "Quando faz um teste de uma perícia, você pode gastar 2 PE para...",
                                            custoPE: 2,
                                          ),
                                        );
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
                                          Poder(
                                            nome:
                                                "Perito (${nomesPerito.join(', ')})",
                                            tipo: "Especialista",
                                            descricao:
                                                "Gaste 2 PE para somar +1d6...",
                                            custoPE: 2,
                                          ),
                                        );
                                      } else if (novaClasse == 'ocultista') {
                                        poderesEscolhidos.add(
                                          Poder(
                                            nome: "Escolhido pelo Outro Lado",
                                            tipo: "Ocultista",
                                            descricao:
                                                "Você pode lançar rituais de 1º círculo...",
                                          ),
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

  void _abrirCatalogoPoderes() {
    String busca = "";
    String filtroPrincipal = "Gerais";
    String filtroParanormal = "Conhecimento";

    Color corTemaLocal = corFundoAfinidade;
    Color corLetra = corTextoAfinidade;
    Color corDestaqueLocal = corDestaque;

    List<String> categoriasPrincipais = [
      "Gerais",
      if (classeAtual == 'combatente') "Combatente",
      if (classeAtual == 'especialista') "Especialista",
      if (classeAtual == 'ocultista') "Ocultista",
      "Poderes Paranormais",
    ];
    if (!categoriasPrincipais.contains(filtroPrincipal)) {
      filtroPrincipal = "Gerais";
    }
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
                if (poderesEscolhidos.any(
                  (pe) => pe.nome == "${p.nome} (Afinidade)",
                )) {
                  return false;
                }
              } else {
                if (poderesEscolhidos.any((pe) => pe.nome == p.nome)) {
                  return false;
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
                            Color corElemento = cat == 'Sangue'
                                ? const Color(0xFF990000)
                                : cat == 'Energia'
                                ? const Color(0xFF9900FF)
                                : cat == 'Conhecimento'
                                ? const Color(0xFFFFB300)
                                : Colors.grey.shade400;
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
                                      poderesEscolhidos.any(
                                        (pe) => pe.nome == p.nome,
                                      );
                                  Color corTitulo = Colors.white;
                                  if (isParanormal) {
                                    if (filtroParanormal == 'Sangue') {
                                      corTitulo = const Color(0xFF990000);
                                    } else if (filtroParanormal == 'Energia') {
                                      corTitulo = const Color(0xFF9900FF);
                                    } else if (filtroParanormal ==
                                        'Conhecimento') {
                                      corTitulo = const Color(0xFFFFB300);
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
                                            poderesEscolhidos.removeWhere(
                                              (pe) => pe.nome == p.nome,
                                            );
                                            poderesEscolhidos.add(
                                              Poder(
                                                nome: "${p.nome} (Afinidade)",
                                                tipo: p.tipo,
                                                descricao: p.descricao,
                                              ),
                                            );
                                          } else {
                                            poderesEscolhidos.add(p);
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

  void atualizarFicha({bool isInitialLoad = false}) {
    setState(() {
      int oldPvMax = pvMax;
      int oldPeMax = peMax;
      int oldSanMax = sanMax;

      if (nex < 10 || classeAtual == '--') trilhaAtual = '--';
      if (nex < 50 && afinidadeAtual != null && trilhaAtual != 'monstruoso') {
        afinidadeAtual = null;
      }

      efAgi = agi;
      efFor = forc;
      efInt = inte;
      efPre = pre;
      efVig = vig;
      dadosExtrasPericias.clear();
      bonusOrigem.clear();
      resistencias.clear();

      if (trilhaAtual == 'monstruoso' && nex >= 10) {
        String elem = afinidadeAtual ?? 'Sangue';
        int resValue = 5;
        int penValue = -1;
        if (nex >= 40) {
          resValue = 10;
          penValue = -2;
        }
        if (nex >= 65) {
          resValue = 15;
          efPre -= 1;
        }
        if (nex >= 99) {
          resValue = 20;
        }

        if (!periciasClasse.contains('ocultismo')) {
          periciasClasse.add('ocultismo');
        }

        if (elem == 'Sangue') {
          resistencias['Balístico'] =
              (resistencias['Balístico'] ?? 0) + resValue;
          resistencias['Sangue'] = (resistencias['Sangue'] ?? 0) + resValue;
          dadosExtrasPericias['ciencias'] = penValue;
          dadosExtrasPericias['intuicao'] = penValue;
          if (nex >= 99) {
            efInt -= 1;
            efFor += 1;
          }
          if (nex >= 65 && !armas.any((a) => a.nome == "Mordida Monstruosa")) {
            armas.add(
              Arma(
                nome: "Mordida Monstruosa",
                tipo: "Corpo a Corpo",
                dano: "1d8",
                margemAmeaca: 20,
                multiplicadorCritico: 2,
                categoria: "0",
                espaco: 0,
                proficiencia: "Simples",
                empunhadura: "Leve",
                descricao: "Arma natural (Faro).",
              ),
            );
          }
        } else if (elem == 'Morte') {
          resistencias['Perfuração'] =
              (resistencias['Perfuração'] ?? 0) + resValue;
          resistencias['Morte'] = (resistencias['Morte'] ?? 0) + resValue;
          dadosExtrasPericias['diplomacia'] = penValue;
          dadosExtrasPericias['enganacao'] = penValue;
          if (nex >= 40) {
            dadosExtrasPericias['intimidacao'] =
                (dadosExtrasPericias['intimidacao'] ?? 0) + 1;
          }
          if (nex >= 99) {
            efPre -= 1;
            efVig += 1;
            resistencias['Morte'] = 999;
          }
        } else if (elem == 'Conhecimento') {
          resistencias['Balístico'] =
              (resistencias['Balístico'] ?? 0) + resValue;
          resistencias['Conhecimento'] =
              (resistencias['Conhecimento'] ?? 0) + resValue;
          dadosExtrasPericias['atletismo'] = penValue;
          dadosExtrasPericias['acrobacia'] = penValue;
          if (nex >= 40) efInt += 1;
          if (nex >= 99) {
            efFor -= 1;
            efInt += 1;
          }
        } else if (elem == 'Energia') {
          resistencias['Corte'] = (resistencias['Corte'] ?? 0) + resValue;
          resistencias['Eletricidade'] =
              (resistencias['Eletricidade'] ?? 0) + resValue;
          resistencias['Fogo'] = (resistencias['Fogo'] ?? 0) + resValue;
          resistencias['Energia'] = (resistencias['Energia'] ?? 0) + resValue;
          dadosExtrasPericias['investigacao'] = penValue;
          dadosExtrasPericias['percepcao'] = penValue;
          if (nex >= 65) {
            resistencias['Químico'] = (resistencias['Químico'] ?? 0) + resValue;
          }
          if (nex >= 99) {
            efFor -= 1;
            efAgi += 1;
          }
        }
      }

      if (trilhaAtual != 'cacador') {
        poderesEscolhidos.removeWhere((p) => p.nome.startsWith("Cacador_"));
      }
      if (trilhaAtual != 'agente_secreto') {
        poderesEscolhidos.removeWhere(
          (p) => p.nome.startsWith("AgenteSecreto_"),
        );
      }

      var origemData = dadosOrigens[origemAtual];
      if (origemData == null) {
        String normalizedOrigin = origemAtual.toLowerCase().replaceAll(
          '_',
          ' ',
        );
        for (var key in dadosOrigens.keys) {
          if (key.toLowerCase().replaceAll('_', ' ') == normalizedOrigin) {
            origemAtual = key;
            origemData = dadosOrigens[key];
            break;
          }
        }
      }

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

      if (origemAtual == 'colegial' &&
          poderesEscolhidos.any((p) => p.nome == "Colegial_Perto") &&
          !poderesEscolhidos.any((p) => p.nome == "Colegial_Morto")) {
        for (var p in listaPericias) {
          bonusOrigem[p.id] = 2;
        }
      }
      if (origemAtual == 'revoltado' &&
          poderesEscolhidos.any((p) => p.nome == "Revoltado_Sozinho")) {
        for (var p in listaPericias) {
          bonusOrigem[p.id] = (bonusOrigem[p.id] ?? 0) + 1;
        }
      }

      if (origemAtual == 'diplomata') bonusOrigem['diplomacia'] = 2;
      if (origemAtual == 'profetizado') bonusOrigem['vontade'] = 2;
      if (origemAtual == 'experimento') resistencias['Geral'] = 2;
      if (origemAtual == 'teorico_da_conspiracao') {
        resistencias['Mental'] = efInt;
      }
      if (trilhaAtual == 'operacoes_especiais' && nex >= 10) {
        bonusOrigem['iniciativa'] = (bonusOrigem['iniciativa'] ?? 0) + 5;
      }

      var stats = dadosClasses[classeAtual];
      if (stats != null) {
        int nivel = (nex / 5).toInt();

        int atributoPE = efPre;
        if (trilhaAtual == 'monstruoso' && nex >= 40) {
          if (afinidadeAtual == 'Sangue') atributoPE = efFor;
          if (afinidadeAtual == 'Morte') atributoPE = efVig;
          if (afinidadeAtual == 'Conhecimento') atributoPE = efInt;
          if (afinidadeAtual == 'Energia') atributoPE = efAgi;
        }

        pvMax =
            stats.pvBase + (efVig * nivel) + (stats.pvPorNivel * (nivel - 1));
        if (trilhaAtual == 'monstruoso' && afinidadeAtual == 'Morte') {
          pvMax += efFor;
        }

        peMax =
            stats.peBase +
            (atributoPE * nivel) +
            (stats.pePorNivel * (nivel - 1));
        if (origemAtual == 'colegial' &&
            poderesEscolhidos.any((p) => p.nome == "Colegial_Morto")) {
          peMax -= nivel;
        }

        int qtdParanormal = poderesEscolhidos
            .where(
              (p) => [
                "Conhecimento",
                "Energia",
                "Morte",
                "Sangue",
              ].contains(p.tipo),
            )
            .length;
        int sanBase = origemAtual == 'cultista_arrependido'
            ? (stats.sanBase ~/ 2)
            : stats.sanBase;
        if (origemAtual == 'cultista_arrependido' && qtdParanormal > 0) {
          qtdParanormal--;
        }

        int perdaMedo = poderesEscolhidos
            .where((p) => p.nome == "Sistema_PerdaSanidadeMedo")
            .length;
        sanMax =
            sanBase +
            (stats.sanPorNivel * (nivel - 1)) -
            (qtdParanormal * stats.sanPorNivel) -
            perdaMedo;
        if (sanMax < 0) sanMax = 0;

        if (origemAtual == 'desgarrado') pvMax += nivel;
        if (origemAtual == 'vitima') sanMax += nivel;
        if (origemAtual == 'mergulhador') pvMax += 5;
        if (origemAtual == 'universitario') {
          peMax += 1;
          int nexImpares = (nivel / 2).floor();
          if (nivel >= 3) peMax += nexImpares;
        }
        if (trilhaAtual == 'tropa_de_choque' && nex >= 10) pvMax += nivel;
      } else {
        if (isInitialLoad && widget.agenteParaEditar == null) {
          pvMax = 0;
          peMax = 0;
          sanMax = 0;
        }
      }

      int defItens = 0, bonusBloqueioBracadeira = 0;
      bool usaProtecaoLeve = false;
      bool usaProtecaoPesadaOuEscudo = false;

      maldicoesConhecimento = 0;
      maldicoesEnergia = 0;
      maldicoesMorte = 0;
      maldicoesSangue = 0;

      void processarMaldicao(String m) {
        if ([
          "Antielemento",
          "Ritualística",
          "Senciente",
          "Abascanta",
          "Profética",
          "Sombria",
          "Carisma",
          "Conjuração",
          "Escudo Mental",
          "Reflexão",
          "Sagacidade",
          "Proteção Elemental (Conhecimento)",
        ].contains(m)) {
          maldicoesConhecimento++;
        }
        if ([
          "Empuxo",
          "Energética",
          "Vibrante",
          "Cinética",
          "Lépida",
          "Voltaica",
          "Defesa",
          "Destreza",
          "Potência",
          "Proteção Elemental (Energia)",
        ].contains(m)) {
          maldicoesEnergia++;
        }
        if ([
          "Consumidora",
          "Erosiva",
          "Repulsora",
          "Letárgica",
          "Repulsiva",
          "Esforço Adicional",
          "Proteção Elemental (Morte)",
        ].contains(m)) {
          maldicoesMorte++;
        }
        if ([
          "Lancinante",
          "Predadora",
          "Sanguinária",
          "Regenerativa",
          "Sádica",
          "Disposição",
          "Pujança",
          "Vitalidade",
          "Proteção Elemental (Sangue)",
        ].contains(m)) {
          maldicoesSangue++;
        }

        // Status bônus de Maldições de Acessórios/Proteções
        if (m == "Sagacidade") efInt += 1;
        if (m == "Carisma") efPre += 1;
        if (m == "Destreza") efAgi += 1;
        if (m == "Disposição") efVig += 1;
        if (m == "Pujança") efFor += 1;
        if (m == "Vitalidade") pvMax += 15;
        if (m == "Esforço Adicional") peMax += 5;
        if (m == "Escudo Mental") {
          resistencias['Mental'] = (resistencias['Mental'] ?? 0) + 10;
        }
        if (m == "Defesa") defItens += 5;
        if (m == "Profética") {
          resistencias['Conhecimento'] =
              (resistencias['Conhecimento'] ?? 0) + 10;
        }
        if (m == "Sombria") {
          dadosExtrasPericias['furtividade'] =
              (dadosExtrasPericias['furtividade'] ?? 0) + 5;
        }
        if (m == "Cinética") {
          defItens += 2;
          resistencias['Geral'] = (resistencias['Geral'] ?? 0) + 2;
        }
        if (m == "Lépida") {
          dadosExtrasPericias['atletismo'] =
              (dadosExtrasPericias['atletismo'] ?? 0) + 10;
        }
        if (m == "Voltaica") {
          resistencias['Energia'] = (resistencias['Energia'] ?? 0) + 10;
        }
        if (m == "Letárgica") defItens += 2;
        if (m == "Repulsiva") {
          resistencias['Morte'] = (resistencias['Morte'] ?? 0) + 10;
        }
        if (m == "Regenerativa") {
          resistencias['Sangue'] = (resistencias['Sangue'] ?? 0) + 10;
        }
        if (m == "Proteção Elemental (Sangue)") {
          resistencias['Sangue'] = (resistencias['Sangue'] ?? 0) + 10;
        }
        if (m == "Proteção Elemental (Morte)") {
          resistencias['Morte'] = (resistencias['Morte'] ?? 0) + 10;
        }
        if (m == "Proteção Elemental एनर्जी") {
          resistencias['Energia'] = (resistencias['Energia'] ?? 0) + 10;
        }
        if (m == "Proteção Elemental (Conhecimento)") {
          resistencias['Conhecimento'] =
              (resistencias['Conhecimento'] ?? 0) + 10;
        }
      }

      // Varredura Itens
      for (var item in inventario.where((i) => i.equipado)) {
        String nomeLower = item.nome.toLowerCase();
        String descLower = item.descricao.toLowerCase();

        for (var mod in item.modificacoes) {
          processarMaldicao(mod);
        }

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

      // Varredura Armas (Apenas pro Preço da Maldição e Repulsora)
      for (var arma in armas.where((a) => a.equipado)) {
        for (var mod in arma.modificacoes) {
          processarMaldicao(mod);
          if (mod == "Repulsora") defItens += 2;
        }
      }

      sofrePenalidadeProtecao = false;
      if (usaProtecaoPesadaOuEscudo) {
        sofrePenalidadeProtecao = true;
      } else if (usaProtecaoLeve && classeAtual == 'ocultista') {
        sofrePenalidadeProtecao = true;
      }

      int bReflexos = listaPericias
          .firstWhere(
            (p) => p.id == 'reflexos',
            orElse: () => Pericia(nome: '', id: '', atributo: ''),
          )
          .treino;
      int bFortitude = listaPericias
          .firstWhere(
            (p) => p.id == 'fortitude',
            orElse: () => Pericia(nome: '', id: '', atributo: ''),
          )
          .treino;

      int bonusDefesaOrigem = 0;
      if (origemAtual == 'policial') bonusDefesaOrigem += 2;
      if (origemAtual == 'ginasta') bonusDefesaOrigem += 2;
      if (origemAtual == 'revoltado' &&
          poderesEscolhidos.any((p) => p.nome == "Revoltado_Sozinho")) {
        bonusDefesaOrigem += 1;
      }

      defesa = 10 + efAgi + defItens + bonusDefesaOrigem;
      if (trilhaAtual == 'monstruoso' && afinidadeAtual == 'Conhecimento') {
        defesa += efInt;
      }
      if (estaSobrecarregado) defesa -= 5;

      esquiva = defesa + bReflexos;
      bloqueio = bFortitude + bonusBloqueioBracadeira;

      if (trilhaAtual == 'monstruoso' && afinidadeAtual == 'Energia') {
        bloqueio += efAgi;
      }
      if (trilhaAtual == 'tropa_de_choque' && nex >= 10) bloqueio += efVig;

      bool isMachucado = pvMax > 0 && pvAtual <= (pvMax ~/ 2);
      if (trilhaAtual == 'tropa_de_choque' && nex >= 99 && isMachucado) {
        defesa += 5;
        resistencias['Geral'] = (resistencias['Geral'] ?? 0) + 5;
      }

      if (trilhaAtual == 'cacador' && nex >= 10) {
        if (!poderesEscolhidos.any((p) => p.nome == "Cacador_SetupFeito")) {
          var p = listaPericias.firstWhere(
            (e) => e.id == 'sobrevivencia',
            orElse: () => Pericia(id: '', nome: '', atributo: ''),
          );
          if (p.id.isNotEmpty) {
            if (p.treino == 0) {
              p.treino = 5;
            } else {
              poderesEscolhidos.add(
                Poder(
                  nome: "Cacador_Bonus_sobrevivencia",
                  tipo: "Sistema",
                  descricao: "",
                ),
              );
            }
          }
          poderesEscolhidos.add(
            Poder(nome: "Cacador_SetupFeito", tipo: "Sistema", descricao: ""),
          );
        }
        if (poderesEscolhidos.any(
          (p) => p.nome == "Cacador_Bonus_sobrevivencia",
        )) {
          bonusOrigem['sobrevivencia'] =
              (bonusOrigem['sobrevivencia'] ?? 0) + 2;
        }
      }

      if (trilhaAtual == 'agente_secreto' && nex >= 10) {
        if (!poderesEscolhidos.any(
          (p) => p.nome == "AgenteSecreto_SetupFeito",
        )) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mostrarDialogAgenteSecreto();
          });
        }
        if (poderesEscolhidos.any(
          (p) => p.nome == "AgenteSecreto_Bonus_diplomacia",
        )) {
          bonusOrigem['diplomacia'] = (bonusOrigem['diplomacia'] ?? 0) + 2;
        }
        if (poderesEscolhidos.any(
          (p) => p.nome == "AgenteSecreto_Bonus_enganacao",
        )) {
          bonusOrigem['enganacao'] = (bonusOrigem['enganacao'] ?? 0) + 2;
        }
        if (nex >= 40) {
          bonusOrigem['diplomacia'] = (bonusOrigem['diplomacia'] ?? 0) + 2;
          bonusOrigem['enganacao'] = (bonusOrigem['enganacao'] ?? 0) + 2;
        }
      }

      if (!isInitialLoad) {
        if (pvMax > oldPvMax && oldPvMax > 0) {
          pvAtual = min(pvMax, pvAtual + (pvMax - oldPvMax));
        }
        if (peMax > oldPeMax && oldPeMax > 0) {
          peAtual = min(peMax, peAtual + (peMax - oldPeMax));
        }
        if (sanMax > oldSanMax && oldSanMax > 0) {
          sanAtual = min(sanMax, sanAtual + (sanMax - oldSanMax));
        }
      } else if (widget.agenteParaEditar == null) {
        pvAtual = pvMax;
        peAtual = peMax;
        sanAtual = sanMax;
      }
    });

    if (!isInitialLoad) _salvarSilencioso();
  }

  void _mostrarDialogAgenteSecreto() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          "Agente Secreto: Carteirada",
          style: TextStyle(color: corDestaque),
        ),
        content: const Text(
          "Sua agência lhe forneceu documentos e treinamento especial. Qual será o seu foco de infiltração?",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => _concluirSetupAgenteSecreto('diplomacia'),
            child: Text(
              "DIPLOMACIA",
              style: TextStyle(color: corDestaque, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => _concluirSetupAgenteSecreto('enganacao'),
            child: Text(
              "ENGANAÇÃO",
              style: TextStyle(color: corDestaque, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogTrilhas() {
    if (classeAtual == '--') return;
    List<DadosTrilha> trilhasDaClasse = trilhasOrdem.values
        .where((t) => t.classe.toLowerCase() == classeAtual.toLowerCase())
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: corDestaque.withValues(alpha: 0.3)),
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
                    Icon(Icons.call_split, color: corDestaque, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      "TRILHAS",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: corDestaque,
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
                const Text(
                  "A trilha representa o caminho de especialização que seu agente seguiu dentro de sua classe.",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: trilhasDaClasse.length,
                    itemBuilder: (context, index) {
                      DadosTrilha t = trilhasDaClasse[index];
                      String idTrilha = trilhasOrdem.entries
                          .firstWhere((e) => e.value.nome == t.nome)
                          .key;
                      bool isSelected = trilhaAtual == idTrilha;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D0D0D),
                          border: Border.all(
                            color: isSelected
                                ? corDestaque
                                : Colors.grey.shade800,
                          ),
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
                              t.nome,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? corDestaque : Colors.white,
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
                                      color: corDestaque.withValues(alpha: 0.3),
                                      thickness: 1,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      t.descricao,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: corFundoAfinidade,
                                        foregroundColor: corTextoAfinidade,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        side: afinidadeAtual == 'Morte'
                                            ? const BorderSide(
                                                color: Colors.white54,
                                              )
                                            : null,
                                      ),
                                      onPressed: isSelected
                                          ? null
                                          : () {
                                              if (idTrilha == 'monstruoso') {
                                                _mostrarDialogElementoMonstruoso();
                                              } else {
                                                setState(() {
                                                  trilhaAtual = idTrilha;
                                                });
                                                atualizarFicha();
                                                Navigator.pop(context);
                                              }
                                            },
                                      child: Text(
                                        isSelected
                                            ? "TRILHA ATUAL"
                                            : "ESCOLHER ESTA TRILHA",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
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
              ],
            ),
          ),
        );
      },
    );
  }

  void _concluirSetupAgenteSecreto(String periciaEscolhida) {
    setState(() {
      var p = listaPericias.firstWhere((e) => e.id == periciaEscolhida);
      if (p.treino == 0) {
        p.treino = 5;
      } else {
        poderesEscolhidos.add(
          Poder(
            nome: "AgenteSecreto_Bonus_$periciaEscolhida",
            tipo: "Sistema",
            descricao: "",
          ),
        );
      }
      poderesEscolhidos.add(
        Poder(nome: "AgenteSecreto_SetupFeito", tipo: "Sistema", descricao: ""),
      );
      inventario.add(
        ItemInventario(
          nome: "Documentos Especiais",
          categoria: "0",
          espaco: 0,
          descricao:
              "Permissão para portar armas de fogo, acesso a locais restritos e jurisdição policial.",
        ),
      );
      atualizarFicha();
    });
    _salvarSilencioso();
    Navigator.pop(context);
    _mostrarNotificacao("Treinamento e Documentos recebidos!");
  }

  void _mostrarDialogElementoMonstruoso() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          "O Parasita",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Você foi infectado. Qual elemento habita o seu corpo agora? Esta escolha ditará seus poderes passivos permanentemente e travará sua afinidade.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _btnElementoMonstruoso("Sangue", const Color(0xFF990000)),
              _btnElementoMonstruoso("Energia", const Color(0xFF9900FF)),
              _btnElementoMonstruoso("Morte", Colors.black),
              _btnElementoMonstruoso("Conhecimento", const Color(0xFFFFB300)),
            ],
          ),
        ],
      ),
    );
  }

  void _verificarLevelUp(int oldNex, int newNex) {
    if (newNex <= oldNex) return;
    List<String> novidades = [];

    if (newNex >= 20 && oldNex < 20) novidades.add("• +1 Ponto de Atributo");
    if (newNex >= 50 && oldNex < 50) {
      novidades.add(
        "• +1 Ponto de Atributo\n• Afinidade Elemental (ou Versatilidade)",
      );
    }
    if (newNex >= 80 && oldNex < 80) novidades.add("• +1 Ponto de Atributo");
    if (newNex >= 95 && oldNex < 95) novidades.add("• +1 Ponto de Atributo");

    if (newNex >= 35 && oldNex < 35) {
      novidades.add("• Grau de Treinamento: Veterano (+10 nas perícias)");
    }
    if (newNex >= 70 && oldNex < 70) {
      novidades.add("• Grau de Treinamento: Expert (+15 nas perícias)");
    }

    List<int> nexPoderes = [15, 30, 45, 60, 75, 90];
    for (int n in nexPoderes) {
      if (newNex >= n && oldNex < n) {
        novidades.add("• Novo Poder de Classe (NEX $n%)");
      }
    }

    if (novidades.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: Text(
              "Level Up! (NEX $newNex%)",
              style: TextStyle(color: corDestaque),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Você desbloqueou as seguintes melhorias:",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                ...novidades.map(
                  (n) => Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text(
                      n,
                      style: TextStyle(
                        color: corDestaque,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Ok", style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        );
      });
    }
  }

  Widget _btnElementoMonstruoso(String elemento, Color cor) {
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
              ? const BorderSide(color: Colors.white54)
              : null,
        ),
        onPressed: () {
          setState(() {
            trilhaAtual = 'monstruoso';
            afinidadeAtual = elemento;
          });
          atualizarFicha();
          Navigator.pop(context);
          Navigator.pop(context);
        },
        child: Text(
          elemento.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // SISTEMA DE ABAS
  Widget _buildAbaAtributos(bool block, Color corDoPainel) {
    List<Arma> armasEquipadas = armas.where((a) => a.equipado).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
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

          if (nex >= 50 &&
              (afinidadeAtual == null || afinidadeAtual!.isEmpty) &&
              !block)
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
              GestureDetector(
                onTap: (block || nex < 10 || classeAtual == '--')
                    ? null
                    : () => _mostrarDialogTrilhas(),
                child: Container(
                  height: 58,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: (nex < 10 || classeAtual == '--')
                        ? Colors.grey.shade900.withValues(alpha: 0.5)
                        : const Color(0xFF0D0D0D),
                    border: Border.all(
                      color: (nex < 10 || classeAtual == '--')
                          ? Colors.grey.shade800
                          : Colors.grey.shade600,
                    ),
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
                            Text(
                              nex < 10
                                  ? "Trilha (Requer NEX 10%)"
                                  : "Trilha de Classe",
                              style: TextStyle(
                                color: (nex < 10 || classeAtual == '--')
                                    ? Colors.grey.shade700
                                    : Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              trilhaAtual == '--'
                                  ? '--'
                                  : (trilhasOrdem[trilhaAtual]?.nome ??
                                            trilhaAtual)
                                        .toUpperCase(),
                              style: TextStyle(
                                color: (nex < 10 || classeAtual == '--')
                                    ? Colors.grey.shade600
                                    : Colors.white,
                                fontSize: 14,
                                fontWeight: trilhaAtual != '--'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.call_split,
                        color: (nex < 10 || classeAtual == '--')
                            ? Colors.grey.shade800
                            : Colors.grey,
                      ),
                    ],
                  ),
                ),
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
                              int oldNex = nex;
                              nex = int.parse(val!);
                              _verificarLevelUp(oldNex, nex);
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
              // ======== CONTADOR DE ATRIBUTOS (Mostra no Modo Edição) ========
              if (!block)
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: totalAtributosAtuais > totalAtributosPermitidos
                          ? Colors.redAccent
                          : (totalAtributosAtuais < totalAtributosPermitidos
                                ? Colors.orange
                                : Colors.green),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Pontos Gastos: $totalAtributosAtuais / $totalAtributosPermitidos",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              // ======== GRID RESPONSIVO DE ATRIBUTOS ========
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12, // Espaço horizontal entre os quadrados
                runSpacing:
                    16, // Espaço vertical se a tela for pequena e quebrar linha
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
                      int oldInt = inte;
                      inte = int.tryParse(val) ?? 0;
                      if (inte > oldInt) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _mostrarNotificacao(
                            "Intelecto aumentado! Você ganhou +1 Perícia Livre.",
                          );
                        });
                      }
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
                cor: (pvMax > 0 && pvAtual <= pvMax ~/ 2)
                    ? Colors.red.shade900
                    : Colors.red,
                onChanged: (val) {
                  setState(() => pvAtual = val.clamp(0, pvMax));
                  atualizarFicha();
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

          SecaoFicha(
            titulo: "Resistências",
            corTema: corFundoAfinidade,
            corTexto: corTextoAfinidade,
            isMorte: afinidadeAtual == 'Morte',
            filhos: [
              if (resistencias.isEmpty)
                const Text(
                  "Nenhuma resistência.",
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
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
                        "${e.key}: ${e.value >= 900 ? 'Imune' : e.value}",
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

                  int modMargemTrilha = 0;
                  if (trilhaAtual == 'guerreiro' &&
                      nex >= 10 &&
                      arma.tipo == 'Corpo a Corpo') {
                    modMargemTrilha += 2;
                  }
                  if (trilhaAtual == 'aniquilador' &&
                      nex >= 99 &&
                      arma.modificacoes.contains("Arma Favorita")) {
                    modMargemTrilha += 2;
                  }
                  int margemExibida =
                      arma.margemAmeacaEfetiva - modMargemTrilha;
                  if (margemExibida < 2) margemExibida = 2;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
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
                            "Dano: ${arma.danoEfetivo}$modDano | Crítico: $margemExibida/x${arma.multiplicadorCritico} \nTipo: ${arma.tipo}$alertaProf",
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
                          ? () => _rolarAtaque(arma, bonusDano, isProficiente)
                          : null,
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF151515),
              foregroundColor: corDestaque,
              side: BorderSide(color: corDestaque.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.help_outline),
            label: const Text(
              "GUIA RÁPIDO DE AÇÕES",
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            onPressed: () => _mostrarDialogAcoesCombate(),
          ),
        ],
      ),
    );
  }

  Widget _buildAbaHabilidades(bool block, Color corDoPainel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Trilha
          if (trilhaAtual != '--')
            SecaoFicha(
              titulo:
                  "Trilha: ${trilhasOrdem[trilhaAtual]?.nome ?? trilhaAtual.toUpperCase()}",
              corTema: corFundoAfinidade,
              corTexto: corTextoAfinidade,
              isMorte: afinidadeAtual == 'Morte',
              filhos: [
                Text(
                  trilhasOrdem[trilhaAtual]?.descricao ??
                      "Descrição da trilha indisponível.",
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.grey),
                const SizedBox(height: 8),

                if (trilhasOrdem.containsKey(trilhaAtual))
                  ...trilhasOrdem[trilhaAtual]!.habilidades.entries
                      .where((e) => nex >= e.key)
                      .map((e) {
                        String nomeHab = e.value.keys.first;
                        String descHab = e.value.values.first;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "NEX ${e.key}% - $nomeHab",
                                style: TextStyle(
                                  color: corDestaque,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                descHab,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
              ],
            ),

          // Origem
          if (origemAtual != '--')
            SecaoFicha(
              titulo:
                  "Habilidade de Origem: ${dadosOrigens[origemAtual]?.nomeHabilidade ?? origemAtual.replaceAll('_', ' ').toUpperCase()}",
              corTema: corFundoAfinidade,
              corTexto: corTextoAfinidade,
              isMorte: afinidadeAtual == 'Morte',
              filhos: [
                Text(
                  (dadosOrigens[origemAtual]?.descHabilidade != null &&
                          dadosOrigens[origemAtual]!.descHabilidade.isNotEmpty)
                      ? dadosOrigens[origemAtual]!.descHabilidade
                      : "Descrição da origem indisponível.",
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),

                if (origemAtual == 'colegial') ...[
                  const SizedBox(height: 16),
                  const Divider(color: Colors.grey),
                  SwitchListTile(
                    title: const Text(
                      "Amigo está Próximo (+2 em Perícias)",
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    value: poderesEscolhidos.any(
                      (p) => p.nome == "Colegial_Perto",
                    ),
                    activeThumbColor: corDestaque,
                    contentPadding: EdgeInsets.zero,
                    onChanged:
                        block ||
                            poderesEscolhidos.any(
                              (p) => p.nome == "Colegial_Morto",
                            )
                        ? null
                        : (val) {
                            setState(() {
                              if (val) {
                                poderesEscolhidos.add(
                                  Poder(
                                    nome: "Colegial_Perto",
                                    tipo: "Origem",
                                    descricao: "",
                                  ),
                                );
                              } else {
                                poderesEscolhidos.removeWhere(
                                  (p) => p.nome == "Colegial_Perto",
                                );
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
                    value: poderesEscolhidos.any(
                      (p) => p.nome == "Colegial_Morto",
                    ),
                    activeThumbColor: Colors.redAccent,
                    contentPadding: EdgeInsets.zero,
                    onChanged: block
                        ? null
                        : (val) {
                            setState(() {
                              if (val) {
                                poderesEscolhidos.add(
                                  Poder(
                                    nome: "Colegial_Morto",
                                    tipo: "Origem",
                                    descricao: "",
                                  ),
                                );
                                poderesEscolhidos.removeWhere(
                                  (p) => p.nome == "Colegial_Perto",
                                );
                              } else {
                                poderesEscolhidos.removeWhere(
                                  (p) => p.nome == "Colegial_Morto",
                                );
                              }
                              atualizarFicha();
                            });
                            _salvarSilencioso();
                          },
                  ),
                ],
                if (origemAtual == 'revoltado') ...[
                  const SizedBox(height: 16),
                  const Divider(color: Colors.grey),
                  SwitchListTile(
                    title: const Text(
                      "Sem Aliados Próximos (+1 Def, +1 Perícias, +1 PE)",
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    value: poderesEscolhidos.any(
                      (p) => p.nome == "Revoltado_Sozinho",
                    ),
                    activeThumbColor: corDestaque,
                    contentPadding: EdgeInsets.zero,
                    onChanged: block
                        ? null
                        : (val) {
                            setState(() {
                              if (val) {
                                poderesEscolhidos.add(
                                  Poder(
                                    nome: "Revoltado_Sozinho",
                                    tipo: "Origem",
                                    descricao: "",
                                  ),
                                );
                              } else {
                                poderesEscolhidos.removeWhere(
                                  (p) => p.nome == "Revoltado_Sozinho",
                                );
                              }
                              atualizarFicha();
                            });
                            _salvarSilencioso();
                          },
                  ),
                ],
              ],
            ),

          // Afinidade
          if (afinidadeAtual != null && afinidadeAtual!.isNotEmpty && nex >= 50)
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

          // Poderes
          SecaoFicha(
            titulo: "Poderes",
            corTema: corFundoAfinidade,
            corTexto: corTextoAfinidade,
            isMorte: afinidadeAtual == 'Morte',
            filhos: [
              if (!block)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => mostrarDialogCriarPoder(
                        context: context,
                        corDestaque: corDestaque,
                        corTema: corFundoAfinidade,
                        corTexto: corTextoAfinidade,
                        onConfirmar: (novoPoder) {
                          setState(() => poderesEscolhidos.add(novoPoder));
                          _salvarSilencioso();
                        },
                      ),
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text("Custom"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF151515),
                        foregroundColor: corDestaque,
                        side: BorderSide(
                          color: corDestaque.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _abrirCatalogoPoderes,
                      icon: const Icon(Icons.search, size: 18),
                      label: const Text("Poder"),
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
              if (poderesEscolhidos
                  .where(
                    (p) =>
                        !p.nome.startsWith("Experimento_") &&
                        !p.nome.startsWith("Profetizado_") &&
                        !p.nome.startsWith("Colegial_") &&
                        !p.nome.startsWith("Revoltado_") &&
                        !p.nome.startsWith("Engenheiro_") &&
                        !p.nome.startsWith("Cacador_") &&
                        !p.nome.startsWith("AgenteSecreto_") &&
                        p.tipo != "Sistema",
                  )
                  .isEmpty)
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
                  Poder p = poderesEscolhidos[index];

                  // Oculta as tags de sistema
                  if (p.nome.startsWith("Experimento_") ||
                      p.nome.startsWith("Profetizado_") ||
                      p.nome.startsWith("Colegial_") ||
                      p.nome.startsWith("Revoltado_") ||
                      p.nome.startsWith("Engenheiro_") ||
                      p.nome.startsWith("Cacador_") ||
                      p.nome.startsWith("AgenteSecreto_") ||
                      p.tipo == "Sistema") {
                    return const SizedBox.shrink();
                  }

                  bool temCusto = p.custoPE > 0;
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
                      border: Border.all(
                        color: temCusto
                            ? Colors.blue.withValues(alpha: 0.5)
                            : Colors.grey.shade800,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      onTap: temCusto && block ? () => _usarPoder(p) : null,
                      title: Row(
                        children: [
                          if (isParanormal)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: p.tipo == 'Sangue'
                                      ? const Color(0xFF990000)
                                      : p.tipo == 'Energia'
                                      ? const Color(0xFF9900FF)
                                      : p.tipo == 'Conhecimento'
                                      ? const Color(0xFFFFB300)
                                      : Colors.white54,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                p.tipo.toUpperCase(),
                                style: TextStyle(
                                  color: p.tipo == 'Sangue'
                                      ? const Color(0xFF990000)
                                      : p.tipo == 'Energia'
                                      ? const Color(0xFF9900FF)
                                      : p.tipo == 'Conhecimento'
                                      ? const Color(0xFFFFB300)
                                      : Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              p.nome,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (temCusto)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "${p.custoPE} PE",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
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
                            p.nome == "Ataque Especial" ||
                            p.nome == "Eclético" ||
                            p.nome.startsWith("Perito") ||
                            p.nome == "Escolhido pelo Outro Lado";
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
}
