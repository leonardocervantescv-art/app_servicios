# app_jenny — Documentación técnica

Backend REST en Node.js/Express + MySQL para la app de servicios/trabajos. Para una descripción funcional no técnica, ver [README.md](README.md).

## Stack

- Node.js + Express 5
- MySQL 8 (probado contra 8.0.42), driver `mysql2/promise` con pool de conexiones
- Autenticación: `jsonwebtoken` + `bcryptjs`
- Toda la lógica de negocio y las consultas viven en **procedimientos almacenados**; el código JS no arma SQL a mano (decisión explícita del proyecto para no exponer las consultas).

## Estructura

```
app.js                  # registro de middlewares globales y montaje de routers
server.js                # arranque del servidor (lee PORT)
config/
  db.js                  # pool mysql2 (lee DB_HOST, DB_USER, DB_PASSWORD, DB_NAME)
  constantes.js           # ROLES, TIPOS_PAGO, ESTADOS_SOLICITUD, PLATAFORMAS
middlewares/
  authMiddleware.js       # verificarToken, verificarRol(...roles)
utils/
  helpers.js              # entero, texto, paginacion, esUrlHttps, fechaValida, manejarError, solicitudInvalida
routes/ · controllers/ · models/
  un archivo por módulo, mismo nombre en los tres (p. ej. agendaRoutes.js -> agendaController.js -> agendaModel.js)
database/
  schema.sql              # DDL original (roles, usuarios, categorías, servicios, publicaciones, solicitudes)
```

**Importante:** `database/schema.sql` quedó desactualizado. Las tablas y procedimientos agregados después (reseñas, favoritos, reportes, bloqueos, likes, imágenes de portafolio, dispositivos de notificación, `eventos_agenda`) se entregaron como scripts SQL sueltos en la conversación y se aplicaron directo a la base, pero no se consolidaron en ese archivo. Si necesitas recrear la base desde cero, hay que juntar esos scripts — decir si se quiere que se centralicen en un solo archivo versionado.

## Variables de entorno (`.env`)

```
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=...
DB_NAME=servicios_app
PORT=3001
JWT_SECRET=...   # obligatorio: sin fallback en código, la app falla si falta
```

## Patrón de capas

```
Cliente HTTP
  -> routes/*.js            (define método + path, aplica middlewares)
  -> middlewares/authMiddleware.js  (verificarToken castea el JWT a req.usuario = {id_usuario, id_rol}; verificarRol(...) filtra por rol)
  -> controllers/*.js        (valida forma/tipos del input con utils/helpers.js, nunca reglas de negocio; llama al model; arma la respuesta HTTP)
  -> models/*.js             (una clase con métodos static; cada método hace un solo `CALL sp_...(...)`)
  -> MySQL: procedimiento almacenado (reglas de negocio, validaciones que dependen del estado en BD, transacciones)
```

Motivo de esta separación: los controllers validan *forma* (¿es un entero?, ¿trae los campos obligatorios?, ¿el enum es válido?) devolviendo 400 antes de tocar la base. Los procedimientos validan *negocio* (¿existe?, ¿te pertenece?, ¿el estado lo permite?, ¿hay traslape?) usando `SIGNAL SQLSTATE`.

### Convención de errores de negocio

Los procedimientos usan `SIGNAL SQLSTATE '45xxx'` donde `xxx` es el código HTTP que debe responder Express:

```sql
SIGNAL SQLSTATE '45404' SET MESSAGE_TEXT = 'Recurso no encontrado.';
```

`utils/helpers.js#manejarError` intercepta esto: si `error.sqlState` matchea `/^45\d{3}$/`, responde con ese código HTTP y el `sqlMessage` tal cual (pensado para mostrarse al usuario). Cualquier otro error cae a 500 genérico y se loggea con `console.error`. Todos los controllers siguen el mismo patrón:

```js
try {
  ...
} catch (error) {
  return manejarError(res, error, 'nombreDeLaFuncion');
}
```

### Transacciones y variables de sesión

Cuando un flujo necesita más de un statement atómico en el mismo `CALL` (por ejemplo un `OUT` parameter, o insertar una fila y sus imágenes), el model toma una conexión dedicada del pool (`db.getConnection()`) en vez de usar `db.query` directo, porque `pool.query` puede resolver cada llamada en una conexión distinta y las variables de sesión (`@variable`) o transacciones no persistirían entre ellas. Ver `usuarioModel.crearUsuario` (usa `OUT` + `@id_usuario`) y `publicacionModel.crear` (transacción JS con `beginTransaction`/`commit`/`rollback` porque inserta N imágenes en un loop).

Los demás procedimientos multi-statement (agenda, servicios, etc.) manejan su propia transacción **dentro** del procedimiento con `START TRANSACTION` / `DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK`, así que el model solo hace un `CALL` simple con `db.query` (pool), sin necesitar conexión dedicada.

## Autenticación y roles

- Login/registro devuelven un JWT firmado con `JWT_SECRET`, payload `{ id_usuario, id_rol }`, expira en 30 días (pendiente de acortar + refresh token antes de producción).
- `verificarToken`: exige header `Authorization: Bearer <token>`, castea el payload a `req.usuario`.
- `verificarRol(...roles)`: factory que compara `req.usuario.id_rol` (Number) contra la lista de roles permitidos. `config/constantes.js` fija `ROLES.CLIENTE = 1`, `ROLES.TRABAJADOR = 2` — **asume ese mapeo en la tabla `roles`**; si cambia, hay que actualizar la constante.
- No hay revocación de tokens ni blacklist; el logout es responsabilidad del cliente (borrar el token guardado).

## Mapa de endpoints

`Auth` = requiere `verificarToken`. `Rol` = además requiere ese rol.

| Módulo | Método y ruta | Auth | Rol |
|---|---|---|---|
| Auth | `POST /api/auth/registro` | — | — |
| Auth | `POST /api/auth/login` | — | — |
| Auth | `GET /api/auth/perfil` | Sí | — |
| Categorías | `GET /api/categorias` | — | — |
| Servicios | `GET /api/servicios/buscar?id_categoria=&tipo_pago=` | — | — |
| Trabajador | `GET /api/trabajadores/:id_usuario` | — | — |
| Trabajador | `PUT /api/trabajadores/perfil` | Sí | Trabajador |
| Trabajador | `POST /api/trabajadores/servicios` | Sí | Trabajador |
| Trabajador | `PUT /api/trabajadores/servicios/:id_servicio` | Sí | Trabajador |
| Trabajador | `DELETE /api/trabajadores/servicios/:id_servicio` | Sí | Trabajador |
| Publicaciones | `GET /api/publicaciones?id_usuario=&pagina=&limite=` | Sí | — |
| Publicaciones | `POST /api/publicaciones` | Sí | — |
| Publicaciones | `GET /api/publicaciones/:id_publicacion` | Sí | — |
| Publicaciones | `DELETE /api/publicaciones/:id_publicacion` | Sí | — |
| Publicaciones | `GET/POST /api/publicaciones/:id_publicacion/comentarios` | Sí | — |
| Publicaciones | `DELETE /api/publicaciones/:id_publicacion/comentarios/:id_comentario` | Sí | — |
| Publicaciones | `POST/DELETE /api/publicaciones/:id_publicacion/like` | Sí | — |
| Solicitudes | `POST /api/solicitudes` | Sí | Cliente |
| Solicitudes | `GET /api/solicitudes?estado=&pagina=&limite=` | Sí | — |
| Solicitudes | `GET /api/solicitudes/:id_solicitud` | Sí | — |
| Solicitudes | `PATCH /api/solicitudes/:id_solicitud/estado` | Sí | — |
| Reseñas | `POST /api/resenas` | Sí | — |
| Reseñas | `GET /api/resenas/usuario/:id_usuario` | — | — |
| Favoritos | `GET /api/favoritos` | Sí | Cliente |
| Favoritos | `POST/DELETE /api/favoritos/:id_trabajador` | Sí | Cliente |
| Moderación | `POST /api/reportes` | Sí | — |
| Moderación | `GET /api/bloqueos` | Sí | — |
| Moderación | `POST/DELETE /api/bloqueos/:id_usuario` | Sí | — |
| Dispositivos | `POST/DELETE /api/dispositivos` (body `token_fcm`) | Sí | — |
| Agenda | `GET /api/agenda?desde=&hasta=` | Sí | Trabajador |
| Agenda | `POST /api/agenda` | Sí | Trabajador |
| Agenda | `PUT/DELETE /api/agenda/:id_evento` | Sí | Trabajador |

Formato de respuesta uniforme: `{ ok: boolean, mensaje?: string, data?: any, total?: number }`.

## Reglas de negocio implementadas en procedimientos (resumen)

- **Publicaciones/comentarios/likes**: se ocultan entre usuarios con bloqueo mutuo (`bloqueos`); las publicaciones y usuarios usan soft delete (`activo`), nunca se borran físicamente salvo comentarios/likes propios.
- **Solicitudes**: no se puede solicitar a uno mismo; solo el trabajador acepta/rechaza desde `Pendiente`; cualquiera cancela desde `Pendiente`/`Aceptado`; solo se completa desde `Aceptado`.
- **Reseñas**: solo sobre solicitudes en estado `Completado`, una reseña por autor por solicitud, calificación 1-5 (`CHECK` + validación en procedimiento).
- **Agenda**: valida `fecha_fin > fecha_inicio` y rechaza traslapes con otro evento del mismo trabajador (`SIGNAL '45409'`).
- **Roles**: el registro (`sp_usuario_crear`) crea automáticamente un `perfiles_trabajador` si `id_rol = 2`.

## Cómo probar

No hay suite de tests automatizada todavía. El flujo usado durante el desarrollo:

1. `npm run dev` (ejecuta `node server.js`; no hay recarga automática — reinicia manualmente tras cada cambio).
2. Postman/Insomnia/curl contra `http://localhost:<PORT>`, con un usuario de prueba registrado vía `/api/auth/registro` y su token.
3. Para validar sintaxis y rutas/validaciones sin tocar la base, se usó `node --check` por archivo + un script Node que levanta `app.js` en un puerto efímero y hace `fetch` a los endpoints verificando el código HTTP esperado (sin mocks de BD: los casos que llegan a MySQL se validan aparte, contra la base real, limpiando los datos de prueba al final).

## Pendientes conocidos (ver también README.md)

- Endpoints de editar perfil propio, eliminar cuenta, cambiar/recuperar contraseña.
- Endpoints de portafolio (tabla `imagenes_portafolio` ya existe, sin CRUD expuesto).
- Puente con Firebase Admin SDK (`createCustomToken`) para que el chat/Storage/FCM reconozcan al mismo `id_usuario`.
- Envío real de notificaciones push (hoy solo se registra el token en `dispositivos_notificacion`).
- `servicioModel.buscarServicios` no pagina, no filtra por texto libre, no excluye inactivos/bloqueados y devuelve el teléfono del trabajador en una ruta pública — revisar antes de exponerlo a producción.
- Endurecimiento pendiente: `helmet`, rate limiting en auth, CORS restringido a los orígenes reales, rechazar login de usuarios con `activo = FALSE`, y que el registro valide `id_rol` contra los roles permitidos en vez de aceptar cualquier valor.
- Desfase de zona horaria en fechas devueltas por `mysql2` (ver conversación de la agenda) — pendiente decidir `dateStrings: true` vs. conversión explícita.
- Consolidar en `database/schema.sql` todas las tablas/procedimientos aplicados después del archivo original.
