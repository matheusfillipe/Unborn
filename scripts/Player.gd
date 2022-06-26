extends "res://scripts/orb.gd"


var health: int = 2
var health_colors = [
	COLOR.RED,
	COLOR.YELLOW,
	COLOR.GREEN,
	]


enum {
	CONTROL
	IDLE
	}

export (int) var max_speed = 600
export (int) var knockback_speed = 1200
export (int) var acceleration = 800
export (int) var friction = 800
export (float) var noise_amplitude = 0.2
export (float, 0, 5) var noise_speed = 8
export (float, 0, 25) var size_limit = 10

var velocity = Vector2()
var target = Vector2()
var has_target = false
var state = IDLE setget set_state
export var can_attack = false setget set_can_attack

onready var rest_position = global_position
onready var timer = $RetreatTimer
onready var scenery_timer = $Timer
onready var fog = $Clouds
onready var fire = $Fire

var attack_button

var Explosion = preload("res://effects/Explosion.tscn")
var Spirit = preload("res://scripts/Spirit.gd")
var AttackButton = preload("res://scenes/AttackButton.tscn")


signal died
signal spirit_kill(color, size)

var initial_size
var dying = false
var knockback = Vector2(0, 0)

func _enter_tree():
	# Load checkpoint if any
	if Global.checkpoint != null:
		global_position = Global.checkpoint


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

func set_can_attack(_can):
	if can_attack == _can:
		return
	can_attack = _can
	if can_attack and Global.is_mobile:
		attack_button = AttackButton.instance()
		attack_button.player = self
		get_node("/root/main/Control").add_child(attack_button)

		# Get rid of bubbles. Call on all of the group
		get_tree().call_group("bubble", "hide")

func stop():
	has_target = false
	rest_position = global_position
	target = global_position

func attack():
	if can_attack:
		if is_instance_valid(attack_button):
			attack_button.queue_free()

		var explosion = Explosion.instance()
		get_parent().add_child(explosion)
		explosion.global_position = global_position
		explosion.scale = scale
		explosion.timer.wait_time = 3
		Global.play(Global.SFX.boom)

		call_deferred("set_size", initial_size)
		set_size(initial_size)
		health = 2
		set_color(health_colors[health])
		self.can_attack = false

func _unhandled_input(event):
	# Mouse click / tap control
	if event.is_action_pressed("click"):
		go_to(get_global_mouse_position())
		self.state = CONTROL

	# Mana attack (Spirit)
	if event.is_action_pressed("attack"):
		# TODO maybe use this someday
		# if get_mana() <= 0:
		# 	# not enough mana
		# 	return
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
	if dying:
		return

	if state == IDLE:
		idle()

	if knockback.length() > 0:
		velocity = move_and_slide(knockback * knockback_speed)
		return

	move(delta)
	velocity = move_and_slide(velocity)


func _on_collide(body: Node):
	if body is Spirit and not body.dying:
		# Only if a smaller one we hit
		if body.size > size:
			return

		body.hit(self)

		# Get health and grow with spirit
		var idx = health_colors.find(body.color)
		if idx > -1:
			# Set color of received spirit if it is bigger than third of the player
			if body.size > size / 3:
				set_color(body.color)
				health = idx

		# Increase
		var new_size = size + body.size/2
		if new_size > size_limit:
			new_size = size_limit
			set_color(COLOR.BLUE)
			self.can_attack = true

		set_size(new_size)
		emit_signal("spirit_kill", body.color, body.size)


func hit(body: Node):
	if dying:
		return

	health = health - 1
	if health < 0:
		die(body)
		return

	Global.play2d(Global.SFX.player_hurt, global_position)
	set_color(health_colors[health])
	knockback = body.global_position.direction_to(global_position)
	timer.start()


func die(body: Node):
	if dying:
		return

	dying = true

	var message = "You were taken to the final judgment..."
	if body.is_in_group("demon"):
		message = "You were taken to hell..."
	elif body.is_in_group("angel"):
		message = "You were taken to heaven..."

	$CollisionShape2D.call_deferred("set", "disabled", not is_present)
	$Area2D/CollisionShape2D.call_deferred("set", "disabled", not is_present)
	emit_signal("died", message)

	# fade out
	var fade = Tween.new()
	add_child(fade)
	fade.interpolate_property(
		self,
		"modulate",
		Color(10, 10, 10, 1),
		Color(1, 1, 1, 0),
		2,
		fade_in_tween.TRANS_LINEAR,
		fade_in_tween.EASE_IN_OUT
	)
	fade.start()


func _on_RetreatTimer_timeout():
	knockback = Vector2.ZERO
	stop()


# Update scenery effects
# TODO fix magic numbers mess
func _on_Timer_timeout():
	var y = global_position.y
	# heaven
	if y < -500:
		# -0.5 is nothing, 1 is max
		var value = lerp(-0.5, 1, min(abs(y+500)/40000, 1))
		fog.get_node("Sprite").material.set_shader_param("shift", value)
		fog.visible = true

	# hell
	elif y > 500:
		# 4 is nothing, 0.5 is max
		var value = lerp(3.5, 2, min(abs(y-500)/10000, 1))
		fire.get_node("Sprite").material.set_shader_param("fire_aperture", value)
		fire.visible = true

	else:
		fog.get_node("Sprite").material.set_shader_param("shift", -0.5)
		fire.get_node("Sprite").material.set_shader_param("fire_aperture", 4)
		fog.visible = false
		fire.visible = false
