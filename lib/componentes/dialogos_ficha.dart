import 'package:flutter/material.dart';

import '../modelos/agente_dados.dart';
import 'estilizacao.dart';
import 'widgets_ficha.dart';

// ============================================================================
// DIALOG: ESCOLHER ELEMENTO DE ITEM PARANORMAL
// ============================================================================
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
  String nomeLimpo = itemBase.nome.replaceAll(' de (elemento)', '').replaceAll(' (elemento)', '');

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
                  child: Text("Escolher Elemento", style: TextStyle(color: corDestaque, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Defina a qual entidade o item '$nomeLimpo' está atrelado:", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 24),
                DropdownFicha(
                  label: "Elemento",
                  value: elementoSelecionado,
                  options: const ["Sangue", "Morte", "Energia", "Conhecimento"],
                  onChanged: (val) => setDialogState(() => elementoSelecionado = val!),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: corTema,
                  foregroundColor: corTexto,
                  side: afinidadeAtual == 'Morte' ? const BorderSide(color: Colors.white54) : null,
                ),
                onPressed: () {
                  String novoNome = itemBase.nome.replaceAll("(elemento)", elementoSelecionado);
                  onConfirmar(ItemInventario(
                    nome: novoNome,
                    categoria: itemBase.categoria,
                    espaco: itemBase.espaco,
                    descricao: itemBase.descricao,
                  ));
                  Navigator.pop(context);
                },
                child: const Text("Confirmar", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }
      );
    },
  );
}

// ============================================================================
// DIALOG: CRIAR CATALISADOR
// ============================================================================
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
                  child: Text("Catalisador Ritualístico", style: TextStyle(color: corDestaque, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Especifique as propriedades paranormais do catalisador que você obteve:", style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 24),
                DropdownFicha(
                  label: "Função",
                  value: tipoSelecionado,
                  options: const ["Ampliador", "Perturbador", "Potencializador", "Prolongador"],
                  onChanged: (val) => setDialogState(() => tipoSelecionado = val!),
                ),
                const SizedBox(height: 16),
                DropdownFicha(
                  label: "Elemento do Catalisador",
                  value: elementoSelecionado,
                  options: const ["Sangue", "Morte", "Energia", "Conhecimento"],
                  onChanged: (val) => setDialogState(() => elementoSelecionado = val!),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: corTema,
                  foregroundColor: corTexto,
                  side: afinidadeAtual == 'Morte' ? const BorderSide(color: Colors.white54) : null,
                ),
                onPressed: () {
                  onConfirmar(ItemInventario(
                    nome: "Catalisador $tipoSelecionado ($elementoSelecionado)",
                    categoria: "I",
                    espaco: 0.5,
                    descricao: "Item Paranormal. Usado para conjurar rituais.",
                  ));
                  Navigator.pop(context);
                },
                child: const Text("Criar Catalisador", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }
      );
    },
  );
}

// ============================================================================
// DIALOG: ESCOLHER PERÍCIA DE VESTIMENTA
// ============================================================================
void mostrarDialogEscolherPericiaVestimenta({
  required BuildContext context,
  required ItemInventario itemBase,
  required List<Pericia> listaPericias,
  required Color corDestaque,
  required Color corTema,
  required Color corTexto,
  required String? afinidadeAtual,
  required Function(ItemInventario) onConfirmar,
}) {
  String periciaSelecionada = listaPericias.first.id;
  String nomePericia = listaPericias.first.nome;

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
                Icon(Icons.checkroom, color: corDestaque),
                const SizedBox(width: 8),
                Text("Costurar Vestimenta", style: TextStyle(color: corDestaque, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Escolha qual perícia esta vestimenta vai aprimorar:", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: periciaSelecionada,
                  dropdownColor: const Color(0xFF1A1A1A),
                  style: const TextStyle(color: Colors.white),
                  decoration: EstiloParanormal.customInputDeco("Perícia", corDestaque, Icons.star),
                  items: listaPericias.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nome))).toList(),
                  onChanged: (val) {
                    setDialogState(() {
                      periciaSelecionada = val!;
                      nomePericia = listaPericias.firstWhere((p) => p.id == val).nome;
                    });
                  },
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: corTema,
                  foregroundColor: corTexto,
                  side: afinidadeAtual == 'Morte' ? const BorderSide(color: Colors.white54) : null,
                ),
                onPressed: () {
                  itemBase.periciaVinculada = periciaSelecionada;
                  itemBase.nome = "Vestimenta de $nomePericia";
                  onConfirmar(itemBase);
                  Navigator.pop(context);
                },
                child: const Text("Confirmar", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }
      );
    },
  );
}

// ============================================================================
// DIALOG: CRIAR EQUIPAMENTO MANUAL (Arma ou Item)
// ============================================================================
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
  String nome = "", tipo = isArma ? "Corpo a Corpo" : "I", dano = "1d4", desc = "";
  String categoria = "0", proficiencia = "Simples", empunhadura = "Uma Mão";
  int margem = 20, mult = 2; double espaco = 1.0;

  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: corDestaque.withValues(alpha: 0.3))),
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(isArma ? Icons.colorize : Icons.backpack, color: corDestaque, size: 28),
                const SizedBox(width: 12),
                Text(isArma ? "CRIAR ARMA" : "CRIAR ITEM", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: corDestaque, letterSpacing: 1.5)),
              ],
            ),
            const SizedBox(height: 24),
            TextField(decoration: EstiloParanormal.customInputDeco("Nome", corDestaque, Icons.edit), onChanged: (val) => nome = val),
            const SizedBox(height: 16),
            if (isArma) ...[
              Row(
                children: [
                  Expanded(child: DropdownFicha(label: "Tipo", value: tipo, options: const ["Corpo a Corpo", "Fogo", "Arremesso", "Disparo"], onChanged: (val) => tipo = val!)),
                  const SizedBox(width: 16),
                  Expanded(child: TextField(decoration: EstiloParanormal.customInputDeco("Dano", corDestaque, Icons.casino), onChanged: (val) => dano = val)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextField(decoration: EstiloParanormal.customInputDeco("Margem", corDestaque, Icons.warning_amber), keyboardType: TextInputType.number, onChanged: (val) => margem = int.tryParse(val) ?? 20)),
                  const SizedBox(width: 16),
                  Expanded(child: TextField(decoration: EstiloParanormal.customInputDeco("Crítico (x)", corDestaque, Icons.close), keyboardType: TextInputType.number, onChanged: (val) => mult = int.tryParse(val) ?? 2)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: DropdownFicha(label: "Proficiência", value: proficiencia, options: const ["Simples", "Táticas", "Pesadas"], onChanged: (val) => proficiencia = val!)),
                  const SizedBox(width: 16),
                  Expanded(child: DropdownFicha(label: "Empunhadura", value: empunhadura, options: const ["Leve", "Uma Mão", "Duas Mãos"], onChanged: (val) => empunhadura = val!)),
                ],
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(child: DropdownFicha(label: "Categoria", value: categoria, options: const ["0", "I", "II", "III", "IV"], onChanged: (val) => categoria = val!)),
                const SizedBox(width: 16),
                Expanded(child: TextField(decoration: EstiloParanormal.customInputDeco("Espaço", corDestaque, Icons.scale), keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: (val) => espaco = double.tryParse(val.replaceAll(',', '.')) ?? 1.0)),
              ],
            ),
            if (!isArma) ...[
              const SizedBox(height: 16),
              TextField(decoration: EstiloParanormal.customInputDeco("Detalhes / Efeitos", corDestaque, Icons.info_outline), maxLines: 3, minLines: 1, onChanged: (val) => desc = val),
            ],
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: Colors.grey), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), 
                    onPressed: () { Navigator.pop(context); onVoltar(); }, 
                    child: const Text("CANCELAR", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
                  )
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: corTema, foregroundColor: corTexto, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), side: afinidadeAtual == 'Morte' ? const BorderSide(color: Colors.white54) : null),
                    onPressed: () {
                      if (nome.isNotEmpty) {
                        Navigator.pop(context);
                        if (isArma) {
                          onConfirmar(Arma(nome: nome, tipo: tipo, dano: dano, margemAmeaca: margem, multiplicadorCritico: mult, categoria: categoria, espaco: espaco, proficiencia: proficiencia, empunhadura: empunhadura));
                        } else {
                          onConfirmar(ItemInventario(nome: nome, categoria: categoria, espaco: espaco, descricao: desc));
                        }
                      }
                    },
                    child: const Text("CRIAR", style: TextStyle(fontWeight: FontWeight.bold)),
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

// ============================================================================
// DIALOG: MODIFICAR EQUIPAMENTO EXISTENTE
// ============================================================================
void mostrarDialogModificarEquipamento({
  required BuildContext context,
  required dynamic equipamento,
  required Color corDestaque,
  required Color corTema,
  required Color corTexto,
  required String? afinidadeAtual,
  required Function(List<String>) onAplicar,
}) {
  bool isArma = equipamento is Arma;
  bool isMunicao = !isArma && (equipamento as ItemInventario).descricao.contains("Munição");
  bool isProtecao = !isArma && (equipamento as ItemInventario).descricao.contains("Proteção");
  bool isVestimenta = !isArma && (equipamento as ItemInventario).nome.toLowerCase().contains("vestimenta");

  List<String> modsDisponiveis = [];
  if (isArma) {
    modsDisponiveis = (equipamento).tipo == "Fogo"
        ? ["Alongada", "Calibre Grosso", "Compensador", "Discreta", "Ferrolho Automático", "Mira Laser", "Mira Telescópica", "Silenciador", "Tática", "Visão de Calor"]
        : ["Certeira", "Cruel", "Discreta", "Perigosa", "Tática"];
  } else if (isMunicao) { modsDisponiveis = ["Dum dum", "Explosiva"]; } 
  else if (isProtecao) { modsDisponiveis = ["Antibombas", "Blindada", "Discreta", "Reforçada"]; } 
  else if (isVestimenta) { modsDisponiveis = ["Aprimorada"]; }

  if (modsDisponiveis.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Este equipamento não suporta modificações."), backgroundColor: Colors.redAccent));
    return;
  }

  List<String> modsSelecionados = List.from(equipamento.modificacoes);
  String catBase = equipamento.categoria;

  int getCatInt(String c) {
    if (c == 'I') return 1; if (c == 'II') return 2; if (c == 'III') return 3; if (c == 'IV') return 4; return 0;
  }

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          bool podeAdicionarMaisMods = (getCatInt(catBase) + modsSelecionados.length) < 4;

          return Dialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: corDestaque.withValues(alpha: 0.3))),
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
                      Expanded(child: Text("BANCADA DE MELHORIAS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: corDestaque))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(equipamento.nome, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("MODIFICAÇÕES", style: TextStyle(color: corDestaque, fontWeight: FontWeight.bold)),
                      if (!podeAdicionarMaisMods) const Text("LIMITE ATINGIDO", style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: modsDisponiveis.map((mod) {
                      bool isSelected = modsSelecionados.contains(mod);
                      return FilterChip(
                        label: Text(mod, style: TextStyle(fontSize: 12, color: isSelected ? corTexto : Colors.grey.shade400, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                        selected: isSelected, selectedColor: corTema, backgroundColor: const Color(0xFF1A1A1A), side: BorderSide(color: isSelected ? corDestaque : Colors.grey.shade800),
                        onSelected: (selected) {
                          setDialogState(() {
                            if (selected) { if (podeAdicionarMaisMods) modsSelecionados.add(mod); } 
                            else { modsSelecionados.remove(mod); }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: Colors.grey), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () => Navigator.pop(context), child: const Text("CANCELAR", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)))),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: corTema, foregroundColor: corTexto, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), side: afinidadeAtual == 'Morte' ? const BorderSide(color: Colors.white54) : null),
                          onPressed: () {
                            onAplicar(modsSelecionados);
                            Navigator.pop(context);
                          },
                          child: const Text("APLICAR", style: TextStyle(fontWeight: FontWeight.bold)),
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

// ============================================================================
// DIALOG: CONFIGURAR ITEM APÓS ESCOLHER NO CATÁLOGO
// ============================================================================
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: corDestaque),
              ),
              const SizedBox(height: 8),
              Text(
                isArma ? "Dano: ${equipamentoBase.dano} | Crítico: ${equipamentoBase.margemAmeaca}/x${equipamentoBase.multiplicadorCritico}" : equipamentoBase.descricao,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: Colors.grey), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () { Navigator.pop(context); onVoltar(); },
                      child: const Text("VOLTAR", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: corTema, foregroundColor: corTexto, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: afinidadeAtual == 'Morte' ? const BorderSide(color: Colors.white54) : null,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        onAdicionar(equipamentoBase);
                      },
                      child: const Text("ADICIONAR", style: TextStyle(fontWeight: FontWeight.bold)),
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