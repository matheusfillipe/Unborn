extends Control

const deaths = [
	"You were run over by a whoopie-cushion truck",
	"You jumped in front of a train",
	"Your airplane fell and you were the only one who died",
	"You weren't ever really fond of vaccinations",
	"You were mauled to death by a mountain lion",
	"Your heart just kinda stopped in your sleep",
	"You died of the Exotic Bear Flu",
	"You died jumping off Mount Everest",
	"You danced too hard and passed away"
	]
var texts = [
	"Well, hello there. Let's see here...",
	"",
	"Well, cool death.",
	"So, here's the thing, you now gotta wander about with some other souls if you want to get another chance at this wild ride called life.",
	"Press any key to start!"
]

var ready = true
var textnumber = 0
onready var label = $Text
onready var tween = $Text/Tween


func _ready():
	Global.play_music_once(Global.Music.intro)
	randomize()
	texts[1] = deaths[randi() % len(deaths)]
	initiallabel()

func _input(event):
	if (event is InputEventKey and event.pressed) or event.is_action_pressed("click"):
		if ready == true:
			if textnumber == 4:
				get_tree().change_scene("res://scenes/main.tscn")
			else:
				nextlabel()
func nextlabel():
	ready = false
	textnumber += 1
	tween.interpolate_property(
		label,
		"modulate",
		Color(1, 1, 1, 1),
		Color(1, 1, 1, 0),
		0.7,
		Tween.TRANS_SINE
	)
	tween.start()
	yield(tween, "tween_all_completed")
	label.text = texts[textnumber]
	tween.interpolate_property(
		label,
		"modulate",
		Color(1, 1, 1, 0),
		Color(1, 1, 1, 1),
		0.7,
		Tween.TRANS_SINE
	)
	tween.start()
	ready = true


func initiallabel():
	ready = false
	tween.interpolate_property(
		label,
		"modulate",
		Color(1, 1, 1, 1),
		Color(1, 1, 1, 0),
		0.7,
		Tween.TRANS_SINE
	)
	tween.start()
	yield(tween, "tween_all_completed")
	label.text = texts[0]
	tween.interpolate_property(
		label,
		"modulate",
		Color(1, 1, 1, 0),
		Color(1, 1, 1, 1),
		0.7,
		Tween.TRANS_SINE
	)
	tween.start()
	ready = true
