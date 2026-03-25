// ignore_for_file: invalid_use_of_protected_member
part of 'ficha_agente.dart';

extension _OrigensFicha on _FichaAgenteState {
  void _mostrarDialogOrigens() {
    String busca = "";
    String? origemExpandida;

    Color corTemaLocal = corFundoAfinidade;
    Color corLetra = corTextoAfinidade;
    Color corDestaqueLocal = corDestaque;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            List<MapEntry<String, DadosOrigem>> filtrados = dadosOrigens.entries
                .where((entry) {
                  if (busca.isNotEmpty &&
                      !entry.value.nome.toLowerCase().contains(
                        busca.toLowerCase(),
                      )) {
                    return false;
                  }
                  return true;
                })
                .toList();
            filtrados.sort((a, b) => a.value.nome.compareTo(b.value.nome));

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
                        Icon(
                          Icons.history_edu,
                          color: corDestaqueLocal,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "ORIGENS",
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
                        "Pesquisar origem...",
                        corDestaqueLocal,
                        Icons.search,
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) => setDialogState(() => busca = val),
                    ),
                    const SizedBox(height: 16),

                    if (busca.isEmpty) ...[
                      ListTile(
                        leading: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.redAccent,
                        ),
                        title: const Text(
                          "Nenhuma Origem (--)",
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          setState(() {
                            origemAtual = '--';
                            // Limpa todos os poderes marcados como 'Origem'
                            poderesEscolhidos.removeWhere(
                              (p) => p.tipo == "Origem",
                            );
                            atualizarFicha();
                          });
                          _salvarSilencioso();
                          Navigator.pop(context);
                        },
                      ),
                      const Divider(color: Colors.grey),
                    ],

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
                                  "Nenhuma origem encontrada.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filtrados.length,
                                itemBuilder: (context, index) {
                                  var entry = filtrados[index];
                                  DadosOrigem org = entry.value;
                                  String keyOrigem = entry.key;
                                  bool isExpanded =
                                      origemExpandida == keyOrigem;
                                  List<String> nomesPericias = org.pericias.map(
                                    (id) {
                                      try {
                                        return listaPericias
                                            .firstWhere((p) => p.id == id)
                                            .nome;
                                      } catch (e) {
                                        return id;
                                      }
                                    },
                                  ).toList();

                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade900,
                                        ),
                                      ),
                                      color: isExpanded
                                          ? Colors.grey.shade900.withValues(
                                              alpha: 0.5,
                                            )
                                          : Colors.transparent,
                                    ),
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        dividerColor: Colors.transparent,
                                      ),
                                      child: ExpansionTile(
                                        title: Text(
                                          org.nome,
                                          style: TextStyle(
                                            color: isExpanded
                                                ? corDestaqueLocal
                                                : Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          isExpanded
                                              ? "Perícias: ${nomesPericias.join(', ')}"
                                              : org.nomeHabilidade,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        iconColor: corDestaqueLocal,
                                        collapsedIconColor: Colors.grey,
                                        onExpansionChanged: (expanded) {
                                          setDialogState(() {
                                            origemExpandida = expanded
                                                ? keyOrigem
                                                : null;
                                          });
                                        },
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
                                                const Divider(
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  "Poder: ${org.nomeHabilidade}",
                                                  style: TextStyle(
                                                    color: corDestaqueLocal,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  org.descHabilidade,
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 13,
                                                    height: 1.4,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                    backgroundColor:
                                                        corTemaLocal,
                                                    foregroundColor: corLetra,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    side:
                                                        afinidadeAtual ==
                                                            'Morte'
                                                        ? const BorderSide(
                                                            color:
                                                                Colors.white54,
                                                          )
                                                        : null,
                                                  ),
                                                  onPressed: () {
                                                    // LIMPA TRIGGERS ANTIGOS DE ORIGEM AO TROCAR
                                                    poderesEscolhidos
                                                        .removeWhere(
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
                                                              ) ||
                                                              p.nome.startsWith(
                                                                "Engenheiro_",
                                                              ),
                                                        );

                                                    // == INTERCEPTADORES DE ORIGEM ==
                                                    if (keyOrigem ==
                                                        'cultista_arrependido') {
                                                      Navigator.pop(context);
                                                      _mostrarDialogPoderCultista();
                                                    } else if (keyOrigem ==
                                                        'operario') {
                                                      Navigator.pop(context);
                                                      _mostrarDialogOperario();
                                                    } else if (keyOrigem ==
                                                        'experimento') {
                                                      Navigator.pop(context);
                                                      _mostrarDialogExperimento();
                                                    } else if (keyOrigem ==
                                                        'profetizado') {
                                                      Navigator.pop(context);
                                                      _mostrarDialogProfetizado();
                                                    } else if (keyOrigem ==
                                                        'engenheiro') {
                                                      Navigator.pop(context);
                                                      _mostrarDialogEngenheiro();
                                                    } else if (keyOrigem ==
                                                        'amnésico') {
                                                      Navigator.pop(context);
                                                      _mostrarDialogAmnesico();
                                                    } else {
                                                      setState(() {
                                                        origemAtual = keyOrigem;
                                                        atualizarFicha();
                                                      });
                                                      _salvarSilencioso();
                                                      Navigator.pop(context);
                                                    }
                                                  },
                                                  child: const Text(
                                                    "ESCOLHER ORIGEM",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
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

  void _mostrarDialogPoderCultista() {
    String busca = "";
    String filtroParanormal = "Conhecimento";

    Color corTemaLocal = corFundoAfinidade;
    Color corLetra = corTextoAfinidade;
    Color corDestaqueLocal = corDestaque;

    List<String> categoriasParanormais = [
      "Conhecimento",
      "Energia",
      "Morte",
      "Sangue",
    ];

    showDialog(
      context: context,
      barrierDismissible:
          false, // Obriga a escolher um poder ou cancelar a origem
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            List<Poder> listaAtiva = [];
            if (filtroParanormal == "Conhecimento") {
              listaAtiva = catalogoPoderesConhecimento;
            } else if (filtroParanormal == "Energia") {
              listaAtiva = catalogoPoderesEnergia;
            } else if (filtroParanormal == "Morte") {
              listaAtiva = catalogoPoderesMorte;
            } else if (filtroParanormal == "Sangue") {
              listaAtiva = catalogoPoderesSangue;
            }

            List<Poder> filtrados = listaAtiva.where((p) {
              if (busca.isNotEmpty &&
                  !p.nome.toLowerCase().contains(busca.toLowerCase())) {
                return false;
              }
              // Oculta poderes que o jogador já tem
              if (poderesEscolhidos.any((poder) => poder.nome == p.nome)) {
                return false;
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
                        Expanded(
                          child: Text(
                            "PODER DO CULTISTA",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: corDestaqueLocal,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "A origem Cultista Arrependido fornece um poder paranormal grátis. Escolha o seu abaixo:",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: EstiloParanormal.customInputDeco(
                        "Pesquisar poder...",
                        corDestaqueLocal,
                        Icons.search,
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) => setDialogState(() => busca = val),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categoriasParanormais.map((cat) {
                          Color corElemento;
                          switch (cat) {
                            case 'Sangue':
                              corElemento = const Color(0xFF990000);
                              break;
                            case 'Energia':
                              corElemento = const Color(0xFF9900FF);
                              break;
                            case 'Conhecimento':
                              corElemento = const Color(0xFFFFB300);
                              break;
                            case 'Morte':
                            default:
                              corElemento = Colors.black;
                              break;
                          }

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
                              onSelected: (val) =>
                                  setDialogState(() => filtroParanormal = cat),
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
                                  "Nenhum poder encontrado.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filtrados.length,
                                itemBuilder: (context, index) {
                                  var p = filtrados[index];

                                  Color corTitulo = Colors.white;
                                  if (filtroParanormal == 'Sangue') {
                                    corTitulo = const Color(0xFF990000);
                                  } else if (filtroParanormal == 'Energia') {
                                    corTitulo = const Color(0xFF9900FF);
                                  } else if (filtroParanormal ==
                                      'Conhecimento') {
                                    corTitulo = const Color(0xFFFFB300);
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
                                        p.nome,
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
                                      trailing: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: corTemaLocal,
                                          foregroundColor: corLetra,
                                          side: afinidadeAtual == 'Morte'
                                              ? const BorderSide(
                                                  color: Colors.white54,
                                                )
                                              : null,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            origemAtual =
                                                'cultista_arrependido';
                                            poderesEscolhidos.add(p);
                                            atualizarFicha();
                                          });
                                          _salvarSilencioso();
                                          Navigator.pop(context);
                                          _mostrarNotificacao(
                                            "Origem e Poder aplicados!",
                                          );
                                        },
                                        child: const Text(
                                          "ESCOLHER",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarDialogOperario() {
    List<Arma> armasValidas = catalogoArmasOrdem
        .where(
          (a) => a.proficiencia == 'Simples' || a.proficiencia == 'Táticas',
        )
        .toList();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text(
            "Ferramenta de Trabalho",
            style: TextStyle(color: corDestaque),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: armasValidas.length,
              itemBuilder: (ctx, i) {
                var arma = armasValidas[i];
                return ListTile(
                  title: Text(
                    arma.nome,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Arma novaArma = Arma(
                      nome: arma.nome,
                      tipo: arma.tipo,
                      dano: arma.dano,
                      margemAmeaca: arma.margemAmeaca,
                      multiplicadorCritico: arma.multiplicadorCritico,
                      categoria: arma.categoria,
                      espaco: arma.espaco,
                      proficiencia: arma.proficiencia,
                      empunhadura: arma.empunhadura,
                      descricao: arma.descricao,
                      modificacoes: ["Ferramenta de Trabalho"],
                    );

                    setState(() {
                      origemAtual = 'operario';
                      armas.add(novaArma);
                      atualizarFicha();
                    });

                    _salvarSilencioso();
                    Navigator.pop(context);
                    _mostrarNotificacao(
                      "Origem aplicada e Ferramenta adicionada!",
                    );
                  },
                );
              },
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
          ],
        );
      },
    );
  }

  void _mostrarDialogExperimento() {
    List<String> idsFisicos = [
      'acrobacia',
      'atletismo',
      'crime',
      'fortitude',
      'furtividade',
      'iniciativa',
      'luta',
      'pilotagem',
      'pontaria',
      'reflexos',
    ];
    List<Pericia> periciasValidas = listaPericias
        .where((p) => idsFisicos.contains(p.id))
        .toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text(
            "Mutação (Experimento)",
            style: TextStyle(color: corDestaque),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: periciasValidas.length,
              itemBuilder: (ctx, i) {
                var p = periciasValidas[i];
                return ListTile(
                  title: Text(
                    p.nome,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    setState(() {
                      origemAtual = 'experimento';
                      poderesEscolhidos.add(
                        Poder(
                          nome: "Experimento_${p.id}",
                          tipo: "Origem",
                          descricao: "",
                        ),
                      );
                      atualizarFicha();
                    });
                    _salvarSilencioso();
                    Navigator.pop(context);
                    _mostrarNotificacao("Origem Experimento aplicada!");
                  },
                );
              },
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
          ],
        );
      },
    );
  }

  void _mostrarDialogProfetizado() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text(
            "Premonição (Profetizado)",
            style: TextStyle(color: corDestaque),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: listaPericias.length,
              itemBuilder: (ctx, i) {
                var p = listaPericias[i];
                return ListTile(
                  title: Text(
                    p.nome,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    setState(() {
                      origemAtual = 'profetizado';
                      poderesEscolhidos.add(
                        Poder(
                          nome: "Profetizado_${p.id}",
                          tipo: "Origem",
                          descricao: "",
                        ),
                      );
                      var pericia = listaPericias.firstWhere(
                        (per) => per.id == p.id,
                      );
                      if (pericia.treino < 5) pericia.treino = 5;
                      pericia.daOrigem = true;

                      var vontade = listaPericias.firstWhere(
                        (v) => v.id == 'vontade',
                      );
                      if (vontade.treino < 5) vontade.treino = 5;
                      vontade.daOrigem = true;
                      atualizarFicha();
                    });
                    _salvarSilencioso();
                    Navigator.pop(context);
                    _mostrarNotificacao("Origem Profetizado aplicada!");
                  },
                );
              },
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
          ],
        );
      },
    );
  }

  void _mostrarDialogEngenheiro() {
    // Filtra itens do catálogo que tenham categoria maior que zero (I, II, III, etc)
    List<ItemInventario> itensValidos = catalogoItensOrdem
        .where((item) => item.categoria != '0' && item.categoria != '--')
        .toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text(
            "Ferramenta Favorita (Engenheiro)",
            style: TextStyle(color: corDestaque),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: itensValidos.length,
              itemBuilder: (ctx, i) {
                var item = itensValidos[i];
                return ListTile(
                  title: Text(
                    item.nome,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "Categoria base: ${item.categoria}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  onTap: () {
                    setState(() {
                      origemAtual = 'engenheiro';
                      poderesEscolhidos.add(
                        Poder(
                          nome: "Engenheiro_${item.nome}",
                          tipo: "Origem",
                          descricao: "",
                        ),
                      );
                      atualizarFicha();
                    });
                    _salvarSilencioso();
                    Navigator.pop(context);
                    _mostrarNotificacao("Origem Engenheiro aplicada!");
                  },
                );
              },
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
          ],
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
                        p.nome.startsWith("Revoltado_") ||
                        p.nome.startsWith("Engenheiro_"),
                  );
                });
                atualizarFicha();
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
