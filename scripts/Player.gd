extends "res://scripts/orb.gd"


var health: int
var health_colors = [
	COLOR.GREEN,
	COLOR.YELLOW,
	COLOR.RED
	]


enum {
	CONTROL
	IDLE
	}

export (int) var max_speed = 600
export (int) var acceleration = 800
export (int) var friction = 800
export (float) var noise_amplitude = 0.2
export (float, 0, 5) var noise_speed = 8
export (float, 0, 25) var size_limit = 10

var velocity = Vector2()
var target = Vector2()
var has_target = false
var state = IDLE setget set_state
export var can_attack = false

onready var rest_position = global_position

var Explosion = preload("res://effects/Explosion.tscn")

var Spirit = preload("res://scripts/Spirit.gd")

var initial_size

func _on_ready():
	initial_size = size

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

func attack():
	if can_attack:
		var explosion = Explosion.instance()
		get_parent().add_child(explosion)
		explosion.global_position = global_position
		explosion.scale = scale
		explosion.timer.wait_time = 3
		Global.play(Global.SFX.boom)

		self.size = initial_size
		self.color = COLOR.GREEN

func hit(body):
	if body.is_in_group("spirit"):
		body.die()


func _input(event):
	# Mouse click / tap control
	if event.is_action_pressed("click"):
		go_to(get_global_mouse_position())
		self.state = CONTROL

	# Mana attack (Spirit)
	if event.is_action_pressed("attack"):
		# TODO Make the effect has an actual collision for enemies and damage level
		if get_mana() <= 0:
			# not enough mana
			return
		attack()


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

func get_mana() -> float:
	return size / initial_size - 1

func _physics_process(delta):
	if state == IDLE:
		idle()

	move(delta)
	velocity = move_and_slide(velocity)


func _on_color_change():
	health = health_colors.find(color)

func _on_collide(body:Node):
	if body is Spirit and not body.dying:
		# Only if a smaller one
		if body.size > size:
			return

		# Get health and grow with spirit
		var idx = health_colors.find(body.color)
		if idx > -1:
			# TODO maybe is better to average things out? or not even have this. idk
			# Set color of received spirit
			self.color = body.color

		# Increase
		var new_size = size + body.size/2
		if new_size > size_limit:
			new_size = size_limit
			self.color = COLOR.BLUE
			can_attack = true

		set_size(new_size)
		body.die()

	# TODO if enemy
	# if health == 0:
	#    die()
	# health = health_colors[health - 1]
	# color =  health_colors[health]
