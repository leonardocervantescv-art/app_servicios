import 'package:flutter/material.dart';
import 'package:manocerca/core/models/usuario.dart';
import 'package:manocerca/core/theme/app_theme.dart';
import 'package:manocerca/core/theme/colors.dart';
import 'package:manocerca/core/widgets/buttons.dart';
import 'package:manocerca/providers/auth_provider.dart';
import 'package:manocerca/providers/categorias_provider.dart';
import 'package:manocerca/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';

final _correoValido = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
final _telefonoValido = RegExp(r'^[0-9+\- ]{7,20}$');

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _apellido = TextEditingController();
  final _correo = TextEditingController();
  final _telefono = TextEditingController();
  final _contrasena = TextEditingController();
  int _idRol = Roles.cliente;
  bool _ocultar = true;

  // Solo trabajadores (ambos opcionales).
  int? _idCategoria;
  String? _tipoPago;

  /// Lo que ve la persona -> valor que entiende el backend.
  static const _tiposPago = <(String, String)>[
    ('Destajo', 'Destajo'),
    ('Por día', 'Día'),
    ('Por proyecto', 'Por trabajo'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthProvider>().limpiarError();
      context.read<CategoriasProvider>().cargarSiHaceFalta();
    });
  }

  @override
  void dispose() {
    _nombre.dispose();
    _apellido.dispose();
    _correo.dispose();
    _telefono.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    // Si el registro funciona, AuthGate reemplaza esta pantalla por la app.
    await context.read<AuthProvider>().registrar(
          idRol: _idRol,
          nombre: _nombre.text.trim(),
          apellido: _apellido.text.trim(),
          correo: _correo.text.trim(),
          contrasena: _contrasena.text,
          telefono: _telefono.text.trim(),
          // Si eligió oficio, aparece de inmediato en esa categoría.
          servicio: _idRol == Roles.trabajador && _idCategoria != null
              ? (idCategoria: _idCategoria!, tipoPago: _tipoPago ?? 'Por trabajo')
              : null,
        );
  }

  String? _requerido(String? v, String campo) =>
      (v ?? '').trim().isEmpty ? 'Ingresa tu $campo' : null;

  Widget _opcionRol(int rol, IconData icono, String titulo, String detalle) {
    final activo = _idRol == rol;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _idRol = rol),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: activo ? C.primary.withValues(alpha: 0.18) : C.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: activo ? C.primary : C.border, width: 1.2),
          ),
          child: Column(
            children: [
              Icon(icono, color: activo ? C.primary : C.muted, size: 28),
              const SizedBox(height: 8),
              Text(titulo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 2),
              Text(detalle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: C.muted, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  /// Oficio y forma de cobro (opcionales). Se pueden cambiar después en
  /// "Mis servicios".
  Widget _datosTrabajador() {
    final cats = context.watch<CategoriasProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        const Text('¿A qué te dedicas? (opcional)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Así los clientes te encuentran en esa categoría desde el primer día.',
            style: TextStyle(color: C.muted, fontSize: 12)),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(
          value: _idCategoria,
          isExpanded: true,
          dropdownColor: C.card,
          decoration: inputDeco(cats.cargando && cats.items.isEmpty
              ? 'Cargando oficios...'
              : 'Elige tu oficio',
              prefix: const Icon(Icons.handyman_outlined, color: C.muted)),
          items: [
            for (final c in cats.items) DropdownMenuItem(value: c.id, child: Text(c.nombre)),
          ],
          onChanged: (v) => setState(() => _idCategoria = v),
        ),
        const SizedBox(height: 14),
        const Text('¿Cómo cobras? (opcional)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in _tiposPago)
              ChoiceChip(
                label: Text(t.$1),
                selected: _tipoPago == t.$2,
                onSelected: (sel) => setState(() => _tipoPago = sel ? t.$2 : null),
              ),
          ],
        ),
        if (_tipoPago != null && _idCategoria == null) ...[
          const SizedBox(height: 6),
          const Text('Elige también tu oficio para guardar la forma de cobro.',
              style: TextStyle(color: C.star, fontSize: 12)),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta',
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
                const Text('¿Cómo vas a usar la app?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _opcionRol(Roles.cliente, Icons.search, 'Busco un servicio',
                        'Soy cliente'),
                    const SizedBox(width: 12),
                    _opcionRol(Roles.trabajador, Icons.handyman, 'Ofrezco servicios',
                        'Soy trabajador'),
                  ],
                ),
                if (_idRol == Roles.trabajador) _datosTrabajador(),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _nombre,
                  textCapitalization: TextCapitalization.words,
                  decoration: inputDeco('Nombre'),
                  validator: (v) => _requerido(v, 'nombre'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _apellido,
                  textCapitalization: TextCapitalization.words,
                  decoration: inputDeco('Apellido'),
                  validator: (v) => _requerido(v, 'apellido'),
                ),
                const SizedBox(height: 14),
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
                  controller: _telefono,
                  keyboardType: TextInputType.phone,
                  decoration: inputDeco('Teléfono (opcional)',
                      prefix: const Icon(Icons.phone_outlined, color: C.muted)),
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty || _telefonoValido.hasMatch(t)) return null;
                    return 'Ingresa un teléfono válido';
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _contrasena,
                  obscureText: _ocultar,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: inputDeco(
                    'Contraseña (mínimo 6 caracteres)',
                    prefix: const Icon(Icons.lock_outline, color: C.muted),
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_ocultar ? Icons.visibility_off : Icons.visibility,
                          color: C.muted),
                      onPressed: () => setState(() => _ocultar = !_ocultar),
                    ),
                  ),
                  validator: (v) => (v ?? '').length < 6
                      ? 'La contraseña debe tener al menos 6 caracteres'
                      : null,
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
                    : PrimaryButton(text: 'Crear cuenta', onTap: _enviar),

                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: const Text(
                      '¿Ya tienes cuenta? Inicia sesión',
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
