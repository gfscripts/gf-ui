# Cambios / Changelog

Todas las versiones de GF UI. El formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y las versiones siguen [Semantic Versioning](https://semver.org/lang/es/).

## [1.0.0] - 2026-10-22

Primera versión pública. / First public release.

### Añadido
- Avisos (notificaciones) con 4 tipos: hecho, error, información y aviso. Se apilan (máximo 5), no se repite el mismo aviso seguido y tienen una barra de tiempo.
- Barra de progreso con animación, escenario y objetos en la mano. Se puede cancelar con X y bloquea movimiento, coche, combate o ratón.
- Texto de ayuda (`[E] Abrir garaje`) con la tecla en un recuadro, también en mitad del texto.
- `config.lua`: color, posiciones, duración, sonido, títulos y tecla de cancelar.
- Exports de cliente: `Notify`, `Progress`, `CancelProgress`, `IsProgressActive`, `ShowText`, `HideText`, `IsTextShown`.
- Export de servidor `Notify(source, data)` y evento `gf-ui:notify`.
- Compatibilidad:
  - ESX: `esx_notify`, `esx_progressbar` y `esx_textui`.
  - QBCore: `progressbar`, más la función de avisos y la de drawtext.
  - ox_lib: guía `OX_LIB.md`.
- Comando de prueba `/gfui_demo` (con `Config.Debug = true`).

### Seguridad
- No hay eventos de servidor: un jugador no puede lanzar nada en el servidor desde GF UI.
- Todo el texto se limpia antes de mostrarlo (sin HTML) y se corta a 500 caracteres.

### Arreglado (antes de publicar)
- Si se paraba o reiniciaba gf-ui en mitad de una barra, los objetos se quedaban en la mano del jugador.
- La interfaz vuelve a pedir el `config.lua` si al entrar todavía no estaba lista. Antes podía salir con el color y las posiciones por defecto.
- Un color mal escrito en `Config.Color` ya no rompe el diseño: se usa el azul por defecto.
- La opción `disable.sprint` de ox_lib ahora se tiene en cuenta.
