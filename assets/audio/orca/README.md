# Sonidos de la orca

Los siete archivos originales están guardados en esta carpeta. La escena usa `AudioStreamPlayer` separados para que puedas cambiar cada stream, volumen y bus desde el Inspector sin editar código.

## Asomo normal

En `src/terrain/Orca.tscn`, seleccioná `AsomoAudio` o `InmersionAudio` para cambiar `Stream`, `Volume dB` o `Bus`. El primer sonido se reproduce al empezar un asomo normal; el segundo, al comenzar la inmersión. Si la orca ataca, ambos se detienen.

## Ataque

En `src/terrain/OrcaAttack.tscn`, los nodos de audio se asignan a estas etapas:

- `AlarmAudio`: alarma durante el ataque. `loop_alarm` permite repetirla mientras dure.
- `JumpAudio`: salto desde el agua.
- `SlideAudio`: deslizamiento sobre el hielo.
- `IceCrackAudio`: segunda capa simultánea para probar el crujido del hielo. `use_ice_crack_layer` permite activarla o quitarla; el nodo tiene volumen independiente.
- `DiveAudio`: inmersión al final del recorrido.

Para atenuar la música, seleccioná la raíz `OrcaAttack` y ajustá `duck_music_during_attack`, `music_duck_db`, `music_duck_fade_seconds` y `music_restore_fade_seconds`. El valor inicial es -12 dB; -60 dB prácticamente la silencia. El nivel elegido en las opciones de música se conserva.

Todos los efectos están en el bus `FX`. Cambiar un `Stream` desde el Inspector no modifica el archivo original.
