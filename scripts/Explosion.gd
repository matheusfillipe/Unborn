extends "res://scripts/Effect.gd"

var bodies: Array

onready var marker = $Position2D

# Keep track of bodies in range
func _on_Area2D_body_exited(body:Node):
	bodies.erase(body)

func _on_Area2D_body_entered(body:Node):
	# TODO check for parent of explosion instead
	if body.is_in_group("hitable") and not body.is_in_group("player"):
		bodies.append(body)


func _process(_delta):
	# Loop over each body and check if it can die
	for body in bodies:
		if is_instance_valid(body):
			if body.global_position.distance_squared_to(global_position) < marker.global_position.distance_squared_to(global_position):
				bodies.erase(body)
				body.hit(body)
		else:
			bodies.erase(body)
