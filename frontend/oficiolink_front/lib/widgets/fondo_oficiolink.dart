import 'package:flutter/material.dart';

/// Fondo azul degradado con las casas dibujadas abajo.
class FondoOficioLink extends StatelessWidget {
  final Widget child;
  const FondoOficioLink({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF021B5E), Color(0xFF000F3D)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 60,
            height: 170,
            child: CustomPaint(painter: _CasasPainter()),
          ),
          child,
        ],
      ),
    );
  }
}

class _CasasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final w = size.width;
    final h = size.height;

    // Casa grande izquierda
    final c1 = Path()
      ..moveTo(w * 0.08, h)
      ..lineTo(w * 0.08, h * 0.45)
      ..lineTo(w * 0.22, h * 0.15)
      ..lineTo(w * 0.36, h * 0.45)
      ..lineTo(w * 0.36, h);
    canvas.drawPath(c1, paint);
    canvas.drawRect(
        Rect.fromLTWH(w * 0.19, h * 0.5, w * 0.06, h * 0.16), paint);

    // Casa pequeña centro
    final c2 = Path()
      ..moveTo(w * 0.62, h)
      ..lineTo(w * 0.62, h * 0.72)
      ..lineTo(w * 0.70, h * 0.58)
      ..lineTo(w * 0.78, h * 0.72)
      ..lineTo(w * 0.78, h);
    canvas.drawPath(c2, paint);

    // Casa grande derecha
    final c3 = Path()
      ..moveTo(w * 0.80, h)
      ..lineTo(w * 0.80, h * 0.35)
      ..lineTo(w * 0.92, h * 0.05)
      ..lineTo(w * 1.04, h * 0.35)
      ..lineTo(w * 1.04, h);
    canvas.drawPath(c3, paint);
    canvas.drawRect(
        Rect.fromLTWH(w * 0.90, h * 0.42, w * 0.05, h * 0.16), paint);

    // Línea de suelo
    canvas.drawLine(Offset(0, h), Offset(w, h), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Botón rojo redondeado reutilizable.
class BotonRojo extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  const BotonRojo({super.key, required this.texto, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF0000),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(texto, style: const TextStyle(fontSize: 17)),
      ),
    );
  }
}