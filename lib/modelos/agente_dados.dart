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
    // Não conta a "Ferramenta Favorita" como uma modificação normal que aumenta o peso
    int qtdMods = modificacoes.where((m) => m != "Ferramenta Favorita" && m != "Explosão Solidária").length;
    
    if (qtdMods == 0 && !modificacoes.contains("Ferramenta Favorita")) return categoria;

    List<String> niveis = ["0", "I", "II", "III", "IV", "V", "VI", "VII"];
    int indexAtual = niveis.indexOf(categoria);
    
    if (indexAtual == -1) return categoria;

    int novoIndex = indexAtual + qtdMods;
    
    // Engenheiro (Reduz a categoria em 1)
    if (modificacoes.contains("Ferramenta Favorita")) novoIndex -= 1;
    if (novoIndex < 0) novoIndex = 0; // Trava no 0 para não existir categoria negativa
    
    if (novoIndex >= niveis.length) return niveis.last;

    return niveis[novoIndex];
  }

  double get espacoEfetivo {
    double e = espaco;
    if (modificacoes.contains("Discreta") ||
        modificacoes.contains("Discreto")) {
      e -= 1.0;
    }
    if (modificacoes.contains("Blindada")) e += 1.0;
    if (modificacoes.contains("Reforçada")) e += 1.0;

    if (espaco >= 0 && e < 0) return 0;
    return e;
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
  String descricao;

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
    this.descricao = "",
  });

  String get categoriaEfetiva {
    // Filtra a lista para não contar a "Ferramenta de Trabalho" no aumento de categoria
    int qtdMods = modificacoes.where((mod) => mod != "Ferramenta de Trabalho").length;
    
    if (qtdMods == 0) return categoria;

    List<String> niveis = ["0", "I", "II", "III", "IV", "V", "VI", "VII"];
    int indexAtual = niveis.indexOf(categoria);
    
    if (indexAtual == -1) return categoria;

    int novoIndex = indexAtual + qtdMods;
    if (novoIndex >= niveis.length) return niveis.last;

    return niveis[novoIndex];
  }

  double get espacoEfetivo {
    double e = espaco;
    if (modificacoes.contains("Discreta") || modificacoes.contains("Discreto")) {
      e -= 1.0;
    }
    if (espaco >= 0 && e < 0) return 0;
    return e;
  }

  // --- MATEMÁTICA ATUALIZADA DO DANO ---
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
      flat += 1; // Bônus do Operário!
    }

    String result = "$dados$resto";
    if (flat > 0) {
      result += "+$flat";
    } else if (flat < 0) {
      result += "$flat";
    }

    return result;
  }

  // --- MATEMÁTICA ATUALIZADA DA MARGEM ---
  int get margemAmeacaEfetiva {
    int m = margemAmeaca;
    if (modificacoes.contains("Perigosa") ||
        modificacoes.contains("Mira Laser")) {
      m -= 2;
    }
    if (modificacoes.contains("Ferramenta de Trabalho")) {
      m -= 1; // Bônus do Operário!
    }
    if (m < 2) return 2;
    return m;
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
    'descricao': descricao,
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
      descricao: json['descricao']?.toString() ?? "",
    );
  }
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
  List<String> poderes;
  List<String> periciasClasse;

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
    this.periciasClasse = const [],
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
    'poderes': poderes,
    'periciasClasse': periciasClasse,
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
    poderes: json['poderes'] is List
        ? List<String>.from(json['poderes'])
        : <String>[],
    periciasClasse: json['periciasClasse'] is List
        ? List<String>.from(json['periciasClasse'])
        : <String>[],
  );
}
