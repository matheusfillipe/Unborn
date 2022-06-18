extends Control

const deaths = [
	"You were run over by a whoopie-cushion truck",
	"You jumped in front of a train",
	"Your airplane fell and you were the only one who died",
	"You weren't ever really fond of vaccinations",
	"You were mauled to death by a mountain lion",
	"Your heart just kind of stopped in your sleep",
	"You died from the Exotic Bear Flu",
	"You died jumping off Mount Everest",
	"You danced too hard and passed away",
	"You choked to death on caviar",
	"You let your beard grow too much and when a small fire broke out you burned to death",
	"You were killed by a Knife-Wielding Bird",
	"You died during a game of chess... what....",
	"You were slain in a battle due to being blind",
	"Wow! You died from Pneumonia after surviving the sinkings of the RMS Titanic, the RMS Alcantara, the HMHS Britannic and the SS Donegal.",
	"You were eaten by the tiger you were taunting",
	"You died from a violent case of diarrhea",
	"You died because you tried to swim under Niagara Falls",
	"You had a stroke after too much effort coding a game for a jam"
	]

var texts = [
	"Hello there.\n Let's see what we got here...",
	"I am sorry to say but...\n",
	"Well, I am sorry for you.\nYou will now receive your final judgment.",
	"Reincarnation? What a pitiful idea! You see, that is no longer a possibility...",
	"Wait! Where are you going? You think you can escape from the wrath of angels and demons?",
	"You shall be taken to your destiny by force!",
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
	texts[1] += deaths[randi() % len(deaths)]
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
