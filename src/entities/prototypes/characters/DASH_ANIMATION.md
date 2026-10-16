# Editing Gunner dash poses

Open `Gunner.tscn`, enable Editable Children on PenguinBase, and select its
AnimationPlayer. Choose dash_right, dash_left, dash_up or dash_down in the
Animation panel and scrub the timeline.

The timeline drives Body:animation, Body:frame, Weapon:position and Arm:position.
Body frames use discrete keys. Key Weapon and Arm positions alongside each body
pose. Move the Weapon socket, not EquippedWeapon: this preserves the weapon's
individual positioning and makes its firing origin follow the pose.

The initial setup lowers weapon and arm by 4 local pixels during the four dash
frames. At the final key, the body switches to its standing idle pose and both
attachments return together. Adjust intermediate keys to match the artwork.
Maintain the final standing keys so nothing rises before the body does.

Clips have a normalized length of 1 second; gameplay scales playback to the
character's Dash Duration (currently 0.5 seconds for Gunner). Changing that
setting changes dash duration and playback together. The dash state advances
the AnimationPlayer each physics tick. Do not add a second timer or resume
AnimatedSprite2D playback during the dash.

Idle and walk continue using SpriteFrames playback. Characters without a dash
AnimationPlayer clip retain their existing animation behavior. If adding clips
for another character, give that character its own library and matching tracks.
AnimationPlayer can animate SpriteFrames' animation/frame properties but does
not own the actual textures: those remain in P Spriteframes.

RESET provides a standing editor pose. Collisions, pushes and death stop dash
playback and restore the authored socket and arm positions. The old DashTimer
node is unused and its timeout connection has been removed.
