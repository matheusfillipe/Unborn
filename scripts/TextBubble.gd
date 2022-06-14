extends CanvasLayer

onready var tween = $Tween
onready var timer = $Timer
onready var label = $Label

var showing = false

func _ready():
	tween.interpolate_property(self, "modulate:a", 0, 1, 0.3, Tween.TRANS_SINE)
	tween.start()

func set_text(message: String):
	label.set_text(message)

func popup(message: String, timeonscreen: int):
	if showing:
		return
	show(message)
	timer.start(timeonscreen)
	yield(timer, "timeout")
	tween.interpolate_property(label, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.3, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	queue_free()

func show(message: String = ""):
	if showing:
		return
	Global.get_tree().get_root().add_child(self)
	set_text(message)
	showing = true

func hide():
	if not showing:
		return
	get_tree().get_root().remove_child(self)
	queue_free()
