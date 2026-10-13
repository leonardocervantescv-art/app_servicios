import 'package:flutter/material.dart';
import 'package:manocerca/core/theme/app_theme.dart';
import 'package:manocerca/core/theme/colors.dart';
import 'package:manocerca/core/widgets/avatar.dart';
import 'package:manocerca/core/widgets/buttons.dart';
import 'package:manocerca/providers/auth_provider.dart';
import 'package:manocerca/screens/agenda/agenda_screen.dart';
import 'package:manocerca/screens/servicios/mis_servicios_screen.dart';
import 'package:provider/provider.dart';

/// Pestaña "Perfil" de la barra inferior: datos de la sesión y cierre de sesión.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;
    if (usuario == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Avatar(name: usuario.nombreCompleto, size: 96),
          const SizedBox(height: 16),
          Text(usuario.nombreCompleto,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(usuario.correo, style: const TextStyle(color: C.muted, fontSize: 14)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: cardDeco(20),
            child: Text(usuario.rolTexto,
                style: const TextStyle(color: C.light, fontSize: 13)),
          ),
          const SizedBox(height: 36),
          if (usuario.esTrabajador) ...[
            _Atajo(
              icono: Icons.handyman,
              titulo: 'Mis servicios',
              detalle: 'Lo que ofreces y tu disponibilidad',
              destino: const MisServiciosScreen(),
            ),
            const SizedBox(height: 12),
            _Atajo(
              icono: Icons.calendar_month,
              titulo: 'Mi agenda',
              detalle: 'Tu calendario de citas y trabajos',
              destino: const AgendaScreen(),
            ),
            const SizedBox(height: 16),
          ],
          OutlineButtonX(
            text: 'Cerrar sesión',
            icon: Icons.logout,
            onTap: () => context.read<AuthProvider>().cerrarSesion(),
          ),
        ],
      ),
    );
  }
}

class _Atajo extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String detalle;
  final Widget destino;
  const _Atajo({
    required this.icono,
    required this.titulo,
    required this.detalle,
    required this.destino,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => destino)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: cardDeco(),
        child: Row(
          children: [
            Icon(icono, color: C.light),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(detalle, style: const TextStyle(color: C.muted, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: C.muted),
          ],
        ),
      ),
    );
  }
}
