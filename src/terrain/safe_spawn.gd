extends RefCounted
class_name SafeSpawn


static func world_polygon(boundary: CollisionPolygon2D) -> PackedVector2Array:
	return boundary.global_transform * boundary.polygon


static func can_spawn(player: Node2D, boundary: CollisionPolygon2D, position: Vector2, margin: float, clearance: float) -> bool:
	var polygon := world_polygon(boundary)
	if polygon.size() < 3:
		return false
	var feet: Node2D = player.get_node("FeetMarker")
	var point := position + feet.global_position - player.global_position
	if not Geometry2D.is_point_in_polygon(point, polygon):
		return false
	for index in range(polygon.size()):
		var nearest := Geometry2D.get_closest_point_to_segment(point, polygon[index], polygon[(index + 1) % polygon.size()])
		if point.distance_to(nearest) < margin:
			return false
	for other in player.get_tree().get_nodes_in_group("active_penguins"):
		if other == player or other.get("is_dead") or other.get("is_eliminated"):
			continue
		var other_feet: Node2D = other.get_node("FeetMarker")
		if point.distance_to(other_feet.global_position) < clearance:
			return false
	return true


static func find_position(player: Node2D, boundary: CollisionPolygon2D, preferred: Vector2, anchors: PackedVector2Array, margin: float, clearance: float) -> Variant:
	if can_spawn(player, boundary, preferred, margin, clearance):
		return preferred
	var candidates := anchors.duplicate()
	var polygon := world_polygon(boundary)
	if polygon.size() < 3:
		return null
	var bounds := Rect2(polygon[0], Vector2.ZERO)
	for point in polygon:
		bounds = bounds.expand(point)
	var feet: Node2D = player.get_node("FeetMarker")
	var offset := feet.global_position - player.global_position
	for y in range(1, 12):
		for x in range(1, 12):
			candidates.append(bounds.position + bounds.size * Vector2(x / 12.0, y / 12.0) - offset)
	var result: Variant = null
	var best_distance := INF
	for candidate in candidates:
		if not can_spawn(player, boundary, candidate, margin, clearance):
			continue
		var distance := candidate.distance_squared_to(preferred)
		if distance < best_distance:
			best_distance = distance
			result = candidate
	return result
