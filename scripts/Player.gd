extends "res://scripts/orb.gd"


var life: int
var life_colors = [
	COLOR.BLUE,
	COLOR.GREEN,
	COLOR.YELLOW,
	COLOR.ORANGE,
	COLOR.RED
	]

export (int) var speed = 200

var velocity = Vector2()
var target = Vector2()
var has_target = false

func _input(event):
	if event.is_action_pressed("click"):
		target = get_global_mouse_position()
		has_target = true

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	velocity = velocity.normalized() * speed

func _physics_process(_delta):
	# TODO add acceleration and friction
	# TODO make delta dependent
	if has_target:
		print("Moving ")
		velocity = position.direction_to(target) * speed
		if position.distance_to(target) < 5:
			has_target = false
	else:
		get_input()
	velocity = move_and_slide(velocity)
