extends SceneTree
func _initialize():
 call_deferred("check")
func check():
 var scene = load("uid://bplqlfsdkfml5").instantiate()
 var p = scene.get_child(0)
 p.setup(0, -1)
 root.add_child(scene)
 var clip = p.animation_player.get_animation("dash_up")
 print("Runtime library: ", p.animation_player.get_animation_library("").resource_path)
 var track = clip.find_track(NodePath("Weapon:position"), Animation.TYPE_VALUE)
 print("Saved key: ", clip.track_get_key_value(track, 0))
 await process_frame
 for x in [float(clip.track_get_key_value(track, 0).x), -130.0, 130.0]:
  p.update_facing(Vector2.UP)
  p.dash_direction = Vector2.UP
  var rest = p.current_weapon.body.global_position - p.global_position
  clip.track_set_key_value(track, 0, Vector2(x, 7))
  p.movement_state_machine.change_state(&"Dash")
  for i in range(5):
   await physics_frame
   await process_frame
   var delta = p.current_weapon.body.global_position - p.global_position - rest
   if p.dash_pose_active:
    assert(delta.is_equal_approx(Vector2(x, 7)), str(delta))
   else:
    assert(delta.is_equal_approx(Vector2.ZERO), str(delta))
  print("Live physics dash X: ", x, " confirmed")
  while p.dash_pose_active:
   await physics_frame
  assert((p.current_weapon.body.global_position-p.global_position).is_equal_approx(rest))
 scene.free()
 quit()



