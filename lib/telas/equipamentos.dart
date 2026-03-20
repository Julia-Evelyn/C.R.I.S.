// ignore_for_file: invalid_use_of_protected_member
part of 'ficha_agente.dart';

extension _EquipamentosFicha on _FichaAgenteState {
  Widget _buildAbaInventario(bool block, Color corDoPainel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SecaoFicha(
            titulo: "Inventário",
            corTema: corFundoAfinidade,
            corTexto: corTextoAfinidade,
            isMorte: afinidadeAtual == 'Morte',
            filhos: [
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: corDestaque, width: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Patente: ${patenteAtual.toUpperCase()}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: corDestaque,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Crédito: $limiteCredito",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 75,
                          child: TextFormField(
                            initialValue: prestigio.toString(),
                            enabled: !block,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            decoration: const InputDecoration(
                              labelText: "PP",
                              labelStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 8,
                              ),
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Color(0xFF1A1A1A),
                            ),
                            onChanged: (val) {
                              prestigio = int.tryParse(val) ?? 0;
                              atualizarFicha();
                            },
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.grey),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: ["I", "II", "III", "IV"].map((cat) {
                        int atual = usoCategoriaAtual[cat]!;
                        int max = limitesCategoria[cat]!;
                        bool excedeu = atual > max;
                        return Column(
                          children: [
                            Text(
                              "Cat $cat",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              "$atual / $max",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: excedeu
                                    ? Colors.redAccent
                                    : Colors.white,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Espaço: ${espacoOcupado.toString().replaceAll('.0', '')} / $espacoMaximo",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: espacoOcupado > espacoMaximo
                          ? Colors.redAccent
                          : Colors.white,
                    ),
                  ),
                  if (!block)
                    ElevatedButton.icon(
                      onPressed: () => _abrirCatalogoEquipamento(),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text("Equipamento"),
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
              const SizedBox(height: 16),
              if (inventario.isEmpty && armas.isEmpty)
                const Text(
                  "Inventário vazio.",
                  style: TextStyle(color: Colors.grey),
                ),

              // ================= ARMAS EXPANSÍVEIS =================
              ...armas.asMap().entries.map((entry) {
                int index = entry.key;
                var arma = entry.value;

                bool isProficiente =
                    arma.proficiencia == 'Simples' ||
                    (arma.proficiencia == 'Táticas' &&
                        classeAtual == 'combatente');
                String alertaProf = isProficiente
                    ? ""
                    : "\n⚠️ Não proficiente: -2d20 no Ataque";
                String modDano = "";

                int bonusDano = 0;
                if (arma.tipo == 'Corpo a Corpo' || arma.tipo == 'Arremesso') {
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

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151515),
                    border: Border.all(color: Colors.grey.shade900),
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
                        arma.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      subtitle: RichText(
                        text: TextSpan(
                          style: TextStyle(color: corDestaque, fontSize: 13),
                          children: [
                            const TextSpan(text: "Categoria: "),

                            TextSpan(
                              text:
                                  "${(trilhaAtual == 'aniquilador' && arma.modificacoes.contains('Arma Favorita')) ? _reduzirCategoriaString(arma.categoriaEfetiva, nex >= 99 ? 3 : (nex >= 40 ? 2 : 1)) : arma.categoriaEfetiva}   ",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const TextSpan(text: "Espaços: "),
                            TextSpan(
                              text: arma.espacoEfetivo.toString().replaceAll(
                                '.0',
                                '',
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Checkbox(
                              value: arma.equipado,
                              activeColor: corDestaque,
                              onChanged: (val) => _toggleEquiparArma(arma),
                            ),
                            Icon(
                              Icons.expand_more,
                              color: corDestaque.withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Divider(
                                color: corDestaque.withValues(alpha: 0.3),
                                thickness: 1,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Arma ${arma.tipo} • ${arma.proficiencia} • ${arma.empunhadura}",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Dano: ${arma.danoEfetivo}$modDano | Crítico: ${arma.margemAmeacaEfetiva}/x${arma.multiplicadorCritico}$alertaProf",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              if (arma.modificacoes.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    "Mods: ${arma.modificacoes.join(', ')}",
                                    style: TextStyle(
                                      color: corDestaque,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (!block)
                                    TextButton(
                                      onPressed: () {
                                        setState(() => armas.removeAt(index));
                                        _salvarSilencioso();
                                      },
                                      child: const Text(
                                        "Remover",
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    )
                                  else
                                    const SizedBox.shrink(),
                                  Row(
                                    children: [
                                      if (!block) ...[
                                        TextButton(
                                          onPressed: () =>
                                              _mostrarDialogEditarAtaque(arma),
                                          child: const Text(
                                            "Editar Teste",
                                            style: TextStyle(
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                        ),
                                        if (!block &&
                                            trilhaAtual == 'aniquilador' &&
                                            nex >= 10 &&
                                            !arma.modificacoes.contains(
                                              "Arma Favorita",
                                            ))
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                for (var a in armas) {
                                                  a.modificacoes =
                                                      List<String>.from(
                                                        a.modificacoes,
                                                      );
                                                  a.modificacoes.remove(
                                                    "Arma Favorita",
                                                  );
                                                }
                                                arma.modificacoes =
                                                    List<String>.from(
                                                      arma.modificacoes,
                                                    );
                                                arma.modificacoes.add(
                                                  "Arma Favorita",
                                                );

                                                atualizarFicha();
                                              });
                                              _salvarSilencioso();
                                              _mostrarNotificacao(
                                                "Arma Favorita definida!",
                                              );
                                            },
                                            child: const Text(
                                              "Tornar Favorita",
                                              style: TextStyle(
                                                color: Colors.orangeAccent,
                                              ),
                                            ),
                                          ),

                                        TextButton(
                                          onPressed: () =>
                                              mostrarDialogModificarEquipamento(
                                                context: context,
                                                equipamento: arma,
                                                corDestaque: corDestaque,
                                                corTema: corFundoAfinidade,
                                                corTexto: corTextoAfinidade,
                                                afinidadeAtual: afinidadeAtual,
                                                nex: nex,
                                                trilhaAtual: trilhaAtual,
                                                onAplicar: (mods) {
                                                  setState(() {
                                                    armas[index].modificacoes =
                                                        List.from(mods);
                                                    atualizarFicha();
                                                  });
                                                  _salvarSilencioso();
                                                },
                                              ),
                                          child: const Text(
                                            "Editar",
                                            style: TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // ================= ITENS EXPANSÍVEIS =================
              ...inventario.asMap().entries.map((entry) {
                int index = entry.key;
                var item = entry.value;

                bool isEquipavel =
                    item.descricao.toLowerCase().contains("proteção") ||
                    item.nome.toLowerCase().contains("vestimenta") ||
                    item.nome.toLowerCase().contains("escudo");

                String tipoItem = item.descricao.split('.').first;
                String descLimpa = item.descricao
                    .replaceFirst("$tipoItem.", "")
                    .trim();
                if (descLimpa.isEmpty) descLimpa = tipoItem;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151515),
                    border: Border.all(color: Colors.grey.shade900),
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
                        item.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: RichText(
                        text: TextSpan(
                          style: TextStyle(color: corDestaque, fontSize: 13),
                          children: [
                            const TextSpan(text: "Categoria: "),
                            TextSpan(
                              text: "${item.categoriaEfetiva}   ",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: "Espaços: "),
                            TextSpan(
                              text: item.espacoEfetivo.toString().replaceAll(
                                '.0',
                                '',
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: isEquipavel
                          ? SizedBox(
                              width: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Checkbox(
                                    value: item.equipado,
                                    activeColor: corDestaque,
                                    onChanged: (val) =>
                                        _toggleEquiparItem(item),
                                  ),
                                  Icon(
                                    Icons.expand_more,
                                    color: corDestaque.withValues(alpha: 0.5),
                                  ),
                                ],
                              ),
                            )
                          : Icon(
                              Icons.expand_more,
                              color: corDestaque.withValues(alpha: 0.5),
                            ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Divider(
                                color: corDestaque.withValues(alpha: 0.3),
                                thickness: 1,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                tipoItem,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                descLimpa,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),

                              if (item.modificacoes.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    "Mods: ${item.modificacoes.join(', ')}",
                                    style: TextStyle(
                                      color: corDestaque,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (!block)
                                    TextButton(
                                      onPressed: () {
                                        setState(
                                          () => inventario.removeAt(index),
                                        );
                                        _salvarSilencioso();
                                      },
                                      child: const Text(
                                        "Remover",
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    )
                                  else
                                    const SizedBox.shrink(),
                                  Row(
                                    children: [
                                      if (!block)
                                        TextButton(
                                          onPressed: () =>
                                              mostrarDialogModificarEquipamento(
                                                context: context,
                                                equipamento: item,
                                                corDestaque: corDestaque,
                                                corTema: corFundoAfinidade,
                                                corTexto: corTextoAfinidade,
                                                afinidadeAtual: afinidadeAtual,
                                                nex: nex,
                                                trilhaAtual: trilhaAtual,
                                                onAplicar: (mods) {
                                                  setState(() {
                                                    inventario[index]
                                                            .modificacoes =
                                                        List.from(mods);
                                                    atualizarFicha();
                                                  });
                                                  _salvarSilencioso();
                                                },
                                              ),
                                          child: const Text(
                                            "Editar",
                                            style: TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  void _abrirCatalogoEquipamento({String filtroInicial = "Todos"}) {
    String filtroAtual = filtroInicial;
    List<String> subFiltrosAtivos = [];
    String busca = "";
    Color corTemaLocal = corFundoAfinidade;
    Color corLetra = corTextoAfinidade;
    Color corDestaqueLocal = corDestaque;

    List<String> categorias = [
      "Todos",
      "Armas",
      "Acessórios",
      "Explosivos",
      "Itens Operacionais",
      "Munições",
      "Proteções",
      "Itens Paranormais",
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Widget buildFiltroArma(String label, List<String> opcoes) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Text(
                      label.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: opcoes.map((sub) {
                      bool isSelected = subFiltrosAtivos.contains(sub);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(
                            sub,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey.shade400,
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: Colors.grey.shade300,
                          backgroundColor: const Color(0xFF151515),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.grey.shade300
                                : Colors.grey.shade800,
                          ),
                          onSelected: (val) {
                            setDialogState(() {
                              if (isSelected) {
                                subFiltrosAtivos.remove(sub);
                              } else {
                                subFiltrosAtivos.removeWhere(
                                  (e) => opcoes.contains(e),
                                );
                                subFiltrosAtivos.add(sub);
                              }
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            }

            List<dynamic> todosEquipamentos = [
              ...catalogoArmasOrdem,
              ...catalogoItensOrdem,
            ];
            List<dynamic> filtrados = todosEquipamentos.where((eq) {
              if (busca.isNotEmpty &&
                  !eq.nome.toLowerCase().contains(busca.toLowerCase())) {
                return false;
              }
              if (filtroAtual != "Todos") {
                if (filtroAtual == "Armas") {
                  if (eq is! Arma) return false;
                  for (String sub in subFiltrosAtivos) {
                    if (["Simples", "Táticas", "Pesadas"].contains(sub) &&
                        eq.proficiencia != sub) {
                      return false;
                    }
                    if (["Corpo a Corpo", "Fogo", "Disparo"].contains(sub) &&
                        eq.tipo != sub) {
                      return false;
                    }
                    if (["Leve", "Uma Mão", "Duas Mãos"].contains(sub) &&
                        eq.empunhadura != sub) {
                      return false;
                    }
                  }
                } else {
                  if (eq is Arma) return false;
                  if (eq is ItemInventario) {
                    if (filtroAtual == "Acessórios" &&
                        (!eq.descricao.contains("Acessório") &&
                            !eq.nome.contains("Vestimenta"))) {
                      return false;
                    }
                    if (filtroAtual == "Explosivos" &&
                        !eq.descricao.contains("Explosivo")) {
                      return false;
                    }
                    if (filtroAtual == "Itens Operacionais" &&
                        !eq.descricao.contains("Item Operacional")) {
                      return false;
                    }
                    if (filtroAtual == "Munições" &&
                        !eq.descricao.contains("Munição")) {
                      return false;
                    }
                    if (filtroAtual == "Proteções" &&
                        !eq.descricao.contains("Proteção")) {
                      return false;
                    }
                    if (filtroAtual == "Itens Paranormais" &&
                        !eq.descricao.contains("Item Paranormal")) {
                      return false;
                    }
                  }
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
                        Icon(
                          Icons.inventory_2,
                          color: corDestaqueLocal,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "ARSENAL",
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
                        "Pesquisar equipamento...",
                        corDestaqueLocal,
                        Icons.search,
                      ),
                      onChanged: (val) => setDialogState(() => busca = val),
                    ),
                    const SizedBox(height: 12),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categorias
                            .map(
                              (cat) => Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(
                                    cat,
                                    style: TextStyle(
                                      color: filtroAtual == cat
                                          ? corLetra
                                          : Colors.grey.shade400,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  selected: filtroAtual == cat,
                                  onSelected: (val) => setDialogState(() {
                                    filtroAtual = cat;
                                    subFiltrosAtivos.clear();
                                  }),
                                  selectedColor: corTemaLocal,
                                  backgroundColor: const Color(0xFF0D0D0D),
                                  side: BorderSide(
                                    color: filtroAtual == cat
                                        ? corDestaqueLocal
                                        : Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    if (filtroAtual == "Armas") ...[
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildFiltroArma("Proficiência", [
                              "Simples",
                              "Táticas",
                              "Pesadas",
                            ]),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.grey.shade800,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            buildFiltroArma("Tipo", [
                              "Corpo a Corpo",
                              "Fogo",
                              "Disparo",
                            ]),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.grey.shade800,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            buildFiltroArma("Empunhadura", [
                              "Leve",
                              "Uma Mão",
                              "Duas Mãos",
                            ]),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    const SizedBox(height: 8),
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
                                  "Equipamento não encontrado",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filtrados.length,
                                itemBuilder: (context, index) {
                                  var eq = filtrados[index];
                                  bool isArma = eq is Arma;
                                  String tipoItem = "";
                                  String descLimpa = "";
                                  if (!isArma) {
                                    tipoItem = eq.descricao.split('.').first;
                                    descLimpa = eq.descricao
                                        .replaceFirst("$tipoItem.", "")
                                        .trim();
                                    if (descLimpa.isEmpty) descLimpa = tipoItem;
                                  }

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF151515),
                                      border: Border.all(
                                        color: Colors.grey.shade900,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        dividerColor: Colors.transparent,
                                      ),
                                      child: ExpansionTile(
                                        iconColor: corDestaqueLocal,
                                        collapsedIconColor: Colors.grey,
                                        tilePadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 4,
                                        ),
                                        title: isArma
                                            ? RichText(
                                                text: TextSpan(
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: "${eq.nome}  ",
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          "${eq.proficiencia} - ${eq.tipo} - ${eq.empunhadura}",
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Text(
                                                eq.nome,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                        subtitle: RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              color: corDestaqueLocal,
                                              fontSize: 13,
                                            ),
                                            children: isArma
                                                ? [
                                                    const TextSpan(
                                                      text: "Categoria: ",
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          "${eq.categoria}   ",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const TextSpan(
                                                      text: "Dano: ",
                                                    ),
                                                    TextSpan(
                                                      text: "${eq.dano}   ",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const TextSpan(
                                                      text: "Crítico: ",
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          "x${eq.multiplicadorCritico}   ",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const TextSpan(
                                                      text: "Espaços: ",
                                                    ),
                                                    TextSpan(
                                                      text: eq.espaco
                                                          .toString()
                                                          .replaceAll('.0', ''),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ]
                                                : [
                                                    const TextSpan(
                                                      text: "Categoria: ",
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          "${eq.categoria}   ",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const TextSpan(
                                                      text: "Espaços: ",
                                                    ),
                                                    TextSpan(
                                                      text: eq.espaco
                                                          .toString()
                                                          .replaceAll('.0', ''),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                          ),
                                        ),
                                        trailing: SizedBox(
                                          width: 90,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.add_circle,
                                                  color: corDestaqueLocal,
                                                  size: 28,
                                                ),
                                                onPressed: () {
                                                  if (eq is ItemInventario &&
                                                      (eq.nome ==
                                                              "Catalisador ritualístico" ||
                                                          eq.nome.contains(
                                                            "(elemento)",
                                                          ))) {
                                                    if (eq.nome ==
                                                        "Catalisador ritualístico") {
                                                      mostrarDialogCatalisador(
                                                        context: context,
                                                        corDestaque:
                                                            corDestaqueLocal,
                                                        corTema: corTemaLocal,
                                                        corTexto: corLetra,
                                                        afinidadeAtual:
                                                            afinidadeAtual,
                                                        onConfirmar: (item) {
                                                          _aplicarTagsOrigemItem(
                                                            item,
                                                          );
                                                          setState(
                                                            () => inventario
                                                                .add(item),
                                                          );
                                                          atualizarFicha();
                                                          _salvarSilencioso();
                                                          _mostrarNotificacao(
                                                            "Catalisador adicionado!",
                                                          );
                                                        },
                                                      );
                                                    } else {
                                                      mostrarDialogElementoItem(
                                                        context: context,
                                                        itemBase: eq,
                                                        corDestaque:
                                                            corDestaqueLocal,
                                                        corTema: corTemaLocal,
                                                        corTexto: corLetra,
                                                        afinidadeAtual:
                                                            afinidadeAtual,
                                                        onConfirmar: (item) {
                                                          _aplicarTagsOrigemItem(
                                                            item,
                                                          );
                                                          setState(
                                                            () => inventario
                                                                .add(item),
                                                          );
                                                          atualizarFicha();
                                                          _salvarSilencioso();
                                                          _mostrarNotificacao(
                                                            "${item.nome} adicionado!",
                                                          );
                                                        },
                                                      );
                                                    }
                                                  } else {
                                                    if (eq is Arma) {
                                                      setState(
                                                        () => armas.add(
                                                          Arma(
                                                            nome: eq.nome,
                                                            tipo: eq.tipo,
                                                            dano: eq.dano,
                                                            margemAmeaca:
                                                                eq.margemAmeaca,
                                                            multiplicadorCritico:
                                                                eq.multiplicadorCritico,
                                                            categoria:
                                                                eq.categoria,
                                                            espaco: eq.espaco,
                                                            proficiencia:
                                                                eq.proficiencia,
                                                            empunhadura:
                                                                eq.empunhadura,
                                                            descricao:
                                                                eq.descricao,
                                                          ),
                                                        ),
                                                      );
                                                      _salvarSilencioso();
                                                      _mostrarNotificacao(
                                                        "Arma adicionada!",
                                                      );
                                                    } else {
                                                      _processarNovoItem(
                                                        ItemInventario(
                                                          nome: eq.nome,
                                                          categoria:
                                                              eq.categoria,
                                                          espaco: eq.espaco,
                                                          descricao:
                                                              eq.descricao,
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                              ),
                                              Icon(
                                                Icons.expand_more,
                                                color: corDestaqueLocal
                                                    .withValues(alpha: 0.5),
                                              ),
                                            ],
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
                                                  color: corDestaqueLocal
                                                      .withValues(alpha: 0.3),
                                                  thickness: 1,
                                                ),
                                                const SizedBox(height: 8),
                                                if (isArma) ...[
                                                  Text(
                                                    eq.descricao.isNotEmpty
                                                        ? eq.descricao
                                                        : "Nenhuma descrição fornecida.",
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ] else ...[
                                                  Text(
                                                    tipoItem,
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    descLimpa,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
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
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.handyman, size: 18),
                            label: const Text(
                              "CRIAR ITEM",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.grey.shade800),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              mostrarDialogCriacaoManual(
                                context: context,
                                isArma: false,
                                corDestaque: corDestaqueLocal,
                                corTema: corTemaLocal,
                                corTexto: corLetra,
                                afinidadeAtual: afinidadeAtual,
                                onVoltar: () => _abrirCatalogoEquipamento(
                                  filtroInicial: filtroAtual,
                                ),
                                onConfirmar: (novoItem) {
                                  _processarNovoItem(novoItem);
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.colorize, size: 18),
                            label: const Text(
                              "CRIAR ARMA",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.grey.shade800),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              mostrarDialogCriacaoManual(
                                context: context,
                                isArma: true,
                                corDestaque: corDestaqueLocal,
                                corTema: corTemaLocal,
                                corTexto: corLetra,
                                afinidadeAtual: afinidadeAtual,
                                onVoltar: () => _abrirCatalogoEquipamento(
                                  filtroInicial: filtroAtual,
                                ),
                                onConfirmar: (novaArma) {
                                  setState(() => armas.add(novaArma));
                                  _salvarSilencioso();
                                  _mostrarNotificacao(
                                    "Arma criada e adicionada!",
                                  );
                                },
                              );
                            },
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

  void _aplicarTagsOrigemItem(ItemInventario item) {
    item.modificacoes = List.from(item.modificacoes);

    // Engenheiro: Verifica se é o item escolhido na Origem
    if (origemAtual == 'engenheiro' &&
        poderesEscolhidos.any((p) => p.nome == "Engenheiro_${item.nome}")) {
      if (!item.modificacoes.contains("Ferramenta Favorita")) {
        item.modificacoes.add("Ferramenta Favorita");
      }
    }
    // Verifica se é um Explosivo de Dano
    if (origemAtual == 'blaster' &&
        item.descricao.toLowerCase().contains("explosivo")) {
      if (item.descricao.toLowerCase().contains("dano") ||
          item.descricao.toLowerCase().contains("d6") ||
          item.descricao.toLowerCase().contains("d8")) {
        if (!item.modificacoes.contains("Explosão Solidária")) {
          item.modificacoes.add("Explosão Solidária");
        }
      }
    }
  }

  void _processarNovoItem(ItemInventario novoItem) {
    // 1. Bloqueio de Carga Absoluta (Dobro do limite)
    if (espacoOcupado + novoItem.espacoEfetivo > espacoMaximo * 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "LIMITE ABSOLUTO! Você não tem força para carregar mais esse item.",
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    _aplicarTagsOrigemItem(novoItem);
    String nomeLower = novoItem.nome.toLowerCase();

    // Interceptador de Kits de Perícia
    if (nomeLower == "kit de perícia" || nomeLower == "kit") {
      _mostrarDialogEscolherKit(novoItem);
      return;
    }

    // Processamento normal de Vestimentas
    if (nomeLower.contains("vestimenta") || nomeLower.contains("utensílio")) {
      bool isVestimenta = nomeLower.contains("vestimenta");
      mostrarDialogEscolherPericiaAprimoramento(
        context: context,
        itemBase: novoItem,
        listaPericias: listaPericias,
        corDestaque: corDestaque,
        corTema: corFundoAfinidade,
        corTexto: corTextoAfinidade,
        afinidadeAtual: afinidadeAtual,
        isVestimenta: isVestimenta,
        onConfirmar: (itemConfigurado) {
          setState(() {
            inventario.add(itemConfigurado);
            atualizarFicha();
          });
          _salvarSilencioso();
          _mostrarNotificacao(
            "${isVestimenta ? 'Vestimenta' : 'Utensílio'} adicionado(a)!",
          );
        },
      );
    } else {
      setState(() => inventario.add(novoItem));
      _salvarSilencioso();
      _mostrarNotificacao("Item adicionado!");
    }
  }

  // Dialog de Seleção do Kit
  void _mostrarDialogEscolherKit(ItemInventario itemBase) {
    String kitEscolhido = 'Medicina';

    final listaKits = ['Crime', 'Enganação', 'Medicina', 'Tecnologia'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: Text(
                "Especialidade do Kit",
                style: TextStyle(color: corDestaque),
              ),
              content: RadioGroup<String>(
                groupValue: kitEscolhido,
                onChanged: (val) {
                  setDialogState(() => kitEscolhido = val!);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: listaKits.map((kit) {
                    return RadioListTile<String>(
                      title: Text(
                        kit,
                        style: const TextStyle(color: Colors.white),
                      ),
                      value: kit,
                      activeColor: corDestaque,
                    );
                  }).toList(),
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
                    backgroundColor: corFundoAfinidade,
                    foregroundColor: corTextoAfinidade,
                  ),
                  onPressed: () {
                    setState(() {
                      itemBase.nome = "Kit de $kitEscolhido";
                      inventario.add(itemBase);
                      atualizarFicha();
                    });
                    _salvarSilencioso();
                    Navigator.pop(context);
                    _mostrarNotificacao("${itemBase.nome} adicionado!");
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

  void _toggleEquiparItem(ItemInventario item) {
    bool isVestimenta = item.nome.toLowerCase().contains("vestimenta");
    bool isProtecao = item.descricao.toLowerCase().contains("proteção");
    bool isEscudo = item.nome.toLowerCase().contains("escudo");

    if (!item.equipado) {
      if (isVestimenta) {
        int equipadas = inventario
            .where(
              (i) => i.equipado && i.nome.toLowerCase().contains("vestimenta"),
            )
            .length;
        int limiteVestimentas =
            poderesEscolhidos.any((p) => p.nome == "Mochileiro") ? 3 : 2;
        if (equipadas >= limiteVestimentas) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Limite: Você só pode vestir $limiteVestimentas vestimentas ao mesmo tempo!",
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }
      }
      if (isProtecao) {
        if (isEscudo) {
          if (maosOcupadas + 1 > 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Limite: Você não tem mãos livres suficientes para equipar o Escudo!",
                ),
                backgroundColor: Colors.redAccent,
              ),
            );
            return;
          }
          if (inventario.any(
            (i) => i.equipado && i.nome.toLowerCase().contains("escudo"),
          )) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Limite: Você já tem um escudo equipado!"),
                backgroundColor: Colors.redAccent,
              ),
            );
            return;
          }
        } else {
          if (inventario.any(
            (i) =>
                i.equipado &&
                i.descricao.toLowerCase().contains("proteção") &&
                !i.nome.toLowerCase().contains("escudo"),
          )) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Limite: Você só pode usar 1 proteção por vez! (Mas pode usar 1 Escudo junto)",
                ),
                backgroundColor: Colors.redAccent,
              ),
            );
            return;
          }
        }
      }
    }
    setState(() {
      item.equipado = !item.equipado;
      atualizarFicha();
    });
  }

  void _toggleEquiparArma(Arma arma) {
    if (!arma.equipado) {
      int custoMaos = arma.empunhadura == 'Duas Mãos' ? 2 : 1;
      if (maosOcupadas + custoMaos > 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Limite: Você não tem mãos livres suficientes para empunhar essa arma!",
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }
    setState(() {
      arma.equipado = !arma.equipado;
      atualizarFicha();
    });
  }
}
