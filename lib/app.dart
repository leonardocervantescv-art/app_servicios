import 'package:flutter/material.dart';
import 'package:manocerca/core/theme/app_theme.dart';
//import 'package:manocerca/screens/welcome/welcome_screen.dart';
import 'package:manocerca/screens/home/api_test_screen.dart';

class Hogarix extends StatelessWidget {
  const Hogarix({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hogarix',
      theme: AppTheme.dark,
      home: const ApiTestScreen(),
    );
  }
}
