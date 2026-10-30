# Character and weapon balance

Open a character scene and select PenguinBase. Expand Combat Stats:

| Inspector field | Effect | Neutral |
| --- | --- | --- |
| Mass | Incoming push speed divided by mass, including dash pushes | 1.0 |
| Melee Power | Equipped melee weapon damage multiplied by this | 1.0 |
| Ranged Attack Speed | Ranged cooldown divided by this | 1.0 |
| Ranged Handling | Ranged spread divided by this | 1.0 |

All characters start neutral. These fields are independent: changing Mass does
not automatically change power, movement speed, bullet damage or damage received.
For example, try Mass 1.25 / Melee Power 1.2 for a heavy character and Mass 0.8 /
Melee Power 0.85 / Ranged Attack Speed 1.15 / Ranged Handling 1.15 for a light one.
These are suggestions, not applied balance values.

Expand Starting Weapon Data to tune the weapon's base Damage, Attack Cooldown,
and type-specific properties. Melee weapons expose Knockback, Attack Range,
Hit Radius and Attack Duration. Ranged weapons expose Spread (radians),
Projectile Speed, Projectile Scene and Automatic. A weapon with zero spread
cannot become more accurate, so use attack speed for an immediate ranged bonus.

Damage per bullet remains the same for every wielder. Reloading/ammunition are
not implemented; handling currently affects only spread. Melee cooldown still
starts after the active swing window. Ranged attack speed does not change it.

Runtime calculations never edit shared weapon data. Assigning the same weapon
and data to a different penguin uses that penguin's modifiers. Equipping still
requires the matching weapon scene and data type; an inventory/swap UI is not
part of this change. If you want an Inspector edit to a shared resource to
affect only one weapon variant, use Make Unique before editing that resource.
