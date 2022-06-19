extends Control

var just_die = false

onready var optbtn = $OptionButton
onready var music = $Music

func _ready():
	music.pressed = not Global.music_muted
	optbtn.selected = Global.world_complexity

func _on_Back_pressed():
	Global.play(Global.SFX.pop)
	if not just_die:
		return get_tree().change_scene("res://scenes/Menu.tscn")
	queue_free()

func _on_OptionButton_item_selected(index:int):
	Global.play(Global.SFX.tick)
	Global.world_complexity = index

func _on_Music_toggled(button_pressed:bool):
	Global.play(Global.SFX.tick)
	Global.music_muted = not button_pressed
	if not button_pressed:
		Global.stop_music_player()
	if button_pressed and Global.current_music != null:
		Global.play_music(Global.current_music)



func _on_PopupDialog_popup_hide():
	Global.play(Global.SFX.tick)
	$TextureRect.modulate = Color(1, 1, 1, 1)
	$PopupDialog.visible = false

func _on_Controls_pressed():
	Global.play(Global.SFX.tick)
	if not $PopupDialog.visible:
		$TextureRect.modulate = Color(0.3, 0.3, 0.3, 1)
		$PopupDialog.popup_centered()
