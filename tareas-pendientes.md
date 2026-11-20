# Fight Club Penguin — tareas pendientes

Actualizado: 20 de noviembre de 2026.

Las tareas ya implementadas se quitaron de esta lista. Las seis primeras quedan a cargo del compañero; el resto está ordenado de menor a mayor esfuerzo estimado. El orden puede variar según los mandos disponibles y el arte que haya que producir.

## A cargo del compañero

- [ ] Mejorar la diferenciación visual entre personajes durante la selección y el combate.
- [ ] Ampliar el tutorial para explicar cómo cargar y ejecutar los ataques especiales de cada personaje.
- [ ] Al terminar la partida, acercar la cámara al ganador y mostrar un mensaje o festejo durante 5 segundos antes del cartel con las opciones de nueva partida y menú. En caso de empate, mantener el resultado de empate sin enfocar a un ganador.
- [ ] Hacer vibrar el mando cuando su jugador recibe un empuje por dash o disparo; comprobar la intensidad en los mandos compatibles.
- [ ] Validar si se puede sincronizar la luz del mando con el color del jugador; restaurarla al liberar o reconectar el mando.
- [ ] Crear música nueva para el menú y el combate y reemplazar la actual.

## Resto — de más fácil a más difícil

1. [ ] Hacer que el arpón sea más largo y comprobar su alcance y presentación durante el ataque.
2. [ ] Extender la franja de ayuda contextual a las demás pantallas.
3. [ ] Revisar si siguen vigentes los fallos registrados el 30/10 en `weapons_2_smoke`, `upward_weapon_smoke` y `health_lives_smoke`; actualizar las pruebas o retirar supuestos obsoletos. `projectile_smoke` quedó registrado con PASS a 60 FPS.
4. [ ] Revisar visualmente el selector, el tutorial, la cuenta regresiva y los resultados con los mandos disponibles.
5. [ ] Hacer una partida manual completa con mandos físicos y mouse: Home → selección → tutorial → combate → pausa → resultado → revancha y regreso al menú. Incluir daño, caídas, eliminación y reconexión.
6. [ ] Probar desconexión y reconexión con mandos físicos en Windows y macOS, incluidos dos mandos iguales. Si la exportación web sigue siendo objetivo, probar también navegador, iconos y reconexión con mandos distintos.
7. [ ] Aumentar la velocidad del dash y la fuerza de empuje para que el combate sea más caótico; ajustar el balance en partida.
8. [ ] Revisar si se pueden sumar sprites al giro del personaje y más ángulos de apuntado y disparo. El apuntado actual se ajusta a ocho direcciones; confirmar qué permite el arte disponible.
9. [ ] Completar la parte artística del tutorial y de la cuenta regresiva, incluyendo demostraciones animadas.
10. [ ] Crear una animación al caer al agua: que el personaje se ahogue o que se lo coma otro animal.
11. [ ] Diseñar una identidad visual común para las pantallas y revisar paleta, tipografías, fondos, tarjetas, contraste y estados interactivos.
12. [ ] Agregar eventos sorpresa a la arena, como una ballena que aparezca, movimiento del piso o vidas que aparezcan durante la partida; definir cuáles implementar y cómo afectan el balance.
