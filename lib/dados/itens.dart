import '../modelos/agente_dados.dart';

final List<ItemInventario> catalogoItensOrdem = [
  // Acessórios
  ItemInventario(
    nome: "Amuleto Sagrado",
    categoria: "0",
    espaco: 1.0,
    descricao:
        "Acessório. Um utensílio especial na forma de shimenawa, rosário ou qualquer objeto que reforce sua fé. Fornece +2 em Religião e Vontade.",
  ),
  ItemInventario(
    nome: "Celular",
    categoria: "0",
    espaco: 1.0,
    descricao:
        "Acessório. Se tiver acesso a internet, fornece +2 em testes para adquirir informações. Ilumina em um cone de 4,5m.",
  ),
  ItemInventario(
    nome: "Chave de Fenda Universal",
    categoria: "0",
    espaco: 1.0,
    descricao:
        "Acessório. Fornece +2 em testes de perícia para criar ou reparar objetos.",
  ),
  ItemInventario(
    nome: "Chaves",
    categoria: "0",
    espaco: 1.0,
    descricao:
        "Acessório. Usar o barulho de um molho de chaves para distrair alguém fornece +2 em Furtividade na mesma rodada.",
  ),
  ItemInventario(
    nome: "Documentos Falsos",
    categoria: "I",
    espaco: 0.0,
    descricao:
        "Acessório. Fornece +2 em testes de Diplomacia, Enganação e Intimidação para se passar pela identidade falsa.",
  ),
  ItemInventario(
    nome: "Manual Operacional",
    categoria: "I",
    espaco: 1.0,
    descricao:
        "Acessório. Gastar uma ação de interlúdio lendo um manual permite que você use essa perícia como se fosse treinado nela.",
  ),
  ItemInventario(
    nome: "Notebook",
    categoria: "0",
    espaco: 2.0,
    descricao:
        "Acessório. Fornece +2 em testes para adquirir informações. Ao relaxar em cenas de interlúdio, você recupera 1 ponto adicional de Sanidade.",
  ),
  ItemInventario(
    nome: "Kit de Perícia",
    categoria: "0",
    espaco: 1.0,
    descricao:
        "Acessório. Conjunto de ferramentas necessárias para algumas perícias. Sem o kit, você sofre –5 no teste.",
  ),
  ItemInventario(
    nome: "Utensílio",
    categoria: "I",
    espaco: 1.0,
    descricao:
        "Acessório. Um item comum que tenha uma utilidade específica. Fornece +2 em uma perícia.",
  ),
  ItemInventario(
    nome: "Vestimenta",
    categoria: "I",
    espaco: 1.0,
    descricao:
        "Acessório. Peça de vestuário que fornece +2 em uma perícia. Vestir ou despir uma vestimenta é uma ação completa.",
  ),

  // Explosivos
  ItemInventario(
    nome: "Granada de Atordoamento",
    categoria: "0",
    espaco: 1.0,
    descricao:
        "Explosivo. Flash-bang que cria um estouro barulhento e luminoso (raio 6m em alcance médio). Seres na área ficam atordoados por 1 rodada (Fortitude DT Agi reduz para ofuscado e surdo).",
  ),
  ItemInventario(
    nome: "Granada de Fragmentação",
    categoria: "I",
    espaco: 1.0,
    descricao:
        "Explosivo. Espalha fragmentos perfurantes (raio 6m em alcance médio). Seres na área sofrem 8d6 de dano de perfuração (Reflexos DT Agi reduz à metade).",
  ),
  ItemInventario(
    nome: "Granada de Fumaça",
    categoria: "0",
    espaco: 1.0,
    descricao:
        "Explosivo. Produz uma fumaça espessa (raio 6m em alcance médio). Seres na área ficam cegos e sob camuflagem total por 2 rodadas.",
  ),
  ItemInventario(
    nome: "Granada Incendiária",
    categoria: "I",
    espaco: 1.0,
    descricao:
        "Explosivo. Espalha labaredas (raio 6m em alcance médio). Causa 6d6 de dano de fogo e deixa em chamas (Reflexos DT Agi reduz à metade e evita a condição).",
  ),
  ItemInventario(
    nome: "Mina Antipessoal",
    categoria: "I",
    espaco: 1.0,
    descricao:
        "Explosivo. Ativada por controle remoto (até alcance longo). Dispara bolas de aço em cone de 6m, causando 12d6 de dano de perfuração (Reflexos DT Int reduz à metade). Instalar exige ação completa e teste de Tática DT 15.",
  ),
  ItemInventario(
    nome: "Dinamite",
    categoria: "I",
    espaco: 1.0,
    descricao:
        "Explosivo. Arremessada em alcance médio (raio 6m). Causa 4d6 de dano de impacto e 4d6 de fogo, e deixa em chamas (Reflexos DT Agi reduz à metade e evita condição).",
  ),
  ItemInventario(
    nome: "Explosivo Plástico",
    categoria: "I",
    espaco: 1.0,
    descricao:
        "Explosivo. Exige 2 rodadas para grudar. Detonado remotamente ou por dano de fogo/eletricidade. Causa 16d6 de impacto em raio de 3m (Reflexos DT Int reduz à metade). Especialistas causam o dobro de dano em estruturas e ignoram RD.",
  ),
  ItemInventario(
    nome: "Galão Vermelho",
    categoria: "0",
    espaco: 2.0,
    descricao:
        "Explosivo. Ao sofrer dano de fogo ou balístico, explode atingindo um raio de 6m. Causa 12d6 de dano de fogo e deixa em chamas (Reflexos DT 25 reduz à metade e evita). A área afetada fica em chamas.",
  ),
  ItemInventario(
    nome: "Granada de Gás Sonífero",
    categoria: "I",
    espaco: 1.0,
    descricao:
        "Explosivo. Libera gás (raio 6m). Seres que iniciam o turno na área ficam inconscientes/caídos ou exaustos (se em atividade física intensa). Fortitude DT Agi reduz para fatigado. O gás permanece por 2 rodadas.",
  ),
  ItemInventario(
    nome: "Granada de PEM",
    categoria: "I",
    espaco: 1.0,
    descricao:
        "Explosivo. Pulso eletromagnético desativa equipamentos elétricos (raio 18m) até o fim da cena. Criaturas de Energia sofrem 6d6 de impacto e ficam paralisadas por 1 rodada (Fortitude DT Agi reduz à metade e evita).",
  ),

  // Proteções
  ItemInventario(
    nome: "Proteção Leve",
    categoria: "I",
    espaco: 2.0,
    descricao:
        "Proteção. Jaqueta de couro pesada ou colete de kevlar. Fornece Defesa +5.",
  ),
  ItemInventario(
    nome: "Proteção Pesada",
    categoria: "II",
    espaco: 5.0,
    descricao:
        "Proteção. Equipamento usado por forças especiais. Fornece Defesa +10 e Resistência a balístico, corte, impacto e perfuração 2. Impõe –5 em testes de perícias com penalidade de carga.",
  ),
  ItemInventario(
    nome: "Escudo",
    categoria: "I",
    espaco: 2.0,
    descricao:
        "Proteção. Precisa ser empunhado em uma mão e fornece Defesa +2 (acumula com a de uma proteção). Conta como proteção pesada para efeitos de proficiência.",
  ),

  // Munições
  ItemInventario(
    nome: "Balas curtas",
    categoria: "0",
    espaco: 1.0,
    descricao: "Munição",
  ),
  ItemInventario(
    nome: "Balas longas",
    categoria: "I",
    espaco: 1.0,
    descricao: "Munição",
  ),
  ItemInventario(
    nome: "Cartuchos",
    categoria: "I",
    espaco: 1.0,
    descricao: "Munição",
  ),
  ItemInventario(
    nome: "Combustível",
    categoria: "I",
    espaco: 1.0,
    descricao: "Munição",
  ),
  ItemInventario(
    nome: "Foguete",
    categoria: "I",
    espaco: 1.0,
    descricao: "Munição",
  ),
  ItemInventario(
    nome: "Flechas",
    categoria: "0",
    espaco: 1.0,
    descricao: "Usadas em arcos e bestas, flechas podem ser reaproveitadas após cada combate. Por isso, um pacote de flechas dura uma missão inteira.",
  ),

  // Itens Operacionais
  ItemInventario(
    nome: "Algemas",
    categoria: "0",
    espaco: 1.0,
    descricao:
        "Item Operacional. Par de algemas de aço. Para prender um alvo não indefeso, vença um teste de Manobra de Combate (Agarrar). Prender dois pulsos impõe –5 em testes com as mãos e impede conjuração. Escapar exige Acrobacia DT 30.",
  ),
  ItemInventario(
    nome: "Arpéu",
    categoria: "0",
    espaco: 1.0,
    descricao:
        "Item Operacional. Gancho de aço. Prender exige Pontaria DT 15. Subir um muro com a ajuda de uma corda fornece +5 em Atletismo.",
  ),
  ItemInventario(
    nome: "Binóculos",
    categoria: "0",
    espaco: 1.0,
    descricao:
        "Item Operacional. Binóculos militares. Fornece +5 em testes de Percepção para observar coisas distantes.",
  ),
  ItemInventario(
    nome: "Mochila Militar",
    categoria: "I",
    espaco: -2.0,
    descricao:
        "Item Operacional. Uma mochila leve e de alta qualidade. Ela não usa nenhum espaço e aumenta sua capacidade de carga em 2 espaços.",
  ),
  ItemInventario(
    nome: "Bandoleira",
    categoria: "I",
    espaco: 1.0,
    descricao:
        "Item Operacional. Um cinto com bolsos e alças. Uma vez por rodada, você pode sacar ou guardar um item em seu inventário como uma ação livre.",
  ),
  ItemInventario(
    nome: "Bloqueador de Sinal",
    categoria: "I",
    espaco: 1.0,
    descricao:
        "Item Operacional. Emite ondas que 'poluem' a frequência de rádio, impedindo qualquer aparelho (celulares, etc) em alcance médio de se conectar.",
  ),
  ItemInventario(
    nome: "Cicatrizante",
    categoria: "I",
    espaco: 1.0,
    descricao:
        "Item Operacional. Spray médico. Com uma ação padrão, cura 2d8+2 PV em você ou em um ser adjacente. É consumido após o uso.",
  ),
  ItemInventario(
    nome: "Corda",
    categoria: "0",
    espaco: 1.0,
    descricao:
        "Item Operacional. Rolo com 10 metros de corda resistente. Fornece +5 em Atletismo para descer buracos ou prédios.",
  ),
  ItemInventario(
    nome: "Equipamento de Sobrevivência",
    categoria: "0",
    espaco: 2.0,
    descricao:
        "Item Operacional. Mochila com saco de dormir, GPS e itens úteis. Fornece +5 em Sobrevivência para acampar e orientar-se (permite o uso sem treinamento).",
  ),
  ItemInventario(
    nome: "Lanterna Tática",
    categoria: "I",
    espaco: 1.0,
    descricao:
        "Item Operacional. Ilumina um cone de 9m. Como ação de movimento, você pode ofuscar um ser em alcance curto por 1 rodada (ele fica imune pelo resto da cena).",
  ),
  ItemInventario(
    nome: "Máscara de Gás",
    categoria: "0",
    espaco: 1.0,
    descricao:
        "Item Operacional. Fornece +10 em testes de Fortitude contra efeitos que dependam de respiração.",
  ),
  ItemInventario(
    nome: "Óculos de Visão Térmica",
    categoria: "I",
    espaco: 1.0,
    descricao:
        "Item Operacional. Elimina a penalidade em testes de ataque e percepção causados por camuflagem.",
  ),
  ItemInventario(
    nome: "Pé de Cabra",
    categoria: "0",
    espaco: 1.0,
    descricao:
        "Item Operacional. Fornece +5 em testes de Força para arrombar portas. Pode ser usada em combate como arma leve (bastão).",
  ),
  ItemInventario(
    nome: "Pistola de Dardos",
    categoria: "I",
    espaco: 1.0,
    descricao:
        "Item Operacional. Arma leve (alcance curto) com sonífero. Acerto causa inconsciência até o fim da cena (Fortitude DT Agi reduz para desprevenido e lento por 1 rodada). Vem com 2 dardos.",
  ),
  ItemInventario(
    nome: "Pistola Sinalizadora",
    categoria: "0",
    espaco: 1.0,
    descricao:
        "Item Operacional. Arma de disparo leve (alcance curto). Chama a atenção para sua localização ou causa 2d6 de dano de fogo. Vem com 2 cargas.",
  ),
  ItemInventario(
    nome: "Soqueira",
    categoria: "0",
    espaco: 1.0,
    descricao:
        "Item Operacional. Fornece +1 em rolagens de dano desarmado e os torna letais. Pode receber modificações de armas corpo a corpo.",
  ),
  ItemInventario(
    nome: "Spray de Pimenta",
    categoria: "I",
    espaco: 1.0,
    descricao:
        "Item Operacional. Ação padrão contra alvo adjacente: deixa cego por 1d4 rodadas (Fortitude DT Agi evita). Possui 2 usos.",
  ),
  ItemInventario(
    nome: "Taser",
    categoria: "I",
    espaco: 1.0,
    descricao:
        "Item Operacional. Ação padrão contra alvo adjacente: 1d6 de eletricidade e atordoado por 1 rodada (Fortitude DT Agi evita). Possui 2 usos.",
  ),
  ItemInventario(
    nome: "Traje Hazmat",
    categoria: "I",
    espaco: 2.0,
    descricao:
        "Item Operacional. Fornece +5 em testes contra efeitos ambientais e Resistência a Químico 10. Ocupa espaço de vestimenta.",
  ),
  ItemInventario(
    nome: "Alarme de Movimento",
    categoria: "0",
    espaco: 1.0,
    descricao:
        "Item Operacional. Ação completa para ativar. Avisa no dispositivo quando há movimento em cone de 30m. Pode ser discreto ou acionar sirene.",
  ),
  ItemInventario(
    nome: "Alimento Energético",
    categoria: "II",
    espaco: 0.5,
    descricao:
        "Item Operacional. Suplemento tático. Ação padrão para consumir: recupera 1d4 PE.",
  ),
  ItemInventario(
    nome: "Aplicador de Medicamentos",
    categoria: "I",
    espaco: 1.0,
    descricao:
        "Item Operacional. Preso ao braço/perna. Permite aplicar uma substância carregada (como cicatrizante) com uma Ação de Movimento. Comporta 3 doses.",
  ),
  ItemInventario(
    nome: "Braçadeira Reforçada",
    categoria: "I",
    espaco: 1.0,
    descricao:
        "Item Operacional. Aumenta em +2 a RD que você recebe por usar a reação de Bloqueio.",
  ),
  ItemInventario(
    nome: "Cão Adestrado",
    categoria: "I",
    espaco: 0.0,
    descricao:
        "Item Operacional. Um parceiro animal. Pode ser usado como aliado se você for treinado em Adestramento.",
  ),
  ItemInventario(
    nome: "Coldre Saque Rápido",
    categoria: "I",
    espaco: 1.0,
    descricao:
        "Item Operacional. Uma vez por rodada, permite sacar ou guardar uma arma de fogo leve como Ação Livre.",
  ),
  ItemInventario(
    nome: "Equipamento de Escuta",
    categoria: "I",
    espaco: 1.0,
    descricao:
        "Item Operacional. Um receptor (alcance 90m) e três transmissores (captação 9m). Instalar exige Crime DT 20. Furtividade oposta se for feito em público.",
  ),
  ItemInventario(
    nome: "Estrepes",
    categoria: "0",
    espaco: 1.0,
    descricao:
        "Item Operacional. Ação padrão para cobrir 1,5m. Quem pisa sofre 1d4 de perfuração e fica lento por um dia (Reflexos DT Agi evita).",
  ),
  ItemInventario(
    nome: "Faixa de Pregos",
    categoria: "I",
    espaco: 2.0,
    descricao:
        "Item Operacional. Ocupa uma linha de 9m. Funciona como Estrepes, mas fura pneus de veículos (deslocamento cai pela metade).",
  ),
  ItemInventario(
    nome: "Isqueiro",
    categoria: "0",
    espaco: 0.5,
    descricao:
        "Item Operacional. Ação de movimento para acender. Incendeia objetos inflamáveis e ilumina raio de 3m.",
  ),
  ItemInventario(
    nome: "Óculos Escuros",
    categoria: "0",
    espaco: 0.5,
    descricao:
        "Item Operacional. Impede que o usuário fique com a condição ofuscado.",
  ),
  ItemInventario(
    nome: "Óculos de Visão Noturna",
    categoria: "I",
    espaco: 1.0,
    descricao:
        "Item Operacional. Fornece visão no escuro. Impõe –1d20 em testes de resistência contra efeitos baseados em luz (como granada de atordoamento).",
  ),
  ItemInventario(
    nome: "Pá",
    categoria: "0",
    espaco: 2.0,
    descricao:
        "Item Operacional. Fornece +5 em testes de Força para cavar buracos ou mover detritos. Pode ser usada em combate como arma.",
  ),
  ItemInventario(
    nome: "Paraquedas",
    categoria: "I",
    espaco: 2.0,
    descricao:
        "Item Operacional. Anula dano de queda. Exige Acrobacia, Pilotagem, Reflexos ou Tática Veterano (ou teste Reflexos DT 20 para abrir com sucesso).",
  ),
  ItemInventario(
    nome: "Traje de Mergulho",
    categoria: "I",
    espaco: 2.0,
    descricao:
        "Item Operacional. Garante 1 hora de oxigênio submerso. Fornece +5 contra efeitos ambientais e Resistência a Químico 5. Ação completa para vestir.",
  ),
  ItemInventario(
    nome: "Traje Espacial",
    categoria: "II",
    espaco: 5.0,
    descricao:
        "Item Operacional. Fornece 8 horas de oxigênio. +10 contra efeitos ambientais e Resistência a Químico 20. Demora 2 rodadas para vestir.",
  ),
  ItemInventario(
    nome: "Antibiótico",
    categoria: "I",
    espaco: 0.5,
    descricao:
        "Item Operacional. Fortalece a imunidade contra vírus e bactérias. Fornece +5 no próximo teste de Fortitude contra efeitos de uma doença feito até o fim do dia.",
  ),
  ItemInventario(
    nome: "Antídoto",
    categoria: "I",
    espaco: 0.5,
    descricao:
        "Item Operacional. Ajuda o corpo a lidar com venenos. Fornece +5 no próximo teste de Fortitude contra efeitos de um veneno até o fim do dia. Um antídoto feito para um veneno específico, em vez disso, remove completamente o veneno.",
  ),
  ItemInventario(
    nome: "Antiemético",
    categoria: "I",
    espaco: 0.5,
    descricao:
        "Item Operacional. Remove a condição enjoado e fornece +5 em testes para evitar essa condição até o fim da cena. A critério do mestre, pode funcionar contra outras condições causadas por náuseas e vômitos.",
  ),
  ItemInventario(
    nome: "Anti-inflamatório",
    categoria: "I",
    espaco: 0.5,
    descricao:
        "Item Operacional. Reduz reações inflamatórias, diminuindo dor e inchaço. Fornece 1d8+2 PV temporários.",
  ),
  ItemInventario(
    nome: "Antitérmico",
    categoria: "I",
    espaco: 0.5,
    descricao:
        "Item Operacional. Reduz reações febris perigosas e alivia dores de cabeça, permitindo um novo teste contra uma condição mental que o usuário esteja sofrendo. Só funciona uma vez por cena.",
  ),
  ItemInventario(
    nome: "Broncodilatador",
    categoria: "I",
    espaco: 0.5,
    descricao:
        "Item Operacional. Auxilia na respiração. Fornece +5 em testes para evitar as condições asfixiado ou fatigado feitos até o fim do dia.",
  ),
  ItemInventario(
    nome: "Coagulante",
    categoria: "I",
    espaco: 0.5,
    descricao:
        "Item Operacional. Aumenta a capacidade de coagulação, fornecendo +5 em testes para se estabilizar da condição sangrando feitos até o fim do dia. Se usado em conjunto com um teste de Medicina para remover a condição morrendo, também fornece +5 nesse teste.",
  ),

  // Itens Paranormais
  ItemInventario(
    nome: "Amarras de (elemento)",
    categoria: "II",
    espaco: 1.0,
    descricao:
        "Item Paranormal. Cordas ou correntes imbuídas com energia da entidade.",
  ),
  ItemInventario(
    nome: "Câmera de aura paranormal",
    categoria: "II",
    espaco: 1.0,
    descricao:
        "Item Paranormal. Capaz de registrar espectros invisíveis a olho nu.",
  ),
  ItemInventario(
    nome: "Componentes ritualísticos de (elemento)",
    categoria: "0",
    espaco: 1.0,
    descricao:
        "Item Paranormal. Materiais associados à entidade, usados para conjurar rituais sem penalidade.",
  ),
  ItemInventario(
    nome: "Emissor de pulsos paranormais",
    categoria: "II",
    espaco: 1.0,
    descricao:
        "Item Paranormal. Interfere em frequências da membrana no ambiente.",
  ),
  ItemInventario(
    nome: "Escuta de ruídos paranormais",
    categoria: "II",
    espaco: 1.0,
    descricao: "Item Paranormal. Capta sussurros e ecos do Outro Lado.",
  ),
  ItemInventario(
    nome: "Medidor de estabilidade da membrana",
    categoria: "II",
    espaco: 1.0,
    descricao:
        "Item Paranormal. Dispositivo que afere o quão fina está a realidade local.",
  ),
  ItemInventario(
    nome: "Scanner de manifestação paranormal de (elemento)",
    categoria: "II",
    espaco: 1.0,
    descricao:
        "Item Paranormal. Rastreia rastros específicos da entidade selecionada.",
  ),
  ItemInventario(
    nome: "Catalisador ritualístico",
    categoria: "I",
    espaco: 0.5,
    descricao:
        "Item Paranormal. Consumido no uso. Ampliador (+Alcance/Área), Perturbador (+2 DT), Potencializador (+1 Dado de Dano) ou Prolongador (Dobra Duração).",
  ),
  ItemInventario(
    nome: "Ligação Direta Infernal",
    categoria: "II",
    espaco: 1.0,
    descricao:
        "Item Paranormal. Ação completa para ligar veículo: ele recebe RD 20 e imunidade a Sangue, e você recebe +5 em Pilotagem. Falhas em Pilotagem são amplificadas (consequências dobradas).",
  ),
  ItemInventario(
    nome: "Medidor de Condição Vertebral",
    categoria: "II",
    espaco: 1.0,
    descricao:
        "Item Paranormal. Ação completa para conectar (atordoa por 1 rodada). Conta como vestimenta (+2 Fortitude). Cores indicam sua saúde. Emite luz lilás sob efeito paranormal. Fornece +5 em Medicina para quem curar o usuário.",
  ),
  ItemInventario(
    nome: "Pé de Morto",
    categoria: "II",
    espaco: 1.0,
    descricao:
        "Item Paranormal. Botas macabras. Fornece +5 em Furtividade. Em cenas de furtividade, ação chamativa apenas de movimento (correr/saltar) aumenta visibilidade em apenas +1.",
  ),
  ItemInventario(
    nome: "Pendrive selado",
    categoria: "II",
    espaco: 0.5,
    descricao:
        "Item Paranormal. Protegido com sigilos de Conhecimento. Não pode ser invadido ou afetado por rituais de Energia. Permite hackear sem ser contaminado.",
  ),
  ItemInventario(
    nome: "Valete da Salvação",
    categoria: "I",
    espaco: 0.5,
    descricao:
        "Item Paranormal. Ação padrão para atirar ao ar. Voa apontando a melhor rota de fuga em alcance médio e desaparece. Em cena de perseguição, garante sucesso em 'cortar caminho'.",
  ),
];

List<Arma> catalogoArmasOrdem = [
  // --- ARMAS SIMPLES ---
  Arma(
    nome: "Bastão",
    categoria: "0",
    dano: "1d6/1d8",
    tipo: "Corpo a Corpo",
    espaco: 1,
    proficiencia: "Simples",
    empunhadura: "Uma Mão",
    descricao: "Um cilindro de madeira maciça. Você pode empunhar com as duas mãos para causar 1d8 de dano.", 
  ),
  Arma(
    nome: "Cajado",
    categoria: "0",
    dano: "1d6/1d6",
    tipo: "Corpo a Corpo",
    espaco: 2,
    proficiencia: "Simples",
    empunhadura: "Duas Mãos",
    descricao: "Haste longa. Arma ágil. Pode ser usada com Combater com Duas Armas para fazer ataques adicionais.",
  ),
  Arma(
    nome: "Faca",
    categoria: "0",
    dano: "1d4",
    margemAmeaca: 19,
    tipo: "Corpo a Corpo",
    espaco: 1,
    proficiencia: "Simples",
    empunhadura: "Leve",
    descricao: "Lâmina afiada. É uma arma ágil e pode ser arremessada.",
  ),
  Arma(
    nome: "Lança",
    categoria: "0",
    dano: "1d6",
    tipo: "Corpo a Corpo",
    espaco: 2,
    proficiencia: "Simples",
    empunhadura: "Uma Mão",
    descricao: "Haste de madeira com ponta metálica. Pode ser arremessada.",
  ),
  Arma(
    nome: "Machadinha",
    categoria: "0",
    dano: "1d6",
    multiplicadorCritico: 3,
    tipo: "Corpo a Corpo",
    espaco: 1,
    proficiencia: "Simples",
    empunhadura: "Uma Mão",
    descricao: "Ferramenta útil para cortar madeira. Pode ser arremessada.",
  ),
  Arma(
    nome: "Martelo",
    categoria: "0",
    dano: "1d6",
    tipo: "Corpo a Corpo",
    espaco: 1,
    proficiencia: "Simples",
    empunhadura: "Uma Mão",
    descricao: "Esta ferramenta comum pode ser usada como arma na falta de opções melhores.",
  ),
  Arma(
    nome: "Picareta",
    categoria: "0",
    dano: "1d6",
    multiplicadorCritico: 4,
    tipo: "Corpo a Corpo",
    espaco: 1,
    proficiencia: "Simples",
    empunhadura: "Uma Mão",
    descricao: "Ferramenta de mineração empregada em combate na falta de armas apropriadas.",
  ),
  Arma(
    nome: "Punhal",
    categoria: "0",
    dano: "1d4",
    multiplicadorCritico: 3,
    tipo: "Corpo a Corpo",
    espaco: 1,
    proficiencia: "Simples",
    empunhadura: "Leve",
    descricao: "Faca de lâmina longa e pontiaguda, muito usada por cultistas. Arma ágil.",
  ),
  Arma(
    nome: "Arco",
    categoria: "0",
    dano: "1d6",
    multiplicadorCritico: 3,
    tipo: "Disparo",
    espaco: 2,
    proficiencia: "Simples",
    empunhadura: "Duas Mãos",
    descricao: "Arco e flecha comum, próprio para tiro ao alvo.",
  ),
  Arma(
    nome: "Besta",
    categoria: "0",
    dano: "1d8",
    margemAmeaca: 19,
    tipo: "Disparo",
    espaco: 2,
    proficiencia: "Simples",
    empunhadura: "Duas Mãos",
    descricao: "Arma da antiguidade. Exige uma ação de movimento para ser recarregada a cada disparo.",
  ),
  Arma(
    nome: "Estilingue",
    categoria: "0",
    dano: "1d4",
    tipo: "Disparo",
    espaco: 1,
    proficiencia: "Simples",
    empunhadura: "Uma Mão",
    descricao: "Permite aplicar Força nas rolagens de dano. Pode lançar granadas em alcance longo.",
  ),
  Arma(
    nome: "Revólver",
    categoria: "I",
    dano: "2d6",
    margemAmeaca: 19,
    multiplicadorCritico: 3,
    tipo: "Fogo",
    espaco: 1,
    proficiencia: "Simples",
    empunhadura: "Uma Mão",
    descricao: "A arma de fogo mais comum, e uma das mais confiáveis.",
  ),
  Arma(
    nome: "Revólver Compacto",
    categoria: "I",
    dano: "2d4",
    margemAmeaca: 19,
    multiplicadorCritico: 3,
    tipo: "Fogo",
    espaco: 1,
    proficiencia: "Simples",
    empunhadura: "Leve",
    descricao: "Arma de baixo calibre projetada para ser escondida. Com treino em Crime, ocupa 0 espaço.",
  ),

  // --- ARMAS TÁTICAS ---
  Arma(
    nome: "Bastão Policial",
    categoria: "I",
    dano: "1d6",
    tipo: "Corpo a Corpo",
    espaco: 1,
    proficiencia: "Táticas",
    empunhadura: "Uma Mão",
    descricao: "Arma ágil. Ao usar a ação Esquiva com ele, o bônus na Defesa aumenta em +1.",
  ),
  Arma(
    nome: "Corrente",
    categoria: "0",
    dano: "1d8",
    tipo: "Corpo a Corpo",
    espaco: 1,
    proficiencia: "Táticas",
    empunhadura: "Duas Mãos",
    descricao: "Fornece +2 em testes para desarmar e derrubar.",
  ),
  Arma(
    nome: "Espada",
    categoria: "I",
    dano: "1d8/1d10",
    margemAmeaca: 19,
    tipo: "Corpo a Corpo",
    espaco: 1,
    proficiencia: "Táticas",
    empunhadura: "Uma Mão",
    descricao: "Pode empunhar com as duas mãos para causar 1d10 de dano.",
  ),
  Arma(
    nome: "Faca Tática",
    categoria: "I",
    dano: "1d6",
    margemAmeaca: 19,
    tipo: "Corpo a Corpo",
    espaco: 1,
    proficiencia: "Táticas",
    empunhadura: "Leve",
    descricao: "Arma ágil. Se usada para contra-atacar, dá +2 no ataque. No bloqueio, gaste 2 PE e sacrifique a faca para aumentar a RD em +20. Pode ser arremessada.",
  ),
  Arma(
    nome: "Florete",
    categoria: "I",
    dano: "1d6",
    margemAmeaca: 18,
    tipo: "Corpo a Corpo",
    espaco: 1,
    proficiencia: "Táticas",
    empunhadura: "Uma Mão",
    descricao: "Espada de lâmina fina usada por esgrimistas. É uma arma ágil.",
  ),
  Arma(
    nome: "Gancho de Carne",
    categoria: "0",
    dano: "1d4",
    multiplicadorCritico: 4,
    tipo: "Corpo a Corpo",
    espaco: 1,
    proficiencia: "Táticas",
    empunhadura: "Uma Mão",
    descricao: "Pode ser amarrado a uma corda/corrente, aumentando o alcance para 4,5m e passando a ocupar 2 espaços.",
  ),
  Arma(
    nome: "Machete",
    categoria: "0",
    dano: "1d6",
    margemAmeaca: 19,
    tipo: "Corpo a Corpo",
    espaco: 1,
    proficiencia: "Táticas",
    empunhadura: "Uma Mão",
    descricao: "Lâmina longa muito usada como ferramenta para abrir trilhas.",
  ),
  Arma(
    nome: "Nunchaku",
    categoria: "0",
    dano: "1d8",
    tipo: "Corpo a Corpo",
    espaco: 1,
    proficiencia: "Táticas",
    empunhadura: "Uma Mão",
    descricao: "Dois bastões ligados por uma corrente. É uma arma ágil.",
  ),
  Arma(
    nome: "Acha",
    categoria: "I",
    dano: "1d12",
    multiplicadorCritico: 3,
    tipo: "Corpo a Corpo",
    espaco: 2,
    proficiencia: "Táticas",
    empunhadura: "Duas Mãos",
    descricao: "Machado grande e pesado.",
  ),
  Arma(
    nome: "Gadanho",
    categoria: "I",
    dano: "2d4",
    multiplicadorCritico: 4,
    tipo: "Corpo a Corpo",
    espaco: 2,
    proficiencia: "Táticas",
    empunhadura: "Duas Mãos",
    descricao: "Ferramenta agrícola letal.",
  ),
  Arma(
    nome: "Katana",
    categoria: "I",
    dano: "1d10",
    margemAmeaca: 19,
    tipo: "Corpo a Corpo",
    espaco: 2,
    proficiencia: "Táticas",
    empunhadura: "Duas Mãos",
    descricao: "Arma ágil. Veteranos em Luta podem usá-la como arma de uma mão.",
  ),
  Arma(
    nome: "Marreta",
    categoria: "I",
    dano: "3d4",
    tipo: "Corpo a Corpo",
    espaco: 2,
    proficiencia: "Táticas",
    empunhadura: "Duas Mãos",
    descricao: "Normalmente usada para demolir paredes, ou pessoas.",
  ),
  Arma(
    nome: "Montante",
    categoria: "I",
    dano: "2d6",
    margemAmeaca: 19,
    tipo: "Corpo a Corpo",
    espaco: 2,
    proficiencia: "Táticas",
    empunhadura: "Duas Mãos",
    descricao: "Enorme e pesada espada de 1,5m.",
  ),
  Arma(
    nome: "Motosserra",
    categoria: "I",
    dano: "3d6",
    tipo: "Corpo a Corpo",
    espaco: 2,
    proficiencia: "Táticas",
    empunhadura: "Duas Mãos",
    descricao: "Sempre que rolar um 6 no dano, role um dado adicional. Impõe –1d20 no ataque. Ligar exige ação de movimento.",
  ),
  Arma(
    nome: "Arco Composto",
    categoria: "I",
    dano: "1d10",
    multiplicadorCritico: 3,
    tipo: "Disparo",
    espaco: 2,
    proficiencia: "Táticas",
    empunhadura: "Duas Mãos",
    descricao: "Permite aplicar o valor de Força às rolagens de dano.",
  ),
  Arma(
    nome: "Balestra",
    categoria: "I",
    dano: "1d12",
    margemAmeaca: 19,
    tipo: "Disparo",
    espaco: 2,
    proficiencia: "Táticas",
    empunhadura: "Duas Mãos",
    descricao: "Besta pesada. Exige ação de movimento para recarregar.",
  ),
  Arma(
    nome: "Shuriken",
    categoria: "I",
    dano: "1d4",
    tipo: "Disparo",
    espaco: 0.5,
    proficiencia: "Táticas",
    empunhadura: "Leve",
    descricao: "Veteranos em Pontaria podem gastar 1 PE para fazer um ataque adicional no mesmo alvo. Ocupa 1 espaço por pacote.",
  ),
  Arma(
    nome: "Pistola",
    categoria: "I",
    dano: "1d12",
    margemAmeaca: 18,
    tipo: "Fogo",
    espaco: 1,
    proficiencia: "Simples",
    empunhadura: "Uma Mão",
    descricao: "Arma comum e facilmente recarregável.",
  ),
  Arma(
    nome: "Pistola Pesada",
    categoria: "I",
    dano: "2d8",
    margemAmeaca: 18,
    tipo: "Fogo",
    espaco: 1,
    proficiencia: "Táticas",
    empunhadura: "Uma Mão",
    descricao: "Impõe –1d20 no ataque. Empunhá-la com as duas mãos anula a penalidade.",
  ),
  Arma(
    nome: "Submetralhadora",
    categoria: "I",
    dano: "2d6",
    margemAmeaca: 19,
    multiplicadorCritico: 3,
    tipo: "Fogo",
    espaco: 1,
    proficiencia: "Táticas",
    empunhadura: "Uma Mão",
    descricao: "Arma de fogo automática.",
  ),
  Arma(
    nome: "Espingarda",
    categoria: "I",
    dano: "4d6",
    multiplicadorCritico: 3,
    tipo: "Fogo",
    espaco: 2,
    proficiencia: "Táticas",
    empunhadura: "Duas Mãos",
    descricao: "Causa apenas metade do dano em alcance médio ou maior.",
  ),
  Arma(
    nome: "Espingarda de Cano Duplo",
    categoria: "II",
    dano: "4d6",
    multiplicadorCritico: 3,
    tipo: "Fogo",
    espaco: 2,
    proficiencia: "Táticas",
    empunhadura: "Duas Mãos",
    descricao: "Exige movimento para recarregar. Pode disparar os dois canos juntos (–1d20 no ataque, mas o dano sobe para 6d6).",
  ),
  Arma(
    nome: "Fuzil de Assalto",
    categoria: "II",
    dano: "2d10",
    margemAmeaca: 19,
    multiplicadorCritico: 3,
    tipo: "Fogo",
    espaco: 2,
    proficiencia: "Táticas",
    empunhadura: "Duas Mãos",
    descricao: "Arma automática padrão de exércitos.",
  ),
  Arma(
    nome: "Fuzil de Caça",
    categoria: "I",
    dano: "2d8",
    margemAmeaca: 19,
    multiplicadorCritico: 3,
    tipo: "Fogo",
    espaco: 2,
    proficiencia: "Táticas",
    empunhadura: "Duas Mãos",
    descricao: "Arma longa popular entre caçadores.",
  ),
  Arma(
    nome: "Fuzil de Precisão",
    categoria: "III",
    dano: "2d10",
    margemAmeaca: 19,
    multiplicadorCritico: 3,
    tipo: "Fogo",
    espaco: 2,
    proficiencia: "Táticas",
    empunhadura: "Duas Mãos",
    descricao: "Veteranos em Pontaria que usarem a ação Mirar recebem +5 na margem de ameaça.",
  ),

  // --- ARMAS PESADAS ---
  Arma(
    nome: "Bazuca",
    categoria: "III",
    dano: "10d8",
    tipo: "Fogo",
    espaco: 2,
    proficiencia: "Pesadas",
    empunhadura: "Duas Mãos",
    descricao: "Raio de 3m. Alvos na área (menos o atingido diretamente) fazem Reflexos DT Agi para reduzir o dano à metade. Exige movimento para recarregar.",
  ),
  Arma(
    nome: "Lança-chamas",
    categoria: "III",
    dano: "6d6",
    tipo: "Fogo",
    espaco: 2,
    proficiencia: "Pesadas",
    empunhadura: "Duas Mãos",
    descricao: "Linha de 1,5m em alcance curto. Faça um único teste contra a Defesa de todos na área. Seres atingidos ficam em chamas.",
  ),
  Arma(
    nome: "Metralhadora",
    categoria: "II",
    dano: "2d12",
    margemAmeaca: 19,
    multiplicadorCritico: 3,
    tipo: "Fogo",
    espaco: 2,
    proficiencia: "Pesadas",
    empunhadura: "Duas Mãos",
    descricao: "Arma automática. Exige Força 4+ ou ação de movimento para apoiar no tripé (se não, sofre –5 no ataque).",
  ),
];