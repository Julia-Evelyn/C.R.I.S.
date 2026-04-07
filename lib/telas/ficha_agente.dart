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
  List<Ritual> rituaisGrimorio = [];
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

  bool armaDeSangueAtiva = false;
  bool encararAMorteAtivo = false;

  String _idade = "", _genero = "", _nacionalidade = "", _aparencia = "";
  String _historico = "", _objetivo = "", _extra = "";

  int pvMax = 0, peMax = 0, sanMax = 0, pvAtual = 0, peAtual = 0, sanAtual = 0;
  int defesa = 10, esquiva = 10, bloqueio = 0;
  String habNome = "", habDesc = "";

  int ppAtual = 0, ppMax = 0;

  // VARIAVEIS ROLADOR DE DADOS
  final List<int> _tiposDados = [4, 6, 8, 10, 12, 20, 100];
  final Map<int, int> _qtdDados = {
    4: 1,
    6: 1,
    8: 1,
    10: 1,
    12: 1,
    20: 1,
    100: 1,
  };

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

  Color _obterCorAfinidade(String? elemento) {
    if (elemento == null) return Colors.white;
    switch (elemento.toLowerCase()) {
      case 'sangue':
        return const Color(0xFF990000);
      case 'energia':
        return const Color(0xFF9900FF);
      case 'morte':
        return Colors.white54;
      case 'conhecimento':
        return const Color(0xFFFFB300);
      case 'medo':
        return Colors.white;
      default:
        return const Color.fromARGB(255, 77, 133, 255);
    }
  }

  int get limitePePorTurno {
    int baseLimite = (nex / 5).ceil();
    if (origemAtual == 'universitario') baseLimite += 1;
    if (origemAtual == 'revoltado' &&
        poderesEscolhidos.any((p) => p.nome == "Revoltado_Sozinho")) {
      baseLimite += 1;
    }

    // PODER: ENCARAR A MORTE
    if (encararAMorteAtivo) {
      baseLimite +=
          poderesEscolhidos.any(
            (p) =>
                p.nome.contains("Encarar a Morte") &&
                p.nome.contains("(Afinidade)"),
          )
          ? 3
          : 1;
    }
    return baseLimite;
  }

  int get deslocamento {
    int baseDesl = 9;
    if (origemAtual == 'ginasta') baseDesl += 3;
    if (poderesEscolhidos.any((p) => p.nome == "Atlético")) baseDesl += 3;
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
    if (trilhaAtual == 'muambeiro' && nex >= 10) base += 5;

    // INVENTÁRIO ORGANIZADO
    if (poderesEscolhidos.any((p) => p.nome == "Inventário Organizado")) {
      base += inte;
    }

    int bonusItens = 0;
    for (var item in inventario) {
      bonusItens += item.bonusCarga;
    }

    return base + bonusItens;
  }

  double get espacoOcupado {
    // INVENTÁRIO ORGANIZADO
    bool invOrganizado = poderesEscolhidos.any(
      (p) => p.nome == "Inventário Organizado",
    );

    double espItens = inventario.fold(0.0, (soma, item) {
      double e = item.espacoEfetivo;
      if (invOrganizado && e == 0.5) e = 0.25;
      return soma + e;
    });
    double espArmas = armas.fold(0.0, (soma, arma) {
      double e = arma.espacoEfetivo;
      if (invOrganizado && e == 0.5) e = 0.25;
      return soma + e;
    });
    return espItens + espArmas;
  }

  bool get estaSobrecarregado => espacoOcupado > espacoMaximo;

  int get maosOcupadas {
    int m = 0;
    for (var a in armas.where((a) => a.equipado)) {
      if (a.nome == "Arma de Sangue") {
        continue; // Arma de Sangue não ocupa mãos
      }
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

  // Lógica de Categorias
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
    if (eq is Arma &&
        trilhaAtual == 'aniquilador' &&
        eq.modificacoes.contains("Arma Favorita")) {
      reducao = nex >= 99 ? 3 : (nex >= 40 ? 2 : 1);
    }

    // TRILHA: TÉCNICO (NEX 40) - Remendão
    if (trilhaAtual == 'tecnico' &&
        nex >= 40 &&
        eq is ItemInventario &&
        eq is! Arma) {
      String desc = eq.descricao.toLowerCase();
      // Detecta se é "Equipamento Geral" lendo a descrição ou nome do item
      if (desc.contains("acessório") ||
          desc.contains("explosivo") ||
          desc.contains("item operacional") ||
          desc.contains("medicamento") ||
          desc.contains("item paranormal") ||
          eq.nome.toLowerCase().contains("vestimenta")) {
        reducao += 1;
      }
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
      ppAtual = ag.ppAtual ?? 0;
      inventario = List.from(ag.inventario);
      armas = List.from(ag.armas);
      poderesEscolhidos = List.from(ag.poderes);
      rituaisConhecidos = List.from(ag.rituais);
      rituaisGrimorio = List.from(ag.rituaisGrimorio);
      periciasClasse = List.from(ag.periciasClasse);
      _idade = ag.idade;
      _genero = ag.genero;
      _nacionalidade = ag.nacionalidade;
      _aparencia = ag.aparencia;
      _historico = ag.historico;
      _objetivo = ag.objetivo;
      _extra = ag.extra;

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
      ppAtual: ppAtual,
      pericias: periciasTreinadas,
      inventario: inventario,
      armas: armas,
      poderes: poderesEscolhidos,
      rituais: rituaisConhecidos,
      rituaisGrimorio: rituaisGrimorio,
      periciasClasse: periciasClasse,
      idade: _idade,
      genero: _genero,
      nacionalidade: _nacionalidade,
      aparencia: _aparencia,
      historico: _historico,
      objetivo: _objetivo,
      extra: _extra,
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

    // LÓGICA ESPECIAL PARA A ARMA DE SANGUE
    if (poder.nome.contains("Arma de Sangue") && !armaDeSangueAtiva) {
      if (peAtual >= poder.custoPE) {
        setState(() {
          peAtual -= poder.custoPE;
          armaDeSangueAtiva = true;

          bool temAfinidade = poderesEscolhidos.any(
            (p) =>
                p.nome.contains("Arma de Sangue") &&
                p.nome.contains("(Afinidade)"),
          );

          // Cria e equipa automaticamente a arma de sangue
          armas.add(
            Arma(
              nome: "Arma de Sangue",
              tipo: "Corpo a Corpo",
              dano: temAfinidade ? "1d10" : "1d6",
              margemAmeaca: 20,
              multiplicadorCritico: 2,
              categoria: "0",
              espaco: 0,
              proficiencia: "Simples",
              empunhadura: "Leve",
              descricao: temAfinidade
                  ? "Parte permanente de você. 1/turno: 1 PE para ataque extra."
                  : "Dura até o fim da cena. 1/turno: 1 PE para ataque extra.",
              equipado: true,
            ),
          );
          atualizarFicha();
        });
        _salvarSilencioso();
        _mostrarNotificacao("Arma de Sangue ativada: -${poder.custoPE} PE");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("PE insuficientes!"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    } else if (poder.nome.contains("Arma de Sangue") && armaDeSangueAtiva) {
      _mostrarNotificacao("Sua Arma de Sangue já está ativa.");
      return;
    }

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
    int flatTotal = bonusDanoFixo;

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

    // ======== GOLPE DE SORTE ========
    if (poderesEscolhidos.any((p) => p.nome.contains("Golpe de Sorte"))) {
      modMargemTrilha += 1;
      if (poderesEscolhidos.any(
        (p) =>
            p.nome.contains("Golpe de Sorte") && p.nome.contains("(Afinidade)"),
      )) {
        modMultExtra += 1;
      }
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
      // Usa o bônus customizado numérico da vestimenta se houver (ex: +3, +10).
      // Se for item antigo (0), cai na regra do Aprimorado (+5) ou Normal (+2).
      int b = v.bonusPericia > 0
          ? v.bonusPericia
          : (v.modificacoes.contains("Aprimorado") ||
                    v.modificacoes.contains("Aprimorada")
                ? 5
                : 2);

      if (b > bonusExtraItem) bonusExtraItem = b;
    }
    int totalBonus =
        bonusPericia +
        (bonusOrigem[periciaUsada] ?? 0) +
        bonusExtraItem +
        modAtaque;

    // ================== ATIRADOR DE ELITE (MIRA DE ELITE) ==================
    if (trilhaAtual == 'atirador_de_elite' &&
        nex >= 10 &&
        arma.tipo == 'Fogo') {
      String descL = arma.descricao.toLowerCase();
      String nomeL = arma.nome.toLowerCase();
      if (descL.contains("balas longas") ||
          nomeL.contains("fuzil") ||
          nomeL.contains("sniper") ||
          nomeL.contains("rifle")) {
        isProficiente = true; // Força a proficiência
        flatTotal += efInt; // Soma Intelecto ao dano base!
      }
    }

    // DEFINIDO APENAS UMA VEZ
    int dadosExtras = isProficiente ? 0 : -2;

    // COMBATER COM DUAS ARMAS (-1d20)
    int countArmasEquipadas = armas
        .where(
          (a) =>
              a.equipado &&
              a.nome != "Ataque Desarmado" &&
              a.nome != "Arma de Sangue",
        )
        .length;
    bool hasLeve = armas.any(
      (a) =>
          a.equipado &&
          a.empunhadura == 'Leve' &&
          a.nome != "Ataque Desarmado" &&
          a.nome != "Arma de Sangue",
    );
    if (poderesEscolhidos.any((p) => p.nome == "Combater com Duas Armas") &&
        countArmasEquipadas >= 2 &&
        hasLeve) {
      dadosExtras -= 1;
    }

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

          // TRILHA: ATIRADOR DE ELITE (Atirar para Matar)
          bool atMaxCrit =
              (trilhaAtual == 'atirador_de_elite' &&
              nex >= 99 &&
              arma.tipo == 'Fogo' &&
              isCrit &&
              !isFalhaCritica);

          for (int i = 0; i < qtd; i++) {
            // Dano máximo sem rolar, se tiver a habilidade do Sniper
            int r = atMaxCrit ? faces : (Random().nextInt(faces) + 1);
            rolagensDano.add(r);
            totalDano += r;
          }
        }
      } else {
        flatTotal += int.tryParse(parte) ?? 0;
      }
    }

    // TIRO CERTEIRO (+AGI no Dano)
    if (arma.tipo == 'Disparo' &&
        poderesEscolhidos.any((p) => p.nome == "Tiro Certeiro")) {
      flatTotal += efAgi;
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
                aniquilador99 ||
                (trilhaAtual == 'atirador_de_elite' && nex >= 10))
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Bônus de Trilhas e Efeitos Ativos aplicados.",
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

  void _rolarDadoAvulso(int faces, int quantidade) {
    if (quantidade <= 0 || !_modoVisualizacao) return;

    List<int> resultados = List.generate(
      quantidade,
      (_) => Random().nextInt(faces) + 1,
    );
    int soma = resultados.fold(0, (a, b) => a + b);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          "Rolagem de ${quantidade}d$faces",
          textAlign: TextAlign.center,
          style: TextStyle(color: corDestaque, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Resultados: [${resultados.join(', ')}]",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              soma.toString(),
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
            child: Text("OK", style: TextStyle(color: corDestaque)),
          ),
        ],
      ),
    );
  }

  Widget _buildSessaoDados(Color corTema) {
    // Lista de proteção para impedir que o jogador delete os dados oficias do RPG
    List<int> dadosPadrao = [4, 6, 8, 10, 12, 20, 100];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        border: Border.all(color: corTema.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: corTema,
          collapsedIconColor: corTema,
          leading: Icon(Icons.casino_outlined, color: corTema, size: 28),
          title: const Text(
            "MESA DE DADOS",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            "Role dados avulsos ou customizados",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 12),

                  // LISTA DOS DADOS
                  ..._tiposDados.map((faces) {
                    int qtd = _qtdDados[faces] ?? 1;
                    bool isCustom = !dadosPadrao.contains(faces);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Container(
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D0D0D),
                              border: Border.all(color: Colors.grey.shade800),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(5),
                                  ),
                                  onTap: () {
                                    if (qtd > 1) {
                                      setState(
                                        () => _qtdDados[faces] = qtd - 1,
                                      );
                                    }
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      size: 18,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 65,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A1A1A),
                                    border: Border.symmetric(
                                      vertical: BorderSide(
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ),
                                  child: FittedBox(
                                    // Impede que o texto quebre a linha, reduzindo a fonte se necessário
                                    fit: BoxFit.scaleDown,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0,
                                      ),
                                      child: Text(
                                        "${qtd}d$faces",
                                        style: TextStyle(
                                          color: corTema,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(5),
                                  ),
                                  onTap: () {
                                    setState(() => _qtdDados[faces] = qtd + 1);
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      size: 18,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),

                          // LIXEIRA APENAS PARA DADOS CUSTOMIZADOS
                          if (isCustom)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                  size: 22,
                                ),
                                tooltip: "Remover Dado",
                                onPressed: () {
                                  setState(() {
                                    _tiposDados.remove(faces);
                                    _qtdDados.remove(faces);
                                  });
                                },
                              ),
                            ),

                          // BOTÃO DE ROLAR
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: corTema,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 0,
                              ),
                              minimumSize: const Size(0, 38),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: _modoVisualizacao
                                ? () => _rolarDadoAvulso(faces, qtd)
                                : null,
                            icon: const Icon(Icons.casino, size: 18),
                            label: const Text(
                              "ROLAR",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 8),

                  // BOTÃO PARA CRIAR UM DADO NOVO (ex: d3, d7)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade800, width: 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      TextEditingController facesCtrl = TextEditingController();
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF1A1A1A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: corTema.withValues(alpha: 0.3),
                            ),
                          ),
                          title: Row(
                            children: [
                              Icon(Icons.add_box, color: corTema),
                              const SizedBox(width: 8),
                              const Text(
                                "Dado Customizado",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          content: TextField(
                            controller: facesCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            decoration:
                                EstiloParanormal.customInputDeco(
                                  "Qtd de Lados (Ex: 3)",
                                  corTema,
                                  Icons.casino,
                                ).copyWith(
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text(
                                "Cancelar",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: corTema,
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () {
                                int? f = int.tryParse(facesCtrl.text);
                                if (f != null && f > 0) {
                                  setState(() {
                                    if (!_tiposDados.contains(f)) {
                                      _tiposDados.add(f);
                                      _tiposDados
                                          .sort(); // Mantém os dados sempre em ordem crescente
                                    }
                                    _qtdDados[f] = 1;
                                  });
                                }
                                Navigator.pop(ctx);
                              },
                              child: const Text(
                                "ADICIONAR",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      "CRIAR NOVO DADO",
                      style: TextStyle(letterSpacing: 1.2, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

                                      for (var p in listaPericias) {
                                        // Se não for perícia da Origem ele zera
                                        if (!p.daOrigem) {
                                          p.treino = 0;
                                        }
                                      }

                                      if (novaClasse == 'combatente') {
                                        poderesEscolhidos.add(
                                          Poder(
                                            nome: "Ataque Especial",
                                            tipo: "Combatente",
                                            descricao:
                                                "Quando faz um ataque, você pode gastar 2 PE para receber +5 no teste de ataque ou na rolagem de dano. NEX 25% (3 PE, +10), NEX 55% (4 PE, +15) e NEX 85% (5 PE, +20)",
                                            custoPE: 2,
                                          ),
                                        );
                                      } else if (novaClasse == 'especialista') {
                                        poderesEscolhidos.add(
                                          Poder(
                                            nome: "Eclético",
                                            tipo: "Especialista",
                                            descricao:
                                                "Quando faz um teste de uma perícia, você pode gastar 2 PE para receber os benefícios de ser treinado nesta perícia.",
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
                                                "Quando faz um teste de uma dessas perícias, você pode gastar 2 PE para somar +1d6 no resultado do teste. Em NEX 25%, pode gastar 3 PE para receber +1d8, NEX 55% gasta 4 PE para receber +1d10 e em NEX 85% gasta Perito 5 PE para +1d12)",
                                            custoPE: 2,
                                          ),
                                        );
                                      } else if (novaClasse == 'ocultista') {
                                        poderesEscolhidos.add(
                                          Poder(
                                            nome: "Escolhido pelo Outro Lado",
                                            tipo: "Ocultista",
                                            descricao:
                                                "Você pode lançar rituais de 1º círculo. À medida que aumenta seu NEX, pode lançar rituais de círculos maiores (2º círculo em NEX 25%, 3º círculo em NEX 55% e 4º círculo em NEX 85%). Você começa com três rituais de 1º círculo. Sempre que avança de NEX, aprende um ritual de qualquer círculo que possa lançar.",
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

  void _abrirCatalogoPoderes({String? filtroInicial}) {
    String busca = "";

    // Se a trilha for Possuído, forçamos o filtro para Poderes Paranormais
    String filtroPrincipal = (trilhaAtual == 'possuido')
        ? "Poderes Paranormais"
        : (filtroInicial ?? "Gerais");

    String filtroParanormal = "Conhecimento"; // Elemento padrão ao abrir

    // Se ele já tiver afinidade e a aba paranormal abrir direto, ele já cai na aba da afinidade dele!
    if (filtroPrincipal == "Poderes Paranormais" &&
        afinidadeAtual != null &&
        afinidadeAtual != "Variável") {
      filtroParanormal = afinidadeAtual!;
    }

    Color corTemaLocal = corFundoAfinidade;
    Color corLetra = corTextoAfinidade;
    Color corDestaqueLocal = corDestaque;

    // Se for Possuído, só mostra a opção de Poderes Paranormais nas abas principais
    List<String> categoriasPrincipais = trilhaAtual == 'possuido'
        ? ["Poderes Paranormais"]
        : [
            "Gerais",
            if (classeAtual == 'combatente') "Combatente",
            if (classeAtual == 'especialista') "Especialista",
            if (classeAtual == 'ocultista') "Ocultista",
            "Poderes Paranormais",
          ];

    // Se por acaso a classe for nula ou o filtroInicial bugar (e não for possuído), voltamos para Gerais
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
                      style: const TextStyle(color: Colors.white),
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
                                        // ==========================================
                                        // REGRA: FOCO EM PERÍCIA
                                        // ==========================================
                                        if (p.nome == "Foco em Perícia") {
                                          showDialog(
                                            context: context,
                                            builder: (ctxFoco) {
                                              // Filtra: Tem que ter treino (>0), não pode ser Luta/Pontaria e não pode já estar focada
                                              List<Pericia>
                                              periciasTreinadas = listaPericias
                                                  .where(
                                                    (per) =>
                                                        per.treino > 0 &&
                                                        per.id != 'luta' &&
                                                        per.id != 'pontaria' &&
                                                        !poderesEscolhidos.any(
                                                          (pe) =>
                                                              pe.nome ==
                                                              "Foco em Perícia (${per.nome})",
                                                        ),
                                                  )
                                                  .toList();

                                              return AlertDialog(
                                                backgroundColor: const Color(
                                                  0xFF1A1A1A,
                                                ),
                                                title: Text(
                                                  "Foco em Perícia",
                                                  style: TextStyle(
                                                    color: corDestaqueLocal,
                                                  ),
                                                ),
                                                content: SizedBox(
                                                  width: double.maxFinite,
                                                  height: 300,
                                                  child:
                                                      periciasTreinadas.isEmpty
                                                      ? const Center(
                                                          child: Text(
                                                            "Você não possui perícias treinadas válidas ou já focou em todas.",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        )
                                                      : ListView.builder(
                                                          shrinkWrap: true,
                                                          itemCount:
                                                              periciasTreinadas
                                                                  .length,
                                                          itemBuilder: (context, idx) {
                                                            return ListTile(
                                                              title: Text(
                                                                periciasTreinadas[idx]
                                                                    .nome,
                                                                style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              trailing:
                                                                  const Icon(
                                                                    Icons.star,
                                                                    color: Colors
                                                                        .amber,
                                                                    size: 16,
                                                                  ),
                                                              onTap: () {
                                                                setState(() {
                                                                  poderesEscolhidos.add(
                                                                    Poder(
                                                                      nome:
                                                                          "Foco em Perícia (${periciasTreinadas[idx].nome})",
                                                                      tipo: p
                                                                          .tipo,
                                                                      descricao:
                                                                          p.descricao,
                                                                      preRequisitos:
                                                                          p.preRequisitos,
                                                                    ),
                                                                  );
                                                                  atualizarFicha();
                                                                });
                                                                Navigator.pop(
                                                                  ctxFoco,
                                                                );
                                                                Navigator.pop(
                                                                  context,
                                                                ); // Fecha o catálogo
                                                              },
                                                            );
                                                          },
                                                        ),
                                                ),
                                              );
                                            },
                                          );
                                          return; // Para a execução do clique normal
                                        }
                                        // Usamos startsWith para abranger variantes personalizadas (Expansão, Fervente)
                                        bool isPoderAtual =
                                            isParanormal &&
                                            poderesEscolhidos.any(
                                              (pe) =>
                                                  pe.nome.startsWith(p.nome),
                                            );

                                        // VERIFICAR PRÉ REQUISITOS DE AFINIDADE
                                        if (isPoderAtual &&
                                            afinidadeAtual != p.tipo) {
                                          showDialog(
                                            context: context,
                                            builder: (ctxErro) => AlertDialog(
                                              backgroundColor: const Color(
                                                0xFF1A1A1A,
                                              ),
                                              title: const Row(
                                                children: [
                                                  Icon(
                                                    Icons.warning_amber_rounded,
                                                    color: Colors.redAccent,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    "Afinidade Incompatível",
                                                    style: TextStyle(
                                                      color: Colors.redAccent,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              content: const Text(
                                                "Você precisa ter Afinidade com este elemento para aprimorar este poder!",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctxErro),
                                                  child: const Text(
                                                    "OK",
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                          return;
                                        }

                                        // VERIFICAR PRÉ REQUISITOS DE PODERES
                                        if (p.preRequisitos != "Nenhum" &&
                                            p.preRequisitos.isNotEmpty) {
                                          Map<String, int> contagem = {
                                            "Sangue": poderesEscolhidos
                                                .where(
                                                  (pe) => pe.tipo == "Sangue",
                                                )
                                                .length,
                                            "Morte": poderesEscolhidos
                                                .where(
                                                  (pe) => pe.tipo == "Morte",
                                                )
                                                .length,
                                            "Energia": poderesEscolhidos
                                                .where(
                                                  (pe) => pe.tipo == "Energia",
                                                )
                                                .length,
                                            "Conhecimento": poderesEscolhidos
                                                .where(
                                                  (pe) =>
                                                      pe.tipo == "Conhecimento",
                                                )
                                                .length,
                                          };
                                          bool cumpre = true;
                                          for (String req
                                              in p.preRequisitos.split(',')) {
                                            req = req.trim();
                                            for (String elem in [
                                              "Sangue",
                                              "Morte",
                                              "Energia",
                                              "Conhecimento",
                                            ]) {
                                              if (req.startsWith(elem)) {
                                                int needed =
                                                    int.tryParse(
                                                      req
                                                          .replaceAll(elem, '')
                                                          .trim(),
                                                    ) ??
                                                    0;
                                                if (contagem[elem]! < needed) {
                                                  cumpre = false;
                                                }
                                              }
                                            }
                                          }
                                          if (!cumpre) {
                                            showDialog(
                                              context: context,
                                              builder: (ctxErro) => AlertDialog(
                                                backgroundColor: const Color(
                                                  0xFF1A1A1A,
                                                ),
                                                title: const Row(
                                                  children: [
                                                    Icon(
                                                      Icons.block,
                                                      color: Colors.redAccent,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      "Requisito Ausente",
                                                      style: TextStyle(
                                                        color: Colors.redAccent,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                content: Text(
                                                  "Pré-requisitos não atendidos: ${p.preRequisitos}",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(ctxErro),
                                                    child: const Text(
                                                      "OK",
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                            return;
                                          }
                                        }

                                        // REGRA: SANGUE FERVENTE
                                        if (p.nome == "Sangue Fervente") {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              backgroundColor: const Color(
                                                0xFF1A1A1A,
                                              ),
                                              title: Text(
                                                isPoderAtual
                                                    ? "Sangue Fervente (Afinidade)"
                                                    : "Sangue Fervente",
                                                style: TextStyle(
                                                  color: corDestaqueLocal,
                                                ),
                                              ),
                                              content: const Text(
                                                "Escolha o atributo para receber o bônus enquanto estiver machucado:",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      if (isPoderAtual) {
                                                        poderesEscolhidos
                                                            .removeWhere(
                                                              (pe) => pe.nome
                                                                  .startsWith(
                                                                    "Sangue Fervente",
                                                                  ),
                                                            );
                                                        poderesEscolhidos.add(
                                                          Poder(
                                                            nome:
                                                                "Sangue Fervente (AGI) (Afinidade)",
                                                            tipo: p.tipo,
                                                            descricao:
                                                                p.descricao,
                                                            preRequisitos:
                                                                p.preRequisitos,
                                                            custoPE: p.custoPE,
                                                          ),
                                                        );
                                                      } else {
                                                        poderesEscolhidos.add(
                                                          Poder(
                                                            nome:
                                                                "Sangue Fervente (AGI)",
                                                            tipo: p.tipo,
                                                            descricao:
                                                                p.descricao,
                                                            preRequisitos:
                                                                p.preRequisitos,
                                                            custoPE: p.custoPE,
                                                          ),
                                                        );
                                                      }
                                                      atualizarFicha();
                                                    });
                                                    Navigator.pop(ctx);
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    "AGILIDADE",
                                                    style: TextStyle(
                                                      color: corDestaqueLocal,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      if (isPoderAtual) {
                                                        poderesEscolhidos
                                                            .removeWhere(
                                                              (pe) => pe.nome
                                                                  .startsWith(
                                                                    "Sangue Fervente",
                                                                  ),
                                                            );
                                                        poderesEscolhidos.add(
                                                          Poder(
                                                            nome:
                                                                "Sangue Fervente (FOR) (Afinidade)",
                                                            tipo: p.tipo,
                                                            descricao:
                                                                p.descricao,
                                                            preRequisitos:
                                                                p.preRequisitos,
                                                            custoPE: p.custoPE,
                                                          ),
                                                        );
                                                      } else {
                                                        poderesEscolhidos.add(
                                                          Poder(
                                                            nome:
                                                                "Sangue Fervente (FOR)",
                                                            tipo: p.tipo,
                                                            descricao:
                                                                p.descricao,
                                                            preRequisitos:
                                                                p.preRequisitos,
                                                            custoPE: p.custoPE,
                                                          ),
                                                        );
                                                      }
                                                      atualizarFicha();
                                                    });
                                                    Navigator.pop(ctx);
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    "FORÇA",
                                                    style: TextStyle(
                                                      color: corDestaqueLocal,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                          return;
                                        }

                                        // REGRA: RESISTIR A ELEMENTO
                                        if (p.nome == "Resistir a Elemento") {
                                          if (isPoderAtual) {
                                            setState(() {
                                              String existingName =
                                                  poderesEscolhidos
                                                      .firstWhere(
                                                        (
                                                          pe,
                                                        ) => pe.nome.startsWith(
                                                          "Resistir a Elemento",
                                                        ),
                                                      )
                                                      .nome;
                                              poderesEscolhidos.removeWhere(
                                                (pe) => pe.nome.startsWith(
                                                  "Resistir a Elemento",
                                                ),
                                              );
                                              poderesEscolhidos.add(
                                                Poder(
                                                  nome:
                                                      "$existingName (Afinidade)",
                                                  tipo: p.tipo,
                                                  descricao: p.descricao,
                                                  preRequisitos:
                                                      p.preRequisitos,
                                                  custoPE: p.custoPE,
                                                ),
                                              );
                                              atualizarFicha();
                                            });
                                            Navigator.pop(context);
                                            return;
                                          } else {
                                            showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                backgroundColor: const Color(
                                                  0xFF1A1A1A,
                                                ),
                                                title: Text(
                                                  "Resistir a Elemento",
                                                  style: TextStyle(
                                                    color: corDestaqueLocal,
                                                  ),
                                                ),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children:
                                                      [
                                                        "Sangue",
                                                        "Morte",
                                                        "Energia",
                                                        "Conhecimento",
                                                      ].map((elem) {
                                                        return ListTile(
                                                          title: Text(
                                                            elem,
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                          onTap: () {
                                                            setState(() {
                                                              poderesEscolhidos.add(
                                                                Poder(
                                                                  nome:
                                                                      "Resistir a Elemento ($elem)",
                                                                  tipo: p.tipo,
                                                                  descricao: p
                                                                      .descricao,
                                                                  preRequisitos:
                                                                      p.preRequisitos,
                                                                  custoPE:
                                                                      p.custoPE,
                                                                ),
                                                              );
                                                              atualizarFicha();
                                                            });
                                                            Navigator.pop(ctx);
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                        );
                                                      }).toList(),
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                        }

                                        // REGRA: EXPANSÃO DE CONHECIMENTO
                                        if (p.nome ==
                                            "Expansão de Conhecimento") {
                                          List<Poder> outrasClasses = [];
                                          List<String> opcoesFiltro = ["Todos"];
                                          if (classeAtual != 'combatente') {
                                            outrasClasses.addAll(
                                              catalogoPoderesCombatente,
                                            );
                                            opcoesFiltro.add("Combatente");
                                          }
                                          if (classeAtual != 'especialista') {
                                            outrasClasses.addAll(
                                              catalogoPoderesEspecialista,
                                            );
                                            opcoesFiltro.add("Especialista");
                                          }
                                          if (classeAtual != 'ocultista') {
                                            outrasClasses.addAll(
                                              catalogoPoderesOcultista,
                                            );
                                            opcoesFiltro.add("Ocultista");
                                          }

                                          String filtroExpansao =
                                              "Todos"; // Estado local do Pop-up

                                          showDialog(
                                            context: context,
                                            builder: (ctx) {
                                              return StatefulBuilder(
                                                builder: (context, setExpansaoState) {
                                                  // Filtra a lista com base no botão clicado
                                                  List<Poder> listaFiltrada =
                                                      outrasClasses.where((
                                                        pod,
                                                      ) {
                                                        if (filtroExpansao ==
                                                            "Todos") {
                                                          return true;
                                                        }
                                                        return pod.tipo ==
                                                            filtroExpansao;
                                                      }).toList();

                                                  return AlertDialog(
                                                    backgroundColor:
                                                        const Color(0xFF1A1A1A),
                                                    title: Text(
                                                      isPoderAtual
                                                          ? "Expansão (Afinidade)"
                                                          : "Expansão de Conhecimento",
                                                      style: TextStyle(
                                                        color: corDestaqueLocal,
                                                      ),
                                                    ),
                                                    content: SizedBox(
                                                      width: double.maxFinite,
                                                      height: 400,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          // BOTOES DE FILTRO DA EXPANSÃO
                                                          SingleChildScrollView(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            child: Row(
                                                              children: opcoesFiltro
                                                                  .map(
                                                                    (
                                                                      cat,
                                                                    ) => Padding(
                                                                      padding: const EdgeInsets.only(
                                                                        right:
                                                                            8.0,
                                                                      ),
                                                                      child: ChoiceChip(
                                                                        label: Text(
                                                                          cat,
                                                                          style: TextStyle(
                                                                            color:
                                                                                filtroExpansao ==
                                                                                    cat
                                                                                ? Colors.black
                                                                                : Colors.grey.shade400,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                        ),
                                                                        selected:
                                                                            filtroExpansao ==
                                                                            cat,
                                                                        onSelected: (val) => setExpansaoState(
                                                                          () => filtroExpansao =
                                                                              cat,
                                                                        ),
                                                                        selectedColor:
                                                                            Colors.white,
                                                                        backgroundColor:
                                                                            const Color(
                                                                              0xFF0D0D0D,
                                                                            ),
                                                                        side: BorderSide(
                                                                          color:
                                                                              filtroExpansao ==
                                                                                  cat
                                                                              ? Colors.white
                                                                              : Colors.grey.shade800,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                  .toList(),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 12,
                                                          ),

                                                          // LISTA DE PODERES ESTRANGEIROS
                                                          Expanded(
                                                            child: ListView.builder(
                                                              itemCount:
                                                                  listaFiltrada
                                                                      .length,
                                                              itemBuilder: (context, idxClass) {
                                                                var pEstrangeiro =
                                                                    listaFiltrada[idxClass];
                                                                return Theme(
                                                                  data:
                                                                      Theme.of(
                                                                        context,
                                                                      ).copyWith(
                                                                        dividerColor:
                                                                            Colors.transparent,
                                                                      ),
                                                                  child: ExpansionTile(
                                                                    iconColor:
                                                                        Colors
                                                                            .white,
                                                                    collapsedIconColor:
                                                                        Colors
                                                                            .white54,
                                                                    title: Text(
                                                                      pEstrangeiro
                                                                          .nome,
                                                                      style: const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            14,
                                                                      ),
                                                                    ),
                                                                    subtitle: Text(
                                                                      pEstrangeiro.preRequisitos !=
                                                                              "Nenhum"
                                                                          ? "Pré-req: ${pEstrangeiro.preRequisitos}"
                                                                          : "Sem Pré-requisito",
                                                                      style: const TextStyle(
                                                                        color: Colors
                                                                            .grey,
                                                                        fontSize:
                                                                            10,
                                                                      ),
                                                                    ),
                                                                    trailing: IconButton(
                                                                      icon: const Icon(
                                                                        Icons
                                                                            .add_circle,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      onPressed: () {
                                                                        // VERIFICAÇÃO DE PRÉ-REQUISITOS DO PODER ESTRANGEIRO
                                                                        if (pEstrangeiro.preRequisitos !=
                                                                                "Nenhum" &&
                                                                            pEstrangeiro.preRequisitos.isNotEmpty) {
                                                                          Map<
                                                                            String,
                                                                            int
                                                                          >
                                                                          contagem = {
                                                                            "Sangue": poderesEscolhidos
                                                                                .where(
                                                                                  (
                                                                                    pe,
                                                                                  ) =>
                                                                                      pe.tipo ==
                                                                                      "Sangue",
                                                                                )
                                                                                .length,
                                                                            "Morte": poderesEscolhidos
                                                                                .where(
                                                                                  (
                                                                                    pe,
                                                                                  ) =>
                                                                                      pe.tipo ==
                                                                                      "Morte",
                                                                                )
                                                                                .length,
                                                                            "Energia": poderesEscolhidos
                                                                                .where(
                                                                                  (
                                                                                    pe,
                                                                                  ) =>
                                                                                      pe.tipo ==
                                                                                      "Energia",
                                                                                )
                                                                                .length,
                                                                            "Conhecimento": poderesEscolhidos
                                                                                .where(
                                                                                  (
                                                                                    pe,
                                                                                  ) =>
                                                                                      pe.tipo ==
                                                                                      "Conhecimento",
                                                                                )
                                                                                .length,
                                                                          };
                                                                          bool
                                                                          cumpre =
                                                                              true;
                                                                          for (String req in pEstrangeiro.preRequisitos.split(
                                                                            ',',
                                                                          )) {
                                                                            req =
                                                                                req.trim();
                                                                            for (String elem in [
                                                                              "Sangue",
                                                                              "Morte",
                                                                              "Energia",
                                                                              "Conhecimento",
                                                                            ]) {
                                                                              if (req.startsWith(
                                                                                elem,
                                                                              )) {
                                                                                int
                                                                                needed =
                                                                                    int.tryParse(
                                                                                      req
                                                                                          .replaceAll(
                                                                                            elem,
                                                                                            '',
                                                                                          )
                                                                                          .trim(),
                                                                                    ) ??
                                                                                    0;
                                                                                if (contagem[elem]! <
                                                                                    needed) {
                                                                                  cumpre = false;
                                                                                }
                                                                              }
                                                                            }
                                                                          }
                                                                          if (!cumpre) {
                                                                            ScaffoldMessenger.of(
                                                                              context,
                                                                            ).showSnackBar(
                                                                              SnackBar(
                                                                                content: Text(
                                                                                  "Pré-requisitos não atendidos: ${pEstrangeiro.preRequisitos}",
                                                                                ),
                                                                                backgroundColor: Colors.redAccent,
                                                                                behavior: SnackBarBehavior.floating,
                                                                              ),
                                                                            );
                                                                            return;
                                                                          }
                                                                        }

                                                                        setState(() {
                                                                          String
                                                                          prefix =
                                                                              isPoderAtual
                                                                              ? "Expansão (Afinidade)"
                                                                              : "Expansão";
                                                                          poderesEscolhidos.add(
                                                                            Poder(
                                                                              nome: "$prefix: ${pEstrangeiro.nome}",
                                                                              tipo: p.tipo,
                                                                              descricao: pEstrangeiro.descricao,
                                                                              preRequisitos: pEstrangeiro.preRequisitos,
                                                                              custoPE: pEstrangeiro.custoPE,
                                                                            ),
                                                                          );
                                                                          atualizarFicha();
                                                                        });
                                                                        Navigator.pop(
                                                                          ctx,
                                                                        );
                                                                        Navigator.pop(
                                                                          context,
                                                                        );
                                                                      },
                                                                    ),
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                          left:
                                                                              16,
                                                                          right:
                                                                              16,
                                                                          bottom:
                                                                              16,
                                                                        ),
                                                                        child: Text(
                                                                          pEstrangeiro
                                                                              .descricao,
                                                                          style: const TextStyle(
                                                                            color:
                                                                                Colors.white70,
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(ctx),
                                                        child: const Text(
                                                          "CANCELAR",
                                                          style: TextStyle(
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          );
                                          return;
                                        }

                                        // ADIÇÃO NORMAL DE PODERES
                                        setState(() {
                                          if (isPoderAtual) {
                                            poderesEscolhidos.removeWhere(
                                              (pe) => pe.nome == p.nome,
                                            );
                                            poderesEscolhidos.add(
                                              Poder(
                                                nome: "${p.nome} (Afinidade)",
                                                tipo: p.tipo,
                                                descricao: p.descricao,
                                                custoPE: p.custoPE,
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
      int oldPpMax = ppMax;

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

      // MOTOR DE PODERES GERAIS (Treino ou +2)
      void aplicarTreinoOuBonus(String idPericia) {
        var per = listaPericias.firstWhere(
          (p) => p.id == idPericia,
          orElse: () => Pericia(id: '', nome: '', atributo: ''),
        );
        if (per.id.isNotEmpty) {
          if (per.treino < 5) {
            per.treino = 5; // Se não é treinado, treina!
          } else {
            bonusOrigem[idPericia] =
                (bonusOrigem[idPericia] ?? 0) + 2; // Se já é, ganha +2!
          }
        }
      }

      // Limpa os bônus antigos antes de recalcular
      for (var p in listaPericias) {
        if (!p.daOrigem && !periciasClasse.contains(p.id)) {
          // Só limpa se a perícia não for originada de classe ou origem.
          // Se a perícia foi setada por um poder geral e depois o jogador remover o poder,
          // nós garantimos que ela volte a 0 no final da função se não houver motivo pra ela ser 5+.
        }
      }

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

      if (classeAtual.toLowerCase() == 'ocultista' && nex >= 5) {
        // O sistema verifica se a tag de setup já existe. Se não existir, chama o pop-up!
        if (!poderesEscolhidos.any(
          (p) => p.nome == "Ocultista_Setup_Iniciais",
        )) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _mostrarDialogEscolhidoPeloOutroLado(),
          );
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

      // ==========================================
      // TRILHAS DE OCULTISTA
      // ==========================================

      // INTUITIVO: Resistências Mentais e Paranormais
      if (trilhaAtual == 'intuitivo') {
        if (nex >= 65) {
          resistencias['Mental'] = (resistencias['Mental'] ?? 0) + 10;
          resistencias['Paranormal'] =
              (resistencias['Paranormal'] ?? 0) + 10; // +10 cumulativo
        }
      }

      // EXORCISTA: Treinamento e Bônus em Religião
      if (trilhaAtual == 'exorcista') {
        if (nex >= 10 &&
            !poderesEscolhidos.any((p) => p.nome == "Exorcista_Setup_10")) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _mostrarDialogExorcista(10),
          );
        }
        if (nex >= 40 &&
            !poderesEscolhidos.any((p) => p.nome == "Exorcista_Setup_40")) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _mostrarDialogExorcista(40),
          );
        }

        // Aplica os bônus caso o jogador já fosse treinado/veterano antes da trilha
        if (poderesEscolhidos.any(
          (p) => p.nome == "Exorcista_BonusNum_Religiao",
        )) {
          bonusOrigem['religiao'] = (bonusOrigem['religiao'] ?? 0) + 2;
        }
        if (poderesEscolhidos.any(
          (p) => p.nome == "Exorcista_BonusDado_Religiao",
        )) {
          dadosExtrasPericias['religiao'] =
              (dadosExtrasPericias['religiao'] ?? 0) + 1;
        }
      }

      // TRILHA: GRADUADO (Saber Ampliado e Grimório)
      if (trilhaAtual == 'graduado') {
        // SABER AMPLIADO (1 ritual de graça em cada novo círculo)
        if (nex >= 10 &&
            !poderesEscolhidos.any(
              (p) => p.nome == "Graduado_SaberAmpliado_1",
            )) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _mostrarDialogSaberAmpliado(1, "Graduado_SaberAmpliado_1"),
          );
        }
        if (nex >= 25 &&
            !poderesEscolhidos.any(
              (p) => p.nome == "Graduado_SaberAmpliado_2",
            )) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _mostrarDialogSaberAmpliado(2, "Graduado_SaberAmpliado_2"),
          );
        }
        if (nex >= 55 &&
            !poderesEscolhidos.any(
              (p) => p.nome == "Graduado_SaberAmpliado_3",
            )) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _mostrarDialogSaberAmpliado(3, "Graduado_SaberAmpliado_3"),
          );
        }
        if (nex >= 85 &&
            !poderesEscolhidos.any(
              (p) => p.nome == "Graduado_SaberAmpliado_4",
            )) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _mostrarDialogSaberAmpliado(4, "Graduado_SaberAmpliado_4"),
          );
        }

        // GRIMÓRIO RITUALÍSTICO (NEX 40)
        if (nex >= 40 &&
            !inventario.any((i) => i.nome == "Grimório Ritualístico")) {
          inventario.add(
            ItemInventario(
              nome: "Grimório Ritualístico",
              categoria: "0",
              espaco: 1.0,
              descricao:
                  "Armazena rituais extras baseados no seu Intelecto. Requer ação completa para folhear antes de conjurar.",
            ),
          );
        }

        // RITUAIS EFICIENTES (NEX 65)
        if (nex >= 65 &&
            !poderesEscolhidos.any(
              (p) => p.nome == "Rituais Eficientes (Passiva)",
            )) {
          poderesEscolhidos.add(
            Poder(
              nome: "Rituais Eficientes (Passiva)",
              tipo: "Sistema",
              descricao:
                  "A DT para resistir a todos os seus rituais ganha um bônus de +5.",
            ),
          );
        }
      }

      // LÂMINA PARANORMAL: Amaldiçoar Arma Elementar
      if (trilhaAtual == 'lamina_paranormal' && nex >= 10) {
        if (!poderesEscolhidos.any((p) => p.nome == "Lamina_Setup_10")) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _mostrarDialogLaminaParanormal(),
          );
        }
      }

      // TRILHA: POSSUÍDO (PPs e Afinidade Final)
      if (trilhaAtual == 'possuido') {
        // 1. Cálculo do Limite de PPs
        int qtdPoderesParanormais = poderesEscolhidos
            .where(
              (p) => [
                "Conhecimento",
                "Energia",
                "Morte",
                "Sangue",
                "Medo",
              ].contains(p.tipo),
            )
            .length;
        ppMax = 3 + (2 * qtdPoderesParanormais);

        // Corta os excessos se ele perder um poder
        if (ppAtual > ppMax) ppAtual = ppMax;

        // Lógica Inteligente para ENCHER os PPs:
        if (isInitialLoad && widget.agenteParaEditar == null) {
          ppAtual = ppMax; // Ficha nova
        } else if (isInitialLoad &&
            widget.agenteParaEditar != null &&
            widget.agenteParaEditar!.ppAtual == null) {
          ppAtual =
              ppMax; // Ficha antiga que acabou de virar possuído (e o ppAtual veio nulo)
        } else if (!isInitialLoad && oldPpMax == 0 && ppMax > 0) {
          ppAtual =
              ppMax; // O jogador acabou de clicar em "ESCOLHER ESTA TRILHA" agora mesmo!
        }

        // 2. Gatilho NEX 65% - Ele Me Ensina
        if (nex >= 65 &&
            !poderesEscolhidos.any((p) => p.nome == "Possuido_Setup_65")) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _mostrarDialogEleMeEnsina(),
          );
        }

        // 3. Gatilho NEX 99% - Tornamo-nos Um
        if (nex >= 99 &&
            afinidadeAtual != null &&
            !poderesEscolhidos.any((p) => p.nome == "Tornamo-nos Um")) {
          String nomePoder = "";
          String descPoder = "";
          switch (afinidadeAtual) {
            case 'Sangue':
              nomePoder = "Presente da Obsessão";
              descPoder =
                  "Gaste 6 PE: Recupera 50 PV. Perícias de FOR/VIG e Intimidação viram +35. Demais de Presença viram -10.";
              break;
            case 'Morte':
              nomePoder = "Presente do Tempo";
              descPoder =
                  "Gaste 6 PE: Recebe um turno adicional na última contagem de iniciativa da rodada.";
              break;
            case 'Conhecimento':
              nomePoder = "Presente do Saber";
              descPoder =
                  "Gaste 6 PE: Recebe um poder qualquer até o fim da cena (requer Vontade DT 15+).";
              break;
            case 'Energia':
              nomePoder = "Presente do Espaço";
              descPoder = "Gaste 6 PE: Teletransporte em alcance médio.";
              break;
          }
          if (nomePoder.isNotEmpty) {
            poderesEscolhidos.add(
              Poder(
                nome: "Tornamo-nos Um ($nomePoder)",
                tipo: "Sistema",
                descricao: descPoder,
              ),
            );
          }
        }
      }

      // RITUAIS AUTOMÁTICOS: NEX 99 e Lâmina Paranormal (NEX 10)
      void aprenderRituaisAutomaticos(String nomeRitual) {
        if (!rituaisConhecidos.any((r) => r.nome == nomeRitual)) {
          var rEncontrado =
              catalogoRituais.where((r) => r.nome == nomeRitual).firstOrNull ??
              Ritual(
                nome: nomeRitual,
                elemento: "Medo",
                circulo: 4,
                execucao: "Padrão",
                alcance: "Toque",
                alvoAreaEfeito: "Alvo",
                duracao: "Cena",
                resistencia: "",
                descricao: "Ritual automático aprendido pelo NEX 99 da trilha.",
              );
          rituaisConhecidos.add(rEncontrado);
        }
      }

      if (nex >= 99) {
        if (trilhaAtual == 'conduite') {
          aprenderRituaisAutomaticos("Canalizar o Medo");
        }
        if (trilhaAtual == 'flagelador') {
          aprenderRituaisAutomaticos("Medo Tangível");
        }
        if (trilhaAtual == 'graduado') {
          aprenderRituaisAutomaticos("Conhecendo o Medo");
        }
        if (trilhaAtual == 'intuitivo') {
          aprenderRituaisAutomaticos("Presença do Medo");
        }
        if (trilhaAtual == 'lamina_paranormal') {
          aprenderRituaisAutomaticos("Lâmina do Medo");
        }
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

      // BÔNUS PASSIVOS DE PODERES PARANORMAIS

      // ESPREITAR DA BESTA
      if (poderesEscolhidos.any((p) => p.nome.contains("Espreitar da Besta"))) {
        int bonusEspreitar =
            poderesEscolhidos.any(
              (p) =>
                  p.nome.contains("Espreitar da Besta") &&
                  p.nome.contains("(Afinidade)"),
            )
            ? 10
            : 5;
        bonusOrigem['furtividade'] =
            (bonusOrigem['furtividade'] ?? 0) + bonusEspreitar;
      }

      // PRECOGNIÇÃO
      if (poderesEscolhidos.any((p) => p.nome.contains("Precognição"))) {
        defesa += 2;
        bonusOrigem['fortitude'] = (bonusOrigem['fortitude'] ?? 0) + 2;
        bonusOrigem['reflexos'] = (bonusOrigem['reflexos'] ?? 0) + 2;
        bonusOrigem['vontade'] = (bonusOrigem['vontade'] ?? 0) + 2;
      }

      // SENSITIVO
      if (poderesEscolhidos.any((p) => p.nome.contains("Sensitivo"))) {
        bonusOrigem['diplomacia'] = (bonusOrigem['diplomacia'] ?? 0) + 5;
        bonusOrigem['intimidacao'] = (bonusOrigem['intimidacao'] ?? 0) + 5;
        bonusOrigem['intuicao'] = (bonusOrigem['intuicao'] ?? 0) + 5;
      }

      // VISÃO DO OCULTO
      if (poderesEscolhidos.any((p) => p.nome.contains("Visão do Oculto"))) {
        bonusOrigem['percepcao'] = (bonusOrigem['percepcao'] ?? 0) + 5;
      }

      // RESISTIR A ELEMENTO
      for (var elem in ["Sangue", "Morte", "Energia", "Conhecimento"]) {
        if (poderesEscolhidos.any(
          (p) => p.nome.contains("Resistir a Elemento ($elem)"),
        )) {
          int resValor =
              poderesEscolhidos.any(
                (p) =>
                    p.nome.contains("Resistir a Elemento ($elem) (Afinidade)"),
              )
              ? 20
              : 10;
          resistencias[elem] = (resistencias[elem] ?? 0) + resValor;
        }
      }

      // BÔNUS PASSIVOS DE PODERES GERAIS
      List<String> poderesNomes = poderesEscolhidos.map((p) => p.nome).toList();

      if (poderesNomes.contains("Acrobático")) {
        aplicarTreinoOuBonus('acrobacia');
      }
      if (poderesNomes.contains("Ás do Volante")) {
        aplicarTreinoOuBonus('pilotagem');
      }
      if (poderesNomes.contains("Atlético")) aplicarTreinoOuBonus('atletismo');
      if (poderesNomes.contains("Dedos Ágeis")) aplicarTreinoOuBonus('crime');
      if (poderesNomes.contains("Detector de Mentiras")) {
        aplicarTreinoOuBonus('intuicao');
      }
      if (poderesNomes.contains("Especialista em Emergências")) {
        aplicarTreinoOuBonus('medicina');
      }
      if (poderesNomes.contains("Informado")) {
        aplicarTreinoOuBonus('atualidades');
      }
      if (poderesNomes.contains("Interrogador")) {
        aplicarTreinoOuBonus('intimidacao');
      }
      if (poderesNomes.contains("Mentiroso Nato")) {
        aplicarTreinoOuBonus('enganacao');
      }
      if (poderesNomes.contains("Observador")) {
        aplicarTreinoOuBonus('investigacao');
      }
      if (poderesNomes.contains("Pai de Pet")) {
        aplicarTreinoOuBonus('adestramento');
      }
      if (poderesNomes.contains("Palavras de Devoção")) {
        aplicarTreinoOuBonus('religiao');
      }
      if (poderesNomes.contains("Pensamento Tático")) {
        aplicarTreinoOuBonus('tatica');
      }
      if (poderesNomes.contains("Personalidade Esotérica")) {
        aplicarTreinoOuBonus('ocultismo');
      }
      if (poderesNomes.contains("Persuasivo")) {
        aplicarTreinoOuBonus('diplomacia');
      }
      if (poderesNomes.contains("Pesquisador Científico")) {
        aplicarTreinoOuBonus('ciencias');
      }
      if (poderesNomes.contains("Proativo")) aplicarTreinoOuBonus('iniciativa');
      if (poderesNomes.contains("Rato de Computador")) {
        aplicarTreinoOuBonus('tecnologia');
      }
      if (poderesNomes.contains("Resposta Rápida")) {
        aplicarTreinoOuBonus('reflexos');
      }
      if (poderesNomes.contains("Sentidos Aguçados")) {
        aplicarTreinoOuBonus('percepcao');
      }
      if (poderesNomes.contains("Sobrevivencialista")) {
        aplicarTreinoOuBonus('sobrevivencia');
      }
      if (poderesNomes.contains("Sorrateiro")) {
        aplicarTreinoOuBonus('furtividade');
      }
      if (poderesNomes.contains("Talentoso")) aplicarTreinoOuBonus('artes');
      if (poderesNomes.contains("Teimosia Obstinada")) {
        aplicarTreinoOuBonus('vontade');
      }
      if (poderesNomes.contains("Tenacidade")) {
        aplicarTreinoOuBonus('fortitude');
      }

      // Bônus Extras dos Poderes Gerais (Deslocamento, RD, etc)
      if (poderesNomes.contains("Atraente")) {
        // Atraente é condicional (só contra quem sente atração), então o mestre julga na hora,
        // mas se quiser forçar um bônus visual na ficha, descomente as linhas abaixo:
        // bonusOrigem['artes'] = (bonusOrigem['artes'] ?? 0) + 5;
        // bonusOrigem['diplomacia'] = (bonusOrigem['diplomacia'] ?? 0) + 5;
        // bonusOrigem['enganacao'] = (bonusOrigem['enganacao'] ?? 0) + 5;
        // bonusOrigem['intimidacao'] = (bonusOrigem['intimidacao'] ?? 0) + 5;
      }

      if (poderesNomes.contains("Observador")) {
        // Soma seu Intelecto em Intuição
        bonusOrigem['intuicao'] = (bonusOrigem['intuicao'] ?? 0) + efInt;
      }

      if (poderesNomes.contains("Sobrevivencialista")) {
        // Bônus passivo de clima é interpretativo, mas se quiser dar o +2 direto:
        // bonusOrigem['sobrevivencia'] = (bonusOrigem['sobrevivencia'] ?? 0) + 2;
      }

      // ==========================================
      // FOCO EM PERÍCIA (+1 Dado)
      // ==========================================
      for (var p in poderesEscolhidos) {
        if (p.nome.startsWith("Foco em Perícia (")) {
          String perNome = p.nome
              .replaceAll("Foco em Perícia (", "")
              .replaceAll(")", "")
              .toLowerCase();
          var per = listaPericias.firstWhere(
            (pericia) => pericia.nome.toLowerCase() == perNome,
            orElse: () => Pericia(id: '', nome: '', atributo: ''),
          );
          if (per.id.isNotEmpty) {
            dadosExtrasPericias[per.id] =
                (dadosExtrasPericias[per.id] ?? 0) + 1;
          }
        }
      }

      // ARTISTA MARCIAL E ATAQUE DESARMADO
      Arma? ataqueDesarmado = armas
          .where((a) => a.nome == "Ataque Desarmado")
          .firstOrNull;
      if (ataqueDesarmado == null) {
        armas.insert(
          0,
          Arma(
            nome: "Ataque Desarmado",
            tipo: "Corpo a Corpo",
            dano: "1d4",
            categoria: "0",
            espaco: 0,
            proficiencia: "Simples",
            empunhadura: "Leve",
            descricao: "Seus punhos, pés, cotovelos e joelhos.",
            equipado: true,
          ),
        );
        ataqueDesarmado = armas.first;
      }

      if (poderesEscolhidos.any((p) => p.nome == "Artista Marcial")) {
        ataqueDesarmado.dano = nex >= 70
            ? "1d10"
            : nex >= 35
            ? "1d8"
            : "1d6";
        ataqueDesarmado.atributoPersonalizado = (efAgi > efFor) ? 'AGI' : 'FOR';
      } else {
        ataqueDesarmado.dano = "1d4";
        ataqueDesarmado.atributoPersonalizado = ''; // Volta ao padrão
      }

      // BÔNUS PASSIVO DE ORIGENS

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

      // TRILHA: INFILTRADOR (Gatuno)
      if (trilhaAtual == 'infiltrador' && nex >= 40) {
        bonusOrigem['atletismo'] = (bonusOrigem['atletismo'] ?? 0) + 5;
        bonusOrigem['crime'] = (bonusOrigem['crime'] ?? 0) + 5;
      }

      // TRILHA: BIBLIOTECÁRIO (A Força do Saber)
      if (trilhaAtual == 'bibliotecario' && nex >= 99) {
        efInt += 1;
        peMax += efInt;

        if (!poderesEscolhidos.any(
          (p) => p.nome.startsWith("Bibliotecario_Setup"),
        )) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _mostrarDialogBibliotecario(),
          );
        }
      }

      // TRILHA: MUAMBEIRO (Mascate e Laboratório de Campo)
      if (trilhaAtual == 'muambeiro') {
        if (nex >= 10 &&
            !poderesEscolhidos.any(
              (p) => p.nome.startsWith("Muambeiro_Setup_10"),
            )) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _mostrarDialogMuambeiro(10),
          );
        }
        if (nex >= 65 &&
            !poderesEscolhidos.any(
              (p) => p.nome.startsWith("Muambeiro_Setup_65"),
            )) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _mostrarDialogMuambeiro(65),
          );
        }
      }

      // FOCO EM PERÍCIA (+1 Dado)
      for (var p in poderesEscolhidos) {
        if (p.nome.startsWith("Foco em Perícia (")) {
          String perNome = p.nome
              .replaceAll("Foco em Perícia (", "")
              .replaceAll(")", "")
              .toLowerCase();
          var per = listaPericias.firstWhere(
            (pericia) => pericia.nome.toLowerCase() == perNome,
            orElse: () => Pericia(id: '', nome: '', atributo: ''),
          );
          if (per.id.isNotEmpty) {
            dadosExtrasPericias[per.id] =
                (dadosExtrasPericias[per.id] ?? 0) + 1;
          }
        }
      }

      if (poderesEscolhidos.any((p) => p.nome == "Artista Marcial")) {
        ataqueDesarmado.dano = nex >= 70
            ? "1d10"
            : nex >= 35
            ? "1d8"
            : "1d6";
        ataqueDesarmado.atributoPersonalizado = (efAgi > efFor) ? 'AGI' : 'FOR';
      } else {
        ataqueDesarmado.dano = "1d4";
        ataqueDesarmado.atributoPersonalizado = ''; // Volta ao padrão
      }

      var stats = dadosClasses[classeAtual];
      if (stats != null) {
        int nivel = (nex / 5).toInt();

        int atributoPE = efPre;

        // RACIONALIDADE INFLEXÍVEL
        if (poderesEscolhidos.any(
          (p) => p.nome == "Racionalidade Inflexível",
        )) {
          atributoPE = efInt;
          var perVontade = listaPericias.firstWhere(
            (p) => p.id == 'vontade',
            orElse: () => Pericia(id: '', nome: '', atributo: ''),
          );
          if (perVontade.id.isNotEmpty) perVontade.atributo = 'INT';
        } else {
          var perVontade = listaPericias.firstWhere(
            (p) => p.id == 'vontade',
            orElse: () => Pericia(id: '', nome: '', atributo: ''),
          );
          if (perVontade.id.isNotEmpty) perVontade.atributo = 'PRE';
        }

        if (trilhaAtual == 'monstruoso' && nex >= 40) {
          if (afinidadeAtual == 'Sangue') atributoPE = efFor;
          if (afinidadeAtual == 'Morte') atributoPE = efVig;
          if (afinidadeAtual == 'Conhecimento') atributoPE = efInt;
          if (afinidadeAtual == 'Energia') atributoPE = efAgi;
        }

        pvMax =
            stats.pvBase + (efVig * nivel) + (stats.pvPorNivel * (nivel - 1));

        // VITALIDADE REFORÇADA
        if (poderesEscolhidos.any((p) => p.nome == "Vitalidade Reforçada")) {
          pvMax += (nex ~/ 5);
          bonusOrigem['fortitude'] = (bonusOrigem['fortitude'] ?? 0) + 2;
        }

        if (trilhaAtual == 'monstruoso' && afinidadeAtual == 'Morte') {
          pvMax += efFor;
        }

        // PODER: SANGUE DE FERRO
        if (poderesEscolhidos.any((p) => p.nome.contains("Sangue de Ferro"))) {
          pvMax += (nivel * 2);
          if (poderesEscolhidos.any(
            (p) =>
                p.nome.contains("Sangue de Ferro") &&
                p.nome.contains("(Afinidade)"),
          )) {
            bonusOrigem['fortitude'] = (bonusOrigem['fortitude'] ?? 0) + 5;
            resistencias['Venenos'] = 999;
            resistencias['Doenças'] = 999;
          }
        }

        peMax =
            stats.peBase +
            (atributoPE * nivel) +
            (stats.pePorNivel * (nivel - 1));

        // VONTADE INABALÁVEL
        if (poderesEscolhidos.any((p) => p.nome == "Vontade Inabalável")) {
          peMax += (nex ~/ 10);
          bonusOrigem['vontade'] = (bonusOrigem['vontade'] ?? 0) + 2;
        }

        if (poderesEscolhidos.any((p) => p.nome == "Personalidade Esotérica")) {
          peMax += 3;
        }

        // POTENCIAL APRIMORADO (Cuidado para não apagar esse, ele já existia antes)
        if (poderesEscolhidos.any(
          (p) => p.nome.contains("Potencial Aprimorado"),
        )) {
          int bonusPE =
              poderesEscolhidos.any(
                (p) =>
                    p.nome.contains("Potencial Aprimorado") &&
                    p.nome.contains("(Afinidade)"),
              )
              ? 2
              : 1;
          peMax += (bonusPE * nivel);
        }

        // ==========================================
        // CÁLCULO DE SANIDADE CORRIGIDO E BLINDADO
        // ==========================================
        int qtdParanormal = poderesEscolhidos.where((p) {
          if (p.tipo == "Sistema" ||
              p.tipo == "Trilha Extra" ||
              p.tipo == "Origem") {
            return false;
          }
          if (p.nome.startsWith("Expansão: ") ||
              p.nome.startsWith("Expansão (Afinidade): ")) {
            return false;
          }
          if ([
            "Conhecimento",
            "Energia",
            "Morte",
            "Sangue",
            "Medo",
          ].contains(p.tipo)) {
            return true;
          }
          return false;
        }).length;

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

        // Bônus Finais de Origens e Trilhas
        if (origemAtual == 'desgarrado') pvMax += nivel;
        if (origemAtual == 'vitima') sanMax += nivel;
        if (origemAtual == 'mergulhador') pvMax += 5;
        if (origemAtual == 'universitario') {
          peMax += 1;
          int nexImpares = (nivel / 2).floor();
          if (nivel >= 3) peMax += nexImpares;
        }
        if (trilhaAtual == 'tropa_de_choque' && nex >= 10) pvMax += nivel;

        // ==========================================
        // VARIÁVEIS DE INVENTÁRIO E PROTEÇÃO
        // ==========================================
        int defItens = 0, bonusBloqueioBracadeira = 0;
        bool usaProtecaoLeve = false;
        bool usaProtecaoPesada = false;
        bool usaEscudo = false;

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
          if (m == "Proteção Elemental (Energia)") {
            resistencias['Energia'] = (resistencias['Energia'] ?? 0) + 10;
          }
          if (m == "Proteção Elemental (Conhecimento)") {
            resistencias['Conhecimento'] =
                (resistencias['Conhecimento'] ?? 0) + 10;
          }
        }

        for (var item in inventario.where((i) => i.equipado)) {
          String nomeLower = item.nome.toLowerCase().trim();
          String descLower = item.descricao.toLowerCase().trim();

          for (var mod in item.modificacoes) {
            processarMaldicao(mod);
          }

          if (descLower.contains("proteção pesada") ||
              descLower.contains("protecao pesada")) {
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

          if (item.tipo == "Proteção" ||
              descLower.contains("proteção") ||
              descLower.contains("protecao") ||
              nomeLower.contains("escudo")) {
            int defItemLocal = item.defesa > 0 ? item.defesa : 0;

            // Se for item antigo sem defesa salva:
            if (defItemLocal == 0) {
              if (nomeLower.contains("leve")) {
                defItemLocal = 5;
              } else if (nomeLower.contains("pesada")) {
                defItemLocal = 10;
              } else if (nomeLower.contains("escudo")) {
                defItemLocal = 2;
              } else if (descLower.contains("defesa +5")) {
                defItemLocal = 5; // Proteção leve antiga
              } else if (descLower.contains("defesa +10")) {
                defItemLocal = 10; // Proteção pesada antiga
              } else {
                defItemLocal = 2;
              }
            }

            defItens += defItemLocal;
            if (item.modificacoes.contains("Reforçada")) defItens += 2;

            // ==========================================
            // CLASSIFICAÇÃO CORRIGIDA (IGNORANDO A DESCRIÇÃO)
            // ==========================================
            bool isEscudoItem = nomeLower.contains("escudo");
            bool isPesadaItem = false;
            bool isLeveItem = false;

            if (!isEscudoItem) {
              if (nomeLower.contains("leve")) {
                isLeveItem = true;
              } else if (nomeLower.contains("pesada")) {
                isPesadaItem = true;
              } else {
                // Se o nome for customizado (ex: "Colete Tático"), usamos o valor da defesa para deduzir
                if (defItemLocal > 7) {
                  isPesadaItem = true;
                } else {
                  isLeveItem = true;
                }
              }
            }

            if (isEscudoItem) usaEscudo = true;
            if (isPesadaItem) usaProtecaoPesada = true;
            if (isLeveItem) usaProtecaoLeve = true;
          }

          if (nomeLower.contains("braçadeira reforçada")) {
            bonusBloqueioBracadeira += 2;
          }
        }

        for (var arma in armas.where((a) => a.equipado)) {
          for (var mod in arma.modificacoes) {
            processarMaldicao(mod);
            if (mod == "Repulsora") defItens += 2;
          }
        }

        // ==========================================
        // APLICAÇÃO OFICIAL DE PENALIDADES DA CLASSE
        // ==========================================
        sofrePenalidadeProtecao = false;
        String cLimpa = classeAtual.toLowerCase().trim();

        bool temPoderPesada = poderesEscolhidos.any(
          (p) =>
              p.nome.toLowerCase().contains('proteção pesada') ||
              p.nome.toLowerCase().contains('protecao pesada'),
        );

        if (cLimpa == 'combatente') {
          if (usaProtecaoPesada && !temPoderPesada) {
            sofrePenalidadeProtecao = true;
          }
        } else if (cLimpa == 'especialista') {
          if (usaProtecaoPesada || usaEscudo) sofrePenalidadeProtecao = true;
        } else if (cLimpa == 'ocultista') {
          if (usaProtecaoLeve || usaProtecaoPesada || usaEscudo) {
            sofrePenalidadeProtecao = true;
          }
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
        // PRECOGNIÇÃO (+2 na Defesa)
        if (poderesEscolhidos.any((p) => p.nome.contains("Precognição"))) {
          defesa += 2;
        }

        // RESISTIR A ELEMENTO (10 ou 20 com afinidade)
        for (var elem in ["Sangue", "Morte", "Energia", "Conhecimento"]) {
          if (poderesEscolhidos.any(
            (p) => p.nome.contains("Resistir a Elemento ($elem)"),
          )) {
            int resValor =
                poderesEscolhidos.any(
                  (p) => p.nome.contains(
                    "Resistir a Elemento ($elem) (Afinidade)",
                  ),
                )
                ? 20
                : 10;
            resistencias[elem] = (resistencias[elem] ?? 0) + resValor;
          }
        }

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

        // PODER: SANGUE FERVENTE
        if (isMachucado) {
          int bonusSangueFervente =
              poderesEscolhidos.any(
                (p) =>
                    p.nome.contains("Sangue Fervente") &&
                    p.nome.contains("(Afinidade)"),
              )
              ? 2
              : 1;

          if (poderesEscolhidos.any(
            (p) => p.nome.contains("Sangue Fervente (AGI)"),
          )) {
            efAgi += bonusSangueFervente;
          } else if (poderesEscolhidos.any(
            (p) => p.nome.contains("Sangue Fervente (FOR)"),
          )) {
            efFor += bonusSangueFervente;
          }
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
          // PV
          if (pvMax > oldPvMax && oldPvMax > 0) {
            pvAtual = min(pvMax, pvAtual + (pvMax - oldPvMax)); // Devolve o PV
          } else if (pvMax < oldPvMax) {
            pvAtual = min(pvAtual, pvMax); // Corta o excesso
          }

          // PE
          if (peMax > oldPeMax && oldPeMax > 0) {
            peAtual = min(peMax, peAtual + (peMax - oldPeMax)); // Devolve o PE
          } else if (peMax < oldPeMax) {
            peAtual = min(peAtual, peMax);
          }

          // SANIDADE
          if (sanMax > oldSanMax && oldSanMax > 0) {
            sanAtual = min(
              sanMax,
              sanAtual + (sanMax - oldSanMax),
            ); // Devolve a Sanidade Perdida
          } else if (sanMax < oldSanMax) {
            sanAtual = min(sanAtual, sanMax);
          }
        } else if (widget.agenteParaEditar == null) {
          pvAtual = pvMax;
          peAtual = peMax;
          sanAtual = sanMax;
        }
      }
    });

    if (!isInitialLoad) _salvarSilencioso();
  }

  void _mostrarDialogEscolhidoPeloOutroLado() {
    List<Ritual> selecionados = [];
    String filtroElemento = "Todos";
    String busca = "";

    List<Ritual> rituais1Circulo = catalogoRituais
        .where((r) => r.circulo == 1)
        .toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            List<Ritual> filtrados = rituais1Circulo.where((r) {
              if (filtroElemento != "Todos") {
                if (r.elemento.toLowerCase() != filtroElemento.toLowerCase()) {
                  return false;
                }
              }
              if (busca.isNotEmpty &&
                  !r.nome.toLowerCase().contains(busca.toLowerCase())) {
                return false;
              }
              return true;
            }).toList();

            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ocultista: Escolhido pelo Outro Lado",
                    style: TextStyle(color: corDestaque, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Escolha 3 rituais de 1º Círculo:",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  children: [
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: EstiloParanormal.customInputDeco(
                        "Buscar ritual...",
                        corDestaque,
                        Icons.search,
                      ),
                      onChanged: (val) => setDialogState(() => busca = val),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            [
                              "Todos",
                              "Sangue",
                              "Morte",
                              "Energia",
                              "Conhecimento",
                              "Medo",
                            ].map((el) {
                              bool ativo = filtroElemento == el;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(
                                    el,
                                    style: TextStyle(
                                      color: ativo
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                  selected: ativo,
                                  selectedColor: el == "Todos"
                                      ? Colors.white
                                      : _obterCorAfinidade(el),
                                  backgroundColor: Colors.black,
                                  onSelected: (val) {
                                    if (val) {
                                      setDialogState(() => filtroElemento = el);
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtrados.length,
                        itemBuilder: (context, index) {
                          Ritual r = filtrados[index];
                          bool isSelected = selecionados.contains(r);

                          return CardRitualAnimado(
                            ritual: r,
                            corElemento: _obterCorAfinidade(r.elemento),
                            leading: Checkbox(
                              activeColor: r.elemento.toLowerCase() == 'medo'
                                  ? Colors.black
                                  : Colors.white,
                              checkColor: r.elemento.toLowerCase() == 'medo'
                                  ? Colors.white
                                  : Colors.black,
                              side: BorderSide(color: Colors.grey.shade500),
                              value: isSelected,
                              onChanged: (bool? val) {
                                setDialogState(() {
                                  if (val == true) {
                                    if (selecionados.length < 3) {
                                      selecionados.add(r);
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Você só pode escolher 3 rituais!",
                                          ),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    }
                                  } else {
                                    selecionados.remove(r);
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Você deve escolher 3 rituais para continuar.",
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text(
                    "Pular",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corDestaque,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: selecionados.length == 3
                      ? () {
                          setState(() {
                            rituaisConhecidos.addAll(selecionados);
                            rituaisConhecidos.sort(
                              (a, b) => a.nome.compareTo(b.nome),
                            );
                            poderesEscolhidos.add(
                              Poder(
                                nome: "Ocultista_Setup_Iniciais",
                                tipo: "Sistema",
                                descricao: "",
                              ),
                            );
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
              ],
            );
          },
        );
      },
    );
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

  void _mostrarDialogBibliotecario() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text("A Força do Saber", style: TextStyle(color: corDestaque)),
          content: SizedBox(
            width: double.maxFinite,
            height: 350,
            child: Column(
              children: [
                const Text(
                  "Sua mente se fortaleceu. Escolha uma perícia para mudar o atributo base para INTELECTO:",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: listaPericias.length,
                    itemBuilder: (context, index) {
                      var per = listaPericias[index];
                      return ListTile(
                        title: Text(
                          per.nome.isEmpty ? per.id.toUpperCase() : per.nome,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "Atributo Atual: ${per.atributo}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.psychology,
                          color: Colors.blueAccent,
                        ),
                        onTap: () {
                          setState(() {
                            per.atributo =
                                'INT'; // Modifica o atributo da perícia!
                            poderesEscolhidos.add(
                              Poder(
                                nome: "Bibliotecario_Setup",
                                tipo: "Sistema",
                                descricao: per.id,
                              ),
                            );
                            atualizarFicha();
                          });
                          Navigator.pop(context);
                          _salvarSilencioso();
                        },
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

  void _mostrarDialogMuambeiro(int nivelSetup) {
    List<String> opcoesId = [
      'profissao_armeiro',
      'profissao_engenheiro',
      'profissao_quimico',
    ];
    List<String> opcoesNome = [
      'Profissão: Armeiro',
      'Profissão: Engenheiro',
      'Profissão: Químico',
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text(
            nivelSetup == 10 ? "Mascate" : "Laboratório de Campo",
            style: TextStyle(color: corDestaque),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Escolha o ofício para receber +5 em treinamento:",
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ...List.generate(opcoesId.length, (index) {
                // O margin agora fica aqui no Container!
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    tileColor: const Color(0xFF111111),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: BorderSide(color: Colors.grey.shade800),
                    ),
                    title: Text(
                      opcoesNome[index],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(Icons.build, color: Colors.amber),
                    onTap: () {
                      setState(() {
                        var per = listaPericias.firstWhere(
                          (p) => p.id == opcoesId[index],
                          orElse: () =>
                              Pericia(id: '', nome: '', atributo: 'INT'),
                        );
                        if (per.id.isEmpty) {
                          // Cria a profissão se não existir
                          listaPericias.add(
                            Pericia(
                              id: opcoesId[index],
                              nome: opcoesNome[index],
                              atributo: 'INT',
                              treino: 5,
                            ),
                          );
                        } else {
                          // Soma se já existir
                          per.treino += 5;
                        }
                        poderesEscolhidos.add(
                          Poder(
                            nome: "Muambeiro_Setup_$nivelSetup",
                            tipo: "Sistema",
                            descricao: opcoesId[index],
                          ),
                        );
                        atualizarFicha();
                      });
                      Navigator.pop(context);
                      _salvarSilencioso();
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _mostrarDialogExorcista(int nivelSetup) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text(
            nivelSetup == 10 ? "Revelação do Mal" : "Poder da Fé",
            style: TextStyle(color: corDestaque),
          ),
          content: Text(
            nivelSetup == 10
                ? "Sua fé revelou os sinais do paranormal.\n\nVocê recebe treinamento em Religião. Se já for treinado, recebe um bônus de +2 na perícia."
                : "Sua mente se fortaleceu.\n\nVocê se torna Veterano em Religião. Se já for, você passa a rolar +1d20 em testes de Religião.",
            style: const TextStyle(color: Colors.white, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: corDestaque,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  var rel = listaPericias.firstWhere(
                    (p) => p.id == 'religiao',
                    orElse: () => Pericia(
                      id: 'religiao',
                      nome: 'Religião',
                      atributo: 'PRE',
                    ),
                  );

                  if (nivelSetup == 10) {
                    if (rel.treino >= 5) {
                      // Já é treinado! Salva uma tag para darmos o bônus de +2
                      poderesEscolhidos.add(
                        Poder(
                          nome: "Exorcista_BonusNum_Religiao",
                          tipo: "Sistema",
                          descricao: "",
                        ),
                      );
                    } else {
                      rel.treino = 5;
                    }
                  } else if (nivelSetup == 40) {
                    if (rel.treino >= 10) {
                      // Já é veterano! Salva uma tag para darmos +1 Dado
                      poderesEscolhidos.add(
                        Poder(
                          nome: "Exorcista_BonusDado_Religiao",
                          tipo: "Sistema",
                          descricao: "",
                        ),
                      );
                    } else {
                      rel.treino = 10;
                    }
                  }

                  poderesEscolhidos.add(
                    Poder(
                      nome: "Exorcista_Setup_$nivelSetup",
                      tipo: "Sistema",
                      descricao: "Bônus de Religião aplicado.",
                    ),
                  );
                  atualizarFicha();
                });
                Navigator.pop(context);
                _salvarSilencioso();
                _mostrarNotificacao(
                  nivelSetup == 10
                      ? "Treinamento em Religião recebido!"
                      : "Mente fortalecida na Fé!",
                );
              },
              child: const Text(
                "RECEBER BÔNUS",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogLaminaParanormal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text("Lâmina Maldita", style: TextStyle(color: corDestaque)),
          content: const Text(
            "Escolha o elemento do ritual Amaldiçoar Arma que você aprendeu com sua trilha.\n\nSe você já possuir esse ritual, o custo dele será reduzido em -1 PE permanentemente.",
            style: TextStyle(color: Colors.white, height: 1.4),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _btnElementoLamina("Sangue", const Color(0xFF990000)),
                _btnElementoLamina(
                  "Morte",
                  Colors.white54,
                ), // Cinza/Branco para não sumir no fundo preto
                _btnElementoLamina("Energia", const Color(0xFF9900FF)),
                _btnElementoLamina("Conhecimento", const Color(0xFFFFB300)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _btnElementoLamina(String elemento, Color cor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: cor,
          foregroundColor: elemento == 'Conhecimento'
              ? Colors.black
              : Colors.white,
        ),
        onPressed: () {
          setState(() {
            String nomeBusca = "Amaldiçoar Arma ($elemento)";
            int indexExistente = rituaisConhecidos.indexWhere(
              (r) => r.nome == nomeBusca,
            );

            if (indexExistente != -1) {
              // ===============================================
              // JÁ POSSUÍA O RITUAL: Ganha a Tag de Desconto!
              // ===============================================
              poderesEscolhidos.add(
                Poder(
                  nome: "Lamina_Desconto_$elemento",
                  tipo: "Sistema",
                  descricao: "",
                ),
              );
            } else {
              // NÃO POSSUÍA O RITUAL: Apenas aprende do Catálogo (sem desconto)
              var rOriginal = catalogoRituais.firstWhere(
                (r) => r.nome == nomeBusca,
                orElse: () => Ritual(
                  nome: nomeBusca,
                  elemento: elemento,
                  circulo: 1,
                  execucao: "Padrão",
                  alcance: "Toque",
                  duracao: "Cena",
                  resistencia: "Nenhuma",
                  descricao: "Amaldiçoa a arma...",
                  custoPE: 1,
                ),
              );

              Ritual novoRitual = Ritual(
                nome: rOriginal.nome,
                elemento: rOriginal.elemento,
                circulo: rOriginal.circulo,
                execucao: rOriginal.execucao,
                alcance: rOriginal.alcance,
                alvoAreaEfeito: rOriginal.alvoAreaEfeito,
                duracao: rOriginal.duracao,
                resistencia: rOriginal.resistencia,
                descricao: rOriginal.descricao,
                custoPE: rOriginal.custoPE,
                custoAdicionalDiscente: rOriginal.custoAdicionalDiscente,
                custoAdicionalVerdadeiro: rOriginal.custoAdicionalVerdadeiro,
                discente: rOriginal.discente,
                verdadeiro: rOriginal.verdadeiro,
              );
              rituaisConhecidos.add(novoRitual);
              rituaisConhecidos.sort((a, b) => a.nome.compareTo(b.nome));
            }

            poderesEscolhidos.add(
              Poder(nome: "Lamina_Setup_10", tipo: "Sistema", descricao: ""),
            );
            atualizarFicha();
          });
          _salvarSilencioso();
          Navigator.pop(context);
          _mostrarNotificacao("Lâmina Maldita ($elemento) configurada!");
        },
        child: Text(
          elemento.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
    );
  }

  // =======================================================
  // POP-UP: SABER AMPLIADO (Aprender Ritual bônus de Círculo)
  // =======================================================
  void _mostrarDialogSaberAmpliado(int circulo, String tagPoder) {
    Ritual? selecionado;
    String filtroElemento = "Todos";
    String busca = "";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            List<Ritual> filtrados = catalogoRituais.where((r) {
              if (r.circulo != circulo) return false;
              if (filtroElemento != "Todos" &&
                  r.elemento.toLowerCase() != filtroElemento.toLowerCase()) {
                return false;
              }
              if (busca.isNotEmpty &&
                  !r.nome.toLowerCase().contains(busca.toLowerCase())) {
                return false;
              }
              // Impede selecionar rituais que o jogador já conheça de cabeça
              if (rituaisConhecidos.any(
                (conhecido) => conhecido.nome == r.nome,
              )) {
                return false;
              }
              return true;
            }).toList();

            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Saber Ampliado",
                    style: TextStyle(
                      color: corDestaque,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Escolha 1 ritual bônus de $circuloº Círculo:",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: EstiloParanormal.customInputDeco(
                        "Buscar...",
                        corDestaque,
                        Icons.search,
                      ),
                      onChanged: (val) => setDialogState(() => busca = val),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            [
                              "Todos",
                              "Sangue",
                              "Morte",
                              "Energia",
                              "Conhecimento",
                            ].map((el) {
                              bool ativo = filtroElemento == el;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(
                                    el,
                                    style: TextStyle(
                                      color: ativo
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                  selected: ativo,
                                  selectedColor: el == "Todos"
                                      ? Colors.white
                                      : _obterCorAfinidade(el),
                                  backgroundColor: Colors.black,
                                  onSelected: (val) {
                                    if (val) {
                                      setDialogState(() => filtroElemento = el);
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtrados.length,
                        itemBuilder: (context, index) {
                          Ritual r = filtrados[index];

                          bool isSelected = selecionado == r;

                          return CardRitualAnimado(
                            ritual: r,
                            corElemento: _obterCorAfinidade(r.elemento),
                            leading: IconButton(
                              icon: Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: isSelected ? corDestaque : Colors.grey,
                              ),
                              onPressed: () {
                                setDialogState(() => selecionado = r);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Obrigatório escolher o ritual!"),
                      ),
                    );
                  },
                  child: const Text(
                    "Pular",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corDestaque,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: selecionado != null
                      ? () {
                          setState(() {
                            rituaisConhecidos.add(selecionado!);
                            rituaisConhecidos.sort(
                              (a, b) => a.nome.compareTo(b.nome),
                            );
                            poderesEscolhidos.add(
                              Poder(
                                nome: tagPoder,
                                tipo: "Sistema",
                                descricao: "",
                              ),
                            );
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
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarDialogEleMeEnsina() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text("Ele Me Ensina", style: TextStyle(color: corDestaque)),
          content: const Text(
            "O paranormal sussurra segredos. Escolha entre Transcender mais uma vez ou aprender o segredo inicial de outra trilha de Ocultista.",
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF222222),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _abrirCatalogoPoderes(filtroInicial: "Poderes Paranormais");
                    setState(
                      () => poderesEscolhidos.add(
                        Poder(
                          nome: "Possuido_Setup_65",
                          tipo: "Sistema",
                          descricao: "",
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "TRANSCENDER",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: corDestaque),
                  onPressed: () {
                    Navigator.pop(context);
                    _mostrarDialogEscolherOutraTrilha();
                  },
                  child: const Text(
                    "APRENDER OUTRA TRILHA",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogEscolherOutraTrilha() {
    // Lista das habilidades de NEX 10% das outras trilhas
    Map<String, String> trilhasExtras = {
      "Conduíte": "Gaste 1 PE para aumentar alcance ou mudar alvo de ritual.",
      "Flagelador": "Pode usar PV no lugar de PE para conjurar rituais.",
      "Graduado":
          "Saber Ampliado: Aprende um ritual adicional de cada círculo.",
      "Intuitivo": "Recebe Resistência Paranormal +5.",
      "Lâmina Paranormal":
          "Aprende Amaldiçoar Arma e usa Ocultismo para atacar.",
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          "Escolha o Conhecimento",
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: trilhasExtras.entries
                .map(
                  (e) => ListTile(
                    title: Text(
                      e.key,
                      style: TextStyle(
                        color: corDestaque,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      e.value,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    onTap: () {
                      setState(() {
                        poderesEscolhidos.add(
                          Poder(
                            nome: "Ele Me Ensina: ${e.key}",
                            tipo: "Trilha Extra",
                            descricao: e.value,
                          ),
                        );
                        poderesEscolhidos.add(
                          Poder(
                            nome: "Possuido_Setup_65",
                            tipo: "Sistema",
                            descricao: "",
                          ),
                        );
                      });
                      Navigator.pop(context);
                      _mostrarNotificacao(
                        "Você aprendeu os segredos do ${e.key}!",
                      );
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  // Adicionar rituais no Grimório (Graduado)
  void _mostrarDialogAdicionarGrimorio(List<int> circulosPermitidos) {
    String filtroElemento = "Todos";
    String filtroCirculo = "Todos";
    String busca = "";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Lógica de filtragem atualizada com o Filtro de Círculos
            List<Ritual> filtrados = catalogoRituais.where((r) {
              if (!circulosPermitidos.contains(r.circulo)) return false;
              if (filtroCirculo != "Todos" &&
                  r.circulo.toString() != filtroCirculo) {
                return false;
              }
              if (filtroElemento != "Todos" &&
                  r.elemento.toLowerCase() != filtroElemento.toLowerCase()) {
                return false;
              }
              if (busca.isNotEmpty &&
                  !r.nome.toLowerCase().contains(busca.toLowerCase())) {
                return false;
              }

              // Bloqueia rituais que já estão na lista de rituais
              if (rituaisGrimorio.any((rg) => rg.nome == r.nome)) return false;
              if (rituaisConhecidos.any((rc) => rc.nome == r.nome)) {
                return false;
              }
              return true;
            }).toList();

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
                    // CABEÇALHO COM BOTÃO FECHAR
                    Row(
                      children: [
                        Icon(Icons.menu_book, color: corDestaque, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          "GRIMÓRIO",
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
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: EstiloParanormal.customInputDeco(
                        "Buscar ritual...",
                        corDestaque,
                        Icons.search,
                      ),
                      onChanged: (val) => setDialogState(() => busca = val),
                    ),
                    const SizedBox(height: 12),

                    // FILTRO DE CÍRCULOS (Só mostra os que a trilha desbloqueou)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            [
                              "Todos",
                              ...circulosPermitidos.map((c) => c.toString()),
                            ].map((circ) {
                              bool ativo = filtroCirculo == circ;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(
                                    circ == "Todos"
                                        ? "Todos Círculos"
                                        : "$circº Círculo",
                                    style: TextStyle(
                                      color: ativo
                                          ? Colors.black
                                          : Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  selected: ativo,
                                  selectedColor: Colors.white,
                                  backgroundColor: Colors.black,
                                  onSelected: (val) {
                                    if (val) {
                                      setDialogState(
                                        () => filtroCirculo = circ,
                                      );
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // FILTRO DE ELEMENTOS
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            [
                              "Todos",
                              "Sangue",
                              "Morte",
                              "Energia",
                              "Conhecimento",
                              "Medo",
                            ].map((el) {
                              bool ativo = filtroElemento == el;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(
                                    el,
                                    style: TextStyle(
                                      color: ativo
                                          ? Colors.black
                                          : Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  selected: ativo,
                                  selectedColor: el == "Todos"
                                      ? Colors.white
                                      : _obterCorAfinidade(el),
                                  backgroundColor: Colors.black,
                                  onSelected: (val) {
                                    if (val) {
                                      setDialogState(() => filtroElemento = el);
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // LISTA DOS RITUAIS
                    Expanded(
                      child: filtrados.isEmpty
                          ? const Center(
                              child: Text(
                                "Nenhum ritual encontrado.",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filtrados.length,
                              itemBuilder: (context, index) {
                                Ritual r = filtrados[index];
                                return CardRitualAnimado(
                                  ritual: r,
                                  corElemento: _obterCorAfinidade(r.elemento),
                                  // O botão '+' ao lado de cada ritual
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.add_circle,
                                      color: corDestaque,
                                    ),
                                    onPressed: () {
                                      // ===========================================
                                      // VERIFICAÇÃO INSTANTÂNEA DOS LIMITES
                                      // ===========================================
                                      int limite1e2 = inte;
                                      int limite3 = nex >= 55 ? 1 : 0;
                                      int limite4 = nex >= 85 ? 1 : 0;

                                      int count1e2 = rituaisGrimorio
                                          .where((rit) => rit.circulo <= 2)
                                          .length;
                                      int count3 = rituaisGrimorio
                                          .where((rit) => rit.circulo == 3)
                                          .length;
                                      int count4 = rituaisGrimorio
                                          .where((rit) => rit.circulo == 4)
                                          .length;

                                      bool canAdd = false;
                                      if (r.circulo <= 2 &&
                                          count1e2 < limite1e2) {
                                        canAdd = true;
                                      } else if (r.circulo == 3 &&
                                          count3 < limite3) {
                                        canAdd = true;
                                      } else if (r.circulo == 4 &&
                                          count4 < limite4) {
                                        canAdd = true;
                                      }

                                      if (canAdd) {
                                        setState(() {
                                          rituaisGrimorio.add(r);
                                          rituaisGrimorio.sort(
                                            (a, b) => a.nome.compareTo(b.nome),
                                          );
                                          atualizarFicha();
                                        });
                                        setDialogState(
                                          () {},
                                        ); // Remove o ritual recém-comprado da lista instantaneamente
                                        _salvarSilencioso();
                                        _mostrarNotificacao(
                                          "${r.nome} escrito!",
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Limite de rituais de ${r.circulo}º Círculo atingido! Aumente seu Intelecto (INT).",
                                            ),
                                            backgroundColor: Colors.redAccent,
                                            duration: const Duration(
                                              seconds: 2,
                                            ),
                                          ),
                                        );
                                      }
                                    },
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
      },
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
            titulo: "Atributos",
            corTema: corFundoAfinidade,
            corTexto: corTextoAfinidade,
            isMorte: afinidadeAtual == 'Morte',
            filhos: [
              // CONTADOR DE ATRIBUTOS
              if (!block) // Só mostra o contador se o modo de edição estiver ativado
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(
                      bottom: 16,
                    ), // Espaçamento antes dos botões
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
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
            titulo: "Ataques",
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

                  // TRILHA: ATIRADOR DE ELITE
                  // Se ele for um Atirador de Elite NEX 10+, cancela a tag de Não Proficiente visualmente
                  if (trilhaAtual == 'atirador_de_elite' &&
                      nex >= 10 &&
                      arma.tipo == 'Fogo') {
                    String descL = arma.descricao.toLowerCase();
                    String nomeL = arma.nome.toLowerCase();
                    if (descL.contains("balas longas") ||
                        nomeL.contains("fuzil") ||
                        nomeL.contains("sniper") ||
                        nomeL.contains("rifle")) {
                      isProficiente = true;
                    }
                  }

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
                  int modMultTrilha = 0;

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

                  // ======== GOLPE DE SORTE ========
                  if (poderesEscolhidos.any(
                    (p) => p.nome.contains("Golpe de Sorte"),
                  )) {
                    modMargemTrilha += 1;
                    if (poderesEscolhidos.any(
                      (p) =>
                          p.nome.contains("Golpe de Sorte") &&
                          p.nome.contains("(Afinidade)"),
                    )) {
                      modMultTrilha += 1;
                    }
                  }

                  int margemExibida =
                      arma.margemAmeacaEfetiva - modMargemTrilha;
                  if (margemExibida < 2) margemExibida = 2;
                  int multExibido = arma.multiplicadorCritico + modMultTrilha;

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
                            "Dano: ${arma.danoEfetivo}$modDano | Crítico: $margemExibida/x$multExibido \nTipo: ${arma.tipo}$alertaProf",
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

          _buildSessaoDados(corDoPainel),

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

          const SizedBox(height: 16),
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
          // EXIBIÇÃO DA ORIGEM
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

          // EXIBIÇÃO DA TRILHA
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
                  ...trilhasOrdem[trilhaAtual]!.habilidades.entries.where((e) => nex >= e.key).map((
                    e,
                  ) {
                    String nomeHab = e.value.keys.first;
                    String descHab = e.value.values.first;

                    // ==========================================
                    // LÓGICA DINÂMICA: TRILHA POSSUÍDO E MONSTRUOSO
                    // ==========================================
                    if (trilhaAtual == 'possuido' && e.key == 99) {
                      if (afinidadeAtual == 'Sangue') {
                        nomeHab = "Tornamo-nos Um (Presente da Obsessão)";
                        descHab =
                            "Uma vez por rodada, você pode gastar 6 PE para recuperar 50 PV. Quando faz isso, até o início do seu próximo turno, os bônus por treinamento em suas perícias baseadas em Força e Vigor, e em Intimidação, mudam para +35. As demais perícias baseadas em Presença mudam para –10. Você pode ativar esse poder mesmo inconsciente.";
                      } else if (afinidadeAtual == 'Morte') {
                        nomeHab = "Tornamo-nos Um (Presente do Tempo)";
                        descHab =
                            "Uma vez por rodada, você pode gastar 6 PE para receber um turno adicional na última contagem de iniciativa da rodada. Você pode ativar essa habilidade mesmo inconsciente.";
                      } else if (afinidadeAtual == 'Conhecimento') {
                        nomeHab = "Tornamo-nos Um (Presente do Saber)";
                        descHab =
                            "Uma vez por cena, você pode gastar 6 PE para reescrever uma fração de seu próprio ser. Você recebe um poder qualquer até o fim da cena. Você deve cumprir os pré-requisitos do poder escolhido, e não pode escolher poderes de trilha de NEX 99%. A cada vez que usa este poder, você deve fazer um teste de Vontade (DT 15 + 5 para cada vez que usou este poder na mesma missão). Se falhar, perde 1d6 pontos de Sanidade para cada vez que usou esse poder nesta missão.";
                      } else if (afinidadeAtual == 'Energia') {
                        nomeHab = "Tornamo-nos Um (Presente do Espaço)";
                        descHab =
                            "Uma vez por rodada, você pode gastar 6 PE para se teletransportar para outro ponto em alcance médio. Você não precisa conhecer o local para onde vai nem precisa vê-lo, mas se teletransportar-se para um espaço ocupado vai ser arremessado para o espaço disponível mais próximo.";
                      } else {
                        descHab =
                            "Desabrochando em seu interior, o paranormal se manifesta como uma dádiva poderosa. Baseado no elemento com que tem afinidade, você recebe um poder especial (Escolha sua Afinidade Elemental primeiro).";
                      }
                    }

                    if (trilhaAtual == 'monstruoso') {
                      if (e.key == 10) {
                        if (afinidadeAtual == 'Sangue') {
                          descHab =
                              "Suas presas ficam protuberantes e seus olhos se tornam vermelhos. Você recebe resistência a balístico e Sangue 5 e faro e, quando faz um contra-ataque bem-sucedido, soma seu Vigor na rolagem de dano, mas sofre –1d20 em Ciências e Intuição.\n\nLembre-se: Uma vez por dia, beba sangue humano ou sofrerá de fome e sede.";
                        } else if (afinidadeAtual == 'Morte') {
                          descHab =
                              "Você fica pálido e seu metabolismo se torna bem mais lento. Você recebe resistência a perfuração e Morte 5 e imunidade a fadiga e soma sua Força em seu total de pontos de vida, mas sofre –1d20 em Diplomacia e Enganação.\n\nLembre-se: Uma vez por dia, inale cinzas de mortos ou sofrerá de fome e sede.";
                        } else if (afinidadeAtual == 'Conhecimento') {
                          descHab =
                              "Seus olhos são banhados em um dourado sobrenatural. Você recebe resistência a balístico e Conhecimento 5 e visão no escuro e soma seu Intelecto na Defesa, mas sofre –1d20 em Atletismo e Acrobacia.\n\nLembre-se: Uma vez por dia, tatue palavras que causam medo ou sofrerá de fome e sede.";
                        } else if (afinidadeAtual == 'Energia') {
                          descHab =
                              "Sua pele ganha cicatrizes de queimaduras elétricas com múltiplas cores. Você recebe resistência a corte, eletricidade, fogo e Energia 5 e soma sua Agilidade na RD recebida por um bloqueio bem-sucedido, mas sofre –1d20 em Investigação e Percepção.\n\nLembre-se: Uma vez por dia, receba choques de cabos elétricos ou sofrerá de fome e sede.";
                        } else {
                          descHab =
                              "Em suas veias corre uma maldição paranormal que aos poucos o está transformando em um monstro. Você se torna treinado em Ocultismo (se já for treinado, recebe +2). Escolha seu Elemento Parasita no botão acima.";
                        }
                      } else if (e.key == 40) {
                        if (afinidadeAtual == 'Sangue') {
                          descHab =
                              "A RD recebida aumenta para 10, e a penalidade para -2d20. Você veste poucas roupas, expondo o máximo de pele. Seu corpo está repleto de cicatrizes. Devorar qualquer coisa que não seja carne/sangue não contém sua fome.\n\nVocê pode usar FOR para calcular PEs. Pode gastar ação de movimento e 1+ PE (limitado a FOR) para recuperar 1d8 PV por PE gasto.";
                        } else if (afinidadeAtual == 'Morte') {
                          descHab =
                              "A RD recebida aumenta para 10, e a penalidade para -2d20. Roupas modernas não fazem sentido; você usa trajes anacrônicos adornados com itens mortos. Você não precisa mais comer ou beber (mas ainda sofre a fome paranormal).\n\nVocê recebe +1d20 em Intimidação e usa VIG para calcular PEs. Você morre apenas após iniciar 4 turnos morrendo na mesma cena.";
                        } else if (afinidadeAtual == 'Conhecimento') {
                          descHab =
                              "A RD recebida aumenta para 10, e a penalidade para -2d20. Você veste joias de ouro puro; seu corpo está coberto de palavras evocando o medo. Você sabe que é superior a todos.\n\nSeu INT aumenta em +1. Você pode usar INT como atributo-chave para Enganação e para calcular PEs.";
                        } else if (afinidadeAtual == 'Energia') {
                          descHab =
                              "A RD recebida aumenta para 10, e a penalidade para -2d20. Você veste roupas complexas com luzes e dispositivos que dão choques.\n\nVocê pode usar AGI para calcular PEs. Ao acertar um ataque corpo a corpo, gaste 1+ PE (limitado a AGI) para causar +1d6 dano de Energia por PE gasto.";
                        } else {
                          descHab =
                              "Conforme sua humanidade é substituída pela Entidade, as mudanças em seu corpo e mente se intensificam. As resistências aumentam para 10, as penalidades para -2d20, e você ganha o efeito adicional do seu elemento.";
                        }
                      } else if (e.key == 65) {
                        if (afinidadeAtual == 'Sangue') {
                          descHab =
                              "Sua RD aumenta para 15. Sua PRE é reduzida permanentemente em 1. Você dilacerou seus órgãos para sentir tudo com total intensidade. A palavra 'não' perdeu o sentido.\n\nVocê tem 50% de chance de ignorar bônus de acerto crítico/furtivo inimigo. Recebe mordida (1d8, 19/x2, Perf). Uma vez por rodada ao agredir com outra arma, gaste 1 PE para atacar com a mordida.";
                        } else if (afinidadeAtual == 'Morte') {
                          descHab =
                              "Sua RD aumenta para 15. Sua PRE é reduzida permanentemente em 1. Lodo preto faz parte do seu consumo, perante a Morte, todas as coisas são iguais.\n\nInício de turno morrendo: Teste VIG (DT 15) acorda com 1 PV. Acertos críticos ou abates recuperam 2 PE.";
                        } else if (afinidadeAtual == 'Conhecimento') {
                          descHab =
                              "Sua RD aumenta para 15. Sua PRE é reduzida permanentemente em 1. Você injeta ouro líquido; registros metódicos são sua rotina.\n\nVocê pode abrir mão de treino em 1 perícia para ganhar dados de bônus igual a INT. Gaste 1 bônus para +1d20 em qualquer teste (até fim da cena). Perícia retorna no interlúdio.";
                        } else if (afinidadeAtual == 'Energia') {
                          descHab =
                              "Sua RD aumenta para 15. Sua PRE é reduzida permanentemente em 1. Os choques aumentam e gotejam ácido. Você inala alucinógenos por uma máscara.\n\nSua RD agora afeta dano Químico. Ação de mov ao tocar fontes elétricas para curar PE (1d4 portátil, 2d4 grande, 4d4 casa). Esgota a fonte irremediavelmente.";
                        } else {
                          descHab =
                              "Sua RD aumenta para 15, e sua Presença é reduzida em 1. Você recebe o efeito passivo especial do elemento parasita.";
                        }
                      } else if (e.key == 99) {
                        if (afinidadeAtual == 'Sangue') {
                          descHab =
                              "Efeitos viram permanentes (mas você ainda sofre a fome). Considerado Criatura Paranormal. RD sobe para 20.\n\nVocê é bestial. INT diminui em -1, FOR aumenta em +1. Dano com mordida cura 5 PV. Aprende o ritual 'Forma Monstruosa'. Ao sofrer dano: Vontade (DT 10 + dano) ou sua próxima ação DEVE ser conjurar a Forma (se falhar e não puder, perde a ação).";
                        } else if (afinidadeAtual == 'Morte') {
                          descHab =
                              "Efeitos viram permanentes (mas você ainda sofre a fome). Considerado Criatura Paranormal. RD sobe para 20.\n\nVocê é um cadáver. PRE diminui em -1, VIG aumenta em +1. Imune a dano de Morte e Imortal (restaurado no dia seguinte pelo Lodo). Fogo/Energia anulam imortalidade. Aprende o ritual 'Fim Inevitável'.";
                        } else if (afinidadeAtual == 'Conhecimento') {
                          descHab =
                              "Efeitos viram permanentes (mas você ainda sofre a fome). Considerado Criatura Paranormal. RD sobe para 20.\n\nBoca costurada, olhos esclera negra. FOR diminui em -1, INT aumenta em +1. Ganha Percepção às Cegas. Aprende um ritual de Conhecimento de 4º Círculo. Ao conjurá-lo, perde a memória de tudo vivenciado na cena.";
                        } else if (afinidadeAtual == 'Energia') {
                          descHab =
                              "Efeitos viram permanentes (mas você ainda sofre a fome). Considerado Criatura Paranormal. RD sobe para 20.\n\nForma plasmática. Flutua acima do chão. FOR diminui em -1, AGI aumenta em +1. Ignora terreno difícil, imune a queda, passa em frestas minúsculas e é imune a condições paralisantes físicas. Aprende o ritual 'Deflagração de Energia'. Não usa itens vestidos e só manipula coisas pela mente (uma de cada vez, tamanho de 2 mãos).";
                        } else {
                          descHab =
                              "O habitat perfeito para a Entidade. RD 20, vira criatura paranormal e seus atributos mudam irreversivelmente.";
                        }
                      }
                    }

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

          // EXIBIÇÃO DA RESERVA PARANORMAL (POSSUÍDO)
          if (trilhaAtual == 'possuido' && nex >= 10)
            SecaoFicha(
              titulo: "Reserva Paranormal",
              corTema: corFundoAfinidade,
              corTexto: corTextoAfinidade,
              isMorte: afinidadeAtual == 'Morte',
              filhos: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "PONTOS DE POSSESSÃO (PP)",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: corDestaque.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: corDestaque.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        "GASTO MÁX: $efPre PP",
                        style: TextStyle(
                          color: corDestaque,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0D0D),
                    border: Border.all(color: Colors.grey.shade800),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Reserva Atual",
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.white70,
                            ),
                            onPressed: () => setState(() {
                              if (ppAtual > 0) ppAtual--;
                              _salvarSilencioso();
                            }),
                          ),
                          Text(
                            "$ppAtual / $ppMax",
                            style: TextStyle(
                              color: corDestaque,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Colors.white70,
                            ),
                            onPressed: () => setState(() {
                              if (ppAtual < ppMax) ppAtual++;
                              _salvarSilencioso();
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

          // EXIBIÇÃO DA LISTA DE PODERES
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
                      onPressed: () {
                        // Trava o filtro para Possuídos abrirem direto nos paranormais
                        if (trilhaAtual == 'possuido') {
                          _abrirCatalogoPoderes(
                            filtroInicial: "Poderes Paranormais",
                          );
                        } else {
                          _abrirCatalogoPoderes();
                        }
                      },
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

                        if (block &&
                            p.nome.contains("Arma de Sangue") &&
                            armaDeSangueAtiva) {
                          bool temAfinidadeArma = poderesEscolhidos.any(
                            (pe) =>
                                pe.nome.contains("Arma de Sangue") &&
                                pe.nome.contains("(Afinidade)"),
                          );
                          if (temAfinidadeArma) {
                            return const Icon(
                              Icons.check_circle,
                              color: Colors.redAccent,
                              size: 24,
                            );
                          }

                          return Switch(
                            value: armaDeSangueAtiva,
                            activeThumbColor: Colors.redAccent,
                            onChanged: (val) {
                              if (!val) {
                                setState(() {
                                  armaDeSangueAtiva = false;
                                  armas.removeWhere(
                                    (a) => a.nome == "Arma de Sangue",
                                  );
                                  atualizarFicha();
                                });
                                _salvarSilencioso();
                                _mostrarNotificacao("Arma de Sangue desfeita.");
                              }
                            },
                          );
                        }

                        if (block && p.nome.contains("Encarar a Morte")) {
                          return Switch(
                            value: encararAMorteAtivo,
                            activeThumbColor: Colors.white,
                            onChanged: (val) {
                              setState(() {
                                encararAMorteAtivo = val;
                                atualizarFicha();
                              });
                            },
                          );
                        }

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
                              setState(() {
                                poderesEscolhidos.removeAt(index);
                                if (p.nome.contains("Arma de Sangue")) {
                                  armaDeSangueAtiva = false;
                                  armas.removeWhere(
                                    (a) => a.nome == "Arma de Sangue",
                                  );
                                }
                              });
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

          // 3. EXIBIÇÃO DA AFINIDADE ELEMENTAL
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

// CARD DE RITUAL (COM ANIMAÇÃO DE MEDO)
class CardRitualAnimado extends StatefulWidget {
  final Ritual ritual;
  final Color corElemento;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onConjurar;

  const CardRitualAnimado({
    super.key,
    required this.ritual,
    required this.corElemento,
    this.trailing,
    this.leading,
    this.onConjurar,
  });

  @override
  State<CardRitualAnimado> createState() => _CardRitualAnimadoState();
}

class _CardRitualAnimadoState extends State<CardRitualAnimado>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    // Configura a velocidade da pulsação da aura
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Configura o tamanho mínimo e máximo do brilho
    _glowAnimation = Tween<double>(
      begin: 2.0,
      end: 12.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isMedo = widget.ritual.elemento.toLowerCase() == 'medo';

    // Inversão de Cores se for Medo
    Color corFundo = isMedo
        ? const Color.fromARGB(255, 223, 223, 223)
        : const Color(0xFF0D0D0D);
    Color corTextoPrincipal = isMedo ? Colors.black : Colors.white;
    Color corTextoSecundario = isMedo ? Colors.black87 : Colors.grey;
    Color corDivisoria = isMedo ? Colors.black26 : Colors.grey.shade900;

    // Tenta ler o alvoAreaEfeito ou alvo (para compatibilidade com sua classe Ritual)
    String alvoTexto = "";
    try {
      alvoTexto =
          (widget.ritual as dynamic).alvoAreaEfeito ??
          (widget.ritual as dynamic).alvo ??
          "";
    } catch (e) {
      alvoTexto = "";
    }

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: corFundo,
            borderRadius: BorderRadius.circular(8),
            border: isMedo
                ? null
                : Border.all(color: widget.corElemento, width: 1.5),
            boxShadow: isMedo
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.8),
                      blurRadius: _glowAnimation.value,
                      spreadRadius: _glowAnimation.value / 2,
                    ),
                  ]
                : [],
          ),
          child: child,
        );
      },
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: widget.leading,
          trailing: widget.trailing,
          iconColor: corTextoPrincipal,
          collapsedIconColor: corTextoSecundario,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

          // TÍTULO DOS RITUAIS
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      (isMedo
                              ? const Color.fromARGB(136, 255, 255, 255)
                              : widget.corElemento)
                          .withValues(alpha: 0.1),
                  border: Border.all(
                    color: isMedo
                        ? const Color.fromARGB(136, 0, 0, 0)
                        : widget.corElemento,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.ritual.elemento.toUpperCase(),
                  style: TextStyle(
                    color: isMedo ? Colors.black87 : widget.corElemento,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                widget.ritual.nome,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: corTextoPrincipal,
                  fontSize: 15,
                  height: 1.2,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ],
          ),

          // SUBTÍTULO COM INFORMAÇÕES RÁPIDAS
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              "${widget.ritual.circulo}º Círculo • ${widget.ritual.execucao} • ${widget.ritual.alcance}",
              style: TextStyle(
                color: isMedo
                    ? Colors.black54
                    : const Color.fromARGB(255, 255, 255, 255),
                fontSize: 11,
              ),
            ),
          ),

          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: corDivisoria, thickness: 1),
                  const SizedBox(height: 8),

                  // ==========================================
                  // INFORMAÇÕES TÉCNICAS COMPLETAS
                  // ==========================================
                  Text(
                    "Círculo: ${widget.ritual.circulo}º | Execução: ${widget.ritual.execucao}\nAlcance: ${widget.ritual.alcance} | Alvo: $alvoTexto\nDuração: ${widget.ritual.duracao}",
                    style: TextStyle(color: corTextoSecundario, fontSize: 12),
                  ),
                  if (widget.ritual.resistencia.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      "Resistência: ${widget.ritual.resistencia}",
                      style: TextStyle(
                        color: corTextoPrincipal,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // ==========================================
                  // DESCRIÇÃO DO RITUAL
                  // ==========================================
                  Text(
                    widget.ritual.descricao,
                    style: TextStyle(
                      color: corTextoPrincipal,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),

                  // ==========================================
                  // O BOTÃO DE CONJURAR
                  // ==========================================
                  if (widget.onConjurar != null) ...[
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isMedo
                              ? Colors.black
                              : const Color.fromARGB(255, 255, 255, 255),
                          foregroundColor: isMedo ? Colors.white : Colors.black,
                        ),
                        icon: const Icon(Icons.auto_awesome, size: 18),
                        label: const Text(
                          "CONJURAR",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: widget.onConjurar,
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
  }
}
