import '../dados/rituais.dart';

class Pericia {
  final String nome, id;
  String atributo;
  int treino;
  bool daOrigem;
  Pericia({
    required this.nome,
    required this.atributo,
    required this.id,
    this.treino = 0,
    this.daOrigem = false,
  });
}

class ItemInventario {
  String nome;
  String categoria;
  double espaco;
  int bonusCarga;
  String descricao;
  List<String> modificacoes;
  bool equipado;
  String periciaVinculada;
  String tipo; 
  int defesa;
  int bonusPericia;

  ItemInventario({
    required this.nome,
    required this.categoria,
    required this.espaco,
    required this.descricao,
    this.bonusCarga = 0,
    this.modificacoes = const [],
    this.equipado = false,
    this.periciaVinculada = "",
    this.tipo = "Geral",
    this.defesa = 0,
    this.bonusPericia = 0,
  });

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'categoria': categoria,
        'espaco': espaco,
        'descricao': descricao,
        'bonusCarga': bonusCarga,
        'modificacoes': modificacoes,
        'equipado': equipado,
        'periciaVinculada': periciaVinculada,
        'tipo': tipo,
        'defesa': defesa,
        'bonusPericia': bonusPericia,
      };

  factory ItemInventario.fromJson(Map<String, dynamic> json) {
    return ItemInventario(
      nome: json['nome'] ?? '',
      categoria: json['categoria'] ?? '0',
      espaco: (json['espaco'] ?? 0).toDouble(),
      descricao: json['descricao'] ?? '',
      bonusCarga: json['bonusCarga'] ?? 0,
      modificacoes: List<String>.from(json['modificacoes'] ?? []),
      equipado: json['equipado'] ?? false,
      periciaVinculada: json['periciaVinculada'] ?? "",
      tipo: json['tipo'] ?? "Geral", 
      defesa: json['defesa'] ?? 0,
      bonusPericia: json['bonusPericia'] ?? 0,
    );
  }
  
  double get espacoEfetivo {
    double e = espaco;
    if (modificacoes.contains("Leve") || modificacoes.contains("Discreta") || modificacoes.contains("Discreto")) {
      e -= 1.0;
    }
    // Se o usuário digitou um número negativo de propósito, o app respeita!
    // Mas se o item era positivo e as modificações zeraram ele, ele trava no 0.
    if (espaco >= 0 && e < 0) return 0;
    
    return e;
  }
}

class Arma extends ItemInventario {
  // 'tipo' removido daqui, pois ele já existe em ItemInventario (o pai)
  String dano;
  int margemAmeaca;
  int multiplicadorCritico;
  String proficiencia;
  String empunhadura;
  String atributoPersonalizado;
  String periciaPersonalizada;

  Arma({
    required super.nome,
    required super.tipo, // Passamos isso para o super
    required this.dano,
    this.margemAmeaca = 20,
    this.multiplicadorCritico = 2,
    required super.categoria,
    required super.espaco,
    required this.proficiencia,
    required this.empunhadura,
    required super.descricao,
    super.modificacoes,
    super.equipado,
    this.atributoPersonalizado = '',
    this.periciaPersonalizada = '',
  });

  // Removi o @override de 'categoriaEfetiva' porque essa variável não existe em ItemInventario.
  // Ela é exclusiva da Arma, então apenas 'get' é suficiente.
  String get categoriaEfetiva {
    int qtdMods = modificacoes
        .where(
          (mod) =>
              !mod.contains("Ferramenta de Trabalho") &&
              !mod.contains("Arma Favorita"),
        )
        .length;

    if (qtdMods == 0) return categoria;

    List<String> niveis = ["0", "I", "II", "III", "IV", "V", "VI", "VII"];
    int indexAtual = niveis.indexOf(categoria.trim());

    if (indexAtual == -1) return categoria;

    int novoIndex = indexAtual + qtdMods;
    if (novoIndex >= niveis.length) return niveis.last;

    return niveis[novoIndex];
  }

  @override
  double get espacoEfetivo {
    double e = espaco;
    if (modificacoes.contains("Discreta") ||
        modificacoes.contains("Discreto")) {
      e -= 1.0;
    }
    if (espaco >= 0 && e < 0) return 0;
    return e;
  }

  // Matemática do dano
  String get danoEfetivo {
    if (!modificacoes.contains("Calibre Grosso") &&
        !modificacoes.contains("Cruel") &&
        !modificacoes.contains("Ferramenta de Trabalho")) {
      return dano;
    }

    String d = dano.replaceAll(' ', '');
    int dados = 1;
    String resto = "";
    int flat = 0;
    bool parseSuccess = false;

    try {
      if (d.contains('d')) {
        var parts = d.split('d');
        dados = int.tryParse(parts[0]) ?? 1;

        if (parts[1].contains('+')) {
          var sub = parts[1].split('+');
          resto = "d${sub[0]}";
          flat = int.tryParse(sub[1]) ?? 0;
        } else if (parts[1].contains('-')) {
          var sub = parts[1].split('-');
          resto = "d${sub[0]}";
          flat = -(int.tryParse(sub[1]) ?? 0);
        } else {
          resto = "d${parts[1]}";
        }
        parseSuccess = true;
      }
    } catch (e) {
      parseSuccess = false;
    }

    if (!parseSuccess) {
      String res = dano;
      if (modificacoes.contains("Calibre Grosso")) res += " (+1 dado)";
      if (modificacoes.contains("Cruel")) res += " (+2 dano)";
      if (modificacoes.contains("Ferramenta de Trabalho")) res += " (+1 dano)";
      return res;
    }

    if (modificacoes.contains("Calibre Grosso")) dados += 1;
    if (modificacoes.contains("Cruel")) flat += 2;
    if (modificacoes.contains("Ferramenta de Trabalho")) {
      flat += 1; // Bônus do Operário
    }

    String result = "$dados$resto";
    if (flat > 0) {
      result += "+$flat";
    } else if (flat < 0) {
      result += "$flat";
    }

    return result;
  }

  // Cálculo da margem
  int get margemAmeacaEfetiva {
    int m = margemAmeaca;
    if (modificacoes.contains("Perigosa") ||
        modificacoes.contains("Mira Laser")) {
      m -= 2;
    }
    if (modificacoes.contains("Ferramenta de Trabalho")) {
      m -= 1; // Bônus do Operário
    }
    if (m < 2) return 2;
    return m;
  }

  @override
  Map<String, dynamic> toJson() {
    var map = super.toJson();
    map.addAll({
      // Removido o 'tipo' daqui porque o super.toJson() já salvou ele!
      'dano': dano,
      'margemAmeaca': margemAmeaca,
      'multiplicadorCritico': multiplicadorCritico,
      'proficiencia': proficiencia,
      'empunhadura': empunhadura,
      'atributoPersonalizado': atributoPersonalizado,
      'periciaPersonalizada': periciaPersonalizada,
    });
    return map;
  }

  factory Arma.fromJson(Map<String, dynamic> json) {
    return Arma(
      nome: json['nome'] ?? '',
      tipo: json['tipo'] ?? 'Corpo a Corpo', // Lê o tipo
      dano: json['dano'] ?? '1d4',
      margemAmeaca: json['margemAmeaca'] ?? 20,
      multiplicadorCritico: json['multiplicadorCritico'] ?? 2,
      categoria: json['categoria'] ?? '0',
      espaco: (json['espaco'] ?? 1).toDouble(),
      proficiencia: json['proficiencia'] ?? 'Simples',
      empunhadura: json['empunhadura'] ?? 'Leve',
      descricao: json['descricao'] ?? '',
      modificacoes: List<String>.from(json['modificacoes'] ?? []),
      equipado: json['equipado'] ?? false,
      atributoPersonalizado: json['atributoPersonalizado'] ?? '',
      periciaPersonalizada: json['periciaPersonalizada'] ?? '',
    );
  }
}

class Poder {
  final String nome;
  final String tipo;
  final String descricao;
  final String preRequisitos;
  final int custoPE;

  Poder({
    required this.nome,
    required this.tipo,
    required this.descricao,
    this.preRequisitos = "Nenhum",
    this.custoPE = 0,
  });

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'tipo': tipo,
    'descricao': descricao,
    'preRequisitos': preRequisitos,
    'custoPE': custoPE,
  };

  factory Poder.fromJson(Map<String, dynamic> json) => Poder(
    nome: json['nome'] ?? '',
    tipo: json['tipo'] ?? '',
    descricao: json['descricao'] ?? '',
    preRequisitos: json['preRequisitos'] ?? 'Nenhum',
    custoPE: json['custoPE'] ?? 0,
  );
}

class AgenteDados {
  String nome, classe, origem, trilha;
  String? fotoPath;
  String? afinidade;
  int nex, prestigio, agi, forc, inte, pre, vig;
  int? pvAtual, peAtual, sanAtual;
  Map<String, int> pericias;
  List<ItemInventario> inventario;
  List<Arma> armas;

  List<Poder> poderes;

  final List<Ritual> rituais;

  List<String> periciasClasse;

  // Informações de backstory (Lore)
  String idade;
  String genero;
  String nacionalidade;
  String aparencia;
  String historico;
  String objetivo;
  String extra;

  AgenteDados({
    required this.nome,
    required this.classe,
    required this.origem,
    this.trilha = '--',
    this.fotoPath,
    this.afinidade,
    required this.nex,
    this.prestigio = 0,
    required this.agi,
    required this.forc,
    required this.inte,
    required this.pre,
    required this.vig,
    this.pvAtual,
    this.peAtual,
    this.sanAtual,
    required this.pericias,
    required this.inventario,
    required this.armas,
    this.poderes = const [],
    this.rituais = const [],
    this.periciasClasse = const [],
    this.idade = "",
    this.genero = "",
    this.nacionalidade = "",
    this.aparencia = "",
    this.historico = "",
    this.objetivo = "",
    this.extra = "",
  });

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'classe': classe,
    'origem': origem,
    'trilha': trilha,
    'fotoPath': fotoPath,
    'afinidade': afinidade,
    'nex': nex,
    'prestigio': prestigio,
    'agi': agi,
    'forc': forc,
    'inte': inte,
    'pre': pre,
    'vig': vig,
    'pvAtual': pvAtual,
    'peAtual': peAtual,
    'sanAtual': sanAtual,
    'pericias': pericias,
    'inventario': inventario.map((i) => i.toJson()).toList(),
    'armas': armas.map((a) => a.toJson()).toList(),

    'poderes': poderes.map((p) => p.toJson()).toList(),

    'rituais': rituais.map((e) => e.toJson()).toList(),

    'periciasClasse': periciasClasse,

    // Novas variáveis da Lore
    'idade': idade,
    'genero': genero,
    'nacionalidade': nacionalidade,
    'aparencia': aparencia,
    'historico': historico,
    'objetivo': objetivo,
    'extra': extra,
  };

  factory AgenteDados.fromJson(Map<String, dynamic> json) => AgenteDados(
    nome: json['nome']?.toString() ?? 'Desconhecido',
    classe: json['classe']?.toString() ?? '--',
    origem: json['origem']?.toString() ?? '--',
    trilha: json['trilha']?.toString() ?? '--',
    fotoPath: json['fotoPath']?.toString(),
    afinidade: json['afinidade']?.toString(),
    nex: json['nex'] != null ? (json['nex'] as num).toInt() : 5,
    prestigio: json['prestigio'] != null
        ? (json['prestigio'] as num).toInt()
        : 0,
    agi: json['agi'] != null ? (json['agi'] as num).toInt() : 1,
    forc: json['forc'] != null ? (json['forc'] as num).toInt() : 1,
    inte: json['inte'] != null ? (json['inte'] as num).toInt() : 1,
    pre: json['pre'] != null ? (json['pre'] as num).toInt() : 1,
    vig: json['vig'] != null ? (json['vig'] as num).toInt() : 1,
    pvAtual: json['pvAtual'] != null ? (json['pvAtual'] as num).toInt() : null,
    peAtual: json['peAtual'] != null ? (json['peAtual'] as num).toInt() : null,
    sanAtual: json['sanAtual'] != null
        ? (json['sanAtual'] as num).toInt()
        : null,
    pericias: json['pericias'] != null
        ? Map<String, int>.from(json['pericias'])
        : <String, int>{},
    inventario: json['inventario'] != null
        ? (json['inventario'] as List)
              .map((i) => ItemInventario.fromJson(i))
              .toList()
        : <ItemInventario>[],
    armas: json['armas'] != null
        ? (json['armas'] as List).map((a) => Arma.fromJson(a)).toList()
        : <Arma>[],
    poderes: json['poderes'] != null
        ? (json['poderes'] as List).map((p) {
            if (p is Map<String, dynamic>) {
              return Poder.fromJson(p);
            } else if (p is String) {
              return Poder(
                nome: p,
                tipo: "Legado",
                descricao: "Poder antigo. Re-adicione para ver o custo.",
              );
            }
            return Poder(nome: "Erro", tipo: "Erro", descricao: "");
          }).toList()
        : <Poder>[],

    rituais: json['rituais'] != null
        ? (json['rituais'] as List).map((i) => Ritual.fromJson(i)).toList()
        : [],

    periciasClasse: json['periciasClasse'] is List
        ? List<String>.from(json['periciasClasse'])
        : <String>[],

    // Instanciação das novas variáveis de Lore
    idade: json['idade']?.toString() ?? "",
    genero: json['genero']?.toString() ?? "",
    nacionalidade: json['nacionalidade']?.toString() ?? "",
    aparencia: json['aparencia']?.toString() ?? "",
    historico: json['historico']?.toString() ?? "",
    objetivo: json['objetivo']?.toString() ?? "",
    extra: json['extra']?.toString() ?? "",
  );
}
