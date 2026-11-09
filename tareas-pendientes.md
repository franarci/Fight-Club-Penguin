# Fight Club Penguin — tareas para la entrega del 31 de octubre de 2026

Actualizado: 30 de octubre de 2026. Fuente: acuerdos con el usuario en este chat y revisión del repositorio.

## Cómo usar esta lista

El editor Godot del usuario está en español: dar instrucciones con nombres de menús en español. Conservar los identificadores técnicos de nodos, recursos, propiedades y acciones cuando aparecen sin traducir. Para confirmar y volver, reutilizar `selection_accept` y `selection_cancel` con `MultiplayerInput`, sin duplicar mapeos innecesariamente en `ui_*`.

Modalidad vigente desde el 27/10/2026: el asistente implementa cambios de código y escenas; el usuario los lee, prueba y solicita ajustes. Bajo ningún punto de vista hacer commits ni push. Trabajar en una rama local por feature, sin publicar cambios.

No agregar comentarios de ningún tipo al código, incluidos comentarios de documentación e inline. Explicar decisiones y aclaraciones por el chat.

Cada feature numerada se implementará en una rama propia y se integrará mediante pull request. El usuario puede encargarse del push y del PR. Crear una rama al acordar la tarea y su base. La primera feature acordada es el menú principal, en `feature/menu-principal`, desde `weapons_2` (`af545f4`). Evitar mezclar cambios de armas, a cargo del compañero, con cambios de interfaz y flujo de partida.

Las casillas vacías son trabajo pendiente o pendiente de comprobar. Las marcadas indican evidencia concreta de implementación o prueba; no significan que toda la feature esté terminada. Los documentos de primera entrega en la carpeta padre describen el hito anterior del 9 de octubre: este archivo define el nuevo alcance.

## 1. Menú principal

Prioridad actualizada: dejar lo pendiente de Home para más adelante. Continuar con el ítem 3, correcciones del selector. Conservar los avances existentes.

- [ ] Completar el menú principal.
    - [ ] Mostrar el nombre Fight Club Penguin con una fuente adecuada, sin exigir animación del título.
    - [x] Agregar Jugar y abrir la selección de personajes (implementado; usuario confirmó los cambios).
    - [x] Configurar Home.tscn como escena inicial del proyecto.
    - [ ] Probar el inicio completo y el regreso a Home con los ajustes finales.
    - [x] Agregar regreso desde el selector mediante Escape/Círculo/B sin slots ocupados, sin botón visible (implementado; prueba manual pendiente).
    - [ ] Decisión pendiente: ¿el dispositivo que pulsa Jugar ocupa automáticamente el primer slot? Si se acepta, conservar su identidad al cambiar de escena y definir comportamiento con mouse.
    - [ ] Probar regreso con slots vacíos, ocupados y durante la cuenta regresiva, y volver a entrar.
    - [x] Reemplazar el menú dedicado a controles por ayuda contextual y tutorial previo a la partida; retirar el botón Controles de Home.
    - [ ] Agregar Opciones y abrir su pantalla.
    - [ ] Permitir navegación y activación con teclado y joystick; clic con mouse.
    - [ ] Gestionar entradas y salidas entre pantallas sin acumular escenas ni estado de partidas anteriores.

## 2. Ayuda contextual y tutorial

Reemplaza la propuesta anterior de un menú dedicado a controles. Retomado después de traducir la interfaz a inglés, en `feature/tutorial-and-context-help`, desde `68f00df`.

- [ ] Extender la franja de ayuda contextual a otras pantallas.
    - [x] Implementar una sola fila negra inferior con texto blanco e iconos PNG según los dispositivos asociados; agrupar acciones y evitar duplicar iconos iguales.
    - [x] Recentrar las tarjetas sobre el espacio disponible, manteniendo ancho y alto fijos, sin el botón de espera que ocupaba la parte inferior.
    - [x] Incorporar los PNG de Kenney Input Prompts (CC0), su licencia y procedencia. Reutilizar el componente de iconos en el tutorial y la confirmación.
    - [x] Mostrar botones y descripciones según pantalla, estado y tipo de dispositivo (PlayStation, Xbox o teclado/mouse).
    - [x] Reutilizar los mapeos actuales sin duplicar acciones.
    - [x] En el selector, explicar incorporarse, seleccionar, cambiar, abandonar slot y volver al menú según corresponda.
- [x] Sustituir el inicio automático por una confirmación modal cuando hay al menos dos participantes, todos listos y nadie eligiendo.
    - [x] Retirar el botón permanente y los textos «Waiting for at least two players» y «Waiting for all players to be ready».
    - [x] Mostrar «Ready to play?», «Let's play» y «Keep choosing», con iconos de aceptar y cancelar según los participantes.
    - [x] Confirmar únicamente con X (PlayStation), A (Xbox) o Enter (teclado), mostrando un único icono de confirmación por tipo de dispositivo. Cancelar vuelve al selector conservando slots y personajes, sin reabrir inmediatamente la pregunta.
    - [x] Esperar a que se suelten los botones para evitar confirmar con el mismo pulso de la última selección o cancelar dos veces.
    - [x] Permitir reabrir la pregunta con el botón de incorporarse de un participante ya listo.
    - [x] Actualizar y cerrar la confirmación si se desconecta un mando y deja de cumplirse el mínimo de participantes.
- [x] Mostrar un tutorial previo al combate inspirado en la referencia de Crash Bash.
    - [x] Presentar objetivo y controles sobre la arena detenida.
    - [x] Incluir movimiento, dash/empuje, ataque y pausa con sus botones reales.
    - [x] Permitir que cualquier jugador avance el tutorial, sin exigir confirmación individual de todos. Quitar el texto «Any player can advance»; mostrar solo los iconos de continuar.
    - [x] Al terminar el tutorial, reutilizar el contador existente y comenzar el combate al finalizar.
    - [x] Retirar el contador del selector; el nuevo flujo será selector → tutorial → contador → combate.
    - [x] En revancha, omitir el tutorial y repetir únicamente el contador 3, 2, 1, GO!, manteniendo el combate detenido hasta terminar.
    - [ ] Dejar demostraciones animadas y artística para más adelante.

Implementación actual del flujo previo a partida: la pregunta Ready to play? aparece automáticamente cuando hay al menos dos participantes y todos están listos. Solo una confirmación posterior abre el tutorial. Keep choosing cierra la pregunta conservando las selecciones; Change en cada tarjeta o el botón de volver permiten editar. La franja usa iconos derivados de las acciones existentes y detecta el tipo de mando; un mando genérico conserva la disposición Xbox. Los iconos iguales se agrupan para caber en una sola fila. Las tarjetas conservan 220 × 500 y quedan centradas sobre la franja. La revancha omite el tutorial y repite la cuenta regresiva antes de habilitar el combate. No se agregaron controles nuevos ni cambios al combate.

- [x] Pruebas automatizadas de confirmación explícita, cancelación/reapertura sin perder selecciones, protección contra botones mantenidos, iconos PNG y eliminación de duplicados, cuatro tarjetas y fila inferior dentro de 1152 × 648, avance del tutorial, arena detenida, cuenta regresiva y reconexión.
- [x] Regresión automatizada de pausa, resultados/revancha y reconexión.
- [ ] Probar visualmente el nuevo flujo, incluidos mandos PlayStation/Xbox y mouse.

## 3. UX del selector de personajes e idioma

Próxima feature priorizada por el usuario. Usar una rama propia después de guardar/versionar los avances de Home; no mezclar ambas features en un PR.

- [ ] Completar los estados y feedback del selector.
    - [x] Reemplazar las imágenes de los cuatro personajes por los WebP provistos por el usuario en `assets/textures/character_select/`, conservando proporciones y ancho fijo de los slots.
    - [x] Pasar toda la interfaz a inglés por decisión del usuario (29/10/2026): Home, selector y atributos, cuenta regresiva, resultado, pausa y reconexión. Rama `feature/english-ui`.
    - [x] Verificar importación sin errores de compilación y regresiones automatizadas de cuenta regresiva, resultados, pausa y reconexión en Godot 4.7.2, sobre copia temporal.
    - [ ] Validar visualmente los textos en inglés y su distribución con el usuario.
    - [x] Alternar el borde entre blanco y negro durante la elección, sin ocultarlo ni alterar el fondo del slot.
    - [x] Fijar un borde legible cuando el jugador confirma.
    - [x] Ocultar flechas y Seleccionar al confirmar; mostrar Cambiar.
    - [x] Implementar los estados Slot libre, Eligiendo y Listo.
    - [x] Cambiar/volver desde Listo: desconfirmar sin perder slot ni dispositivo y habilitar otra elección.
    - [x] Cambiar/volver desde Eligiendo: abandonar el slot y regresar a la espera de Start.
    - [x] Ocultar el borde al abandonar.
    - [x] Conectar los botones visibles a la selección y al cambio, reutilizando la lógica del mando.
    - [x] Sincronizar el estado listo del recuadro y PlayerManager; la confirmación de inicio solo existe con al menos dos participantes y todos listos.


- [ ] Agregar el prototipo de habilidades por personaje.
    - [x] Ubicar el apartado debajo de la imagen del pingüino y encima de los botones.
    - [x] Mostrar Velocidad, Fuerza y Resistencia, cada una con su etiqueta y barra de nivel.
    - [x] Definir valores configurables por pingüino y una escala común para comparar personajes.
    - [x] Actualizar las tres barras al navegar entre los personajes disponibles.
    - [x] Mantener el ancho estable de las columnas al mostrar el apartado.
    - [x] Vincular las barras de Gunner y Demolisher a las escenas de combate: velocidad de movimiento, daño por impacto del arma inicial (con multiplicador melee) y masa como resistencia al empuje.
    - [ ] Coordinar futuras habilidades y completar el balance de Explorer y Hunter; conservan el perfil provisional.
    - [x] Mostrar las diferencias reales de Gunner y Demolisher sin modificar su balance; conservar valores provisionales para Explorer y Hunter.
    - [x] Implementar el prototipo en el selector; valores predeterminados conservados por acuerdo del usuario.

## 4. Cuenta regresiva visual

Flujo actualizado el 29/10/2026: `PreMatch` reutiliza `CountdownOverlay` tras el tutorial. El selector ya no contiene temporizador ni inicia automáticamente. El combate permanece detenido hasta terminar 3, 2, 1 y GO!.

- [ ] Completar la cuenta regresiva animada.
    - [x] Usar un Timer único tras el tutorial, una vez iniciado explícitamente con al menos dos jugadores listos.
    - [x] Mostrar 3, 2, 1 y ¡YA! en un panel cuadrado superpuesto.
    - [x] Hacer crecer cada texto desde pequeño hasta aproximadamente el 75 % del alto de pantalla, reiniciando la escala en cada paso.
    - [x] Sincronizar animación, temporización e inicio de partida, sin dos mecanismos que compitan.
    - [x] Durante la selección, deshabilitar Start match si cambia la preparación o la cantidad de participantes. Durante el tutorial o contador, una desconexión suspende el flujo hasta recuperar el mando y continuar; el contador reinicia desde 3.
    - [x] Evitar múltiples inicios de partida y bloquear incorporaciones tardías durante tutorial y contador.
    - [ ] Validar la propuesta de cuatro intervalos de un segundo: 3, 2, 1 y ¡YA! (cuatro segundos totales).

Implementación original en `feature/cuenta-regresiva`, desde el selector guardado en `6e80836`. La escena reutilizable CountdownOverlay presenta el texto y anima el crecimiento mediante Tween sin capturar clics. Actualmente un Timer de PreMatch controla los cuatro pasos después del tutorial. GO! también dura un segundo: cuatro segundos totales. No hay cuenta automática en el selector.

- [x] Prueba automatizada `tests/countdown_smoke.gd`, actualizada al nuevo flujo: inicio explícito, mínimo de participantes, cambios de preparación, tutorial compartido, crecimiento y secuencia del contador, simulación detenida y reconexión durante la cuenta. PASS en Godot 4.7.2, copia temporal.
- [x] El usuario probó y aprobó el funcionamiento de la cuenta regresiva; artística pendiente para más adelante.
- [ ] Revisión de código por el usuario. No se realizaron commits ni push.

## 5. Vidas, salud, caídas y eliminación

- [ ] Validar e integrar el ciclo de vidas con el resto del juego.
    - [x] La rama weapons_2 conecta salir del hielo con lose_life().
    - [x] El daño reduce HP; llegar a cero también consume una vida.
    - [x] Hay protección contra pérdidas repetidas, demora de respawn, restauración de HP y protección temporal al reaparecer.
    - [x] La última vida elimina al personaje y emite eliminated(slot).
    - [x] El HUD recibe cambios de HP y vidas.
    - [ ] Comprobar el flujo con mandos reales y actualizar la interfaz si se detectan inconsistencias.
    - [ ] Probar reapariciones en presencia de otros personajes y decidir cómo resolver solapamientos.
    - [ ] Revisar junto al compañero el balance y las reglas definitivas de HP frente a corazones.

## 6. Final de partida y revancha

- [ ] Completar resultados y repetición de partida.
    - [x] Contabilizar participantes vivos a partir de la eliminación definitiva, no de la muerte temporal previa al respawn.
    - [x] Detectar al último jugador y mostrar ¡Ganó el jugador N!.
    - [x] Mostrar empate si los últimos participantes son eliminados antes de resolver el resultado diferido.
    - [x] Detener movimiento, ataques, proyectiles y eventos de ronda al mostrar el resultado.
    - [x] Agregar Jugar de nuevo conservando participantes, personajes y dispositivos; restaura la ronda y muestra 3, 2, 1, GO! antes de habilitar el combate.
    - [x] Restaurar vidas, HP, posiciones, cooldowns, protección, estados y HUD; eliminar proyectiles y timers de la ronda anterior.
    - [x] Agregar Volver al menú principal y limpiar participantes y objetos de partida.
    - [ ] Verificar varias rondas consecutivas y el regreso al menú sin duplicaciones.

Implementación en `feature/resultado-partida`. `main.gd` escucha la señal de eliminación, evalúa los supervivientes de forma diferida y pausa el árbol al cerrar la ronda. `RoundResult.tscn` muestra el resultado y opera con la simulación pausada. La revancha recarga Main y usa una intención de revancha en PlayerManager; volver a Home limpia esa intención y los participantes. Pantalla con botones operables por mouse/teclado y selección/navegación con cruceta del mando, reutilizando las acciones existentes.

- [x] `tests/round_result_smoke.gd`: comprobaciones automatizadas de daño, caída sin doble descuento, respawn y protección, eliminación, ganador, empate, limpieza y restauración en revancha y regreso al menú. PASS en copia temporal con Godot 4.7.2.
- [ ] Prueba visual y con mandos reales por el usuario; revisión de código antes de cerrar la feature.


- [ ] Mejora futura: secuencia de festejo antes del cartel de ganador.
    - [ ] Al definir al ganador, detener el combate y dirigir la cámara hacia él.
    - [ ] Hacer zoom y centrar al pingüino manteniendo su cuerpo completo dentro del encuadre, incluso cerca de los bordes de la arena.
    - [ ] Crear una animación de festejo; propuesta: saltar y agitar las aletas de un lado a otro.
    - [ ] Mostrar el festejo durante dos segundos y después presentar el cartel y los botones de resultado actuales.
    - [ ] Mantener al ganador festejando de fondo mientras se muestra el cartel y se elige Jugar de nuevo o Volver al menú; la animación solo termina al abandonar esa pantalla.
    - [ ] Permitir que cámara y festejo se animen aunque la simulación de combate esté detenida.
    - [ ] Restaurar cámara y estados al jugar de nuevo o volver al menú.
    - [ ] En caso de empate, omitir el enfoque en un ganador y conservar el resultado de empate.

## 7. Pausa y confirmación de regreso

- [ ] Completar el menú de pausa.
    - [x] Mapear la pausa para teclado y mandos, diferenciándola por contexto del Start del selector.
    - [x] Permitir pausar a cualquier participante.
    - [x] Congelar la simulación y mantener operativa la interfaz de pausa.
    - [x] Mostrar un panel central superpuesto con Continuar, Opciones y Volver al menú principal.
    - [x] Dar control del menú exclusivamente al dispositivo que pausó, sin interferencias de otros mandos.
    - [ ] Abrir opciones de Música y Efectos desde la pausa.
    - [x] Confirmar el regreso: ¿Volver al menú principal? Se perderá la partida actual.
    - [x] Ofrecer Volver al menú y Cancelar; cancelar conserva la pausa.
    - [x] Restaurar correctamente la simulación al continuar o iniciar otra partida.

Implementado en `feature/menu-pausa`, desde `a1d1da5`. Escape o Start/Options pausa solamente durante una ronda y para un participante con vidas. El menú conserva el control del dispositivo que pausó; si fue teclado, admite también mouse. Círculo/B o Escape vuelve de la confirmación a pausa y desde pausa continúa la partida. Opciones está visible pero deshabilitado: la integración real de Música/FX sigue pendiente, sin controles de audio ficticios.

- [x] `tests/pause_smoke.gd`: contexto de pausa, simulación detenida y reanudación, filtrado por dispositivo, navegación/confirmación/cancelación, vuelta a Home y convivencia con resultado y revancha. PASS en Godot 4.7.2.
- [x] Regresión automatizada de resultado y cuenta regresiva después de integrar pausa.
- [ ] Probar visualmente y con mandos físicos antes de cerrar la feature.
- [x] Desconexión del mando dueño de la pausa: pasa al modo compartido del ítem 8 y permite recuperar el mando o volver al menú.

## 8. Desconexión y reconexión de mandos

- [x] Pausar la partida cuando se desconecta el mando de un participante con vidas.
    - [x] Reservar su slot y conservar personaje, posición, salud y vidas.
    - [x] Recuperar automáticamente el slot cuando la identidad disponible permite una asociación única.
    - [x] Ante varios mandos indistinguibles, mostrar «Soy el jugador N» y confirmar desde el mando que se quiere asociar.
    - [x] Actualizar el dispositivo del pingüino y de su arma al recuperar el slot.
    - [x] Permitir que cualquier mando conectado, teclado o mouse maneje esta pausa y pueda volver al menú principal.
    - [x] Convertir la pausa exclusiva en compartida si se desconecta un participante, incluido el dueño de la pausa.
    - [x] Deshabilitar Continuar mientras falten mandos; al recuperarlos, esperar que se elija Continuar sin reanudar automáticamente.
    - [x] Cancelar la confirmación de salida cuando cambia el estado de conexión para evitar confirmaciones accidentales.
    - [x] Mantener el control exclusivo del jugador que pausó durante una pausa voluntaria normal.
- [x] Pruebas automatizadas de recuperación única y ambigua, conservación de estado, reasignación de armas, pausa compartida y salida al menú. Regresión de pausa, resultado y cuenta regresiva.
- [x] El usuario confirmó que probó y commiteó la feature de reconexión el 29/10/2026.
- [ ] Validar desconexión y reconexión con mandos físicos en macOS y Windows, incluidos dos mandos iguales.
- [x] Durante la selección, desconectar libera el slot, retira la identidad del mando y actualiza la confirmación de inicio. Durante tutorial y partida se conserva la recuperación de slot.

Decisiones acordadas: 1.b, recuperación automática si es inequívoca y confirmación explícita si hay ambigüedad; 2.b, pausa compartida ante desconexiones; 3.b, reanudación manual cuando todos recuperen su mando. La identificación usa los datos disponibles del dispositivo; sin identificación suficiente se pide elegir el jugador. Implementado en `feature/reconexion-mandos`.

## 9. Opciones y audio

- [ ] Completar las opciones compartidas de audio.
    - [ ] Separar Música y Efectos (FX) en la interfaz y en el control de audio.
    - [ ] Usar una única configuración tanto en menú principal como en pausa.
    - [ ] Mantener la preferencia al cambiar de pantalla y al reiniciar una ronda.
    - [ ] Incorporar música y efectos después de la clase sobre audio, sin presentar controles vacíos como funcionalidad terminada.
    - [ ] Comprobar que desactivar una categoría no silencie la otra.
    - [ ] Decidir si las preferencias deben persistir al cerrar la aplicación; aún no acordado.

## 10. Coordinación e integración de armas

- [ ] Cerrar con el compañero la integración de combate, evitando duplicar su trabajo.
    - [x] Hay recursos base de armas, rifle, proyectiles y acción attack en weapons_2.
    - [x] El proyectil excluye al emisor, comprueba el segmento recorrido, aplica daño y se elimina por impacto/tiempo/salida de pantalla.
    - [x] Hay orientación visual del arma, barra de HP y nuevas animaciones/sprites de Gunner y Demolisher.
    - [x] Hay apuntado en ocho direcciones, recarga entre disparos y correcciones de posición/orden visual del arma.
    - [x] El editor muestra una vista previa del sprite sin ejecutar la lógica de partida.
    - [x] El compañero agregó cinco scripts de pruebas de armas, proyectiles, poses del dash y salud/vidas; su ejecución completa sigue pendiente de corregir, según los resultados al final de este archivo.
    - [x] Integrar el arpón de Hunter: estocada de mayor alcance, carga configurable y lanzamiento que atrae al rival y regresa a la mano; pendiente de ajuste visual y prueba manual.
    - [ ] Confirmar personajes, equipamientos y controles definitivos antes de preparar la pantalla de controles.
    - [ ] Ajustar el balance de daño, alcance, carga y tirón del arpón tras probarlo con mandos.
    - [x] Acordar la base de las próximas tareas: el usuario eligió weapons_2 (`af545f4`).
    - [ ] Coordinar la integración de weapons_2 en master y la base de cada PR.
    - [ ] Probar que armas respeten pausa, eliminación, revancha y limpieza de proyectiles.

## Prioridades para cerrar la entrega del 31

- [ ] Validar visualmente este selector y sus iconos con teclado y los mandos físicos disponibles; comprobar confirmación, cancelación y reconexión.
- [x] Sustituir las imágenes del selector por gunner.webp, demolisher.webp, explorer.webp y hunter.webp, provistos por el usuario.
- [ ] Coordinar la integración final de armas y habilidades; conectar las barras del selector a los valores acordados cuando estén disponibles.
- [ ] Probar el recorrido completo: Home → selección → confirmación → tutorial → contador → combate → resultado → revancha/menú, incluyendo pausa y desconexión.
- [ ] Integrar las ramas y preparar la entrega con el compañero; commits, push y PR a cargo del usuario.

En espera por decisión del usuario: Opciones y audio. Mejoras para después: paleta y fondos, artística del tutorial/contador, festejo del ganador, luces de mandos y ocupación automática del primer slot. No son condiciones adicionales para cerrar esta entrega.

## Revisión de ramas y base de trabajo

Consulta remota y fetch realizados durante esta tarea. GitHub no expone el orden de los pushes mediante las fechas de commit: se identifica el commit alcanzable desde las ramas con fecha de committer más reciente.

- weapons_2: af545f47174a5f930bf97d973523d54fe0d9c1d4, 16/10/2026 16:20:50 -03, «agrego demolisher sprites, cambios a las armas». Rama actual actualizada con fast-forward; incluye master.
- master: 5edee29, integración de la demo de hielo y dash mediante PR #4.
- layout-adjustments-and-collision: 2a77f14, demo de hielo, colisiones, empuje y retorno; integrada en master.
- multiplayer: cbc1431, multijugador, HUD y correcciones de animaciones/colores; integrada en master.
- penguinCharacter: 0ef8149, base de movimiento por estados; antecedente integrado.
- weapons: c74ec64, prototipo antiguo de armas; no usar como reemplazo automático de weapons_2.
- player-selection-adjustments: ya no existe en GitHub; su rama local permanece y su trabajo está integrado.

Se creó `feature/menu-principal` desde `weapons_2` (`af545f4`) el 19/10/2026. Se trabajará primero en el ítem 1 mediante guía paso a paso en Godot. La rama todavía no se subió y no tiene PR. Para integrar, usar como base `weapons_2` mientras sus cambios no estén en `master`, o coordinar primero su integración; evitar un PR que incluya accidentalmente todo el trabajo de armas.

## Comprobaciones técnicas de esta revisión

Se importó una copia temporal con Godot 4.7.2 y se ejecutaron los cinco scripts de pruebas existentes. La importación no mostró errores de compilación; el entorno restringió la escritura de ajustes/logs fuera del workspace. No se realizó una partida manual con mandos.

- [x] dash_pose_smoke: terminó con PASS.
- [ ] Revisar weapons_2_smoke: falló una aserción en línea 33.
- [ ] Revisar projectile_smoke: falló una aserción en línea 53.
- [ ] Revisar upward_weapon_smoke: falló una aserción en línea 20.
- [ ] Revisar health_lives_smoke: accede a can_attack sobre una referencia nula en línea 80.

Estos resultados no establecen por sí solos si el fallo está en el juego, en supuestos desactualizados de las pruebas o en el entorno. No declarar validada la rama completa hasta investigarlos. No se corrigieron scripts durante esta tarea.


## 11. Rediseño visual — más adelante

- [ ] Diseñar una identidad visual común antes de trasladar cambios a Godot.
    - [ ] Explorar referencias y prototipos de pantallas, por ejemplo en Figma o Penpot.
    - [ ] Revisar paleta, tipografías, fondos, tarjetas y estados interactivos.
    - [ ] Considerar fondos animados y definir sus movimientos primero en un boceto.
    - [ ] Revisar contraste y legibilidad en monitor y proyector, sin depender solo del color o del parpadeo.
    - [ ] Evaluar borde doble, estados de texto y movimiento opcional; por ahora conservar el borde blanco/negro acordado.
    - [ ] Implementar el diseño elegido más adelante, en una rama propia y con guía paso a paso.


## 12. Chiche opcional: luz del joystick

Mejora futura, sin prioridad para la entrega del 31 de octubre.

- [ ] Sincronizar la luz de los mandos compatibles con el color asignado al jugador.
    - [ ] Consultar compatibilidad con `Input.has_joy_light(device)` antes de aplicar el color mediante `Input.set_joy_light(device, color)`.
    - [ ] Usar el color del jugador definido en PlayerManager.
    - [ ] Definir qué color dejar al abandonar el slot o volver al menú.
    - [ ] Reaplicar el color al reconectar el mando si corresponde.
    - [ ] Probar con DualShock 4 en macOS y Windows, según los equipos disponibles.
    - [ ] Mantener el juego operativo sin esta función cuando el mando no la soporte; no asumir luces RGB en mandos Xbox o Switch.

- [ ] Rediseñar la artística de la cuenta regresiva más adelante; el usuario aprobó el funcionamiento actual el 27/10/2026.

Ajuste de alcance del 30/10/2026: quedan tres horas para entregar. Priorizar correcciones de UI, integración del trabajo del compañero y prueba completa. Las imágenes nuevas se integraron al recibir los archivos WebP. Música solo si queda margen después de validar la integración. No hay archivos de audio en el repositorio actual.

## Integración de entrega — 30/10/2026

- [x] Simplificar Ready to play?: un único botón de avance por dispositivo (X en PlayStation, A en Xbox, Enter en teclado), conservando cancelar y el clic con mouse.
- [x] Quitar «Any player can advance» del tutorial.
- [x] Consultar GitHub e integrar `origin/master` fijado en `b5acb6f` (30/10/2026 14:39 -03): martillo y equipamiento intercambiable, balance, animaciones, colores de equipo, cámara compartida, arena y olas.
- [x] Resolver los cruces de Main y selector conservando Home en inglés, pausa, resultados/revancha, reconexión, tutorial y ayuda con iconos.
- [x] Mantener el selector en MenuLayer (CanvasLayer) para que la cámara no desplace su interfaz. Usar la señal selection_finished para abrir el tutorial.
- [x] Probar el recorrido integrado con Gunner y Demolisher, armas rifle/martillo, cámara, límite poligonal, eliminación, ganador, revancha y regreso a Home (`tests/integration_flow_smoke.gd`).
- [x] Regresión de confirmación, tutorial/contador, pausa, resultados y reconexión; comprobación de combate, equipamiento, paleta y proyectiles.
- [ ] Hacer una partida manual completa con los mandos físicos antes de entregar.
- [ ] Revisar y completar el commit de merge y push: a cargo del usuario. Se dejaron todos los conflictos resueltos y archivos preparados, sin crear commits ni hacer push.
- [ ] Música opcional: priorizar primero la prueba manual; no se incorporó audio ni hay una pista disponible en el repositorio.

Las cuatro imágenes nuevas ya están conectadas desde `assets/textures/character_select/`.

Se contrastaron las pruebas fallidas de combate/animaciones con una copia limpia de `b5acb6f`. Doce pruebas también fallan en esa base: `gunner_rotation`, `demolisher_dash_timeline`, `hand_attachment`, `directional_animation`, `melee_knockback`, `melee_swing`, `shared_camera`, `upward_weapon`, `standalone_weapons`, `dash_pose`, `weapons_2` y `health_lives` (todas con sufijo `_smoke.gd`). Algunos supuestos quedaron desactualizados, por ejemplo los tests que buscan CollisionPolygon2D cuando el nodo pasó a llamarse Ground; no se declara validado todo el combate por estas pruebas. `projectile_smoke` pasa al ejecutarse con paso fijo de 60 FPS, evitando el supuesto de que 0.15 segundos de reloj siempre incluyan suficientes pasos físicos en headless. No se alteró la lógica del proyectil.

Respaldo previo a la fusión, fuera del repositorio: `/Users/lucky/Documents/Codex/2026-10-01/ne/work/pre-merge-backup/`. La copia de integración y los registros de pruebas están en ese mismo workspace. No borrar el respaldo hasta revisar y confirmar la entrega.

## 13. Temporizador visible de partida — feature pendiente

- [ ] Agregar un temporizador visible de cinco minutos para limitar la duración de cada partida.
    - [ ] Mostrar el tiempo restante en el HUD, comenzando en 5:00 al habilitar el combate, después del countdown.
    - [ ] Detener el tiempo durante pausa, desconexiones y resultado de partida.
    - [ ] Reiniciarlo a 5:00 en cada revancha.
    - [ ] Definir qué ocurre al llegar a 0:00 y cómo se determina el ganador o un empate; criterio pendiente de acordar.

Ajuste implementado el 30/10/2026: la revancha reutiliza PreMatch y CountdownOverlay, sin repetir el tutorial. Los personajes y sus armas quedan detenidos hasta finalizar GO!. No se implementó todavía el temporizador de cinco minutos.

- [x] Verificar la revancha con cuenta completa, simulación detenida y reinicio de vidas/estado; regresión de tutorial, pausa, reconexión y flujo integrado. PASS en Godot 4.7.2 sobre copia temporal.

## Ajustes previos a demo — perfiles e imágenes

- [x] Ocultar temporalmente Options en Home; conservar el nodo para reactivarlo al implementar opciones.
- [x] Leer los valores reales desde las escenas Gunner y Demolisher para actualizar las barras al navegar, evitando copiar números de balance al selector.

Valores comprobados en escenas: Gunner tiene velocidad 180, daño del rifle 10, masa 1 y HP 100. Demolisher tiene velocidad 165, daño del martillo 40, multiplicador melee 1, masa 1 y HP 100. Las barras usan la misma escala visual para ambos: velocidad 0–200, daño por impacto 0–50 y masa 0–2, convertidas a 0–100 %. Esto produce Speed 90/82.5, Strength 20/80 y Resistance 50/50. Resistance es resistencia al empuje, no reducción de daño. No se alteraron velocidades, daños, masas, salud ni habilidades del juego. Explorer y Hunter siguen con 50/50/50 provisional, porque sus perfiles y equipamiento aún no están definidos.

WebP se admite como textura; para las nuevas imágenes del selector se prefiere exportar sin pérdida y con transparencia cuando corresponda. Usar `assets/textures/character_select/` para los archivos nuevos y comunicar el nombre que corresponde a cada personaje.

- [x] `tests/character_profile_smoke.gd`: Options oculto, barras de Gunner y Demolisher leídas de escenas reales, actualización al navegar, fallback provisional e independencia de recursos. Regresión de selector, tutorial, combate integrado y revancha comprobada en copia temporal con Godot 4.7.2.

Actualización de imágenes del 30/10/2026: recibidas y conectadas las cuatro ilustraciones WebP al selector. Se conserva el ajuste de aspecto de TextureRect y el tamaño fijo de las tarjetas; los archivos anteriores no se borraron. Los originales nuevos tienen algunos artefactos en el borde inferior, especialmente Gunner y Explorer; no se retocaron los archivos fuente. Pendiente de revisión visual por el usuario.

- [x] Verificar con Godot la importación y asignación de las cuatro ilustraciones WebP, su proporción y que las tarjetas mantienen 220 × 500. PASS en copia temporal.

## Selección habilitada para la demo

- [x] Mostrar el nombre del personaje en la cabecera de cada tarjeta activa, actualizándolo al navegar. Mantener PRESS START en slots vacíos.
- [x] Permitir seleccionar únicamente Gunner y Demolisher. Explorer y Hunter se pueden previsualizar en gris, con el botón Unavailable deshabilitado.
- [x] Proteger también la confirmación por teclado/joystick para que no puedan elegir personajes bloqueados, ni disparar la confirmación de partida con ellos.
- [x] Usar un material de retrato independiente por tarjeta para que el filtro gris no afecte a los demás jugadores.
- [ ] Completar Explorer y habilitar su campo selectable cuando esté listo para jugar.
- [x] Integrar Hunter al selector con movimiento, dash, reacción al daño, muerte y arpón; pendiente de prueba visual y de jugabilidad.
- [x] Quitar el fondo negro del retrato de Demolisher. El selector usa demolisher-transparent.png y se conserva el WebP original. Transparencia comprobada con Godot.

- [x] Verificar nombres, bloqueo de personajes no disponibles, restauración del color al navegar y materiales independientes por jugador con `tests/character_availability_smoke.gd`. Regresión de perfiles, selector, tutorial/countdown y partida integrada aprobada.

## Feedback al recibir daño

- [ ] Mostrar un efecto visible en el personaje cuando reciba daño efectivo.
    - [ ] Definir la presentación visual. Propuesta pendiente: destello breve blanco o rojizo y pequeña inclinación del sprite, con recuperación rápida.
    - [ ] Aplicar la reacción únicamente a la representación visual; conservar la forma de colisión y la dirección física del personaje.
    - [ ] Mantener los colores identificadores de jugadores al terminar el efecto y distinguirlo de la protección temporal al reaparecer.
    - [ ] Resolver impactos consecutivos sin acumular inclinaciones ni dejar el personaje teñido.
    - [ ] Probar legibilidad durante combate y en proyector; evitar depender exclusivamente del rojo o de un parpadeo repetido.
    - [ ] Complementar más adelante con un efecto de sonido de impacto en el bus de FX.

## Música original — primera propuesta

Rama: `feature/music`. El feedback visual al recibir daño queda para otra rama después de revisar la música.

- [x] Componer un bucle para Home y selección: drum and bass chiptune divertido, pianito y sintetizador minimalista.
- [x] Componer un bucle de combate más intenso con batería marcada, bajo pesado y sintetizador de fondo, compartiendo el motivo del menú.
- [x] Guardar WAV y generador reproducible sin samples externos en el proyecto.
- [x] Integrar reproducción persistente entre menús y cambio a combate al terminar el contador, también en revancha.
- [x] Separar buses Music y FX, manteniendo Options oculto hasta implementar su configuración real.
- [x] Verificar con Godot 4.7.2 la importación WAV, bucles PCM estéreo completos, buses separados, transiciones interrumpidas y reproducción durante pausa. Pruebas de integración y tutorial/contador aprobadas. Archivos sin saturación digital y continuidad de muestras en el límite del bucle comprobada; falta aprobación auditiva del usuario.
- [ ] Escuchar y aprobar las dos pistas con el usuario; ajustar timbres, ritmo, mezcla o melodía según su devolución.

- [x] Segunda propuesta musical: conservar BPM y patrones de batería, reforzar drones oscuros y fríos, bajo de combate y acentos metálicos; reducir el brillo melódico. Pendiente de escucha del usuario.

## Identificación de mandos en exportación web

- [x] El usuario confirmó que los botones funcionan y el problema es únicamente visual.
- [ ] Reproducir con mando físico la exportación publicada; confirmar navegador, sistema operativo y nombre/ID reportado.
- [x] Ampliar la detección visual de PlayStation para nombres y vendor ID 054c en formatos web de Chromium y Firefox/Safari, incluidos ceros omitidos. Reconocer PS5 por nombre o IDs de producto conocidos. Conservar el mapeo de acciones.
- [x] Probar clasificadores, iconos, falsos positivos, selector y tutorial/contador con Godot 4.7.2. No implica validación con mandos físicos en navegador.
- [ ] Si el navegador entrega una identidad genérica, ofrecer selección manual de iconos por jugador sin modificar el mapeo de acciones.
- [ ] Probar dos mandos de marcas distintas y reconexión en la versión publicada. No asumir que el GUID web identifica un dispositivo físico; puede ser simplemente standard.
