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
	RED
	}

var colormap = {
	COLOR.WHITE: OrbColor.new([1,1,1], [1,1,1], [1, 1, 1]),
	COLOR.BLACK: OrbColor.new([0,0,0], [0,0,0], [0, 0, 0]),
	COLOR.BLUE: OrbColor.new([0,0.2,1], [1,1,1], [0, 0, 0]),
	COLOR.GREEN: OrbColor.new([0,1,0], [1,1,1], [0, 0, 0]),
	COLOR.YELLOW: OrbColor.new([1,1,0.1], [1,1,1], [0, 0, 0]),
	COLOR.RED: OrbColor.new([1,0,0], [1,1,1], [0, 0, 0]),
	}

export(COLOR) var start_color = COLOR.BLUE
export(int) var start_size = 1
export(float, 0, 100) var start_brightness = 5
export(float, 1, 100) var collision_brightness_multiplier = 2.0

var size:float = 1.0 setget set_size
var color = COLOR.GREEN setget set_color
var brightness: float = 1.0 setget set_brightness
var is_colliding = false

# Children Nodes
onready var circle = $circle
onready var shape = $CollisionShape2D
onready var areashape = $Area2D/CollisionShape2D
onready var btimer = $BrightTimer

onready var start_circle_scale: float = $circle.scale.x
onready var start_shape_size: float = $CollisionShape2D.shape.radius
onready var start_areashape_size: float = $Area2D/CollisionShape2D.shape.radius

export var tutorial_message: String = ""
export var tutorial_message_time: int = 0

signal size_changed


func _ready():
	set_color(start_color)
	set_size(start_size * scale.x)
	set_brightness(start_brightness)

	# This is so children classes can overwrite the ready function doing stuff before it
	_on_ready()

func _on_ready():
	pass

func set_size(_size: float):
	shape.shape.radius = _size * start_shape_size
	areashape.shape.radius = _size * start_areashape_size + 3
	circle.scale = Vector2.ONE * _size * start_circle_scale
	size = _size
	emit_signal("size_changed", _size)

func _on_color_change():
	pass

func set_color(colorname: int):
	assert(colorname in colormap, "Invalid color: " + str(colorname) + ". For: " + self.name)
	color = colorname
	var c: OrbColor = colormap[color]
	circle.material.set_shader_param("main_color", c.shader1)
	circle.material.set_shader_param("second_color", c.shader2)
	circle.material.set_shader_param("third_color", c.shader3)
	_on_color_change()

func _set_brightness(b: float):
	var mainc: Color = circle.material.get_shader_param("main_color")
	var mainv = Vector3(mainc.r, mainc.g, mainc.b).normalized()
	circle.modulate = Color(b * mainv.x, b * mainv.y, b * mainv.z, 1)

func set_brightness(b: float):
	_set_brightness(b)
	brightness = b

func get_size():
	return shape.shape.radius


func _on_BrightTimer_timeout():
	if is_colliding:
		return
	set_brightness(brightness)

func _on_Area2D_body_exited(body:Node):
	if body == self:
		return
	is_colliding = false
	btimer.start()

func _on_collide(body):
	if body.is_in_group("player") and tutorial_message != "":
		Global.popup(tutorial_message, tutorial_message_time)

func _on_Area2D_body_entered(body:Node):
	if body == self or is_colliding:
		return
	is_colliding = true
	btimer.stop()
	var b = brightness * collision_brightness_multiplier
	_set_brightness(b)
	_on_collide(body)
