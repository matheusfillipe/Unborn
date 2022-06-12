extends Node2D

func _physics_process(_delta):
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
