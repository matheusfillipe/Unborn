extends Area2D

var player = null

func can_see_player():
	return player != null

func _on_PlayerDetect_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_PlayerDetect_body_exited(body):
	if body.is_in_group("player"):
		player = null
