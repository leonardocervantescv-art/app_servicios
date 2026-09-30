import 'package:flutter/material.dart';
import '../constants/assets.dart';
import '../widgets/fondo_oficiolink.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _azulLink = Color(0xFF2D7DF6);

  final _correoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _correoCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  InputDecoration _campo() => InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );

  Widget _etiqueta(String texto) => Padding(
        padding: const EdgeInsets.only(bottom: 6, left: 4),
        child: Text(texto,
            style: const TextStyle(color: Colors.white, fontSize: 14)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: FondoOficioLink(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.vertical -
                    40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo "OficioLink"
                  Image.asset(Assets.logoOficioLink, height: 52),
                  const SizedBox(height: 16),
                  const Text('Iniciar sesión',
                      style: TextStyle(color: Colors.white, fontSize: 28)),
                  const SizedBox(height: 18),

                  // Botón Google
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        // login con Google
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        children: [
                          Image.asset(Assets.googleIcon, height: 26),
                          const Expanded(
                            child: Text('Continuar con Google',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16)),
                          ),
                          const SizedBox(width: 26),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Text('O',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                      Expanded(child: Divider(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _etiqueta('Correo electrónico*'),
                  TextField(
                    controller: _correoCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _campo(),
                  ),
                  const SizedBox(height: 16),

                  _etiqueta('Contraseña*'),
                  TextField(
                    controller: _passCtrl,
                    obscureText: true,
                    decoration: _campo(),
                  ),
                  const SizedBox(height: 40),

                  GestureDetector(
                    onTap: () {
                      // recuperar contraseña
                    },
                    child: const Text(
                      'Olvidé mi contraseña',
                      style: TextStyle(
                        color: _azulLink,
                        fontSize: 17,
                        decoration: TextDecoration.underline,
                        decorationColor: _azulLink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),

                  BotonRojo(
                    texto: 'Iniciar sesión',
                    onPressed: () {
                      // TODO: validar y autenticar con _correoCtrl / _passCtrl
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}