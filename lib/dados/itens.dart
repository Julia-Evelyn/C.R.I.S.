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
  ItemInventario(nome: "Vestimenta", categoria: "I", espaco: 1.0, descricao: "Acessório (Concede +2 em uma perícia)"),
  
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

  // Proteções
  ItemInventario(nome: "Proteção leve", categoria: "I", espaco: 2.0, descricao: "Proteção (+5 Defesa)"),
  ItemInventario(nome: "Proteção pesada", categoria: "II", espaco: 5.0, descricao: "Proteção (+10 Defesa, Penalidade de Carga -5)"),
  ItemInventario(nome: "Escudo", categoria: "I", espaco: 2.0, descricao: "Proteção (+2 Defesa, empunhado em 1 mão)"),

  // Munições
  ItemInventario(nome: "Balas curtas", categoria: "0", espaco: 1.0, descricao: "Munição"),
  ItemInventario(nome: "Balas longas", categoria: "I", espaco: 1.0, descricao: "Munição"),
  ItemInventario(nome: "Cartuchos", categoria: "I", espaco: 1.0, descricao: "Munição"),
  ItemInventario(nome: "Combustível", categoria: "I", espaco: 1.0, descricao: "Munição"),
  ItemInventario(nome: "Flechas", categoria: "0", espaco: 1.0, descricao: "Munição"),
  ItemInventario(nome: "Foguete", categoria: "I", espaco: 1.0, descricao: "Munição"),

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
  
  // Táticas - Arremesso e Fogo
  Arma(nome: "Shuriken", dano: "1d4", tipo: "Arremesso", margemAmeaca: 20, multiplicadorCritico: 2, categoria: "I", espaco: 0.5, proficiencia: "Táticas", empunhadura: "Leve"),
  Arma(nome: "Pistola pesada", dano: "2d8", tipo: "Fogo", margemAmeaca: 18, multiplicadorCritico: 2, categoria: "I", espaco: 1.0, proficiencia: "Táticas", empunhadura: "Uma Mão"),
  Arma(nome: "Espingarda de cano duplo", dano: "4d6", tipo: "Fogo", margemAmeaca: 20, multiplicadorCritico: 3, categoria: "II", espaco: 2.0, proficiencia: "Táticas", empunhadura: "Duas Mãos"),
];