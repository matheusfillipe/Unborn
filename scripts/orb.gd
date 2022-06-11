extends KinematicBody2D




class OrbColor:
	var shader1: Color
	var shader2: Color
	var shader3: Color
	func _init(c1, c2, c3):
		self.shader1 = Color(c1[0], c1[1], c1[2], 1)
		self.shader2 = Color(c2[0], c2[1], c2[2], 1)
		self.shader3 = Color(c3[0], c3[1], c3[2], 1)

enum COLOR {
	WHITE
	BLACK
	BLUE
	GREEN
	YELLOW
	ORANGE
	RED
	}

# TODO improve those colors
var colormap = {
	COLOR.WHITE: OrbColor.new([1,1,1], [1,1,1], [1, 1, 1]),
	COLOR.BLACK: OrbColor.new([0,0,0], [0,0,0], [0, 0, 0]),
	COLOR.BLUE: OrbColor.new([0,0.56,1], [0.21,0.14,0.14], [0, 0, 0]),
	COLOR.GREEN: OrbColor.new([0,1,0.56], [0.14,0.14,0.21], [0, 0, 0]),
	COLOR.YELLOW: OrbColor.new([1,0.56,0], [0.21,0.21,0.14], [0, 0, 0]),
	COLOR.ORANGE: OrbColor.new([1,1,0], [0.21,0.14,0.14], [0, 0, 0]),
	COLOR.RED: OrbColor.new([1,0.56,1], [1,0.14,0.14], [0, 0, 0]),
	}

export(COLOR) var start_color = COLOR.BLUE
export(int) var start_size = 1
export(float, 0, 100) var start_brightness = 1
export(float, 1, 100) var collision_brightness_multiplier = 1.5

var size = 1 setget set_size
var color = "blue" setget set_color
var brightness = 1 setget set_brightness
var is_colliding = false

onready var circle = $circle

func _ready():
	set_color(start_color)
	set_size(start_size)
	set_brightness(start_brightness)

func set_size(_size: int):
	scale = Vector2(_size, _size)

func set_color(colorname: int):
	assert(colorname in colormap, "Invalid color: " + str(colorname))
	color = colorname
	var c: OrbColor = colormap[color]
	circle.material.set_shader_param("main_color", c.shader1)
	circle.material.set_shader_param("second_color", c.shader2)
	circle.material.set_shader_param("third_color", c.shader2)

func set_brightness(b: float):
	modulate = Color(b, b, b, 1)
	brightness = b


func _on_Area2D_body_exited(body:Node):
	is_colliding = false
	set_brightness(brightness / collision_brightness_multiplier)


func _on_Area2D_body_entered(body:Node):
	is_colliding = true
	set_brightness(brightness * collision_brightness_multiplier)
