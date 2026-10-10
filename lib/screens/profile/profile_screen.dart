import 'package:flutter/material.dart';
import 'package:manocerca/core/models/pro.dart';
import 'package:manocerca/core/theme/colors.dart';
import 'package:manocerca/core/widgets/avatar.dart';
import 'package:manocerca/core/widgets/buttons.dart';
import 'package:manocerca/core/widgets/stars.dart';
import 'package:manocerca/screens/chat/chat_screen.dart';
import 'package:manocerca/screens/request/request_screen.dart';
import 'package:manocerca/screens/reviews/reviews_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Pro pro;
  const ProfileScreen({super.key, required this.pro});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _tab = 0;
  bool _fav = false;
  static const _tabs = ['Sobre mí', 'Servicios', 'Reseñas'];

  Widget _info(IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: C.light),
            const SizedBox(width: 10),
            Text(text, style: const TextStyle(color: C.muted, fontSize: 14)),
          ],
        ),
      );

  Widget _tabContent() {
    switch (_tab) {
      case 0:
        return const Text(
          'Me especializo en instalaciones eléctricas, mantenimiento y reparación. '
          'Trabajo con responsabilidad y compromiso.',
          style: TextStyle(color: C.muted, fontSize: 14, height: 1.5),
        );
      case 1:
        return Column(
          children: [
            for (final s in [
              'Instalación eléctrica',
              'Reparación de cortocircuitos',
              'Cambio de contactos y apagadores',
              'Revisión de tablero'
            ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 18, color: C.green),
                    const SizedBox(width: 10),
                    Text(s, style: const TextStyle(color: C.muted, fontSize: 14)),
                  ],
                ),
              ),
          ],
        );
      default:
        return Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ReviewsScreen(pro: widget.pro)),
            ),
            icon: const Icon(Icons.star_rounded, color: C.star),
            label: Text('Ver las ${widget.pro.reviews} reseñas'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pro;
    return Scaffold(
      body: Column(
        children: [
          // Cabecera
          Container(
            height: 270,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3F7A), C.bg],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Positioned(
                    left: 8,
                    top: 4,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 4,
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(_fav ? Icons.favorite : Icons.favorite_border,
                              color: _fav ? Colors.redAccent : Colors.white),
                          onPressed: () => setState(() => _fav = !_fav),
                        ),
                        IconButton(
                          icon: const Icon(Icons.ios_share),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  Center(child: Avatar(name: p.name, size: 140)),
                  Positioned(
                    left: 20,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F3D2E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: C.green, width: 0.8),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.check_circle, size: 14, color: C.green),
                          SizedBox(width: 5),
                          Text('Verificado', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Stars(rating: p.rating, size: 18),
                      const SizedBox(width: 8),
                      Text('${p.rating} (${p.reviews} reseñas)',
                          style: const TextStyle(color: C.muted, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Electricista',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  _info(Icons.location_on, 'A ${p.distance} de ti'),
                  _info(Icons.workspace_premium, '3 años de experiencia'),
                  _info(Icons.schedule, 'Responde en menos de 1 hora'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (int i = 0; i < _tabs.length; i++)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _tab = i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: _tab == i ? C.primary : C.border,
                                    width: _tab == i ? 2.5 : 1,
                                  ),
                                ),
                              ),
                              child: Text(
                                _tabs[i],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _tab == i ? Colors.white : C.muted,
                                  fontWeight:
                                      _tab == i ? FontWeight.w700 : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _tabContent(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  PrimaryButton(
                    text: 'Contactar',
                    icon: Icons.chat_bubble_outline,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChatScreen(pro: p)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlineButtonX(
                    text: 'Solicitar servicio',
                    icon: Icons.event_available_outlined,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RequestScreen(pro: p)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
