extends Control

# TODO help me come up with more lame reasons of death
const deaths = [
	"You were run over by a car",
	"You jumped in front of a train",
	"Your airplane fell and you were the only one who died",
	]

onready var death_label = $DeathStory


func _ready():
	randomize()
	death_label.text = deaths[randi() % len(deaths)]

func _input(event):
	if (event is InputEventKey and event.pressed) or event.is_action_pressed("click"):
		get_tree().change_scene("res://scenes/main.tscn")
