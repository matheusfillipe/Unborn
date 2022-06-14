extends Node

var Bubble = load("res://scenes/TextBubble.tscn")
var bubble = Bubble.instance()

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

func popup(message, time):
	if is_instance_valid(bubble):
		bubble.hide()
	bubble = Bubble.instance()
	bubble.popup(message, time)


func show_text(message, time):
	if is_instance_valid(bubble):
		bubble.hide()
	bubble = Bubble.instance()
	bubble.show_text(message, time)
	return bubble

func _input(event):
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused

		# Pause shaders
		if get_tree().paused:
			Engine.time_scale = 0
			bubble = Bubble.instance()
			bubble.show("PAUSED")
		else:
			Engine.time_scale = 1
			bubble.hide()

# Safe disconnect
func sdisconnect(node: Node, _signal: String, target: Object, method: String):
	if node.is_connected(_signal, target, method):
		node.disconnect(_signal, target, method)

func random_vec2() -> Vector2:
   var new_dir: = Vector2()
   randomize()
   new_dir.x = rand_range(-1, 1)
   randomize()
   new_dir.y = rand_range(-1, 1)
   return new_dir.normalized()

func sum(arr: Array) -> float:
	var r = 0
	for a in arr:
		r += a
	return r
