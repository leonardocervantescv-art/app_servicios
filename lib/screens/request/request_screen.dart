import 'package:flutter/material.dart';
import 'package:manocerca/core/models/pro.dart';
import 'package:manocerca/core/theme/app_theme.dart';
import 'package:manocerca/core/theme/colors.dart';
import 'package:manocerca/core/widgets/avatar.dart';
import 'package:manocerca/core/widgets/buttons.dart';
import 'package:manocerca/core/widgets/stars.dart';
import 'package:manocerca/screens/confirmed/confirmed_screen.dart';

class RequestScreen extends StatefulWidget {
  final Pro pro;
  const RequestScreen({super.key, required this.pro});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  int _day = 1;
  int _time = 1;
  static const _days = [
    ['Vie', '12'],
    ['Sáb', '13'],
    ['Dom', '14'],
    ['Lun', '15'],
    ['Mar', '16'],
  ];
  static const _times = ['8:00', '10:00', '12:00', '14:00', '16:00', '18:00'];

  @override
  Widget build(BuildContext context) {
    final p = widget.pro;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar servicio',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: cardDeco(),
              child: Row(
                children: [
                  Avatar(name: p.name, size: 56),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Stars(rating: p.rating, size: 13),
                          const SizedBox(width: 6),
                          Text('${p.rating} (${p.reviews})',
                              style:
                                  const TextStyle(color: C.muted, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text('Electricista',
                          style: TextStyle(color: C.muted, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text('Selecciona la fecha',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Row(
              children: [
                for (int i = 0; i < _days.length; i++)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _day = i),
                      child: Container(
                        margin: EdgeInsets.only(right: i == _days.length - 1 ? 0 : 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _day == i ? C.primary : C.card,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: _day == i ? C.primary : C.border),
                        ),
                        child: Column(
                          children: [
                            Text(_days[i][0],
                                style: TextStyle(
                                    fontSize: 12,
                                    color: _day == i ? Colors.white : C.muted)),
                            const SizedBox(height: 4),
                            Text(_days[i][1],
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            const Text('Selecciona un horario',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.6,
              children: [
                for (int i = 0; i < _times.length; i++)
                  GestureDetector(
                    onTap: () => setState(() => _time = i),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _time == i ? C.primary : C.card,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: _time == i ? C.primary : C.border),
                      ),
                      child: Text(_times[i],
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            const Text('Detalle del servicio',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            TextField(
              maxLines: 3,
              decoration: inputDeco('Cuéntale brevemente qué necesitas...'),
            ),
            const SizedBox(height: 22),
            PrimaryButton(
              text: 'Enviar solicitud',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConfirmedScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
