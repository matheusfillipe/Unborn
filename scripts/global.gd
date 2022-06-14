extends Node

var Bubble = preload("res://scenes/TextBubble.tscn")

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS


func _input(event):
	if event.is_action_pressed("pause"):
		var bubble = Bubble.instance()
		get_tree().get_root().add_child(bubble)
		bubble.textprocess("PAUSED", 10)
		get_tree().paused = not get_tree().paused

		# Pause shaders
		if get_tree().paused:
			Engine.time_scale = 0
		else:
			Engine.time_scale = 1

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
