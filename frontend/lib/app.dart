import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:manocerca/core/theme/app_theme.dart';
import 'package:manocerca/screens/auth/auth_gate.dart';
// import 'package:manocerca/screens/home/api_test_screen.dart';

class Hogarix extends StatelessWidget {
  const Hogarix({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hogarix',
      theme: AppTheme.dark,
      // Textos de los selectores de fecha y diálogos del sistema en español.
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('es', 'MX'), Locale('es')],
      home: const AuthGate(),
    );
  }
}
