# Weapon poses

Open Demolisher.tscn and select PenguinBase / Weapon / EquippedWeapon.
Editor Preview Enabled defaults to off so SpriteFrames and Inspector editing
are not overwritten. Turn it on only to preview poses or scrub a swing; turn it
off again before editing the Body directly.
Under Directional Poses, change Preview Direction to inspect a hammer pose in
the editor. To match the penguin preview, select PenguinBase and change
P Autoplay to a corresponding available body animation. Preview Direction
only controls the weapon; runtime uses the player's aim.

For the hammer, expand Visual Profile, then Poses, then an entry to adjust:
The profile is saved separately as melee/hammer_visual_profile.tres and is
also assigned to Starting Weapon Data, which restores it during runtime setup.

- Animation: the exact SpriteFrames animation to use.
- Flip H / Flip V: explicit mirroring for this pose only.
- Hand Position: where the grip should sit, in weapon-local coordinates.
- Grip Offset: the grip point measured from the source frame's center, before
  mirroring. This compensates for different handle locations in each image.
- Layer: weapon Z relative to its parent; the hammer uses -1 behind the body
  and 1 in front, with the foreground arm at 2.

The Demolisher weapon has scale 0.1, so 10 local units move the grip by one
penguin-local unit. Its initial grip positions are starting values to tune
against the artwork. Adjust Hand Position rather than Body Position, which
is calculated from the grip anchor. Keep the parent Weapon socket available
for dash animation tracks.

Weapons without poses retain their existing visual behavior. To configure
another weapon, create resources using weapon_pose.gd and add one entry per
direction to its Directional Poses array. Keep these resources unique to the
weapon when its artwork or grip positions differ. Melee weapons preview in
the editor; other weapon subclasses must run the base editor preview to
support Preview Direction.
