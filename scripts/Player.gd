extends "res://scripts/orb.gd"


var life: int
var life_colors = [
	COLOR.BLUE,
	COLOR.GREEN,
	COLOR.YELLOW,
	COLOR.ORANGE,
	COLOR.RED
	]

export (int) var max_speed = 400
export (int) var acceleration = 800
export (int) var friction = 800

var velocity = Vector2()
var target = Vector2()
var has_target = false

func _input(event):
	if event.is_action_pressed("click"):
		target = get_global_mouse_position()
		has_target = true

func get_input():
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input.normalized()
	input = input.normalized() * max_speed
	return input

func _physics_process(delta):
	# TODO add acceleration and friction

	# Mouse click / tap control
	if has_target:
		velocity = position.direction_to(target) * max_speed
		if position.distance_to(target) < 5:
			has_target = false

	# Arrow control
	else:
		var input = get_input()
		if input != Vector2.ZERO:
			velocity = velocity.move_toward(input * max_speed, acceleration * delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	velocity = move_and_slide(velocity)
