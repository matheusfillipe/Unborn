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
	"Well, hello there.",
	"Seems as this is where your journey ends...",
	"Now let's see here...",
	"",
	"Well, cool death.",
	"So, here's the thing",
	"You need to reincarnate, otherwise you'll just be kinda stuck in the orb form of your sṕpirit.",
	"You are now tasked with the objective of floating around with other spirits like you, in a task for enlightenment, or something..."
]

var ready = true
var textnumber = 0
onready var label = $Text
onready var tween = $Text/Tween


func _ready():
	randomize()
	texts[3] = deaths[randi() % len(deaths)]
	initiallabel()

func _input(event):
	if (event is InputEventKey and event.pressed) or event.is_action_pressed("click"):
		if ready == true:
			nextlabel()
func nextlabel():
	ready = false
	textnumber += 1
	tween.interpolate_property(label, "modulate:a", 1, 0, 0.7, Tween.TRANS_SINE)
	tween.start()
	yield(tween, "tween_all_completed")
	label.text = texts[textnumber]
	tween.interpolate_property(label, "modulate:a", 0, 1, 0.7, Tween.TRANS_SINE)
	tween.start()
	ready = true


func initiallabel():
	ready = false
	tween.interpolate_property(label, "modulate:a", 1, 0, 0.7, Tween.TRANS_SINE)
	tween.start()
	yield(tween, "tween_all_completed")
	label.text = texts[0]
	tween.interpolate_property(label, "modulate:a", 0, 1, 0.7, Tween.TRANS_SINE)
	tween.start()
	ready = true
