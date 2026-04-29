import '../modelos/agente_dados.dart'; // Importa a classe Poder que criamos no agente_dados.dart

// PODERES GERAIS

final List<Poder> catalogoPoderesGerais = [
  Poder(
    nome: "Acrobático",
    tipo: "Geral",
    descricao:
        "Você possui um talento natural para piruetas, cambalhotas e outras acrobacias complexas. Você recebe treinamento em Acrobacia ou, se já for treinado nesta perícia, recebe +2 nela. Além disso, terreno difícil não reduz seu deslocamento nem o impede de realizar investidas.",
    preRequisitos: "Agi 2",
  ),
  Poder(
    nome: "Artista Marcial",
    tipo: "Geral",
    descricao:
        "Seus ataques desarmados causam 1d6 pontos de dano, podem causar dano letal e se tornam ágeis. Em NEX 35%, o dano aumenta para 1d8 e, em NEX 70%, para 1d10.",
  ),
  Poder(
    nome: "Ás do Volante",
    tipo: "Geral",
    descricao:
        "Você é um apaixonado por velocidade, e tem a coragem (ou falta de juízo) necessária para executar qualquer manobra. Você recebe treinamento em Pilotagem ou, se já for treinado nesta perícia, recebe +2 nela. Além disso, uma vez por rodada, quando um veículo que você está pilotando sofre dano, você pode fazer um teste de Pilotagem (DT igual ao resultado do teste de ataque ou à DT do efeito que causou o dano). Se passar, evita esse dano.",
    preRequisitos: "Agi 2",
  ),
  Poder(
    nome: "Atlético",
    tipo: "Geral",
    descricao:
        "Você possui um corpo atlético, resultado de uma fortuita disposição genética ou árduo treinamento. Você recebe treinamento em Atletismo ou, se já for treinado nesta perícia, recebe +2 nela. Além disso, recebe +3m em seu deslocamento.",
    preRequisitos: "For 2",
  ),
  Poder(
    nome: "Atraente",
    tipo: "Geral",
    descricao:
        "Seja por pura beleza física ou por sua postura e atitude, você atrai olhares por onde passa. Você recebe +5 em testes de Artes, Diplomacia, Enganação, e Intimidação contra pessoas que possam se sentir fisicamente atraídas por você.",
    preRequisitos: "Pre 2",
  ),
  Poder(
    nome: "Combater com Duas Armas",
    tipo: "Geral",
    descricao:
        "Se estiver empunhando duas armas (e pelo menos uma for leve) e fizer a ação agredir, você pode fazer dois ataques, um com cada arma. Se fizer isso, sofre –1d20 em todos os testes de ataque até o seu próximo turno.",
    preRequisitos: "Agi 3, Treinado em Luta ou Pontaria",
  ),
  Poder(
    nome: "Dedos Ágeis",
    tipo: "Geral",
    descricao:
        "Você possui uma motricidade fina precisa, particularmente útil para manipular ferramentas delicadas. Você recebe treinamento em Crime ou, se já for treinado nesta perícia, recebe +2 nela. Além disso, pode arrombar com uma ação padrão, furtar com uma ação livre (apenas uma vez por rodada) e sabotar com uma ação completa.",
    preRequisitos: "Agi 2",
  ),
  Poder(
    nome: "Detector de Mentiras",
    tipo: "Geral",
    descricao:
        "Você possui uma aptidão para perceber os sutis sinais de alguém que está mentindo. Você recebe treinamento em Intuição ou, se já for treinado nesta perícia, recebe +2 nela. Além disso, outros seres sofrem uma penalidade de –10 em testes de Enganação para mentir para você.",
    preRequisitos: "Pre 2",
  ),
  Poder(
    nome: "Especialista em Emergências",
    tipo: "Geral",
    descricao:
        "Você recebeu treinamento como socorrista de emergência, e sabe como tratar um paciente em situações de urgência. Você recebe treinamento em Medicina ou, se já for treinado nesta perícia, recebe +2 nela. Além disso, pode aplicar cicatrizantes e medicamentos como uma ação de movimento e, uma vez por rodada, pode sacar um desses itens como uma ação livre.",
    preRequisitos: "Int 2",
  ),
  Poder(
    nome: "Estigmado",
    tipo: "Geral",
    descricao:
        "A adrenalina causada pela dor faz você se manter focado no que está acontecendo. Sempre que sofre dano mental de efeitos de medo, você pode converter esse dano em perda de pontos de vida (se sofre 5 pontos de dano mental de medo você pode, em vez disso, perder 5 pontos de vida).",
  ),
  Poder(
    nome: "Foco em Perícia",
    tipo: "Geral",
    descricao:
        "Você se dedicou a estudar e treinar os vários pormenores de uma área de conhecimento específica. Escolha uma perícia (exceto Luta e Pontaria). Quando faz um teste dessa perícia, você rola +1d20. Você pode escolher este poder outras vezes para perícias diferentes.",
    preRequisitos: "Treinado na perícia escolhida",
  ),
  Poder(
    nome: "Informado",
    tipo: "Geral",
    descricao:
        "Você passa bastante tempo consumindo fofocas… bem, notícias sobre o mundo ao seu redor. Você recebe treinamento em Atualidades ou, se já for treinado nesta perícia, recebe +2 nela. Além disso, pode usar Atualidades no lugar de qualquer outra perícia para testes envolvendo informações, desde que aprovado pelo mestre.",
    preRequisitos: "Int 2",
  ),
  Poder(
    nome: "Interrogador",
    tipo: "Geral",
    descricao:
        "Você sabe como usar o medo para extrair todo tipo de informação das outras pessoas. Você recebe treinamento em Intimidação ou, se já for treinado nesta perícia, recebe +2 nela. Além disso, pode fazer testes de Intimidação para coagir como uma ação padrão, mas apenas uma vez por cena contra a mesma pessoa.",
    preRequisitos: "For 2",
  ),
  Poder(
    nome: "Inventário Organizado",
    tipo: "Geral",
    descricao:
        "Você sabe como organizar sua mochila e seu equipamento de forma organizada e racional. Você soma seu Intelecto no limite de espaços que pode carregar. Para você, itens muito leves ou pequenos, que normalmente ocupam meio espaço (0,5), em vez disso ocupam 1/4 de espaço (0,25).",
    preRequisitos: "Int 2",
  ),
  Poder(
    nome: "Mentiroso Nato",
    tipo: "Geral",
    descricao:
        "Você é um cara de pau, capaz de mentir descaradamente sem que ninguém perceba. Você recebe treinamento em Enganação ou, se já for treinado nesta perícia, recebe +2 nela. Além disso, a penalidade que você sofre por mentiras muito implausíveis diminui para –1d20.",
    preRequisitos: "Pre 2",
  ),
  Poder(
    nome: "Observador",
    tipo: "Geral",
    descricao:
        "Você possui uma combinação de sentidos apurados para perceber pistas e intelecto afiado para processá-las. Você recebe treinamento em Investigação ou, se já for treinado nesta perícia, recebe +2 nela. Além disso, soma seu Intelecto em Intuição.",
    preRequisitos: "Int 2",
  ),
  Poder(
    nome: "Pai de Pet",
    tipo: "Geral",
    descricao:
        "Você adora animais, e cuida de seus pets como se fossem seus filhos. Você recebe treinamento em Adestramento ou, se já for treinado nesta perícia, recebe +2 nela. Além disso, possui um animal de estimação que o auxilia e o acompanha em suas aventuras. Em termos de jogo, é um aliado que fornece +2 em duas perícias a sua escolha (exceto Luta ou Pontaria e aprovadas pelo mestre).",
    preRequisitos: "Pre 2",
  ),
  Poder(
    nome: "Palavras de Devoção",
    tipo: "Geral",
    descricao:
        "Você combina uma fé verdadeira com o conhecimento dos ritos e tradições de sua religião. Você recebe treinamento em Religião ou, se já for treinado nesta perícia, recebe +2 nela. Além disso, uma vez por cena, pode gastar 3 PE e uma ação completa para executar uma oração para um número de pessoas até o dobro de sua Presença. Até o fim da cena, todos os participantes dessa oração recebem resistência a dano mental 5.",
    preRequisitos: "Pre 2",
    custoPE: 3,
  ),
  Poder(
    nome: "Parceiro",
    tipo: "Geral",
    descricao:
        "Em algum momento da sua vida, você conquistou uma amizade fiel e verdadeira; alguém disposto a até mesmo a se arriscar para lhe ajudar. Você possui um parceiro, uma pessoa que o acompanha e o auxilia em suas missões. Escolha os detalhes dele, como nome, aparência e personalidade. Em termos de jogo, é um aliado de um tipo à sua escolha. O parceiro obedece às suas ordens e se arrisca para ajudá-lo, mas, se for maltratado, pode parar de segui-lo. Se perder seu aliado, você precisa gastar uma folga da Ordem para receber outro.",
    preRequisitos: "Treinado em Diplomacia, NEX 30%",
  ),
  Poder(
    nome: "Pensamento Tático",
    tipo: "Geral",
    descricao:
        "Você possui uma mente voltada para análises táticas e pensamento estratégico. Você recebe treinamento em Tática ou, se já for treinado nesta perícia, recebe +2 nela. Além disso, quando você passa em um teste de Tática para analisar terreno, você e seus aliados em alcance médio recebem uma ação de movimento adicional na primeira rodada do próximo combate neste terreno (desde que ele ocorra até o fim do dia).",
    preRequisitos: "Int 2",
  ),
  Poder(
    nome: "Personalidade Esotérica",
    tipo: "Geral",
    descricao:
        "Você sempre teve uma afinidade com assuntos esotéricos. Você recebe +3 PE e recebe treinamento em Ocultismo. Se já for treinado nesta perícia, recebe +2 nela.",
    preRequisitos: "Int 2",
  ),
  Poder(
    nome: "Persuasivo",
    tipo: "Geral",
    descricao:
        "Você possui uma personalidade diplomática e sabe obter o que deseja por meio de argumentação e conversa. Você recebe treinamento em Diplomacia ou, se já for treinado nesta perícia, recebe +2 nela. Além disso, ao fazer um teste para persuasão, a penalidade que você sofre por perguntar ou pedir coisas custosas ou perigosas diminui em –5.",
    preRequisitos: "Pre 2",
  ),
  Poder(
    nome: "Pesquisador Científico",
    tipo: "Geral",
    descricao:
        "Você possui um profundo respeito pela ciência e acredita que ela é a resposta para muitos de seus questionamentos. Você recebe treinamento em Ciências ou, se já for treinado nesta perícia, recebe +2 nela. Além disso, você pode usar Ciências no lugar de Ocultismo e Sobrevivência para identificar criaturas e animais, respectivamente.",
    preRequisitos: "Int 2",
  ),
  Poder(
    nome: "Proativo",
    tipo: "Geral",
    descricao:
        "Seu negócio é fazer as coisas, e não deixar para depois. Você recebe treinamento em Iniciativa ou, se já for treinado nesta perícia, recebe +2 nela. Além disso, ao rolar um 19 ou 20 em pelo menos um dos dados de um teste de Iniciativa, você recebe uma ação padrão adicional em seu primeiro turno.",
    preRequisitos: "Agi 2",
  ),
  Poder(
    nome: "Provisões de Emergência",
    tipo: "Geral",
    descricao:
        "Você é um sujeito precavido e mantém uma reserva secreta para quando as coisas ficarem ruins. Você possui um esconderijo com equipamentos e suprimentos escondidos para uma situação de emergência. Uma vez por missão, você pode usar uma ação de interlúdio para recuperar o conteúdo de seu esconderijo. Você recebe novos equipamentos a sua escolha equivalente à sua patente no início desta missão.",
  ),
  Poder(
    nome: "Racionalidade Inflexível",
    tipo: "Geral",
    descricao:
        "Suas convicções e sua visão de mundo são baseadas em argumentos racionais e lógicos. Você pode usar Intelecto no lugar de Presença como atributo-chave de Vontade e para calcular seus pontos de esforço.",
    preRequisitos: "Int 3",
  ),
  Poder(
    nome: "Rato de Computador",
    tipo: "Geral",
    descricao:
        "Você adora computadores e outros dispositivos tecnológicos. Você recebe treinamento em Tecnologia ou, se já for treinado nesta perícia, recebe +2 nela. Você pode hackear, localizar arquivo ou operar dispositivo como uma ação completa e, uma vez por cena de investigação, se tiver acesso a um computador, pode fazer um teste de Tecnologia para procurar pistas sem gastar uma rodada de investigação.",
    preRequisitos: "Int 2",
  ),
  Poder(
    nome: "Resposta Rápida",
    tipo: "Geral",
    descricao:
        "Seus reflexos são tão apurados que o permitem agir antes mesmo de você perceber as ameaças de forma consciente. Você recebe treinamento em Reflexos ou, se já for treinado nesta perícia, recebe +2 nela. Além disso, ao falhar em um teste de Percepção para evitar ficar desprevenido, você pode gastar 2 PE para rolar novamente o teste usando Reflexos.",
    preRequisitos: "Agi 2",
    custoPE: 2,
  ),
  Poder(
    nome: "Saque Rápido",
    tipo: "Geral",
    descricao:
        "Você pode sacar ou guardar itens como uma ação livre (em vez de ação de movimento). Além disso, caso esteja usando a regra opcional de contagem de munição, uma vez por rodada pode recarregar uma arma de disparo como uma ação livre.",
    preRequisitos: "Treinado em Iniciativa",
  ),
  Poder(
    nome: "Sentidos Aguçados",
    tipo: "Geral",
    descricao:
        "Todos os seus sentidos são mais aguçados que o normal. Você recebe treinamento em Percepção ou, se já for treinado nessa perícia, recebe +2 nela. Além disso, não fica desprevenido contra inimigos que não possa ver e, sempre que erra um ataque devido a camuflagem, pode rolar mais uma vez o dado da chance de falha.",
    preRequisitos: "Pre 2",
  ),
  Poder(
    nome: "Sobrevivencialista",
    tipo: "Geral",
    descricao:
        "Você aprecia — ou aprecia enfrentar — a natureza. Você recebe treinamento em Sobrevivência ou, se já for treinado nesta perícia, recebe +2 nela. Além disso, você recebe +2 em testes para resistir a efeitos de clima e terreno difícil natural não reduz seu deslocamento nem impede que você execute investidas.",
    preRequisitos: "Int 2",
  ),
  Poder(
    nome: "Sorrateiro",
    tipo: "Geral",
    descricao:
        "Você sabe ser discreto em qualquer situação. Você recebe treinamento em Furtividade ou, se já for treinado nesta perícia, recebe +2 nela. Além disso, você não sofre penalidades por se mover normalmente enquanto está furtivo, nem por seguir alguém em ambientes sem esconderijos ou sem movimento.",
    preRequisitos: "Agi 2",
  ),
  Poder(
    nome: "Talentoso",
    tipo: "Geral",
    descricao:
        "Você possui inclinação para todas as formas de expressão artística. Você recebe treinamento em Artes ou, se já for treinado nesta perícia, recebe +2 nela. Além disso, quando faz um teste de Artes para impressionar, o bônus em perícias que você recebe aumenta em +1 para cada 5 pontos adicionais em que o resultado de seu teste passar a DT.",
    preRequisitos: "Pre 2",
  ),
  Poder(
    nome: "Teimosia Obstinada",
    tipo: "Geral",
    descricao:
        "As pessoas chamam você de teimoso. Mas elas estão erradas! Você recebe treinamento em Vontade ou, se já for treinado nesta perícia, recebe +2 nela. Além disso, quando faz um teste de Vontade contra um efeito que cause uma condição mental ou tente modificar sua categoria de atitude (como o ritual Enfeitiçar), você pode gastar 2 PE para receber +5 neste teste.",
    preRequisitos: "Pre 2",
  ),
  Poder(
    nome: "Tenacidade",
    tipo: "Geral",
    descricao:
        "Seu corpo desenvolveu a capacidade de suportar rigores extremos. Você recebe treinamento em Fortitude ou, se já for treinado nesta perícia, recebe +2 nela. Além disso, ao estar morrendo, mas consciente (com pelo menos 1 PV), você pode fazer um teste de Fortitude (DT 20 + 10 por teste anterior na mesma cena) como ação livre. Se for bem-sucedido, encerra a condição morrendo.",
    preRequisitos: "Vig 2",
  ),
  Poder(
    nome: "Tiro Certeiro",
    tipo: "Geral",
    descricao:
        "Se estiver usando uma arma de disparo, você soma sua Agilidade nas rolagens de dano e ignora a penalidade contra alvos envolvidos em combate corpo a corpo (mesmo se não usar a ação mirar).",
    preRequisitos: "Treinado em Pontaria",
  ),
  Poder(
    nome: "Vitalidade Reforçada",
    tipo: "Geral",
    descricao:
        "Você possui uma capacidade superior de suportar ferimentos. Você recebe +1 PV para cada 5% de NEX e +2 em Fortitude.",
    preRequisitos: "Vig 2",
  ),
  Poder(
    nome: "Vontade Inabalável",
    tipo: "Geral",
    descricao:
        "Sua mente é preparada para suportar os mais rigorosos traumas. Você recebe +1 PE para cada 10% de NEX e +2 em Vontade.",
    preRequisitos: "Pre 2",
  ),
];

// PODERES DE COMBATENTE

final List<Poder> catalogoPoderesCombatente = [
  Poder(
    nome: "Apego Angustiado",
    tipo: "Combatente",
    descricao:
        "Não importa o quão profundos sejam seus ferimentos, você escolhe a agonia enlouquecedora da dor a perder a consciência diante da própria morte. Você não fica inconsciente por estar morrendo, mas sempre que terminar uma rodada nesta condição e consciente, perde 2 pontos de Sanidade.",
  ),
  Poder(
    nome: "Armamento Pesado",
    tipo: "Combatente",
    descricao: "Você recebe proficiência com armas pesadas.",
    preRequisitos: "For 2",
  ),
  Poder(
    nome: "Ataque de Oportunidade",
    tipo: "Combatente",
    descricao:
        "Sempre que um ser sair voluntariamente de um espaço adjacente ao seu, você pode gastar uma reação e 1 PE para fazer um ataque corpo a corpo contra ele.",
    custoPE: 1,
  ),
  Poder(
    nome: "Caminho para Forca",
    tipo: "Combatente",
    descricao:
        "Se for para alguém do seu grupo ser pego, que seja você. Quando usa a ação sacrifício em uma cena de perseguição (p. 90), você pode gastar 1 PE para fornecer +1d20 extra (para um total de +2d20) nos testes dos outros personagens e, quando usa a ação chamar atenção em uma cena de furtividade (p. 92), você pode gastar 1 PE para diminuir a visibilidade de todos os seus aliados próximos em –2 (em vez de –1).",
    custoPE: 1,
  ),
  Poder(
    nome: "Ciente das Cicatrizes",
    tipo: "Combatente",
    descricao:
        "Acostumado a manusear armas, você aprendeu também a identificar as marcas que elas deixam. Quando faz um teste para encontrar uma pista relacionada a armas ou ferimentos (como um teste para necropsia ou para identificar uma arma amaldiçoada), você pode usar Luta ou Pontaria no lugar da perícia original.",
    preRequisitos: "Treinado em Luta ou Pontaria",
  ),
  Poder(
    nome: "Combate Defensivo",
    tipo: "Combatente",
    descricao:
        "Quando usa a ação agredir, você pode combater defensivamente. Se fizer isso, até seu próximo turno, sofre –1d20 em todos os testes de ataque, mas recebe +5 na Defesa.",
    preRequisitos: "Int 2",
  ),
  Poder(
    nome: "Correria Desesperada",
    tipo: "Combatente",
    descricao:
        "Você já esteve diante de coisas que não podem ser derrotadas e aprendeu da forma mais trágica que às vezes fugir é a única chance de vitória. Você recebe +3m em seu deslocamento e +1d20 em testes de perícia para fugir em uma perseguição (veja p. 90).",
  ),
  Poder(
    nome: "Engolir o Choro",
    tipo: "Combatente",
    descricao:
        "Mesmo ferido, você não vai emitir um pio até que a ameaça se afaste. Você não sofre penalidades por condições em testes de perícia para fugir e em testes de Furtividade.",
  ),
  Poder(
    nome: "Golpe Demolidor",
    tipo: "Combatente",
    descricao:
        "Quando usa a manobra quebrar ou ataca um objeto, você pode gastar 1 PE para causar dois dados de dano extra do mesmo tipo de sua arma.",
    preRequisitos: "For 2, Treinado em Luta",
    custoPE: 1,
  ),
  Poder(
    nome: "Golpe Pesado",
    tipo: "Combatente",
    descricao:
        "Enquanto estiver empunhando uma arma corpo a corpo, o dano dela aumenta em mais um dado do mesmo tipo.",
  ),
  Poder(
    nome: "Incansável",
    tipo: "Combatente",
    descricao:
        "Uma vez por cena, você pode gastar 2 PE para fazer uma ação de investigação adicional, mas deve usar Força ou Agilidade como atributo-base do teste.",
    custoPE: 2,
  ),
  Poder(
    nome: "Instinto de Fuga",
    tipo: "Combatente",
    descricao:
        "Sabendo que nem toda batalha pode ser vencida, você desenvolveu um sexto sentido para prever quando é hora de fugir. Quando uma cena de perseguição (ou semelhante) tem início, você recebe +2 em todos os testes de perícia que fizer durante a cena.",
    preRequisitos: "Treinado em Intuição",
  ),
  Poder(
    nome: "Mochileiro",
    tipo: "Combatente",
    descricao:
        "Você já precisou pegar a estrada para escapar de perseguidores o suficiente para saber como carregar tudo que precisa. Seu limite de carga aumenta em 5 espaços e você pode se beneficiar de uma vestimenta adicional.",
    preRequisitos: "Vig 2",
  ),
  Poder(
    nome: "Paranoia Defensiva",
    tipo: "Combatente",
    descricao:
        "Você sabe que eles estão lá fora, e fará tudo ao seu alcance para mantê-los assim. Uma vez por cena, você pode gastar uma rodada e 3 PE. Se fizer isso, você e cada aliado presente escolhe entre receber +5 na Defesa contra o próximo ataque que sofrer na cena ou receber um bônus de +5 em um único teste de perícia feito até o fim da cena.",
    custoPE: 3,
  ),
  Poder(
    nome: "Presteza Atlética",
    tipo: "Combatente",
    descricao:
        "Quando faz um teste de facilitar a investigação, você pode gastar 1 PE para usar Força ou Agilidade no lugar do atributo-base da perícia. Se passar no teste, o próximo aliado que usar seu bônus também recebe +1d20 no teste.",
    custoPE: 1,
  ),
  Poder(
    nome: "Proteção Pesada",
    tipo: "Combatente",
    descricao: "Você recebe proficiência com Proteções Pesadas.",
    preRequisitos: "NEX 30%",
  ),
  Poder(
    nome: "Reflexos Defensivos",
    tipo: "Combatente",
    descricao: "Você recebe +2 em Defesa e em testes de resistência.",
    preRequisitos: "Agi 2",
  ),
  Poder(
    nome: "Sacrificar os Joelhos",
    tipo: "Combatente",
    descricao:
        "Diante de algo que não pode ser vencido, você abre mão da autopreservação para superar seus limites de fuga. Uma vez por cena de perseguição (p. 90), quando faz a ação esforço extra, você pode gastar 2 PE para passar automaticamente no teste de perícia.",
    preRequisitos: "Treinado em Atletismo",
    custoPE: 2,
  ),
  Poder(
    nome: "Segurar o Gatilho",
    tipo: "Combatente",
    descricao:
        "Sempre que acerta um ataque com uma arma de fogo, pode fazer outro ataque com a mesma arma contra o mesmo alvo, pagando 2 PE por cada ataque já realizado no turno. Ou seja, pode fazer o primeiro ataque extra gastando 2 PE e, se acertar, pode fazer um segundo ataque extra gastando mais 4 PE e assim por diante, até errar um ataque ou atingir o limite de seus PE por rodada.",
    preRequisitos: "NEX 60%",
    custoPE: 2,
  ),
  Poder(
    nome: "Sem Tempo, Irmão",
    tipo: "Combatente",
    descricao:
        "Você sabe que pistas são importantes, mas com o paranormal podendo surgir a qualquer momento, cada segundo conta. Uma vez por cena de investigação, quando usa a ação facilitar investigação (OPRPG, p. 80), você pode prestar ajuda de forma apressada e descuidada. Você passa automaticamente no teste para auxiliar seus aliados, mas faz uma rolagem adicional na tabela de eventos de investigação (p. 82).",
  ),
  Poder(
    nome: "Sentido Tático",
    tipo: "Combatente",
    descricao:
        "Você pode gastar uma ação de movimento e 2 PE para analisar o ambiente. Se fizer isso, recebe um bônus em Defesa e em testes de resistência igual ao seu Intelecto até o final da cena.",
    preRequisitos: "Int 2, Treinado em Percepção e Tática",
    custoPE: 2,
  ),
  Poder(
    nome: "Tanque de Guerra",
    tipo: "Combatente",
    descricao:
        "Se estiver usando uma proteção pesada, a Defesa e a resistência a dano que ela fornece aumentam em +2.",
    preRequisitos: "Proteção Pesada",
  ),
  Poder(
    nome: "Tiro de Cobertura",
    tipo: "Combatente",
    descricao:
        "Você pode gastar uma ação padrão e 1 PE para disparar uma arma de fogo na direção de um ser no alcance da arma para forçá-lo a se proteger. Faça um teste de Pontaria contra a Vontade do alvo. Se vencer, até o início do seu próximo turno o alvo não pode sair do lugar onde está e sofre –5 em testes de ataque. A critério do mestre, o alvo recebe +5 no teste de Vontade se estiver em um lugar extremamente perigoso. Este é um efeito de medo.",
    custoPE: 1,
  ),
  Poder(
    nome: "Valentão",
    tipo: "Combatente",
    descricao:
        "Em algum momento, a vida lhe ensinou que a brutalidade pode ser amedrontadora, e agora esse é seu principal idioma. Você pode usar Força no lugar de Presença para Intimidação. Além disso, uma vez por cena, pode gastar 1 PE para fazer um teste de Intimidação para assustar como uma ação livre.",
    custoPE: 1,
  ),
  Poder(
    nome: "Ataque Especial",
    tipo: "Combatente",
    descricao: "Quando faz um ataque, você pode gastar 2 PE para receber +5 no teste de ataque ou na rolagem de dano. Conforme avança de NEX, você pode gastar +1 PE para receber mais bônus de +5. Você pode aplicar cada bônus de +5 em ataque ou dano.",
    custoPE: 2,
  ),
];

// PODERES DE ESPECIALISTA

final List<Poder> catalogoPoderesEspecialista = [
  Poder(
    nome: "Acolher o Terror",
    tipo: "Especialista",
    descricao:
        "Você já sofreu tanto medo que às vezes aceitar o terror é como voltar para casa. Você pode se entregar para o medo (veja p. 88) uma vez por sessão de jogo adicional.",
  ),
  Poder(
    nome: "Artista Marcial",
    tipo: "Especialista",
    descricao:
        "Seus ataques desarmados causam 1d6 pontos de dano, podem causar dano letal e contam como armas ágeis. Em NEX 35%, o dano aumenta para 1d8 e, em NEX 70%, para 1d10.",
  ),
  Poder(
    nome: "Balística Avançada",
    tipo: "Especialista",
    descricao:
        "Você recebe proficiência com armas táticas de fogo e +2 em rolagens de dano com armas de fogo.",
  ),
  Poder(
    nome: "Conhecimento Aplicado",
    tipo: "Especialista",
    descricao:
        "Quando faz um teste de perícia (exceto Luta e Pontaria), você pode gastar 2 PE para mudar o atributo-base da perícia para Int.",
    preRequisitos: "Int 2",
    custoPE: 2,
  ),
  Poder(
    nome: "Contatos Oportunos",
    tipo: "Especialista",
    descricao:
        "Ao longo de sua vida, você fez amizades úteis com pessoas de vários tipos em muitos lugares. Você pode usar uma ação de interlúdio para acionar seus contatos locais. Você recebe um aliado de um tipo à sua escolha, que lhe acompanha até o fim da missão ou até ser dispensado. Você só pode ter um desses aliados por vez.",
    preRequisitos: "Treinado em Crime",
  ),
  Poder(
    nome: "Disfarce Sutil",
    tipo: "Especialista",
    descricao:
        "Você sabe como se disfarçar rapidamente, usando pequenos detalhes para alterar sua aparência. Quando faz um disfarce em si mesmo usando Enganação, você pode gastar 1 PE para se disfarçar como uma ação completa e sem necessidade de um kit de disfarces (se usar um kit, recebe +5 no teste).",
    preRequisitos: "Pre 2, Treinado em Enganação",
    custoPE: 1,
  ),
  Poder(
    nome: "Esconderijo Desesperado",
    tipo: "Especialista",
    descricao:
        "Você já esteve diante de coisas que não podem ser derrotadas e aprendeu da forma mais trágica que às vezes se esconder é a única chance de vitória. Você não sofre –1d20 em testes de Furtividade por se mover ao seu deslocamento normal. Além disso, em cenas de furtividade, sempre que passa em um teste para esconder-se, sua visibilidade diminui em –2 (em vez de apenas –1).",
  ),
  Poder(
    nome: "Especialista Diletante",
    tipo: "Especialista",
    descricao:
        "A vida lhe ensinou que todo tipo de conhecimento pode ser útil. Você aprende um poder que não pertença à sua classe (exceto poderes de trilha ou paranormais), à sua escolha, cujos pré-requisitos possa cumprir.",
    preRequisitos: "NEX 30%",
  ),
  Poder(
    nome: "Flashback",
    tipo: "Especialista",
    descricao:
        "Um novo trauma recente desbloqueia um conhecimento adormecido. Talvez fosse uma memória enterrada fundo em sua mente, ou uma habilidade desenvolvida por seu cérebro como um mecanismo de defesa. Escolha uma origem que não seja a sua. Você recebe o poder dessa origem.",
  ),
  Poder(
    nome: "Hacker",
    tipo: "Especialista",
    descricao:
        "Você recebe +5 em testes de Tecnologia para invadir sistemas e diminui o tempo necessário para hackear qualquer sistema para uma ação completa.",
    preRequisitos: "Treinado em Tecnologia",
  ),
  Poder(
    nome: "Leitura Fria",
    tipo: "Especialista",
    descricao:
        "Você estudou técnicas de “leitura fria”, a capacidade de analisar e compreender uma pessoa através de suas mais sutis reações. Uma vez em cada interlúdio, se passar alguns minutos interagindo com uma pessoa, ou observando-a, você pode fazer três perguntas pessoais sobre ela. Para cada pergunta não respondida pelo mestre, você recebe 2 PE temporários que duram até o fim da missão. Apenas em NPCs.",
    preRequisitos: "Treinado em Intuição",
  ),
  Poder(
    nome: "Mãos Firmes",
    tipo: "Especialista",
    descricao:
        "Quando faz um teste de Furtividade para esconder-se ou para executar uma ação discreta que envolva manipular um objeto, você pode gastar 2 PE para receber +1d20 nesse teste.",
    preRequisitos: "Treinado em Furtividade",
    custoPE: 2,
  ),
  Poder(
    nome: "Mãos Rápidas",
    tipo: "Especialista",
    descricao:
        "Ao fazer um teste de Crime, você pode pagar 1 PE para fazê-lo como uma ação livre.",
    preRequisitos: "Agi 3, Treinado em Crime",
    custoPE: 1,
  ),
  Poder(
    nome: "Mochila de Utilidades",
    tipo: "Especialista",
    descricao:
        "Um item a sua escolha (exceto armas) conta como uma categoria abaixo e ocupa 1 espaço a menos.",
  ),
  Poder(
    nome: "Movimento Tático",
    tipo: "Especialista",
    descricao:
        "Você pode gastar 1 PE para ignorar a penalidade em deslocamento por terreno difícil e por escalar até o final do turno.",
    preRequisitos: "Treinado em Atletismo",
    custoPE: 1,
  ),
  Poder(
    nome: "Na Trilha Certa",
    tipo: "Especialista",
    descricao:
        "Sempre que tiver sucesso em um teste para procurar pistas, você pode gastar 1 PE para receber +1d20 no próximo teste. Os custos e os bônus são cumulativos.",
    custoPE: 1,
  ),
  Poder(
    nome: "Nerd",
    tipo: "Especialista",
    descricao:
        "Você é um repositório de conhecimento útil. Uma vez por cena, pode gastar 2 PE para fazer um teste de Atualidades (DT 20). Se passar, recebe uma informação útil para essa cena (dica para pista, fraqueza de inimigo, etc.).",
    custoPE: 2,
  ),
  Poder(
    nome: "Ninja Urbano",
    tipo: "Especialista",
    descricao:
        "Você recebe proficiência com armas táticas de ataque corpo a corpo e de disparo (exceto de fogo) e +2 em rolagens de dano com armas de corpo a corpo e de disparo.",
  ),
  Poder(
    nome: "Pensamento Ágil",
    tipo: "Especialista",
    descricao:
        "Uma vez por rodada, durante uma cena de investigação, você pode gastar 2 PE para fazer uma ação de procurar pistas adicional.",
    custoPE: 2,
  ),
  Poder(
    nome: "Perito em Explosivos",
    tipo: "Especialista",
    descricao:
        "Você soma seu Intelecto na DT para resistir aos seus explosivos e pode excluir dos efeitos da explosão um número de alvos igual ao seu valor de Intelecto.",
  ),
  Poder(
    nome: "Plano de Fuga",
    tipo: "Especialista",
    descricao:
        "Você pode usar Intelecto no lugar de Força para a ação criar obstáculos em uma perseguição. Além disso, uma vez por cena, pode gastar 2 PE para dispensar o teste e ser bem-sucedido nesta ação.",
    custoPE: 2,
  ),
  Poder(
    nome: "Primeira Impressão",
    tipo: "Especialista",
    descricao:
        "Você recebe +2d20 no primeiro teste de Diplomacia, Enganação, Intimidação ou Intuição que fizer em uma cena.",
  ),
  Poder(
    nome: "Remoer Memórias",
    tipo: "Especialista",
    descricao:
        "Sua mente está constantemente revivendo memórias do passado. Uma vez por cena, quando faz um teste de perícia baseada em Intelecto ou Presença, você pode gastar 2 PE para substituir esse teste por um teste de Intelecto com DT 15.",
    preRequisitos: "Int 1",
    custoPE: 2,
  ),
  Poder(
    nome: "Resistir à Pressão",
    tipo: "Especialista",
    descricao:
        "Uma vez por cena de investigação, você pode gastar 5 PE para coordenar os esforços de seus companheiros. A urgência da investigação aumenta em 1 rodada, e durante esta rodada adicional todos os personagens (incluindo você) recebem +2 em testes de perícia.",
    preRequisitos: "Treinado em Investigação",
    custoPE: 5,
  ),
  Poder(
    nome: "Eclético",
    tipo: "Especialista",
    descricao: "Quando faz um teste de uma perícia, você pode gastar 2 PE para receber os benefícios de ser treinado nesta perícia.",
    custoPE: 2,
  ),
  Poder(
    nome: "Perito",
    tipo: "Especialista",
    descricao: "Escolha duas perícias nas quais você é treinado (exceto Luta e Pontaria). Quando faz um teste de uma dessas perícias, você pode gastar 2 PE para somar +1d6 no resultado do teste. Conforme avança de NEX, o dado de bônus aumenta.",
    custoPE: 2,
  ),
];

// PODERES DE OCULTISTA

final List<Poder> catalogoPoderesOcultista = [
  Poder(
    nome: "Camuflar Ocultismo",
    tipo: "Ocultista",
    descricao:
        "Você pode gastar uma ação livre para esconder símbolos e sigilos que estejam desenhados ou gravados em objetos ou em sua pele, tornando-os invisíveis para outras pessoas além de você mesmo. Além disso, quando lança um ritual, pode gastar +2 PE para lançá-lo sem usar componentes ritualísticos e sem gesticular, usando apenas concentração. Outros seres só perceberão que você lançou um ritual se passarem num teste de Ocultismo (DT 25).",
    custoPE: 2,
  ),
  Poder(
    nome: "Criar Selo",
    tipo: "Ocultista",
    descricao:
        "Você sabe fabricar selos paranormais de rituais que conheça. Fabricar um selo gasta uma ação de interlúdio e um número de PE iguais ao custo de conjurar o ritual. Você pode ter um número máximo de selos criados ao mesmo tempo igual à sua Presença.",
  ),
  Poder(
    nome: "Deixe os Sussurros Guiarem",
    tipo: "Ocultista",
    descricao:
        "Você sabe abrir sua mente para os sussurros do Paranormal, vozes que lhe guiam às custas de sua Sanidade. Uma vez por cena, você pode gastar 2 PE e uma rodada para receber +2 em testes de perícia para investigação até o fim da cena. Entretanto, enquanto este poder estiver ativo, sempre que falha em um teste de perícia, você perde 1 ponto de Sanidade.",
    custoPE: 2,
  ),
  Poder(
    nome: "Domínio Esotérico",
    tipo: "Ocultista",
    descricao:
        "Você estudou a fundo a complexidade de catalisadores esotéricos e aprendeu a combinar suas propriedades paranormais. Ao lançar um ritual, você pode combinar os efeitos de até dois catalisadores ritualísticos diferentes ao mesmo tempo.",
    preRequisitos: "Int 3",
  ),
  Poder(
    nome: "Envolto em Mistério",
    tipo: "Ocultista",
    descricao:
        "Sua aparência e postura assombrosas o permitem manipular e assustar pessoas ignorantes ou supersticiosas. Como regra geral, você recebe +5 em Enganação e Intimidação contra pessoas não treinadas em Ocultismo.",
  ),
  Poder(
    nome: "Especialista em Elemento",
    tipo: "Ocultista",
    descricao:
        "Escolha um elemento. A DT para resistir aos seus rituais desse elemento aumenta em +2.",
  ),
  Poder(
    nome: "Estalos Macabros",
    tipo: "Ocultista",
    descricao:
        "Você sabe colidir pequenos objetos amaldiçoados para gerar distrações fortuitas em momentos de necessidade. Quando faz uma ação para atrapalhar a atenção de outro ser, você pode gastar 1 PE para usar Ocultismo em vez da perícia original. Se o alvo da sua distração for uma pessoa ou animal, você recebe +5 no teste.",
    custoPE: 1,
  ),
  Poder(
    nome: "Ferramentas Paranormais",
    tipo: "Ocultista",
    descricao:
        "Você reduz a categoria de um item paranormal em I e pode ativar itens paranormais sem pagar seu custo em PE.",
  ),
  Poder(
    nome: "Fluxo de Poder",
    tipo: "Ocultista",
    descricao:
        "Você pode manter dois efeitos sustentados de rituais ativos ao mesmo tempo com apenas uma ação livre, pagando o custo de cada efeito separadamente.",
    preRequisitos: "NEX 60%",
  ),
  Poder(
    nome: "Guiado pelo Paranormal",
    tipo: "Ocultista",
    descricao:
        "Uma vez por cena, você pode gastar 2 PE para fazer uma ação de investigação adicional.",
    custoPE: 2,
  ),
  Poder(
    nome: "Identificação Paranormal",
    tipo: "Ocultista",
    descricao:
        "Você recebe +10 em testes de Ocultismo para identificar criaturas, objetos ou rituais.",
  ),
  Poder(
    nome: "Improvisar Componentes",
    tipo: "Ocultista",
    descricao:
        "Uma vez por cena, você pode gastar uma ação completa para fazer um teste de Investigação (DT 15). Se passar, encontra objetos que podem servir como componentes ritualísticos de um elemento à sua escolha.",
  ),
  Poder(
    nome: "Intuição Paranormal",
    tipo: "Ocultista",
    descricao:
        "Sempre que usa a ação facilitar investigação, você soma seu Intelecto ou Presença no teste (à sua escolha).",
  ),
  Poder(
    nome: "Mestre em Elemento",
    tipo: "Ocultista",
    descricao:
        "Escolha um elemento. O custo para lançar rituais desse elemento diminui em –1 PE.",
    preRequisitos: "Especialista em Elemento no elemento escolhido, NEX 45%",
  ),
  Poder(
    nome: "Minha Dor me Impulsiona",
    tipo: "Ocultista",
    descricao:
        "Você está acostumado com sacrifícios dolorosos e aprendeu a transformar sua dor em impulso físico. Quando faz um teste de Acrobacia, Atletismo ou Furtividade, você pode gastar 1 PE para receber +1d6 no teste. Você só pode usar este poder se estiver com pelo menos 5 pontos de dano em seus PV.",
    preRequisitos: "Vig 2",
    custoPE: 1,
  ),
  Poder(
    nome: "Nos Olhos do Monstro",
    tipo: "Ocultista",
    descricao:
        "Se estiver em uma cena envolvendo uma criatura paranormal, você pode gastar uma rodada e 3 PE para encarar essa criatura. Se fizer isso, você recebe +5 em testes contra a criatura (exceto testes de ataque) até o fim da cena.",
    custoPE: 3,
  ),
  Poder(
    nome: "Olhar Sinistro",
    tipo: "Ocultista",
    descricao:
        "Você pode usar Presença no lugar de Intelecto para Ocultismo e pode usar esta perícia para coagir (veja Intimidação).",
    preRequisitos: "Pre 1",
  ),
  Poder(
    nome: "Ritual Potente",
    tipo: "Ocultista",
    descricao:
        "Você soma seu Intelecto nas rolagens de dano ou nos efeitos de cura de seus rituais.",
    preRequisitos: "Int 2",
  ),
  Poder(
    nome: "Ritual Predileto",
    tipo: "Ocultista",
    descricao:
        "Escolha um ritual que você conhece. Você reduz em –1 PE o custo do ritual. Essa redução se acumula com reduções fornecidas por outras fontes.",
  ),
  Poder(
    nome: "Sentido Premonitório",
    tipo: "Ocultista",
    descricao:
        "Você pode gastar 3 PE para ativar um sentido premonitório. Enquanto seu sentido estiver ativo, você tem um déjà vu do futuro próximo (equivalente a uma rodada). Você sabe com uma rodada de antecedência quando a urgência de uma investigação vai acabar e quais ações seus inimigos irão tomar. Para manter seu sentido ativado, você deve gastar 1 PE no início de cada rodada.",
    custoPE: 3,
  ),
  Poder(
    nome: "Sincronia Paranormal",
    tipo: "Ocultista",
    descricao:
        "Você pode gastar uma ação padrão e 2 PE para estabelecer uma sincronia mental com personagens em alcance médio. No início de cada rodada em que a sincronia estiver em efeito você pode distribuir uma quantidade de O de bônus igual à sua Presença entre os participantes. Manter a sincronia custa 1 PE no início de cada rodada.",
    preRequisitos: "Pre 2",
    custoPE: 2,
  ),
  Poder(
    nome: "Tatuagem Ritualística",
    tipo: "Ocultista",
    descricao:
        "Símbolos marcados em sua pele reduzem em –1 PE o custo de rituais de alcance pessoal que têm você como alvo.",
  ),
  Poder(
    nome: "Traçado Conjuratório",
    tipo: "Ocultista",
    descricao:
        "Você pode gastar 1 PE e uma ação completa traçando um símbolo paranormal no chão. Enquanto estiver dentro desse símbolo, você recebe +2 em testes de Ocultismo e de resistência e a DT para resistir aos seus rituais aumenta em +2. O símbolo dura até o fim da cena.",
    custoPE: 1,
  ),
];

// PODERES PARANORMAIS

// CONHECIMENTO
final List<Poder> catalogoPoderesConhecimento = [
  Poder(
    nome: "Absorver Conhecimento",
    tipo: "Conhecimento",
    descricao:
        "Se estiver empunhando uma fonte de conhecimento escrito, você pode gastar 1 PE e uma ação completa para fazer uma pergunta a esta fonte. Se a resposta estiver armazenada, você a obtém. Se usar com a ação ler, o dado de bônus aumenta em um passo.\nAfinidade: rituais de Conhecimento tocados reduzem -1 PE.",
    custoPE: 1,
  ),
  Poder(
    nome: "Apatia Herege",
    tipo: "Conhecimento",
    descricao:
        "Quando faz um teste contra uma condição de medo, você pode gastar 2 PE para rolar o teste novamente. Você deve aceitar o segundo resultado.\nAfinidade: pode usar depois de saber o resultado e escolhe a melhor rolagem.",
    preRequisitos: "Conhecimento 1",
    custoPE: 2,
  ),
  Poder(
    nome: "Aprender Ritual (Conhecimento)",
    tipo: "Conhecimento",
    descricao:
        "Você aprende um ritual de Conhecimento de 1º círculo. Em NEX 45%, aprende até 2º círculo. Em NEX 75%, aprende até 3º círculo.",
  ),
  Poder(
    nome: "Expansão de Conhecimento",
    tipo: "Conhecimento",
    descricao:
        "Você aprende um poder de classe que não pertença à sua classe.\nAfinidade: você aprende um segundo poder de classe de outra classe.",
    preRequisitos: "Conhecimento 1",
  ),
  Poder(
    nome: "Percepção Paranormal",
    tipo: "Conhecimento",
    descricao:
        "Em cenas de investigação, para procurar pistas, você pode rolar novamente um dado com resultado menor que 10. Você deve aceitar a segunda rolagem.\nAfinidade: você pode rolar novamente até dois dados.",
  ),
  Poder(
    nome: "Precognição",
    tipo: "Conhecimento",
    descricao:
        "Você recebe +2 em Defesa e em testes de resistência.\nAfinidade: você fica imune à condição desprevenido.",
    preRequisitos: "Conhecimento 1",
  ),
  Poder(
    nome: "Resistir a Conhecimento",
    tipo: "Conhecimento",
    descricao:
        "Você recebe resistência a Conhecimento 10.\nAfinidade: aumenta a resistência para 20.",
  ),
  Poder(
    nome: "Sensitivo",
    tipo: "Conhecimento",
    descricao:
        "Você recebe +5 em testes de Diplomacia, Intimidação e Intuição.\nAfinidade: quando faz um teste oposto usando uma dessas perícias, o oponente sofre –1d20.",
  ),
  Poder(
    nome: "Visão do Oculto",
    tipo: "Conhecimento",
    descricao:
        "Você recebe +5 em testes de Percepção e enxerga no escuro.\nAfinidade: você ignora camuflagem.",
  ),
];

// ENERGIA
final List<Poder> catalogoPoderesEnergia = [
  Poder(
    nome: "Afortunado",
    tipo: "Energia",
    descricao:
        "Uma vez por rolagem, você pode rolar novamente um resultado 1 em qualquer dado que não seja d20.\nAfinidade: além disso, uma vez por teste, você pode rolar novamente um resultado 1 em d20.",
  ),
  Poder(
    nome: "Aprender Ritual (Energia)",
    tipo: "Energia",
    descricao:
        "Você aprende um ritual de Energia de 1º círculo. Em NEX 45%, aprende até 2º círculo. Em NEX 75%, aprende até 3º círculo.",
  ),
  Poder(
    nome: "Campo Protetor",
    tipo: "Energia",
    descricao:
        "Quando usa a ação esquiva, você pode gastar 1 PE para receber +5 em Defesa.\nAfinidade: você também recebe +5 em Reflexo e não sofre dano em testes de Reflexo que reduziriam à metade.",
    preRequisitos: "Energia 1",
    custoPE: 1,
  ),
  Poder(
    nome: "Causalidade Fortuita",
    tipo: "Energia",
    descricao:
        "Em cenas de investigação, a DT para procurar pistas diminui em –5 para você até você encontrar uma pista.\nAfinidade: a DT para procurar pistas sempre diminui em –5 para você.",
  ),
  Poder(
    nome: "Conexão Empática",
    tipo: "Energia",
    descricao:
        "Você pode gastar uma ação completa e 2 PE para tocar um objeto elétrico e conversar com ele como se fosse senciente. O objeto tem atitude indiferente.\nAfinidade: você recebe +5 em Intelecto ou Presença com o item.",
    preRequisitos: "Energia 1",
    custoPE: 2,
  ),
  Poder(
    nome: "Golpe de Sorte",
    tipo: "Energia",
    descricao:
        "Seus ataques recebem +1 na margem de ameaça.\nAfinidade: seus ataques recebem +1 no multiplicador de crítico.",
    preRequisitos: "Energia 1",
  ),
  Poder(
    nome: "Manipular Entropia",
    tipo: "Energia",
    descricao:
        "Quando outro ser em alcance curto faz um teste de perícia, você pode gastar 2 PE para fazê-lo rolar novamente um dos dados desse teste.\nAfinidade: o alvo rola novamente todos os dados que você escolher.",
    preRequisitos: "Energia 1",
    custoPE: 2,
  ),
  Poder(
    nome: "Resistir a Energia",
    tipo: "Energia",
    descricao:
        "Você recebe resistência a Energia 10.\nAfinidade: aumenta a resistência para 20.",
  ),
  Poder(
    nome: "Valer-se do Caos",
    tipo: "Energia",
    descricao:
        "Quando faz um teste, você pode receber +1d20. Se o teste falhar ou o dado extra for <= 5, perde 1d4 de Sanidade.\nAfinidade: você perde Sanidade se a falha for 1 ou 2 no dado extra.",
  ),
];

// MORTE
final List<Poder> catalogoPoderesMorte = [
  Poder(
    nome: "Antecipar Vitalidade",
    tipo: "Morte",
    descricao:
        "Você pode acumular cargas de antecipação (até seu Vigor) para adicionar +1d20 a testes. Cada carga consumida tira recuperação na ação dormir.\nAfinidade: limite aumenta em +2 e perde 2 cargas por ação dormir.",
  ),
  Poder(
    nome: "Aprender Ritual (Morte)",
    tipo: "Morte",
    descricao:
        "Você aprende um ritual de Morte de 1º círculo. Em NEX 45%, aprende até 2º círculo. Em NEX 75%, aprende até 3º círculo.",
  ),
  Poder(
    nome: "Aura de Pavor",
    tipo: "Morte",
    descricao:
        "Gaste 2 PE e movimento para deixar alvo em alcance médio apavorado (Vontade reduz para abalado). Termina no fim da cena ou se mudar de alvo.\nAfinidade: DT aumenta em +5 e afeta quaisquer alvos escolhidos no alcance.",
    custoPE: 2,
  ),
  Poder(
    nome: "Encarar a Morte",
    tipo: "Morte",
    descricao:
        "Durante cenas de ação, seu limite de gasto de PE aumenta em +1.\nAfinidade: limite de gasto de PE aumenta em +2 (total +3).",
  ),
  Poder(
    nome: "Escapar da Morte",
    tipo: "Morte",
    descricao:
        "Uma vez por cena, ao receber dano que o deixaria com 0 PV, você fica com 1 PV. Não funciona em dano massivo.\nAfinidade: evita completamente o dano. Em dano massivo, fica com 1 PV.",
    preRequisitos: "Morte 1",
  ),
  Poder(
    nome: "Potencial Aprimorado",
    tipo: "Morte",
    descricao:
        "Você recebe +1 PE máximo por NEX.\nAfinidade: você recebe +1 PE adicional por NEX (total +2 PE por NEX).",
  ),
  Poder(
    nome: "Potencial Reaproveitado",
    tipo: "Morte",
    descricao:
        "Uma vez por rodada, quando passa num teste de resistência, você ganha 2 PE temporários cumulativos até o fim da cena.\nAfinidade: ganha 3 PE temporários, em vez de 2.",
  ),
  Poder(
    nome: "Resistir a Morte",
    tipo: "Morte",
    descricao:
        "Você recebe resistência a Morte 10.\nAfinidade: aumenta a resistência para 20.",
  ),
  Poder(
    nome: "Surto Temporal",
    tipo: "Morte",
    descricao:
        "Uma vez por cena, no seu turno, gaste 3 PE para realizar uma ação padrão adicional.\nAfinidade: pode usar uma vez por turno.",
    preRequisitos: "Morte 2",
    custoPE: 3,
  ),
];

// SANGUE
final List<Poder> catalogoPoderesSangue = [
  Poder(
    nome: "Anatomia Insana",
    tipo: "Sangue",
    descricao:
        "Você tem 50% de chance (resultado par em 1d4) de ignorar dano adicional de acerto crítico ou ataque furtivo.\nAfinidade: você é imune a críticos e furtivos.",
    preRequisitos: "Sangue 2",
  ),
  Poder(
    nome: "Aprender Ritual (Sangue)",
    tipo: "Sangue",
    descricao:
        "Você aprende um ritual de Sangue de 1º círculo. Em NEX 45%, aprende até 2º círculo. Em NEX 75%, aprende até 3º círculo.",
  ),
  Poder(
    nome: "Arma de Sangue",
    tipo: "Sangue",
    descricao:
        "Gaste movimento e 2 PE para produzir arma natural simples/leve (1d6 Sangue). Gaste 1 PE ao agredir para fazer ataque extra com ela.\nAfinidade: arma permanente e causa 1d10 Sangue.",
    custoPE: 2,
  ),
  Poder(
    nome: "Espreitar da Besta",
    tipo: "Sangue",
    descricao:
        "Recebe +5 em Furtividade. Em perseguição, usa Furtividade em vez de Atletismo. Em furtividade, ações discretas não sofrem penalidade de -1d20.\nAfinidade: bônus em Furtividade aumenta para +10.",
  ),
  Poder(
    nome: "Instintos Sanguinários",
    tipo: "Sangue",
    descricao:
        "Você recebe visão no escuro e faro.\nAfinidade: não pode ser flanqueado/desprevenido e recebe +5 em testes contra armadilhas.",
  ),
  Poder(
    nome: "Resistir a Sangue",
    tipo: "Sangue",
    descricao:
        "Você recebe resistência a Sangue 10.\nAfinidade: aumenta a resistência para 20.",
  ),
  Poder(
    nome: "Sangue de Ferro",
    tipo: "Sangue",
    descricao:
        "Você recebe +2 PV máximo por NEX.\nAfinidade: você recebe +5 em Fortitude e imunidade a venenos/doenças.",
  ),
  Poder(
    nome: "Sangue Fervente",
    tipo: "Sangue",
    descricao:
        "Enquanto machucado, recebe +1 em Agilidade ou Força à escolha.\nAfinidade: bônus aumenta para +2.",
    preRequisitos: "Sangue 2",
  ),
  Poder(
    nome: "Sangue Vivo",
    tipo: "Sangue",
    descricao:
        "Primeira vez machucado na cena, ganha cura acelerada 2 até curar metade da vida.\nAfinidade: cura acelerada aumenta para 5.",
    preRequisitos: "Sangue 1",
  ),
];