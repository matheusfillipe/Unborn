extends Control

const s=[
		"You worshiped the lower echelon god known as Benent Golmia for 3 billion years and were later reborn as a cat named Bato. Bato was unmarried but had three children. He was attacked by a bean beetle and died instantly.",
		"You worshiped the upper echelon god known as Storga Nodmeetia for 5 million years and were later reborn as a bird named Bao. Bao was unmarried but had seven children. He was attacked by a bean beetle and died instantly.",
		"You worshiped the upper echelon god known as Stwega Nowtin for 5 million years and were later reborn as a fish named Arowe. Arowe was unmarried but had five children. He was attacked by a bean beetle and died instantly.",
		"You worshiped the upper echelon god known as Ytre La for 10 million years and were later reborn as a cat named Bato. Bato was unmarried but had three children. He was attacked by a bean beetle and died instantly.",
		"You worshiped the upper echelon god known as Grafa Noteq for 7 trillion years and were later reborn as a whale named Kalew. Kalew was unmarried but had four children. He was attacked by a bean beetle and died instantly.",
		"You worshiped the upper echelon god known as Sa Nojeti for 20 million years and were later reborn as a cat named Bato. Bato was unmarried but had three children. He was attacked by a bean beetle and died instantly.",
		"You worshiped the upper echelon god known as Ra Nogega for 50 trillion years and were later reborn as a cat named Bato. Bato was unmarried but had three children. He was attacked by a bean beetle and died instantly.",
		"You worshiped the upper echelon god known as Ia Nteua for 20 million years and were later reborn as a cat named Bato. Bato was unmarried but had three children. He was attacked by a bean beetle and died instantly.",
		"You worshiped the lower god known as Pirga Wermwe for 5 billion years and were later reborn as a bee named Chonzo. Chonzo married, had a child and was hit by a flying plate. At his funeral, people said he was a nice guy.",
		"You worshiped the upper middling god known as Treageri for 3 thousand years and were later reborn as a bee named Aruga. Aruga married, had a child and was hit by an onion truck. People said she accomplished a lot in her short life.",
		"You worshiped the lower god known as Keales Lerued for seven trillion years and were later reborn as a dog named Dennis. Dennis married, had five children and was hit by a truck.",
		"You worshiped the higher god known as Crenler Lopenxo for three hundred years and were later reborn as a bee named Chafri. Chafri married, had two children and was hit by a bean truck. The driver of the truck was Klere Dindo, who lives in a small house in Missouri when he's not out trucking.",
		"You worshiped the lower god known as Borga Normetar for 2 thousand years and were later reborn as a ferret named Horatio. Horatio married, had a child and was hit by a truck.",
		"You worshiped the lower god known as Borga Normetar for 5 billion years and were later reborn as a bee named Paloa. Paloa married, had a child and was hit by a truck. She died pretty quickly and then she kind of let out a little sigh as she was falling over.",
	]

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
