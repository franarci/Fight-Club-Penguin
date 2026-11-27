# Fight Club Penguin — tareas pendientes

## Integración de entrega — 27/11/2026

- [x] Integrar tutorial de ataques cargados, presentación del ganador y preview del selector en master.
- [x] Incorporar origin/feedbacks 5def4cf: asignación persistente, apuntado, arpón, recargas, ballena con ataque y audio, océano y avión con caja en paracaídas.
- [ ] Vibración pendiente: prueba física en Mac/USB sin vibración; cambios conservados en stash de feature/impact-vibration y excluidos de esta entrega.
- [ ] Validar el conjunto exportado en navegador y publicar.

## Audio futuro — registrado el 27/11/2026

- [ ] Agregar música de victoria a la presentación/resultados.
- [ ] Agregar sonidos de salto y aterrizaje a los festejos, sincronizados con la animación y controlados por FX.
- [ ] Estas dos tareas quedan para más adelante; no se implementan al guardar esta feature.

## F3 — presentación del ganador, 27/11/2026

Trabajo en feature/winner-presentation desde el tutorial aprobado cb9b3b4, en la carpeta habitual. El usuario aprobó la versión de saltitos y autorizó expresamente crear su commit y hacer push.

- [x] Congelar el combate y ocultar el HUD al terminar la ronda.
- [x] Mostrar Player N wins! con color del slot y fuente de juego con contorno, sin presentar todavía los botones de resultados.
- [x] Acercar y centrar suavemente la cámara en el cuerpo del ganador durante 1,2 segundos; la animación continúa con la partida pausada.
- [x] Al terminar el zoom, iniciar el anuncio y el festejo al mismo tiempo. Mantener el anuncio durante cinco segundos completos desde ese momento y luego habilitar el cartel de revancha/menú. Bloquear las acciones de esos botones antes de tiempo.
- [x] En empate, mostrar Draw durante el mismo intervalo sin enfocar un ganador inexistente.
- [x] Si el ganador por tiempo estaba esperando respawn, mostrarlo en su punto de reaparición para la presentación, sin cambiar vidas, HP ni puntuación.
- [x] Restaurar el flujo y el encuadre inicial con la revancha y su countdown; preservar regreso a Home.
- [x] Verificar en Godot sin ventana: espera real de cinco segundos, zoom gradual y centrado, pausa, bloqueo de acciones anticipadas, resultado único, empate, ganador temporalmente muerto y reset en revancha. También pasan timer, resultados, integración, flujo completo, pausa y eliminación.
- [x] Ajuste solicitado: reducir a la mitad el zoom final de la primera propuesta y ampliar el anuncio de 32 a 64 px. Incorporar Iceberg con licencia OFL, color blanco hielo, contorno azul y sombra celeste.
- [ ] Prueba visual del usuario y comprobación web.
- [x] Autorización expresa del usuario para commitear y pushear los cambios aprobados.
- [x] Ocultar el identificador del ganador desde el inicio de la presentación.
- [x] Implementar festejos distintos, autorizados por el usuario, iniciados al terminar el zoom:
  - [x] Gunner: dos saltitos rápidos, sin levantar el arma.
  - [x] Demolisher: salto pesado y pequeña nube de nieve al aterrizar, sin levantar el martillo.
  - [x] Hunter: salto corto manteniendo la pose original del arpón.
  - [x] Scout: dos saltitos laterales manteniendo la pose original del rifle.
- [x] Revisión del usuario: descartar los gestos independientes de las armas. Cuerpo, arma y aleta se trasladan juntos con el mismo salto y conservan su agarre; sin giros ni elevación adicional del arma. Mantener la nieve de Demolisher.
- [x] Repetir el festejo de fondo mientras se muestran las opciones de revancha y menú.
- [x] Animar solo los sprites y el arma, sin mover el cuerpo físico ni modificar HP/vidas. Restaurar poses y limpiar efectos al salir.
- [x] Pruebas en Godot sin ventana: cuatro gestos distintos, movimiento visual con partida pausada, limpieza de nieve, identificador oculto, inicio luego del zoom, cinco segundos completos de anuncio, festejo continuo detrás del menú y reset en revancha.
- [x] Aprobación del usuario de la versión simplificada a saltitos.

## F2 — tutorial visual de ataques cargados, 27/11/2026

Desarrollo retomado por indicación del usuario el 27/11. La explicación solo textual de Controls fue rechazada y se reemplaza por una tercera pantalla. Trabajo en feature/charged-attack-tutorial, en la carpeta habitual. El usuario aprobó la vista y autorizó expresamente al asistente a crear el commit y hacer push de esta feature.

- [x] Agregar la pantalla Charged attacks después de How to win y Controls.
- [x] Mostrar demostraciones automáticas de Hunter y Demolisher con sus escenas, armas, carga y efectos reales.
- [x] Animar los iconos de ataque de los dispositivos participantes mostrando presión mantenida y liberación; acompañar con indicador de carga y estados Hold, Full charge y Release.
- [x] Repetir mantener → cargar → soltar → atacar, usando la duración de carga de cada arma.
- [x] Aislar las demostraciones en viewports 2D propios: sin input de combate, daño a jugadores, movimiento de arena ni sonidos repetidos. Limpiar actores y efectos al cambiar de pantalla o suspender el tutorial.
- [x] Mantener Back/Next; comenzar el contador después de la tercera pantalla. La revancha sigue iniciando directamente con countdown.
- [x] Retirar la ayuda textual añadida anteriormente en Controls. Conservar una aclaración breve de que soltar antes produce ataque normal y que los ataques cargados corresponden a Hunter y Demolisher.
- [x] Verificar en Godot sin ventana: aparición del proyectil real de arpón y de la onda de choque durante la pausa, navegación de tres páginas, suspensión/reanudación, limpieza, iconos y distribución dentro de 1152×648. También pasan integración de cuatro clases, flujo hasta revancha/Home, countdown con reconexión y timer.
- [x] Revisión visual del usuario: aprobada.
- [ ] Validación en exportación web.
- [x] Tutorial aprobado, commit cb9b3b4 creado y pusheado a origin/feature/charged-attack-tutorial por autorización expresa del usuario.

## Historial F2 — explicación textual descartada

- [x] Crear feature/charged-attack-tutorial desde master 9b4bea3. Por indicación del usuario, trasladar los cambios a la carpeta habitual y retirar la copia separada; el selector permanece guardado en feature/selection-arena-preview, commit 25b43e2.
- [x] Añadir una explicación breve dentro de la pantalla Controls existente, sin una página nueva.
- [x] Indicar Hunter y Demolisher: mantener Attack hasta completar CHARGE y soltar; soltar antes produce un ataque normal. Identificar lanzamiento de arpón y onda de choque.
- [x] Conservar los iconos del ataque para cada tipo de control, las acciones existentes, Back, reconexión y countdown.
- [x] Verificar en Godot sin ventana: navegación entre las dos páginas, explicación de carga y liberación temprana, distribución sin superposición, iconos de ataque, Back por mouse/teclado/mando, suspensión/reanudación y countdown. Integración de las cuatro clases hasta revancha aprobada.
- [ ] Revisión visual del usuario y prueba en web.
- [ ] Commit y push por parte del usuario. El asistente no los realiza.


## Pendiente agregado — 22/11/2026

- [ ] Selector: reemplazar el mensaje «Press Start» por «Press any key» y permitir que el jugador se incorpore/inicie la selección presionando cualquier tecla o botón de su dispositivo. Conservar la asignación de mando a jugador. Registrado únicamente; no implementar todavía.

## Feedback con usuarios — 19/11/2026

Este bloque actualiza el alcance vigente tras la prueba con usuarios reales. El cierre del 13/11 queda como historial de la versión ya entregada. Se registran once tareas; el usuario eligió seis para intentar completar para mañana, 20/11. El usuario aprobó comenzar F1 con una vista del personaje real en el selector. El resto se tomará de a una después de revisar este cambio; el orden sigue siendo la propuesta de referencia.

### Seleccionadas para esta iteración — orden propuesto

- [ ] F1. Reconocer en combate al personaje elegido en el selector.
  - [x] Aclaración del usuario: la dificultad es relacionar retrato de selección con apariencia en arena; distinguir slots o colorear el LED es complementario.
  - [x] Aprobar la primera propuesta: conservar el retrato y acompañarlo con el personaje real animado, su arma y color del slot.
  - [x] Crear feature/selection-arena-preview desde master 9b4bea3, conservando las notas locales.
  - [x] Añadir ArenaCharacterPreview reutilizable: instancia la escena de combate en un viewport 2D independiente, en reposo y sin input, colisiones, ataques ni sonidos.
  - [x] Reutilizar la paleta y equipamiento reales de Gunner, Demolisher, Scout y Hunter. Cambiar la vista al navegar y mantenerla al confirmar; limpiarla al liberar el slot.
  - [x] Revisión del usuario: separar el personaje real de la ficha. Mantener retrato, estadísticas y botones dentro de Card; colocar el personaje debajo, fuera del panel y sin texto explicativo. Conservar ancho uniforme en los cuatro slots.
  - [x] Ampliar la figura respecto de la primera propuesta, añadir sombra ovalada fija y respiración suave además de la animación idle. Verificar que la figura queda debajo de Card y por encima de la barra inferior.
  - [x] Verificar en Godot sin ventana: cuatro clases por cuatro slots, materiales de color independientes, animación activa, ausencia de jugadores de preview en combate, encuadre del contenido y ciclo entrar/seleccionar/cambiar/salir. Pruebas de integración hasta revancha y coherencia de colores aprobadas.
  - [x] Revisión posterior: slot vacío con card a alto completo original, sin reservar espacio inferior; al presionar Start se achica la card y aparece la figura debajo. Al abandonar el slot se restaura la card alta. Verificado con slots vacíos y activos simultáneos.
  - [ ] Revisar visualmente con el usuario tamaño del retrato y preview, legibilidad y reconocimiento entre selector y combate.
  - [ ] Verificar aspecto y fluidez en web antes de cerrar la tarea.
  - [ ] Commit y push a cargo del usuario; el asistente no los realizó.

- [ ] F2. Tutorial para cargar ataques especiales.
  - [ ] Ampliar la ayuda actual de ataque con la secuencia mantener → completar carga → soltar, usando los botones reales de teclado/PlayStation/Xbox.
  - [ ] Explicar qué indica que la carga está lista y qué ocurre al soltar antes de completarla.
  - [ ] Distinguir los personajes/armas que realmente tienen ataque cargado; no presentar disparos normales o recargas como ataques especiales cargables.
  - [ ] Reutilizar el tutorial y ayudas de controles existentes, en inglés, sin añadir acciones de input nuevas.
  - [ ] Validar que la explicación coincide con las mecánicas de Hunter y Demolisher y los controles actuales.

- [ ] F3. Presentación del ganador antes de resultados.
  - [ ] Detener el combate al resolver la partida y localizar al ganador.
  - [ ] Acercar y centrar la cámara suavemente sobre el ganador, manteniéndolo visible.
  - [ ] Mostrar un mensaje de victoria durante cinco segundos; luego habilitar el cartel existente de revancha y menú.
  - [ ] Verificar victoria por último superviviente y por tiempo, incluso si el ganador espera respawn. Propuesta para empate: mensaje sin enfocar a un ganador inexistente.
  - [ ] Evitar resultados duplicados y restablecer cámara/estado en revancha y regreso a Home.
  - [ ] La animación de festejo avanzada registrada antes sigue siendo futura; no forma parte automática de este cambio.

- [ ] F4. Vibración al recibir impactos.
  - [ ] Vibrar únicamente el mando del jugador que recibe un impacto aceptado de dash o de proyectil.
  - [ ] Diferenciar con pulsos breves los tipos de impacto y evitar vibrar por contacto suave, impactos rechazados o invulnerabilidad.
  - [ ] Reutilizar la identificación de dispositivo por slot; contemplar teclado, desconexión y reconexión.
  - [ ] Comprobar soporte real en los mandos disponibles y en la exportación web; continuar normalmente si no existe vibración.
  - [ ] Ajustar intensidad y duración mediante prueba manual sin sumar un menú nuevo a esta tarea.

- [ ] F5. Música nueva.
  - [ ] Retomar la dirección pendiente y elegir una pista aprobada por el usuario antes de integrarla.
  - [ ] Mantener tensión previa a una batalla, energía competitiva e identidad bélica; evitar las propuestas ya rechazadas.
  - [ ] Acordar si se reemplaza solo Home/selector o también combate. La selección de esta tarea no define todavía ese alcance.
  - [ ] Confirmar disponibilidad del archivo final y permiso de uso; preparar formato, volumen y repetición sin cortes.
  - [ ] Conservar mute/volumen Music–FX y validar transiciones y reproducción web.
  - [ ] No modificar la música actual hasta aprobar el reemplazo.

- [ ] F6. Validar color de la luz del joystick.
  - [ ] Comprobar disponibilidad de control de LED en la versión local de Godot, los mandos reales y la plataforma de entrega.
  - [ ] Investigar por separado aplicación nativa y navegador; no asumir que detectar marca/botones permite cambiar el LED.
  - [ ] Si hay soporte, proponer asignar el color del slot y actualizarlo al reconectar o liberar el mando.
  - [ ] Si no hay soporte en la plataforma objetivo, registrar la limitación y cerrar la investigación con evidencia; no comprometer una implementación universal.

Referencias técnicas para F4/F6: [Godot: características de mandos](https://docs.godotengine.org/en/stable/tutorials/inputs/controller_features.html), [Godot: Input y luces](https://docs.godotengine.org/en/latest/classes/class_input.html#class-input-method-set-joy-light), [MDN: vibración en navegador](https://developer.mozilla.org/en-US/docs/Web/API/GamepadHapticActuator/playEffect). La documentación consultada limita el control de luz a plataformas nativas compatibles; la vibración web depende de navegador y hardware. La compatibilidad de la instalación del proyecto se verificará al tomar cada tarea.

### Registradas fuera de las seis seleccionadas — sin iniciar

- [ ] F7. Más ángulos de giro y disparo.
  - [ ] Evaluar sprites disponibles para direcciones intermedias; actualmente el apuntado/poses trabaja con ocho direcciones.
  - [ ] Distinguir ampliar la animación visual de ampliar el apuntado real de proyectiles.
  - [ ] Revisar alineación de manos, arma, salida del proyectil y colisiones al cambiar los ángulos.
  - [ ] Acordar cantidad de direcciones y necesidad de arte nuevo antes de implementar.

- [ ] F8. Dash más rápido y empuje más fuerte.
  - [ ] Ajustar velocidad y fuerza para aumentar el caos sin confundirlas con duración, distancia y cooldown.
  - [ ] Probar todas las clases, masas, colisiones y caídas; no modificar valores en esta planificación.

- [ ] F9. Arpón más largo.
  - [ ] Acordar si se refiere a largo visual, alcance de estocada, alcance del lanzamiento o una combinación.
  - [ ] Mantener coherencia entre imagen, alcance de impacto, cuerda y retorno.

- [ ] F10. Animación de caída al agua.
  - [ ] Elegir una propuesta: hundirse/ahogarse, ser devorado por un animal u otra animación acordada.
  - [ ] Coordinar efecto, pérdida de vida y respawn seguro; conservar como referencia la espera de dos segundos ya anotada.
  - [ ] No duplicar pérdida de vidas ni habilitar movimiento durante la caída.

- [ ] F11. Una novedad de arena.
  - [ ] Elegir una: ballena que atraviese la arena, suelo que se mueva, aparición de vidas u otra propuesta acordada.
  - [ ] Definir aviso previo, frecuencia, interacción y balance antes de implementar.
  - [ ] Implementar una sola novedad primero, sin asumir aprobadas todas las alternativas.

### Metodología de esta iteración

- [ ] Aprobar prioridades y alcance con el usuario antes de iniciar desarrollo.
- [ ] Tomar una tarea por vez, en su propia rama desde la base acordada y con revisión del usuario.
- [ ] Mantener código sin comentarios nuevos. El asistente no hace commit ni push.
- [ ] Probar cada cambio en Godot y cerrar con exportación y prueba web de la versión integrada.
- [ ] No dar por terminadas las tareas de hardware solamente con pruebas automáticas.

## Cierre vigente — confirmación del usuario, 13/11/2026

Este estado prevalece sobre los registros históricos siguientes. El usuario confirma merge final, exportación, publicación y prueba web completos y funcionando correctamente. Al cerrar esa entrega quedaban música nueva, animación de caída y novedad de arena; el feedback del 19/11, arriba, amplía y reemplaza ese alcance vigente.

- [x] Mute: funciona correctamente, confirmado por el usuario.
- [x] Cortes de audio: resueltos, confirmado por el usuario.
- [ ] Música nueva: pendiente.
- [x] Detección de mandos en la web publicada: funciona correctamente, confirmado por el usuario el 13/11/2026.
- [ ] Animación de caída al agua: pendiente.
- [ ] Novedad de arena: pendiente.
- [x] Retrato de Scout: conservar la imagen actual por decisión del usuario. No requiere reemplazo.
- [x] Merge final: completado por el usuario.
- [x] Exportación y publicación: completadas.
- [x] Prueba web final: todo funcionando correctamente, confirmado por el usuario.

## Correcciones conjuntas — feature/gameplay-stability

Base 20d2fb9, después de que el usuario probó y guardó la integración a05c5fc. El usuario autorizó continuar en una rama nueva con los pendientes de estabilidad; esta autorización pasa N1, N2 y N14 al trabajo de esta rama. La música nueva, la caída animada y la novedad de arena siguen en pausa.

- [x] N1: comprobar el punto de los pies en coordenadas mundiales, con 36 px de margen respecto del agua y 64 px respecto de otros jugadores vivos. Conservar el spawn preferido si es válido y buscar otro punto interior cercano cuando no lo sea.
- [x] Validar también el spawn inicial. Si temporalmente no hay espacio seguro para reaparecer, esperar y reintentar sin perder otra vida ni habilitar al personaje en el agua.
- [x] N2: conservar referencias a los puntos de respawn durante la ronda, suavizar ambas direcciones del zoom y esperar 0,8 s antes de acercar de nuevo. Mantener el margen de seguridad en pantalla y el efecto de sacudida existente.
- [x] N14: contacto normal con empuje leve, limitado a 72 px/s antes de aplicar masa, con aceleración de 300 px/s², sin daño ni bloqueo de controles. El dash mantiene su impulso fuerte.
- [x] Extender únicamente el fondo de agua en 1536 px alrededor del escenario y limitar el encuadre y las sacudidas a ese fondo para evitar márgenes grises. El hielo, sus colisiones y el área jugable conservan su tamaño. Verificar límites con cuatro tamaños de pantalla.
- [x] Ajustar las formas de contacto de Gunner, Demolisher, Hunter y Scout a su tamaño visible, con cápsulas horizontales y sin escalado adicional de Collision. Mantener separadas las zonas de daño y el marcador de pies.
- [x] Normalizar P1–P4 a fuente de 28 px en el mundo, independientemente de la escala o clase del personaje. Conservar colocación automática sobre el personaje; quitar la separación lateral entre etiquetas cercanas para que no se reordenen al acercarse.
- [x] Verificar 160 contactos entre las cuatro clases, en ocho direcciones y con movimiento normal/dash: sin penetración física ni daño por contacto. Verificar las etiquetas P1–P4 en cada clase, cambios de escala y animaciones de dash. Pruebas sin ventana; pendiente aprobación visual del usuario.
- [x] Inicializar P1–P4 al crear los personajes, antes del primer cuadro, para que la pausa del tutorial/contador no muestre tamaños distintos. Comprobar los cuatro slots con el árbol pausado.
- [x] Preparar Main antes de mostrar Home, cambiar a la escena ya cargada al presionar Play y reutilizar perfiles de selección. Los cuatro personajes siguen leyendo sus datos reales.
- [x] Medición local orientativa sin ventana: Play pasa de 936,6 ms a 13,9 ms; la carga se traslada al arranque de Home (64,1 ms a 832,1 ms). Esto no es una medición del navegador ni garantiza esos tiempos en otros equipos.
- [x] Prueba física: desplazar lentamente al rival por contacto, sin daño, respetando masa; el dash sigue siendo más fuerte. Pruebas de respawn inválido/ocupado, margen de costa, reintento sin consumir vidas, encuadre al morir y zoom gradual aprobadas.
- [x] Regresiones de las cuatro clases y revancha, Home, perfiles, cámara, timer, eliminación, audio, pausa, reconexión, salud, resultados, tutorial, dash e integración aprobadas en Godot sin ventana. Persisten los avisos de recursos al cerrar algunas pruebas.
- [ ] Aprobación manual del usuario: sensación de cámara y empuje, spawn/respawn en partidas completas y transición Home → selector con audio en el navegador.
- [x] Generar versión web aislada en http://127.0.0.1:8767/stability/; verificar arranque del paquete en Godot, sus 428 archivos y entrega HTTP. La URL anterior conserva la integración previa. No equivale a una prueba visual en navegador.
- [ ] Generar/publicar el export definitivo desde la revisión aprobada por el usuario.
- [ ] Guardar commit y push por parte del usuario. El asistente no hizo commit ni push.

## Estado de integración — 13/11/2026

Este bloque actualiza el estado vigente; los registros posteriores conservan las revisiones anteriores.

- [x] Recibir origin/addRemainingClasses en 1150729 y confirmar que el compañero ya la integró en origin/master 5987e63.
- [x] Preparar la rama integration/nov13-four-classes desde 375c5c8 e incorporar origin/master con merge detenido antes del commit. Las ramas master local y remota no se modificaron.
- [x] Conservar timer, eliminación, paleta, tutorial, botones unificados, Home polar, selector militar, contador sin recuadro y opciones Music/FX.
- [x] Incorporar Hunter/arpón y Scout/rifle, animaciones, correcciones de hurtboxes, sonidos y HUD de una bala del compañero.
- [x] Conectar ChargedImpactAudio al bus FX compartido para Hunter y Demolisher; el control de efectos ahora incluye el impacto cargado.
- [x] Actualizar datos de pruebas con CharacterData.character_scene, disponibilidad de las cuatro clases y referencias al polígono vigente; ejecutar el inicio de selección como escena para que los autoloads estén disponibles al cargar los personajes.
- [x] Verificar en Godot sin ventana: cuatro clases desde el selector hasta revancha, daño/tirón del arpón, recarga y HUD de Scout, respawn básico, FX, timer, eliminación, pausa, reconexión, resultado, Home, tutorial y colores. Persisten avisos de recursos al cerrar algunas pruebas; no equivalen a aprobación visual ni de rendimiento web.
- [ ] Prueba manual conjunta con mandos: cuatro clases, combate, opciones de audio, pausa/reconexión, caídas, resultado y revancha.
- [ ] Guardar el commit de integración y hacer push/PR por parte del usuario después de revisar los cambios. No se hicieron commits ni push desde el asistente.
- [ ] Generar export web de la integración aprobada y verificar la versión publicada.
- [ ] N1/N2/N14, compañero: siguen pendientes la garantía de respawn seguro, el ajuste nuevo de zoom y el empuje suave. Los cuatro puntos de spawn probados sobre hielo no garantizan corregido el problema de respawn informado.
- [ ] Confirmar o reemplazar el retrato de Scout, que todavía reutiliza explorer.webp.
- [ ] Música nueva: en pausa por decisión del usuario. Conservar la música vigente; las muestras y sus generadores siguen sin versionar y fuera del conjunto de cambios de integración preparado en el índice.
- [ ] Caída al agua y novedad de arena: salteadas por el usuario; no reactivarlas automáticamente para esta integración.

## Roadmap vigente — entrega del viernes 13 de noviembre de 2026 a las 16:00

Actualizado el 12/11/2026, Argentina (UTC−3), tras fetch de origin y revisión de addRemainingClasses. Este bloque reemplaza las prioridades y fechas del 6/11 conservadas abajo. Los identificadores N1–N17 siguen vigentes como referencia de cada feature; su prioridad actual se define aquí.

### Base y separación entre implementado e integrado

- [x] Confirmar master local y origin/master en ac0c097; no se cambió de rama ni se modificó código del juego.
- [x] Revisar origin/addRemainingClasses en 1289d52: dos commits nuevos, 5ea796e (Hunter y Scout) y 1289d52 (sonido del martillo contra el suelo).
- [x] Registrar confirmación del usuario: la exportación anterior de master funcionó. Esto no valida ni publica los personajes nuevos.
- [ ] Integrar addRemainingClasses en master después de revisar y probar los cambios. La rama parte de 44c18d9 y no contiene 71853a4, con las correcciones web de audio e iconos. Conservar esas correcciones al integrar; no reemplazar master por el estado de la rama.
- [ ] Conservar las anotaciones locales de este archivo al integrar: la rama también toca tareas-pendientes.md y su listado es anterior al roadmap local.

### Ya implementado en addRemainingClasses, pendiente de integración y validación jugable

- [x] Hunter seleccionable con escena propia, movimiento, dash, reacción al daño y muerte direccionales.
- [x] Arpón de Hunter: estocada normal y lanzamiento cargado de 0,8 segundos; aplica daño, atrae al rival al impactar y vuelve a la mano. Incluye cuerda y cancelación del proyectil al interrumpir el ataque.
- [x] Scout seleccionable reemplazando la entrada Explorer del selector; Explorer.tscn sigue en el repositorio, pero esa entrada del selector ahora inicia Scout. No son cinco personajes seleccionables.
- [x] Rifle de Scout: cargador de un disparo, 35 de daño base, recarga de 1,6 segundos y retroceso de 80; proyectil y sonido propios.
- [x] Mostrar el estado de Scout en HUD con una sola bala e indicador de recarga sobre ella; conservar el HUD de ráfagas del Gunner y de carga de armas melee.
- [x] Instanciar personajes usando CharacterData.character_scene en lugar de una cadena de if por nombre. Hunter y Scout ya están enlazados a sus escenas, por lo que sus barras derivan de la configuración de juego existente.
- [x] Ajustar apuntado del arma a ocho direcciones, separación de etiquetas P1/P2 cuando se aproximan y orden visual por los pies del personaje en movimiento.
- [x] Añadir animaciones hit para los nuevos personajes, completar direcciones de muerte reflejadas y sumar sonido del martillo cargado contra el suelo.
- [ ] Probar Hunter y Scout con mandos físicos: balance, alcance, direcciones, cuerda, tirón, colisiones, daño, pausa, desconexión, eliminación y revancha. Que exista el código no cierra estas comprobaciones.
- [ ] Confirmar o reemplazar el retrato de Scout: actualmente reutiliza explorer.webp; su nombre y escena jugable sí son Scout.
- [ ] Revisar perfiles y documentación de balance. Las barras de selector leen velocidad/daño/masa; no representan por sí solas recarga, tirón, alcance o potencia del ataque cargado. No inventar estadísticas distintas sin acordarlas.

### Verificación realizada el 12/11 en copia aislada de 1289d52

Se importó con Godot 4.7.2, sin errores de parseo de proyecto durante la importación. El entorno impide guardar los ajustes del editor y los logs user://; esos avisos se distinguen de los fallos de comprobaciones siguientes. No se hizo prueba visual ni se exportó/publicó esta rama.

- [x] scout_selection_start_smoke.tscn: pasa la selección de Scout y su inicio en partida con rifle y HUD de una bala.
- [x] integration_flow_smoke.gd: pasan confirmación, tutorial, contador, partida Gunner/Demolisher, resultado, revancha y regreso a Home. Reporta recursos/instancias pendientes al salir: revisar limpieza; no declarar esta prueba libre de avisos.
- [ ] Corregir y repetir character_availability_smoke.gd: falla en línea 46 porque conserva la expectativa de saturación gris para una tarjeta cuyo personaje ya es seleccionable.
- [ ] Actualizar y repetir character_profile_smoke.gd: falla en línea 34 porque todavía exige perfiles neutros de 50 para personajes que ahora tienen escena y arma reales.
- [ ] Revisar selection_start_smoke.gd: la ejecución con --script produjo errores de resolución de autoloads PlayerManager/MultiplayerInput al cargar scripts y luego falla al iniciar. Comparar su arranque con la prueba Scout mediante escena, que sí pasa; no concluir solo con esta ejecución que el juego normal no inicia.
- [ ] Actualizar health_lives_smoke.gd: crea CharacterData sin character_scene y usa un arranque/recorrido anterior; el nuevo spawn rechaza esos datos. No se validaron salud/vidas para las cuatro clases con esta prueba.
- [ ] Extender comprobaciones de Hunter/arpón: no hay evidencia automática suficiente del impacto, tirón, regreso, alcance y cancelación del arma nueva.

Logs de esta revisión: work/addRemainingClasses-*.log dentro del workspace de Codex, fuera del repositorio del juego.

### Reparto y alcance acordados el 12/11

El usuario confirma que su compañero se ocupa de integrar y estabilizar las cuatro clases, incluidas las comprobaciones de armas/clases de N11/N17, y de corregir respawn y cámara (N1/N2). El asistente no duplica ese trabajo. N16, música entrecortada, se cierra por confirmación del usuario, sin continuar su diagnóstico.

Se aprueban timer, feedback y todas las mejoras mencionadas como pospuestas en el resumen anterior: opciones de audio, artística de Home, una novedad de arena, empuje suave y unificación de botones. También se conserva en el alcance organizado la caída al agua y la coherencia de colores de N7/N9; se desarrollan de forma coordinada con el respawn del compañero. Este es el alcance de trabajo, no una afirmación de que ya esté implementado. No sumar LEDs, celebración avanzada del ganador ni múltiples novedades de arena a esta entrega.

- [x] Asignar integración/estabilidad de clases y N11/N17 al compañero; siguen pendientes de que entregue y valide los cambios.
- [x] Asignar respawn seguro y cámara (N1/N2) al compañero; no marcarlos terminados sin evidencia.
- [x] Asignar también N14 al compañero por indicación del 13/11; comprobar su implementación al terminar las demás features.
- [x] Reordenar N6 por indicación del 13/11: opciones de sonido después de N12, artística de Home.
- [x] Cerrar N16: el usuario indica que el problema de audio entrecortado está resuelto. No se atribuye una causa ni una solución técnica nueva.
- [x] Incorporar opciones de audio, artística de Home, novedad de arena, empuje suave y botones unificados al trabajo aprobado; ya no son mejoras condicionadas a que sobre tiempo.
- [ ] Recibir del compañero una base integrada y confirmar su commit antes de integrar nuestras ramas y exportar.

### Orden de ejecución de nuestro trabajo

Una feature por rama y revisión del usuario antes de pasar a la siguiente. No crear todas las ramas ahora: cada una parte de la base acordada más reciente, conservando la documentación local. El asistente modifica código; no hace commits, merge ni push salvo autorización nueva y expresa. Usar componentes reutilizables, las acciones actuales de input y el idioma inglés en el juego, sin comentarios nuevos en código.

1. **Timer (N5) — feature/match-timer.** Contador visible 5:00 después de GO!, pausa/desconexión/resultado detenidos, reset en revancha y último superviviente como victoria anticipada. Al agotarse: corazones → HP → empate. Propuesta pendiente de acordar para quien espera respawn: comparar el HP que recibirá al reaparecer, sin penalizarlo dos veces por su HP temporal en cero. Verificar expiración y muertes simultáneas.
2. **Feedback de selección (parte de N7) — feature/selection-feedback.** Mensaje mínimo dos jugadores, sin recuperar el botón grande de espera ni alterar tamaños de tarjetas. Confirmación de partida conserva sus condiciones actuales.
3. **Eliminación definitiva (N8) — feature/elimination-feedback.** Aviso breve y estado Eliminated persistente en HUD, distintos de la muerte temporal y del cartel de ganador. Avisos simultáneos y limpieza en revancha. Integrar sobre el HUD del compañero, sin reescribir sus indicadores de arma.
4. **Tutorial — feature/tutorial-weapons.** Alcance corregido por el usuario: informar máximo cinco minutos, conservar solo How to win/Controls, Attack con icono real y botón Back. No agregar sección explicativa de armas. El comportamiento de las armas lo valida el compañero.
5. **Colores consistentes (resto de N7) — feature/player-color-consistency.** Fuente única por slot para selector, equipo, identificador y HUD. Revisar retratos prerenderizados, personajes repetidos y restauración del color tras daño. Coordinar la nueva imagen de Scout si se proporciona, sin inventar assets distintos.
6. **Botones y ayudas unificados (N15) — feature/unified-ui-actions.** Alcance aclarado: unificar las representaciones duplicadas de una misma acción en Ready to play y tutorial, conservando la ayuda con iconos como elemento clickable. No rediseñar tarjetas ni reasignar mouse a slots. Componente compartido con hover/foco/deshabilitado; controles de juego siguen informativos.
7. **Caída al agua (N9) — feature/water-fall-feedback.** Integrar sobre el respawn seguro del compañero. Propuesta acotada: splash y hundimiento/desaparición; esperar dos segundos antes de reaparecer si quedan vidas. Una sola pérdida de vida y pausa respetada. Tiburón/alma no se implementan simultáneamente salvo elección expresa del usuario.
8. **Una novedad de arena (N10) — feature/arena-event.** El alcance aprobado incluye una mecánica nueva; falta elegir cuál. Propuesta: recoger una vida extra en una posición segura del hielo. Ballena o armas recogibles siguen siendo alternativas, no tres tareas acumulativas. Acordar frecuencia, máximo de vidas y regla de aparición antes de implementarla.
9. **Home y artística (N12) — feature/polar-home.** Título pixel/8 bits con licencia compatible y fondo polar animado con paneo lateral suave y agua/nieve mediante shader. Priorizar legibilidad, baja carga y estabilidad del audio web. Primera propuesta visual se revisa antes de construir todo el fondo; no extender automáticamente el rediseño a todas las pantallas.
10. **Opciones de audio (N6) — feature/audio-options.** Un mismo panel desde Home y pausa: Music y Sound effects, cada uno con mute y slider independiente. Configuración compartida entre escenas; enrutar efectos al bus FX antes de probar controles. No reabrir N16 ni cambiar reproducción musical por iniciativa propia.
11. **Integración final y deploy (N13).** Recibir master con las correcciones del compañero, integrar las features aprobadas de a una y probar el recorrido completo con cuatro clases. Exportar desde esa base final y validar URL real, mandos, audio, pausa, timer, caídas y revancha. Publicar a cargo del usuario salvo autorización nueva.

**A cargo del compañero — N14:** empuje suave por contacto, sin daño. No implementarlo en nuestras ramas. Al terminar las demás features, comprobar en su base si está hecho y probarlo; si no está, dejarlo pendiente y acordar quién lo toma.

### Cómo trabajamos hasta la entrega

- [ ] Antes de cada feature, confirmar base/archivos compartidos con el compañero; no pisar sus cambios de main, controlador y HUD mientras trabaja.
- [ ] Implementar y comprobar cada feature por separado; el usuario revisa y prueba antes de integrarla. Registrar qué se verificó realmente.
- [ ] Probar las transiciones entre features: opciones en pausa, timer durante caídas, vida extra en el límite de tiempo y acciones unificadas sin doble activación.
- [ ] Al terminar las demás features, chequear el empuje suave N14 del compañero y registrar si está implementado y funciona.
- [ ] Dejar todas las tareas aprobadas visibles si una no llega a terminarse; no ocultarla ni marcarla hecha por haber aprobado el alcance.
- [ ] Propuesta de corte técnico: viernes 13 a las 15:00, con última hora reservada para exportar, publicar y probar antes de las 16:00. El alcance es amplio; el avance real por feature determina si hace falta renegociar el corte, sin recortar tareas unilateralmente.

### Qué sigue abierto aunque la rama ya agregue contenido

- [ ] N1, compañero: respawn seguro sobre el hielo. Pendiente de recibir y validar su corrección.
- [ ] N2, compañero: zoom cómodo. Pendiente de recibir y validar su corrección.
- [ ] N5: implementación completada en feature/match-timer desde master ac0c097; falta revisión visual del usuario, integración y prueba web.
- [ ] N6: opciones Music/FX y enrutamiento de efectos nuevos.
- [ ] N7: aviso mínimo de jugadores aprobado; colores unificados en feature/player-color-consistency, pendiente de revisión visual e integración.
- [x] N8: usuario confirmó prueba manual y guardó/pusheó 6dc36b8. Quedan integración final y comprobación web.
- [ ] N9: efecto específico de caída al agua y espera de dos segundos. Existe una opción animate_death_on_life_loss, pero no está habilitada en las escenas revisadas; el delay sigue en 0,8 segundos y no hay splash/tiburón/alma.
- [ ] N10, nuestro trabajo aprobado: elegir e implementar una novedad de arena; propuesta de vida extra pendiente de elección.
- [ ] N11/N17, compañero: validar feedback, armas y HUD de las cuatro clases y confirmar alcance de sangre/efectos.
- [ ] N12: Home con identidad visual polar.
- [ ] N14, compañero: empuje suave sin daño; comprobar al terminar si lo implementó, sin asumirlo resuelto.
- [ ] N15: duplicados unificados en Ready to play y tutorial en feature/unified-ui-actions; falta revisión visual, integración y prueba web.
- [x] N16: audio entrecortado resuelto por confirmación del usuario el 12/11. Diagnóstico descartado del trabajo pendiente.
- [ ] N13: integración, exportación, publicación y aceptación de la entrega del 13/11 a las 16:00.

---

## Registro anterior — planificación del 6 de noviembre de 2026

Actualizado: 6 de noviembre de 2026, Argentina (UTC−3). Fuente: devolución de la entrega informada por el usuario, acuerdos de este chat e inspección estática de master ac0c097 tras integrar improveGameFeel y las correcciones web. Entrega: versión web publicada y probada hoy, antes de las 00:00 del 7 de noviembre.

## Plan vigente y límite de alcance

Este bloque reemplaza las prioridades del hito del 31 de octubre; el historial se conserva más abajo. No confundir código existente o pruebas automatizadas anteriores con validación de esta entrega. La última revisión compara ed68efb con master ac0c097. Se inspeccionaron código y recursos; no se ejecutó el juego en esta revisión. Las casillas de implementación no equivalen a validación jugable.

- [x] Registrar las devoluciones y separar correcciones, mejoras y decisiones.
- [x] Confirmar la base local actual: master ac0c097. La referencia local origin/master apunta al mismo commit, sin fetch nuevo. Incluye 71853a4 (correcciones web) y el PR #7, 44c18d9, con improveGameFeel hasta 75a419b.
- [x] Acordar el desempate del temporizador: más corazones; a igualdad, más HP; si ambos valores coinciden, empate.
- [ ] Acordar con el usuario el corte de alcance de hoy antes de implementar.

Trabajar de a una feature en una rama propia, con revisión del usuario. No hacer commits, merges ni push salvo autorización explícita para esa acción. No agregar comentarios al código. La interfaz del juego continúa en inglés; este listado y la conversación permanecen en español. No modificar export_presets.cfg durante esta revisión; ahora está versionado en master.

Prioridad propuesta, pendiente de debate:

1. En coordinación con el compañero — N1 (respawn) y N2 (cámara). Apartados del trabajo del asistente hasta confirmar su avance; no se consideran resueltos.
2. Resueltos según confirmación del usuario: N3 (audio web) y N4 (iconos de mandos web). Mantener pendientes únicamente las comprobaciones ampliadas que no se hicieron.
3. P1 — cerrar reglas y configuración: N5 (timer) y N6 (opciones de audio).
4. P1 — claridad para los jugadores: N7 (mínimo de participantes y colores) y N8 (eliminación).
5. P2 — mejorar la caída: N9, con splash y dos segundos de espera como primera propuesta acotada.
6. P2 — elegir UNA novedad de jugabilidad: N10. Propuesta: recoger una vida extra; ballena y cambio de armas quedan como alternativas.
7. P3 — presentación de Home: N12. Priorizar título con fuente pixel antes de construir un paisaje polar completo.
8. Transversal — avances de N11 integrados en master; falta validarlos junto con el resto y completar N17. N13 (integración, prueba web y publicación) sigue siendo obligatorio.
9. Nuevos pendientes: N14 (empuje suave), N15 (unificación de botones) y N16 (audio entrecortado en Brave/Windows). N5 (timer) está pausado por indicación del usuario hasta terminar esta revisión.

No se promete completar todos los P2/P3 hoy. Reservar al menos los últimos 45–60 minutos para integrar, exportar y comprobar la URL real. Si no queda margen, cerrar el alcance con el usuario y conservar las mejoras restantes como pendientes; no declararlas implementadas.

## Estado tras la integración en master — ac0c097

- [x] Integrar las correcciones de audio e iconos web de 71853a4.
- [x] Integrar improveGameFeel mediante PR #7 y merge posterior; constatado en el historial local.
- [x] Incorporar rifle Gunner con ráfagas de cuatro, cargador de doce, recarga automática de 1,2 segundos y HUD de munición/recarga.
- [x] Incorporar martillo cargable durante 1,4 segundos: al soltar antes se ejecuta el ataque normal; con carga completa se produce onda de área, empuje fuerte y sacudida de cámara. Daño cargado limitado a 70 y barra CHARGE permanente.
- [x] Incorporar sonidos de disparo, martillo, daño, dash, empuje y muerte; destello de boca del rifle y proyectil animado.
- [x] Incorporar animación direccional de muerte por daño para Gunner y Demolisher; restaurar sus elementos visuales al reaparecer.
- [x] Convertir la tarjeta HUD en escena reutilizable con retrato, HP, corazones, munición/recarga y carga del martillo.
- [x] Reducir empuje base de dash de 500 a 375 y knockback de martillo normal de 337,5 a 250; son ajustes existentes, no implementación del empuje suave de N14.
- [ ] Validar manualmente estas incorporaciones con pausa, muerte, respawn, desconexión y revancha; no se ejecutaron pruebas en esta revisión documental.
- [x] Generar exportación release de master ac0c097 con improveGameFeel; el usuario confirmó que funcionó. Las incorporaciones posteriores de addRemainingClasses requieren otra integración y exportación.

Siguen sin implementarse en esta integración: corrección de spawn inseguro, suavizado nuevo de zoom, timer, opciones de audio, aviso de mínimo de jugadores, feedback de eliminación definitiva, caída al agua animada con dos segundos de espera, novedad de arena, rediseño de Home, empuje suave y unificación de botones. El problema nuevo de música entrecortada sigue abierto.

## N1. En coordinación — reaparición segura sobre el hielo

Responsable confirmado el 12/11: el compañero. No duplicar trabajo ni modificar esta mecánica por ahora.

Revisión ac0c097: configure_arena sigue guardando global_position y el respawn vuelve a esa posición sin validarla contra el hielo; no hay corrección nueva de spawn en esta integración.

Incidencia reportada: algunos jugadores reaparecen directamente en el agua. No se confirmó todavía la causa. Se revisará antes de agregar animaciones de caída.

- [ ] Reproducir el problema con los personajes y slots disponibles, muertes por daño y por agua, y varias reapariciones consecutivas.
- [ ] Revisar las coordenadas guardadas al configurar la arena, las transformaciones del personaje y el punto de los pies usado para detectar el hielo.
- [ ] Validar que el punto de reaparición real, incluidos pies y dimensiones del personaje, esté dentro del polígono de hielo y separado de su borde.
- [ ] Elegir un punto seguro alternativo si el spawn guardado no es válido; nunca volver a habilitar un personaje sobre el agua.
- [ ] Revisar colisiones, velocidad, empuje y protección al reaparecer; evitar pérdidas de vidas en cadena o doble respawn.
- [ ] Probar también con otros jugadores cerca del punto de aparición y con la cámara desplazada.

Aceptación: ninguna reaparición de los casos probados vuelve a matar inmediatamente al jugador por estar en el agua. No confundir posición en pantalla con posición de mundo.

## N2. En coordinación — cámara estable y cómoda

Responsable confirmado el 12/11: el compañero. Apartado del trabajo actual del asistente.

Revisión ac0c097: se agregó sacudida de cámara para el martillo cargado, pero la lógica de seguimiento y zoom sigue siendo la anterior. La sacudida no resuelve esta incidencia y debe evaluarse por separado por comodidad.

Incidencia reportada: el zoom al morir/reaparecer y al eliminarse personajes marea. El código actual interpola el acercamiento pero puede alejar instantáneamente por seguridad de encuadre; revisar como hipótesis, no como causa confirmada.

- [ ] Reproducir acercamientos y alejamientos en muertes temporales, respawn, eliminación definitiva y jugadores en extremos opuestos.
- [ ] Acordar un comportamiento estable. Propuesta para hoy: encuadre fijo de toda la arena; alternativa: zoom dinámico limitado con umbral y espera antes de acercarse.
- [ ] Evitar cambios bruscos de encuadre al ocultar/reaparecer un jugador; mantener visibles jugadores activos e indicadores.
- [ ] Comprobar que HUD, selector y menús superpuestos no se muevan con la cámara.
- [ ] Probar diferentes proporciones de ventana, pausa y revancha.

Aceptación: las muertes y reapariciones no provocan pulsaciones abruptas de zoom ni dejan jugadores fuera de cuadro. Elegir la alternativa con el usuario antes de implementarla.

## N3. Resuelto — música audible en la exportación web

- [x] Usuario confirma que la música funciona en la versión web probada. Chrome puede suspender el audio hasta la primera interacción; se observó el aviso de AudioContext y la reproducción posterior al interactuar. No se garantiza autoplay sin interacción en todos los navegadores. Las comprobaciones ampliadas de abajo siguen pendientes cuando no hay evidencia específica.

Antecedente resuelto: la música funciona en Chrome/macOS del usuario, pero no se escuchó en Chrome/Windows de la profesora; otros juegos web sí tenían audio. Causa del bloqueo inicial confirmada después: política de autoplay de Chrome. Los WAV y buses Music/FX ya existen; no recomponer la música para investigar este problema.

- [ ] Probar la misma URL y versión exportada en Chrome/macOS y Chrome/Windows, con perfil o sesión nuevos.
- [ ] Revisar errores del navegador, carga de archivos, volumen/mute de pestaña y sistema, estado del audio y configuración de exportación.
- [x] Confirmar con el mensaje de Chrome que el AudioContext queda suspendido antes de una interacción y que la música se escucha después de interactuar.
- [x] Retirar la pantalla de activación rechazada por el usuario. Intentar la música automáticamente desde Home con Stream explícito, sin pasos adicionales ni esperar una interacción desde el código del juego. Usuario confirmó reproducción audible tras interactuar; no garantiza eludir una política de autoplay del navegador.
- [ ] Verificar música de Home/selector, tutorial, combate, pausa y revancha en el build web, incluidos niveles de volumen de N6.
- [ ] Confirmar que el build publicado contiene las dos pistas y que se está probando la versión nueva, sin caché anterior.

Aceptación: se escucha la música tras la interacción prevista en la URL publicada tanto en macOS como en Windows. Las pruebas locales del editor no cierran esta incidencia.

## N4. Resuelto — iconos correctos de mandos en navegador

- [x] Usuario confirma que el problema de los iconos de joystick quedó resuelto tras preparar la nueva versión web y probar en Windows. No implica haber validado todas las marcas, modelos y combinaciones.

Antecedente resuelto en los dispositivos probados: los botones funcionaban, pero los mandos PlayStation se mostraban como Xbox. La corrección integrada consulta el ID original del navegador y contempla la firma Sony de Windows y el nombre observado en macOS.

- [x] Registrar el PlayStation probado en Chrome/macOS: Wireless controller (STANDARD GAMEPAD), y Chrome/Windows: Wireless controller (STANDARD GAMEPAD Vendor: 054c Product: 05c4). Windows se reconoce por fabricante Sony; macOS usa el nombre conocido, sin garantía universal para mandos genéricos.
- [x] Revisar la identidad real: Windows entrega Vendor 054c y Product 05c4; macOS entrega un nombre genérico conocido. La identificación en macOS sigue siendo una heurística y no garantiza todos los dispositivos.
- [x] Consultar en web el ID original de navigator.getGamepads para no depender de nombres normalizados por Godot; conservar la detección por nombre/vendor y las acciones actuales. Usuario confirmó iconos correctos con el mando físico probado; las combinaciones adicionales siguen pendientes.
- [x] Retirar por indicación del usuario el botón Icons, la acción de cambio y el servicio de selección manual. Resolver iconos automáticamente sin agregar controles a las tarjetas.
- [ ] Probar iconos automáticos al reconectar y en equipos distintos. No quedan preferencias manuales ni caché por índice de mando.
- [ ] Probar mandos PS4/PS5 y Xbox juntos: iconos en franja, tutorial, confirmaciones y pausa, sin cambiar la asignación de slots.

Aceptación: cada jugador ve los iconos correspondientes a su mando en la web probada, mediante detección automática, sin selector manual de iconos. No prometer detección automática si el navegador no entrega identidad suficiente.

## N5. Implementado — límite de cinco minutos y resultado por tiempo

Implementado el 12/11 en feature/match-timer desde master ac0c097, sin commit/push. Esta rama no incluye addRemainingClasses, que integra el compañero. Al combinarla, conservar el spawn por CharacterData del compañero y los enlaces del MatchClock; no reemplazar main.gd completo por una de las versiones.

- [x] Mostrar 5:00 arriba centrado, margen superior de 6 px, blanco con contorno oscuro de 6 px, tamaño 30 (reducido desde 36 a pedido del usuario), sin recuadro. Componente MatchClock reutilizable dentro del HUD, independiente de la cámara.
- [x] Contar cinco minutos efectivos de combate desde el final de GO!, oculto durante la selección y el tutorial/contador previo.
- [x] Detener el tiempo con la pausa del árbol, incluida recuperación de mandos; detenerlo al mostrar resultado y restaurarlo en revancha con una instancia nueva.
- [x] Al agotarse, comparar corazones restantes → HP → empate. Excluir participantes eliminados y mantener victoria anticipada por último superviviente.
- [x] Quien espera respawn con vidas restantes participa con max_health, la salud que recibirá al reaparecer, para no penalizar por el cero temporal además del corazón perdido. Regla comunicada al usuario al comenzar; pendiente de su revisión del resultado.
- [x] Mostrar motivo del resultado en inglés cuando termina por tiempo; conservar los textos previos para victoria/eliminación normal.
- [x] Resolver el vencimiento de forma diferida al final del procesamiento para considerar las pérdidas de vida del mismo cuadro; proteger el cierre único de ronda.
- [x] tests/match_timer_smoke.tscn: validar avance real del reloj, pausa, vencimiento único, GO!, duración 300, posición horizontal, prioridad de vidas/HP, empate, respawn oculto, eliminación simultánea, victoria anticipada y reset en revancha con slots no consecutivos.
- [x] Regresión ejecutada: integration_flow_smoke, round_result_smoke, pause_smoke y gamepad_recovery_smoke. Pasan sus comprobaciones; mantienen avisos de recursos/instancias pendientes al salir, también vistos en revisiones anteriores, no resueltos por esta feature.
- [ ] Probar visualmente tamaño, contraste y posición del reloj en Godot y varias ventanas; verificar que no se superpone a tarjetas HUD de las cuatro clases.
- [ ] Integrar con la base final del compañero y validar en la exportación web publicada. No se exportó ni publicó esta feature todavía.

Aceptación: la ronda dura como máximo cinco minutos de combate efectivo; resultado consistente y reloj legible. Implementación y pruebas automatizadas completas; aceptación visual/integración pendientes.

## N6. P1 — opciones reales de música y efectos

Orden actualizado el 13/11: implementar después de la artística de Home (N12), por indicación del usuario.

Implementado en `feature/audio-options`, desde `3e8a25d`. AudioSettings conserva ajustes durante la sesión, sin guardarlos entre ejecuciones. 100% conserva el nivel de referencia de cada bus; mute conserva el volumen elegido. La nueva dirección musical de Home sigue pendiente como tarea separada.

Requisito: acceso desde Home y pausa, con checkbox de mute y slider de volumen independiente para Música y FX. Reutiliza el ítem 9, los buses existentes y una configuración compartida.

- [x] Crear un mismo panel de opciones reutilizable desde ambas pantallas y habilitar sus accesos.
- [x] Agregar Music: checkbox Mute y slider de volumen con valor visible.
- [x] Agregar Sound effects: checkbox Mute y slider de volumen con valor visible.
- [x] Aplicar cada control a su bus sin silenciar el otro; conservar el volumen elegido al mutear y desmutear.
- [x] Compartir la configuración durante cambios de escena y revancha; decidir más adelante si se guarda al cerrar el juego.
- [x] Asegurar manejo con teclado, mouse y el mando que controla la pausa, respetando confirmación y volver.
- [x] Incorporar efectos reales de combate desde improveGameFeel; ya hay material para validar mute y volumen.
- [x] Enrutar daño, dash, empuje, muerte, disparos y efectos de martillo al bus FX; conservar volúmenes individuales y controlar el grupo desde las opciones.
- [ ] Probar mute y volumen contra música y efectos reales, incluidas transiciones y pausa.
- [x] Godot sin ventana: pasan opciones (ganancias y mute independientes, sincronización Home/pausa, clics reales en checkbox/slider, navegación, propiedad del mando y recuperación), pausa/reconexión/Home, música e integración. Persisten avisos de recursos al cerrar algunas pruebas.
- [ ] Aprobación visual y auditiva del usuario en Godot y comprobación de ambos controles en la versión web.

Aceptación: ambos accesos editan los mismos valores y los cambios se escuchan en la versión web.

## N7. P1 — claridad del selector y coherencia de colores

- [x] Ajuste de paleta pedido el 13/11: P1 rojo vivo (#ff3347) para diferenciarlo del marrón; P2 azul (#2796ff); intercambio de P3/P4: P3 verde (#2ecc71), P4 marrón (#9c764a). Ajuste visual en prueba, pendiente de aprobación del usuario. Se aplica desde PlayerManager a selector, equipo e identificadores/HUD.

- [x] Agregar At least 2 players are required to play. abajo centrado sobre el fondo azul, justo encima de la franja de controles con 8 px de separación, con tamaño 18 y color claro, visible con cero/un participante y oculto con dos o más. Implementado en feature/selection-feedback desde 0f6f638 (timer guardado por el usuario); no cambia tamaño/posición de tarjetas ni agrega un botón de espera.
- [x] Ejecutar selector_ui_smoke en una copia con el ajuste: pasan tarjetas centradas de ancho fijo, franja inferior y confirmación; mantiene avisos de instancias al salir.
- [x] Usuario aprobó visualmente el aviso debajo de las tarjetas y lo guardó/publicó en su rama: ab84385. La integración final y exportación con todas las features siguen pendientes.
- [ ] Mantener la confirmación de partida solo cuando haya dos o más participantes, todos listos; informar el estado sin alterar ancho fijo ni composición de las tarjetas.
- [ ] Comparar color del slot, imagen de selección, equipo del personaje, identificador y HUD para cada jugador y arquetipo.
- [x] Unificar fondos del selector, equipamiento, indicador y HUD con PlayerManager.PLAYER_COLORS; paleta aprobada y guardada en 4744fba por el usuario: P1 rojo vivo (#ff3347), P2 azul, P3 verde y P4 marrón. Retirar cuatro fondos duplicados de character_select.tscn y configurar cada slot desde la paleta, incluso antes de incorporarse. Quitar preserve_original para P1: todos aplican la misma regla de equipo. Implementado en feature/player-color-consistency desde 543a29d.
- [x] Mantener borde de selección blanco/negro y materiales/estilos independientes por jugador; el retrato prerenderizado conserva su arte original y no se pinta como un bloque de color.
- [ ] Revisar visualmente las cuatro clases cuando el compañero las integre: las comprobaciones actuales de juego cubren Gunner y Demolisher de esta base.
- [x] Ejecutar player_color_consistency_smoke y player_palette_smoke: cuatro slots del mismo personaje, color del selector vacío/activo/listo, equipo, flecha, etiqueta, HUD, aislamiento de estilos, salir/reingresar y conservación tras daño. Regresiones selector_ui_smoke e integration_flow_smoke aprobadas; persisten avisos de recursos/instancias al cerrar tests ya registrados.
- [ ] Usuario revisa visualmente la coincidencia de fondo/identidad y la legibilidad de los cuatro slots, antes de integrar y exportar.
- [ ] Probar contraste del texto y colores en el build web.

Aceptación: se entiende el mínimo de jugadores y se reconoce el mismo color de jugador antes y durante la pelea.

## N8. Implementado — feedback de eliminación definitiva

Implementado en feature/elimination-feedback desde ab84385, selección y timer ya guardados por el usuario. No incluye addRemainingClasses; al integrar conservar el HUD de Scout del compañero junto con estos estados. Sin commit/push por el asistente.

- [x] Distinguir muerte temporal de eliminación: activar el feedback solo al perder la última vida. El HUD escucha lives_changed, sin cambiar daño ni respawn.
- [x] Mostrar Player N eliminated! durante tres segundos efectivos de juego debajo del timer, en una lista centrada, con contorno oscuro y color del jugador aclarado para legibilidad.
- [x] Mostrar mensajes simultáneos sin pisarse ni bloquear controles; no repetir el aviso del mismo slot en una ronda y detener su duración en pausa.
- [x] Conservar Eliminated visible en la tarjeta HUD, atenuar retrato y ocultar indicadores de arma; el número Pn y los textos permiten identificar el estado sin depender solo del color.
- [x] Respetar la transición inmediata al resultado existente: la pantalla del ganador tiene prioridad visual sobre los avisos, sin demorar el fin de partida.
- [x] Limpiar avisos y slots anunciados al reconstruir el HUD; la revancha crea tarjetas activas nuevas y salir elimina la escena con sus timers.
- [x] Prueba específica: muerte temporal, última vida, duplicados, mensajes simultáneos, pausa/expiración, estado persistente, transición a ganador y reset del HUD.
- [x] Regresión del timer y flujo integrado de partida: pasan las comprobaciones. Persisten avisos de instancias/recursos al cerrar los tests, registrados anteriormente.
- [ ] Revisar visualmente posición/contraste de mensajes y tarjetas con dos/cuatro jugadores y en distintas ventanas, incluida eliminación simultánea final.
- [ ] Integrar sobre la base del compañero y probar la exportación web. No está publicada esta feature.

Aceptación: se reconoce la eliminación definitiva sin confundirla con respawn ni interrumpir el combate de los demás. Implementación y comprobaciones automatizadas completas; revisión visual y web pendientes.

## N9. P2 — caída al agua y reaparición a los dos segundos

Requisito del usuario: representar la caída y reaparecer después de dos segundos si quedan vidas. En ac0c097 respawn_delay sigue en 0,8 segundos y los personajes activos no lo sobrescriben; no marcar este requisito como terminado. Hacerlo después de N1 para reutilizar un respawn seguro.

- [x] Separar en código el origen: lose_life(true) desde daño reproduce animación de muerte si hay sprites; la caída usa lose_life() y oculta directamente. Esto no implementa una animación de agua.
- [ ] Incorporar una presentación específica para la caída al agua, que todavía no tiene splash, tiburón ni alma.
- [ ] Elegir una o varias presentaciones: splash del agua; tiburón que se come al pingüino; alma que asciende al cielo.
- [ ] Propuesta para hoy: splash breve y hundimiento/desaparición del personaje. Dejar tiburón y alma como mejoras alternativas salvo decisión expresa.
- [ ] Capturar el punto de caída para el efecto y consumir una sola vida; evitar impactos o nuevas caídas durante la secuencia.
- [ ] Esperar dos segundos desde la caída antes de reaparecer en un punto validado sobre el hielo; respetar la pausa y la protección al volver.
- [ ] Si no quedan vidas, finalizar la caída con la eliminación definitiva y el feedback de N8, sin respawn.
- [ ] Limpiar efectos al terminar la ronda, reiniciar o salir; comprobar varias caídas simultáneas y convivencia con la cámara.

Aceptación: la caída es visible, se pierde una sola vida y el jugador con vidas vuelve al hielo a los dos segundos de juego, sin contar tiempo pausado.

## N10. P2 — UNA novedad de jugabilidad

No implementar las tres alternativas para esta entrega. Elegir con el usuario después de cerrar correcciones y comprobar el margen para publicar.

- [ ] Elegir una alternativa: ballena que cruza/barre la arena; vida extra que aparece en el hielo; armas para recoger y cambiar equipamiento.
- [ ] Propuesta de menor alcance: pickup de una vida extra, reutilizando vidas/HUD. Confirmar que otorga un corazón, no HP, y definir el máximo permitido.
- [ ] Para vida extra: definir frecuencia y aviso de aparición, posición segura sobre el hielo, recogida por un solo jugador y feedback visible; evitar consumirse sin beneficio si ya está al máximo.
- [ ] Respetar pausa, fin de ronda y revancha; evitar objetos duplicados, recogidas múltiples y vidas para jugadores eliminados.
- [ ] Si se elige ballena: anticipar dirección/zona con tiempo para esquivarla, resolver colisiones una vez por pasada y retirar el evento al terminar.
- [ ] Si se eligen armas: aprovechar equip/unequip existentes, definir aparición y recogida y conservar propietario, controles y cooldowns.
- [ ] Validar que la alternativa elegida aporta una decisión o riesgo al combate y no impide terminar la ronda.

Aceptación: UNA mecánica adicional funciona durante una partida completa. Las subtareas de alternativas no elegidas quedan fuera del alcance implementado.

## N11. Coordinación — sangre, acción y frenetismo

Responsable de los avances: el compañero. improveGameFeel ya está integrado en master ac0c097; no duplicar su implementación. Estado por inspección de código/recursos, pendiente de prueba del conjunto.

- [x] Integrar improveGameFeel hasta 75a419b mediante PR #7 y merge de master.
- [x] Conservar el destello blanco e inclinación de daño de ed68efb y agregar sonido al recibir daño.
- [x] Agregar sonidos de dash, choque por dash, disparo, movimiento/impacto del martillo, carga completa y muerte por daño.
- [x] Agregar destello de disparo y sprite animado del proyectil del rifle.
- [x] Implementar ráfagas de cuatro, cargador de doce, recarga automática y visualización de munición/recarga en HUD.
- [x] Implementar carga de martillo, ataque de área con onda visual, empuje y sacudida de cámara; barra CHARGE siempre visible y daño cargado limitado a 70.
- [x] Agregar animaciones direccionales de muerte por daño para Gunner y Demolisher y restauración visual al reaparecer.
- [x] Ampliar HUD con retratos y estado de cada arma mediante una escena de tarjeta reutilizable.
- [ ] Confirmar con el compañero si falta sangre u otros efectos prometidos: los nuevos sonidos y muertes no equivalen a una implementación de sangre.
- [ ] Validar el conjunto en una partida completa y en web, incluidas armas durante muerte, pausa, desconexión y revancha; revisar N17.
- [ ] Completar compatibilidad con FX/mute de N6, caída de N9 y paletas; no considerar resuelto el zoom de N2 por haber agregado sacudida.

## N12. P3 — identidad visual de Home

Implementación en `feature/polar-home`, a partir de `603fc79`. El usuario eligió la propuesta de paisaje nevado con título azul oscuro y sombra roja. Se mantienen título y botones quietos; el movimiento ambiental reemplaza el paneo de cámara propuesto inicialmente.

- [x] Elegir Press Start 2P para el título y los botones; incluir fuente y licencia SIL OFL en el proyecto.
- [x] Armar un fondo polar con hielo, agua y un pingüino con casco y bufanda roja, separado del paisaje mediante transparencia.
- [x] Mantener la cámara y la interfaz estables; concentrar el movimiento en nieve, agua y bufanda según la propuesta elegida.
- [x] Animar la nieve en dos capas y el agua mediante shaders; animar los extremos de la bufanda sin desplazar el personaje.
- [x] Conservar navegación, inicio de partida y Options oculto hasta trabajar en opciones de audio.
- [x] Comprobar sin ventana transparencia, distribución en cuatro tamaños de pantalla, estabilidad del título/botón, animación de bufanda y transición Play; también pasa el recorrido integrado existente. Las pruebas todavía reportan recursos pendientes al cerrar.
- [x] El usuario probó y aprobó Home, y confirmó sus cambios pusheados antes de avanzar al selector.
- [ ] Comprobar proporciones de pantalla, fluidez y coste del fondo en la exportación web.

Aceptación: se percibe el ambiente polar y el título tiene identidad sin dificultar el uso del menú.

### N12a. Selector — fichas militares polares

Propuesta 2 elegida por el usuario. Rama `feature/military-selector`, conservando las reglas y acciones de selección existentes.

- [x] Reutilizar el paisaje polar, agua y nieve de Home, sin el pingüino decorativo del menú.
- [x] Incorporar título pixel azul con sombra roja y cuatro fichas azul oscuro con grilla, detalles metálicos y encabezados con los colores compartidos de los jugadores.
- [x] Mantener ancho y alto fijos de las fichas al entrar, elegir y confirmar; conservar retratos y atributos reales, y personajes no disponibles bloqueados.
- [x] Mostrar número de jugador y nombre del personaje por separado, una marca READY al confirmar y un icono de mando en espacios libres.
- [x] Mantener el aviso de mínimo de jugadores, la fila de ayudas y los botones unificados del diálogo de confirmación.
- [x] Godot sin ventana: pasan márgenes y tamaños fijos, estados vacíos/activos/READY, disponibilidad, atributos, correspondencia de colores, botones unificados y recorrido integrado. Persisten avisos de recursos al cerrar las pruebas; no equivalen a una validación visual o del rendimiento web.
- [ ] Revisar apariencia y animaciones en Godot con el usuario y comprobar el resultado en web antes de publicar.

## N13. Obligatorio — integración, exportación y publicación

- [ ] Definir el corte de features antes del tramo final y conservar una versión estable para entregar.
- [x] Integrar correcciones web e improveGameFeel en master ac0c097.
- [ ] Probar el conjunto integrado antes de publicar; los tests y confirmaciones de la exportación anterior no validan estas armas, sonidos y HUD nuevos.
- [ ] Ejecutar comprobaciones pertinentes y un recorrido manual: Home → selección de dos o más → tutorial → contador → combate → resultado → revancha → Home.
- [ ] Probar pausa/opciones, daño, caídas, respawn, eliminación, timer y desconexión/reconexión según lo implementado.
- [ ] Exportar con versión de Godot/plantillas correctas y verificar que los archivos generados correspondan a la versión probada.
- [ ] Publicar en GitHub Pages solo con autorización del usuario o a cargo del usuario; comprobar que el push realmente llegó al remoto y que el despliegue terminó.
- [ ] Abrir la URL final con recarga limpia en Chrome/macOS y Chrome/Windows; comprobar audio, mandos e iconos con equipos físicos.
- [ ] Registrar qué quedó terminado, qué falta validar y qué se difiere, y entregar el enlace antes de las 00:00 del 7/11 (Argentina).

## N14. Compañero — empuje suave por contacto sin dash

Responsable asignado por el usuario el 13/11: compañero. No implementar en nuestras ramas.

- [ ] Al terminar nuestras otras features, revisar la rama integrada del compañero y probar si ya implementó este contacto suave; si no, registrar el pendiente y acordar el siguiente paso.

Requisito del usuario: al caminar contra otro personaje y hacer contacto sin dash, desplazarlo lentamente para que no se sienta como chocar contra una pared. Este contacto no produce daño.

- [ ] Detectar el contacto entre personajes durante el movimiento normal, separado del impacto de dash.
- [ ] Aplicar un empuje leve en la dirección del contacto, con velocidad baja y ajustable; conservar el empuje fuerte del dash.
- [ ] No reducir HP ni vidas por el contacto suave. La caída al agua conserva sus reglas actuales.
- [ ] Evitar empujes estando quietos y oscilaciones o acumulación de velocidad cuando el contacto se mantiene.
- [ ] Probar el contacto entre dos jugadores, ambos caminando uno contra otro, cerca del borde y con varios personajes juntos; comprobar pausa y respawn.

Aceptación: caminar contra otro jugador lo desplaza suavemente sin daño directo; el dash sigue siendo claramente más fuerte. Prioridad por acordar antes de implementar.

## N15. Implementado — unificar botones y ayudas duplicadas

Aclaración del usuario el 13/11: el problema es la duplicación de botones convencionales y ayudas con la misma acción en Ready to play y otras pantallas. Conservar una sola representación con iconos, clickable y con el comportamiento existente. No cambiar asignación del mouse a jugadores, ni rediseñar las acciones de las tarjetas.

Implementado en feature/unified-ui-actions desde 4744fba (paleta guardada/pusheada por el usuario). No se hizo commit/push por el asistente.

- [x] Reutilizar ActionButton, derivado de Button, con ControlPrompt como contenido: un solo texto e iconos, accesibilidad por nombre, superficie clickable completa, hover/foco y estado deshabilitado.
- [x] Corregir superposición reportada en Ready to play: reservar custom_minimum_size a partir del contenido real y actualizarlo cuando cambia su mínimo. Conservar separación entre acciones. Recuperar el fondo normal del tema Button anterior en Ready y tutorial (flat=false), con sus estados nativos.
- [x] En Ready to play, retirar la fila de botones convencionales duplicados. Let's play y Keep choosing con sus iconos son ahora las únicas acciones visibles, conectadas a los mismos callbacks de aceptar/cancelar.
- [x] En el tutorial, Next/Start countdown y Back incorporan sus iconos; retirar la fila de ayudas repetida. Conservar las dos páginas y los controles de juego informativos.
- [x] Conservar los mapeos existentes, protección de pulsaciones mantenidas y recuperación de mandos. No cambiar home/pausa/resultados ni tarjetas que no tenían esta duplicación.
- [x] unified_actions_smoke: clics reales al viewport, teclado, disabled, cancelación/reapertura/inicio y tutorial sin doble activación. Ampliado tras el reporte visual: verificar que cada botón contiene texto/iconos, los rectángulos no se superponen, se respeta la separación de 24 px en Ready y 16 px en tutorial, el panel cabe en 1152 × 648 y el fondo está habilitado. Regresiones selector_ui_smoke y tutorial_navigation_smoke aprobadas con el ajuste.
- [x] Regresiones: tutorial_navigation_smoke, countdown_smoke, selector_ui_smoke, match_timer_smoke e integration_flow_smoke. Comprobaciones aprobadas; persisten avisos de instancias/recursos al cerrar algunos tests, ya registrados.
- [ ] Usuario revisa visualmente tamaño/espaciado, hover y legibilidad de las acciones con iconos.
- [ ] Integrar y probar con mandos físicos en la exportación web final.

Aceptación: una sola acción visible por operación en las pantallas corregidas, clickable y utilizable con sus controles habituales, sin duplicar botón y ayuda.

## N16. Resuelto — música entrecortada con el juego visible

- [x] El usuario confirma el 12/11 que está resuelto y solicita descartarlo del trabajo pendiente. No continuar el diagnóstico ni cambiar el modo de reproducción de música por esta incidencia.

Antecedente conservado: el compañero reportó cortes en Windows + Brave, en todas las pantallas, con reproducción fluida al cambiar de pestaña. Se propuso comparar Chrome en esa misma PC y evaluar Stream/Sample; no se recibió detalle técnico de qué resolvió el problema. No atribuir la resolución a una modificación no comprobada. Las futuras pruebas generales de audio forman parte de N13 y no reabren este bug.

## N17. Pendiente — validar e informar las nuevas mecánicas integradas

### Instructivo corregido en feature/tutorial-weapons

Base 6dc36b8, eliminación guardada/pusheada por el usuario. Por indicación posterior se retiró por completo la página de armas y sus descripciones. No se integró addRemainingClasses ni se modificaron ataques.

- [x] Mantener solo How to win y Controls antes de 3, 2, 1, GO!.
- [x] Informar máximo cinco minutos, victoria anticipada y desempate por vidas → HP → empate.
- [x] En Controls, mostrar únicamente Attack con el icono de la acción ya mapeada: Cuadrado en PlayStation, X en Xbox y F/clic izquierdo en teclado/mouse. Sin explicaciones específicas de armas ni nuevas acciones.
- [x] Agregar Back junto a Start countdown en Controls para volver a How to win, con clic o selection_cancel (Escape/Círculo/B), e incluir la ayuda con sus iconos.
- [x] Ocultar Back en la primera página e impedir retroceso durante el contador o suspensión; conservar reconexión y revancha.
- [x] tutorial_navigation_smoke: dos páginas, ausencia de WeaponGuides, duración, Attack con iconos, navegación mouse/teclado/joystick, suspensión, contador y distribución dentro de 1152 × 648.
- [x] Regresión ejecutada: countdown_smoke, match_timer_smoke e integration_flow_smoke, con flujo original de dos páginas restaurado. Comprobaciones aprobadas; persisten avisos de recursos/instancias al salir de los tests registrados anteriormente.
- [x] Usuario aprobó el instructivo y guardó/pusheó 543a29d. Integración final y prueba web pendientes; el asistente no hizo commit/push/exportación.

Derivado de la revisión de master ac0c097. Son comprobaciones de integración y claridad, no autorización para modificar código durante esta revisión.

- [x] Informar en inglés duración máxima de cinco minutos y victoria anticipada por último superviviente en la página How to win.
- [x] Simplificar por pedido del usuario: Attack con su icono dentro de Controls, sin sección ni explicaciones adicionales de armas.
- [ ] Verificar consumo de munición y estado de ráfaga/recarga al morir y reaparecer. El respawn reanuda el arma existente, sin volver a llamar setup; acordar si se conserva o rellena el cargador.
- [ ] Verificar cancelación de carga/ataques y limpieza de la barra en dash, muerte, pausa, desconexión, resultado y revancha.
- [ ] Probar ataque normal y cargado: alcance, daño máximo 70, varios objetivos, un impacto por objetivo y protección de respawn.
- [ ] Revisar legibilidad y dimensiones de las nuevas tarjetas HUD con cuatro jugadores, resolución web y proporciones de ventana distintas.
- [ ] Verificar disparos, destellos y muerte en todas las direcciones; en reaparición restaurar arma, brazo, indicador y animación de movimiento.
- [ ] Revisar comodidad de la nueva sacudida y compatibilidad con la incidencia de cámara de N2.
- [ ] Probar el audio nuevo en web y separar Music/FX según N6; no dar por resuelto el corte de Brave de N16 por integrar más sonidos.

## Decisiones para el próximo paso

- [x] Timer: corazones → HP → empate, confirmado por el usuario.
- [ ] Cámara: encuadre fijo recomendado para hoy o mantener zoom dinámico con límites/esperas.
- [x] Implementación N5: un jugador temporalmente muerto con vidas se compara con el HP completo de su próximo respawn; comunicado al usuario, pendiente de revisión manual.
- [x] El usuario descartó la selección manual de iconos. Investigar identificación automática con datos reales antes de descartar casos.
- [ ] Caída: splash recomendado para hoy, tiburón/alma como alternativas.
- [ ] Novedad: vida extra recomendada, máximo y frecuencia por acordar; ballena/armas como alternativas.
- [ ] Corte de alcance y disponibilidad del trabajo del compañero.

---

## Historial — entrega del 31 de octubre de 2026

Registro histórico actualizado el 30 de octubre de 2026. Sus prioridades y estados antiguos no reemplazan el plan vigente del 6 de noviembre que aparece arriba.

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

- [x] Ajustar la cuenta regresiva en `feature/military-selector`: mostrar solamente 3, 2, 1 y GO!, sin fondo cuadrado, usando Press Start 2P blanca con contorno oscuro. Conservar tamaño de fuente 72 y animación de crecimiento. El usuario aprobó el resultado visual.

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
    - [x] Criterio acordado el 6/11: al llegar a 0:00, más corazones restantes; a igualdad de corazones, más HP; a igualdad de ambos, empate. Implementación pendiente; ver N5.

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

- [x] Efecto visible de daño integrado en master en ed68efb (destello blanco e inclinación). Las subtareas originales de esta sección se conservan como antecedente; la revisión visual actual se coordina con el compañero en N11.
    - [ ] Definir la presentación visual. Propuesta pendiente: destello breve blanco o rojizo y pequeña inclinación del sprite, con recuperación rápida.
    - [ ] Aplicar la reacción únicamente a la representación visual; conservar la forma de colisión y la dirección física del personaje.
    - [ ] Mantener los colores identificadores de jugadores al terminar el efecto y distinguirlo de la protección temporal al reaparecer.
    - [ ] Resolver impactos consecutivos sin acumular inclinaciones ni dejar el personaje teñido.
    - [ ] Probar legibilidad durante combate y en proyector; evitar depender exclusivamente del rojo o de un parpadeo repetido.
    - [ ] Complementar más adelante con un efecto de sonido de impacto en el bus de FX.

## Música original — primera propuesta

### Próximo cambio — dirección musical de Home

- [x] Registrar nueva dirección tras rechazar las tres marchas lentas: tensión antes de una batalla, energía competitiva, destreza y urgencia. Mantener identidad bélica, redoblantes y flautas; evitar tono fúnebre y no fijar 52 BPM como requisito.
- [x] Preparar tres muestras originales de esa dirección para comparar con Suno: Orden de asalto (35,56 s), Rivales en el hielo (32,73 s) y Cuenta atrás de guerra (33,10 s). Archivos 04/05/06 en assets/audio/music/previews, generador tools/compose_battle_themes.py, en la misma rama de música. No se cambia la reproducción vigente.
- [ ] Comparar estas muestras con los resultados de Suno y elegir la dirección musical definitiva con el usuario.
- [x] Recibir devolución de la primera muestra: sigue demasiado animada. Nueva dirección: marcha militar sombría, redoblantes y flautas de guerra, melodías espaciadas y sin brillo alegre.
- [x] Preparar tres muestras originales alternativas, sin integrarlas: Procesión del hielo (52 BPM, 27,69 s), Batallón polar (60 BPM, 32 s) y Asedio en la niebla (48 BPM, 30 s). Archivos 01/02/03 en assets/audio/music/previews y generador tools/compose_dark_marches.py.
- [ ] Elegir y ajustar una de las tres muestras según escucha del usuario antes de reemplazar la música vigente.
- [x] Preparar la muestra original home_polar_march.wav en assets/audio/music/previews, rama `feature/home-march-music` desde `375c5c8`: 80 BPM, 16 compases, 48 segundos, chiptune marcial oscuro con bajo grave y acentos fríos. Generador reproducible tools/compose_polar_march.py. No reemplaza todavía la pista vigente del juego.
- [ ] Escuchar y aprobar o ajustar esta muestra antes de integrarla; la validación del WAV no equivale a aprobación artística.
- [ ] Reemplazar la música de Home por una composición original chiptune/8 bits, más lenta, tenebrosa y marcial; abandonar el drum and bass para esta pantalla.
- [ ] Transmitir amenaza, guerra y tensión mediante pulsos graves, percusión de marcha y armonías oscuras. La marcha de Darth Vader es una referencia de carácter, sin reproducir su melodía ni buscar una pieza que se le parezca.
- [ ] Preparar una muestra para aprobación auditiva antes de reemplazar el bucle definitivo; conservar un loop continuo sin cortes.
- [ ] Revisar la transición hacia el selector: hoy ambas pantallas comparten música. Acordar si el nuevo tema también continúa allí, sin extender automáticamente el cambio al combate.
- [x] Abrir una rama propia para la muestra, sin modificar todavía la reproducción de audio del juego, ni hacer commit o push.

### Antecedentes implementados

Implementado originalmente en `feature/music`, integrado en master en 4f292b5. El feedback de daño también está integrado, en ed68efb. La falta de audio en Chrome/Windows durante la demo se reabre en N3.

- [x] Componer un bucle para Home y selección: drum and bass chiptune divertido, pianito y sintetizador minimalista.
- [x] Componer un bucle de combate más intenso con batería marcada, bajo pesado y sintetizador de fondo, compartiendo el motivo del menú.
- [x] Guardar WAV y generador reproducible sin samples externos en el proyecto.
- [x] Integrar reproducción persistente entre menús y cambio a combate al terminar el contador, también en revancha.
- [x] Separar buses Music y FX, manteniendo Options oculto hasta implementar su configuración real.
- [x] Verificar con Godot 4.7.2 la importación WAV, bucles PCM estéreo completos, buses separados, transiciones interrumpidas y reproducción durante pausa. Pruebas de integración y tutorial/contador aprobadas. Archivos sin saturación digital y continuidad de muestras en el límite del bucle comprobada; falta aprobación auditiva del usuario.
- [x] El usuario probó y aprobó la segunda propuesta musical antes de autorizar su merge. La incidencia de reproducción web sigue abierta en N3.

- [x] Segunda propuesta musical: conservar BPM y patrones de batería, reforzar drones oscuros y fríos, bajo de combate y acentos metálicos; reducir el brillo melódico. Aprobada por el usuario e integrada en 4f292b5.

## Identificación de mandos en exportación web

- [x] El usuario confirmó que los botones funcionan y el problema es únicamente visual.
- [ ] Reproducir con mando físico la exportación publicada; confirmar navegador, sistema operativo y nombre/ID reportado.
- [x] Ampliar la detección visual de PlayStation para nombres y vendor ID 054c en formatos web de Chromium y Firefox/Safari, incluidos ceros omitidos. Reconocer PS5 por nombre o IDs de producto conocidos. Conservar el mapeo de acciones.
- [x] Probar clasificadores, iconos, falsos positivos, selector y tutorial/contador con Godot 4.7.2. No implica validación con mandos físicos en navegador.
Selección manual descartada por el usuario el 6/11: conservar solo identificación automática y probar con nombres reales del navegador.
- [ ] Probar dos mandos de marcas distintas y reconexión en la versión publicada. No asumir que el GUID web identifica un dispositivo físico; puede ser simplemente standard.

## Avance N3/N4 — correcciones web del 6 de noviembre

Rama `feature/web-audio-and-controller-icons`, sin commits ni push. N1/N2 apartados por indicación del usuario, probablemente en manos del compañero; falta confirmar su avance.

- [x] Importación con Godot 4.7.2 sin errores de compilación y exportación web completa en copia de prueba.
- [x] Pruebas automatizadas: inicio de audio con clic/tecla/toque, espera ante joystick sin gesto de navegador, última pista solicitada, modos PS4/PS5/Xbox por dispositivo, iconos, tamaño fijo de tarjetas/franja, recuperación de preferencias por jugador y mapeos intactos.
- [x] Regresiones de música, clasificador, selector, tutorial/contador, integración completa, pausa y recuperación de mandos.
- [ ] Escuchar y probar el build en navegador con mandos físicos, tanto macOS como Windows, antes de cerrar N3/N4.

Build local de revisión: `/Users/lucky/Documents/Codex/2026-10-01/ne/work/web-fixes-export/index.html`. No publicado. La apertura automatizada del navegador local fue rechazada por el permiso del navegador; no se sorteó ese bloqueo. Las pruebas de Godot y la exportación no equivalen a una prueba auditiva en Chrome/Windows.

## Revisión acordada — inicio e iconos automáticos

- [x] Eliminar por completo Click or press a key to start y el botón Icons: Auto, sin reemplazarlos por nuevas interfaces.
- [x] Restaurar reproducción automática desde Home y mantener Stream para la música. El juego no demora la reproducción hasta un evento de entrada.
- [x] Obtener el ID real del PlayStation del usuario en Chrome: Wireless controller (STANDARD GAMEPAD), índice 0, mapping standard. No informa Sony ni vendor ID.
- [x] Reconocer exactamente Wireless controller, con o sin el sufijo (STANDARD GAMEPAD), como la firma de PlayStation observada. No clasificar cualquier mando inalámbrico como Sony: Xbox Wireless Controller sigue siendo Xbox.
- [x] Usar el ID original de navigator.getGamepads en web para evitar los nombres sustituidos por el mapeo de Godot.
- [x] Pruebas de ausencia de las interfaces retiradas, solicitud automática de música, firma exacta aportada por el usuario, Xbox y regresiones de música, selector, tutorial/contador e integración. Exportación web generada sin errores de compilación.
- [ ] Usuario: confirmar audio sin tocar el juego e iconos PlayStation en la copia actualizada. Luego verificar Windows y publicación.

La detección por el nombre observado es una regla concreta apoyada en el mando identificado por el usuario, no una garantía de poder distinguir todos los dispositivos que compartan un nombre genérico. Las reglas de autoplay del navegador siguen sujetas a comprobación real; no se las deshabilitó ni se cambiaron preferencias del navegador.

## Lista aportada por feedbacks — conservar como referencia del compañero

Actualizado: 24 de noviembre de 2026.

Las tareas ya implementadas se quitaron de esta lista. El orden va de menor a mayor esfuerzo estimado y puede variar según los mandos disponibles y el arte que haya que producir.

## Tareas pendientes — de más fácil a más difícil

1. [ ] Comprobar en partida el nuevo alcance del arpón (256 px) y su presentación durante el ataque.
2. [ ] Extender la franja de ayuda contextual a las demás pantallas.
3. [ ] Revisar si siguen vigentes los fallos registrados el 30/10 en `weapons_2_smoke`, `upward_weapon_smoke` y `health_lives_smoke`; actualizar las pruebas o retirar supuestos obsoletos. `projectile_smoke` quedó registrado con PASS a 60 FPS.
4. [ ] Revisar visualmente el selector, el tutorial, la cuenta regresiva, los resultados y la aparición y el ataque de la ballena.
5. [ ] Hacer una partida manual completa con mandos físicos y mouse: Home → selección → tutorial → combate → pausa → resultado → revancha y regreso al menú. Incluir daño, caídas, eliminación y reconexión.
6. [ ] Probar desconexión y reconexión con mandos físicos en Windows y macOS, incluidos dos mandos iguales. Si la exportación web sigue siendo objetivo, probar también navegador, iconos y reconexión con mandos distintos.
7. [ ] Aumentar la velocidad del dash y la fuerza de empuje para que el combate sea más caótico; ajustar el balance en partida.
8. [ ] Completar la parte artística del tutorial y de la cuenta regresiva, incluyendo demostraciones animadas.
9. [ ] Crear una animación al caer al agua: que el personaje se ahogue o que se lo coma otro animal.
10. [ ] Diseñar una identidad visual común para las pantallas y revisar paleta, tipografías, fondos, tarjetas, contraste y estados interactivos.
11. [ ] Diseñar e implementar otros eventos sorpresa para la arena, como movimiento del piso o aparición de vidas; ajustar su impacto en el balance.
12. Poner sonido en el contador al iniciar la partida
