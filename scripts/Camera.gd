extends Camera2D

export (NodePath) var target_path
export var speed = 5
export(bool) var use_mouse = false
export var scroll_wheel_zoom_multiplier = 1.08

var target

var drags = PoolVector2Array()
var attached = true
var paralax_layers = []


func _ready():
	zoom = Vector2.ONE
	if target_path:
		target = get_node(target_path)

	for layer in Global.get_children_with_type(self, ParallaxLayer):
		paralax_layers.append([layer, layer.motion_scale])


func _physics_process(delta):
	position = lerp(position, target.position, speed * delta)


func _unhandled_input(event):
	if not use_mouse:
		return

	if event is InputEventMouseButton:
		if event.is_pressed():
			# zoom in
			if event.button_index == BUTTON_WHEEL_UP:
				# global_position = get_global_mouse_position()
				zoom /= scroll_wheel_zoom_multiplier

			# zoom out
			if event.button_index == BUTTON_WHEEL_DOWN:
				# global_position = get_global_mouse_position()
				zoom *= scroll_wheel_zoom_multiplier
