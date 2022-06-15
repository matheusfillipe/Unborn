extends Node2D

var Spirit = preload("res://scenes/Spirit.tscn")

export(int, 0, 100) var ammount = 10
export(float, 0, 100) var duration = 1

var used = false

func _ready():
	add_to_group("actions")

func act(caller: Node):
	if used:
		return
	used = true

	# time to spawn by
	var spawn_by = duration / ammount

	caller.tutorial_message = "I gave you enough spirits, go catch'em all! Then explode the weak gates"

	for _i in range(ammount):
		var dir = Global.random_vec2()
		var spirit = Spirit.instance()
		add_child(spirit)

		spirit.start_color = 0
		spirit.global_position = global_position
		spirit.velocity = - dir * rand_range(50, 500)
		spirit.noise_amplitude = rand_range(1, 10)
		spirit.noise_speed = rand_range(2, 20)
		spirit.size = 0.5 + 2 * pow(10, rand_range(0, 2)) / 100

		yield(get_tree().create_timer(spawn_by, false), "timeout")
