extends Line2D

var Gates = preload("res://scenes/Gates.tscn")

func _ready():
	visible = false
	var i = 0
	while i < len(points) - 1:
		# Spawn a gate with correct length and rotation
		var p1: Vector2 = points[i]
		var p2: Vector2 = points[i+1]

		var angle = p1.angle_to_point(p2) + PI
		var length = p1.distance_to(p2)
		var gate = Gates.instance()
		get_node("../").call_deferred("add_child", gate)
		gate.length = length
		gate.global_rotation = angle
		gate.global_position = p1


		i += 1
