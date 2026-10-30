# Interchangeable weapons

Work one task at a time, preserving existing character visuals and Inspector customization.

- [x] Task 1: Standalone Hammer and Rifle scenes, with reusable frames, combat data, and poses. Character scenes instance these weapons. Empty Starting Weapon Data uses the equipped scene's Default Weapon Data.
- [x] Task 2: Shared equip/unequip API. Cancel attacks, replace the scene safely, initialize wielder/input/aim, and test Gunner + hammer and Demolisher + rifle. Handle swaps during dash, death, and cooldown.
- [x] Task 3: Character hand attachments separated from weapon grip settings. Preserve current layouts, support different body sizes, and expose per-direction positions in the Inspector.
- [x] Task 4: Demolisher AnimationPlayer timelines. Coordinate body, arm, and hand attachment without assuming a particular weapon. Restore standing poses when animations finish or are interrupted.

## Task 4: Demolisher dash timelines

All eight directions now have separate timelines in characters/demolisher_dash_poses.tres. Open Demolisher.tscn, select PenguinBase/AnimationPlayer and choose dash_right, dash_down_right, dash_down, dash_down_left, dash_left, dash_up_left, dash_up, or dash_up_right. The pre-existing empty walk_right timeline is retained.

Each timeline uses normalized time 0–1, scaled at runtime to Dash Duration. Four existing slide frames play at 0, 0.25, 0.5, and 0.75; the standing frame returns at 1. The approved right-facing layout is the baseline for all directions: Weapon:position holds (0, 7) through the slide and returns to (0, 0). Arm:position holds (-30, 20) and returns to (-30, 14). Each timeline can be adjusted independently. RESET restores editor standing values.

Left diagonal timelines mirror the corresponding right-diagonal sprites. Cardinal left also mirrors its existing right-facing art. Explicit Body:flip_h tracks make editor previews match gameplay. Upper diagonal idle frames currently fall back to idle_up because no dedicated upper diagonal idle artwork exists. The runtime selects the appropriate idle/walk animation and flip on dash exit.

No weapon sprite, grip, swing, or attack tracks were added. Attachment movement works with both hammer and rifle and keeps the current directional layer. Existing cleanup restores positions after interruptions. Headless demolisher_dash_timeline_smoke checks all eight directions, both weapons, four frames, mirroring, two dash durations, and completion/interruption.

## Task 3 hand placement

Select the character's PenguinBase, expand Weapon Attachment > Hand Positions, and edit Right, Down Right, Down, Down Left, Left, Up Left, Up, or Up Right. Coordinates are local to the Weapon socket: positive X is right, positive Y is down. These positions apply to every weapon equipped by that character.

Gunner and Demolisher have separate resources in characters/gunner_hand_positions.tres and characters/demolisher_hand_positions.tres. Their original hand locations were migrated without changing their starting weapon layouts. Duplicate the resource for a character variant with different placement.

Weapon Visual Profile > Grip Offset still identifies the handle in source sprite pixels. The old Hand Position in that profile is now only a fallback for standalone weapons or characters without a hand resource. Muzzle offsets remain weapon-specific. Character and weapon scales are handled by coordinate conversion; this does not automatically resize a swapped weapon to match a character's proportions.

To preview, select EquippedWeapon, enable Editor Preview Enabled and choose Preview Direction. Changes to the character hand resource then update the weapon placement. Disable preview again before editing SpriteFrames. Dash timelines should animate Weapon:position as an additive offset; return that offset to the standing value at the end.

Validation: hand_attachment_smoke checks preserved original layouts and both weapon grips against both characters' hands in all eight directions, including socket offsets. Swap, muzzle, dash restoration, and hammer animation checks also pass.

## Task 2 runtime API

Call `penguin.equip_weapon(weapon_scene, optional_data_override)` with Hammer.tscn or Rifle.tscn (or another WeaponBase scene). Returns false for missing/mismatched data, invalid scenes, or dead/eliminated characters; the old weapon stays equipped. Omit the data override to use the scene's Default Weapon Data. Starting Weapon Data only applies to the initial weapon.

Call `penguin.unequip_weapon()` to become unarmed. Removed weapons are disposed, not dropped as pickups. Existing bullets continue flying. A future pickup should export a PackedScene field for selecting the weapon in the Inspector and call equip_weapon deferred from collision signals.

During an AnimationPlayer dash, accepted changes wait until the timeline exits. The latest request replaces earlier pending requests. Death discards a pending change. Replacement preserves aim/device/wielder and outstanding attack cooldown (including cancelled melee recovery); unequipping cannot bypass that cooldown. Respawn resets the cooldown as before.

An empty EquippedWeapon Node2D keeps the existing dash layer tracks valid while unarmed. Character hand positioning and scale fitting are still task 3; the swap API does not infer grip placement for different characters.

Validation: weapon_swap_smoke covers both character/weapon combinations, melee cancellation, firing, cooldown carryover, unarmed dash, queued dash swap, invalid data, death and respawn. Existing muzzle, dash-layer, and vertical hammer tests also pass.

## Task 1 editing locations

- `melee/Hammer.tscn`: hammer scale, Body, pose profile, Default Weapon Data, and swing preview.
- `melee/hammer_frames.tres`: existing hammer SpriteFrames extracted from Demolisher, including attack_up and attack_down.
- `melee/hammer_data.tres`: exact existing Demolisher attack settings, including downward swing offset.
- `ranged/Rifle.tscn`: concrete rifle inheriting RangedWeapon, with Default Weapon Data.
- `ranged/gunner_rifle_data.tres`: exact existing Gunner combat settings. The older rifle_data.tres preset remains separate because it has different speed/automatic-fire settings.
- Each character's Starting Weapon Data remains an optional override. Changing its type alone does not replace the weapon scene; runtime replacement is task 2.

These resources are shared: editing Hammer's frames updates every user of that hammer. Make a separate weapon scene/resource for a different weapon variant. Character-specific attachment offsets remain in the character scenes until task 3.

Validation: standalone_weapons_smoke, vertical_weapon_animation_smoke, rifle_muzzle_smoke, and dash_layer_restore_smoke pass headlessly. Interactive visual review remains useful for the authored artwork.
