extends CanvasLayer

const mobile_font_multiplier = 1.5


onready var tween = $Tween
onready var timer = $Timer
onready var labelc = $LabelCentered
onready var labelb = $Label


var label

var showing = false

var font_increased = false

func _ready():
	# Resize fonts on mobile
	if Global.is_mobile and not Global.mobile_font_resized:
		labelb.get_font('font').size *= mobile_font_multiplier
		labelc.get_font('font').size *= mobile_font_multiplier
		Global.mobile_font_resized = true


	label = labelb
	labelc.modulate = Color(1, 1, 1, 0)
	labelb.modulate = Color(1, 1, 1, 0)

	tween.interpolate_property(
		label,
		"modulate",
		Color(1, 1, 1, 0),
		Color(1, 1, 1, 1),
		0.3,
		Tween.TRANS_SINE
	)
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

func show(message: String = "", middle=false):
	if showing:
		return

	Global.get_node('/root').add_child(self)

	if middle:
		label = labelc

	label.modulate = Color(1, 1, 1, 1)
	set_text(message)
	showing = true

func hide():
	if not showing:
		return
	get_tree().get_root().remove_child(self)
	queue_free()
