extends StaticBody2D

# This is the actual length you want it to tile into
export(float, 0, 10000) var length = 20.5

# This is the texture length in godot units. Take care not to set wrong
export(float) var texture_length = 20.5

onready var shape = $CollisionShape2D
onready var texture = $TextureRect
onready var initial_texture_width = $TextureRect.margin_right

func _ready():
	length = length / 2
	shape.shape.extents.x = length
	shape.position.x = length
	texture.margin_right = length / texture_length * initial_texture_width
