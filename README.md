# ManoCerca (frontend Flutter)

App de profesionales de oficios cerca de ti. Solo interfaz, sin backend (datos de ejemplo).

## Cómo abrirlo en VS Code

1. Abre esta carpeta (`manocerca`) en VS Code.
2. En la terminal, dentro de la carpeta, genera las carpetas de plataforma (android, ios, web...):

   ```bash
   flutter create . --project-name manocerca
   ```

   Esto NO sobrescribe la carpeta `lib/` ni el `pubspec.yaml`.
3. Instala dependencias y ejecuta:

   ```bash
   flutter pub get
   flutter run
   ```

## Estructura

```
lib/
├── main.dart                  # Punto de entrada
├── app.dart                   # MaterialApp + tema
├── core/                      # Lo compartido
│   ├── theme/                 # colors.dart, app_theme.dart
│   ├── models/                # pro.dart, chat_msg.dart
│   ├── data/                  # mock_data.dart (datos de ejemplo)
│   └── widgets/               # avatar, stars, botones
└── screens/                   # Una carpeta por pantalla
    ├── welcome/               # 1. Bienvenida
    ├── main_shell/            # Barra de navegación inferior
    ├── home/                  # 2. Inicio
    ├── messages/              # Lista de mensajes
    ├── pro_list/              # 3. Lista de electricistas
    ├── profile/               # 4. Perfil del profesional
    ├── chat/                  # 5. Chat
    ├── request/               # 6. Solicitar servicio
    ├── confirmed/             # 7. Servicio confirmado
    └── reviews/               # 8. Reseñas
```

## Flujo de navegación

Bienvenida → Inicio → Categoría (lista) → Perfil → Contactar (Chat) / Solicitar servicio → Confirmado.
Desde el perfil, la pestaña "Reseñas" abre la pantalla de reseñas.
