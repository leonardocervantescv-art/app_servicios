import 'package:flutter/material.dart';
import 'package:manocerca/core/models/pro.dart';
import 'package:manocerca/core/theme/app_theme.dart';
import 'package:manocerca/core/theme/colors.dart';
import 'package:manocerca/core/widgets/avatar.dart';
import 'package:manocerca/core/widgets/stars.dart';

class ReviewsScreen extends StatelessWidget {
  final Pro pro;
  const ReviewsScreen({super.key, required this.pro});

  @override
  Widget build(BuildContext context) {
    const dist = [85, 25, 7, 2, 1];
    const total = 120;
    const reviews = [
      ['Ana Martínez', 'Hace 2 semanas', 'Excelente servicio, muy puntual y profesional. ¡Lo recomiendo!'],
      ['Ricardo López', 'Hace 1 mes', 'Muy buen trabajo, solucionó el problema rápidamente.'],
      ['Sofía Ramírez', 'Hace 2 meses', 'Buen trato y precios justos.'],
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reseñas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('4.9',
                  style: TextStyle(fontSize: 54, fontWeight: FontWeight.w800)),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Stars(rating: 5, size: 24),
                  SizedBox(height: 2),
                  Text('120 reseñas', style: TextStyle(color: C.muted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < 5; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Text('${5 - i}', style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  const Icon(Icons.star_rounded, size: 16, color: C.star),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: dist[i] / total,
                        minHeight: 8,
                        backgroundColor: C.card,
                        valueColor: const AlwaysStoppedAnimation(C.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 26,
                    child: Text('${dist[i]}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: C.muted, fontSize: 13)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          for (final r in reviews)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: cardDeco(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Avatar(name: r[0], size: 38),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r[0],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 15)),
                            Row(
                              children: [
                                const Stars(rating: 5, size: 13),
                                const SizedBox(width: 8),
                                Text(r[1],
                                    style: const TextStyle(
                                        color: C.muted, fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(r[2],
                      style: const TextStyle(
                          color: C.muted, fontSize: 14, height: 1.4)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
