# Apertura de la caja de pescado

Copiá la carpeta `caja_flor` completa dentro de tu proyecto de Godot 4 e instanciá `caja_pescado.tscn`. El origen de la escena es el centro de la caja a la altura del hielo. Al tocar el suelo, llamá a `$AnimationPlayer.play("abrir")` desde la caja.

## Dónde va el premio

Agregá el sprite o la escena del premio como hijo del nodo vacío `Recompensa`, con su base en el origen local y su Z relativa en 0. El reproductor lo hace visible a los 0,33 s, mientras baja la pared del pescado. La base de madera queda debajo del premio. Si volvés a utilizar la misma instancia, llevá la animación al primer fotograma para restaurar la pose cerrada.

| Orden de dibujo | Nodo | Piezas |
| --- | --- | --- |
| Fondo · Z 0 | PlanoTrasero | Sombra, paracaídas, base, pared trasera, pared izquierda y tapa |
| Medio · Z 1 | Recompensa | Espacio para tu ítem |
| Frente · Z 2 | PlanoDelantero | Pared derecha y frente con el pescado |

## Texturas

Cada pared tiene su propio PNG RGBA en `texturas/`. Las ocho hojas comparten la misma grilla de 7 columnas × 2 filas. Cada fotograma mide 192 × 160 px y tiene el pivote en (96, 120). Se leen por filas, de izquierda a derecha. La escena reproduce los 14 fotogramas a 18 fps y conserva la caja abierta al terminar. Si tu escena de entrega ya dibuja el paracaídas durante la apertura, podés ocultar `PlanoTrasero/Paracaidas`.

La tapa aterriza a la derecha. Tres paredes quedan sobre el hielo y la cuarta se detiene con unos 23° de inclinación al apoyarse sobre la tapa.
