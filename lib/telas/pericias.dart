// ignore_for_file: invalid_use_of_protected_member, library_private_types_in_public_api
part of 'ficha_agente.dart';

extension PericiasFicha on _FichaAgenteState {
  Widget _buildAbaPericias(bool block, Color corDoPainel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
      child: SecaoFicha(
        titulo: "Perícias",
        corTema: corFundoAfinidade,
        corTexto: corTextoAfinidade,
        isMorte: afinidadeAtual == 'Morte',
        filhos: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: listaPericias.length,
            itemBuilder: (context, index) {
              var pericia = listaPericias[index];

              int bonusExtra = 0;
              var aprimoramentos = inventario.where((i) {
                bool isUtensilio = i.nome.toLowerCase().contains("utensílio");
                return i.periciaVinculada == pericia.id &&
                    (i.equipado || isUtensilio);
              });

              for (var v in aprimoramentos) {
                bool temModAprimorado =
                    v.modificacoes.contains("Aprimorado") ||
                    v.modificacoes.contains("Aprimorada");
                int b = temModAprimorado ? 5 : 2;
                if (b > bonusExtra) bonusExtra = b;
              }

              int bonusDaOrigemAplicado = bonusOrigem[pericia.id] ?? 0;
              int bonusTotalExtras = bonusExtra + bonusDaOrigemAplicado;
              int totalBonus = pericia.treino + bonusTotalExtras;

              bool isLocked =
                  pericia.daOrigem || periciasClasse.contains(pericia.id);

              bool sofreCarga = [
                'acrobacia',
                'crime',
                'furtividade',
              ].contains(pericia.id);
              bool precisaKit = [
                'enganacao',
                'crime',
                'medicina',
                'tecnologia',
              ].contains(pericia.id);

              // Lógica de UX: Deixa o aviso vermelho se estiver penalizado
              bool temPenalidadeCarga = sofreCarga && estaSobrecarregado;
              bool temPenalidadeKit =
                  precisaKit &&
                  !inventario.any(
                    (i) => i.nome.toLowerCase().contains(
                      "kit de ${pericia.nome.toLowerCase()}",
                    ),
                  );

              // Lógica dos Ícones de Bônus
              bool temBonusGeral = bonusDaOrigemAplicado > 0;
              bool temVestimenta = aprimoramentos.isNotEmpty;

              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade800),
                  ),
                  // Volta a ficar com a cor do tema se for treinada, mesmo que seja perícia de classe/origem!
                  color: pericia.treino > 0
                      ? corDoPainel.withValues(alpha: 0.1)
                      : Colors.transparent,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Row(
                        children: [
                          // ================= D20 ICON RESTAURADO =================
                          GestureDetector(
                            // Agora só verifica se está no modo visualização (block). Pode rolar à vontade!
                            onTap: block
                                ? () => _rolarPericia(pericia, totalBonus)
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Image.asset(
                                'assets/d20_icon.png',
                                width: 20,
                                height: 20,
                                // Fica com a cor do tema se estiver no modo de rolar dados, senão fica cinza para indicar edição
                                color: block
                                    ? corDoPainel
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),

                          // ================= NOME E ÍCONES ============================
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: GestureDetector(
                                    onTap: () =>
                                        _mostrarDialogDescricaoPericia(pericia),
                                    child: RichText(
                                      overflow: TextOverflow.ellipsis,
                                      text: TextSpan(
                                        style: TextStyle(
                                          color: pericia.treino > 0
                                              ? Colors.white
                                              : Colors.grey,
                                          fontWeight: pericia.treino > 0
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          decoration: TextDecoration.underline,
                                          decorationColor: pericia.treino > 0
                                              ? Colors.white54
                                              : Colors.grey.shade800,
                                          decorationStyle:
                                              TextDecorationStyle.dotted,
                                          fontSize: 14,
                                        ),
                                        children: [
                                          TextSpan(text: "${pericia.nome} "),
                                          if (sofreCarga)
                                            TextSpan(
                                              text: "+",
                                              style: TextStyle(
                                                color: temPenalidadeCarga
                                                    ? Colors.redAccent
                                                    : corDoPainel,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          if (precisaKit)
                                            TextSpan(
                                              text: "*",
                                              style: TextStyle(
                                                color: temPenalidadeKit
                                                    ? Colors.redAccent
                                                    : corDoPainel,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          TextSpan(
                                            text: " (${pericia.atributo})",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Ícones de Bônus Reposicionados Aqui (Seguros)
                                if (temVestimenta)
                                  Padding(
                                    padding: EdgeInsets.only(left: 4.0),
                                    child: Icon(
                                      Icons.checkroom,
                                      color: corDoPainel,
                                      size: 16,
                                    ),
                                  ),
                                if (temBonusGeral)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4.0),
                                    child: Icon(
                                      Icons.add_circle,
                                      color: corDoPainel,
                                      size: 16,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: pericia.treino,
                          isExpanded: true,
                          alignment: Alignment.centerRight,
                          icon: const Icon(Icons.arrow_drop_down, size: 16),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                          items: [
                            if (!isLocked || pericia.treino == 0)
                              const DropdownMenuItem(
                                value: 0,
                                alignment: Alignment.centerRight,
                                child: Text("(+0)"),
                              ),
                            const DropdownMenuItem(
                              value: 5,
                              alignment: Alignment.centerRight,
                              child: Text("(+5)"),
                            ),
                            const DropdownMenuItem(
                              value: 10,
                              alignment: Alignment.centerRight,
                              child: Text("(+10)"),
                            ),
                            const DropdownMenuItem(
                              value: 15,
                              alignment: Alignment.centerRight,
                              child: Text("(+15)"),
                            ),
                          ],
                          onChanged: block
                              ? null
                              : (val) {
                                  setState(() {
                                    pericia.treino = val!;
                                    atualizarFicha();
                                  });
                                },
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "+",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 35,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey.shade800),
                      ),
                      child: Text(
                        "+$bonusTotalExtras",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "=",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 35,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: corDoPainel.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: corDoPainel.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        "+$totalBonus",
                        style: TextStyle(
                          color: corDoPainel,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _mostrarDialogDescricaoPericia(Pericia pericia) {
    Map<String, String> descricoesPericias = {
      'acrobacia':
          "Você consegue fazer proezas acrobáticas.\n\n"
          "Amortecer Queda (Veterano, DT 15): Quando cai, você pode gastar uma reação e fazer um teste para reduzir o dano. Se passar, reduz em 1d6, mais 1d6 para cada 5 pontos acima da DT. Se reduzir a zero, cai de pé.\n\n"
          "Equilíbrio: Andar por superfícies precárias exige um teste por ação de movimento. DT 10 (escorregadio), 15 (estreito) ou 20 (muito estreito). Passar avança metade do deslocamento. Falhar não avança. Falhar por 5 ou mais, cai.\n\n"
          "Escapar: Escapar de amarras. A DT é o teste de Agilidade de quem amarrou +10 (cordas) ou 30 (algemas). Gasta uma ação completa.\n\n"
          "Levantar-se Rapidamente (Treinado, DT 20): Se caído, faça um teste. Se passar, levanta como ação livre. Se falhar, gasta a ação de movimento mas continua caído.\n\n"
          "Passar por Espaço Apertado (Treinado, DT 25): Espremer-se por lugares onde só a cabeça passaria. Gasta uma ação completa e avança metade do deslocamento.\n\n"
          "Passar por Inimigo: Atravesse um espaço ocupado oposto a Acrobacia, Iniciativa ou Luta do oponente. Conta como terreno difícil.",

      'adestramento':
          "Você sabe lidar com animais.\n\n"
          "Acalmar Animal (DT 25): Acalma um animal nervoso/agressivo. Gasta uma ação completa.\n\n"
          "Cavalgar: Montar como ação livre exige DT 20. Terrenos difíceis exigem DT 15 ou 20. Falhar causa queda e 1d6 de dano.\n\n"
          "Manejar Animal (DT 15): Faz o animal realizar tarefa treinada. Gasta uma ação de movimento.",

      'artes':
          "Expressão através de música, dança, atuação, etc.\n\n"
          "Impressionar: Teste oposto à Vontade do alvo. Se passar, recebe +2 em testes baseados em Presença contra ele na cena. Se falhar, sofre –2. Leva de minutos a horas.",

      'atletismo':
          "Você pode realizar façanhas atléticas.\n\n"
          "Corrida: Ação completa. Avança seu deslocamento + o resultado do teste em quadrados de 1,5m. Limite de rodadas igual ao Vigor (depois exige Fortitude DT 5+5).\n\n"
          "Escalar: Ação de movimento. Avança metade do deslocamento. DT 10 (com apoios), 15 (árvore), 20 (muro) ou 25 (parede lisa).\n\n"
          "Natação: Ação de movimento. DT 10 (calma), 15 (agitada), 20 (tempestade). Falhar por 5 ou mais afunda. Prender a respiração dura rodadas iguais ao Vigor.\n\n"
          "Saltar: Salto longo: DT 5 por quadrado de 1,5m. Altura: DT 15 por quadrado. Exige 6m de corrida (sem espaço, DT +5).",

      'atualidades':
          "Conhecimento geral, política e entretenimento.\n\n"
          "DT 15 para informações comuns. DT 20 para específicas. DT 25 para quase desconhecidas.",

      'ciencias':
          "Conhecimento em matemática, física, química, etc.\n\n"
          "Questões complexas exigem DT 20. Avaliações experimentais exigem DT 30.",

      'crime':
          "Você sabe exercer atividades ilícitas. Exigem Kit (sem ele sofre -5).\n\n"
          "Arrombar: Ação completa. DT 20 (comum), 25 (reforçada), 30 (avançada/cofre).\n\n"
          "Furto (DT 20): Ação padrão. Vítima pode notar com Percepção oposta.\n\n"
          "Ocultar: Ação padrão. Oposto à Percepção de quem vê. Se revistado, o observador ganha +10.\n\n"
          "Sabotar (Veterano): Desabilitar dispositivos. DT 20 a 30. Gasta 1d4+1 ações completas.",

      'diplomacia':
          "Você convence pessoas com lábia e argumentação.\n\n"
          "Acalmar (Treinado, DT 20): Ação padrão. Estabiliza aliado enlouquecendo para Sanidade 1.\n\n"
          "Mudar Atitude: Oposto à Vontade. Muda a atitude de um NPC em 1 passo (2 passos se passar por 10+).\n\n"
          "Persuasão (DT 20): Convence a fazer favores. Tarefas perigosas falham ou impõem -10.",

      'enganacao':
          "Você manipula pessoas com blefes e trapaças.\n\n"
          "Disfarce (Treinado): Oposto à Percepção. Exige 10 min e um kit (sem kit sofre -5).\n\n"
          "Falsificação (Veterano): Oposto à Percepção de quem examina. Assinaturas impõem -2d20.\n\n"
          "Fintar (Treinado): Ação padrão. Oposto aos Reflexos do alvo. Deixa o alvo desprevenido.\n\n"
          "Insinuação (DT 20): Mensagens secretas. Terceiros usam Intuição oposta para captar.\n\n"
          "Intriga (DT 20): Espalha uma fofoca. Exige pelo menos um dia. Alvos podem investigar a fonte.\n\n"
          "Mentir: Oposto à Intuição da vítima. Mentiras absurdas sofrem -2d20.",

      'fortitude':
          "Testes de vitalidade contra doenças, venenos, manter fôlego ou correr longas distâncias.\n\n"
          "Usado como Defesa de Bloqueio passiva em combates.",

      'furtividade':
          "Ser discreto e sorrateiro.\n\n"
          "Esconder-se: Ação livre no fim do turno. Oposto à Percepção. Mover-se mais que a metade impõe -1d20. Atacar impõe -3d20.\n\n"
          "Seguir: Oposto à Percepção do alvo. Lugares desertos impõem -5.",

      'iniciativa': "Sua velocidade de reação no início de uma cena de ação.",

      'intimidacao':
          "Assustar e coagir. Efeitos de Medo.\n\n"
          "Assustar (Treinado): Ação padrão oposta à Vontade. Deixa o alvo Abalado na cena (ou Apavorado por 1 rodada se passar por 10+).\n\n"
          "Coagir: Obriga um NPC adjacente a obedecer uma ordem. Leva minutos e deixa o alvo hostil.",

      'intuicao':
          "Medir empatia e sexto sentido.\n\n"
          "Perceber Mentira: Oposto à Enganação.\n\n"
          "Pressentimento (Treinado, DT 20): Analisa pessoas ou situações para perceber anormalidades.",

      'investigacao':
          "Você sabe como descobrir pistas e informações.\n\n"
          "Interrogar: Descobrir informações com pessoas. Informações restritas têm DT 20. Confidenciais têm DT 30. Gasta de 1 hora a 1 dia.\n\n"
          "Procurar: Examinar um local. DT 15 (item discreto), 20 (escondido) ou 30 (muito bem escondido). Gasta de uma ação completa a 1 dia.",

      'luta':
          "Fazer ataques corpo a corpo.\n\n"
          "A DT é a Defesa do alvo. Se você acertar, causa dano de acordo com a arma utilizada.",

      'medicina':
          "Tratar ferimentos, doenças e venenos. Exige Kit (sem ele sofre -5, ou -1d20 se for em si mesmo).\n\n"
          "Primeiros Socorros (DT 20): Ação padrão. Tira um alvo adjacente de 'Morrendo' e deixa-o com 1 PV.\n\n"
          "Cuidados Prolongados (Veterano, DT 20): Ação de interlúdio. Trata até 1 ser por Intelecto. Eles recuperam o dobro de PV ao dormir.\n\n"
          "Necropsia (Treinado, DT 20): Exige 10 min. Determina causa e hora da morte (causas místicas DT +10).\n\n"
          "Tratamento (Treinado): Ação completa. Ajuda contra doenças/venenos contínuos. Concede +5 no próximo teste de Fortitude do paciente.",

      'ocultismo':
          "Você estudou o paranormal.\n\n"
          "Identificar Criatura: Ação completa. A DT é a da Presença Perturbadora. Revela poderes/vulnerabilidades (mais um por cada 5 pontos acima da DT). Falhar por 5+ dá conclusão errada.\n\n"
          "Identificar Item Amaldiçoado (DT 20): Ação de interlúdio. Identifica poderes ou rituais de um objeto.\n\n"
          "Identificar Ritual (DT 10 + 5/círculo): Reação. Descobre o ritual sendo lançado.\n\n"
          "Informação: Responde sobre o Outro Lado. DT 20 para complexas, DT 30 para mistérios e enigmas.",

      'percepcao':
          "Você nota coisas usando os sentidos.\n\n"
          "Observar: Ver coisas ocultas. DT de 15 a 30, ou oposto à Furtividade/Crime do alvo. Ler lábios tem DT 20.\n\n"
          "Ouvir: DT 15 para sussurros (+5 atrás de portas). Perceber seres invisíveis tem DT 20 ou +10 na Furtividade do ser. Ouvir dormindo sofre -2d20.",

      'pilotagem':
          "Operar veículos.\n\n"
          "Gasta ação de movimento. Situações ruins têm DT 15, terríveis DT 25. Veteranos podem pilotar aeronaves.",

      'pontaria':
          "Fazer ataques à distância.\n\n"
          "A DT é a Defesa do alvo. Se acertar, causa dano da arma.",

      'profissao':
          "Exercer uma profissão específica.\n\n"
          "Pode substituir testes dependendo do background (ex: advogado usando para Diplomacia legal). Garante um item adicional no início das missões (Categoria I para Treinado, II para Veterano, III para Expert).",

      'reflexos':
          "Testes de reação rápida contra armadilhas e explosões.\n\n"
          "Também usado para evitar Fintas e como Defesa de Esquiva em combates.",

      'religiao':
          "Teologia e religiões do mundo.\n\n"
          "Acalmar (DT 20): Como Diplomacia para estabilizar sanidade.\n\n"
          "Informação: Sobre mitos e relíquias. DT 10 a 30.\n\n"
          "Rito (Veterano, DT 20): Realiza cerimônias religiosas.",

      'sobrevivencia':
          "Guiar-se nos ermos e evitar perigos naturais.\n\n"
          "Acampamento (Treinado): DT 15 a 25. Permite interlúdios ao relento.\n\n"
          "Identificar Animal (Treinado, DT 20): Ação completa para animais exóticos.\n\n"
          "Orientar-se: Teste por dia para viajar. Falhar avança metade, falhar por 5+ se perde o dia todo.\n\n"
          "Rastrear (Treinado): DT 15 a 25. Deslocamento cai pela metade. Cada dia atrasado aumenta a DT em +1.",

      'tatica':
          "Você recebeu educação militar.\n\n"
          "Analisar Terreno (DT 20): Ação de movimento. Descobre vantagens como cobertura ou terreno elevado.\n\n"
          "Plano de Ação (Veterano, DT 20): Ação padrão. Dá +5 na Iniciativa de um aliado em alcance médio.",

      'tecnologia':
          "Eletrônica e informática avançada.\n\n"
          "Falsificação (Veterano): Para documentos digitais.\n\n"
          "Hackear: DT 15 (PC pessoal) a 25 (Servidor militar). Gasta 1d4+1 ações completas. Falhar por 5+ aciona rastreio.\n\n"
          "Localizar Arquivo: Em sistemas já invadidos. Ação completa (DT 15) a 1d6+2 ações completas (DT 25).\n\n"
          "Operar Dispositivo: Acessar câmeras, alarmes. DT 15 a 25. Gasta 1d4+1 ações completas e exige Kit (sem kit sofre -5).",

      'vontade':
          "Testes de determinação contra intimidação e rituais mentais.\n\n"
          "Também usado para conjurar rituais em condições adversas.",
    };

    String desc =
        descricoesPericias[pericia.id] ??
        "Descrição desta perícia ainda não foi adicionada no banco de dados.";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: corDestaque.withValues(alpha: 0.3)),
        ),
        title: Row(
          children: [
            Icon(Icons.menu_book, color: corDestaque),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "${pericia.nome} (${pericia.atributo})",
                style: TextStyle(
                  color: corDestaque,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            desc,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.4,
              fontSize: 14,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fechar", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _rolarPericia(Pericia pericia, int bonusTotal) {
    if (!_modoVisualizacao) return;

    // 1. Monstruoso 40% (Conhecimento muda a Enganação para Intelecto)
    String atribUsado = pericia.atributo;
    if (trilhaAtual == 'monstruoso' && afinidadeAtual == 'Conhecimento' && nex >= 40 && pericia.id == 'enganacao') {
      atribUsado = 'INT';
    }

    int valorAtrib = 1;
    switch (atribUsado.toUpperCase()) {
      case 'AGI': valorAtrib = efAgi; break; // Puxando do atributo Efetivo!
      case 'FOR': valorAtrib = efFor; break;
      case 'INT': valorAtrib = efInt; break;
      case 'PRE': valorAtrib = efPre; break;
      case 'VIG': valorAtrib = efVig; break;
    }

    int penalidadeCarga = 0;
    if (estaSobrecarregado && ['acrobacia', 'crime', 'furtividade'].contains(pericia.id)) penalidadeCarga = 5;

    int penalidadeKit = 0;
    if (['enganacao', 'crime', 'medicina', 'tecnologia'].contains(pericia.id)) {
      bool temKit = inventario.any((i) => i.nome.toLowerCase().contains("kit de ${pericia.nome.toLowerCase()}"));
      if (!temKit) penalidadeKit = 5;
    }

    // 2. Aplica DADOS EXTRAS/REMOVIDOS do Monstruoso (O -1d20 ou +1d20)
    int modDados = dadosExtrasPericias[pericia.id] ?? 0;
    int qtdDados = valorAtrib + modDados;
    
    bool rolarPior = false;
    if (qtdDados <= 0) {
      qtdDados = 2 + qtdDados.abs();
      rolarPior = true;
    }

    List<int> resultados = List.generate(qtdDados, (_) => Random().nextInt(20) + 1);
    int d20Escolhido = rolarPior ? resultados.reduce(min) : resultados.reduce(max);

    int resultadoFinal = d20Escolhido + bonusTotal - penalidadeCarga - penalidadeKit;

    Color corDoPopUp = corDestaque;
    String mensagemCritico = "";
    Color corNumero = Colors.white;

    if (d20Escolhido == 20 && valorAtrib > 0) {
      mensagemCritico = "SUCESSO CRÍTICO no Dado!";
      corNumero = const Color.fromARGB(255, 63, 152, 63);
    } else if (d20Escolhido == 1) {
      mensagemCritico = "FALHA CRÍTICA no Dado!";
      corNumero = Colors.redAccent;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          "Teste de ${pericia.nome}",
          textAlign: TextAlign.center,
          style: TextStyle(color: corDoPopUp),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Dados (${rolarPior ? 'Pior de $qtdDados' : '${qtdDados}d20'}): ${resultados.join(', ')}",
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            if (modDados != 0) 
              Text(
                "Modificador Monstruoso: ${modDados > 0 ? '+' : ''}${modDados}d20",
                style: const TextStyle(color: Colors.orangeAccent, fontSize: 11, fontStyle: FontStyle.italic),
              ),
            const SizedBox(height: 8),
            Text(
              "Total: $resultadoFinal",
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: corNumero),
            ),
            const SizedBox(height: 12),
            Text(
              "Dado Base: $d20Escolhido\nBônus: +$bonusTotal"
              "${penalidadeCarga > 0 ? '\nCarga: -$penalidadeCarga' : ''}"
              "${penalidadeKit > 0 ? '\nSem Kit: -$penalidadeKit' : ''}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
            ),
            if (mensagemCritico.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(mensagemCritico, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: corNumero, letterSpacing: 1.2)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: TextStyle(color: corDoPopUp)),
          ),
        ],
      ),
    );
  }
  
  void _inicializarPericias() {
    listaPericias = periciasBase
        .map(
          (p) =>
              Pericia(nome: p["nome"]!, atributo: p["atributo"]!, id: p["id"]!),
        )
        .toList();
  }
}
