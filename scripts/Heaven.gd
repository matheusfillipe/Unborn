extends Control

const s=["Come with me to the next life.",
"You cannot escape fate.",
"You will learn to enjoy your new afterlife.",
"Ggaaaaaaaaa.",
"Do not run.",
"Do not fear.",
"You will be educated in the new ways.",
"You will be brought for final judgment.",
"Come with me to your final destination.",
"All must go with me.",]

var texts = [
	"",
	"Or maybe try again..."
]

var ready = true
var textnumber = 0
var touched = false

onready var label = $Text
onready var next_label = $Label
onready var tween = $Tween
onready var timer = $UserWakeUpTimer


func _ready():
	Global.play_music_once(Global.Music.intro)
	randomize()
	texts[0] += s[randi() % len(s)]
	nextlabel()

func _input(event):
	if (event is InputEventKey and event.pressed) or event.is_action_pressed("click"):
		if ready:
			touched = true
			if textnumber == len(texts):
				get_tree().change_scene("res://scenes/Menu.tscn")
			else:
				nextlabel()

# If 'in' is true will fade, in, if false will fade out
func fadelabel(_label: Label, _in: bool = true):
	var colors = [
		Color(1, 1, 1, 1),
		Color(1, 1, 1, 0),
	]
	if _in:
		colors = [colors[1], colors[0]]

	tween.interpolate_property(
		_label,
		"modulate",
		colors[0],
		colors[1],
		0.7,
		Tween.TRANS_SINE
	)
	tween.start()

func nextlabel():
	ready = false
	if next_label.modulate.a == 1.0:
		fadelabel(next_label, false)
		touched = false
		timer.start()

	fadelabel(label, false)
	yield(tween, "tween_all_completed")
	label.text = texts[textnumber]
	fadelabel(label)
	textnumber += 1
	ready = true

func _on_UserWakeUpTimer_timeout():
	if not touched:
		fadelabel(next_label)
