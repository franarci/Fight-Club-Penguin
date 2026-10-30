# Equipment player colors

PenguinBase no longer tints the whole character. Body and optional equipment
sprites receive a private ShaderMaterial per penguin; weapons are not included.
The P1/P2 label and triangle retain their player color. Alpha and respawn fading
are preserved. Mass, animation and combat behavior are independent of color.

Inspector: select PenguinBase > Equipment Colors.

- Equipment Palette: expand Shader Parameters to tune the three source colors,
  Tolerance, Hue Tolerance, Shadow Strength and Highlight Strength. Source
  defaults are #303b1b, #4b5c28 and #6b7b3a. Current art has many nearby shades,
  so tolerance matching preserves continuous lighting between these shades.
- Tolerance limits RGB differences; Hue Tolerance rejects similarly dark browns
  and grays. Raise carefully: unrelated pixels using the same palette cannot
  be distinguished without a separate mask.
- Equipment Sprite Paths: defaults to Arm. Add other equipment sprites as
  paths relative to PenguinBase; Body is always included. Do not add Weapon
  if its own artwork should stay unchanged.
- Preview Equipment Color: opt-in editor preview. Choose Equipment Preview
  Color to inspect the effect without running. Toggle preview off/on after
  changing template palette parameters. Preview does not control animations.

PlayerManager.PLAYER_COLORS remains the gameplay color source. Each runtime
material is duplicated, so two players choosing the same class are independent.
For a class-specific source palette, Make Unique on Equipment Palette before
editing its shader parameters. Shared edits otherwise affect all classes.

Use consistent olive source shades across every direction and dash frame.
Keep lossless import and nearest texture filtering for crisp pixels. Existing
files already contain blended color variants; importing them losslessly cannot
remove those variants. A strict three-color palette can use a smaller tolerance.

Hunter and Explorer currently reference gunner/lr_penguin2.png, rather than their
new class artwork. Assign their updated SpriteFrames to use their intended
equipment palette; this change does not replace those scene assets.
