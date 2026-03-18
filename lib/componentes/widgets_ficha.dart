import 'package:flutter/material.dart';

class SecaoFicha extends StatelessWidget {
  final String titulo;
  final List<Widget> filhos;
  final Color corTema;
  final Color corTexto;
  final bool isMorte;

  const SecaoFicha({
    super.key,
    required this.titulo,
    required this.filhos,
    required this.corTema,
    required this.corTexto,
    this.isMorte = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFF333333)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: corTema,
                border: isMorte ? Border.all(color: Colors.white54, width: 1) : null,
                borderRadius: isMorte ? BorderRadius.circular(2) : null,
              ),
              child: Text(
                titulo.toUpperCase(),
                style: TextStyle(
                  color: corTexto,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...filhos,
          ],
        ),
      ),
    );
  }
}

class BarraStatusFicha extends StatelessWidget {
  final String titulo;
  final int atual;
  final int maximo;
  final Color cor;
  final Function(int) onChanged;

  const BarraStatusFicha({
    super.key,
    required this.titulo,
    required this.atual,
    required this.maximo,
    required this.cor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    double progresso = maximo == 0 ? 0 : atual / maximo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(titulo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            Text("$atual / $maximo", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: () => onChanged(atual - 5),
              child: const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Icon(Icons.keyboard_double_arrow_left, color: Colors.white54, size: 22)),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => onChanged(atual - 1),
              onLongPress: () => onChanged(0),
              child: const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Icon(Icons.remove_circle_outline, color: Colors.white54, size: 24)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onPanUpdate: (details) {
                      double percent = details.localPosition.dx / constraints.maxWidth;
                      onChanged((percent * maximo).round());
                    },
                    onTapDown: (details) {
                      double percent = details.localPosition.dx / constraints.maxWidth;
                      onChanged((percent * maximo).round());
                    },
                    child: Container(
                      height: 24,
                      alignment: Alignment.center,
                      color: Colors.transparent,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progresso,
                          minHeight: 12,
                          backgroundColor: Colors.grey.shade800,
                          color: cor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onChanged(atual + 1),
              onLongPress: () => onChanged(maximo),
              child: const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Icon(Icons.add_circle_outline, color: Colors.white54, size: 24)),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => onChanged(atual + 5),
              child: const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Icon(Icons.keyboard_double_arrow_right, color: Colors.white54, size: 22)),
            ),
          ],
        ),
      ],
    );
  }
}

class AtributoInputFicha extends StatelessWidget {
  final String label;
  final int value;
  final bool isVisu;
  final Color corPopUp;
  final Function(String) onChanged;
  final Function(String, int) onRolarDado;

  const AtributoInputFicha({
    super.key,
    required this.label,
    required this.value,
    required this.isVisu,
    required this.corPopUp,
    required this.onChanged,
    required this.onRolarDado,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isVisu ? () => onRolarDado(label, value) : null,
      child: SizedBox(
        width: 65,
        child: TextFormField(
          initialValue: value.toString(),
          enabled: !isVisu,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isVisu ? corPopUp : Colors.white,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: const Color(0xFF0D0D0D),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class DropdownFicha extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final Function(String?)? onChanged;

  const DropdownFicha({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: const Color(0xFF0D0D0D),
      ),
      initialValue: options.contains(value) ? value : options.first,
      isExpanded: true,
      items: options.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(),
      onChanged: onChanged,
    );
  }
}

class StatusFixoFicha extends StatelessWidget {
  final String label;
  final int value;

  const StatusFixoFicha({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}