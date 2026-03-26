// ignore_for_file: invalid_use_of_protected_member
part of 'ficha_agente.dart';

extension _RituaisFicha on _FichaAgenteState {
  Color _corElementoRitual(String elemento) {
    switch (elemento) {
      case 'Sangue':
        return const Color(0xFF990000);
      case 'Energia':
        return const Color(0xFF9900FF);
      case 'Conhecimento':
        return const Color(0xFFFFB300);
      case 'Morte':
        return Colors.grey.shade400;
      case 'Medo':
        return Colors.white;
      default:
        return Colors.white54;
    }
  }

  void _conjurarRitual(Ritual r, int custo, String versao) {
    if (r.elemento != 'Medo' && peAtual < custo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pontos de Esforço insuficientes!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (r.elemento == 'Medo') {
      int perdaPermanente = 1;
      if (versao == "Discente") perdaPermanente = 2;
      if (versao == "Verdadeiro") perdaPermanente = 3;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              const SizedBox(width: 8),
              Text("Ritual de Medo", style: TextStyle(color: corDestaque)),
            ],
          ),
          content: Text(
            "Rituais de Medo NÃO consomem Pontos de Esforço, mas cobram um preço irreversível da sua mente.\n\n"
            "Se conjurar a versão $versao, você perderá $custo de Sanidade Atual e sofrerá uma redução PERMANENTE de $perdaPermanente na sua Sanidade Máxima.\n\n"
            "Deseja prosseguir?",
            style: const TextStyle(color: Colors.white, height: 1.4),
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
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                _efetivarConjuracao(r, custo, versao, perdaPermanente);
              },
              child: const Text(
                "CONJURAR",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } else {
      _efetivarConjuracao(r, custo, versao, 0);
    }
  }

  void _efetivarConjuracao(
    Ritual r,
    int custo,
    String versao,
    int perdaSanidadePermanente,
  ) {
    setState(() {
      if (r.elemento == 'Medo') {
        sanAtual -= custo;
        if (sanAtual < 0) sanAtual = 0;

        for (int i = 0; i < perdaSanidadePermanente; i++) {
          poderesEscolhidos.add(
            Poder(
              nome: "Sistema_PerdaSanidadeMedo",
              tipo: "Sistema",
              descricao: "Perda permanente de SAN por ritual de Medo.",
            ),
          );
        }
        atualizarFicha();
      } else {
        peAtual -= custo;
      }
    });

    _salvarSilencioso();
    _mostrarNotificacao(
      "Conjurou ${r.nome} ($versao)!${r.elemento == 'Medo' ? "\n-$custo SAN Atual | -$perdaSanidadePermanente SAN Máx." : "\n-$custo PE"}",
    );
  }

  Widget _buildAbaRituais(bool block, Color corDoPainel) {
    // Cálculo da DT de Rituais = 10 + Limite de PE do Turno + PRE
    int dtRitual = 10 + limitePePorTurno + pre;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SecaoFicha(
            titulo: "Grimório",
            corTema: corFundoAfinidade,
            corTexto: corTextoAfinidade,
            isMorte: afinidadeAtual == 'Morte',
            filhos: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0D0D),
                      border: Border.all(
                        color: corDestaque.withValues(alpha: 0.5),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "DT de Rituais: $dtRitual",
                      style: TextStyle(
                        color: corDestaque,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (!block)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _mostrarDialogCriarRitual,
                          icon: const Icon(Icons.add_circle_outline, size: 18),
                          label: const Text("Custom"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF151515),
                            foregroundColor: corDestaque,
                            side: BorderSide(
                              color: corDestaque.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _abrirCatalogoRituais,
                          icon: const Icon(Icons.auto_awesome, size: 18),
                          label: const Text("Aprender Ritual"),
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
                ],
              ),
              const SizedBox(height: 12),

              if (rituaisConhecidos.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Seu grimório está vazio. Aprenda rituais do Outro Lado para conjurá-los.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rituaisConhecidos.length,
                itemBuilder: (context, index) {
                  Ritual r = rituaisConhecidos[index];
                  Color corTag = _corElementoRitual(r.elemento);

                  // Extrai o valor adicional e usa as variáveis corretamente
                  int aditivoDiscente =
                      r.custoDiscente ??
                      (int.tryParse(
                            RegExp(
                                  r'\+(\d+)',
                                ).firstMatch(r.discente)?.group(1) ??
                                '0',
                          ) ??
                          0);
                  int aditivoVerdadeiro =
                      r.custoVerdadeiro ??
                      (int.tryParse(
                            RegExp(
                                  r'\+(\d+)',
                                ).firstMatch(r.verdadeiro)?.group(1) ??
                                '0',
                          ) ??
                          0);

                  String sigla = r.elemento == 'Medo' ? "SAN" : "PE";
                  Color corBotao = r.elemento == 'Medo'
                      ? Colors.blueGrey
                      : Colors.blue;

                  return Container(
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0D0D),
                      border: Border.all(color: Colors.grey.shade800),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        iconColor: corTag,
                        collapsedIconColor: Colors.grey,
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        title: Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: corTag),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                r.elemento.toUpperCase(),
                                style: TextStyle(
                                  color: corTag,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                r.nome,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "${r.circulo}º Círculo • Execução: ${r.execucao} • Alcance: ${r.alcance}",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Divider(
                                  color: corTag.withValues(alpha: 0.3),
                                  thickness: 1,
                                ),
                                const SizedBox(height: 8),
                                _buildRitualDetailRow(
                                  "Alvo/Área",
                                  r.alvoAreaEfeito,
                                ),
                                _buildRitualDetailRow("Duração", r.duracao),
                                _buildRitualDetailRow(
                                  "Resistência",
                                  r.resistencia,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  r.descricao,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (r.discente != "Nenhum")
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          height: 1.4,
                                        ),
                                        children: [
                                          const TextSpan(
                                            text: "Discente ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          TextSpan(text: r.discente),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (r.verdadeiro != "Nenhum")
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          height: 1.4,
                                        ),
                                        children: [
                                          const TextSpan(
                                            text: "Verdadeiro ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          TextSpan(text: r.verdadeiro),
                                        ],
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),

                                // Botões para conjurar ritual só aparecem no modo visualização
                                if (block)
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: corBotao.withValues(
                                            alpha: 0.2,
                                          ),
                                          foregroundColor: corBotao,
                                        ),
                                        onPressed: () => _conjurarRitual(
                                          r,
                                          r.custoPE,
                                          "Normal",
                                        ),
                                        child: Text(
                                          "Normal (-${r.custoPE} $sigla)",
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      if (r.discente != "Nenhum" ||
                                          r.custoDiscente != null)
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: corBotao
                                                .withValues(alpha: 0.2),
                                            foregroundColor: corBotao,
                                          ),
                                          onPressed: () => _conjurarRitual(
                                            r,
                                            r.custoPE + aditivoDiscente,
                                            "Discente",
                                          ),
                                          child: Text(
                                            "Discente (-${r.custoPE + aditivoDiscente} $sigla)",
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      if (r.verdadeiro != "Nenhum" ||
                                          r.custoVerdadeiro != null)
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: corBotao
                                                .withValues(alpha: 0.2),
                                            foregroundColor: corBotao,
                                          ),
                                          onPressed: () => _conjurarRitual(
                                            r,
                                            r.custoPE + aditivoVerdadeiro,
                                            "Verdadeiro",
                                          ),
                                          child: Text(
                                            "Verdadeiro (-${r.custoPE + aditivoVerdadeiro} $sigla)",
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                // Esquecer ritual só aparece no modo de edição
                                if (!block)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: () {
                                        setState(
                                          () =>
                                              rituaisConhecidos.removeAt(index),
                                        );
                                        _salvarSilencioso();
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                        size: 16,
                                      ),
                                      label: const Text(
                                        "Esquecer Ritual",
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 12,
                                        ),
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRitualDetailRow(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.grey, fontSize: 12),
          children: [
            TextSpan(
              text: "$titulo: ",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            TextSpan(text: valor),
          ],
        ),
      ),
    );
  }

  void _abrirCatalogoRituais() {
    String busca = "";
    String filtroElemento = "Todos";
    String filtroCirculo = "Todos";
    Color corTemaLocal = corFundoAfinidade;

    List<String> elementos = [
      "Todos",
      "Sangue",
      "Morte",
      "Energia",
      "Conhecimento",
      "Medo",
    ];
    List<String> circulos = [
      "Todos",
      "1º Círculo",
      "2º Círculo",
      "3º Círculo",
      "4º Círculo",
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            List<Ritual> filtrados = catalogoRituais.where((r) {
              if (busca.isNotEmpty &&
                  !r.nome.toLowerCase().contains(busca.toLowerCase())) {
                return false;
              }
              if (filtroElemento != "Todos" &&
                  r.elemento != filtroElemento &&
                  r.elemento != "Variável") {
                return false;
              }

              if (filtroCirculo != "Todos") {
                int circuloBuscado = int.parse(filtroCirculo.substring(0, 1));
                if (r.circulo != circuloBuscado) return false;
              }

              if (rituaisConhecidos.any(
                (conhecido) => conhecido.nome == r.nome,
              )) {
                return false;
              }
              return true;
            }).toList();

            filtrados.sort((a, b) => a.nome.compareTo(b.nome));

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
                        Icon(Icons.auto_awesome, color: corDestaque, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "CATÁLOGO DE RITUAIS",
                            style: TextStyle(
                              fontSize: 16,
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
                    const SizedBox(height: 16),
                    TextField(
                      decoration: EstiloParanormal.customInputDeco(
                        "Pesquisar ritual...",
                        corDestaque,
                        Icons.search,
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) => setDialogState(() => busca = val),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: elementos.map((el) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(
                                el,
                                style: TextStyle(
                                  color: filtroElemento == el
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              selected: filtroElemento == el,
                              onSelected: (val) =>
                                  setDialogState(() => filtroElemento = el),
                              selectedColor: _corElementoRitual(el),
                              backgroundColor: const Color(0xFF0D0D0D),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: circulos.map((circ) {
                          bool isSelected = filtroCirculo == circ;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(
                                circ,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey.shade400,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (val) =>
                                  setDialogState(() => filtroCirculo = circ),
                              selectedColor: Colors.grey.shade300,
                              backgroundColor: const Color(0xFF0D0D0D),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade800,
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
                                  "Nenhum ritual encontrado.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filtrados.length,
                                itemBuilder: (context, index) {
                                  Ritual r = filtrados[index];
                                  Color corTag = _corElementoRitual(r.elemento);

                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade900,
                                        ),
                                      ),
                                    ),
                                    child: ListTile(
                                      title: Row(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: corTag),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              r.elemento.toUpperCase(),
                                              style: TextStyle(
                                                color: corTag,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              r.nome,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Text(
                                        "${r.circulo}º Círculo • ${r.execucao}",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 11,
                                        ),
                                      ),
                                      trailing: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: corTemaLocal,
                                          foregroundColor: corTextoAfinidade,
                                        ),
                                        onPressed: () {
                                          if (r.elemento == "Variável") {
                                            _escolherElementoVariavel(r);
                                          } else {
                                            setState(() {
                                              rituaisConhecidos.add(r);
                                              rituaisConhecidos.sort(
                                                (a, b) =>
                                                    a.nome.compareTo(b.nome),
                                              );
                                            });
                                            _salvarSilencioso();
                                            Navigator.pop(context);
                                            _mostrarNotificacao(
                                              "Ritual ${r.nome} aprendido!",
                                            );
                                          }
                                        },
                                        child: const Text(
                                          "APRENDER",
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _escolherElementoVariavel(Ritual rOriginal) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text(
            "Amaldiçoar (${rOriginal.nome})",
            style: TextStyle(color: corDestaque),
          ),
          content: const Text(
            "Escolha qual elemento você irá usar para conjurar este ritual:",
            style: TextStyle(color: Colors.grey),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: ["Sangue", "Morte", "Energia", "Conhecimento"].map((el) {
            Color corBotao = _corElementoRitual(el);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corBotao,
                    foregroundColor: el == "Conhecimento"
                        ? Colors.black
                        : Colors.white,
                  ),
                  onPressed: () {
                    Ritual novoRitual = Ritual(
                      nome: "${rOriginal.nome} ($el)",
                      elemento: el,
                      circulo: rOriginal.circulo,
                      execucao: rOriginal.execucao,
                      alcance: rOriginal.alcance,
                      alvoAreaEfeito: rOriginal.alvoAreaEfeito,
                      duracao: rOriginal.duracao,
                      resistencia: rOriginal.resistencia,
                      descricao: rOriginal.descricao,
                      discente: rOriginal.discente,
                      verdadeiro: rOriginal.verdadeiro,
                      custoPE: rOriginal.custoPE,
                      custoDiscente: rOriginal.custoDiscente,
                      custoVerdadeiro: rOriginal.custoVerdadeiro,
                    );
                    setState(() {
                      rituaisConhecidos.add(novoRitual);
                      rituaisConhecidos.sort(
                        (a, b) => a.nome.compareTo(b.nome),
                      );
                    });
                    _salvarSilencioso();
                    Navigator.pop(context);
                    Navigator.pop(context);
                    _mostrarNotificacao("Ritual ${novoRitual.nome} aprendido!");
                  },
                  child: Text(
                    el.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _mostrarDialogCriarRitual() {
    TextEditingController nomeCtrl = TextEditingController();
    TextEditingController execucaoCtrl = TextEditingController(text: "Padrão");
    TextEditingController alcanceCtrl = TextEditingController(text: "Curto");
    TextEditingController alvoCtrl = TextEditingController(text: "1 ser");
    TextEditingController duracaoCtrl = TextEditingController(text: "Cena");
    TextEditingController resistCtrl = TextEditingController(text: "Nenhuma");
    TextEditingController descCtrl = TextEditingController();
    TextEditingController discenteCtrl = TextEditingController();
    TextEditingController verdadeiroCtrl = TextEditingController();

    TextEditingController custoDiscCtrl = TextEditingController();
    TextEditingController custoVerdCtrl = TextEditingController();

    String elAtual = "Conhecimento";
    int circuloAtual = 1;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: Text(
                "Criar Ritual Personalizado",
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
                        "Nome do Ritual",
                        corDestaque,
                        Icons.edit,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownFicha(
                            label: "Elemento",
                            value: elAtual,
                            options: const [
                              "Conhecimento",
                              "Energia",
                              "Morte",
                              "Sangue",
                              "Medo",
                              "Outro",
                            ],
                            onChanged: (val) =>
                                setDialogState(() => elAtual = val!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownFicha(
                            label: "Círculo",
                            value: circuloAtual.toString(),
                            options: const ["1", "2", "3", "4"],
                            onChanged: (val) => setDialogState(
                              () => circuloAtual = int.parse(val!),
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
                            controller: execucaoCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: EstiloParanormal.customInputDeco(
                              "Execução",
                              corDestaque,
                              Icons.timer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: alcanceCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: EstiloParanormal.customInputDeco(
                              "Alcance",
                              corDestaque,
                              Icons.straighten,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: alvoCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: EstiloParanormal.customInputDeco(
                        "Alvo / Área / Efeito",
                        corDestaque,
                        Icons.my_location,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: duracaoCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: EstiloParanormal.customInputDeco(
                              "Duração",
                              corDestaque,
                              Icons.hourglass_bottom,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: resistCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: EstiloParanormal.customInputDeco(
                              "Resistência",
                              corDestaque,
                              Icons.shield,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: EstiloParanormal.customInputDeco(
                        "Descrição do Efeito",
                        corDestaque,
                        Icons.description,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.grey),
                    const Text(
                      "Aprimoramentos (Deixe em branco se não houver)",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 8),
                    TextField(
                      controller: discenteCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: EstiloParanormal.customInputDeco(
                        "Efeito Discente",
                        corDestaque,
                        Icons.upgrade,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: custoDiscCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: EstiloParanormal.customInputDeco(
                        "Custo Adicional Discente (+PE)",
                        corDestaque,
                        Icons.add,
                      ),
                    ),

                    const SizedBox(height: 12),
                    TextField(
                      controller: verdadeiroCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: EstiloParanormal.customInputDeco(
                        "Efeito Verdadeiro",
                        corDestaque,
                        Icons.keyboard_double_arrow_up,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: custoVerdCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: EstiloParanormal.customInputDeco(
                        "Custo Adicional Verdadeiro (+PE)",
                        corDestaque,
                        Icons.add,
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
                    backgroundColor: corFundoAfinidade,
                    foregroundColor: corTextoAfinidade,
                  ),
                  onPressed: () {
                    if (nomeCtrl.text.trim().isEmpty) return;

                    int custoCalculado = 1;
                    if (circuloAtual == 2) custoCalculado = 3;
                    if (circuloAtual == 3) custoCalculado = 6;
                    if (circuloAtual == 4) custoCalculado = 10;

                    Ritual novoRitual = Ritual(
                      nome: nomeCtrl.text.trim(),
                      elemento: elAtual,
                      circulo: circuloAtual,
                      execucao: execucaoCtrl.text.trim().isEmpty
                          ? "Padrão"
                          : execucaoCtrl.text.trim(),
                      alcance: alcanceCtrl.text.trim().isEmpty
                          ? "Curto"
                          : alcanceCtrl.text.trim(),
                      alvoAreaEfeito: alvoCtrl.text.trim().isEmpty
                          ? "1 ser"
                          : alvoCtrl.text.trim(),
                      duracao: duracaoCtrl.text.trim().isEmpty
                          ? "Instantânea"
                          : duracaoCtrl.text.trim(),
                      resistencia: resistCtrl.text.trim().isEmpty
                          ? "Nenhuma"
                          : resistCtrl.text.trim(),
                      descricao: descCtrl.text.trim().isEmpty
                          ? "Efeito customizado do jogador."
                          : descCtrl.text.trim(),
                      discente: discenteCtrl.text.trim().isEmpty
                          ? "Nenhum"
                          : discenteCtrl.text.trim(),
                      verdadeiro: verdadeiroCtrl.text.trim().isEmpty
                          ? "Nenhum"
                          : verdadeiroCtrl.text.trim(),
                      custoPE: custoCalculado,
                      custoDiscente: custoDiscCtrl.text.isNotEmpty
                          ? int.tryParse(custoDiscCtrl.text.trim())
                          : null,
                      custoVerdadeiro: custoVerdCtrl.text.isNotEmpty
                          ? int.tryParse(custoVerdCtrl.text.trim())
                          : null,
                    );

                    setState(() {
                      rituaisConhecidos.add(novoRitual);
                      rituaisConhecidos.sort(
                        (a, b) => a.nome.compareTo(b.nome),
                      );
                    });

                    _salvarSilencioso();
                    Navigator.pop(context);
                    _mostrarNotificacao("Ritual ${novoRitual.nome} criado!");
                  },
                  child: const Text(
                    "CRIAR E APRENDER",
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
