tool
extends Line2D

# TODO also export this when there are multiple types of walls
var Gates = preload("res://scenes/Gates.tscn")

export(bool) var breakable = false setget set_break
export(bool) var invert = false
export(bool) var enabled = true setget set_enable

onready var initial_color = default_color
onready var initial_width = width

var parts = []

signal on_ready(Node)

func _process(_delta):
	if Engine.editor_hint :
		if breakable:
			default_color = Color(1, 0.5, 0, 1)
			width = 10
		else:
			default_color = initial_color
			width = initial_width


# Spawn a gate with correct length and rotation
# i is the start index of points
# j is the end index of points
func add_gate(i: int, j: int):
	var p1: Vector2 = points[i]
	var p2: Vector2 = points[j]

	var angle = p1.angle_to_point(p2) + PI
	var length = p1.distance_to(p2)
	var gate = Gates.instance()

	get_node("../").call_deferred("add_child", gate)
	gate.length = length
	gate.global_rotation = angle
	gate.global_position = p1 + position

	parts.append(gate)


func _ready():
	if not Engine.editor_hint :
		visible = false

		var i = 0
		if invert:
			i = len(points) - 1
			while i > 0:
				add_gate(i, i-1)
				i -= 1

		else:
			while i < len(points) - 1:
				add_gate(i, i+1)
				i += 1

	self.breakable = breakable
	self.enabled = enabled
	emit_signal("on_ready", self)


func set_break(_breakable):
	breakable = _breakable
	for gate in parts:
		gate.call_deferred("set_break", breakable)


func set_enable(_enable: bool):
	enabled = _enable

	for gate in parts:
		gate.call_deferred("set_enabled", enabled)
		gate.visible = enabled
