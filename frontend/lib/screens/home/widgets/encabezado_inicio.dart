import 'package:flutter/material.dart';
import 'package:manocerca/core/theme/colors.dart';
import 'package:manocerca/providers/auth_provider.dart';
import 'package:manocerca/screens/messages/messages_screen.dart';
import 'package:manocerca/screens/notificaciones/notificaciones_screen.dart';
import 'package:manocerca/screens/ubicacion/ubicacion_sheet.dart';
import 'package:manocerca/services/api_client.dart';
import 'package:manocerca/services/chat_service.dart';
import 'package:provider/provider.dart';

/// Barra superior del Inicio (cliente y trabajador): ubicación editable,
/// mensajes (opcional) y notificaciones con su contador.
class EncabezadoInicio extends StatefulWidget {
  final bool mostrarMensajes;
  const EncabezadoInicio({super.key, this.mostrarMensajes = false});

  @override
  State<EncabezadoInicio> createState() => _EncabezadoInicioState();
}

class _EncabezadoInicioState extends State<EncabezadoInicio> {
  int _avisos = 0;
  int _mensajes = 0;

  @override
  void initState() {
    super.initState();
    _contar();
  }

  Future<void> _contar() async {
    final api = context.read<ApiClient>();
    try {
      final n = await NotificacionService(api).noLeidas();
      if (mounted) setState(() => _avisos = n);
    } catch (_) {}
    if (!widget.mostrarMensajes) return;
    try {
      final m = await ChatService(api).noLeidos();
      if (mounted) setState(() => _mensajes = m);
    } catch (_) {}
  }

  Future<void> _ir(Widget pantalla) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
    if (mounted) _contar();
  }

  Widget _icono(IconData icono, int contador, String ayuda, VoidCallback onTap) => IconButton(
        tooltip: ayuda,
        onPressed: onTap,
        icon: Badge(
          isLabelVisible: contador > 0,
          label: Text(contador > 9 ? '9+' : '$contador'),
          child: Icon(icono, size: 26),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final ubicacion = context.select<AuthProvider, String?>((a) => a.usuario?.ubicacionTexto);
    return Row(
      children: [
        Flexible(
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => editarUbicacion(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, color: C.primary, size: 22),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      ubicacion ?? 'Elige tu ubicación',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        color: ubicacion == null ? C.light : Colors.white,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, size: 20),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        if (widget.mostrarMensajes)
          _icono(Icons.chat_bubble_outline, _mensajes, 'Mensajes',
              () => _ir(const MessagesScreen(conAppBar: true))),
        _icono(Icons.notifications_none, _avisos, 'Notificaciones',
            () => _ir(const NotificacionesScreen())),
      ],
    );
  }
}
