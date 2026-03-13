import '../modelos/agente_dados.dart';

final List<ItemInventario> catalogoItensOrdem = [
  // Acessórios
  ItemInventario(nome: "Amuleto sagrado", categoria: "0", espaco: 1.0, descricao: "Acessório"),
  ItemInventario(nome: "Celular", categoria: "0", espaco: 1.0, descricao: "Acessório"),
  ItemInventario(nome: "Chave de fenda universal", categoria: "0", espaco: 1.0, descricao: "Acessório"),
  ItemInventario(nome: "Chaves", categoria: "0", espaco: 1.0, descricao: "Acessório"),
  ItemInventario(nome: "Documentos falsos", categoria: "I", espaco: 1.0, descricao: "Acessório"),
  ItemInventario(nome: "Kit de perícia", categoria: "0", espaco: 1.0, descricao: "Acessório"),
  ItemInventario(nome: "Manual operacional", categoria: "I", espaco: 1.0, descricao: "Acessório"),
  ItemInventario(nome: "Notebook", categoria: "0", espaco: 2.0, descricao: "Acessório"),
  ItemInventario(nome: "Utensílio", categoria: "I", espaco: 1.0, descricao: "Acessório"),
  ItemInventario(nome: "Vestimenta", categoria: "I", espaco: 1.0, descricao: "Acessório"),

  // Proteções
  ItemInventario(nome: "Proteção leve", categoria: "I", espaco: 2.0, descricao: "Item Operacional (+5 Defesa.)"),
  ItemInventario(nome: "Proteção pesada", categoria: "II", espaco: 5.0, descricao: "Item Operacional (+10 Defesa. Penalidade -2)"),
  
  // Explosivos
  ItemInventario(nome: "Dinamite", categoria: "I", espaco: 1.0, descricao: "Explosivo"),
  ItemInventario(nome: "Explosivo plástico", categoria: "I", espaco: 1.0, descricao: "Explosivo"),
  ItemInventario(nome: "Galão vermelho", categoria: "0", espaco: 2.0, descricao: "Explosivo"),
  ItemInventario(nome: "Granada de atordoamento", categoria: "0", espaco: 1.0, descricao: "Explosivo"),
  ItemInventario(nome: "Granada de fragmentação", categoria: "I", espaco: 1.0, descricao: "Explosivo"),
  ItemInventario(nome: "Granada de fumaça", categoria: "0", espaco: 1.0, descricao: "Explosivo"),
  ItemInventario(nome: "Granada de gás sonífero", categoria: "I", espaco: 1.0, descricao: "Explosivo"),
  ItemInventario(nome: "Granada incendiária", categoria: "I", espaco: 1.0, descricao: "Explosivo"),
  ItemInventario(nome: "Granada de PEM", categoria: "I", espaco: 1.0, descricao: "Explosivo"),
  ItemInventario(nome: "Mina antipessoal", categoria: "I", espaco: 1.0, descricao: "Explosivo"),

  // Munições
  ItemInventario(nome: "Flechas", categoria: "0", espaco: 1.0, descricao: "Munição"),
  ItemInventario(nome: "Balas curtas", categoria: "0", espaco: 1.0, descricao: "Munição"),
  ItemInventario(nome: "Balas longas", categoria: "I", espaco: 1.0, descricao: "Munição"),
  ItemInventario(nome: "Cartuchos", categoria: "I", espaco: 1.0, descricao: "Munição"),

  // Itens Operacionais
  ItemInventario(nome: "Alarme de movimento", categoria: "0", espaco: 1.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Algemas", categoria: "0", espaco: 1.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Alimento energético", categoria: "II", espaco: 1.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Aplicador de medicamentos", categoria: "I", espaco: 1.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Arpéu", categoria: "0", espaco: 1.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Bandoleira", categoria: "I", espaco: 1.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Binóculos", categoria: "0", espaco: 1.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Bloqueador de sinal", categoria: "I", espaco: 1.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Braçadeira reforçada", categoria: "I", espaco: 1.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Cão adestrado", categoria: "I", espaco: 0.0, descricao: "Aliado"),
  ItemInventario(nome: "Cicatrizante", categoria: "I", espaco: 1.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Coldre saque rápido", categoria: "I", espaco: 1.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Corda", categoria: "0", espaco: 1.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Equipamento de escuta", categoria: "I", espaco: 1.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Equipamento de sobrevivência", categoria: "0", espaco: 2.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Estrepes (saco)", categoria: "0", espaco: 1.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Faixa de pregos", categoria: "I", espaco: 2.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Isqueiro", categoria: "0", espaco: 0.5, descricao: "Item Operacional"),
  ItemInventario(nome: "Lanterna tática", categoria: "I", espaco: 1.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Máscara de gás", categoria: "0", espaco: 1.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Mochila militar", categoria: "I", espaco: -2.0, descricao: "Item Operacional (Aumenta capacidade em 2)"),
  ItemInventario(nome: "Óculos de visão noturna", categoria: "I", espaco: 1.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Óculos de visão térmica", categoria: "I", espaco: 1.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Óculos escuros", categoria: "0", espaco: 1.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Pá", categoria: "0", espaco: 2.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Paraquedas", categoria: "I", espaco: 2.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Pé de cabra", categoria: "0", espaco: 1.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Pistola de dardos", categoria: "I", espaco: 1.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Pistola sinalizadora", categoria: "0", espaco: 1.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Soqueira", categoria: "0", espaco: 1.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Spray de pimenta", categoria: "I", espaco: 1.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Taser", categoria: "I", espaco: 1.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Traje de mergulho", categoria: "I", espaco: 2.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Traje espacial", categoria: "II", espaco: 5.0, descricao: "Item Operacional"),
  ItemInventario(nome: "Traje hazmat", categoria: "I", espaco: 2.0, descricao: "Item Operacional"),

  // Medicamentos
  ItemInventario(nome: "Antibiótico", categoria: "I", espaco: 0.5, descricao: "Medicamento"),
  ItemInventario(nome: "Antídoto", categoria: "I", espaco: 0.5, descricao: "Medicamento"),
  ItemInventario(nome: "Antiemético", categoria: "I", espaco: 0.5, descricao: "Medicamento"),
  ItemInventario(nome: "Antihistamínico", categoria: "I", espaco: 0.5, descricao: "Medicamento"),
  ItemInventario(nome: "Anti-inflamatório", categoria: "I", espaco: 0.5, descricao: "Medicamento"),
  ItemInventario(nome: "Antitérmico", categoria: "I", espaco: 0.5, descricao: "Medicamento"),
  ItemInventario(nome: "Broncodilatador", categoria: "I", espaco: 0.5, descricao: "Medicamento"),
  ItemInventario(nome: "Coagulante", categoria: "I", espaco: 0.5, descricao: "Medicamento"),

  // Itens Paranormais
  ItemInventario(nome: "Ampliador (Catalisador)", categoria: "I", espaco: 0.5, descricao: "Item Paranormal"),
  ItemInventario(nome: "Perturbador (Catalisador)", categoria: "I", espaco: 0.5, descricao: "Item Paranormal"),
  ItemInventario(nome: "Potencializador (Catalisador)", categoria: "I", espaco: 0.5, descricao: "Item Paranormal"),
  ItemInventario(nome: "Prolongador (Catalisador)", categoria: "I", espaco: 0.5, descricao: "Item Paranormal"),
  ItemInventario(nome: "Ligação Direta Infernal", categoria: "II", espaco: 1.0, descricao: "Item Paranormal"),
  ItemInventario(nome: "Medidor de Condição Vertebral", categoria: "II", espaco: 1.0, descricao: "Item Paranormal"),
  ItemInventario(nome: "Pé de Morto", categoria: "II", espaco: 1.0, descricao: "Item Paranormal"),
  ItemInventario(nome: "Pendrive selado", categoria: "II", espaco: 0.5, descricao: "Item Paranormal"),
  ItemInventario(nome: "Valete da Salvação", categoria: "I", espaco: 0.5, descricao: "Item Paranormal"),
];

final List<Arma> catalogoArmasOrdem = [
  
  // Armas Simples - Corpo a Corpo
  Arma(nome: "Coronhada", dano: "1d4/1d6", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 2, categoria: "0", espaco: 0.0),
  Arma(nome: "Faca", dano: "1d4", tipo: "Corpo a Corpo", margemAmeaca: 19, multiplicadorCritico: 2, categoria: "0", espaco: 1.0),
  Arma(nome: "Martelo", dano: "1d6", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 2, categoria: "0", espaco: 1.0),
  Arma(nome: "Punhal", dano: "1d4", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 3, categoria: "0", espaco: 1.0),
  Arma(nome: "Bastão", dano: "1d6/1d8", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 2, categoria: "0", espaco: 1.0),
  Arma(nome: "Machete", dano: "1d6", tipo: "Corpo a Corpo", margemAmeaca: 19, multiplicadorCritico: 2, categoria: "0", espaco: 1.0),
  Arma(nome: "Lança", dano: "1d6", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 2, categoria: "0", espaco: 1.0),
  Arma(nome: "Cajado", dano: "1d6/1d6", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 2, categoria: "0", espaco: 2.0),
  
  // Armas Simples - Disparo e Fogo
  Arma(nome: "Arco", dano: "1d6", tipo: "Disparo", margemAmeaca: 20, multiplicadorCritico: 3, categoria: "0", espaco: 2.0),
  Arma(nome: "Besta", dano: "1d8", tipo: "Disparo", margemAmeaca: 19, multiplicadorCritico: 2, categoria: "0", espaco: 2.0),
  Arma(nome: "Estilingue", dano: "1d4", tipo: "Disparo", margemAmeaca: 20, multiplicadorCritico: 2, categoria: "0", espaco: 1.0),
  Arma(nome: "Pregador pneumático", dano: "1d4", tipo: "Disparo", margemAmeaca: 20, multiplicadorCritico: 4, categoria: "0", espaco: 1.0),
  Arma(nome: "Pistola", dano: "1d12", tipo: "Fogo", margemAmeaca: 18, multiplicadorCritico: 2, categoria: "I", espaco: 1.0),
  Arma(nome: "Revólver", dano: "2d6", tipo: "Fogo", margemAmeaca: 19, multiplicadorCritico: 3, categoria: "I", espaco: 1.0),
  Arma(nome: "Revólver compacto", dano: "2d4", tipo: "Fogo", margemAmeaca: 19, multiplicadorCritico: 3, categoria: "I", espaco: 1.0),
  Arma(nome: "Fuzil de caça", dano: "2d8", tipo: "Fogo", margemAmeaca: 19, multiplicadorCritico: 3, categoria: "I", espaco: 2.0),
  
  // Armas Táticas - Corpo a Corpo
  Arma(nome: "Machadinha", dano: "1d6", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 3, categoria: "0", espaco: 1.0),
  Arma(nome: "Nunchaku", dano: "1d8", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 2, categoria: "0", espaco: 1.0),
  Arma(nome: "Baioneta", dano: "1d4", tipo: "Corpo a Corpo", margemAmeaca: 19, multiplicadorCritico: 2, categoria: "0", espaco: 1.0),
  Arma(nome: "Faca tática", dano: "1d6", tipo: "Corpo a Corpo", margemAmeaca: 19, multiplicadorCritico: 2, categoria: "I", espaco: 1.0),
  Arma(nome: "Gancho de carne", dano: "1d4", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 4, categoria: "0", espaco: 1.0),
  Arma(nome: "Corrente", dano: "1d8", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 2, categoria: "0", espaco: 1.0),
  Arma(nome: "Espada", dano: "1d8/1d10", tipo: "Corpo a Corpo", margemAmeaca: 19, multiplicadorCritico: 2, categoria: "I", espaco: 1.0),
  Arma(nome: "Florete", dano: "1d6", tipo: "Corpo a Corpo", margemAmeaca: 18, multiplicadorCritico: 2, categoria: "I", espaco: 1.0),
  Arma(nome: "Machado", dano: "1d8", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 3, categoria: "I", espaco: 1.0),
  Arma(nome: "Maça", dano: "2d4", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 2, categoria: "I", espaco: 1.0),
  Arma(nome: "Bastão policial", dano: "1d6", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 2, categoria: "I", espaco: 1.0),
  Arma(nome: "Picareta", dano: "1d6", tipo: "Corpo a Corpo", margemAmeaca: 20, multiplicadorCritico: 4, categoria: "0", espaco: 1.0),
  
  // Armas Táticas - Arremesso e Fogo
  Arma(nome: "Shuriken", dano: "1d4", tipo: "Arremesso", margemAmeaca: 20, multiplicadorCritico: 2, categoria: "I", espaco: 0.5),
  Arma(nome: "Pistola pesada", dano: "2d8", tipo: "Fogo", margemAmeaca: 18, multiplicadorCritico: 2, categoria: "I", espaco: 1.0),
  Arma(nome: "Espingarda de cano duplo", dano: "4d6", tipo: "Fogo", margemAmeaca: 20, multiplicadorCritico: 3, categoria: "II", espaco: 2.0),
];