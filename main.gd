extends Node2D
onready var orb = $orb
func _ready():
	orb.resize(Vector2(8,8))
	orb.recolor(Color(0,255,0,255))
