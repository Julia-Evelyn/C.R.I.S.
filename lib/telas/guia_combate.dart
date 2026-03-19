// ignore_for_file: invalid_use_of_protected_member, library_private_types_in_public_api
part of 'ficha_agente.dart';

extension GuiaCombateFicha on _FichaAgenteState {

  // Guia de combate
  void _mostrarDialogAcoesCombate() {
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
            Icon(Icons.info_outline, color: corDestaque),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "AÇÕES EM COMBATE",
                style: TextStyle(
                  color: corDestaque,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopicoRegra(
                  "AÇÕES PADRÃO",
                  "Normalmente a coisa mais importante que você vai fazer em seu turno.",
                  corDestaque,
                ),
                _buildItemRegra(
                  "Agredir",
                  "Você faz um ataque com uma arma. Corpo a corpo (alvos a 1,5m) ou à distância (qualquer alvo visível no alcance). Atirar além do alcance sofre –5 no ataque.",
                ),
                _buildItemRegra(
                  "Atirando em Corpo a Corpo",
                  "Se atirar contra um alvo que esteja a 1,5m de qualquer inimigo, você sofre –1d20 no teste de ataque.",
                ),
                _buildItemRegra(
                  "Manobra de Combate",
                  "Ataque corpo a corpo para algo diferente de dano (oposto ao teste do alvo):\n• Agarrar: Alvo fica desprevenido e imóvel.\n• Derrubar: Deixa o alvo caído. Vencer por 5+ empurra 1,5m.\n• Desarmar: Derruba o item segurado.\n• Empurrar: Empurra 1,5m (+1,5m a cada 5 pontos extras).\n• Quebrar: Atinge um item que o alvo segura.\n• Atropelar: Feito durante o movimento. Se vencer, derruba e passa por ele.",
                ),
                _buildItemRegra(
                  "Conjurar Ritual",
                  "A maioria exige uma ação padrão.",
                ),
                _buildItemRegra(
                  "Fintar",
                  "Enganação oposta a Reflexos. Se passar, o alvo fica desprevenido contra seu próximo ataque (até o fim do seu próximo turno).",
                ),
                _buildItemRegra(
                  "Preparar",
                  "Prepara uma ação (padrão, movimento ou livre) para realizar como reação a uma circunstância específica antes do seu próximo turno.",
                ),
                _buildItemRegra(
                  "Usar Habilidade/Item",
                  "Algumas regras exigem ação padrão para ativação.",
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: Colors.grey),
                ),

                _buildTopicoRegra(
                  "AÇÕES DE MOVIMENTO",
                  "Mudar algo de posição — seja você ou um item.",
                  corDestaque,
                ),
                _buildItemRegra(
                  "Levantar-se",
                  "Levantar do chão, de uma cadeira ou cama.",
                ),
                _buildItemRegra(
                  "Manipular Item",
                  "Pegar objeto na mochila, abrir porta, atirar corda, etc.",
                ),
                _buildItemRegra(
                  "Mirar",
                  "Anula a penalidade de atirar em combate corpo a corpo contra aquele alvo até o fim do seu próximo turno. Exige treinamento em Pontaria.",
                ),
                _buildItemRegra(
                  "Movimentar-se",
                  "Percorre uma distância igual ao seu deslocamento (geralmente 9m).",
                ),
                _buildItemRegra(
                  "Sacar/Guardar Item",
                  "Pegar ou guardar equipamento.",
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: Colors.grey),
                ),

                _buildTopicoRegra(
                  "AÇÕES COMPLETAS",
                  "Exigem muito tempo e esforço, consumindo todo o turno.",
                  corDestaque,
                ),
                _buildItemRegra(
                  "Corrida",
                  "Corre mais que seu deslocamento normal usando a perícia Atletismo.",
                ),
                _buildItemRegra(
                  "Golpe de Misericórdia",
                  "Golpe letal num alvo adjacente e indefeso. É acerto crítico automático e a vítima tem chance de morrer na hora (25% NPCs principais, 75% NPCs secundários).",
                ),
                _buildItemRegra(
                  "Investida",
                  "Avança até o dobro do deslocamento (mínimo 3m) em linha reta e ataca corpo a corpo. Ganha +1d20 no ataque, mas sofre –5 na Defesa até o próximo turno.",
                ),
                _buildItemRegra(
                  "Conjurar Ritual Longo",
                  "Rituais muito longos gastam uma ação completa por rodada de execução.",
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: Colors.grey),
                ),

                _buildTopicoRegra(
                  "AÇÕES LIVRES",
                  "Demandam pouco ou nenhum tempo e esforço. Você pode executar quantas quiser por turno (a critério do mestre).",
                  corDestaque,
                ),
                _buildItemRegra(
                  "Atrasar",
                  "Você escolhe agir mais tarde na ordem de Iniciativa. Quando a nova Iniciativa chegar, você age normalmente.\n• Limites: Pode atrasar até 0 menos seu bônus de Iniciativa. Após isso, deve agir ou perder o turno.\n• Vários atrasos: Se vários quiserem agir ao mesmo tempo, quem tiver a maior Iniciativa (ou Agilidade) tem a vantagem de decidir quem age primeiro (ou por último).",
                ),
                _buildItemRegra(
                  "Falar",
                  "Falar frases curtas (limite padrão de 20 palavras) é livre. Rituais e habilidades que usam a voz não entram nessa regra.",
                ),
                _buildItemRegra(
                  "Jogar-se no Chão",
                  "Você se joga no chão de propósito. Recebe os benefícios e penalidades de estar caído, mas não sofre dano.",
                ),
                _buildItemRegra(
                  "Largar um Item",
                  "Soltar algo que esteja segurando. (Atenção: jogar um item para acertar algo é Ação Padrão; jogar para alguém pegar é Ação de Movimento).",
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Entendido",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildTopicoRegra(String titulo, String subtitulo, Color cor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              color: cor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitulo,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRegra(String nome, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.4,
          ),
          children: [
            TextSpan(
              text: "• $nome: ",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: desc),
          ],
        ),
      ),
    );
  }

}