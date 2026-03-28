import 'dart:io';
import 'package:flutter/material.dart';
import '../modelos/agente_dados.dart';

class TelaLoreAgente extends StatefulWidget {
  final AgenteDados agente;
  final Color corTema;
  final Future<void> Function() onSalvar;

  const TelaLoreAgente({
    super.key,
    required this.agente,
    required this.corTema,
    required this.onSalvar,
  });

  @override
  State<TelaLoreAgente> createState() => _TelaLoreAgenteState();
}

class _TelaLoreAgenteState extends State<TelaLoreAgente> {
  bool _isEditing = false;

  late TextEditingController idadeCtrl;
  late TextEditingController generoCtrl;
  late TextEditingController nacCtrl;
  late TextEditingController apaCtrl;
  late TextEditingController histCtrl;
  late TextEditingController objCtrl;
  late TextEditingController extCtrl;

  @override
  void initState() {
    super.initState();
    idadeCtrl = TextEditingController(text: widget.agente.idade);
    generoCtrl = TextEditingController(text: widget.agente.genero);
    nacCtrl = TextEditingController(text: widget.agente.nacionalidade);
    apaCtrl = TextEditingController(text: widget.agente.aparencia);
    histCtrl = TextEditingController(text: widget.agente.historico);
    objCtrl = TextEditingController(text: widget.agente.objetivo);
    extCtrl = TextEditingController(text: widget.agente.extra);
  }

  @override
  void dispose() {
    idadeCtrl.dispose();
    generoCtrl.dispose();
    nacCtrl.dispose();
    apaCtrl.dispose();
    histCtrl.dispose();
    objCtrl.dispose();
    extCtrl.dispose();
    super.dispose();
  }

  void _salvarLore() async {
    setState(() {
      widget.agente.idade = idadeCtrl.text;
      widget.agente.genero = generoCtrl.text;
      widget.agente.nacionalidade = nacCtrl.text;
      widget.agente.aparencia = apaCtrl.text;
      widget.agente.historico = histCtrl.text;
      widget.agente.objetivo = objCtrl.text;
      widget.agente.extra = extCtrl.text;
      _isEditing = false; // Sai do modo de edição
    });

    await widget
        .onSalvar(); // Salva no SharedPreferences através da tela inicial

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Arquivo confidencial atualizado com sucesso!",
            style: TextStyle(
              fontFamily: 'Courier',
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: widget.corTema,
        ),
      );
    }
  }

  // Estilo de bloco para informações rápidas (Idade, Gênero, etc.)
  Widget _buildInfoBlock(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        border: Border.all(color: Colors.grey.shade800),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: widget.corTema,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isNotEmpty ? value.toUpperCase() : "---",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Courier',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Estilo de bloco para textos longos (Histórico, Aparência, etc.)
  Widget _buildTextSection(String titulo, String texto) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border(left: BorderSide(color: widget.corTema, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo.toUpperCase(),
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            texto.isNotEmpty ? texto : "Dados não inseridos no sistema.",
            style: TextStyle(
              color: texto.isNotEmpty ? Colors.white70 : Colors.white24,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color corAcento = widget.corTema == Colors.white
        ? Colors.grey.shade400
        : widget.corTema;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text(
          "ARQUIVO: ${widget.agente.nome.toUpperCase()}",
          style: const TextStyle(
            fontFamily: 'Courier',
            letterSpacing: 1,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: widget.corTema, height: 2.0),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide =
              constraints.maxWidth >
              600; // Define se a tela é grande (Tablet/Desktop)

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 800,
                ), // Limita a largura em telas muito grandes
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CABEÇALHO DO ARQUIVO
                    Row(
                      children: [
                        Icon(
                          Icons.folder_shared,
                          color: widget.corTema,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "ARQUIVO CONFIDENCIAL",
                          style: TextStyle(
                            fontFamily: 'Courier',
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.shade900, thickness: 1),
                    const SizedBox(height: 16),

                    // IDENTIFICAÇÃO RESPONSIVA
                    isWide ? _buildModoGrande() : _buildModoPequeno(),

                    const SizedBox(height: 24),
                    Divider(color: Colors.grey.shade900, thickness: 1),
                    const SizedBox(height: 16),

                    // SEÇÕES DE LORE ROLÁVEIS
                    if (_isEditing)
                      _buildModoEdicao(corAcento)
                    else
                      _buildModoLeitura(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _isEditing ? Colors.green : widget.corTema,
        foregroundColor:
            _isEditing ||
                widget.corTema == Colors.white ||
                widget.corTema == Colors.white54
            ? Colors.black
            : Colors.white,
        icon: Icon(_isEditing ? Icons.save : Icons.edit),
        label: Text(
          _isEditing ? "SALVAR FICHA" : "EDITAR FICHA",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Courier',
          ),
        ),
        onPressed: () {
          if (_isEditing) {
            _salvarLore();
          } else {
            setState(() => _isEditing = true);
          }
        },
      ),
    );
  }

  // FOTO DE PERFIL PADRONIZADA
  Widget _buildFotoPerfil(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: widget.corTema, width: 2),
        boxShadow: [
          BoxShadow(
            color: widget.corTema.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        image: widget.agente.fotoPath != null
            ? DecorationImage(
                image: FileImage(File(widget.agente.fotoPath!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: widget.agente.fotoPath == null
          ? Icon(Icons.person, size: size * 0.5, color: Colors.grey.shade800)
          : null,
    );
  }

  // LAYOUT GRANDE: FOTO À ESQUERDA, INFORMAÇÕES À DIREITA
  Widget _buildModoGrande() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFotoPerfil(140),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.agente.nome.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildInfoBlock("Idade", widget.agente.idade),
                  _buildInfoBlock("Gênero", widget.agente.genero),
                  _buildInfoBlock("Nacionalidade", widget.agente.nacionalidade),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // LAYOUT PEQUENO: FOTO NO TOPO, INFORMAÇÕES ABAIXO
  Widget _buildModoPequeno() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildFotoPerfil(100),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.agente.nome.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildInfoBlock("Idade", widget.agente.idade)),
            const SizedBox(width: 8),
            Expanded(child: _buildInfoBlock("Gênero", widget.agente.genero)),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: _buildInfoBlock("Nacionalidade", widget.agente.nacionalidade),
        ),
      ],
    );
  }

  Widget _buildModoLeitura() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextSection("Aparência Física", widget.agente.aparencia),
        _buildTextSection("Histórico do Agente", widget.agente.historico),
        _buildTextSection("Objetivo na Ordem", widget.agente.objetivo),
        _buildTextSection("Informações Extras", widget.agente.extra),
        const SizedBox(height: 80), // Respiro pro FAB
      ],
    );
  }

  Widget _buildModoEdicao(Color corAcento) {
    InputDecoration inputDeco(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: corAcento, fontWeight: FontWeight.bold),
        filled: true,
        fillColor: const Color(0xFF151515),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: corAcento, width: 2),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: idadeCtrl,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Courier',
                ),
                decoration: inputDeco("Idade"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: generoCtrl,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Courier',
                ),
                decoration: inputDeco("Gênero"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: nacCtrl,
          style: const TextStyle(color: Colors.white, fontFamily: 'Courier'),
          decoration: inputDeco("Nacionalidade"),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: apaCtrl,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: inputDeco("Aparência Física"),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: histCtrl,
          maxLines: 6,
          style: const TextStyle(color: Colors.white),
          decoration: inputDeco("Histórico do Agente"),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: objCtrl,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: inputDeco("Objetivo na Ordem"),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: extCtrl,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: inputDeco("Informações Extras"),
        ),
        const SizedBox(height: 80), // Respiro pro FAB
      ],
    );
  }
}
