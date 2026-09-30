# app_jenny — Backend

Backend de una app móvil para conectar **clientes** que buscan un servicio (carpintería, herrería, plomería, etc.) con **trabajadores** que lo ofrecen. Además de ser un buscador de servicios, funciona como una pequeña red social: los trabajadores pueden publicar su trabajo, recibir comentarios y likes, y los clientes pueden calificarlos después de contratarlos.

Este repositorio es **solo el backend** (el servidor que guarda y entrega la información). El frontend, que es donde el usuario realmente ve y usa la app, se construirá en Flutter en otra carpeta/proyecto aparte.

## ¿Cómo funciona en términos simples?

Piensa en el backend como el "cerebro" de la app: guarda todos los datos (usuarios, servicios, publicaciones, citas) y decide qué puede hacer cada quien. Flutter (el frontend) es la "cara" que ve el usuario: pantallas, botones, formularios. Flutter nunca guarda los datos importantes por su cuenta — cada vez que necesita mostrar o cambiar algo, se lo pide a este backend por internet.

Para eso, Flutter y el backend se hablan con **peticiones HTTP**: Flutter manda una petición (por ejemplo "dame los servicios de la categoría Carpintería") y el backend responde con la información en un formato llamado JSON, que es básicamente una lista organizada de datos.

Hay dos piezas más en la arquitectura, pero ninguna vive en este proyecto:

- **MySQL**: donde se guardan realmente los datos (usuarios, servicios, publicaciones, citas, etc.). El backend es el único que le habla directamente a MySQL.
- **Firebase**: se usa aparte para el **chat** entre cliente y trabajador, para **guardar imágenes** (fotos de perfil, publicaciones, trabajos), y en el futuro para **notificaciones push**. Flutter se conecta a Firebase directamente para esas tres cosas, sin pasar por este backend.

## Los dos tipos de usuario

- **Cliente**: busca y contrata trabajadores, puede publicar contenido, comentar, dar like, calificar, guardar favoritos y reportar/bloquear.
- **Trabajador**: además de todo lo anterior, tiene un perfil con biografía y sus servicios (categoría, tipo de pago, precio), y ahora también su propia **agenda/calendario** para bloquear horarios.

Cuando alguien se registra, dice si es cliente o trabajador, y eso determina qué puede hacer en la app. El backend revisa ese rol en cada petición sensible (por ejemplo, solo un trabajador puede crear un servicio o un evento de agenda).

## Cómo sabe el backend quién eres

Cuando el usuario inicia sesión, el backend le entrega una especie de "gafete digital" (token). Flutter guarda ese gafete y lo muestra en cada petición siguiente, así el backend sabe quién es sin pedir la contraseña otra vez. Ese gafete expira solo después de un tiempo, por seguridad.

## Qué puede hacer la app hoy (módulos ya construidos)

1. **Cuentas** — registro, inicio de sesión y ver el perfil propio.
2. **Categorías** — lista de tipos de trabajo (Carpintería, Herrería, etc.) para armar los filtros de búsqueda.
3. **Perfil y servicios del trabajador** — ver el perfil público de un trabajador (con su calificación promedio), y que el trabajador administre sus servicios (qué ofrece, tipo de pago, precio).
4. **Búsqueda de servicios** — el cliente busca por categoría y, opcionalmente, por tipo de pago (Día, Destajo, Por trabajo, Por hora).
5. **Publicaciones (red social)** — crear publicaciones con imágenes, comentarlas y darles like. Se filtran automáticamente las publicaciones de gente que te haya bloqueado o a quien hayas bloqueado.
6. **Solicitudes de trabajo** — el cliente le pide trabajo a un trabajador; el trabajador acepta, rechaza o completa la solicitud; cualquiera puede cancelarla mientras siga pendiente.
7. **Reseñas** — al completar una solicitud, cliente y trabajador pueden calificarse mutuamente (1 a 5 estrellas + comentario).
8. **Favoritos** — el cliente guarda trabajadores para encontrarlos rápido después.
9. **Reportes y bloqueos** — para mantener la comunidad segura, requisito habitual de Play Store cuando hay contenido generado por usuarios.
10. **Notificaciones (preparación)** — el backend ya puede guardar el identificador del celular de cada usuario para mandarle notificaciones push más adelante; el envío real se conectará después con Firebase.
11. **Agenda / calendario del trabajador** — el trabajador puede bloquear horarios propios (citas, trabajos, tiempo ocupado). El sistema no deja crear dos eventos que se crucen en el mismo horario. Es privada: solo el trabajador ve su propia agenda.

## Qué falta todavía

- Editar el perfil propio (nombre, teléfono, foto) y eliminar la cuenta.
- Recuperar/cambiar contraseña.
- Conectar este backend con Firebase para que el chat y las notificaciones reconozcan a los mismos usuarios.
- Enviar notificaciones push de verdad (hoy solo se guarda el identificador del celular).
- Búsqueda más completa (por texto libre, ordenar por calificación, etc.).
- Geolocalización y verificación de identidad del trabajador — decididas a propósito para el final del proyecto, porque agregan trámites y permisos adicionales para publicar en Play Store.
- Ajustes de seguridad antes de publicar la app (HTTPS, límites de intentos de login, etc.).

## Cómo debe conectarse Flutter con todo esto

1. Flutter le pide al backend con peticiones HTTP normales (`GET`, `POST`, `PUT`, `DELETE`) todo lo relacionado con cuentas, búsqueda, publicaciones, solicitudes, reseñas, favoritos, moderación y agenda.
2. Después de iniciar sesión, Flutter guarda el token de forma segura en el celular (no en cualquier archivo) y lo manda en cada petición a las rutas que lo requieren.
3. Para el **chat**, Flutter se conecta directo a Firebase (no a este backend). El identificador de cada usuario en Firebase será el mismo `id_usuario` que usa este backend, para poder relacionar todo.
4. Para **imágenes** (fotos de perfil, publicaciones, portafolio), Flutter sube el archivo directo a Firebase Storage, obtiene el link de la imagen, y ese link es lo que se le manda al backend para guardarlo junto con la publicación o el perfil.
5. El backend responde siempre en el mismo formato: `{ "ok": true/false, "mensaje": "...", "data": ... }`, así Flutter puede manejar todas las respuestas de forma consistente, sepa si algo salió bien o mal, y mostrar el mensaje de error tal cual cuando `ok` es `false`.
