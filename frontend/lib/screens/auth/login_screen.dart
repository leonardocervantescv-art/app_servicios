import 'package:flutter/material.dart';
import 'package:manocerca/core/theme/app_theme.dart';
import 'package:manocerca/core/theme/colors.dart';
import 'package:manocerca/core/widgets/buttons.dart';
import 'package:manocerca/providers/auth_provider.dart';
import 'package:manocerca/screens/auth/register_screen.dart';
import 'package:provider/provider.dart';

final _correoValido = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  bool _ocultar = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthProvider>().limpiarError();
    });
  }

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    // Si el login funciona, AuthGate reemplaza esta pantalla por la app.
    await context.read<AuthProvider>().login(
          correo: _correo.text.trim(),
          contrasena: _contrasena.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sesión',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text('Bienvenido de nuevo',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text('Ingresa para buscar o ofrecer servicios.',
                    style: TextStyle(color: C.muted, fontSize: 15)),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _correo,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: inputDeco('Correo electrónico',
                      prefix: const Icon(Icons.mail_outline, color: C.muted)),
                  validator: (v) => _correoValido.hasMatch((v ?? '').trim())
                      ? null
                      : 'Ingresa un correo válido',
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _contrasena,
                  obscureText: _ocultar,
                  autofillHints: const [AutofillHints.password],
                  decoration: inputDeco(
                    'Contraseña',
                    prefix: const Icon(Icons.lock_outline, color: C.muted),
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_ocultar ? Icons.visibility_off : Icons.visibility,
                          color: C.muted),
                      onPressed: () => setState(() => _ocultar = !_ocultar),
                    ),
                  ),
                  validator: (v) =>
                      (v ?? '').isEmpty ? 'Ingresa tu contraseña' : null,
                  onFieldSubmitted: (_) => _enviar(),
                ),
                if (auth.error != null) ...[
                  const SizedBox(height: 14),
                  Text(auth.error!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 14)),
                ],
                const SizedBox(height: 24),
                auth.cargando
                    ? const SizedBox(
                        height: 50,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : PrimaryButton(text: 'Iniciar sesión', onTap: _enviar),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                    child: const Text(
                      '¿No tienes cuenta? Regístrate',
                      style: TextStyle(
                        color: C.light,
                        decoration: TextDecoration.underline,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
