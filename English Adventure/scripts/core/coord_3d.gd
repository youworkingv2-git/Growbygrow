class_name Coord3D
extends RefCounted
## Converts between legacy 2D logical coordinates (1280x720 JSON data)
## and 3D world-space meters (1 meter = 32 px, centered around origin).

const PIXELS_PER_METER := 32.0
const ORIGIN_2D := Vector2(640.0, 360.0)
const WORLD_HALF_X: float = 19.2
const WORLD_HALF_Z: float = 10.6


static func to_3d(pos_2d: Vector2, height_y: float = 0.0) -> Vector3:
	return Vector3(
		(pos_2d.x - ORIGIN_2D.x) / PIXELS_PER_METER,
		height_y,
		(pos_2d.y - ORIGIN_2D.y) / PIXELS_PER_METER
	)


static func dict_to_3d(pos_dict: Dictionary, fallback_2d: Vector2 = Vector2(640.0, 500.0), height_y: float = 0.0) -> Vector3:
	var px := float(pos_dict.get("x", fallback_2d.x))
	var py := float(pos_dict.get("y", fallback_2d.y))
	return to_3d(Vector2(px, py), height_y)


static func to_2d(pos_3d: Vector3) -> Vector2:
	return Vector2(
		pos_3d.x * PIXELS_PER_METER + ORIGIN_2D.x,
		pos_3d.z * PIXELS_PER_METER + ORIGIN_2D.y
	)
