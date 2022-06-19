extends "res://scripts/orb.gd"

export var velocity: Vector2 = Vector2(0, 100)
var noise_amplitude = 5.0
var noise_speed = 5.0

onready var aplayer = $AnimationPlayer
var bubble = preload("res://scenes/TextBubble.tscn")
var ShockWave = preload("res://effects/ShockWave.tscn")
var dying = false

var wall_free = true


func _on_ready():
	yield(get_tree().create_timer(0.1, false), "timeout")
	if not wall_free:
		queue_free()

func _physics_process(_delta):
	if dying:
		return
	var time = OS.get_ticks_msec() / 1000.0

	# direction
	var t = Vector2(cos(time * noise_speed), sin(time * noise_speed))
	var l = (1.0 + randf()) * noise_amplitude

	velocity += l * t
	velocity = move_and_slide(velocity)

func die(_body: Node):
	if not is_present:
		return

	dying = true
	var node = ShockWave.instance()
	node.scale = scale
	add_child(node)
	aplayer.play("fade")
	Global.play2d(Global.SFX.pop, global_position)


func _on_AnimationPlayer_animation_finished(anim_name:String):
	match anim_name:
		"fade":
			queue_free()

func _on_WallDetection_area_entered(_area:Area2D):
	wall_free = false

func _on_Area2D_body_exited(body:Node):
	if body == self or dying:
		return
	is_colliding = false
	btimer.call_deferred("start")

# Die with one hit
func hit(body: Node):
	die(body)
