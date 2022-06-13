extends "res://scripts/orb.gd"

export var velocity: Vector2 = Vector2(0, 100)
var noise_amplitude = 5
var noise_speed = 5

onready var aplayer = $AnimationPlayer
var bubble = preload("res://scenes/TextBubble.tscn")
var ShockWave = preload("res://effects/ShockWave.tscn")
var dying = false


func _on_ready():
	randomize()
	noise_amplitude = 5 + randf() * 15
	randomize()
	noise_speed = 0.2 + randf() * 5

func _physics_process(_delta):
	if dying:
		return
	var time = OS.get_ticks_msec() / 1000.0

	# direction
	var t = Vector2(cos(time * noise_speed), sin(time * noise_speed))
	velocity += t
	velocity = move_and_slide(velocity)

func die():
	dying = true
	var node = ShockWave.instance()
	node.scale = scale
	add_child(node)
	aplayer.play("fade")


func _on_AnimationPlayer_animation_finished(anim_name:String):
	match anim_name:
		"fade":
			queue_free()
