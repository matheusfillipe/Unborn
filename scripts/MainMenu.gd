extends Control

# RESET game status
func _ready():
	Global.checkpoint = null
	Global.spirit_counter = {}
	Global.current_music = null

func _on_Options_pressed():
	Global.play(Global.SFX.pop)
	return get_tree().change_scene("res://scenes/Options.tscn")

func _on_Play_pressed():
	Global.play(Global.SFX.pop)
	return get_tree().change_scene("res://scenes/Intro.tscn")
