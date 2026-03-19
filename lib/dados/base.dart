class DadosClasse {
  final int pvBase, peBase, sanBase, pvPorNivel, pePorNivel, sanPorNivel;
  DadosClasse(
    this.pvBase,
    this.peBase,
    this.sanBase,
    this.pvPorNivel,
    this.pePorNivel,
    this.sanPorNivel,
  );
}

class DadosOrigem {
  final String nome, nomeHabilidade, descHabilidade;
  final List<String> pericias;
  DadosOrigem(
    this.nome,
    this.pericias,
    this.nomeHabilidade,
    this.descHabilidade,
  );
}

final Map<String, DadosClasse> dadosClasses = {
  'combatente': DadosClasse(20, 2, 12, 4, 2, 3),
  'especialista': DadosClasse(16, 3, 16, 3, 3, 4),
  'ocultista': DadosClasse(12, 4, 20, 2, 4, 5),
};

final Map<String, DadosOrigem> dadosOrigens = {
  'academico': DadosOrigem(
    "Acadêmico",
    ["ciencias", "investigacao"],
    "Saber é Poder",
    "Quando faz um teste de Intelecto, você pode gastar 2 PE para receber +5 nesse teste.",
  ),
  'agente_de_saude': DadosOrigem(
    "Agente de Saúde",
    ["intuicao", "medicina"],
    "Médico de Campo",
    "Sempre que você curar um personagem, você adiciona seu Intelecto no total de PV curados.",
  ),
  'amigo_dos_animais': DadosOrigem(
    "Amigo dos Animais",
    ["adestramento", "percepcao"],
    "Companheiro Animal",
    "Você consegue entender as intenções e sentimentos de animais e pode usar Adestramento para mudar a atitude deles. Além disso, possui um animal aliado que fornece +2 em uma perícia à sua escolha. Em NEX 35% ele também passa a fornecer o bônus de um tipo de aliado escolhido e em NEX 70% fornece a habilidade desse aliado. Se ele morrer, você perde 10 pontos de Sanidade permanentemente e fica perturbado até o fim da cena.",
  ),
  'amnesico': DadosOrigem(
    "Amnésico",
    ["vontade", "intuicao"],
    "Vislumbres do Passado",
    "Uma vez por cena, você pode gastar 2 PE para fazer um teste de Vontade (DT 15) e, se passar, fazer uma pergunta de 'sim' ou 'não' ao mestre sobre seu passado ou o Paranormal.",
  ),
  'artista': DadosOrigem(
    "Artista",
    ["artes", "enganacao"],
    "Magnum Opus",
    "Uma vez por missão, pode determinar que uma pessoa envolvida em uma cena de interação o reconheça. Você recebe +5 em testes de Presença e de perícias baseadas em Presença contra aquela pessoa. A critério do mestre, pode receber esse bônus em outras situações nas quais seria reconhecido.",
  ),
  'astronauta': DadosOrigem(
    "Astronauta",
    ["ciencias", "fortitude"],
    "Acostumado ao Extremo",
    "Quando sofre dano de fogo, de frio ou mental, você pode gastar 1 PE para reduzir esse dano em 5. Cada uso adicional na mesma cena aumenta o custo em +1 PE.",
  ),
  'atleta': DadosOrigem(
    "Atleta",
    ["acrobacia", "atletismo"],
    "110%",
    "Quando faz um teste de perícia usando Força ou Agilidade (exceto Luta e Pontaria) você pode gastar 2 PE para receber +5 nesse teste.",
  ),
  'chef': DadosOrigem(
    "Chef",
    ["fortitude", "profissao"],
    "Ingrediente Secreto",
    "Em cenas de interlúdio, você pode fazer a ação alimentar-se para cozinhar um prato especial. Você, e todos os membros do grupo que fizeram a ação alimentar-se, recebem o benefício de dois pratos (caso o mesmo benefício seja escolhido duas vezes, seus efeitos se acumulam).",
  ),
  'chef_do_outro_lado': DadosOrigem(
    "Chef do Outro Lado",
    ["ocultismo", "profissao"],
    "Fome do Outro Lado",
    "Você pode usar partes de criaturas do Outro Lado como ingredientes culinários para preparar pratos especiais que concedem RD 10 contra o tipo de dano do elemento da criatura até o fim da próxima cena. Se falhar no preparo, o prato causa vulnerabilidade. Cada refeição consumida faz você perder 1 ponto permanente de Sanidade.",
  ),
  'colegial': DadosOrigem(
    "Colegial",
    ["atualidades", "tecnologia"],
    "Poder da Amizade",
    "Escolha um personagem como melhor amigo. Se estiver em alcance médio dele e puder trocar olhares, recebe +2 em todos os testes de perícia. Se ele morrer, seu total de PE é reduzido em −1 para cada 5% de NEX até o fim da missão.",
  ),
  'cosplayer': DadosOrigem(
    "Cosplayer",
    ["artes", "vontade"],
    "Não É Fantasia, É Cosplay!",
    "Você pode fazer testes de disfarce usando Artes em vez de Enganação. Além disso, ao fazer um teste de perícia usando um cosplay relacionado à ação, recebe +2.",
  ),
  'criminoso': DadosOrigem(
    "Criminoso",
    ["crime", "furtividade"],
    "O Crime Compensa",
    "No final de uma missão, escolha um item encontrado na missão. Em sua próxima missão, você pode incluir esse item em seu inventário sem que ele conte em seu limite de itens por patente.",
  ),
  'cultista_arrependido': DadosOrigem(
    "Cultista Arrependido",
    ["ocultismo", "religiao"],
    "Traços do Outro Lado",
    "Você possui um poder paranormal à sua escolha. Porém, começa o jogo com metade da Sanidade normal para sua classe.",
  ),
  'desgarrado': DadosOrigem(
    "Desgarrado",
    ["fortitude", "sobrevivencia"],
    "Calejado",
    "Você recebe +1 PV para cada 5% de NEX.",
  ),
  'diplomata': DadosOrigem(
    "Diplomata",
    ["atualidades", "diplomacia"],
    "Conexões",
    "Você recebe +2 em Diplomacia. Além disso, se puder contatar um NPC que possa ajudar, pode gastar 10 minutos e 2 PE para substituir um teste de perícia relacionada ao conhecimento desse NPC por um teste de Diplomacia.",
  ),
  'engenheiro': DadosOrigem(
    "Engenheiro",
    ["profissao", "tecnologia"],
    "Ferramenta Favorita",
    "Um item a sua escolha (exceto armas) conta como uma categoria abaixo (por exemplo, um item de categoria II conta como categoria I para você).",
  ),
  'executivo': DadosOrigem(
    "Executivo",
    ["diplomacia", "profissao"],
    "Processo Otimizado",
    "Sempre que faz um teste de perícia durante um teste estendido, ou uma ação para revisar documentos (físicos ou digitais), pode pagar 2 PE para receber +5 nesse teste.",
  ),
  'explorador': DadosOrigem(
    "Explorador",
    ["fortitude", "sobrevivencia"],
    "Manual do Sobrevivente",
    "Ao fazer um teste para resistir a armadilhas, clima, doenças, fome, sede, fumaça, sono, sufocamento ou veneno, você pode gastar 2 PE para receber +5 nesse teste. Em cenas de interlúdio, você considera condições precárias de sono como normais.",
  ),
  'experimento': DadosOrigem(
    "Experimento",
    ["atletismo", "fortitude"],
    "Mutação",
    "Você recebe resistência a dano 2 e +2 em uma perícia baseada em Força, Agilidade ou Vigor à sua escolha, mas sofre −1d20 em Diplomacia.",
  ),
  'fanatico_por_criaturas': DadosOrigem(
    "Fanático por Criaturas",
    ["investigacao", "ocultismo"],
    "Conhecimento Oculto",
    "Você pode usar Ocultismo para identificar criaturas a partir de pistas ou registros. Se passar no teste, descobre suas características e recebe +2 em todos os testes contra a criatura até o fim da missão.",
  ),
  'fotografo': DadosOrigem(
    "Fotógrafo",
    ["artes", "percepcao"],
    "Através da Lente",
    "Quando faz um teste de Investigação ou Percepção usando uma câmera ou analisando fotos, pode gastar 2 PE para receber +5 no teste.",
  ),
  'investigador': DadosOrigem(
    "Investigador",
    ["investigacao", "percepcao"],
    "Faro para Pistas",
    "Uma vez por cena, quando fizer um teste para procurar pistas, você pode gastar 1 PE para receber +5 nesse teste.",
  ),
  'inventor_paranormal': DadosOrigem(
    "Inventor Paranormal",
    ["profissao", "vontade"],
    "Invenção Paranormal",
    "Você possui um invento paranormal que permite executar o efeito de um ritual de 1º círculo escolhido. Para ativá-lo, faz um teste de Profissão (engenheiro) com DT 15 +5 para cada ativação na missão. Se falhar, o item enguiça até ser reparado durante um interlúdio.",
  ),
  'jovem_mistico': DadosOrigem(
    "Jovem Místico",
    ["ocultismo", "religiao"],
    "A Culpa é das Estrelas",
    "Escolha um número da sorte de 1 a 6. No início de cada cena, você pode gastar 1 PE e rolar 1d6; se cair no número escolhido recebe +2 em testes de perícia até o fim da cena.",
  ),
  'legista_turno_noite': DadosOrigem(
    "Legista do Turno da Noite",
    ["ciencias", "medicina"],
    "Luto Habitual",
    "Você sofre metade do dano mental ao presenciar cenas relacionadas à rotina de um legista. Além disso, ao fazer testes de Medicina para primeiros socorros ou necropsia, pode gastar 2 PE para receber +5.",
  ),
  'lutador': DadosOrigem(
    "Lutador",
    ["luta", "reflexos"],
    "Mão Pesada",
    "Você recebe +2 em rolagens de dano com ataques corpo a corpo.",
  ),
  'magnata': DadosOrigem(
    "Magnata",
    ["diplomacia", "pilotagem"],
    "Patrocinador da Ordem",
    "Seu limite de crédito é sempre considerado um acima do atual.",
  ),
  'mateiro': DadosOrigem(
    "Mateiro",
    ["percepcao", "sobrevivencia"],
    "Mapa Celeste",
    "Desde que possa ver o céu, você sempre sabe as direções cardeais e consegue voltar a lugares já visitados sem se perder. Ao fazer um teste de Sobrevivência, pode gastar 2 PE para rolar novamente e escolher o melhor resultado.",
  ),
  'mendigo': DadosOrigem(
    "Mendigo",
    ["sobrevivencia", "diplomacia"],
    "Pedir Esmola",
    "A critério do mestre, sempre que tiver acesso a uma rua, você pode gastar 2 PE para pedir esmola e, caso tenha sucesso (DT 20), ganha um item aleatório de categoria I.",
  ),
  'mergulhador': DadosOrigem(
    "Mergulhador",
    ["atletismo", "fortitude"],
    "Fôlego de Nadador",
    "Você recebe +5 PV, pode prender a respiração por um número de rodadas igual ao dobro do seu Vigor e, quando passa em um teste de Atletismo para natação, move-se com deslocamento normal.",
  ),
  'mercenario': DadosOrigem(
    "Mercenário",
    ["iniciativa", "intimidacao"],
    "Posição de Combate",
    "No primeiro turno de cada cena de ação, você pode gastar 2 PE para receber uma ação de movimento adicional.",
  ),
  'militar': DadosOrigem(
    "Militar",
    ["pontaria", "tatica"],
    "Para Bellum",
    "Você recebe +2 em rolagens de dano com armas de fogo.",
  ),
  'motorista': DadosOrigem(
    "Motorista",
    ["pilotagem", "reflexos"],
    "Mãos no Volante",
    "Você não sofre penalidades em ataques por estar em um veículo em movimento e, ao fazer testes de Pilotagem ou resistência enquanto dirige, pode gastar 2 PE para receber +5.",
  ),
  'nerd_entusiasta': DadosOrigem(
    "Nerd Entusiasta",
    ["ciencias", "tecnologia"],
    "O Inteligentão",
    "O bônus recebido ao utilizar a ação de interlúdio ler aumenta em +1 dado.",
  ),
  'operario': DadosOrigem(
    "Operário",
    ["fortitude", "profissao"],
    "Ferramenta de Trabalho",
    "Escolha uma arma simples ou tática que, a critério do mestre, poderia ser usada como ferramenta em sua profissão (como uma marreta para um pedreiro). Você sabe usar a arma escolhida e recebe +1 em testes de ataque, rolagens de dano e margem de ameaça com ela.",
  ),
  'policial': DadosOrigem(
    "Policial",
    ["percepcao", "pontaria"],
    "Patrulha",
    "Você recebe +2 em Defesa.",
  ),
  'profetizado': DadosOrigem(
    "Profetizado",
    [
      "vontade",
      "pericia_extra",
    ], // Como "pericia_extra" é genérica, ela servirá como marcação.
    "Luta ou Fuga",
    "Você recebe +2 em Vontade. Quando surge uma referência à sua premonição de morte, você recebe +2 PE temporários até o fim da cena.",
  ),
  'psicologo': DadosOrigem(
    "Psicólogo",
    ["intuicao", "profissao"],
    "Terapia",
    "Você pode usar Profissão (psicólogo) como Diplomacia. Uma vez por rodada, quando você ou um aliado em alcance curto falha em um teste contra dano mental, pode gastar 2 PE para fazer um teste de Profissão (psicólogo) e usar o resultado no lugar do teste falho.",
  ),
  'religioso': DadosOrigem(
    "Religioso",
    ["religiao", "vontade"],
    "Acalentar",
    "Você recebe +5 em testes de Religião para acalmar. Além disso, quando acalma uma pessoa, ela recebe um número de pontos de Sanidade igual a 1d6 + a sua Presença.",
  ),
  'reporter_investigativo': DadosOrigem(
    "Repórter Investigativo",
    ["atualidades", "investigacao"],
    "Encontrar a Verdade",
    "Você pode usar Investigação no lugar de Diplomacia para persuadir e mudar atitudes. Além disso, ao fazer um teste de Investigação, pode gastar 2 PE para receber +5.",
  ),
  'servidor_publico': DadosOrigem(
    "Servidor Público",
    ["intuicao", "vontade"],
    "Espírito Cívico",
    "Sempre que faz um teste para ajudar, você pode gastar 1 PE para aumentar o bônus concedido em +2.",
  ),
  'teorico_da_conspiracao': DadosOrigem(
    "Teórico da Conspiração",
    ["investigacao", "ocultismo"],
    "Eu Já Sabia",
    "Você não se abala tanto com entidades ou anomalias. Afinal, sempre soube que isso tudo existia. Você recebe resistência a dano mental igual ao seu Intelecto.",
  ),
  'ti': DadosOrigem(
    "T.I.",
    ["investigacao", "tecnologia"],
    "Motor de Busca",
    "A critério do mestre, sempre que tiver acesso a internet, você pode gastar 2 PE para substituir um teste de perícia qualquer por um teste de Tecnologia.",
  ),
  'trabalhador_rural': DadosOrigem(
    "Trabalhador Rural",
    ["adestramento", "sobrevivencia"],
    "Desbravador",
    "Quando faz um teste de Adestramento ou Sobrevivência, você pode gastar 2 PE para receber +5 nesse teste. Além disso, você não sofre penalidade em deslocamento por terreno difícil.",
  ),
  'trambiqueiro': DadosOrigem(
    "Trambiqueiro",
    ["crime", "enganacao"],
    "Impostor",
    "Uma vez por cena, você pode gastar 2 PE para substituir um teste de perícia qualquer por um teste de Enganação.",
  ),
  'universitario': DadosOrigem(
    "Universitário",
    ["atualidades", "investigacao"],
    "Dedicação",
    "Você recebe +1 PE, e mais 1 PE adicional a cada NEX ímpar (15%, 25%…). Além disso, seu limite de PE por turno aumenta em 1.",
  ),
  'vitima': DadosOrigem(
    "Vítima",
    ["reflexos", "vontade"],
    "Cicatrizes Psicológicas",
    "Você recebe +1 de Sanidade para cada 5% de NEX.",
  ),
  'body_builder': DadosOrigem(
    "Body Builder",
    ["atletismo", "fortitude"],
    "Saindo da Jaula",
    "O éxtase de ir além dos limites do seu corpo é inebriante. Quando faz um teste usando Força ou Vigor (exceto Luta) você pode gastar 2 PE para receber +5 nesse teste.",
  ),
  'personal_trainer': DadosOrigem(
    "Personal Trainer",
    ["atletismo", "ciencias"],
    "Todo Mundo Pagando 10",
    "Você pode gastar uma ação de movimento e 2 PE para motivar sua equipe. Enquanto você estiver consciente, você e seus aliados em alcance curto recebem +2 em testes de perícia que usam Força ou Agilidade (exceto Luta e Pontaria) até o fim da cena.",
  ),
  'blaster': DadosOrigem(
    "Blaster",
    ["ciencias", "profissao"],
    "Explosão Solidária",
    "Seus explosivos que provocam dano causam +2d6 pontos de dano. Além disso, você pode gastar 2 PE e uma ação de interlúdio para melhorar um explosivo, aumentando a CD para resistir a ele em +5. Só é possível melhorar o mesmo explosivo uma vez.",
  ),
  'duble': DadosOrigem(
    "Dublê",
    ["pilotagem", "reflexos"],
    "Destemido",
    "Quando faz um teste de perícia para o qual uma falha terá como consequência direta dano ou uma condição negativa, você recebe +5 nesse teste.",
  ),
  'ginasta': DadosOrigem(
    "Ginasta",
    ["acrobacia", "reflexos"],
    "Mobilidade Acrobática",
    "Você recebe +2 na Defesa e seu deslocamento aumenta em +3m.",
  ),
  'revoltado': DadosOrigem(
    "Revoltado",
    ["furtividade", "vontade"],
    "Antes Só...",
    "Você recebe +1 na Defesa, em testes de perícias e em seu limite de PE por turno se estiver sem nenhum aliado em alcance curto.",
  ),
  'gauderio_abutre': DadosOrigem(
    "Gaudério Abutre",
    ["luta", "pilotagem"],
    "Fraternidade Gaudéria",
    "Uma vez por rodada, quando um aliado adjacente é alvo de um ataque ou efeito, você pode gastar 1 PE para trocar de lugar com este aliado e se tornar o alvo deste ataque ou efeito. Se fizer isso, em seu próximo turno você recebe +2 em testes de ataque contra o agressor.",
  ),
};

// BASE DE PERÍCIAS PARA A FICHA ---
final List<Map<String, String>> periciasBase = [
  {"nome": "Acrobacia", "atributo": "AGI", "id": "acrobacia"},
  {"nome": "Adestramento", "atributo": "PRE", "id": "adestramento"},
  {"nome": "Artes", "atributo": "PRE", "id": "artes"},
  {"nome": "Atletismo", "atributo": "FOR", "id": "atletismo"},
  {"nome": "Atualidades", "atributo": "INT", "id": "atualidades"},
  {"nome": "Ciências", "atributo": "INT", "id": "ciencias"},
  {"nome": "Crime", "atributo": "AGI", "id": "crime"},
  {"nome": "Diplomacia", "atributo": "PRE", "id": "diplomacia"},
  {"nome": "Enganação", "atributo": "PRE", "id": "enganacao"},
  {"nome": "Fortitude", "atributo": "VIG", "id": "fortitude"},
  {"nome": "Furtividade", "atributo": "AGI", "id": "furtividade"},
  {"nome": "Iniciativa", "atributo": "AGI", "id": "iniciativa"},
  {"nome": "Intimidação", "atributo": "PRE", "id": "intimidacao"},
  {"nome": "Intuição", "atributo": "PRE", "id": "intuicao"},
  {"nome": "Investigação", "atributo": "INT", "id": "investigacao"},
  {"nome": "Luta", "atributo": "FOR", "id": "luta"},
  {"nome": "Medicina", "atributo": "INT", "id": "medicina"},
  {"nome": "Ocultismo", "atributo": "INT", "id": "ocultismo"},
  {"nome": "Percepção", "atributo": "PRE", "id": "percepcao"},
  {"nome": "Pilotagem", "atributo": "AGI", "id": "pilotagem"},
  {"nome": "Pontaria", "atributo": "AGI", "id": "pontaria"},
  {"nome": "Profissão", "atributo": "INT", "id": "profissao"},
  {"nome": "Reflexos", "atributo": "AGI", "id": "reflexos"},
  {"nome": "Religião", "atributo": "PRE", "id": "religiao"},
  {"nome": "Sobrevivência", "atributo": "INT", "id": "sobrevivencia"},
  {"nome": "Tática", "atributo": "INT", "id": "tatica"},
  {"nome": "Tecnologia", "atributo": "INT", "id": "tecnologia"},
  {"nome": "Vontade", "atributo": "PRE", "id": "vontade"},
];