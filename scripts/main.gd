extends Node2D

onready var orb = $orb

func _ready():
	orb.color = orb.COLOR.BLUE
	orb.size = 3
	orb.brightness = 1
