extends Camera2D

export (NodePath) var target_path
export var speed = 5
var target

func _ready():
	if target_path:
		target = get_node(target_path)

func _physics_process(delta):
	position = lerp(position, target.position, speed * delta)
