# Gunner animation setup

The active gunners.png sheet contains cardinal directions plus down-right
walking and dashing. Its row at y=604 was previously labelled walk_up_left,
but depicts down-right. It now supplies walk_down_right and idle_down_right.
The row at y=1359 supplies dash_down_right. Left diagonals mirror these.
The empty walk_up_right entry was removed to avoid suggesting it has artwork.

Upper-diagonal body idle, walk and dash artwork is still missing. Those
directions use the matching straight-up action. To add proper upper diagonals,
create idle_up_right, walk_up_right and dash_up_right with actual back-diagonal
frames; the shared resolver mirrors them for the left side. A new dash animation
also needs a corresponding AnimationPlayer clip if attachment motion is desired.

The rifle's four source images cover all eight directions through explicit
poses in ranged/rifle_visual_profile.tres. Upward poses use layer -1; other
poses use 1. Only straight-down flips vertically. A dedicated rifle idle_down
image remains optional: if added, update the down pose's Animation and disable
Flip V in the profile (configured profiles use their explicit settings).

Open Gunner.tscn, select PenguinBase / Weapon / EquippedWeapon, expand Visual
Profile > Poses to adjust each Animation, Hand Position, Grip Offset and Layer.
Unlike the hammer, the rifle root has scale 1 and its Body has scale 0.06;
Hand Position is in weapon-local units, Grip Offset is in source-image pixels.
The penguin's scale then scales both. Right-facing placement preserves the
previous attachment position; other directions now have independent placement.

Editor Preview Enabled is off by default. Turn it on only when inspecting
Preview Direction; turn it off to edit SpriteFrames normally. Weapon profiles
do not alter the parent Weapon socket, which the dash timelines animate.
