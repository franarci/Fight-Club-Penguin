# Icebreaker — Fight Club Penguin

Dos composiciones instrumentales originales sintetizadas para el proyecto. No usan grabaciones ni samples externos.

- `menu_icebreaker.wav`: drum and bass chiptune con pianito sintético, drones graves y una capa fría y sombría de sintetizador.
- `combat_icebreaker.wav`: variación del mismo motivo con batería más intensa, bajo subgrave con capa reese reforzada, drones oscuros y acentos metálicos de hielo.

Ambas: 174 BPM, 4/4, 32 compases, aproximadamente 44,14 segundos, centro tonal La menor/Do mayor. WAV PCM estéreo de 16 bits a 32 kHz. Las colas y ecos cruzan el final del archivo para repetir el arreglo completo sin pausas añadidas. Godot activa el bucle sobre todos los frames del WAV.

La música de menú continúa entre Home y selección sin reiniciarse. Acompaña tutorial y contador; al terminar GO comienza combate con una transición de 0,45 segundos. Continúa durante la pausa, desconexiones y resultados. La revancha vuelve a la pista de menú durante el contador y lanza combate al terminarlo. El regreso a Home recupera la pista de menú. El bus Music tiene un nivel inicial de -8 dB; FX queda separado y reservado para futuros efectos. No se agregaron opciones de audio a la interfaz.

Para regenerar ambas pistas con Python 3, sin dependencias adicionales:

```sh
python3 tools/compose_music.py
```

El arreglo y el sintetizador están en ese archivo. Esta es una primera propuesta pendiente de escucha y aprobación artística del usuario.

Revisión artística: mantener 174 BPM y los mismos patrones de batería; agregar drones graves con osciladores desafinados y movimiento lento, quinta grave, tensión menor y acentos metálicos espaciados. Reducir el protagonismo del pianito y la melodía aguda para dar más peso al ambiente. La versión anterior queda como respaldo temporal fuera del repositorio. Pendiente de aprobación auditiva.
