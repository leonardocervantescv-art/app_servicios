# OficioLink

App móvil para conectar **clientes** con **trabajadores de oficios** (carpintería, plomería, herrería, etc.), con funciones de red social: publicaciones, reseñas, favoritos, solicitudes de trabajo y chat.

Este repositorio contiene las dos partes de la aplicación:

| Carpeta | Qué es | Tecnología |
|---|---|---|
| [`backend/`](backend/) | API REST: cuentas, servicios, publicaciones, solicitudes, reseñas, chat, notificaciones | Node.js, Express 5, MySQL 8 |
| [`frontend/`](frontend/) | App móvil | Flutter (paquete `manocerca`), Provider |

La documentación de cada parte está en su carpeta:
- [`backend/README.md`](backend/README.md) — funcionamiento explicado de forma sencilla.
- [`backend/README_TECNICO.md`](backend/README_TECNICO.md) — arquitectura, convenciones y endpoints.

## Cómo correrlo en local

### 1. Base de datos
Crea la base `servicios_app` en MySQL y aplica, en orden, los scripts de [`backend/sql/`](backend/sql/):

```
001_chat_archivos_notificaciones.sql
002_servicios_buscar_enriquecido.sql
```

Los scripts de tablas anteriores (usuarios, servicios, publicaciones, etc.) no están versionados todavía.

### 2. Backend
```bash
cd backend
cp .env.example .env     # completa DB_PASSWORD y JWT_SECRET
npm install
npm run dev              # http://localhost:3001
```

### 3. Frontend
```bash
cd frontend
flutter pub get
flutter run -d chrome    # o un emulador Android
```

La app elige sola la URL del backend: `localhost:3001` en web y `10.0.2.2:3001` en el emulador de Android. Para un celular físico o producción:

```bash
flutter run --dart-define=API_URL=http://<IP-de-tu-PC>:3001
```

## Pruebas
```bash
cd frontend && flutter test && flutter analyze
```
