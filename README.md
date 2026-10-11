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
Para una base nueva, un solo script crea todo (21 tablas, procedimientos, función y catálogos de roles y categorías):

```bash
mysql --comments -u root -p < backend/sql/schema_completo.sql
```

Las migraciones numeradas de [`backend/sql/`](backend/sql/) (`001_...`, `002_...`) ya están incluidas en ese archivo. Sirven para actualizar una base que ya existe sin recrearla; los cambios futuros se agregan ahí como `003_...`, `004_...`.

El script no incluye datos de usuarios ni de la aplicación.

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
