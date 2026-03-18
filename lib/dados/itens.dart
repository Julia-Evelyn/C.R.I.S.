import '../modelos/agente_dados.dart';

final List<ItemInventario> catalogoItensOrdem = [
  // Acessórios
  ItemInventario(nome: "Amuleto Sagrado", categoria: "I", espaco: 1.0, descricao: "Acessório. Um utensílio especial na forma de shimenawa, rosário ou qualquer objeto que reforce sua fé. Fornece +2 em Religião e Vontade."),
  ItemInventario(nome: "Celular", categoria: "0", espaco: 1.0, descricao: "Acessório. Se tiver acesso a internet, fornece +2 em testes para adquirir informações. Ilumina em um cone de 4,5m."),
  ItemInventario(nome: "Chave de Fenda Universal", categoria: "0", espaco: 1.0, descricao: "Acessório. Fornece +2 em testes de perícia para criar ou reparar objetos."),
  ItemInventario(nome: "Chaves", categoria: "0", espaco: 1.0, descricao: "Acessório. Usar o barulho de um molho de chaves para distrair alguém fornece +2 em Furtividade na mesma rodada."),
  ItemInventario(nome: "Documentos Falsos", categoria: "I", espaco: 0.0, descricao: "Acessório. Fornece +2 em testes de Diplomacia, Enganação e Intimidação para se passar pela identidade falsa."),
  ItemInventario(nome: "Manual Operacional", categoria: "I", espaco: 1.0, descricao: "Acessório. Gastar uma ação de interlúdio lendo um manual permite que você use essa perícia como se fosse treinado nela."),
  ItemInventario(nome: "Notebook", categoria: "I", espaco: 2.0, descricao: "Acessório. Fornece +2 em testes para adquirir informações. Ao relaxar em cenas de interlúdio, você recupera 1 ponto adicional de Sanidade."),
  ItemInventario(nome: "Kit de Perícia", categoria: "I", espaco: 1.0, descricao: "Acessório. Conjunto de ferramentas necessárias para algumas perícias. Sem o kit, você sofre –5 no teste."),
  ItemInventario(nome: "Utensílio", categoria: "I", espaco: 1.0, descricao: "Acessório. Um item comum que tenha uma utilidade específica. Fornece +2 em uma perícia."),
  ItemInventario(nome: "Vestimenta", categoria: "I", espaco: 1.0, descricao: "Acessório. Peça de vestuário que fornece +2 em uma perícia. Vestir ou despir uma vestimenta é uma ação completa."),
  
  // Explosivos
  ItemInventario(nome: "Granada de Atordoamento", categoria: "I", espaco: 1.0, descricao: "Explosivo. Flash-bang que cria um estouro barulhento e luminoso (raio 6m em alcance médio). Seres na área ficam atordoados por 1 rodada (Fortitude DT Agi reduz para ofuscado e surdo)."),
  ItemInventario(nome: "Granada de Fragmentação", categoria: "I", espaco: 1.0, descricao: "Explosivo. Espalha fragmentos perfurantes (raio 6m em alcance médio). Seres na área sofrem 8d6 de dano de perfuração (Reflexos DT Agi reduz à metade)."),
  ItemInventario(nome: "Granada de Fumaça", categoria: "I", espaco: 1.0, descricao: "Explosivo. Produz uma fumaça espessa (raio 6m em alcance médio). Seres na área ficam cegos e sob camuflagem total por 2 rodadas."),
  ItemInventario(nome: "Granada Incendiária", categoria: "I", espaco: 1.0, descricao: "Explosivo. Espalha labaredas (raio 6m em alcance médio). Causa 6d6 de dano de fogo e deixa em chamas (Reflexos DT Agi reduz à metade e evita a condição)."),
  ItemInventario(nome: "Mina Antipessoal", categoria: "II", espaco: 1.0, descricao: "Explosivo. Ativada por controle remoto (até alcance longo). Dispara bolas de aço em cone de 6m, causando 12d6 de dano de perfuração (Reflexos DT Int reduz à metade). Instalar exige ação completa e teste de Tática DT 15."),
  ItemInventario(nome: "Dinamite", categoria: "I", espaco: 1.0, descricao: "Explosivo. Arremessada em alcance médio (raio 6m). Causa 4d6 de dano de impacto e 4d6 de fogo, e deixa em chamas (Reflexos DT Agi reduz à metade e evita condição)."),
  ItemInventario(nome: "Explosivo Plástico", categoria: "II", espaco: 1.0, descricao: "Explosivo. Exige 2 rodadas para grudar. Detonado remotamente ou por dano de fogo/eletricidade. Causa 16d6 de impacto em raio de 3m (Reflexos DT Int reduz à metade). Especialistas causam o dobro de dano em estruturas e ignoram RD."),
  ItemInventario(nome: "Galão Vermelho", categoria: "I", espaco: 2.0, descricao: "Explosivo. Ao sofrer dano de fogo ou balístico, explode atingindo um raio de 6m. Causa 12d6 de dano de fogo e deixa em chamas (Reflexos DT 25 reduz à metade e evita). A área afetada fica em chamas."),
  ItemInventario(nome: "Granada de Gás Sonífero", categoria: "II", espaco: 1.0, descricao: "Explosivo. Libera gás (raio 6m). Seres que iniciam o turno na área ficam inconscientes/caídos ou exaustos (se em atividade física intensa). Fortitude DT Agi reduz para fatigado. O gás permanece por 2 rodadas."),
  ItemInventario(nome: "Granada de PEM", categoria: "II", espaco: 1.0, descricao: "Explosivo. Pulso eletromagnético desativa equipamentos elétricos (raio 18m) até o fim da cena. Criaturas de Energia sofrem 6d6 de impacto e ficam paralisadas por 1 rodada (Fortitude DT Agi reduz à metade e evita)."),

  // Proteções
  ItemInventario(nome: "Proteção Leve", categoria: "I", espaco: 2.0, descricao: "Proteção. Jaqueta de couro pesada ou colete de kevlar. Fornece Defesa +5."),
  ItemInventario(nome: "Proteção Pesada", categoria: "II", espaco: 5.0, descricao: "Proteção. Equipamento usado por forças especiais. Fornece Defesa +10 e Resistência a balístico, corte, impacto e perfuração 2. Impõe –5 em testes de perícias com penalidade de carga."),
  ItemInventario(nome: "Escudo", categoria: "I", espaco: 2.0, descricao: "Proteção. Precisa ser empunhado em uma mão e fornece Defesa +2 (acumula com a de uma proteção). Conta como proteção pesada para efeitos de proficiência."),

  // Munições
  ItemInventario(nome: "Balas curtas", categoria: "0", espaco: 1.0, descricao: "Munição"),
  ItemInventario(nome: "Balas longas", categoria: "I", espaco: 1.0, descricao: "Munição"),
  ItemInventario(nome: "Cartuchos", categoria: "I", espaco: 1.0, descricao: "Munição"),
  ItemInventario(nome: "Combustível", categoria: "I", espaco: 1.0, descricao: "Munição"),
  ItemInventario(nome: "Flechas", categoria: "0", espaco: 1.0, descricao: "Munição"),
  ItemInventario(nome: "Foguete", categoria: "I", espaco: 1.0, descricao: "Munição"),
  ItemInventario(nome: "Flechas", categoria: "0", espaco: 1.0, descricao: "Munição para arcos e balestras."),

  // Itens Operacionais
  ItemInventario(nome: "Algemas", categoria: "I", espaco: 1.0, descricao: "Item Operacional. Par de algemas de aço. Para prender um alvo não indefeso, vença um teste de Manobra de Combate (Agarrar). Prender dois pulsos impõe –5 em testes com as mãos e impede conjuração. Escapar exige Acrobacia DT 30."),
  ItemInventario(nome: "Arpéu", categoria: "I", espaco: 1.0, descricao: "Item Operacional. Gancho de aço. Prender exige Pontaria DT 15. Subir um muro com a ajuda de uma corda fornece +5 em Atletismo."),
  ItemInventario(nome: "Binóculos", categoria: "I", espaco: 1.0, descricao: "Item Operacional. Binóculos militares. Fornece +5 em testes de Percepção para observar coisas distantes."),
  ItemInventario(nome: "Bloqueador de Sinal", categoria: "II", espaco: 1.0, descricao: "Item Operacional. Emite ondas que 'poluem' a frequência de rádio, impedindo qualquer aparelho (celulares, etc) em alcance médio de se conectar."),
  ItemInventario(nome: "Cicatrizante", categoria: "I", espaco: 1.0, descricao: "Item Operacional. Spray médico. Com uma ação padrão, cura 2d8+2 PV em você ou em um ser adjacente. É consumido após o uso."),
  ItemInventario(nome: "Corda", categoria: "0", espaco: 1.0, descricao: "Item Operacional. Rolo com 10 metros de corda resistente. Fornece +5 em Atletismo para descer buracos ou prédios."),
  ItemInventario(nome: "Equipamento de Sobrevivência", categoria: "I", espaco: 2.0, descricao: "Item Operacional. Mochila com saco de dormir, GPS e itens úteis. Fornece +5 em Sobrevivência para acampar e orientar-se (permite o uso sem treinamento)."),
  ItemInventario(nome: "Lanterna Tática", categoria: "I", espaco: 1.0, descricao: "Item Operacional. Ilumina um cone de 9m. Como ação de movimento, você pode ofuscar um ser em alcance curto por 1 rodada (ele fica imune pelo resto da cena)."),
  ItemInventario(nome: "Máscara de Gás", categoria: "I", espaco: 1.0, descricao: "Item Operacional. Fornece +10 em testes de Fortitude contra efeitos que dependam de respiração."),
  ItemInventario(nome: "Óculos de Visão Térmica", categoria: "II", espaco: 1.0, descricao: "Item Operacional. Elimina a penalidade em testes de ataque e percepção causados por camuflagem."),
  ItemInventario(nome: "Pé de Cabra", categoria: "0", espaco: 1.0, descricao: "Item Operacional. Fornece +5 em testes de Força para arrombar portas. Pode ser usada em combate como arma leve (bastão)."),
  ItemInventario(nome: "Pistola de Dardos", categoria: "II", espaco: 1.0, descricao: "Item Operacional. Arma leve (alcance curto) com sonífero. Acerto causa inconsciência até o fim da cena (Fortitude DT Agi reduz para desprevenido e lento por 1 rodada). Vem com 2 dardos."),
  ItemInventario(nome: "Pistola Sinalizadora", categoria: "I", espaco: 1.0, descricao: "Item Operacional. Arma de disparo leve (alcance curto). Chama a atenção para sua localização ou causa 2d6 de dano de fogo. Vem com 2 cargas."),
  ItemInventario(nome: "Soqueira", categoria: "I", espaco: 1.0, descricao: "Item Operacional. Fornece +1 em rolagens de dano desarmado e os torna letais. Pode receber modificações de armas corpo a corpo."),
  ItemInventario(nome: "Spray de Pimenta", categoria: "I", espaco: 1.0, descricao: "Item Operacional. Ação padrão contra alvo adjacente: deixa cego por 1d4 rodadas (Fortitude DT Agi evita). Possui 2 usos."),
  ItemInventario(nome: "Taser", categoria: "I", espaco: 1.0, descricao: "Item Operacional. Ação padrão contra alvo adjacente: 1d6 de eletricidade e atordoado por 1 rodada (Fortitude DT Agi evita). Possui 2 usos."),
  ItemInventario(nome: "Traje Hazmat", categoria: "II", espaco: 2.0, descricao: "Item Operacional. Fornece +5 em testes contra efeitos ambientais e Resistência a Químico 10. Ocupa espaço de vestimenta."),
  ItemInventario(nome: "Alarme de Movimento", categoria: "I", espaco: 1.0, descricao: "Item Operacional. Ação completa para ativar. Avisa no dispositivo quando há movimento em cone de 30m. Pode ser discreto ou acionar sirene."),
  ItemInventario(nome: "Alimento Energético", categoria: "0", espaco: 0.5, descricao: "Item Operacional. Suplemento tático. Ação padrão para consumir: recupera 1d4 PE."),
  ItemInventario(nome: "Aplicador de Medicamentos", categoria: "I", espaco: 1.0, descricao: "Item Operacional. Preso ao braço/perna. Permite aplicar uma substância carregada (como cicatrizante) com uma Ação de Movimento. Comporta 3 doses."),
  ItemInventario(nome: "Braçadeira Reforçada", categoria: "I", espaco: 1.0, descricao: "Item Operacional. Aumenta em +2 a RD que você recebe por usar a reação de Bloqueio."),
  ItemInventario(nome: "Cão Adestrado", categoria: "II", espaco: 0.0, descricao: "Item Operacional. Um parceiro animal. Pode ser usado como aliado se você for treinado em Adestramento."),
  ItemInventario(nome: "Coldre Saque Rápido", categoria: "I", espaco: 1.0, descricao: "Item Operacional. Uma vez por rodada, permite sacar ou guardar uma arma de fogo leve como Ação Livre."),
  ItemInventario(nome: "Equipamento de Escuta", categoria: "II", espaco: 1.0, descricao: "Item Operacional. Um receptor (alcance 90m) e três transmissores (captação 9m). Instalar exige Crime DT 20. Furtividade oposta se for feito em público."),
  ItemInventario(nome: "Estrepes", categoria: "I", espaco: 1.0, descricao: "Item Operacional. Ação padrão para cobrir 1,5m. Quem pisa sofre 1d4 de perfuração e fica lento por um dia (Reflexos DT Agi evita)."),
  ItemInventario(nome: "Faixa de Pregos", categoria: "II", espaco: 2.0, descricao: "Item Operacional. Ocupa uma linha de 9m. Funciona como Estrepes, mas fura pneus de veículos (deslocamento cai pela metade)."),
  ItemInventario(nome: "Isqueiro", categoria: "0", espaco: 0.5, descricao: "Item Operacional. Ação de movimento para acender. Incendeia objetos inflamáveis e ilumina raio de 3m."),
  ItemInventario(nome: "Óculos Escuros", categoria: "0", espaco: 0.5, descricao: "Item Operacional. Impede que o usuário fique com a condição ofuscado."),
  ItemInventario(nome: "Óculos de Visão Noturna", categoria: "II", espaco: 1.0, descricao: "Item Operacional. Fornece visão no escuro. Impõe –1d20 em testes de resistência contra efeitos baseados em luz (como granada de atordoamento)."),
  ItemInventario(nome: "Pá", categoria: "0", espaco: 2.0, descricao: "Item Operacional. Fornece +5 em testes de Força para cavar buracos ou mover detritos. Pode ser usada em combate como arma."),
  ItemInventario(nome: "Paraquedas", categoria: "II", espaco: 2.0, descricao: "Item Operacional. Anula dano de queda. Exige Acrobacia, Pilotagem, Reflexos ou Tática Veterano (ou teste Reflexos DT 20 para abrir com sucesso)."),
  ItemInventario(nome: "Traje de Mergulho", categoria: "II", espaco: 2.0, descricao: "Item Operacional. Garante 1 hora de oxigênio submerso. Fornece +5 contra efeitos ambientais e Resistência a Químico 5. Ação completa para vestir."),
  ItemInventario(nome: "Traje Espacial", categoria: "IV", espaco: 5.0, descricao: "Item Operacional. Fornece 8 horas de oxigênio. +10 contra efeitos ambientais e Resistência a Químico 20. Demora 2 rodadas para vestir."),

  // Itens Paranormais
  ItemInventario(nome: "Amarras de (elemento)", categoria: "II", espaco: 1.0, descricao: "Item Paranormal. Cordas ou correntes imbuídas com energia da entidade."),
  ItemInventario(nome: "Câmera de aura paranormal", categoria: "II", espaco: 1.0, descricao: "Item Paranormal. Capaz de registrar espectros invisíveis a olho nu."),
  ItemInventario(nome: "Componentes ritualísticos de (elemento)", categoria: "0", espaco: 1.0, descricao: "Item Paranormal. Materiais associados à entidade, usados para conjurar rituais sem penalidade."),
  ItemInventario(nome: "Emissor de pulsos paranormais", categoria: "II", espaco: 1.0, descricao: "Item Paranormal. Interfere em frequências da membrana no ambiente."),
  ItemInventario(nome: "Escuta de ruídos paranormais", categoria: "II", espaco: 1.0, descricao: "Item Paranormal. Capta sussurros e ecos do Outro Lado."),
  ItemInventario(nome: "Medidor de estabilidade da membrana", categoria: "II", espaco: 1.0, descricao: "Item Paranormal. Dispositivo que afere o quão fina está a realidade local."),
  ItemInventario(nome: "Scanner de manifestação paranormal de (elemento)", categoria: "II", espaco: 1.0, descricao: "Item Paranormal. Rastreia rastros específicos da entidade selecionada."),
  ItemInventario(nome: "Catalisador ritualístico", categoria: "I", espaco: 0.5, descricao: "Item Paranormal. Consumido no uso. Ampliador (+Alcance/Área), Perturbador (+2 DT), Potencializador (+1 Dado de Dano) ou Prolongador (Dobra Duração)."),
  ItemInventario(nome: "Ligação Direta Infernal", categoria: "II", espaco: 1.0, descricao: "Item Paranormal. Ação completa para ligar veículo: ele recebe RD 20 e imunidade a Sangue, e você recebe +5 em Pilotagem. Falhas em Pilotagem são amplificadas (consequências dobradas)."),
  ItemInventario(nome: "Medidor de Condição Vertebral", categoria: "II", espaco: 1.0, descricao: "Item Paranormal. Ação completa para conectar (atordoa por 1 rodada). Conta como vestimenta (+2 Fortitude). Cores indicam sua saúde. Emite luz lilás sob efeito paranormal. Fornece +5 em Medicina para quem curar o usuário."),
  ItemInventario(nome: "Pé de Morto", categoria: "II", espaco: 1.0, descricao: "Item Paranormal. Botas macabras. Fornece +5 em Furtividade. Em cenas de furtividade, ação chamativa apenas de movimento (correr/saltar) aumenta visibilidade em apenas +1."),
  ItemInventario(nome: "Pendrive selado", categoria: "II", espaco: 0.5, descricao: "Item Paranormal. Protegido com sigilos de Conhecimento. Não pode ser invadido ou afetado por rituais de Energia. Permite hackear sem ser contaminado."),
  ItemInventario(nome: "Valete da Salvação", categoria: "I", espaco: 0.5, descricao: "Item Paranormal. Ação padrão para atirar ao ar. Voa apontando a melhor rota de fuga em alcance médio e desaparece. Em cena de perseguição, garante sucesso em 'cortar caminho'."),
];

final List<Arma> catalogoArmasOrdem = [
  // Simples - Corpo a Corpo
  Arma(nome: "Coronhada", dano: "1d4/1d6", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 2, categoria: "0", espaco: 0.0, proficiencia: "Simples", empunhadura: "Leve"),
  Arma(nome: "Faca", dano: "1d4", tipo: "Corpo a Corpo", margemAmeaca: 19, multiplicadorCritico: 2, categoria: "0", espaco: 1.0, proficiencia: "Simples", empunhadura: "Leve"),
  Arma(nome: "Martelo", dano: "1d6", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 2, categoria: "0", espaco: 1.0, proficiencia: "Simples", empunhadura: "Leve"),
  Arma(nome: "Punhal", dano: "1d4", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 3, categoria: "0", espaco: 1.0, proficiencia: "Simples", empunhadura: "Leve"),
  Arma(nome: "Bastão", dano: "1d6/1d8", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 2, categoria: "0", espaco: 1.0, proficiencia: "Simples", empunhadura: "Uma Mão"),
  Arma(nome: "Machete", dano: "1d6", tipo: "Corpo a Corpo", margemAmeaca: 19, multiplicadorCritico: 2, categoria: "0", espaco: 1.0, proficiencia: "Simples", empunhadura: "Uma Mão"),
  Arma(nome: "Lança", dano: "1d6", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 2, categoria: "0", espaco: 1.0, proficiencia: "Simples", empunhadura: "Uma Mão"),
  Arma(nome: "Cajado", dano: "1d6/1d6", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 2, categoria: "0", espaco: 2.0, proficiencia: "Simples", empunhadura: "Duas Mãos"),
  
  // Simples - Distância
  Arma(nome: "Arco", dano: "1d6", tipo: "Disparo", margemAmeaca: 20, multiplicadorCritico: 3, categoria: "0", espaco: 2.0, proficiencia: "Simples", empunhadura: "Duas Mãos"),
  Arma(nome: "Besta", dano: "1d8", tipo: "Disparo", margemAmeaca: 19, multiplicadorCritico: 2, categoria: "0", espaco: 2.0, proficiencia: "Simples", empunhadura: "Duas Mãos"),
  Arma(nome: "Estilingue", dano: "1d4", tipo: "Disparo", margemAmeaca: 20, multiplicadorCritico: 2, categoria: "0", espaco: 1.0, proficiencia: "Simples", empunhadura: "Duas Mãos"),
  Arma(nome: "Pregador pneumático", dano: "1d4", tipo: "Disparo", margemAmeaca: 20, multiplicadorCritico: 4, categoria: "0", espaco: 1.0, proficiencia: "Simples", empunhadura: "Uma Mão"),
  Arma(nome: "Pistola", dano: "1d12", tipo: "Fogo", margemAmeaca: 18, multiplicadorCritico: 2, categoria: "I", espaco: 1.0, proficiencia: "Simples", empunhadura: "Leve"),
  Arma(nome: "Revólver", dano: "2d6", tipo: "Fogo", margemAmeaca: 19, multiplicadorCritico: 3, categoria: "I", espaco: 1.0, proficiencia: "Simples", empunhadura: "Leve"),
  Arma(nome: "Revólver compacto", dano: "2d4", tipo: "Fogo", margemAmeaca: 19, multiplicadorCritico: 3, categoria: "I", espaco: 1.0, proficiencia: "Simples", empunhadura: "Leve"),
  Arma(nome: "Fuzil de caça", dano: "2d8", tipo: "Fogo", margemAmeaca: 19, multiplicadorCritico: 3, categoria: "I", espaco: 2.0, proficiencia: "Simples", empunhadura: "Duas Mãos"),
  
  // Táticas - Corpo a Corpo
  Arma(nome: "Machadinha", dano: "1d6", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 3, categoria: "0", espaco: 1.0, proficiencia: "Táticas", empunhadura: "Leve"),
  Arma(nome: "Nunchaku", dano: "1d8", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 2, categoria: "0", espaco: 1.0, proficiencia: "Táticas", empunhadura: "Leve"),
  Arma(nome: "Baioneta", dano: "1d4", tipo: "Corpo a Corpo", margemAmeaca: 19, multiplicadorCritico: 2, categoria: "0", espaco: 1.0, proficiencia: "Táticas", empunhadura: "Leve"),
  Arma(nome: "Faca tática", dano: "1d6", tipo: "Corpo a Corpo", margemAmeaca: 19, multiplicadorCritico: 2, categoria: "I", espaco: 1.0, proficiencia: "Táticas", empunhadura: "Leve"),
  Arma(nome: "Gancho de carne", dano: "1d4", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 4, categoria: "0", espaco: 1.0, proficiencia: "Táticas", empunhadura: "Leve"),
  Arma(nome: "Corrente", dano: "1d8", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 2, categoria: "0", espaco: 1.0, proficiencia: "Táticas", empunhadura: "Uma Mão"),
  Arma(nome: "Espada", dano: "1d8/1d10", tipo: "Corpo a Corpo", margemAmeaca: 19, multiplicadorCritico: 2, categoria: "I", espaco: 1.0, proficiencia: "Táticas", empunhadura: "Uma Mão"),
  Arma(nome: "Florete", dano: "1d6", tipo: "Corpo a Corpo", margemAmeaca: 18, multiplicadorCritico: 2, categoria: "I", espaco: 1.0, proficiencia: "Táticas", empunhadura: "Uma Mão"),
  Arma(nome: "Machado", dano: "1d8", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 3, categoria: "I", espaco: 1.0, proficiencia: "Táticas", empunhadura: "Uma Mão"),
  Arma(nome: "Maça", dano: "2d4", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 2, categoria: "I", espaco: 1.0, proficiencia: "Táticas", empunhadura: "Uma Mão"),
  Arma(nome: "Bastão policial", dano: "1d6", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 2, categoria: "I", espaco: 1.0, proficiencia: "Táticas", empunhadura: "Uma Mão"),
  Arma(nome: "Picareta", dano: "1d6", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 4, categoria: "0", espaco: 1.0, proficiencia: "Táticas", empunhadura: "Uma Mão"),
  
  // --- CORPO A CORPO (DUAS MÃOS) ---
  Arma(nome: "Acha", categoria: "I", dano: "1d12", margemAmeaca: 20, multiplicadorCritico: 3, tipo: "Corpo a Corpo", espaco: 2, proficiencia: "Táticas", empunhadura: "Duas Mãos"),
  Arma(nome: "Gadanho", categoria: "I", dano: "2d4", margemAmeaca: 20, multiplicadorCritico: 4, tipo: "Corpo a Corpo", espaco: 2, proficiencia: "Táticas", empunhadura: "Duas Mãos"),
  Arma(nome: "Katana", categoria: "I", dano: "1d10", margemAmeaca: 19, multiplicadorCritico: 2, tipo: "Corpo a Corpo", espaco: 2, proficiencia: "Táticas", empunhadura: "Duas Mãos"),
  Arma(nome: "Marreta", categoria: "I", dano: "3d4", margemAmeaca: 20, multiplicadorCritico: 2, tipo: "Corpo a Corpo", espaco: 2, proficiencia: "Táticas", empunhadura: "Duas Mãos"),
  Arma(nome: "Montante", categoria: "I", dano: "2d6", margemAmeaca: 19, multiplicadorCritico: 2, tipo: "Corpo a Corpo", espaco: 2, proficiencia: "Táticas", empunhadura: "Duas Mãos"),
  Arma(nome: "Motosserra", categoria: "I", dano: "3d6", margemAmeaca: 20, multiplicadorCritico: 2, tipo: "Corpo a Corpo", espaco: 2, proficiencia: "Táticas", empunhadura: "Duas Mãos"),

  // --- ARMAS DE DISPARO (DUAS MÃOS) ---
  Arma(nome: "Arco composto", categoria: "I", dano: "1d10", margemAmeaca: 20, multiplicadorCritico: 3, tipo: "Disparo", espaco: 2, proficiencia: "Táticas", empunhadura: "Duas Mãos"),
  Arma(nome: "Balestra", categoria: "I", dano: "1d12", margemAmeaca: 19, multiplicadorCritico: 2, tipo: "Disparo", espaco: 2, proficiencia: "Táticas", empunhadura: "Duas Mãos"),

  // --- ARMAS DE FOGO (UMA MÃO) ---
  Arma(nome: "Submetralhadora", categoria: "I", dano: "2d6", margemAmeaca: 19, multiplicadorCritico: 3, tipo: "Fogo", espaco: 1, proficiencia: "Táticas", empunhadura: "Uma Mão"),

  // --- ARMAS DE FOGO (DUAS MÃOS) ---
  Arma(nome: "Espingarda", categoria: "I", dano: "4d6", margemAmeaca: 20, multiplicadorCritico: 3, tipo: "Fogo", espaco: 2, proficiencia: "Táticas", empunhadura: "Duas Mãos"),
  Arma(nome: "Fuzil de assalto", categoria: "II", dano: "2d10", margemAmeaca: 19, multiplicadorCritico: 3, tipo: "Fogo", espaco: 2, proficiencia: "Táticas", empunhadura: "Duas Mãos"),
  Arma(nome: "Fuzil de precisão", categoria: "III", dano: "2d10", margemAmeaca: 19, multiplicadorCritico: 3, tipo: "Fogo", espaco: 2, proficiencia: "Táticas", empunhadura: "Duas Mãos"),

  // --- ARMAS PESADAS ---
  Arma(nome: "Bazuca", categoria: "III", dano: "10d8", margemAmeaca: 20, multiplicadorCritico: 2, tipo: "Fogo", espaco: 2, proficiencia: "Pesadas", empunhadura: "Duas Mãos"),
  Arma(nome: "Lança-chamas", categoria: "III", dano: "6d6", margemAmeaca: 20, multiplicadorCritico: 2, tipo: "Fogo", espaco: 2, proficiencia: "Pesadas", empunhadura: "Duas Mãos"),
  Arma(nome: "Metralhadora", categoria: "II", dano: "2d12", margemAmeaca: 19, multiplicadorCritico: 3, tipo: "Fogo", espaco: 2, proficiencia: "Pesadas", empunhadura: "Duas Mãos"),

  // Táticas - Arremesso e Fogo
  Arma(nome: "Shuriken", dano: "1d4", tipo: "Arremesso", margemAmeaca: 20, multiplicadorCritico: 2, categoria: "I", espaco: 0.5, proficiencia: "Táticas", empunhadura: "Leve"),
  Arma(nome: "Pistola pesada", dano: "2d8", tipo: "Fogo", margemAmeaca: 18, multiplicadorCritico: 2, categoria: "I", espaco: 1.0, proficiencia: "Táticas", empunhadura: "Uma Mão"),
  Arma(nome: "Espingarda de cano duplo", dano: "4d6", tipo: "Fogo", margemAmeaca: 20, multiplicadorCritico: 3, categoria: "II", espaco: 2.0, proficiencia: "Táticas", empunhadura: "Duas Mãos"),
];