import 'package:flutter/material.dart';
import '../modelos/agente_dados.dart';
import 'estilizacao.dart';
import 'widgets_ficha.dart';

// Escolher elemento de um item
void mostrarDialogElementoItem({
  required BuildContext context,
  required ItemInventario itemBase,
  required Color corDestaque,
  required Color corTema,
  required Color corTexto,
  required String? afinidadeAtual,
  required Function(ItemInventario) onConfirmar,
}) {
  String elementoSelecionado = "Sangue";
  String nomeLimpo = itemBase.nome
      .replaceAll(' de (elemento)', '')
      .replaceAll(' (elemento)', '');

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: corDestaque.withValues(alpha: 0.3)),
            ),
            title: Row(
              children: [
                Icon(Icons.auto_awesome, color: corDestaque),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Escolher Elemento",
                    style: TextStyle(
                      color: corDestaque,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Defina a qual entidade o item '$nomeLimpo' está atrelado:",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 24),
                DropdownFicha(
                  label: "Elemento",
                  value: elementoSelecionado,
                  options: const ["Sangue", "Morte", "Energia", "Conhecimento"],
                  onChanged: (val) =>
                      setDialogState(() => elementoSelecionado = val!),
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
                  backgroundColor: corTema,
                  foregroundColor: corTexto,
                  side: afinidadeAtual == 'Morte'
                      ? const BorderSide(color: Colors.white54)
                      : null,
                ),
                onPressed: () {
                  String novoNome = itemBase.nome.replaceAll(
                    "(elemento)",
                    elementoSelecionado,
                  );
                  onConfirmar(
                    ItemInventario(
                      nome: novoNome,
                      categoria: itemBase.categoria,
                      espaco: itemBase.espaco,
                      descricao: itemBase.descricao,
                    ),
                  );
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
    },
  );
}

// Criar catalizador
void mostrarDialogCatalisador({
  required BuildContext context,
  required Color corDestaque,
  required Color corTema,
  required Color corTexto,
  required String? afinidadeAtual,
  required Function(ItemInventario) onConfirmar,
}) {
  String tipoSelecionado = "Ampliador";
  String elementoSelecionado = "Sangue";

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: corDestaque.withValues(alpha: 0.3)),
            ),
            title: Row(
              children: [
                Icon(Icons.auto_awesome, color: corDestaque),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Catalisador Ritualístico",
                    style: TextStyle(
                      color: corDestaque,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Especifique as propriedades paranormais do catalisador que você obteve:",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 24),
                DropdownFicha(
                  label: "Função",
                  value: tipoSelecionado,
                  options: const [
                    "Ampliador",
                    "Perturbador",
                    "Potencializador",
                    "Prolongador",
                  ],
                  onChanged: (val) =>
                      setDialogState(() => tipoSelecionado = val!),
                ),
                const SizedBox(height: 16),
                DropdownFicha(
                  label: "Elemento do Catalisador",
                  value: elementoSelecionado,
                  options: const ["Sangue", "Morte", "Energia", "Conhecimento"],
                  onChanged: (val) =>
                      setDialogState(() => elementoSelecionado = val!),
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
                  backgroundColor: corTema,
                  foregroundColor: corTexto,
                  side: afinidadeAtual == 'Morte'
                      ? const BorderSide(color: Colors.white54)
                      : null,
                ),
                onPressed: () {
                  onConfirmar(
                    ItemInventario(
                      nome:
                          "Catalisador $tipoSelecionado ($elementoSelecionado)",
                      categoria: "I",
                      espaco: 0.5,
                      descricao:
                          "Item Paranormal. Usado para conjurar rituais.",
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  "Criar Catalisador",
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

// Escolher a perícia da vestimenta
void mostrarDialogEscolherPericiaAprimoramento({
  required BuildContext context,
  required ItemInventario itemBase,
  required List<Pericia> listaPericias,
  required Color corDestaque,
  required Color corTema,
  required Color corTexto,
  required String? afinidadeAtual,
  required bool isVestimenta,
  required Function(ItemInventario) onConfirmar,
}) {
  // Remove Luta e Pontaria das opções
  List<Pericia> periciasValidas = listaPericias
      .where((p) => p.id != 'luta' && p.id != 'pontaria')
      .toList();

  String periciaSelecionada = periciasValidas.first.id;
  String nomePericia = periciasValidas.first.nome;
  String tipoTexto = isVestimenta ? "Vestimenta" : "Utensílio";

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: corDestaque.withValues(alpha: 0.3)),
            ),
            title: Row(
              children: [
                Icon(
                  isVestimenta ? Icons.checkroom : Icons.build_circle,
                  color: corDestaque,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Configurar $tipoTexto",
                    style: TextStyle(
                      color: corDestaque,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Escolha qual perícia este $tipoTexto vai aprimorar:",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: periciaSelecionada,
                  dropdownColor: const Color(0xFF1A1A1A),
                  style: const TextStyle(color: Colors.white),
                  decoration: EstiloParanormal.customInputDeco(
                    "Perícia",
                    corDestaque,
                    Icons.star,
                  ),
                  // Usa a nova lista filtrada
                  items: periciasValidas
                      .map(
                        (p) =>
                            DropdownMenuItem(value: p.id, child: Text(p.nome)),
                      )
                      .toList(),
                  onChanged: (val) {
                    setDialogState(() {
                      periciaSelecionada = val!;
                      nomePericia = periciasValidas
                          .firstWhere((p) => p.id == val)
                          .nome;
                    });
                  },
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
                  backgroundColor: corTema,
                  foregroundColor: corTexto,
                  side: afinidadeAtual == 'Morte'
                      ? const BorderSide(color: Colors.white54)
                      : null,
                ),
                onPressed: () {
                  itemBase.periciaVinculada = periciaSelecionada;
                  itemBase.nome = "$tipoTexto de $nomePericia";
                  Navigator.pop(context);
                  onConfirmar(itemBase);
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
    },
  );
}

// Criar equipamento personalizado
void mostrarDialogCriacaoManual({
  required BuildContext context,
  required bool isArma,
  required Color corDestaque,
  required Color corTema,
  required Color corTexto,
  required String? afinidadeAtual,
  required Function(dynamic) onConfirmar,
  required VoidCallback onVoltar,
}) {
  String nome = "",
      tipo = isArma ? "Corpo a Corpo" : "I",
      dano = "1d4",
      desc = "";
  String categoria = "0", proficiencia = "Simples", empunhadura = "Uma Mão";
  int margem = 20, mult = 2;
  double espaco = 1.0;

  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: corDestaque.withValues(alpha: 0.3)),
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
                  color: corDestaque,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  isArma ? "CRIAR ARMA" : "CRIAR ITEM",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: corDestaque,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: EstiloParanormal.customInputDeco(
                "Nome",
                corDestaque,
                Icons.edit,
              ),
              onChanged: (val) => nome = val,
            ),
            const SizedBox(height: 16),
            if (isArma) ...[
              Row(
                children: [
                  Expanded(
                    child: DropdownFicha(
                      label: "Tipo",
                      value: tipo,
                      options: const [
                        "Corpo a Corpo",
                        "Fogo",
                        "Arremesso",
                        "Disparo",
                      ],
                      onChanged: (val) => tipo = val!,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: EstiloParanormal.customInputDeco(
                        "Dano",
                        corDestaque,
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
                        corDestaque,
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
                        corDestaque,
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
                    child: DropdownFicha(
                      label: "Proficiência",
                      value: proficiencia,
                      options: const ["Simples", "Táticas", "Pesadas"],
                      onChanged: (val) => proficiencia = val!,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownFicha(
                      label: "Empunhadura",
                      value: empunhadura,
                      options: const ["Leve", "Uma Mão", "Duas Mãos"],
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
                  child: DropdownFicha(
                    label: "Categoria",
                    value: categoria,
                    options: const ["0", "I", "II", "III", "IV"],
                    onChanged: (val) => categoria = val!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: EstiloParanormal.customInputDeco(
                      "Espaço",
                      corDestaque,
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
                  corDestaque,
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
                      onVoltar();
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
                      backgroundColor: corTema,
                      foregroundColor: corTexto,
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
                          onConfirmar(
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
                              descricao: '',
                            ),
                          );
                        } else {
                          onConfirmar(
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

// Modificar item
void mostrarDialogModificarEquipamento({
  required BuildContext context,
  required dynamic equipamento,
  required Color corDestaque,
  required Color corTema,
  required Color corTexto,
  required String? afinidadeAtual,
  required int nex,
  required String trilhaAtual,
  required Function(List<String>) onAplicar,
}) {
  bool isArma = equipamento is Arma;
  String descLower = isArma
      ? ""
      : (equipamento as ItemInventario).descricao.toLowerCase();

  bool isMunicao = !isArma && descLower.contains("munição");
  bool isProtecao = !isArma && descLower.contains("proteção");
  bool isAcessorio = !isArma && descLower.contains("acessório");

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
  } else if (isAcessorio ||
      descLower.contains("vestimenta") ||
      descLower.contains("utensílio")) {
    modsDisponiveis = [
      "Aprimorada",
      "Discreta",
      "Função adicional",
      "Instrumental",
    ];
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

  // Descrição das Modificações
  Map<String, String> descricoesMods = {
    "Aprimorada": "Aumenta um dos bônus em perícia para +5.",
    "Aprimorado": "Aumenta um dos bônus em perícia para +5.",
    "Discreta": "+5 em testes para ocultar e reduz o espaço ocupado em –1.",
    "Discreto": "+5 em testes para ocultar e reduz o espaço ocupado em –1.",
    "Função adicional": "Concede +2 a uma perícia adicional.",
    "Instrumental": "O acessório funciona como um kit de perícia.",
    "Antibombas": "+5 em testes de resistência contra efeitos de área.",
    "Blindada": "Aumenta RD para 5 e o espaço em +1.",
    "Reforçada": "Aumenta a Defesa em +2 e o espaço em +1.",
    "Certeira": "+2 em testes de ataque.",
    "Cruel": "+2 em rolagens de dano.",
    "Perigosa": "+2 em margem de ameaça.",
    "Tática": "Pode sacar como ação livre.",
    "Alongada": "+2 em testes de ataque.",
    "Calibre Grosso": "Aumenta o dano em mais um dado do mesmo tipo.",
    "Compensador": "Anula penalidade por rajadas.",
    "Ferrolho Automático": "A arma se torna automática.",
    "Mira Laser": "+2 em margem de ameaça.",
    "Mira Telescópica": "Aumenta alcance da arma e do Ataque Furtivo.",
    "Silenciador":
        "Reduz em –2d20 a penalidade em Furtividade para se esconder após atacar.",
    "Visão de Calor": "Ignora camuflagem.",
    "Dum dum": "+1 em multiplicador de crítico.",
    "Explosiva": "Aumenta o dano em +2d6.",
  };

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
          int calcularCategoriaSimulada() {
            int base = getCatInt(catBase);

            // 1. Conta apenas modificações que realmente aumentam o peso
            int modsAdicionais = modsSelecionados
                .where(
                  (m) =>
                      m != "Arma Favorita" &&
                      m != "Ferramenta de Trabalho" &&
                      m != "Explosão Solidária",
                )
                .length;

            // 2. Calcula os descontos de trilha
            int reducaoTrilha = 0;
            if (isArma &&
                trilhaAtual == 'aniquilador' &&
                modsSelecionados.contains("Arma Favorita")) {
              if (nex >= 99) {
                reducaoTrilha = 3;
              } else if (nex >= 40) {
                reducaoTrilha = 2;
              } else if (nex >= 10) {
                reducaoTrilha = 1;
              }
            }

            // 3. Resultado final atual da arma na bancada
            int total = base + modsAdicionais - reducaoTrilha;
            if (total < 0) return 0;
            return total;
          }

          // Se a categoria simulada já for 4 (IV) ou maior, trava os botões!
          int categoriaAtualSimulada = calcularCategoriaSimulada();
          bool podeAdicionarMaisMods = categoriaAtualSimulada < 4;
          // =======================================================

          return Dialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: corDestaque.withValues(alpha: 0.3)),
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
                      Icon(Icons.build, color: corDestaque, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "BANCADA DE MELHORIAS",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: corDestaque,
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
                          color: corDestaque,
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
                            color: isSelected ? corTexto : Colors.grey.shade400,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: corTema,
                        backgroundColor: const Color(0xFF1A1A1A),
                        side: BorderSide(
                          color: isSelected
                              ? corDestaque
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

                  if (modsSelecionados.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      "Efeitos Ativos:",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: modsSelecionados.map((mod) {
                          if (mod == "Arma Favorita" ||
                              mod == "Ferramenta de Trabalho") {
                            return const SizedBox.shrink();
                          }

                          String efeito =
                              descricoesMods[mod] ?? "Efeito aplicado à arma.";
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                                children: [
                                  TextSpan(
                                    text: "• $mod: ",
                                    style: TextStyle(
                                      color: corDestaque,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: efeito),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
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
                            backgroundColor: corTema,
                            foregroundColor: corTexto,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: afinidadeAtual == 'Morte'
                                ? const BorderSide(color: Colors.white54)
                                : null,
                          ),
                          onPressed: () {
                            onAplicar(modsSelecionados);
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

// Configurar item dps de escolher no catálogo
void mostrarDialogConfigurarEquipamentoBase({
  required BuildContext context,
  required dynamic equipamentoBase,
  required Color corDestaque,
  required Color corTema,
  required Color corTexto,
  required String? afinidadeAtual,
  required VoidCallback onVoltar,
  required Function(dynamic) onAdicionar,
}) {
  bool isArma = equipamentoBase is Arma;

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
                  color: corDestaque,
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
                        onVoltar();
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
                        backgroundColor: corTema,
                        foregroundColor: corTexto,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: afinidadeAtual == 'Morte'
                            ? const BorderSide(color: Colors.white54)
                            : null,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        onAdicionar(equipamentoBase);
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

// Criar poder personalizado
void mostrarDialogCriarPoder({
  required BuildContext context,
  required Color corDestaque,
  required Color corTema,
  required Color corTexto,
  required Function(Poder) onConfirmar,
}) {
  TextEditingController nomeCtrl = TextEditingController();
  TextEditingController descCtrl = TextEditingController();
  TextEditingController preReqCtrl = TextEditingController();
  TextEditingController custoPECtrl = TextEditingController(text: "0");

  bool isParanormal = false; // Começa na aba "Geral"
  String elementoEscolhido =
      "Sangue"; // Elemento padrão se for para a aba paranormal

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: Text("Criar Poder", style: TextStyle(color: corDestaque)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: nomeCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Nome do Poder",
                      labelStyle: const TextStyle(color: Colors.grey),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: corDestaque),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ============================================
                  // NOVO SELETOR DE CATEGORIA (Geral vs Paranormal)
                  // ============================================
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0D0D),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade800),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Aba Geral
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                isParanormal = false;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: !isParanormal
                                    ? corDestaque
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(7),
                                  bottomLeft: Radius.circular(7),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "Geral",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: !isParanormal
                                        ? Colors.black
                                        : Colors.grey.shade500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Divisória sutil
                        Container(width: 1, color: Colors.grey.shade800),
                        // Aba Paranormal
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                isParanormal = true;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isParanormal
                                    ? corDestaque
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(7),
                                  bottomRight: Radius.circular(7),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "Paranormal",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isParanormal
                                        ? Colors.black
                                        : Colors.grey.shade500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ============================================
                  // ESCOLHA DE ELEMENTO (Só aparece na aba Paranormal)
                  // ============================================
                  if (isParanormal) ...[
                    const Text(
                      "Elemento do Poder:",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ["Sangue", "Morte", "Energia", "Conhecimento"].map((
                        elem,
                      ) {
                        Color corElem = elem == 'Sangue'
                            ? const Color(0xFF990000)
                            : elem == 'Energia'
                            ? const Color(0xFF9900FF)
                            : elem == 'Conhecimento'
                            ? const Color(0xFFFFB300)
                            : Colors.grey.shade400;
                        bool selected = elementoEscolhido == elem;

                        // Garante que o texto de Morte e Conhecimento fique legível quando selecionado
                        Color txtCor = selected
                            ? (elem == 'Conhecimento' || elem == 'Morte'
                                  ? Colors.black
                                  : Colors.white)
                            : corElem;
                        if (elem == 'Morte' && selected) {
                          txtCor = Colors.black;
                        } else if (elem == 'Morte' && !selected) {
                          txtCor = Colors.white;
                        }

                        return ChoiceChip(
                          label: Text(
                            elem,
                            style: TextStyle(
                              color: txtCor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: selected,
                          selectedColor: corElem,
                          backgroundColor: const Color(0xFF0D0D0D),
                          side: BorderSide(
                            color: selected ? corElem : Colors.grey.shade800,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setDialogState(() => elementoEscolhido = elem);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextField(
                    controller: descCtrl,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Descrição",
                      labelStyle: const TextStyle(color: Colors.grey),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: corDestaque),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: preReqCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Pré-requisitos (Ex: Sangue 1)",
                      labelStyle: const TextStyle(color: Colors.grey),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: corDestaque),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: custoPECtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Custo em PE",
                      labelStyle: const TextStyle(color: Colors.grey),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: corDestaque),
                      ),
                    ),
                  ),
                ],
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: corTema,
                  foregroundColor: corTexto,
                ),
                onPressed: () {
                  onConfirmar(
                    Poder(
                      nome: nomeCtrl.text.isNotEmpty
                          ? nomeCtrl.text
                          : "Poder Desconhecido",
                      // Se for paranormal, usa o elemento. Senão, vai pro filtro "Gerais"
                      tipo: isParanormal ? elementoEscolhido : "Gerais",
                      descricao: descCtrl.text,
                      preRequisitos: preReqCtrl.text.isNotEmpty
                          ? preReqCtrl.text
                          : "Nenhum",
                      custoPE: int.tryParse(custoPECtrl.text) ?? 0,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text("CRIAR"),
              ),
            ],
          );
        },
      );
    },
  );
}

