# Projectiles

`Projectile.tscn` is the shared Sprite2D scene. It owns `LifetimeTimer` and
`Hitbox/CollisionShape2D`. Create an inherited scene for each weapon, as with
`RifleProjectile.tscn`; change its texture, speed, damage, lifetime, mask and shape
in the Inspector. Additional behaviors can extend `projectile.gd`.

Launch with `initialize(container, global_spawn_position, direction, shooter,
speed_override, damage_override)`. The last three arguments are optional.
Direction is normalized; the container may be transformed. Weapon data overrides
speed and damage. Ranged weapon spread is expressed in radians.

The shooter and its collision descendants are ignored. A hit consumes the bullet
once, emits `hit(target, damage, shooter, direction)`, and calls
`target.receive_damage(damage, shooter, direction)` when available. Legacy
`notify_hit()` is supported. Colliders without either method still stop bullets.
HP is not implemented here.

Collision masks select physics layers, not players; ownership prevents self-hits
in PvP. The default mask targets layer 1. Penguins have body collision shapes and receive damage through the shared
health system.
An Area2D hurtbox must receive/forward damage itself.

The ray sweep prevents fast bullets crossing thin colliders between physics
frames. Area overlaps also use the editable hitbox shape. The sweep follows the
bullet center; broad projectiles need a shape sweep for their full travel volume.
Offscreen cleanup uses canvas coordinates to account for camera transforms.

Tests: `godot --headless --path . --script res://tests/projectile_smoke.gd`.
