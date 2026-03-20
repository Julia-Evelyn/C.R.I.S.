// ignore_for_file: invalid_use_of_protected_member
part of 'ficha_agente.dart';

extension _OrigensFicha on _FichaAgenteState {
  void _mostrarDialogOrigens() {
    String busca = ""; // Variável para a barra de pesquisa

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Filtra as origens com base no que for digitado
            var origensFiltradas = dadosOrigens.entries.where((e) {
              return busca.isEmpty ||
                  e.value.nome.toLowerCase().contains(busca.toLowerCase());
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
                    Row(
                      children: [
                        Icon(Icons.history_edu, color: corDestaque, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          "ORIGENS",
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
                      "A origem de um agente é a sua vida antes de se envolver com o paranormal. Cada origem fornece treinamento em duas perícias e um poder único.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // =======================================
                    // A BARRA DE PESQUISA ESTÁ DE VOLTA AQUI!
                    TextField(
                      decoration: EstiloParanormal.customInputDeco(
                        "Pesquisar origem...",
                        corDestaque,
                        Icons.search,
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) {
                        setDialogState(() {
                          busca = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // =======================================
                    Expanded(
                      child: origensFiltradas.isEmpty
                          ? const Center(
                              child: Text(
                                "Nenhuma origem encontrada.",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: origensFiltradas.length,
                              itemBuilder: (context, index) {
                                String idOrigem = origensFiltradas[index].key;
                                DadosOrigem o = origensFiltradas[index].value;
                                bool isSelected = origemAtual == idOrigem;

                                String nomesPericias = o.pericias
                                    .map((pid) {
                                      var periciaEncontrada = listaPericias
                                          .firstWhere(
                                            (p) => p.id == pid,
                                            orElse: () => Pericia(
                                              id: pid,
                                              nome: 'À escolha do jogador',
                                              atributo: '',
                                            ),
                                          );
                                      return periciaEncontrada.nome;
                                    })
                                    .join(" e ");

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
                                    data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent,
                                    ),
                                    child: ExpansionTile(
                                      iconColor: corDestaque,
                                      collapsedIconColor: Colors.grey,
                                      tilePadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 4,
                                      ),
                                      title: Text(
                                        o.nome,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? corDestaque
                                              : Colors.white,
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Text(
                                          "Perícias: $nomesPericias",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
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
                                                color: corDestaque.withValues(
                                                  alpha: 0.3,
                                                ),
                                                thickness: 1,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "PODER: ${o.nomeHabilidade}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                o.descHabilidade,
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 13,
                                                  height: 1.4,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      corFundoAfinidade,
                                                  foregroundColor:
                                                      corTextoAfinidade,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                      ),
                                                  side:
                                                      afinidadeAtual == 'Morte'
                                                      ? const BorderSide(
                                                          color: Colors.white54,
                                                        )
                                                      : null,
                                                ),
                                                onPressed: isSelected
                                                    ? null
                                                    : () {
                                                        if (idOrigem ==
                                                            'experimento') {
                                                          _mostrarDialogExperimento();
                                                        } else if (idOrigem ==
                                                            'profetizado') {
                                                          _mostrarDialogProfetizado();
                                                        } else if (idOrigem ==
                                                            'engenheiro') {
                                                          _mostrarDialogEngenheiro();
                                                        } else if (idOrigem ==
                                                            'amnésico') {
                                                          _mostrarDialogAmnesico();
                                                        } else {
                                                          setState(() {
                                                            origemAtual =
                                                                idOrigem;
                                                            poderesEscolhidos.removeWhere(
                                                              (p) =>
                                                                  p.nome.startsWith(
                                                                    "Experimento_",
                                                                  ) ||
                                                                  p.nome.startsWith(
                                                                    "Profetizado_",
                                                                  ) ||
                                                                  p.nome.startsWith(
                                                                    "Colegial_",
                                                                  ) ||
                                                                  p.nome.startsWith(
                                                                    "Revoltado_",
                                                                  ),
                                                            );
                                                          });
                                                          atualizarFicha();
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                        }
                                                      },
                                                child: Text(
                                                  isSelected
                                                      ? "ORIGEM ATUAL"
                                                      : "ESCOLHER ESTA ORIGEM",
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
      },
    );
  }

  // ============== DIALOGS ESPECÍFICOS DE ORIGENS ==============

  void _mostrarDialogExperimento() {
    List<Pericia> listaValida = listaPericias
        .where((p) => p.treino == 0)
        .toList();
    if (listaValida.isEmpty) {
      listaValida = List.from(listaPericias);
    }
    String periciaSelecionada = listaValida.first.id;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: Text(
                "Cobáia (Experimento)",
                style: TextStyle(color: corDestaque),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Escolha UMA perícia extra para receber treinamento (+5):",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: periciaSelecionada,
                    dropdownColor: const Color(0xFF1A1A1A),
                    style: const TextStyle(color: Colors.white),
                    decoration: EstiloParanormal.customInputDeco(
                      "Perícia Extra",
                      corDestaque,
                      Icons.star,
                    ),
                    items: listaValida
                        .map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(p.nome),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setDialogState(() => periciaSelecionada = val!),
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
                    backgroundColor: corFundoAfinidade,
                    foregroundColor: corTextoAfinidade,
                  ),
                  onPressed: () {
                    setState(() {
                      origemAtual = 'experimento';
                      poderesEscolhidos.removeWhere(
                        (p) =>
                            p.nome.startsWith("Experimento_") ||
                            p.nome.startsWith("Profetizado_") ||
                            p.nome.startsWith("Colegial_") ||
                            p.nome.startsWith("Revoltado_"),
                      );
                      poderesEscolhidos.add(
                        Poder(
                          nome: "Experimento_$periciaSelecionada",
                          tipo: "Origem",
                          descricao: "",
                        ),
                      );
                    });
                    atualizarFicha();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text("Confirmar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarDialogProfetizado() {
    String atributoSelecionado = 'PRE';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: Text(
                "Marca do Destino (Profetizado)",
                style: TextStyle(color: corDestaque),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Você recebe +1 em um atributo à sua escolha:",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: atributoSelecionado,
                    dropdownColor: const Color(0xFF1A1A1A),
                    style: const TextStyle(color: Colors.white),
                    decoration: EstiloParanormal.customInputDeco(
                      "Atributo Extra",
                      corDestaque,
                      Icons.star,
                    ),
                    items: const [
                      DropdownMenuItem(value: "AGI", child: Text("Agilidade")),
                      DropdownMenuItem(value: "FOR", child: Text("Força")),
                      DropdownMenuItem(value: "INT", child: Text("Intelecto")),
                      DropdownMenuItem(value: "PRE", child: Text("Presença")),
                      DropdownMenuItem(value: "VIG", child: Text("Vigor")),
                    ],
                    onChanged: (val) =>
                        setDialogState(() => atributoSelecionado = val!),
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
                    backgroundColor: corFundoAfinidade,
                    foregroundColor: corTextoAfinidade,
                  ),
                  onPressed: () {
                    setState(() {
                      origemAtual = 'profetizado';
                      if (atributoSelecionado == 'AGI') agi += 1;
                      if (atributoSelecionado == 'FOR') forc += 1;
                      if (atributoSelecionado == 'INT') inte += 1;
                      if (atributoSelecionado == 'PRE') pre += 1;
                      if (atributoSelecionado == 'VIG') vig += 1;

                      poderesEscolhidos.removeWhere(
                        (p) =>
                            p.nome.startsWith("Experimento_") ||
                            p.nome.startsWith("Profetizado_") ||
                            p.nome.startsWith("Colegial_") ||
                            p.nome.startsWith("Revoltado_"),
                      );
                      poderesEscolhidos.add(
                        Poder(
                          nome: "Profetizado_$atributoSelecionado",
                          tipo: "Origem",
                          descricao: "",
                        ),
                      );
                    });
                    atualizarFicha();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text("Confirmar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarDialogEngenheiro() {
    TextEditingController customItemController = TextEditingController();
    String itemSelecionado = "Arma";
    bool mostrarCustom = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: Text(
                "Ferramenta Favorita (Engenheiro)",
                style: TextStyle(color: corDestaque),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Escolha um item ou arma para ser sua ferramenta favorita. Ela receberá -1 na categoria e não contabilizará modificações como aumento de peso.",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: itemSelecionado,
                    dropdownColor: const Color(0xFF1A1A1A),
                    style: const TextStyle(color: Colors.white),
                    decoration: EstiloParanormal.customInputDeco(
                      "Item/Arma",
                      corDestaque,
                      Icons.handyman,
                    ),
                    items:
                        {
                          ...armas.map((a) => a.nome),
                          ...inventario.map((i) => i.nome),
                          "Outro (Digitar manualmente)",
                        }.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (val) {
                      setDialogState(() {
                        itemSelecionado = val!;
                        mostrarCustom = val == "Outro (Digitar manualmente)";
                      });
                    },
                  ),
                  if (mostrarCustom) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: customItemController,
                      style: const TextStyle(color: Colors.white),
                      decoration: EstiloParanormal.customInputDeco(
                        "Nome Exato do Item",
                        corDestaque,
                        Icons.edit,
                      ),
                    ),
                  ],
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
                    backgroundColor: corFundoAfinidade,
                    foregroundColor: corTextoAfinidade,
                  ),
                  onPressed: () {
                    String finalItem = mostrarCustom
                        ? customItemController.text.trim()
                        : itemSelecionado;
                    if (finalItem.isEmpty) return;

                    setState(() {
                      origemAtual = 'engenheiro';
                      poderesEscolhidos.removeWhere(
                        (p) =>
                            p.nome.startsWith("Experimento_") ||
                            p.nome.startsWith("Profetizado_") ||
                            p.nome.startsWith("Colegial_") ||
                            p.nome.startsWith("Revoltado_") ||
                            p.nome.startsWith("Engenheiro_"),
                      );
                      poderesEscolhidos.add(
                        Poder(
                          nome: "Engenheiro_$finalItem",
                          tipo: "Origem",
                          descricao: "",
                        ),
                      );
                    });
                    atualizarFicha();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text("Confirmar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarDialogAmnesico() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text(
            "Vislumbres do Passado (Amnésico)",
            style: TextStyle(color: corDestaque),
          ),
          content: const Text(
            "Aviso: Com esta origem, o aplicativo NÃO definirá suas perícias nem seu poder de origem automaticamente. \n\nNo momento em que o mestre decidir que você lembrou de algo na campanha, você deverá adicionar as perícias e os bônus manualmente editando a sua ficha.",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Voltar", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: corFundoAfinidade,
                foregroundColor: corTextoAfinidade,
              ),
              onPressed: () {
                setState(() {
                  origemAtual = 'amnésico';
                  poderesEscolhidos.removeWhere(
                    (p) =>
                        p.nome.startsWith("Experimento_") ||
                        p.nome.startsWith("Profetizado_") ||
                        p.nome.startsWith("Colegial_") ||
                        p.nome.startsWith("Revoltado_"),
                  );
                });
                atualizarFicha();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Entendi, Confirmar Origem"),
            ),
          ],
        );
      },
    );
  }
}
