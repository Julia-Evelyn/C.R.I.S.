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
  bool equipado;
  String? periciaVinculada;

  ItemInventario({
    required this.nome,
    required this.categoria,
    required this.espaco,
    this.descricao = "",
    this.modificacoes = const [],
    this.equipado = false,
    this.periciaVinculada,
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
    if (modificacoes.contains("Blindada")) e += 1.0;
    if (modificacoes.contains("Reforçada")) e += 1.0;
    return e < 0 ? 0 : e;
  }

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'categoria': categoria,
    'espaco': espaco,
    'descricao': descricao,
    'modificacoes': modificacoes,
    'equipado': equipado,
    'periciaVinculada': periciaVinculada,
  };

  factory ItemInventario.fromJson(Map<String, dynamic> json) {
    return ItemInventario(
      nome: json['nome']?.toString() ?? 'Item Desconhecido',
      categoria: json['categoria']?.toString() ?? '0',
      espaco: json['espaco'] != null ? (json['espaco'] as num).toDouble() : 1.0,
      descricao: json['descricao']?.toString() ?? "",
      modificacoes: json['modificacoes'] is List
          ? List<String>.from(json['modificacoes'])
          : <String>[],
      equipado: json['equipado'] == true,
      periciaVinculada: json['periciaVinculada']?.toString(),
    );
  }
}

class Arma {
  String nome, dano, tipo, categoria;
  int margemAmeaca, multiplicadorCritico;
  double espaco;
  List<String> modificacoes;
  bool equipado;
  String proficiencia;
  String empunhadura;

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
    this.proficiencia = 'Simples',
    this.empunhadura = 'Uma Mão',
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
    'proficiencia': proficiencia,
    'empunhadura': empunhadura,
  };

  factory Arma.fromJson(Map<String, dynamic> json) {
    return Arma(
      nome: json['nome']?.toString() ?? 'Arma Desconhecida',
      dano: json['dano']?.toString() ?? '1d4',
      tipo: json['tipo']?.toString() ?? 'Corpo a Corpo',
      margemAmeaca: json['margem'] != null
          ? (json['margem'] as num).toInt()
          : 20,
      multiplicadorCritico: json['mult'] != null
          ? (json['mult'] as num).toInt()
          : 2,
      categoria: json['categoria']?.toString() ?? '0',
      espaco: json['espaco'] != null ? (json['espaco'] as num).toDouble() : 1.0,
      modificacoes: json['modificacoes'] is List
          ? List<String>.from(json['modificacoes'])
          : <String>[],
      equipado: json['equipado'] == true,
      proficiencia: json['proficiencia']?.toString() ?? 'Simples',
      empunhadura: json['empunhadura']?.toString() ?? 'Uma Mão',
    );
  }
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
  List<String> poderes;
  List<String> periciasClasse;

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
    this.poderes = const [],
    this.periciasClasse = const [],
  });

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'classe': classe,
    'origem': origem,
    'fotoPath': fotoPath,
    'afinidade': afinidade,
    'nex': nex,
    'prestigio': prestigio,
    'agi': agi, 'forc': forc, 'inte': inte, 'pre': pre, 'vig': vig,
    'pvAtual': pvAtual,
    'peAtual': peAtual,
    'sanAtual': sanAtual,
    'pericias': pericias,
    'inventario': inventario.map((i) => i.toJson()).toList(),
    'armas': armas.map((a) => a.toJson()).toList(),
    'poderes': poderes,
    'periciasClasse': periciasClasse,
  };

  factory AgenteDados.fromJson(Map<String, dynamic> json) => AgenteDados(
    nome: json['nome']?.toString() ?? 'Desconhecido',
    classe: json['classe']?.toString() ?? 'combatente',
    origem: json['origem']?.toString() ?? 'academico',
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
    poderes: json['poderes'] is List
        ? List<String>.from(json['poderes'])
        : <String>[],
    periciasClasse: json['periciasClasse'] is List
        ? List<String>.from(json['periciasClasse'])
        : <String>[],
  );
}
