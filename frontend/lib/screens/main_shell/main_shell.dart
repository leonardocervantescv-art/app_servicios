import 'package:flutter/material.dart';
import 'package:manocerca/core/models/solicitud.dart';
import 'package:manocerca/core/theme/colors.dart';
import 'package:manocerca/providers/auth_provider.dart';
import 'package:manocerca/screens/agenda/agenda_screen.dart';
import 'package:manocerca/screens/buscar/buscar_screen.dart';
import 'package:manocerca/screens/calificar/aviso_calificacion.dart';
import 'package:manocerca/screens/home/home_screen.dart';
import 'package:manocerca/screens/mas/mas_screen.dart';
import 'package:manocerca/screens/messages/messages_screen.dart';
import 'package:manocerca/screens/panel/panel_trabajador_screen.dart';
import 'package:manocerca/screens/perfil_cliente/perfil_cliente_screen.dart';
import 'package:manocerca/screens/perfil_trabajador/perfil_trabajador_screen.dart';
import 'package:manocerca/screens/solicitudes/solicitudes_screen.dart';
import 'package:manocerca/services/api_client.dart';
import 'package:manocerca/services/solicitud_service.dart';
import 'package:manocerca/screens/main_shell/shell_controller.dart';
import 'package:provider/provider.dart';

/// Una pestaña = la pantalla + su botón en la barra inferior.
class _Tab {
  final Widget Function() pagina;
  final IconData icono;
  final IconData iconoActivo;
  final String etiqueta;
  const _Tab(this.pagina, this.icono, this.iconoActivo, this.etiqueta);
}

/// Contenedor con la barra de navegación inferior. Clientes y trabajadores
/// ven pestañas y pantallas distintas.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late final ShellController _shell;

  /// Solo se construyen las pestañas que ya se abrieron (carga más rápida).
  final Set<int> _abiertas = {0};

  // Mensajes del cliente: icono en el encabezado del Inicio.
  static final _tabsCliente = <_Tab>[
    _Tab(() => const HomeScreen(), Icons.home_outlined, Icons.home_filled, 'Inicio'),
    _Tab(() => const BuscarScreen(), Icons.search, Icons.search, 'Buscar'),
    _Tab(() => const AgendaScreen(), Icons.calendar_month_outlined, Icons.calendar_month,
        'Agenda'),
    _Tab(() => const SolicitudesScreen(), Icons.assignment_outlined,
        Icons.assignment, 'Solicitudes'),
    _Tab(() => const PerfilClienteScreen(), Icons.person_outline, Icons.person, 'Perfil'),
  ];

  static final _tabsTrabajador = <_Tab>[
    _Tab(() => const PanelTrabajadorScreen(), Icons.home_outlined, Icons.home_filled,
        'Inicio'),
    _Tab(() => const AgendaScreen(), Icons.calendar_month_outlined, Icons.calendar_month,
        'Calendario'),
    _Tab(() => const MessagesScreen(), Icons.chat_bubble_outline, Icons.chat_bubble,
        'Mensajes'),
    _Tab(() => const MiPerfilTrabajadorScreen(), Icons.person_outline, Icons.person,
        'Perfil'),
    _Tab(() => const MasScreen(), Icons.menu, Icons.menu, 'Más'),
  ];

  @override
  void initState() {
    super.initState();
    _shell = context.read<ShellController>()..reiniciar();
    _shell.addListener(_alCambiarPestana);
    WidgetsBinding.instance.addPostFrameCallback((_) => _avisarCalificacionPendiente());
  }

  @override
  void dispose() {
    _shell.removeListener(_alCambiarPestana);
    super.dispose();
  }

  void _alCambiarPestana() => setState(() => _abiertas.add(_shell.index));

  /// Como en Uber: al entrar, si hay un trabajo completado sin calificar,
  /// se ofrece calificarlo.
  Future<void> _avisarCalificacionPendiente() async {
    final usuario = context.read<AuthProvider>().usuario;
    if (usuario == null) return;
    try {
      final completadas = await SolicitudService(context.read<ApiClient>())
          .listar(estado: EstadoSolicitud.completado, limite: 10);
      final pendiente = completadas.where((s) => s.porCalificar).firstOrNull;
      if (pendiente == null || !mounted) return;
      await mostrarAvisoCalificacion(context, pendiente, usuario.id);
    } catch (_) {
      // Sin conexión o sin solicitudes: no se muestra nada.
    }
  }

  @override
  Widget build(BuildContext context) {
    final esTrabajador =
        context.select<AuthProvider, bool>((a) => a.usuario?.esTrabajador ?? false);
    final tabs = esTrabajador ? _tabsTrabajador : _tabsCliente;
    final index = _shell.index.clamp(0, tabs.length - 1);

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: index,
          children: [
            for (int i = 0; i < tabs.length; i++)
              _abiertas.contains(i) ? tabs[i].pagina() : const SizedBox.shrink(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: C.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: _shell.ir,
          type: BottomNavigationBarType.fixed,
          backgroundColor: C.navy,
          selectedItemColor: C.primary,
          unselectedItemColor: Colors.white,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: [
            for (final t in tabs)
              BottomNavigationBarItem(
                icon: Icon(t.icono),
                activeIcon: Icon(t.iconoActivo),
                label: t.etiqueta,
              ),
          ],
        ),
      ),
    );
  }
}
