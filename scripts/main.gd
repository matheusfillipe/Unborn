extends Node2D

onready var player = $Player
onready var overlay = $FadeInHack
onready var tween = $Tween

func _ready():

	# Pause and create transition effect on the beginning
	overlay.visible = true
	yield(get_tree().create_timer(1, false), "timeout")
	overlay.visible = false


# Nice metallica song btw
func fade_to_black(callback: String):
	overlay.modulate = Color(1, 1, 1, 0)
	overlay.visible = true
	tween.interpolate_property(overlay, "modulate",
		overlay.modulate,
		Color(1, 1, 1, 1),
		2,
		tween.TRANS_LINEAR,
		tween.EASE_IN_OUT
	)
	tween.connect("tween_all_completed", self, callback)
	tween.start()

func restart():
	Global.sdisconnect(tween, "tween_all_completed", self, "restart")
	get_tree().reload_current_scene()

func _process(_delta):
	if Input.is_action_just_pressed("reset"):
		fade_to_black("restart")

	if Input.is_action_just_pressed("pause"):
		get_tree().paused = not get_tree().paused
		# TODO show paused text
