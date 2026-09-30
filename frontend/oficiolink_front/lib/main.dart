import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/inicio_screen.dart';

void main() => runApp(const OficioLinkApp());

class OficioLinkApp extends StatelessWidget {
  const OficioLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OficioLink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: ThemeData.light().textTheme.apply(
          fontFamily: GoogleFonts.nunito().fontFamily,
        ),
      ),
      home: const InicioScreen(),
    );
  }
}
