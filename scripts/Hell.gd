extends Control

const s=[
		"You shoveled eyeballs for 50 billion years and were later reborn as a swan named Wayne. Wayne married, had two children and was hit by a truck. Well, I guess I'll see you around.",
		"You shoveled poo for 5 billion years and were later reborn as a swan named Bruce. Bruce married, had a child and was hit by a flying hotdog. He died on the way to the hospital. The hotdog actually was not damaged at all. I think someone ate it pretty soon after all of this happened.",
		"You were stabbed by knives for 5 billion years and were later reborn as a dog named Dennis. Dennis married, had seven children and was hit by a potato truck. This was a truck operated by RNS Trading Company out of Atlanta. They took the truck out for repairs for a couple days and then they were back in business.",
		"You were kept in a cage for 50 billion years and were later reborn as a bee named Chorfeeth. Chorfeeth married, had no children and was hit by a tamale truck. That tamale place went out of business a little while later. That place had some of the best tamales you've probably ever had in your life.",
		"You were eaten by lions for 10 billion years and were later reborn as an octopus named Bruce. Bruce married, had eight children and was eaten by radioactive bean beetles.",
		"You were eaten by ants for 500 billion years and were later reborn as a dog named Dennis. Dennis married, had a child and was hit by a low flying hamburger without onions.",
		"You shoveled eyeballs for 5 million years and were later reborn as a dog named Dennis. Dennis married, had a child and was hit by a truck hauling 50 thousand packages of anchovies. He died after a couple minutes.",
		"You were eaten by ants for 50 thousand years and were later reborn as a bee named Terence. Terence married, had three children and was hit by a car, one of those newer model cars that probably you would have to be rich to be able to afford.",
		"You shoveled lungs for 5 million years and were later reborn as a swan named Steve. Steve married, had a child and was hit by a truck.",
		"You shoveled eyeballs for 5 hundred years and were later reborn as a beetle named Bruce. Bruce married, had three children and was hit by a truck.",
		"You shoveled eyeballs for 5 billion years and were later reborn as a dog named Dennis. Dennis married, had a child and was hit by a truck.",
		"You shoveled eyeballs for 5 quadrillion years and were later reborn as a swan named Connor. Connor married, had five children and was hit by a truck.",
		"You shoveled eyeballs for 50 thousand years and were later reborn as a swan named Bruce. Bruce married, had six children and was hit by a truck.",
		"You worshiped the lower god known as Borga Normetar for 5 billion years and were later reborn as a dog named Kuei. Kuei married, had a child and was hit by a flying shoe. She died after about three hours when she was on the way to the hospital.",
		"You shoveled bees for 50 billion years and were later reborn as a bee named Sazoli. Sazoli married, had a child and was hit by a truck.",
		"You shoveled hair for 5 million years and were later reborn as a swan named Elwin. Elwin married, had a child and was hit by a truck.",
		"You shoveled stomachs for 50 billion years and were later reborn as a swan named Bruce. Bruce married, had a child and was hit by a truck.",
		"You shoveled eyes for 5 billion years and were later reborn as a dog named Nachu. Nachu married, had two children and was hit by a truck.",
		"You shoveled organs for 5 billion years and were later reborn as a swan named Vobion. Vobion married, had a child and was hit by a truck.",
		"You shoveled poo for 50 billion years and were later reborn as a swan named Bruce. Bruce married, had two children and was hit by a truck.",
]

var texts = [
	"",
	"Maybe try again..."
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
				get_tree().change_scene("res://scenes/main.tscn")
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
