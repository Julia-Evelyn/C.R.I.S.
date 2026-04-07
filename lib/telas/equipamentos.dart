// ignore_for_file: invalid_use_of_protected_member
part of 'ficha_agente.dart';

extension _EquipamentosFicha on _FichaAgenteState {
  // Dicionário Massivo de Descrições Mundanas e Maldições
  Map<String, String> get _descricoesModsEMaldicoes => {
    // ARMAS
    "Alongada":
        "Com um cano mais longo, que aumenta a precisão dos disparos, a arma fornece +2 nos testes de ataque.",
    "Calibre Grosso":
        "A arma é modificada para disparar munição de maior calibre, aumentando seu dano em mais um dado do mesmo tipo.",
    "Certeira":
        "Fabricada para ser mais precisa e balanceada, a arma fornece +2 nos testes de ataque.",
    "Compensador":
        "Apenas para armas automáticas. Anula a penalidade em testes de ataque por disparar rajadas.",
    "Cruel":
        "A arma possui a lâmina especialmente afiada ou foi fabricada com materiais mais densos. Fornece +2 nas rolagens de dano.",
    "Discreta":
        "Oculta facilmente. Fornece +5 em testes de Crime para ser ocultada (pode testar destreinado) e reduz o número de espaços ocupados em 1.",
    "Dum Dum":
        "Apenas balas curtas e longas. Aumenta o multiplicador de crítico em +1.",
    "Explosiva":
        "Apenas balas curtas e longas. Aumenta o dano causado em +2d6.",
    "Ferrolho Automático":
        "O mecanismo de ação da arma é modificado para disparar várias vezes em sequência. A arma se torna automática.",
    "Mira Laser":
        "Cria um reflexo luminoso na mira. Aumenta a margem de ameaça em +2.",
    "Mira Telescópica":
        "Aumenta o alcance da arma em uma categoria e permite que Ataque Furtivo seja usado em qualquer alcance.",
    "Perigosa":
        "Possui a lâmina afiada como navalha ou material maciço. Aumenta a margem de ameaça em +2.",
    "Silenciador":
        "Reduz em –5 a penalidade em Furtividade para se esconder no mesmo turno em que atacou com a arma de fogo.",
    "Tática":
        "Possui bandoleira e acessórios. Você pode sacar a arma como uma ação livre.",
    "Visão de Calor":
        "Sobrepõe imagens em infravermelho. Ao disparar com a arma, você ignora qualquer camuflagem do alvo.",

    // PROTEÇÕES
    "Antibombas":
        "Amortece estilhaços e explosões. Fornece +5 em testes de resistência contra efeitos de área. (Apenas proteções pesadas).",
    "Blindada":
        "Aumenta a resistência a dano para 5 e o espaço ocupado em +1. (Apenas proteções pesadas).",
    "Reforçada":
        "Aumenta a Defesa fornecida em +2 e o espaço ocupado em +1. (Não pode ser discreta junto).",

    // ACESSÓRIOS
    "Aprimorado":
        "O bônus em perícia concedido pelo acessório aumenta para +5.",
    "Discreto":
        "O item é miniaturizado. Reduz espaços em 1, fornece +5 em Crime para ocultar (mesmo destreinado).",
    "Função Adicional":
        "O acessório fornece +2 em uma perícia adicional à sua escolha.",
    "Instrumental":
        "O acessório pode ser usado como um kit de perícia específico.",

    // MALDIÇÕES
    "Antielemento":
        "Arma letal contra um elemento. Quando ataca uma criatura desse elemento, gaste 2 PE para causar +4d8 de dano.",
    "Ritualística":
        "Armazena um ritual na arma (gasta os PE na hora). Ao acertar ataque, descarrega o ritual como ação livre.",
    "Senciente":
        "Gaste ação de movimento e 2 PE: a arma flutua e ataca sozinha (1/rodada). Custa 1 PE/turno para manter flutuando.",
    "Empuxo":
        "Pode ser arremessada em alcance curto (+1 dado de dano) e volta para você no mesmo turno. Pegar é reação.",
    "Energética":
        "Gaste 2 PE por ataque para fornecer +5 no Ataque, ignorar resistência e converter todo o dano para Energia.",
    "Vibrante":
        "Recebe a habilidade Ataque Extra (ou reduz o custo em -1 PE se já possuir).",
    "Consumidora":
        "Alvos atingidos ficam lentos na cena. Ao atacar, gaste 2 PE para imobilizar o alvo por 1 rodada.",
    "Erosiva":
        "Causa +1d8 de Morte. Gaste 2 PE ao atacar: vítima sofre 2d4 de Morte no início de seus turnos por 2 rodadas.",
    "Repulsora":
        "+2 de Defesa enquanto empunhada. Quando faz um bloqueio, gaste 2 PE para +5 na Defesa adicional.",
    "Lancinante":
        "+1d8 de Sangue. Esse bônus é multiplicado em acertos críticos.",
    "Predadora":
        "Anula penalidade de camuflagem/cobertura leve, aumenta alcance em uma categoria e dobra a margem de ameaça.",
    "Sanguinária":
        "Acertos deixam o alvo sangrando (2d6 cumulativo). Em acerto crítico, cura 2d10 PV temporários para você e deixa alvo fraco.",
    "Abascanta":
        "+5 testes resistência contra rituais. 1/cena, ao ser alvo de ritual, gaste reação + PE do ritual para refleti-lo de volta.",
    "Profética":
        "Resistência a Conhecimento 10. Quando faz um teste de resistência, pode gastar 2 PE para re-rolar.",
    "Sombria":
        "+5 Furtividade e ignora penalidade de carga na perícia. Pode virar roupa comum (ação movimento + 1 PE).",
    "Cinética": "+2 Defesa e Resistência a dano 2 (leve/escudo) ou 5 (pesada).",
    "Lépida":
        "+10 Atletismo e +3m desl. Gaste 2 PE para ignorar terreno difícil, deslocamento de escalada e imune a queda de 9m.",
    "Voltaica":
        "Resistência a Energia 10. Gaste mov. e 2 PE: no fim dos seus turnos causa 2d6 de Energia a seres adjacentes.",
    "Letárgica":
        "+2 Defesa. Chance de ignorar dano extra de crítico/furtivo (25% leve/escudo ou 50% pesada).",
    "Repulsiva":
        "Resistência a Morte 10. Gaste mov. e 2 PE: agressores corpo a corpo sofrem 2d8 de Morte.",
    "Regenerativa":
        "Resistência a Sangue 10. Gaste ação de mov. e 1 PE para recuperar 1d12 PV.",
    "Sádica":
        "No início do seu turno, recebe +1 em Ataque e Dano para cada 10 pontos de dano sofrido desde o fim do seu último turno.",
    "Carisma":
        "Gera aura autoconfiante. +1 Presença (não concede PE adicionais).",
    "Conjuração":
        "Possui um ritual de 1º círculo. Se o conhecer, seu custo diminui em -1 PE.",
    "Escudo Mental":
        "Gera barreira psíquica. Você recebe resistência mental 10.",
    "Reflexão":
        "1/rodada, alvo de ritual: gaste PE igual ao custo dele como reação para refleti-lo de volta ao conjurador.",
    "Sagacidade": "Mente acelerada. +1 Intelecto (não fornece perícias/graus).",
    "Defesa": "Barreira invisível fornece +5 de Defesa.",
    "Destreza": "Aprimora velocidade. +1 Agilidade.",
    "Potência":
        "Aumenta a DT contra suas habilidades, rituais e poderes em +1.",
    "Esforço Adicional": "Fornece +5 PE. (Ativa apenas após um dia de uso).",
    "Disposição": "Poder do sangue. +1 Vigor.",
    "Pujança": "Aumenta potência muscular. +1 Força.",
    "Vitalidade": "Fornece +15 PV. (Ativa apenas após um dia de uso).",
    "Proteção Elemental (Sangue)": "Resistência 10 contra Sangue.",
    "Proteção Elemental (Morte)": "Resistência 10 contra Morte.",
    "Proteção Elemental (Energia)": "Resistência 10 contra Energia.",
    "Proteção Elemental (Conhecimento)": "Resistência 10 contra Conhecimento.",
  };

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
                        int atual = usoCategoriaAtual[cat] ?? 0;
                        int max = limitesCategoria[cat] ?? 0;
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
              ...armas
                  .asMap()
                  .entries
                  .where((e) => e.value.nome != "Arma de Sangue")
                  .map((entry) {
                    int index = entry.key;
                    var arma = entry.value;

                    bool isProficiente =
                        arma.proficiencia == 'Simples' ||
                        (arma.proficiencia == 'Táticas' &&
                            classeAtual == 'combatente');

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
                              style: TextStyle(
                                color: corDestaque,
                                fontSize: 13,
                              ),
                              children: [
                                const TextSpan(text: "Categoria: "),
                                TextSpan(
                                  text: "${_obterCategoriaCalculada(arma)}   ",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const TextSpan(text: "Espaços: "),
                                TextSpan(
                                  text: arma.espacoEfetivo
                                      .toString()
                                      .replaceAll('.0', ''),
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
                                    "Dano: ${arma.danoEfetivo}$modDano | Crítico: $margemExibida/x$multExibido \nTipo: ${arma.tipo}$alertaProf",
                                    style: TextStyle(
                                      color: isProficiente
                                          ? Colors.grey
                                          : Colors.redAccent,
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

                                  if (!block)
                                    Wrap(
                                      spacing: 4,
                                      alignment: WrapAlignment.end,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        if (trilhaAtual == 'aniquilador' &&
                                            nex >= 10 &&
                                            !arma.modificacoes.contains(
                                              "Arma Favorita",
                                            ))
                                          TextButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                for (var a in armas) {
                                                  a.modificacoes = List.from(
                                                    a.modificacoes,
                                                  )..remove("Arma Favorita");
                                                }
                                                arma.modificacoes = List.from(
                                                  arma.modificacoes,
                                                )..add("Arma Favorita");
                                                atualizarFicha();
                                              });
                                              _salvarSilencioso();
                                              _mostrarNotificacao(
                                                "Arma Favorita definida!",
                                              );
                                            },
                                            icon: Icon(
                                              Icons.star,
                                              size: 16,
                                              color: corDestaque,
                                            ),
                                            label: Text(
                                              "Favorita",
                                              style: TextStyle(
                                                color: corDestaque,
                                              ),
                                            ),
                                          ),
                                        IconButton(
                                          onPressed: () {
                                            setState(
                                              () => armas.removeAt(index),
                                            );
                                            atualizarFicha();
                                            _salvarSilencioso();
                                          },
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.redAccent,
                                            size: 20,
                                          ),
                                          tooltip: "Excluir Arma",
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              _mostrarDialogEditarAtaque(arma),
                                          child: const Text(
                                            "Ataque",
                                            style: TextStyle(
                                              color: Colors.deepPurpleAccent,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        TextButton.icon(
                                          icon: const Icon(
                                            Icons.build,
                                            size: 16,
                                          ),
                                          onPressed: () =>
                                              _mostrarDialogSeletorModificacoes(
                                                arma,
                                                true,
                                              ),
                                          label: const Text(
                                            "Aprimorar",
                                            style: TextStyle(
                                              color: Colors.blueAccent,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              _mostrarDialogEdicaoCompletaArma(
                                                arma,
                                                index,
                                              ),
                                          child: const Text(
                                            "Editar",
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
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
                    item.tipo == "Proteção" ||
                    item.tipo.contains("Acessório") ||
                    item.descricao.toLowerCase().contains("proteção") ||
                    item.nome.toLowerCase().contains("vestimenta") ||
                    item.nome.toLowerCase().contains("utensílio") ||
                    item.nome.toLowerCase().contains("escudo");
                String tipoItem = item.descricao.split('.').first;
                String descLimpa = item.descricao
                    .replaceFirst("$tipoItem.", "")
                    .trim();
                if (descLimpa.isEmpty) descLimpa = tipoItem;

                return GestureDetector(
                  onDoubleTap: () {
                    if (item.nome.contains("Grimório Ritualístico")) {
                      setState(() {
                        _abaAtual = 3; // 3 é o índice da Aba de Rituais!
                      });
                      _mostrarNotificacao("Folheando o Grimório...");
                    }
                  },
                  child: Container(
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
                                text: "${_obterCategoriaCalculada(item)}   ",
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

                                if (!block)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          setState(
                                            () => inventario.removeAt(index),
                                          );
                                          atualizarFicha();
                                          _salvarSilencioso();
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                        ),
                                        tooltip: "Excluir Item",
                                      ),
                                      TextButton.icon(
                                        icon: const Icon(Icons.build, size: 16),
                                        onPressed: () =>
                                            _mostrarDialogSeletorModificacoes(
                                              item,
                                              false,
                                            ),
                                        label: const Text(
                                          "Aprimorar",
                                          style: TextStyle(
                                            color: Colors.blueAccent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            _mostrarDialogEdicaoCompletaItem(
                                              item,
                                              index,
                                            ),
                                        child: const Text(
                                          "Editar",
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  // Pop up escolher modificações
  void _mostrarDialogSeletorModificacoes(dynamic equipamento, bool isArma) {
    List<String> modsAtuais = List.from(equipamento.modificacoes);
    String filtroPrincipal = "Mundanas";
    String filtroElemento = "Todos";
    String busca = "";

    List<String> mundanas = isArma
        ? [
            "Alongada",
            "Balanceada",
            "Calibre Grosso",
            "Certeira",
            "Compensador",
            "Cruel",
            "Discreta",
            "Dum Dum",
            "Explosiva",
            "Ferrolho Automático",
            "Mira Laser",
            "Mira Telescópica",
            "Perigosa",
            "Silenciador",
            "Tática",
            "Visão de Calor",
          ]
        : ((equipamento.descricao.toLowerCase().contains("proteção") ||
                  equipamento.nome.toLowerCase().contains("escudo"))
              ? ["Antibombas", "Blindada", "Discreta", "Reforçada"]
              : ["Aprimorado", "Discreto", "Função Adicional", "Instrumental"]);

    Map<String, List<String>> maldicoes = isArma
        ? {
            "Sangue": ["Lancinante", "Predadora", "Sanguinária"],
            "Morte": ["Consumidora", "Erosiva", "Repulsora"],
            "Energia": ["Empuxo", "Energética", "Vibrante"],
            "Conhecimento": ["Antielemento", "Ritualística", "Senciente"],
          }
        : ((equipamento.descricao.toLowerCase().contains("proteção") ||
                  equipamento.nome.toLowerCase().contains("escudo"))
              ? {
                  "Sangue": ["Regenerativa", "Sádica"],
                  "Morte": ["Letárgica", "Repulsiva"],
                  "Energia": ["Cinética", "Lépida", "Voltaica"],
                  "Conhecimento": ["Abascanta", "Profética", "Sombria"],
                }
              : {
                  "Sangue": [
                    "Disposição",
                    "Pujança",
                    "Vitalidade",
                    "Proteção Elemental (Sangue)",
                  ],
                  "Morte": ["Esforço Adicional", "Proteção Elemental (Morte)"],
                  "Energia": [
                    "Defesa",
                    "Destreza",
                    "Potência",
                    "Proteção Elemental (Energia)",
                  ],
                  "Conhecimento": [
                    "Carisma",
                    "Conjuração",
                    "Escudo Mental",
                    "Reflexão",
                    "Sagacidade",
                    "Proteção Elemental (Conhecimento)",
                  ],
                });

    Color getCorModificacao(String modNome) {
      if (filtroPrincipal == "Mundanas") return Colors.white;
      if (maldicoes["Sangue"]?.contains(modNome) ?? false) {
        return const Color(0xFF990000);
      }
      if (maldicoes["Energia"]?.contains(modNome) ?? false) {
        return const Color(0xFF9900FF);
      }
      if (maldicoes["Conhecimento"]?.contains(modNome) ?? false) {
        return const Color(0xFFFFB300);
      }
      return Colors.grey.shade400; // Morte
    }

    String obterElementoMaldicao(String mod) {
      for (var entry in maldicoes.entries) {
        if (entry.value.contains(mod)) return entry.key;
      }
      return "Mundano";
    }

    bool podeAdicionarMaldicao(String novaMod) {
      String elemNovo = obterElementoMaldicao(novaMod);
      if (elemNovo == "Mundano") return true;

      for (String modAtual in modsAtuais) {
        String elemAtual = obterElementoMaldicao(modAtual);
        if (elemAtual == "Mundano") continue;

        if (elemNovo == 'Sangue' &&
            (elemAtual == 'Morte' || elemAtual == 'Conhecimento')) {
          return false;
        }
        if (elemNovo == 'Morte' &&
            (elemAtual == 'Sangue' || elemAtual == 'Energia')) {
          return false;
        }
        if (elemNovo == 'Energia' &&
            (elemAtual == 'Morte' || elemAtual == 'Conhecimento')) {
          return false;
        }
        if (elemNovo == 'Conhecimento' &&
            (elemAtual == 'Energia' || elemAtual == 'Sangue')) {
          return false;
        }
      }
      return true;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            List<String> listaAtiva = [];
            if (filtroPrincipal == "Mundanas") {
              listaAtiva = mundanas;
            } else {
              if (filtroElemento == "Todos") {
                listaAtiva = maldicoes.values.expand((x) => x).toList();
              } else {
                listaAtiva = maldicoes[filtroElemento] ?? [];
              }
            }

            List<String> filtrados = listaAtiva.where((mod) {
              if (busca.isNotEmpty &&
                  !mod.toLowerCase().contains(busca.toLowerCase())) {
                return false;
              }
              return true;
            }).toList();

            filtrados.sort((a, b) => a.compareTo(b));

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
                        Icon(Icons.build, color: corDestaque, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "APRIMORAMENTOS",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: corDestaque,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      decoration: EstiloParanormal.customInputDeco(
                        "Pesquisar modificação...",
                        corDestaque,
                        Icons.search,
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) => setDialogState(() => busca = val),
                    ),
                    const SizedBox(height: 12),

                    // FILTRO PRINCIPAL (Mundanas vs Maldições)
                    Row(
                      children: ["Mundanas", "Maldições"].map((cat) {
                        bool isSel = filtroPrincipal == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(
                              cat,
                              style: TextStyle(
                                color: isSel
                                    ? Colors.black
                                    : Colors.grey.shade400,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            selected: isSel,
                            onSelected: (val) {
                              if (val) {
                                setDialogState(() {
                                  filtroPrincipal = cat;
                                  busca = "";
                                });
                              }
                            },
                            selectedColor: cat == "Mundanas"
                                ? Colors.grey.shade300
                                : Colors.deepPurpleAccent,
                            backgroundColor: const Color(0xFF0D0D0D),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),

                    // SUB-FILTRO DE ELEMENTOS
                    if (filtroPrincipal == "Maldições") ...[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ["Todos", ...maldicoes.keys].map((el) {
                            Color corChip = el == "Sangue"
                                ? const Color(0xFF990000)
                                : el == "Energia"
                                ? const Color(0xFF9900FF)
                                : el == "Conhecimento"
                                ? const Color(0xFFFFB300)
                                : el == "Morte"
                                ? Colors.grey.shade400
                                : Colors.deepPurpleAccent;

                            Color txtCor =
                                (filtroElemento == el &&
                                    el != "Morte" &&
                                    el != "Todos")
                                ? Colors.black
                                : (filtroElemento == el)
                                ? Colors.white
                                : Colors.white;

                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(
                                  el,
                                  style: TextStyle(
                                    color: txtCor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                selected: filtroElemento == el,
                                selectedColor: corChip,
                                backgroundColor: const Color(0xFF0D0D0D),
                                side: BorderSide(
                                  color: filtroElemento == el
                                      ? corChip
                                      : Colors.grey.shade800,
                                ),
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
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          "Aviso: A 1ª maldição aumenta a categoria em +2. Falhar em testes usando o item consome Sanidade.",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),

                    // LISTA EXPANSÍVEL
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
                                  "Nenhuma modificação encontrada.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filtrados.length,
                                itemBuilder: (context, index) {
                                  String mod = filtrados[index];
                                  bool isSelected = modsAtuais.contains(mod);
                                  Color corTemaLinha = getCorModificacao(mod);

                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade900,
                                        ),
                                      ),
                                    ),
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        dividerColor: Colors.transparent,
                                      ),
                                      child: ExpansionTile(
                                        iconColor: Colors.white,
                                        collapsedIconColor: Colors.white54,
                                        tilePadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 4,
                                        ),
                                        title: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                mod,
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? corTemaLinha
                                                      : Colors.white,
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                isSelected
                                                    ? Icons.remove_circle
                                                    : Icons.add_circle,
                                                color: isSelected
                                                    ? Colors.redAccent
                                                    : Colors.white,
                                                size: 28,
                                              ),
                                              onPressed: () {
                                                if (!isSelected &&
                                                    !podeAdicionarMaldicao(
                                                      mod,
                                                    )) {
                                                  WidgetsBinding.instance
                                                      .addPostFrameCallback((
                                                        _,
                                                      ) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              "Opressão Elemental! Você não pode combinar esta maldição com o elemento atual.",
                                                            ),
                                                            backgroundColor:
                                                                Colors
                                                                    .redAccent,
                                                            behavior:
                                                                SnackBarBehavior
                                                                    .floating,
                                                          ),
                                                        );
                                                      });
                                                  return;
                                                }
                                                setDialogState(() {
                                                  if (isSelected) {
                                                    modsAtuais.remove(mod);
                                                  } else {
                                                    modsAtuais.add(mod);
                                                  }
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        // Sem a propriedade "trailing", a setinha original do Flutter volta a aparecer na extrema direita!
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
                                                  color: corTemaLinha
                                                      .withValues(alpha: 0.3),
                                                  thickness: 1,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  _descricoesModsEMaldicoes[mod] ??
                                                      "Descrição indisponível.",
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 13,
                                                    height: 1.4,
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
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: corFundoAfinidade,
                        foregroundColor: corTextoAfinidade,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        setState(() {
                          equipamento.modificacoes = List<String>.from(
                            modsAtuais,
                          );
                          atualizarFicha();
                        });
                        _salvarSilencioso();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "SALVAR APRIMORAMENTOS",
                        style: TextStyle(fontWeight: FontWeight.bold),
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

  // FUNÇÕES DE EQUIPAR, CATÁLOGO E CRIAR

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
      "Itens Amaldiçoados",
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Widget buildSubFiltro(String label, List<String> opcoes) {
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
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: opcoes.map((sub) {
                      bool isSelected = subFiltrosAtivos.contains(sub);

                      Color corChip = Colors.grey.shade300;
                      if (filtroAtual == "Itens Amaldiçoados") {
                        if (sub == "Sangue") {
                          corChip = const Color(0xFF990000);
                        } else if (sub == "Morte") {
                          corChip = Colors.grey.shade400;
                        } else if (sub == "Energia") {
                          corChip = const Color(0xFF9900FF);
                        } else if (sub == "Conhecimento") {
                          corChip = const Color(0xFFFFB300);
                        } else if (sub == "Medo") {
                          corChip = Colors.white;
                        } else if (sub == "Varia") {
                          corChip = Colors.deepPurpleAccent;
                        }
                      }

                      Color txtCor = isSelected
                          ? Colors.black
                          : Colors.grey.shade400;
                      if (filtroAtual == "Itens Amaldiçoados" && isSelected) {
                        txtCor =
                            (sub == 'Conhecimento' ||
                                sub == 'Morte' ||
                                sub == 'Medo')
                            ? Colors.black
                            : Colors.white;
                      }

                      return FilterChip(
                        label: Text(
                          sub,
                          style: TextStyle(
                            color: txtCor,
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: corChip,
                        backgroundColor: const Color(0xFF151515),
                        side: BorderSide(
                          color: isSelected ? corChip : Colors.grey.shade800,
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
                      );
                    }).toList(),
                  ),
                ],
              );
            }

            List<dynamic> todosEquipamentos = [
              ...catalogoArmasOrdem,
              ...armasAmaldicoadas,
              ...catalogoItensOrdem,
              ...itensAmaldicoados,
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
                    if ([
                          "Corpo a Corpo",
                          "Fogo",
                          "Disparo",
                          "Arremesso",
                        ].contains(sub) &&
                        eq.tipo != sub) {
                      return false;
                    }
                    if (["Leve", "Uma Mão", "Duas Mãos"].contains(sub) &&
                        eq.empunhadura != sub) {
                      return false;
                    }
                    // Lógica para filtrar especificamente armas amaldiçoadas
                    if (sub == "Amaldiçoada" &&
                        !eq.descricao.toLowerCase().contains("amaldiçoado")) {
                      return false;
                    }
                  }
                } else if (filtroAtual == "Itens Amaldiçoados") {
                  if (!eq.descricao.toLowerCase().contains("amaldiçoado")) {
                    return false;
                  }

                  if (subFiltrosAtivos.isNotEmpty) {
                    bool temElemento = false;
                    for (String sub in subFiltrosAtivos) {
                      if (eq.descricao.toLowerCase().contains(
                        "(${sub.toLowerCase()})",
                      )) {
                        temElemento = true;
                        break;
                      }
                    }
                    if (!temElemento) return false;
                  }
                } else {
                  if (eq is Arma) return false;
                  if (eq is ItemInventario) {
                    String descLower = eq.descricao.toLowerCase();
                    if (filtroAtual == "Acessórios" &&
                        (!descLower.contains("acessório") &&
                            !eq.nome.toLowerCase().contains("vestimenta"))) {
                      return false;
                    }
                    if (filtroAtual == "Explosivos" &&
                        !descLower.contains("explosivo")) {
                      return false;
                    }
                    if (filtroAtual == "Itens Operacionais" &&
                        !descLower.contains("item operacional")) {
                      return false;
                    }
                    if (filtroAtual == "Munições" &&
                        !descLower.contains("munição")) {
                      return false;
                    }
                    if (filtroAtual == "Proteções" &&
                        !descLower.contains("proteção")) {
                      return false;
                    }
                    if (filtroAtual == "Itens Paranormais" &&
                        (!descLower.contains("item paranormal") ||
                            descLower.contains("amaldiçoado"))) {
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
                      style: const TextStyle(color: Colors.white),
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
                            buildSubFiltro("Proficiência", [
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
                            buildSubFiltro("Tipo", [
                              "Corpo a Corpo",
                              "Fogo",
                              "Disparo",
                              "Arremesso",
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
                            buildSubFiltro("Empunhadura", [
                              "Leve",
                              "Uma Mão",
                              "Duas Mãos",
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
                            buildSubFiltro("Paranormal", [
                              "Amaldiçoada",
                            ]), // <--- NOVO FILTRO ADICIONADO
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    if (filtroAtual == "Itens Amaldiçoados") ...[
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildSubFiltro("Elemento da Maldição", [
                              "Sangue",
                              "Morte",
                              "Energia",
                              "Conhecimento",
                              "Medo",
                              "Varia",
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
                                  String tipoItem = "", descLimpa = "";

                                  if (!isArma) {
                                    tipoItem = eq.descricao.split('.').first;
                                    descLimpa = eq.descricao
                                        .replaceFirst("$tipoItem.", "")
                                        .trim();
                                    if (descLimpa.isEmpty) descLimpa = tipoItem;
                                  }

                                  // LÓGICA DA TAG VISUAL DE ELEMENTO
                                  String elementoTag = "";
                                  Color corElemento = Colors.white;
                                  String descLower = eq.descricao.toLowerCase();

                                  if (descLower.contains("amaldiçoado")) {
                                    if (descLower.contains("(sangue)")) {
                                      elementoTag = "SANGUE";
                                      corElemento = const Color(0xFF990000);
                                    } else if (descLower.contains("(morte)")) {
                                      elementoTag = "MORTE";
                                      corElemento = Colors
                                          .white54; // Cinza claro/Branco para destaque
                                    } else if (descLower.contains(
                                      "(energia)",
                                    )) {
                                      elementoTag = "ENERGIA";
                                      corElemento = const Color(0xFF9900FF);
                                    } else if (descLower.contains(
                                      "(conhecimento)",
                                    )) {
                                      elementoTag = "CONHECIMENTO";
                                      corElemento = const Color(0xFFFFB300);
                                    } else if (descLower.contains("(medo)")) {
                                      elementoTag = "MEDO";
                                      corElemento = Colors.white;
                                    } else if (descLower.contains("(varia)")) {
                                      elementoTag = "VARIA";
                                      corElemento = Colors.deepPurpleAccent;
                                    }
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

                                        // AQUI ENTRA O TÍTULO COM A TAG!
                                        title: Row(
                                          children: [
                                            if (elementoTag.isNotEmpty)
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  right: 8,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: corElemento,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  elementoTag,
                                                  style: TextStyle(
                                                    color: corElemento,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            Expanded(
                                              child: isArma
                                                  ? RichText(
                                                      text: TextSpan(
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                        ),
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                "${eq.nome}  ",
                                                          ),
                                                          TextSpan(
                                                            text:
                                                                "${eq.proficiencia} - ${eq.tipo} - ${eq.empunhadura}",
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 10,
                                                                  color: Colors
                                                                      .grey,
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : Text(
                                                      eq.nome,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                            ),
                                          ],
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
                                                          eq.descricao
                                                              .toLowerCase()
                                                              .contains(
                                                                "amaldiçoado",
                                                              ) ||
                                                          eq.descricao
                                                              .toLowerCase()
                                                              .contains(
                                                                "paranormal",
                                                              ) ||
                                                          eq.nome
                                                              .toLowerCase()
                                                              .contains(
                                                                "(elemento)",
                                                              ))) {
                                                    // 1. Se for o Catalisador, chama o dialog de Catalisador
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
                                                        onConfirmar:
                                                            (novoCatalisador) {
                                                              _processarNovoItem(
                                                                novoCatalisador,
                                                              );
                                                            },
                                                      );
                                                    }
                                                    // 2. Se for um item genérico de Elemento (Componente, Amarras, etc), chama o dialog de Elemento
                                                    else if (eq.nome
                                                        .toLowerCase()
                                                        .contains(
                                                          "(elemento)",
                                                        )) {
                                                      mostrarDialogElementoItem(
                                                        context: context,
                                                        itemBase: eq,
                                                        corDestaque:
                                                            corDestaqueLocal,
                                                        corTema: corTemaLocal,
                                                        corTexto: corLetra,
                                                        afinidadeAtual:
                                                            afinidadeAtual,
                                                        onConfirmar:
                                                            (
                                                              novoItemElementar,
                                                            ) {
                                                              _processarNovoItem(
                                                                novoItemElementar,
                                                              );
                                                            },
                                                      );
                                                    }
                                                    // 3. Se for só um item paranormal comum, processa direto
                                                    else {
                                                      _processarNovoItem(
                                                        ItemInventario(
                                                          nome: eq.nome,
                                                          categoria:
                                                              eq.categoria,
                                                          espaco: eq.espaco,
                                                          descricao:
                                                              eq.descricao,
                                                          modificacoes:
                                                              List<String>.from(
                                                                eq.modificacoes,
                                                              ),
                                                        ),
                                                      );
                                                    }
                                                  } else {
                                                    // (O resto do código de armas/itens mundanos continua igual)
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
                                                            modificacoes:
                                                                List<
                                                                  String
                                                                >.from(
                                                                  eq.modificacoes,
                                                                ),
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
                                                          modificacoes:
                                                              List<String>.from(
                                                                eq.modificacoes,
                                                              ),
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
                                                if (isArma)
                                                  Text(
                                                    eq.descricao.isNotEmpty
                                                        ? eq.descricao
                                                        : "Nenhuma descrição fornecida.",
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                    ),
                                                  )
                                                else ...[
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
                              _mostrarDialogCriarItemLocal();
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
    if (origemAtual == 'engenheiro' &&
        poderesEscolhidos.any((p) => p.nome == "Engenheiro_${item.nome}")) {
      if (!item.modificacoes.contains("Ferramenta Favorita")) {
        item.modificacoes.add("Ferramenta Favorita");
      }
    }
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
    if (nomeLower == "kit de perícia" || nomeLower == "kit") {
      _mostrarDialogEscolherKit(novoItem);
      return;
    }
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
                onChanged: (val) => setDialogState(() => kitEscolhido = val!),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: listaKits
                      .map(
                        (kit) => RadioListTile<String>(
                          title: Text(
                            kit,
                            style: const TextStyle(color: Colors.white),
                          ),
                          value: kit,
                          activeColor: corDestaque,
                        ),
                      )
                      .toList(),
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
    bool isVestimenta =
        item.tipo == "Acessório (Vestimenta)" ||
        item.nome.toLowerCase().contains("vestimenta");
    bool isUtensilio =
        item.tipo == "Acessório (Utensílio)" ||
        item.nome.toLowerCase().contains("utensílio");
    bool isProtecao =
        item.tipo == "Proteção" ||
        item.descricao.toLowerCase().contains("proteção");
    bool isEscudo = item.nome.toLowerCase().contains("escudo");

    if (!item.equipado) {
      // REGRA DE LIMITE: VESTIMENTAS (Ocupam o corpo, máx 2 ou 3)
      if (isVestimenta) {
        int equipadas = inventario
            .where(
              (i) =>
                  i.equipado &&
                  (i.tipo == "Acessório (Vestimenta)" ||
                      i.nome.toLowerCase().contains("vestimenta")),
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

      // REGRA DE LIMITE: UTENSÍLIOS (Ocupam as mãos)
      if (isUtensilio) {
        if (maosOcupadas + 1 > 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Limite: Você não tem mãos livres suficientes para segurar este utensílio!",
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }
      }

      // REGRA DE LIMITE: PROTEÇÕES E ESCUDOS
      if (isProtecao) {
        if (isEscudo) {
          if (maosOcupadas + 1 > 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Limite: Você não tem mãos livres para equipar o Escudo!",
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
                (i.tipo == "Proteção" ||
                    i.descricao.toLowerCase().contains("proteção")) &&
                !i.nome.toLowerCase().contains("escudo"),
          )) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Limite: Você só pode usar 1 armadura por vez! (Mas pode usar 1 Escudo junto)",
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

  // EDIÇÃO DE STATUS (DANO, MARGEM, ETC)

  void _mostrarDialogEdicaoCompletaArma(Arma arma, int index) {
    TextEditingController nomeCtrl = TextEditingController(text: arma.nome);
    TextEditingController danoCtrl = TextEditingController(text: arma.dano);
    TextEditingController margemCtrl = TextEditingController(
      text: arma.margemAmeaca.toString(),
    );
    TextEditingController multCtrl = TextEditingController(
      text: arma.multiplicadorCritico.toString(),
    );
    TextEditingController espacoCtrl = TextEditingController(
      text: arma.espaco.toString(),
    );
    String tipoAtual = arma.tipo;
    String catAtual = arma.categoria;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: Text("Editar Arma", style: TextStyle(color: corDestaque)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nomeCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: EstiloParanormal.customInputDeco(
                        "Nome da Arma",
                        corDestaque,
                        Icons.edit,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: danoCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: EstiloParanormal.customInputDeco(
                              "Dano",
                              corDestaque,
                              Icons.casino,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownFicha(
                            label: "Tipo",
                            value: tipoAtual,
                            options: const [
                              "Corpo a Corpo",
                              "Fogo",
                              "Disparo",
                              "Arremesso",
                            ],
                            onChanged: (val) =>
                                setDialogState(() => tipoAtual = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: margemCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: EstiloParanormal.customInputDeco(
                              "Margem",
                              corDestaque,
                              Icons.warning,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: multCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: EstiloParanormal.customInputDeco(
                              "Crítico (x)",
                              corDestaque,
                              Icons.close,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: espacoCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: const TextStyle(color: Colors.white),
                            decoration: EstiloParanormal.customInputDeco(
                              "Espaço",
                              corDestaque,
                              Icons.backpack,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownFicha(
                            label: "Categoria",
                            value: catAtual,
                            options: const [
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
                            ],
                            onChanged: (val) =>
                                setDialogState(() => catAtual = val!),
                          ),
                        ),
                      ],
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
                    backgroundColor: corFundoAfinidade,
                    foregroundColor: corTextoAfinidade,
                  ),
                  onPressed: () {
                    setState(() {
                      arma.nome = nomeCtrl.text;
                      arma.dano = danoCtrl.text;
                      arma.tipo = tipoAtual;
                      arma.margemAmeaca = int.tryParse(margemCtrl.text) ?? 20;
                      arma.multiplicadorCritico =
                          int.tryParse(multCtrl.text) ?? 2;
                      arma.espaco = double.tryParse(espacoCtrl.text) ?? 1.0;
                      arma.categoria = catAtual;
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

  void _mostrarDialogEdicaoCompletaItem(ItemInventario item, int index) {
    TextEditingController nomeCtrl = TextEditingController(text: item.nome);
    TextEditingController descCtrl = TextEditingController(
      text: item.descricao,
    );
    TextEditingController espacoCtrl = TextEditingController(
      text: item.espaco.toString(),
    );

    // Controladores para os status numéricos
    TextEditingController defesaCtrl = TextEditingController(
      text: item.defesa.toString(),
    );
    TextEditingController bonusCargaCtrl = TextEditingController(
      text: item.bonusCarga.toString(),
    );
    TextEditingController bonusPericiaCtrl = TextEditingController(
      text: item.bonusPericia.toString(),
    );

    String catAtual = item.categoria;
    String tipoAtual = item.tipo;

    // Atualiza os itens antigos do banco de dados automaticamente
    if (tipoAtual == "Acessório (Vestimenta)" ||
        tipoAtual == "Acessório (Utensílio)") {
      tipoAtual = "Acessório";
    }

    // Lista oficial de Tipos
    List<String> tiposValidos = [
      "Item Operacional",
      "Acessório",
      "Proteção",
      "Arma",
      "Munição",
      "Explosivo",
      "Outro",
    ];
    if (!tiposValidos.contains(tipoAtual)) tiposValidos.add(tipoAtual);

    // Estados dos Checkboxes baseados nos dados atuais do item
    bool forneceBonusPericia =
        item.periciaVinculada.isNotEmpty && item.bonusPericia > 0;
    bool isArmazenamento = item.bonusCarga > 0;
    String periciaAtual = item.periciaVinculada.isEmpty
        ? "nenhuma"
        : item.periciaVinculada;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: Text(
                "Configurar Item",
                style: TextStyle(color: corDestaque),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nomeCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: EstiloParanormal.customInputDeco(
                        "Nome do Item",
                        corDestaque,
                        Icons.edit,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: EstiloParanormal.customInputDeco(
                        "Descrição",
                        corDestaque,
                        Icons.description,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: espacoCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: const TextStyle(color: Colors.white),
                            decoration: EstiloParanormal.customInputDeco(
                              "Espaço",
                              corDestaque,
                              Icons.backpack,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownFicha(
                            label: "Categoria",
                            value: catAtual,
                            options: const [
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
                            ],
                            onChanged: (val) =>
                                setDialogState(() => catAtual = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ==========================================
                    // TIPO DO ITEM
                    // ==========================================
                    DropdownFicha(
                      label: "Tipo de Item",
                      value: tipoAtual,
                      options: tiposValidos,
                      onChanged: (val) {
                        setDialogState(() {
                          tipoAtual = val!;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // ==========================================
                    // LÓGICA DE ACESSÓRIO (Checkbox e Perícia)
                    // ==========================================
                    if (tipoAtual == "Acessório") ...[
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text(
                          "Fornecer bônus em perícia",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        value: forneceBonusPericia,
                        activeColor: corDestaque,
                        side: const BorderSide(color: Colors.grey),
                        onChanged: (val) {
                          setDialogState(
                            () => forneceBonusPericia = val ?? false,
                          );
                        },
                      ),
                      if (forneceBonusPericia) ...[
                        DropdownFicha(
                          label: "Perícia Vinculada",
                          value: periciaAtual,
                          options: [
                            "nenhuma",
                            ...listaPericias.map((p) => p.id),
                          ],
                          onChanged: (val) {
                            setDialogState(() => periciaAtual = val!);
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: bonusPericiaCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: EstiloParanormal.customInputDeco(
                            "Bônus na Perícia (+)",
                            Colors.greenAccent,
                            Icons.star,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],

                    // ==========================================
                    // LÓGICA DE ITEM OPERACIONAL (Armazenamento)
                    // ==========================================
                    if (tipoAtual == "Item Operacional") ...[
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text(
                          "Item de Armazenamento",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        subtitle: const Text(
                          "Aumenta o limite de Carga (ex: Mochila)",
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                        value: isArmazenamento,
                        activeColor: corDestaque,
                        side: const BorderSide(color: Colors.grey),
                        onChanged: (val) {
                          setDialogState(() => isArmazenamento = val ?? false);
                        },
                      ),
                      if (isArmazenamento) ...[
                        TextField(
                          controller: bonusCargaCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: EstiloParanormal.customInputDeco(
                            "Bônus de Capacidade (+)",
                            Colors.orangeAccent,
                            Icons.fitness_center,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],

                    // ==========================================
                    // LÓGICA DE PROTEÇÃO
                    // ==========================================
                    if (tipoAtual == "Proteção" ||
                        nomeCtrl.text.toLowerCase().contains("escudo")) ...[
                      TextField(
                        controller: defesaCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: EstiloParanormal.customInputDeco(
                          "Bônus de Defesa (+)",
                          Colors.blueAccent,
                          Icons.shield,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
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
                    backgroundColor: corFundoAfinidade,
                    foregroundColor: corTextoAfinidade,
                  ),
                  onPressed: () {
                    setState(() {
                      item.nome = nomeCtrl.text;
                      item.descricao = descCtrl.text;
                      item.espaco = double.tryParse(espacoCtrl.text) ?? 1.0;
                      item.categoria = catAtual;
                      item.tipo = tipoAtual;

                      // Salva a Defesa apenas se for Proteção
                      if (tipoAtual == "Proteção" ||
                          item.nome.toLowerCase().contains("escudo")) {
                        item.defesa = int.tryParse(defesaCtrl.text) ?? 0;
                      } else {
                        item.defesa = 0;
                      }

                      // Salva Perícia APENAS se for Acessório E o checkbox estiver marcado
                      if (tipoAtual == "Acessório" &&
                          forneceBonusPericia &&
                          periciaAtual != "nenhuma") {
                        item.periciaVinculada = periciaAtual;
                        item.bonusPericia =
                            int.tryParse(bonusPericiaCtrl.text) ?? 0;
                      } else {
                        item.periciaVinculada = "";
                        item.bonusPericia = 0;
                      }

                      // Salva Carga APENAS se for Operacional E o checkbox estiver marcado
                      if (tipoAtual == "Item Operacional" && isArmazenamento) {
                        item.bonusCarga =
                            int.tryParse(bonusCargaCtrl.text) ?? 0;
                      } else {
                        item.bonusCarga = 0;
                      }

                      atualizarFicha();
                    });
                    _salvarSilencioso();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "SALVAR",
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

  void _mostrarDialogCriarItemLocal() {
    String nomeNovo = "";
    String categoriaNova = "0";
    String espacoNovo = "1";
    String descNova = "";
    String tipoNovo = "Geral";

    // Variáveis de controle
    String periciaVinculadaNova = "nenhuma";
    int defesaNova = 0;
    int bonusPericiaNovo = 0;
    int bonusCargaNovo = 0;

    // Estados dos checkboxes
    bool forneceBonusPericiaNovo = false;
    bool isArmazenamentoNovo = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: Text("Criar Item", style: TextStyle(color: corDestaque)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: EstiloParanormal.customInputDeco(
                        "Nome do Item",
                        corDestaque,
                        Icons.edit,
                      ),
                      onChanged: (val) => nomeNovo = val,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      maxLines: 2,
                      decoration: EstiloParanormal.customInputDeco(
                        "Descrição Rápida",
                        corDestaque,
                        Icons.description,
                      ),
                      onChanged: (val) => descNova = val,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: const TextStyle(color: Colors.white),
                            decoration: EstiloParanormal.customInputDeco(
                              "Espaço",
                              corDestaque,
                              Icons.backpack,
                            ),
                            onChanged: (val) => espacoNovo = val,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownFicha(
                            label: "Categoria",
                            value: categoriaNova,
                            options: const [
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
                            ],
                            onChanged: (val) =>
                                setDialogState(() => categoriaNova = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ==========================================
                    // TIPO DO ITEM
                    // ==========================================
                    DropdownFicha(
                      label: "Tipo de Item",
                      value: tipoNovo,
                      options: const [
                        "Geral",
                        "Proteção",
                        "Acessório", // Agora apenas Acessório
                        "Explosivo",
                        "Item Operacional",
                        "Medicamento",
                        "Outro",
                      ],
                      onChanged: (val) => setDialogState(() => tipoNovo = val!),
                    ),
                    const SizedBox(height: 12),

                    // ==========================================
                    // LÓGICA DE PROTEÇÃO
                    // ==========================================
                    if (tipoNovo == "Proteção") ...[
                      TextField(
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: EstiloParanormal.customInputDeco(
                          "Bônus de Defesa (+)",
                          Colors.blueAccent,
                          Icons.shield,
                        ),
                        onChanged: (val) => defesaNova = int.tryParse(val) ?? 0,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ==========================================
                    // LÓGICA DE ACESSÓRIO
                    // ==========================================
                    if (tipoNovo == "Acessório") ...[
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text(
                          "Fornecer bônus em perícia",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        value: forneceBonusPericiaNovo,
                        activeColor: corDestaque,
                        side: const BorderSide(color: Colors.grey),
                        onChanged: (val) {
                          setDialogState(
                            () => forneceBonusPericiaNovo = val ?? false,
                          );
                        },
                      ),
                      if (forneceBonusPericiaNovo) ...[
                        DropdownFicha(
                          label: "Perícia Vinculada",
                          value: periciaVinculadaNova,
                          options: [
                            "nenhuma",
                            ...listaPericias.map((p) => p.id),
                          ],
                          onChanged: (val) =>
                              setDialogState(() => periciaVinculadaNova = val!),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: EstiloParanormal.customInputDeco(
                            "Bônus na Perícia (+)",
                            Colors.greenAccent,
                            Icons.star,
                          ),
                          onChanged: (val) =>
                              bonusPericiaNovo = int.tryParse(val) ?? 0,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],

                    // ==========================================
                    // LÓGICA DE ITEM OPERACIONAL (Armazenamento)
                    // ==========================================
                    if (tipoNovo == "Item Operacional") ...[
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text(
                          "Item de Armazenamento",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        subtitle: const Text(
                          "Aumenta o limite de Carga (ex: Mochila)",
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                        value: isArmazenamentoNovo,
                        activeColor: corDestaque,
                        side: const BorderSide(color: Colors.grey),
                        onChanged: (val) {
                          setDialogState(
                            () => isArmazenamentoNovo = val ?? false,
                          );
                        },
                      ),
                      if (isArmazenamentoNovo) ...[
                        TextField(
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: EstiloParanormal.customInputDeco(
                            "Bônus de Capacidade (+)",
                            Colors.orangeAccent,
                            Icons.fitness_center,
                          ),
                          onChanged: (val) =>
                              bonusCargaNovo = int.tryParse(val) ?? 0,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
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
                    backgroundColor: corDestaque,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    if (nomeNovo.trim().isEmpty) return;

                    setState(() {
                      // Processamento Seguro dos Valores
                      String periciaFinal =
                          (tipoNovo == "Acessório" &&
                              forneceBonusPericiaNovo &&
                              periciaVinculadaNova != "nenhuma")
                          ? periciaVinculadaNova
                          : "";
                      int bonusPericiaFinal =
                          (tipoNovo == "Acessório" &&
                              forneceBonusPericiaNovo &&
                              periciaVinculadaNova != "nenhuma")
                          ? bonusPericiaNovo
                          : 0;
                      int bonusCargaFinal =
                          (tipoNovo == "Item Operacional" &&
                              isArmazenamentoNovo)
                          ? bonusCargaNovo
                          : 0;
                      int defesaFinal = (tipoNovo == "Proteção")
                          ? defesaNova
                          : 0;

                      inventario.add(
                        ItemInventario(
                          nome: nomeNovo,
                          categoria: categoriaNova,
                          espaco: double.tryParse(espacoNovo) ?? 1.0,
                          descricao: descNova,
                          tipo: tipoNovo,
                          defesa: defesaFinal,
                          periciaVinculada: periciaFinal,
                          bonusPericia: bonusPericiaFinal,
                          bonusCarga:
                              bonusCargaFinal, // Passando o Bônus de Mochila!
                        ),
                      );
                      atualizarFicha();
                    });
                    _salvarSilencioso();
                    Navigator.pop(context);
                    _mostrarNotificacao("$nomeNovo adicionado!");
                  },
                  child: const Text(
                    "CRIAR ITEM",
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
}
