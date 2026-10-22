import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:manocerca/core/theme/app_theme.dart';
import 'package:manocerca/screens/auth/auth_gate.dart';
import 'package:manocerca/screens/main_shell/shell_controller.dart';
import 'package:provider/provider.dart';

class Hogarix extends StatelessWidget {
  const Hogarix({super.key});

  @override
  Widget build(BuildContext context) {
    // El ShellController vive arriba del MaterialApp para que las pantallas
    // abiertas encima de la barra inferior también puedan cambiar de pestaña.
    return ChangeNotifierProvider(
      create: (_) => ShellController(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hogarix',
        theme: AppTheme.dark,
        // Textos de los selectores de fecha y diálogos del sistema en español.
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [Locale('es', 'MX'), Locale('es')],
        home: const AuthGate(),
      ),
    );
  }
}
