extends Control

var options = preload("res://scenes/Options.tscn")

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _on_Continue_pressed():
	Global.play(Global.SFX.pop)
	queue_free()

func _on_Menu_pressed():
	Global.play(Global.SFX.pop)
	return get_tree().change_scene("res://scenes/Menu.tscn")

func _on_Checkpoint_pressed():
	Global.play(Global.SFX.pop)
	return Global.get_tree().change_scene("res://scenes/main.tscn")

func _on_Options_pressed():
	Global.play(Global.SFX.pop)
	var opt = options.instance()
	opt.just_die = true
	add_child(opt)

func _exit_tree():
	Engine.time_scale = 1
	get_tree().paused = false
