extends Area2D

var player = null
var wall_list = []

func can_see_player():
	return player != null

func _on_PlayerDetect_body_entered(body):
	if body.is_in_group("player"):
		player = body
	elif body.is_in_group("wall"):
		wall_list.append(body)

func _on_PlayerDetect_body_exited(body):
	if body.is_in_group("player"):
		player = null
	elif body.is_in_group("wall"):
		wall_list.erase(body)
