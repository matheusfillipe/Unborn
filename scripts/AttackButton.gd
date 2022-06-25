extends Control

var player


func _on_Button_pressed():
	player.attack()
	queue_free()
