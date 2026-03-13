import 'dart:io';
import 'package:flutter/material.dart';

// --- ESTILOS GLOBAIS ---
class EstiloParanormal {
  // Retorna a cor principal baseada na afinidade
  static Color corTema(String? afinidade) {
    if (afinidade == null) return Colors.white; 
    switch (afinidade) {
      case 'Sangue': return const Color(0xFF990000); 
      case 'Energia': return const Color(0xFF9900FF); 
      case 'Morte': return Colors.black; 
      case 'Conhecimento': return const Color(0xFFFFB300); 
      default: return Colors.white;
    }
  }

  // Retorna a cor do texto para dar contraste
  static Color corTextoTema(String? afinidade) {
    return (afinidade == 'Conhecimento' || afinidade == null) ? Colors.black : Colors.white;
  }

  // Estilo padronizado para Inputs nos Pop-ups
  static InputDecoration customInputDeco(String label, Color corBase, IconData icone) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icone, color: Colors.grey, size: 20),
      filled: true,
      fillColor: const Color(0xFF0D0D0D),
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: corBase, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    );
  }
}


class BotaoAfinidadeAnimado extends StatefulWidget {
  final VoidCallback onPressed;
  const BotaoAfinidadeAnimado({super.key, required this.onPressed});

  @override
  State<BotaoAfinidadeAnimado> createState() => _BotaoAfinidadeAnimadoState();
}

class _BotaoAfinidadeAnimadoState extends State<BotaoAfinidadeAnimado> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 5), vsync: this)..repeat();
    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(weight: 1.0, tween: ColorTween(begin: const Color(0xFF990000), end: const Color(0xFF9900FF))), 
      TweenSequenceItem(weight: 1.0, tween: ColorTween(begin: const Color(0xFF9900FF), end: Colors.white)), 
      TweenSequenceItem(weight: 1.0, tween: ColorTween(begin: Colors.white, end: const Color(0xFFFFB300))), 
      TweenSequenceItem(weight: 1.0, tween: ColorTween(begin: const Color(0xFFFFB300), end: const Color(0xFF990000))), 
    ]).animate(_controller);
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.black, borderRadius: BorderRadius.circular(8), 
            border: Border.all(color: _colorAnimation.value ?? Colors.white, width: 2),
            boxShadow: [BoxShadow(color: (_colorAnimation.value ?? Colors.white).withValues(alpha: 0.6), blurRadius: 10, spreadRadius: 2)],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(8),
              child: Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20), child: Text("ESCOLHER AFINIDADE", textAlign: TextAlign.center, style: TextStyle(color: _colorAnimation.value, fontWeight: FontWeight.bold, letterSpacing: 1.5))),
            ),
          ),
        );
      }
    );
  }
}

class AvatarPulsante extends StatefulWidget {
  final String? afinidade; final Color corTema; final String? fotoPath; final bool isVisualizacao; final VoidCallback onTap;
  const AvatarPulsante({super.key, required this.afinidade, required this.corTema, this.fotoPath, required this.isVisualizacao, required this.onTap});
  @override
  State<AvatarPulsante> createState() => _AvatarPulsanteState();
}
class _AvatarPulsanteState extends State<AvatarPulsante> with SingleTickerProviderStateMixin {
  late AnimationController _controller; late Animation<double> _glowAnimation;
  @override
  void initState() { super.initState(); _controller = AnimationController(vsync: this); _configurarAnimacao(); }

  void _configurarAnimacao() {
    if (widget.afinidade == null) { _controller.stop(); _glowAnimation = const AlwaysStoppedAnimation(0.0); return; }
    if (widget.afinidade == 'Sangue') {
      _controller.duration = const Duration(milliseconds: 1200); 
      _glowAnimation = TweenSequence<double>([TweenSequenceItem(weight: 15.0, tween: Tween(begin: 2.0, end: 18.0).chain(CurveTween(curve: Curves.easeOut))), TweenSequenceItem(weight: 15.0, tween: Tween(begin: 18.0, end: 2.0).chain(CurveTween(curve: Curves.easeIn))), TweenSequenceItem(weight: 15.0, tween: Tween(begin: 2.0, end: 24.0).chain(CurveTween(curve: Curves.easeOut))), TweenSequenceItem(weight: 25.0, tween: Tween(begin: 24.0, end: 2.0).chain(CurveTween(curve: Curves.easeIn))), TweenSequenceItem(weight: 30.0, tween: Tween(begin: 2.0, end: 2.0))]).animate(_controller);
      _controller.repeat(); 
    } 
    else if (widget.afinidade == 'Energia') {
      _controller.duration = const Duration(milliseconds: 600); 
      _glowAnimation = TweenSequence<double>([TweenSequenceItem(weight: 20.0, tween: Tween(begin: 2.0, end: 22.0)), TweenSequenceItem(weight: 10.0, tween: Tween(begin: 22.0, end: 5.0)), TweenSequenceItem(weight: 25.0, tween: Tween(begin: 5.0, end: 28.0).chain(CurveTween(curve: Curves.bounceOut))), TweenSequenceItem(weight: 15.0, tween: Tween(begin: 28.0, end: 0.0)), TweenSequenceItem(weight: 15.0, tween: Tween(begin: 0.0, end: 15.0)), TweenSequenceItem(weight: 15.0, tween: Tween(begin: 15.0, end: 2.0))]).animate(_controller);
      _controller.repeat(); 
    } 
    else if (widget.afinidade == 'Morte') {
      _controller.duration = const Duration(milliseconds: 2500); 
      _glowAnimation = TweenSequence<double>([TweenSequenceItem(weight: 50.0, tween: Tween(begin: 4.0, end: 14.0).chain(CurveTween(curve: Curves.easeInOut))), TweenSequenceItem(weight: 50.0, tween: Tween(begin: 14.0, end: 4.0).chain(CurveTween(curve: Curves.easeInOut)))]).animate(_controller);
      _controller.repeat(); 
    }
    else if (widget.afinidade == 'Conhecimento') {
      _controller.duration = const Duration(milliseconds: 3000); 
      _glowAnimation = TweenSequence<double>([TweenSequenceItem(weight: 10.0, tween: Tween(begin: 2.0, end: 26.0).chain(CurveTween(curve: Curves.decelerate))), TweenSequenceItem(weight: 10.0, tween: Tween(begin: 26.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn))), TweenSequenceItem(weight: 80.0, tween: Tween(begin: 0.0, end: 0.0))]).animate(_controller);
      _controller.repeat();
    }
  }
  @override
  void didUpdateWidget(AvatarPulsante oldWidget) { super.didUpdateWidget(oldWidget); if (widget.afinidade != oldWidget.afinidade) { _controller.reset(); _configurarAnimacao(); } }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(animation: _glowAnimation, builder: (context, child) {
          return Container(width: 120, height: 120, decoration: BoxDecoration(color: const Color(0xFF1A1A1A), border: Border.all(color: widget.corTema, width: 2), borderRadius: BorderRadius.circular(8), boxShadow: widget.afinidade != null ? [BoxShadow(color: widget.corTema.withValues(alpha: 0.7), blurRadius: _glowAnimation.value, spreadRadius: _glowAnimation.value / 4)] : [], image: widget.fotoPath != null ? DecorationImage(image: FileImage(File(widget.fotoPath!)), fit: BoxFit.cover) : null), child: widget.fotoPath == null ? Icon(widget.isVisualizacao ? Icons.person : Icons.add_a_photo, size: 40, color: Colors.grey) : null);
        }
      ),
    );
  }
}