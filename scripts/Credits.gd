extends Control


func _ready():
	var time =  Global.get_game_time()
	var hours = time / 3600
	var minutes = (time - hours * 3600) / 60
	var seconds = time - hours * 3600 - minutes * 60

	# If you took more than 99 hours screw you
	$Label2.text = "Game time: %02d:%02d:%02d" % [hours, minutes, seconds]

func _on_Timer_timeout():
	return get_tree().change_scene("res://scenes/Menu.tscn")

func _input(event):
	if (event is InputEventKey and event.pressed) or event.is_action_pressed("click"):
		_on_Timer_timeout()
