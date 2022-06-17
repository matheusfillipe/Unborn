extends Node2D

# No o fence
var Fence = preload("res://scenes/Fence.tscn")

var fences = []
var end_points = PoolVector2Array()

export(float) var size = 500
export(float) var border = 100
export(float) var ammount = 10
export(float) var min_len = 10
export(float) var max_len = 100
export(PoolVector2Array) var starting_points

signal player_exited

func rvec(l: float) -> Vector2:
	var idx = int(rand_range(1, 7.5))
	return [
			Vector2(0, 1),
			Vector2(1, 1),
			Vector2(0, 1),
			Vector2(-1, 1),
			Vector2(-1, 0),
			Vector2(-1, -1),
			Vector2(0, -1),
			Vector2(-1, -1),
	][idx].normalized() * l


func random_points(from: Vector2) -> Array:
	randomize()
	var points = []
	points.append(from)
	for i in range(int(rand_range(size/max_len, size/min_len))):
		from = from + rvec(rand_range(min_len, max_len))
		points.append(from)
	return points

func add_fence(points: Array):
	var fence = Fence.instance()
	var relative_points = []
	for gpt in points:
		relative_points.append(gpt - global_position)
	fence.points = relative_points
	# fence.global_position = global_position
	add_child(fence)
	fences.append(fence)

func _ready():
	# Make everything in global position then convert later
	$Area2D/CollisionShape2D.shape.extents.x = size - border
	$Area2D/CollisionShape2D.shape.extents.y = size - border

	var lines = []

	# Always separate y == 0 heaven from hell
	if global_position.y - size / 2  < 0:
		lines.append(
			[
				Vector2(global_position.x - size, 0),
				Vector2(global_position.x + size, 0),
			])

	# Generate random fences from starting points
	for pt in starting_points:
		lines.append(random_points(pt))

	# generate more until you have ammount
	if len(starting_points) < ammount:
		for _i in range(ammount - len(starting_points)):
			randomize()
			var pt = Vector2(
				rand_range(global_position.x - size / 2, global_position.x + size / 2),
				rand_range(global_position.y - size / 2, global_position.y + size / 2))
			lines.append(random_points(pt))

	for points in lines:
		add_fence(points)



func _on_Area2D_body_exited(body:Node):
	if body.is_in_group("player"):
		emit_signal("player_exited")
