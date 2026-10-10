import 'package:flutter/material.dart';
import 'package:manocerca/core/data/mock_data.dart';
import 'package:manocerca/core/theme/app_theme.dart';
import 'package:manocerca/core/theme/colors.dart';
import 'package:manocerca/core/widgets/avatar.dart';
import 'package:manocerca/core/widgets/stars.dart';
import 'package:manocerca/screens/profile/profile_screen.dart';

class ProListScreen extends StatefulWidget {
  final String title;
  const ProListScreen({super.key, required this.title});

  @override
  State<ProListScreen> createState() => _ProListScreenState();
}

class _ProListScreenState extends State<ProListScreen> {
  int _chip = 0;
  final Set<int> _favs = {};
  static const _chips = ['Cerca de mí', 'Mejor valorados', 'Disponibles hoy'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('32 profesionales cerca de ti',
                style: TextStyle(color: C.muted, fontSize: 15)),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < _chips.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _chip = i),
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                          decoration: BoxDecoration(
                            color: _chip == i ? C.primary : C.card,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: _chip == i ? C.primary : C.border),
                          ),
                          child: Text(_chips[i],
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                itemCount: pros.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final p = pros[i];
                  final today = p.availability.contains('hoy');
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProfileScreen(pro: p)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: cardDeco(),
                      child: Row(
                        children: [
                          Avatar(name: p.name, size: 72, online: true),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name,
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Stars(rating: p.rating),
                                    const SizedBox(width: 6),
                                    Text('${p.rating} (${p.reviews})',
                                        style: const TextStyle(
                                            color: C.muted, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text('Electricista',
                                    style: TextStyle(color: C.muted, fontSize: 13)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 13, color: C.muted),
                                    const SizedBox(width: 3),
                                    Text('A ${p.distance}',
                                        style: const TextStyle(
                                            color: C.muted, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Icon(Icons.circle,
                                        size: 9,
                                        color: today ? C.green : C.star),
                                    const SizedBox(width: 5),
                                    Text(p.availability,
                                        style: TextStyle(
                                            color: today ? C.green : C.star,
                                            fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _favs.contains(i) ? _favs.remove(i) : _favs.add(i);
                              }),
                              child: Icon(
                                _favs.contains(i)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _favs.contains(i) ? Colors.redAccent : Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
