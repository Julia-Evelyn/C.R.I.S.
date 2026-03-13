class Pericia {
  final String nome, atributo, id;
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
  String nome, categoria, descricao;
  double espaco;
  List<String> modificacoes;
  bool equipado; // NOVO: Sistema de Equipar

  ItemInventario({
    required this.nome,
    required this.categoria,
    required this.espaco,
    this.descricao = "",
    this.modificacoes = const [],
    this.equipado = false,
  });

  String get categoriaEfetiva {
    int c = 0;
    if (categoria == 'I') {
      c = 1;
    } else if (categoria == 'II') {
      c = 2;
    } else if (categoria == 'III') {
      c = 3;
    } else if (categoria == 'IV') {
      c = 4;
    }
    c += modificacoes.length;
    if (c >= 4) return 'IV';
    if (c == 3) return 'III';
    if (c == 2) return 'II';
    if (c == 1) return 'I';
    return '0';
  }

  double get espacoEfetivo => espaco;

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'categoria': categoria,
    'espaco': espaco,
    'descricao': descricao,
    'modificacoes': modificacoes,
    'equipado': equipado,
  };

  factory ItemInventario.fromJson(Map<String, dynamic> json) => ItemInventario(
    nome: json['nome'],
    categoria: json['categoria'],
    espaco: json['espaco'] != null ? (json['espaco'] as num).toDouble() : 1.0,
    descricao: json['descricao'] ?? "",
    modificacoes: json['modificacoes'] != null
        ? List<String>.from(json['modificacoes'])
        : <String>[],
    equipado: json['equipado'] ?? false, // Se não existir no save, começa falso
  );
}

class Arma {
  String nome, dano, tipo, categoria;
  int margemAmeaca, multiplicadorCritico;
  double espaco;
  List<String> modificacoes;
  bool equipado; // NOVO: Sistema de Equipar

  Arma({
    required this.nome,
    required this.dano,
    this.tipo = 'Corpo a Corpo',
    this.margemAmeaca = 20,
    this.multiplicadorCritico = 2,
    this.categoria = '0',
    this.espaco = 1.0,
    this.modificacoes = const [],
    this.equipado = false,
  });

  String get categoriaEfetiva {
    int c = 0;
    if (categoria == 'I') {
      c = 1;
    } else if (categoria == 'II') {
      c = 2;
    } else if (categoria == 'III') {
      c = 3;
    } else if (categoria == 'IV') {
      c = 4;
    }
    c += modificacoes.length;
    if (c >= 4) return 'IV';
    if (c == 3) return 'III';
    if (c == 2) return 'II';
    if (c == 1) return 'I';
    return '0';
  }

  double get espacoEfetivo {
    double e = espaco;
    if (modificacoes.contains("Discreta")) e -= 1.0;
    return e < 0 ? 0 : e;
  }

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'dano': dano,
    'tipo': tipo,
    'margem': margemAmeaca,
    'mult': multiplicadorCritico,
    'categoria': categoria,
    'espaco': espaco,
    'modificacoes': modificacoes,
    'equipado': equipado,
  };

  factory Arma.fromJson(Map<String, dynamic> json) => Arma(
    nome: json['nome'],
    dano: json['dano'],
    tipo: json['tipo'] ?? 'Corpo a Corpo',
    margemAmeaca: json['margem'] ?? 20,
    multiplicadorCritico: json['mult'] ?? 2,
    categoria: json['categoria'] ?? '0',
    espaco: json['espaco'] != null ? (json['espaco'] as num).toDouble() : 1.0,
    modificacoes: json['modificacoes'] != null
        ? List<String>.from(json['modificacoes'])
        : <String>[],
    equipado:
        json['equipado'] ??
        true, // Armas antigas já carregam equipadas para não sumirem
  );
}

class AgenteDados {
  String nome, classe, origem;
  String? fotoPath;
  String? afinidade;
  int nex, prestigio, agi, forc, inte, pre, vig;
  int? pvAtual, peAtual, sanAtual;
  Map<String, int> pericias;
  List<ItemInventario> inventario;
  List<Arma> armas;

  AgenteDados({
    required this.nome,
    required this.classe,
    required this.origem,
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
  });

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'classe': classe,
    'origem': origem,
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
  };

  factory AgenteDados.fromJson(Map<String, dynamic> json) => AgenteDados(
    nome: json['nome'] ?? 'Desconhecido',
    classe: json['classe'] ?? 'combatente',
    origem: json['origem'] ?? 'academico',
    fotoPath: json['fotoPath'],
    afinidade: json['afinidade'],
    nex: json['nex'] ?? 5,
    prestigio: json['prestigio'] ?? 0,
    agi: json['agi'] ?? 1,
    forc: json['forc'] ?? 1,
    inte: json['inte'] ?? 1,
    pre: json['pre'] ?? 1,
    vig: json['vig'] ?? 1,
    pvAtual: json['pvAtual'],
    peAtual: json['peAtual'],
    sanAtual: json['sanAtual'],
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
  );
}
