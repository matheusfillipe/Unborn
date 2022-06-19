extends Control

const lives = [
	"You were born into a wealthy family in Canada.",
	"You were born into a poor family in Botswana.",
	"You were born into a middle class family in Switzerland.",
	"You were born into a very wealthy family in Brazil.",
	"You were born into a poor family in the United States.",
	"You were born into a middle class family in Taiwan.",
	"You were born into a poor family in Japan.",
	"You were born into a middle class family in South Africa.",
	"You were born into a middle class family in Nigeria.",
	"You were born into a wealthy family in India."
	]

var texts = [
	"Odds were agains't you, and yet...",
	"You were successfull in your quest for reincarnation.",
	"I am surprised, which is rare.",
	'Well, I do have this little thing called a "future log", and it says here...',
	"",
	"Well, I hope that this was all worth it.",
	"Anyways, thanks for participating in this.",
]

var ready = true
var textnumber = 0
var touched = false

onready var label = $Text
onready var next_label = $Label
onready var tween = $Tween
onready var timer = $UserWakeUpTimer


func _ready():
	Global.play_music(Global.Music.end)
	randomize()
	texts[4] += lives[randi() % len(lives)]
	nextlabel()

func _input(event):
	if (event is InputEventKey and event.pressed) or event.is_action_pressed("click"):
		if ready:
			touched = true
			if textnumber == len(texts):
# warning-ignore:return_value_discarded
				get_tree().change_scene("res://scenes/Credits.tscn")
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
