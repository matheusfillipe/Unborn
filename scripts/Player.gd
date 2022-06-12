extends "res://scripts/orb.gd"


var life: int
var life_colors = [
	COLOR.BLUE,
	COLOR.GREEN,
	COLOR.YELLOW,
	COLOR.ORANGE,
	COLOR.RED
	]

enum {
	CONTROL
	IDLE
	}

export (int) var max_speed = 600
export (int) var acceleration = 800
export (int) var friction = 800
export (float) var noise_amplitude = 0.5
export (float, 0, 5) var noise_speed = 5

var velocity = Vector2()
var target = Vector2()
var has_target = false
var state = IDLE setget set_state

onready var rest_position = global_position


# Moves to a certain target. Use stop to stop.
func go_to(p_target: Vector2):
		target = p_target
		has_target = true


func set_state(new_state):
	match new_state:
		IDLE:
			stop()
	state = new_state

func stop():
	has_target = false
	rest_position = global_position
	target = global_position

func _input(event):
	# Mouse click / tap control
	if event.is_action_pressed("click"):
		go_to(get_global_mouse_position())
		self.state = CONTROL

func get_input():
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	return input.normalized()

func move(delta):
	var input = Vector2.ZERO

	if has_target:
		input = position.direction_to(target)

		# Stop moving before so that can stop in time
		# S = v_0 - at^2/2
		var S = position.distance_to(target)

		# Torricelli equation
		if velocity.length_squared() / (2 * friction) > S - get_size() - noise_amplitude:
			has_target = false
			self.state = IDLE

	# Arrow control
	var arrow_input = get_input()
	if arrow_input.length() > 0:
		stop()
		input = arrow_input
		self.state = CONTROL

	# Not clicked, no arrow input and not idling
	elif not has_target:
		self.state = IDLE

	if input != Vector2.ZERO:
		velocity = velocity.move_toward(input * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

# Idle movement
func idle():
	randomize()
	var time = OS.get_ticks_msec() / 1000.0

	# directions
	var t = Vector2(cos(time * noise_speed), sin(time * noise_speed))

	# Random length
	var l = (1 + randf()) * noise_amplitude
	go_to(rest_position + t * l)


func _physics_process(delta):
	if state == IDLE:
		idle()

	move(delta)
	velocity = move_and_slide(velocity)

	if is_colliding:
		self.state = IDLE
