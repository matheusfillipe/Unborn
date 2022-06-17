extends Camera2D

export(float) var speed = 5000

export var scroll_wheel_zoom_multiplier = 1.08
export var drag_multiplier = 0.05

var drags = PoolVector2Array()
var attached = true


func _unhandled_input(event):
	if event is InputEventScreenDrag:
		var input_vector = Vector2(event.relative[0], event.relative[1])
		drags.append(-input_vector * drag_multiplier)
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
