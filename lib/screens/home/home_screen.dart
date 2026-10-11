import 'package:flutter/material.dart';
import 'package:manocerca/core/theme/app_theme.dart';
import 'package:manocerca/core/theme/colors.dart';
import 'package:manocerca/core/utils/categoria_icono.dart';
import 'package:manocerca/providers/auth_provider.dart';
import 'package:manocerca/providers/categorias_provider.dart';
import 'package:manocerca/screens/pro_list/pro_list_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CategoriasProvider>().cargarSiHaceFalta();
    });
  }

  Widget _categorias(CategoriasProvider cats) {
    if (cats.items.isEmpty) {
      if (cats.cargando) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (cats.error != null) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(cats.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: C.muted, fontSize: 14)),
              const SizedBox(height: 8),
              TextButton(onPressed: cats.recargar, child: const Text('Reintentar')),
            ],
          ),
        );
      }
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('Aún no hay categorías disponibles.',
              style: TextStyle(color: C.muted, fontSize: 14)),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.15,
      children: [
        for (final c in cats.items)
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProListScreen(categoria: c)),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: cardDeco(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(iconoDeCategoria(c.nombre), color: C.light, size: 30),
                  const SizedBox(height: 8),
                  Text(c.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final nombre = context.watch<AuthProvider>().usuario?.nombre ?? '';
    final cats = context.watch<CategoriasProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.location_on, color: C.primary, size: 22),
              SizedBox(width: 6),
              Text('Puebla, Pue.', style: TextStyle(fontSize: 15)),
              Icon(Icons.keyboard_arrow_down, size: 20),
              Spacer(),
              Icon(Icons.notifications_none, size: 26),
            ],
          ),
          const SizedBox(height: 22),
          Text('Hola, $nombre',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('¿Qué servicio necesitas hoy?',
              style: TextStyle(color: C.muted, fontSize: 15)),
          const SizedBox(height: 16),
          TextField(
            decoration: inputDeco('Buscar un oficio...',
                prefix: const Icon(Icons.search, color: C.muted)),
          ),
          const SizedBox(height: 16),
          Container(
            height: 170,
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [Color(0xFF1E4FA8), Color(0xFF0F2A57)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Stack(
              children: [
                const Positioned(
                  right: 0,
                  bottom: 0,
                  child: Icon(Icons.handyman, size: 110, color: Color(0x33FFFFFF)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Tu proyecto\nen buenas manos',
                        style: TextStyle(
                            fontSize: 21, fontWeight: FontWeight.w800, height: 1.25)),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 190,
                      child: Text(
                        'Encuentra profesionales cerca de ti, de forma rápida y segura.',
                        style: TextStyle(color: Color(0xFFD0DBF0), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_dot(true), _dot(false), _dot(false)],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Categorías', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              Text('Ver todas', style: TextStyle(color: C.primary, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          _categorias(cats),
        ],
      ),
    );
  }

  Widget _dot(bool active) => Container(
        width: 6,
        height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? C.light : C.border,
        ),
      );
}
