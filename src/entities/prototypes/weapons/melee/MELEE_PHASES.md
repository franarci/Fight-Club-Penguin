# Hammer implementation

1. Completed: directional damage, one hit per target per swing, owner exclusion,
   active duration, cooldown, scale-independent hit radius and death cancellation.
2. Implemented: configurable knockback on accepted hits. Two-player feel and
   balance testing remains manual; existing reach and timings are preserved.
3. Implemented: grip-anchored motion using the existing eight directional poses,
   with a shared physics timeline for wind-up, impact and recovery. Custom
   frame-by-frame swing artwork is still a future art improvement.

Phase 1 uses the existing attack input. The attack direction locks at the start
of the swing. The hit circle follows the wielder's position during the active
window, centered Attack Range world pixels ahead. Hit Radius is also in world
pixels and ignores visual scaling. Bodies on the Hitbox collision mask with
receive_damage() can be hit, including bodies already overlapping at startup.
Health, life loss and respawn protection remain handled by receive_damage().
Cooldown starts after recovery; holding attack does not auto-repeat. Total time
between attacks is Windup Duration + Attack Duration + Recovery Duration +
Attack Cooldown (defaults: 0.1 + 0.25 + 0.15 + 0.5 = 1 second).

Tune Demolisher > PenguinBase > Starting Weapon Data: Damage, Attack Duration,
Attack Cooldown, Attack Range and Hit Radius. Knockback controls the initial
push speed in world pixels/second (default 150); zero disables it. Push Friction
on the receiving penguin slows the push down. Protected targets and lethal hits
do not receive a push. Each target is pushed at most once per swing.
Under Starting Weapon Data > Swing Animation, tune Windup Duration, Recovery
Duration, Windup Angle and Impact Angle (degrees). Attack Duration remains the
damaging portion of the swing. Angles are relative to the resting artwork and
mirror for left-facing directions. Grip Offset in each visual pose is the pivot.

For an editor preview, select Weapon / EquippedWeapon, enable Editor Preview
Enabled (off by default), set Preview Direction,
then scrub Swing Preview > Preview Swing Progress from 0 to 1. The Demolisher's
Preview Weapon Data references its Starting Weapon Data, so editing either
updates the same settings. For another melee weapon, assign its data there.
Set progress back to 0 for the resting preview. The runtime ignores this slider.
Disable Editor Preview Enabled before editing SpriteFrames or Body properties.
Straight-up and straight-down attacks prefer nonempty SpriteFrames animations
named attack_up and attack_down. These play without procedural rotation or flips.
Frame 0 is held during Windup Duration; frames 1 onward span Attack Duration,
respecting their relative frame durations. The final frame is held through
recovery, then the idle pose returns. The combat timeline controls playback,
so SpriteFrames FPS and Loop do not change attack timing. Missing/empty attack
animations retain the procedural swing. The other six directions are unchanged.

Strike Fraction controls how quickly the visual strike reaches its impact pose
within the damage window; it also compresses authored attack frames after the
wind-up. The impact pose is held for the remaining window. Recoil Angle adds a
small reverse movement during procedural recovery; authored vertical attacks
are never rotated. The hammer uses a 0.07-second wind-up, 0.18-second recovery,
-45/85-degree angles, Strike Fraction 0.4 and Recoil Angle 8 for a sharper swing.
Attack Duration and cooldown remain unchanged, and total attack cadence stays
the same; the damage window now starts 0.03 seconds earlier.

Down Attack Offset moves only the authored attack_down visual during the strike,
holds it at impact, and returns it during recovery. Positive Y moves downward.
The hammer starts at (0, 80) weapon-local units: its 0.1 scale makes this an
8-pixel shift in penguin-local space. Adjust it under Starting Weapon Data >
Swing Animation, and preview using Preview Swing Progress while facing down.
It does not change the idle hand position, the up attack, or hitbox reach.
The parent's Weapon socket remains available to the penguin's dash timeline.

Try targets in front, behind, and just outside reach, then repeat in all eight
directions. Two opponents within the circle should each receive one hit.
For phase 2, try values of 150, 250 and 350 for Knockback, checking recovery
time and whether a hit near an arena edge causes the existing fall/life loss.
Keep damage/reach/timing fixed while comparing strengths; choose those after
the push feels right. Damage occurs only in the middle stage, never during
wind-up or recovery. The attack locks its direction until recovery ends and
then follows the latest aim. Death cancels the swing and restores its rest pose.

### Down attack per-frame placement

Hammer data now uses Down Attack Frame Positions > Down Attack Frame Offsets.
Each Array[Vector2] entry corresponds to the same zero-based attack_down SpriteFrames index.
Offsets are relative to the resting Body position, in weapon-local units (Hammer scale 0.1 makes Y=290 approximately 29 penguin-local pixels).
The initial entries are (0,0), (0,145), (0,290). Tune the middle entry to the artwork.
The offset does not interpolate: it changes with the displayed frame and remains fixed through recovery.
At completion/cancellation, idle artwork and resting position restore together.
With a nonempty array, legacy Down Attack Offset is ignored for this animation. Other weapons with an empty array retain their old behavior.
If frames are added, add matching entries; missing entries use the final supplied offset. Extra entries are unused.

In Demolisher, select EquippedWeapon, enable Editor Preview Enabled, choose Preview Direction down,
and scrub Preview Swing Progress. Expand Preview Weapon Data (the same shared hammer_data.tres used at runtime),
then Down Attack Frame Positions to edit offsets. Disable preview after tuning and save the resource.
This does not change damage windows or add recovery artwork. Returning to idle remains a direct sprite switch.
