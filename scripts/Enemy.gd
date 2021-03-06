extends KinematicBody2D

onready var playerdetect = $PlayerDetect
onready var wandercontroller = $WanderController
onready var audio = $AudioStreamPlayer2D
onready var sprite = $Sprite
onready var animation = $AnimationPlayer
onready var hitarea = $HitArea

export var ACCELERATION = 300
export var MAX_SPEED = 300
export var FRICTION = 200
export var knockback_speed = 200
export var on_hurt_audio = 7
export(float, 1, 100) var sleep_on_hit_time = 20
export(int) var sleep_frame = 5
export(bool) var use_bloom = true

enum {
	IDLE,
	WANDER,
	CHASE,
	SLEEP
}

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var state = WANDER

onready var scene = get_tree().get_current_scene()

func _ready():
	randomize()
	audio.pitch_scale = rand_range(0.8, 1.4)

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	match state:
		IDLE:
			animation.play("hover")
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			update_wander()
			accelerate_towards_point(wandercontroller.target_position, delta)
			if global_position.distance_to(wandercontroller.target_position) <= MAX_SPEED * delta:
				update_wander()

		WANDER:
			animation.play("hover")
			seek_player()
			update_wander()
			accelerate_towards_point(wandercontroller.target_position, delta)
			if global_position.distance_to(wandercontroller.target_position) <= MAX_SPEED * delta:
				update_wander()
		CHASE:
			animation.play("hover")
			if playerdetect.can_see_player():
				var player = playerdetect.player
				if player.dying:
					knockback = Vector2.ZERO
					return

				accelerate_towards_point(player.global_position, delta)
			else:
				state = IDLE

		SLEEP:
			animation.stop()
			velocity = Vector2(0, 0)
			sprite.frame = sleep_frame

	velocity = move_and_slide(velocity)



func update_wander():
	if wandercontroller.get_time_left() == 0:
		state = pick_random_state([IDLE, WANDER])
		wandercontroller.start_wander_timer(rand_range(1, 3))

func seek_player():
	if playerdetect.can_see_player():
		state = CHASE

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0




func hit(_body: Node):
	if state == SLEEP:
		return

	Global.play2d(on_hurt_audio, global_position)
	var pre_modulate = sprite.modulate
	var param = "bloomIntensity"
	var bloom

	audio.stop()
	sprite.modulate = Color(0.6, 0.6, 0.6, 1)
	if use_bloom:
		bloom = sprite.material.get_shader_param(param)
		sprite.material.set_shader_param(param, 0)
	hitarea.monitoring = false
	state = SLEEP

	yield(get_tree().create_timer(sleep_on_hit_time, false), "timeout")

	state = WANDER
	audio.play()
	sprite.modulate = pre_modulate
	hitarea.monitoring = true
	if use_bloom:
		sprite.material.set_shader_param(param, bloom)


func _on_AudioStreamPlayer2D_finished():
		randomize()
		yield(get_tree().create_timer(rand_range(0.5, 2), false), "timeout")
		if state != SLEEP:
			audio.play()

func _on_HitArea_body_entered(body):
	if body == self or not body.is_in_group("hitable"):
		return

	# Should enemies hit each other? I think not... for now
	# But angels should hit demons!
	if body.is_in_group("enemy"):
		if is_in_group("demon") != body.is_in_group("demon"):
			body.hit(self)
		else:
			return

	# Player hit or spirits
	body.hit(self)
	if "size" in body:
		knockback = body.global_position.direction_to(global_position) * body.size * knockback_speed
