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


func update_paralax():
	"""Change paralax on zooming"""
	for layer in paralax_layers:
		layer[0].motion_scale.x = layer[1].x / zoom.x
		layer[0].motion_scale.y = layer[1].y / zoom.y

	# HACK This is so the paralax doesn't disappear when detached
	global_position += Vector2(0, -10)

func _unhandled_input(event):
	if not use_mouse:
		return

	if event is InputEventMouseButton:
		if event.is_pressed():
			# zoom in
			if event.button_index == BUTTON_WHEEL_UP:
				# global_position = get_global_mouse_position()
				zoom /= scroll_wheel_zoom_multiplier
				update_paralax()
			# zoom out
			if event.button_index == BUTTON_WHEEL_DOWN:
				# global_position = get_global_mouse_position()
				zoom *= scroll_wheel_zoom_multiplier
				update_paralax()
