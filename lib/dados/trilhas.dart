class DadosTrilha {
  final String id;
  final String nome;
  final String classe;
  final String descricao;
  final Map<int, Map<String, String>> habilidades;

  DadosTrilha({
    required this.id,
    required this.nome,
    required this.classe,
    required this.descricao,
    required this.habilidades,
  });
}

Map<String, DadosTrilha> trilhasOrdem = {
  // Trilhas de Combatente
  'aniquilador': DadosTrilha(
    id: 'aniquilador',
    nome: 'Aniquilador',
    classe: 'combatente',
    descricao: "Você é treinado para abater alvos com eficiência e velocidade. Suas armas são suas melhores amigas e você cuida tão bem delas quanto de seus companheiros de equipe.",
    habilidades: {
      10: {"A Favorita": "Escolha uma arma para ser sua favorita, como katana ou fuzil de assalto. A categoria da arma escolhida é reduzida em I."},
      40: {"Técnica Secreta": "A categoria da arma favorita passa a ser reduzida em II. Quando faz um ataque com ela, você pode gastar 2 PE para executar um dos efeitos abaixo. Pode adicionar mais efeitos gastando +2 PE por extra:\n• Amplo: O ataque pode atingir um alvo adicional em seu alcance e adjacente ao original.\n• Destruidor: Aumenta o multiplicador de crítico da arma em +1."},
      65: {"Técnica Sublime": "Você adiciona os seguintes efeitos à lista de sua Técnica Secreta:\n• Letal: Aumenta a margem de ameaça em +2. Pode escolher duas vezes para +5.\n• Perfurante: Ignora até 5 pontos de resistência a dano de qualquer tipo do alvo."},
      99: {"Máquina de Matar": "A categoria da arma favorita passa a ser reduzida em III, ela recebe +2 na margem de ameaça e seu dano aumenta em um dado do mesmo tipo."},
    },
  ),

  'comandante_de_campo': DadosTrilha(
    id: 'comandante_de_campo',
    nome: 'Comandante de Campo',
    classe: 'combatente',
    descricao: "Sem um oficial uma batalha não passa de uma briga de bar. Você é treinado para coordenar e auxiliar seus companheiros em combate, tomando decisões rápidas.",
    habilidades: {
      10: {"Inspirar Confiança": "Sua liderança inspira seus aliados. Você pode gastar uma reação e 2 PE para fazer um aliado em alcance curto rolar novamente um teste recém realizado."},
      40: {"Estrategista": "Você pode direcionar aliados em alcance curto. Gaste uma ação padrão e 1 PE por aliado (limitado pelo Intelecto). No próximo turno deles, ganham uma ação de movimento adicional."},
      65: {"Brecha na Guarda": "Uma vez por rodada, quando um aliado causar dano em um inimigo em alcance curto, gaste uma reação e 2 PE para que você ou outro aliado faça um ataque extra contra ele. O alcance de inspirar e estrategista aumenta para médio."},
      99: {"Oficial Comandante": "Gaste uma ação padrão e 5 PE para que cada aliado que você possa ver em alcance médio receba uma ação padrão adicional no próximo turno dele."},
    },
  ),

  'guerreiro': DadosTrilha(
    id: 'guerreiro',
    nome: 'Guerreiro',
    classe: 'combatente',
    descricao: "Você treinou sua musculatura e movimentos a ponto de transformar seu corpo em uma verdadeira arma. Com golpes corpo a corpo tão poderosos quanto uma bala.",
    habilidades: {
      10: {"Técnica Letal": "Você recebe um aumento de +2 na margem de ameaça com todos os seus ataques corpo a corpo."},
      40: {"Revidar": "Sempre que bloquear um ataque, você pode gastar uma reação e 2 PE para fazer um ataque corpo a corpo no inimigo que o atacou."},
      65: {"Força Opressora": "Quando acerta um ataque corpo a corpo, gaste 1 PE para realizar uma manobra derrubar ou empurrar como ação livre. Se empurrar, recebe +5 para cada 10 de dano. Se derrubar, gaste 1 PE para ataque extra contra o alvo caído."},
      99: {"Potência Máxima": "Quando usa seu Ataque Especial com armas corpo a corpo, todos os bônus numéricos são dobrados (Ex: gastando 5 PE para +5/+15, você recebe +10/+30)."},
    },
  ),

  'operacoes_especiais': DadosTrilha(
    id: 'operacoes_especiais',
    nome: 'Operações Especiais',
    classe: 'combatente',
    descricao: "Você é um combatente eficaz. Suas ações são calculadas e otimizadas, sempre antevendo os movimentos inimigos.",
    habilidades: {
      10: {"Iniciativa Aprimorada": "Você recebe +5 em Iniciativa e uma ação de movimento adicional na primeira rodada."},
      40: {"Ataque Extra": "Uma vez por rodada, quando faz um ataque, você pode gastar 2 PE para fazer um ataque adicional."},
      65: {"Surto de Adrenalina": "Uma vez por rodada, você pode gastar 5 PE para realizar uma ação padrão ou de movimento adicional."},
      99: {"Sempre Alerta": "Você recebe uma ação padrão adicional no início de cada cena de combate."},
    },
  ),

  'tropa_de_choque': DadosTrilha(
    id: 'tropa_de_choque',
    nome: 'Tropa de Choque',
    classe: 'combatente',
    descricao: "Você é duro na queda. Treinou seu corpo para resistir a traumas físicos, tornando-o praticamente inquebrável.",
    habilidades: {
      10: {"Casca Grossa": "Você recebe +1 PV para cada 5% de NEX e, quando faz um bloqueio, soma seu Vigor na resistência a dano recebida."},
      40: {"Cai Dentro": "Sempre que um oponente em alcance curto ataca um aliado, gaste uma reação e 1 PE para o oponente testar Vontade (DT Vig). Se falhar, ele deve atacar você."},
      65: {"Duro de Matar": "Ao sofrer dano não paranormal, gaste uma reação e 2 PE para reduzir à metade. Em NEX 85%, pode usar contra dano paranormal."},
      99: {"Inquebrável": "Enquanto estiver machucado, recebe +5 na Defesa e RD 5. Enquanto estiver morrendo, não fica indefeso e pode realizar ações normais."},
    },
  ),

  'agente_secreto': DadosTrilha(
    id: 'agente_secreto',
    nome: 'Agente Secreto',
    classe: 'combatente',
    descricao: "Indivíduos treinados para trabalhar sozinhos ou em pequenos grupos, que contam apenas com suas próprias habilidades e sorrisos carismáticos.",
    habilidades: {
      10: {"Carteirada": "Recebe treino ou +2 em Diplomacia ou Enganação. Recebe documentos falsos indetectáveis por pessoas comuns que dão privilégios jurídicos e acesso a áreas restritas."},
      40: {"O Sorriso": "Recebe +2 em Diplomacia e Enganação. Ao falhar, gaste 2 PE para repetir (apenas uma vez). Uma vez por cena, pode testar Diplomacia para acalmar a si mesmo."},
      65: {"Método Investigativo": "A urgência de investigações aumenta em 1 rodada. Pode gastar 2 PE para anular um evento ruim de investigação (aumenta +2 PE por uso extra)."},
      99: {"Multifacetado": "Uma vez por cena, gaste 5 de Sanidade para receber todas as habilidades até 65% de uma trilha de combatente ou especialista. Sanidade só recupera no fim da missão."},
    },
  ),

  'cacador': DadosTrilha(
    id: 'cacador',
    nome: 'Caçador',
    classe: 'combatente',
    descricao: "Valendo-se de relatos e incidentes inexplicáveis, você reúne informações sobre como caçar as coisas que espreitam na escuridão.",
    habilidades: {
      10: {"Rastrear o Paranormal": "Treino ou +2 em Sobrevivência. Pode usar Sobrevivência no lugar de Ocultismo (identificar criaturas), Investigação e Percepção para rastros paranormais."},
      40: {"Estudar Fraquezas": "Gaste ação de interlúdio estudando uma pista do alvo. Descobre uma informação útil e ganha +1 em testes contra o alvo por pista até o fim da missão."},
      65: {"Atacar das Sombras": "Não sofre penalidade de Furtividade por mover-se rápido. Atacar com armas silenciosas reduz penalidade para –1d20. Visibilidade inicial reduzida em 1."},
      99: {"Estudar a Presa": "Você pode transformar um tipo de ser estudado em sua 'presa'. Contra eles, recebe +1d20 em testes, +1 na margem e crítico, e RD 5."},
    },
  ),

  'monstruoso': DadosTrilha(
    id: 'monstruoso',
    nome: 'Monstruoso',
    classe: 'combatente',
    descricao: "Você propositalmente desfigura e altera seu corpo para que as Entidades o invadam com maior intensidade.",
    habilidades: {
      10: {"Ser Amaldiçoado": "Treino ou +2 em Ocultismo. Escolha um elemento (Sangue, Morte, Conhecimento ou Energia). Executar a rotina bizarra do elemento concede bônus específicos (+RD e trocas de atributos), caso contrário sofre de fome/sede."},
      40: {"Ser Macabro": "Sua RD elemental aumenta para 10, penalidades aumentam para -2d20. O corpo ganha novas capacidades dependendo do elemento (Ex: usar Força ou Agilidade para PE)."},
      65: {"Ser Assustador": "Sua RD aumenta para 15, mas perde 1 de Presença para sempre. Ganha capacidades extremas do elemento (Ex: Mordida de Sangue, Dados de bônus de Conhecimento)."},
      99: {"Ser Aterrorizante": "Transformação completa. Torna-se criatura paranormal. RD aumenta para 20 e ganha poderes máximos (Imortalidade na Morte, Forma plasmática na Energia, etc)."},
    },
  ),

  // Trilhas de Especialista
  'bibliotecario': DadosTrilha(
    id: 'bibliotecario',
    nome: 'Bibliotecário',
    classe: 'especialista',
    descricao: "Passar a vida cercado de conhecimento não o torna menos apto. Na verdade, seu vasto conhecimento é muitas vezes a única solução para situações desesperadoras.",
    habilidades: {
      10: {"Conhecimento Prático": "Você pode se lembrar de informações úteis de suas leituras. Gaste 2 PE ao fazer um teste de perícia (exceto Luta e Pontaria) para mudar o atributo-base para Int (Se possuir Conhecimento Aplicado, reduz o custo em -1 PE)."},
      40: {"Leitor Contumaz": "O dado de bônus ganho pela ação de interlúdio 'ler' aumenta para 1d8 e pode ser aplicado em qualquer perícia. Ao usá-lo, pode gastar 2 PE para aumentar em +1 dado (2d8)."},
      65: {"Rato de Biblioteca": "Em ambientes com muitos livros, gaste alguns minutos (ou 1 rodada em investigação) para receber os benefícios da ação de interlúdio 'ler' ou 'revisar caso'. Uma vez por cena."},
      99: {"A Força do Saber": "Seu Intelecto aumenta em +1 e você soma este valor em seu total de PE. Além disso, escolha uma perícia qualquer: o atributo-base dela passa a ser Intelecto permanentemente."},
    },
  ),

  'perseverante': DadosTrilha(
    id: 'perseverante',
    nome: 'Perseverante',
    classe: 'especialista',
    descricao: "Você sabe que é um sobrevivente. Possui o espírito necessário para perseverar onde todos os outros caíram. Seria o último a sair vivo no final do filme de terror.",
    habilidades: {
      10: {"Soluções Improvisadas": "Quando as coisas dão errado, você pensa em soluções inusitadas. Gaste 2 PE para rolar novamente 1 dos dados de um teste recém-realizado (apenas uma vez) e fique com o melhor resultado."},
      40: {"Fuga Obstinada": "Recebe +1d20 em testes para fugir de um inimigo. Em cenas de perseguição, se for a presa, pode acumular até 4 falhas antes de ser pego."},
      65: {"Determinação Inquestionável": "Uma vez por cena, gaste 5 PE e uma ação padrão para remover uma condição de medo, mental ou de paralisia de si mesmo."},
      99: {"Só Mais um Passo...": "Uma vez por rodada, quando sofre dano que reduziria seus PV a 0, você pode gastar 5 PE para, em vez disso, ficar com 1 PV. (Não funciona contra dano massivo)."},
    },
  ),

  'muambeiro': DadosTrilha(
    id: 'muambeiro',
    nome: 'Muambeiro',
    classe: 'especialista',
    descricao: "Você sempre foi bom em lidar com equipamentos e produzir os itens certos em qualquer ocasião.",
    habilidades: {
      10: {"Mascate": "Recebe treino em Profissão (armeiro, engenheiro ou químico). Capacidade de carga +5. Fabricar item improvisado tem DT reduzida em -10 (em vez de -5)."},
      40: {"Fabricação Própria": "Leva metade do tempo para fabricar itens mundanos (2 munições/consumíveis por ação de manutenção, ou apenas 1 ação para armas e proteções). Não afeta itens paranormais."},
      65: {"Laboratório de Campo": "Recebe treino (ou +5 se já treinado) na Profissão escolhida no NEX 10%. Permite usar fabricação em campo para itens paranormais (exige 3 ações de interlúdio não consecutivas)."},
      99: {"Achado Conveniente": "Gaste uma ação completa e 5 PE para 'produzir' um item de até Categoria III (exceto paranormais) do nada. O item funciona até o fim da cena, e depois quebra permanentemente."},
    },
  ),

  'atirador_de_elite': DadosTrilha(
    id: 'atirador_de_elite',
    nome: 'Atirador de Elite',
    classe: 'especialista',
    descricao: "Um tiro, uma morte. Você é perito em neutralizar ameaças de longe, tratando sua arma como uma ferramenta de precisão.",
    habilidades: {
      10: {"Mira de Elite": "Recebe proficiência com armas de fogo de balas longas e soma seu Intelecto em rolagens de dano com elas."},
      40: {"Disparo Letal": "Quando faz a ação mirar, pode gastar 1 PE para aumentar em +2 a margem de ameaça do próximo ataque até o final do seu próximo turno."},
      65: {"Disparo Impactante": "Ao atacar com arma de fogo, gaste 2 PE e, em vez de dano, realize uma manobra (derrubar, desarmar, empurrar ou quebrar) a distância."},
      99: {"Atirar para Matar": "Ao fazer um acerto crítico com arma de fogo, você causa dano máximo automaticamente, sem precisar rolar os dados."},
    },
  ),

  'infiltrador': DadosTrilha(
    id: 'infiltrador',
    nome: 'Infiltrador',
    classe: 'especialista',
    descricao: "Perito em infiltração, neutraliza alvos desprevenidos sem causar alarde através de acrobacia e técnica.",
    habilidades: {
      10: {"Ataque Furtivo": "Uma vez por rodada, contra alvo desprevenido, em alcance curto ou flanqueado, gaste 1 PE para causar +1d6 de dano. (Aumenta para +2d6 em 40%, +3d6 em 65%, +4d6 em 99%)."},
      40: {"Gatuno": "Recebe +5 em Atletismo e Crime. Pode se mover com deslocamento normal enquanto furtivo sem sofrer penalidades."},
      65: {"Assassinar": "Gaste ação de movimento e 3 PE para analisar um alvo. O próximo Ataque Furtivo nele dobra os dados extras. Se sofrer dano, o alvo fica inconsciente/morrendo (Fortitude DT Agi evita)."},
      99: {"Sombra Fugaz": "Ao testar Furtividade após atacar ou fazer ação chamativa, gaste 3 PE para ignorar a penalidade de -3d20."},
    },
  ),

  'medico_de_campo': DadosTrilha(
    id: 'medico_de_campo',
    nome: 'Médico de Campo',
    classe: 'especialista',
    descricao: "Treinado em emergências no campo de batalha. (Requer treino em Medicina e Kit de Medicina para usar os poderes).",
    habilidades: {
      10: {"Paramédico": "Ação padrão e 2 PE para curar 2d10 PV de si ou de um aliado adjacente. (Pode curar +1d10 em 40%, 65% e 99% pagando +1 PE por dado)."},
      40: {"Equipe de Trauma": "Ação padrão e 2 PE para remover uma condição negativa (exceto morrendo) de um aliado adjacente."},
      65: {"Resgate": "Uma vez por rodada, aproxime-se de aliado machucado/morrendo como ação livre. Curá-lo dá +5 de Defesa a ambos até o próximo turno. Aliados carregados ocupam metade do espaço."},
      99: {"Reanimação": "Uma vez por cena, gaste ação completa e 10 PE para trazer de volta à vida alguém que morreu na mesma cena (exceto dano massivo)."},
    },
  ),

  'negociador': DadosTrilha(
    id: 'negociador',
    nome: 'Negociador',
    classe: 'especialista',
    descricao: "Diplomata habilidoso capaz de avaliar situações e tirar o grupo de apuros que nem a mais poderosa das armas poderia resolver.",
    habilidades: {
      10: {"Eloquência": "Ação completa e 1 PE por alvo curto. Teste social vs Vontade. Se vencer, alvos ficam fascinados enquanto se concentrar. Em combate, alvos ganham +5 de resistência e testes extras por rodada."},
      40: {"Discurso Motivador": "Ação padrão e 4 PE. Aliados em alcance curto ganham +1d20 em testes de perícia na cena. (Em NEX 65%, gaste 8 PE para +2d20)."},
      65: {"Eu Conheço um Cara": "Uma vez por missão, peça um favor narrativo gigante (re-equipar grupo, abrigo, resgate). Mestre aprova a viabilidade."},
      99: {"Truque de Mestre": "Gaste 5 PE para copiar qualquer habilidade que tenha visto um aliado usar na cena (ignorando os pré-requisitos, mas pagando custos de ação/PE)."},
    },
  ),

  'tecnico': DadosTrilha(
    id: 'tecnico',
    nome: 'Técnico',
    classe: 'especialista',
    descricao: "Manutenção, reparo e improvisação extrema de equipamentos e ferramentas.",
    habilidades: {
      10: {"Inventário Otimizado": "Soma Intelecto à Força para calcular capacidade de carga de espaços do inventário."},
      40: {"Remendão": "Ação completa e 1 PE remove a condição 'quebrado' de um item. Qualquer equipamento geral tem a categoria reduzida em I para você."},
      65: {"Improvisar": "Crie itens gerais do nada. Ação completa e 2 PE (+2 PE por categoria do item). Gera versão funcional que se desfaz no fim da cena."},
      99: {"Preparado para Tudo": "Gaste ação de movimento e 3 PE por categoria do item (exceto armas) para revelar que você já o tinha na bolsa desde o começo!"},
    },
  ),

  // Trilhas de Ocultista
  'conduite': DadosTrilha(
    id: 'conduite',
    nome: 'Conduíte',
    classe: 'ocultista',
    descricao: "Domina os aspectos fundamentais da conjuração e é capaz de aumentar alcance e velocidade, interferindo com outros ocultistas.",
    habilidades: {
      10: {"Ampliar Ritual": "Gaste +2 PE ao conjurar um ritual para aumentar o alcance em um passo (Curto > Médio > Longo > Extremo) ou dobrar a área de efeito."},
      40: {"Acelerar Ritual": "Uma vez por rodada, aumente o custo de um ritual em +4 PE para conjurá-lo como ação livre."},
      65: {"Anular Ritual": "Ao ser alvo de ritual, gaste PE igual ao custo do ritual inimigo e faça Ocultismo vs Conjurador. Se vencer, anula o ritual e seus efeitos."},
      99: {"Canalizar o Medo": "Aprende o ritual 'Canalizar o Medo'."},
    },
  ),

  'flagelador': DadosTrilha(
    id: 'flagelador',
    nome: 'Flagelador',
    classe: 'ocultista',
    descricao: "A dor é um catalisador. Você aprendeu a transformá-la em poder para seus rituais e usar a agonia de seus inimigos a seu favor.",
    habilidades: {
      10: {"Poder do Flagelo": "Ao conjurar rituais, você pode gastar 2 Pontos de Vida (PV) para pagar cada 1 PE do custo. PVs gastos assim não curam com rituais, só descansando."},
      40: {"Abraçar a Dor": "Ao sofrer dano não paranormal, gaste uma reação e 2 PE para reduzir esse dano à metade."},
      65: {"Absorver Agonia": "Quando reduz inimigos a 0 PV com rituais, ganha PE temporário igual ao círculo do ritual."},
      99: {"Medo Tangível": "Aprende o ritual 'Medo Tangível'."},
    },
  ),

  'graduado': DadosTrilha(
    id: 'graduado',
    nome: 'Graduado',
    classe: 'ocultista',
    descricao: "Foco total nos estudos, conhecendo mais rituais que os outros e os tornando quase impossíveis de serem resistidos.",
    habilidades: {
      10: {"Saber Ampliado": "Aprende um ritual extra de 1º Círculo. Sempre que desbloquear um novo Círculo, aprende um ritual bônus dele (não contam no limite de rituais)."},
      40: {"Grimório Ritualístico": "Cria um grimório que armazena (Intelecto) rituais extras de 1º ou 2º círculos (expandível). Exige 1 ação completa empunhando o livro para conjurá-los. Ocupa 1 espaço."},
      65: {"Rituais Eficientes": "A DT para os inimigos resistirem aos seus rituais aumenta em +5."},
      99: {"Conhecendo o Medo": "Aprende o ritual 'Conhecendo o Medo'."},
    },
  ),

  'intuitivo': DadosTrilha(
    id: 'intuitivo',
    nome: 'Intuitivo',
    classe: 'ocultista',
    descricao: "Assim como combatentes treinam o corpo, você blindou a mente contra o Outro Lado, expandindo seus próprios limites paranormais.",
    habilidades: {
      10: {"Mente Sã": "Recebe +5 em testes de resistência contra todos os efeitos paranormais."},
      40: {"Presença Poderosa": "Adiciona o valor de Presença ao Limite de PE/turno (usável APENAS para conjurar rituais, não afeta a DT deles)."},
      65: {"Inabalável": "Recebe RD Mental e Paranormal 10. Se passar em um teste de Vontade que reduziria dano à metade, não sofre dano algum."},
      99: {"Presença do Medo": "Aprende o ritual 'Presença do Medo'."},
    },
  ),

  'lamina_paranormal': DadosTrilha(
    id: 'lamina_paranormal',
    nome: 'Lâmina Paranormal',
    classe: 'ocultista',
    descricao: "Prefere usar o paranormal como arma. Dominou técnicas de combate mesclando lâminas e feitiçaria.",
    habilidades: {
      10: {"Lâmina Maldita": "Aprende 'Amaldiçoar Arma' (Pode gastar +1 PE para conjurar como Ação de Movimento). Usa Ocultismo no lugar de Luta/Pontaria ao atacar com a arma amaldiçoada."},
      40: {"Gladiador Paranormal": "Acertar um ataque corpo a corpo dá 2 PE temporários (até o limite máximo do seu Limite de PE/turno). Somem no fim da cena."},
      65: {"Conjuração Marcial": "Uma vez por rodada, ao conjurar um ritual de ação padrão, gaste 2 PE para dar um ataque corpo a corpo como ação livre."},
      99: {"Lâmina do Medo": "Aprende o ritual 'Lâmina do Medo'."},
    },
  ),

  'exorcista': DadosTrilha(
    id: 'exorcista',
    nome: 'Exorcista',
    classe: 'ocultista',
    descricao: "Com sua fé como escudo (independente da religião), você enfrenta a escuridão e resgata almas atormentadas.",
    habilidades: {
      10: {"Revelação do Mal": "Treino ou +2 em Religião. Pode usar Religião no lugar de Investigação, Percepção e Ocultismo para notar e identificar traços paranormais."},
      40: {"Poder da Fé": "Se torna Veterano (+10) ou ganha +1d20 em Religião. Ao falhar em um teste de resistência, gaste 2 PE para rolar de novo usando Religião (aceitando o novo resultado)."},
      65: {"Parareligiosidade": "Gaste +2 PE em qualquer ritual para adicionar um efeito extra de Catalisador Ritualístico a sua escolha."},
      99: {"Chagas da Resistência": "Quando sua Sanidade chegar a 0, gaste 10 PV para ficar com 1 de Sanidade e não enlouquecer."},
    },
  ),

  'possuido': DadosTrilha(
    id: 'possuido',
    nome: 'Possuído',
    classe: 'ocultista',
    descricao: "O paranormal escolheu você como hospedeiro. Você luta pela Realidade enquanto a entidade aflora de dentro para fora.",
    habilidades: {
      10: {"Poder Não Desejado": "Toda vez que ganhar Poder de Ocultista, é OBRIGADO a pegar 'Transcender'. Recebe Pontos de Possessão (PP) iguais a 3 + (2x total de Transcender). Ação livre na rodada: 1 PP cura 10 PV ou 2 PE. Recupera 1 PP ao dormir."},
      40: {"As Sombras Dentro de Mim": "Recupera 2 PP ao dormir. Gaste 2 PE para dar o controle à entidade: ganha +1d20 em Acrobacia, Atletismo e Furtividade por uma rodada e oculta visualmente seus rastros de Furtividade."},
      65: {"Ele Me Ensina": "A voz se manifesta: Escolha entre Transcender de novo OU pegar o primeiro poder de QUALQUER outra trilha de Ocultista."},
      99: {"Tornamo-nos Um": "Ganha o presente supremo de acordo com sua afinidade. SANGUE: Gasta 6 PE p/ curar 50 PV e as perícias de FOR/VIG vão pra +35. MORTE: 6 PE p/ agir duas vezes na rodada. CONHECIMENTO: 6 PE p/ ganhar um poder aleatório. ENERGIA: 6 PE p/ teleporte médio."},
    },
  ),

  'parapsicologo': DadosTrilha(
    id: 'parapsicologo',
    nome: 'Parapsicólogo',
    classe: 'ocultista',
    descricao: "Rejeitado pela academia cética. Estuda a mente humana e prova que o paranormal pode sanar os traumas que ele próprio cria. (Requer treino em Profissão: Psicólogo).",
    habilidades: {
      10: {"Terapia": "Usa Profissão (Psicólogo) como Diplomacia. Ao falhar em resistência mental, gaste 2 PE para usar Psicologia no lugar da defesa. Se já a possuía, reduz em -1 PE e ganha +2 de bônus."},
      40: {"Palavras-chave": "Quando passa no teste de Acalmar, pode gastar PE. Para cada 1 PE, o alvo recupera 1 de Sanidade perdida."},
      65: {"Reprogramação Mental": "Hipnotiza voluntários (Ação de Interlúdio + 5 PE). O alvo ganha temporariamente 1 poder geral, de classe ou de trilha até o próximo descanso, acreditando que sempre soube usá-lo."},
      99: {"A Sanidade Está Lá Fora": "Gaste ação de movimento e 5 PE para curar TODAS as condições mentais/medo de um aliado adjacente de uma só vez."},
    },
  ),
};