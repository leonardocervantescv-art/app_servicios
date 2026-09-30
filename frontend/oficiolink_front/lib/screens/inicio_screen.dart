import 'package:flutter/material.dart';
import '../constants/assets.dart';
import '../widgets/fondo_oficiolink.dart';
import 'login_screen.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  static const _azulLink = Color(0xFF2D7DF6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoOficioLink(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Logo principal 
                Image.asset(Assets.logoPrincipal, width: 170),
                const SizedBox(height: 60),
                const Text(
                  'Encuentra los\ntrabajadores que\nnecesites',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    height: 1.35,
                  ),
                ),
                const Spacer(flex: 3),
                BotonRojo(
                  texto: 'Ingresar',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿No tienes cuenta? ',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    GestureDetector(
                      onTap: () {
                        // TODO: navegar a la pantalla de registro
                      },
                      child: const Text(
                        'Regístrate',
                        style: TextStyle(
                          color: _azulLink,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                          decorationColor: _azulLink,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}